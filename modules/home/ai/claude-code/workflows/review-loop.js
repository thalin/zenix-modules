export const meta = {
  name: 'review-loop',
  description: 'Review a branch with parallel Sonnet reviewers and a background host build, fix confirmed findings, repeat until clean',
  whenToUse: 'Before merging a branch in a Nix repo, when the user wants review-and-fix passes until it comes back clean. args: {repo, range?, hosts?, maxPasses?}',
  phases: [
    { title: 'Review', detail: 'parallel reviewers plus host-verify build', model: 'sonnet' },
    { title: 'Verify', detail: 'try to refute each finding' },
    { title: 'Fix', detail: 'apply confirmed findings and commit' },
  ],
}

// args: { repo: absolute path to the worktree, range?: 'main...HEAD',
//         hosts?: ['es1', ...] (default: all), maxPasses?: 4 }
const a = typeof args === 'string' ? { repo: args } : (args || {})
if (!a.repo) throw new Error('review-loop needs args.repo (absolute path to the worktree)')
const range = a.range || 'main...HEAD'
const maxPasses = a.maxPasses || 4
const hosts = a.hosts && a.hosts.length ? a.hosts.join(' ') : 'every nixosConfigurations host'

const FINDINGS = {
  type: 'object',
  properties: {
    findings: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          file: { type: 'string' },
          line: { type: 'integer' },
          severity: { type: 'string', enum: ['high', 'medium', 'low'] },
          summary: { type: 'string' },
          failure: { type: 'string', description: 'concrete scenario where this goes wrong' },
        },
        required: ['file', 'severity', 'summary', 'failure'],
      },
    },
  },
  required: ['findings'],
}
const VERDICT = {
  type: 'object',
  properties: { real: { type: 'boolean' }, reason: { type: 'string' } },
  required: ['real', 'reason'],
}
const BUILD = {
  type: 'object',
  properties: {
    hosts: {
      type: 'array',
      items: {
        type: 'object',
        properties: { host: { type: 'string' }, pass: { type: 'boolean' }, error: { type: 'string' } },
        required: ['host', 'pass'],
      },
    },
    warnings: { type: 'array', items: { type: 'string' } },
  },
  required: ['hosts'],
}

const DIMENSIONS = [
  { key: 'correctness', lens: 'correctness: Nix evaluation semantics, option types and merging, service wiring, scripts that fail at runtime' },
  { key: 'standards', lens: 'repo standards: CLAUDE.md and .claude/rules conventions (snowfall layout, zen.* namespace, module style), duplication, dead code' },
  { key: 'security', lens: 'security and ops: firewall ports, service sandboxing, secret handling (paths, never plaintext in the store), destructive scripts, failure and restore paths' },
]

const reviewPrompt = (d, pass, previous) => `Review the changes in ${range} in the git repo at ${a.repo} (pass ${pass}).
Lens: ${d.lens}.
Only report problems introduced or touched by this diff, each with a concrete failure scenario. Report nothing rather than guess.${previous.length ? `
Already fixed in earlier passes, don't re-report: ${previous.map(f => f.summary).join('; ')}` : ''}`

const fixed = []
for (let pass = 1; pass <= maxPasses; pass++) {
  phase('Review')
  log(`Pass ${pass}: ${DIMENSIONS.length} reviewers + host build`)

  // The build runs alongside the reviews; a failing host becomes a finding.
  const buildP = agent(`In ${a.repo}, evaluate and build ${hosts}. Report pass/fail per host.`,
    { label: `host-verify:pass${pass}`, phase: 'Review', agentType: 'host-verify', model: 'sonnet', schema: BUILD })

  // Each reviewer's findings are verified as soon as that reviewer finishes.
  const reviewed = await pipeline(
    DIMENSIONS,
    d => agent(reviewPrompt(d, pass, fixed), { label: `review:${d.key}`, phase: 'Review', model: 'sonnet', schema: FINDINGS }),
    r => parallel((r?.findings || []).map(f => () =>
      agent(`Try to refute this review finding for ${range} in ${a.repo}. Read the code. Answer real=false if it's wrong, already handled, or you're unsure.
${f.file}:${f.line ?? '?'} [${f.severity}] ${f.summary}
Failure scenario: ${f.failure}`, { label: `verify:${f.file}`, phase: 'Verify', schema: VERDICT })
        .then(v => (v?.real ? f : null)))),
  )
  const confirmed = reviewed.filter(Boolean).flat().filter(Boolean)

  const build = await buildP
  const failing = (build?.hosts || []).filter(h => !h.pass)
  for (const h of failing) {
    confirmed.push({ file: `host ${h.host}`, severity: 'high', summary: `${h.host} fails to build`, failure: h.error || 'see host-verify output' })
  }
  log(`Pass ${pass}: ${confirmed.length} confirmed (${failing.length} failing hosts)`)
  if (!confirmed.length) {
    return { clean: true, passes: pass, fixed, warnings: build?.warnings || [] }
  }

  phase('Fix')
  await agent(`In the git repo at ${a.repo}, fix these confirmed problems from review pass ${pass}, then commit the fixes in one commit following the repo's commit message rules. Don't push or merge.
${confirmed.map((f, i) => `${i + 1}. ${f.file}${f.line ? ':' + f.line : ''} [${f.severity}] ${f.summary}\n   ${f.failure}`).join('\n')}
If a finding turns out to be wrong, skip it and say why.`, { label: `fix:pass${pass}`, phase: 'Fix' })
  fixed.push(...confirmed)
}
log(`Stopped after ${maxPasses} passes without a clean pass`)
return { clean: false, passes: maxPasses, fixed }

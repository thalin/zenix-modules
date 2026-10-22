export const meta = {
  name: 'fleet-check',
  description: 'Health-check several hosts at once, one Sonnet fleet-check agent per host',
  whenToUse: 'When the user asks whether a group of hosts or services is running fine. args: ["es1", "es2", ...] or {hosts, focus?}',
  phases: [{ title: 'Check', detail: 'one read-only agent per host', model: 'sonnet' }],
}

// args: ["es1", "es2"] or { hosts: [...], focus?: 'what to look at closely' }
const a = Array.isArray(args) ? { hosts: args } : (args || {})
const hosts = a.hosts && a.hosts.length ? a.hosts : ['es1', 'es2', 'es3', 'ds1', 'ds2', 'ds3']
if (!(a.hosts && a.hosts.length)) log(`No hosts given; checking the eth fleet: ${hosts.join(' ')}`)

const REPORT = {
  type: 'object',
  properties: {
    host: { type: 'string' },
    status: { type: 'string', enum: ['ok', 'degraded', 'down', 'unreachable'] },
    issues: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          severity: { type: 'string', enum: ['high', 'medium', 'low'] },
          summary: { type: 'string' },
          evidence: { type: 'string' },
        },
        required: ['severity', 'summary'],
      },
    },
    checked: { type: 'string' },
  },
  required: ['host', 'status', 'issues', 'checked'],
}

phase('Check')
const reports = await parallel(hosts.map(h => () =>
  agent(`Check the health of host ${h}.${a.focus ? ` Look closely at: ${a.focus}.` : ''}`,
    { label: `fleet-check:${h}`, phase: 'Check', agentType: 'fleet-check', model: 'sonnet', schema: REPORT })))

const missing = hosts.filter((h, i) => !reports[i])
if (missing.length) log(`No report from: ${missing.join(' ')}`)
return { reports: reports.filter(Boolean), missing }

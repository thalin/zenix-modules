# Global instructions

## Git commit messages

Use `[scope]: description` for the subject line in every repo, unless that repo's own CLAUDE.md says otherwise.

- `scope` goes in literal square brackets. It names the area the commit touches: a directory, package, module, host or file. Use `[all]` for repo-wide changes.
- No conventional-commit prefixes (`feat:`, `fix:`, `chore:` …).
- Keep the description short. Add a body after a blank line when the change needs explaining.

Examples:

```
[justfile]: add command to build install iso
[sops_utils]: handle sops encrypt failure
[flake]: update nix-secrets
[git]: add worktree directory to gitignore
[all]: missed cleanup
```

## Subagents

Use subagents on Sonnet for exploration: reading and summarizing files, finding code paths, locating definitions, sweeping directories. Keep planning, design decisions and final edits on the main model.

These agents already run on Sonnet. Launch independent ones together in one message, then work from their summaries instead of re-reading the same files:

- `Explore`: code and file questions.
- `upstream-research`: nixpkgs or flake-input internals, read at the pinned revision.
- `fleet-check`: one per host, for "is everything running?" checks.
- `host-verify`: evaluate or build hosts after a change, in the background.

Forks run on the main model, so use them only when the task needs the full conversation.

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

Use subagents on Sonnet (`model: "sonnet"`) for exploration: reading and summarizing files, finding code paths, locating definitions, sweeping directories. Keep planning, design decisions and final edits on the main model.

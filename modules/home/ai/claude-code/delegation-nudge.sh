# Claude Code hook: nudge the main thread toward Sonnet subagents.
#
# PreToolUse: count back-to-back exploration calls (reads, searches, ssh,
# /nix/store greps) made by the main thread. At the threshold, attach a note
# suggesting parallel subagents. Never blocks and never makes a permission
# decision, so normal permission prompts are unaffected.
# UserPromptSubmit (arg "reset"): start a fresh count for each user prompt.

threshold="${CLAUDE_NUDGE_THRESHOLD:-4}"
input="$(cat)"

session="$(jq -r '.session_id // "none"' <<<"$input")"
state_dir="${XDG_RUNTIME_DIR:-/tmp}/claude-delegation-nudge"
mkdir -p "$state_dir"
state="$state_dir/${session//[^A-Za-z0-9_-]/_}"

if [[ "${1:-}" == reset ]]; then
  rm -f "$state"
  exit 0
fi

# Calls made inside a subagent carry agent_id; leave those alone.
if [[ -n "$(jq -r '.agent_id // empty' <<<"$input")" ]]; then
  exit 0
fi

tool="$(jq -r '.tool_name // ""' <<<"$input")"
explore=0
case "$tool" in
  Read | Grep | Glob | WebFetch | WebSearch | mcp__nixos-search__*) explore=1 ;;
  Bash)
    cmd="$(jq -r '.tool_input.command // ""' <<<"$input")"
    if grep -qE '(^|[;&|(]\s*)(ssh|cat|head|tail|grep|rg|find|fd|ls|tree|wc|journalctl)\b|sed -n|/nix/store/' <<<"$cmd" \
      && ! grep -qE '\bnix (build|eval|flake (check|update))|nixos-rebuild|\bgit (commit|merge|rebase|push)' <<<"$cmd"; then
      explore=1
    fi
    ;;
esac

if ((explore == 0)); then
  rm -f "$state"
  exit 0
fi

# Calls from one parallel batch arrive within moments of each other; count the
# batch once, since it's the serial round-trips that are slow.
now=$(date +%s%3N)
count=0 last=0
[[ -f "$state" ]] && read -r count last <"$state"
if ((now - last > 1500)); then
  count=$((count + 1))
fi
if ((count < threshold)); then
  echo "$count $now" >"$state"
  exit 0
fi
rm -f "$state"

jq -n --arg n "$count" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    additionalContext: ("The main thread has made \($n) exploration calls in a row. In this setup, multi-step reading, searching and host checks go to Sonnet subagents launched in parallel in one message: Explore for code and file questions, upstream-research for nixpkgs/flake-input internals, fleet-check for one host each, host-verify for builds. The main thread keeps design, decisions and edits, and uses the agents'"'"' summaries rather than re-reading the same files.")
  }
}'

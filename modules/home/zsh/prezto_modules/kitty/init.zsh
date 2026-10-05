# Use kitten ssh when talking to kitty directly, plain ssh otherwise
# (e.g. inside a multiplexer like herdr that doesn't answer kitty queries).
ssh() {
  # `command` bypasses this function; `which ssh` would return the function body in zsh
  if [[ -n "$(command kitten query-terminal 2>/dev/null)" ]]; then
    command kitten ssh "$@"
  else
    command ssh "$@"
  fi
}

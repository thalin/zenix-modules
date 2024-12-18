# Define the function
ssh() {
  # Get the full path to the kitten executable
  local kitten_path=$(which kitten)

  # Get the full path to the ssh executable
  local ssh_path=$(which ssh)

  # Capture the output of kitten query-terminal
  local terminal_output=$($kitten_path query-terminal)

  # Check if the output is not empty
  if [[ -n "$terminal_output" ]]; then
    # If there's output, use kitten ssh
    $kitten_path ssh "$@"
  else
    # Otherwise, use regular ssh
    $ssh_path "$@"
  fi
}

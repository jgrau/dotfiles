#!/usr/bin/env zsh

# The binding passes its pane explicitly; tmux popups do not set TMUX_PANE.
parent_session=$(tmux display-message -p -t "$WORKMUX_TASK_PANE" '#{session_name}') || exit 1
[[ -n $parent_session ]] || exit 1

# Tmux may predate the login shell that added Pax to PATH.
export PATH="$HOME/src/pax/bin:$PATH"

bindkey -e
# send-break aborts this non-interactive shell with an error status, which tmux displays.
# Cancellation is intentional, so close the popup with a successful exit instead.
cancel-task() { exit 0 }
zle -N cancel-task
bindkey '^[' cancel-task

task=''
print 'New task from main. Enter submits; Esc cancels.'
print
vared -p 'Task: ' task || exit 0
[[ -n ${task//[[:space:]]/} ]] || exit 0

# Keep task text as one argument, never executable shell input.
workmux add -A --base main --mode window --parent-session "$parent_session" -p "$task"
result=$?
if (( result != 0 )); then
  print '\nWorktree creation failed. Press any key to close.'
  read -k 1
fi
exit "$result"

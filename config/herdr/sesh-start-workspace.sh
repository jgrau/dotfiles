#!/bin/sh
# Build the standard Sesh workspace: Pax | reviewr | shell.
set -u

H=${HERDR_BIN_PATH:-herdr}
cwd=$(pwd -P)
root=${HERDR_PANE_ID:-}
[ -n "$root" ] || exec "$HOME/src/pax/bin/pax" --continue --cwd "$cwd"

# First add the rightmost plain shell, then insert reviewr to the root pane's
# right. The pane-balancer plugin evens the resulting three columns.
"$H" pane split --pane "$root" --direction right --cwd "$cwd" --no-focus >/dev/null 2>&1 ||
  printf 'sesh startup: could not create shell pane\n' >&2

"$H" plugin pane open --plugin persiyanov.reviewr --entrypoint pane \
  --placement split --target-pane "$root" --direction right \
  --cwd "$cwd" --no-focus >/dev/null 2>&1 ||
  printf 'sesh startup: could not create reviewr pane\n' >&2

exec "$HOME/src/pax/bin/pax" --continue --cwd "$cwd"

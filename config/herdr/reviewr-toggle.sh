#!/bin/sh
# Toggle reviewr, then focus away and back to force Herdr to synchronize the
# new split's PTY size. Without this, plugin split panes can retain the
# pre-split width until another focus or layout change occurs.
set -u

H=${HERDR_BIN_PATH:-herdr}

# Shell keybindings expose the UI selection as HERDR_ACTIVE_*. Override any
# stale pane context inherited by the long-running server before invoking the
# plugin action, so reviewr opens beside the pane the user actually focused.
workspace=${HERDR_ACTIVE_WORKSPACE_ID:-${HERDR_WORKSPACE_ID:-}}
active_pane=${HERDR_ACTIVE_PANE_ID:-${HERDR_PANE_ID:-}}
[ -n "$workspace" ] || exit 0
[ -z "$active_pane" ] || export HERDR_PANE_ID=$active_pane
export HERDR_WORKSPACE_ID=$workspace
[ -z "${HERDR_ACTIVE_TAB_ID:-}" ] || export HERDR_TAB_ID=$HERDR_ACTIVE_TAB_ID

find_reviewr() {
  panes=$(
    "$H" pane list --workspace "$workspace" 2>/dev/null |
      jq -r '.result.panes[].pane_id // empty' 2>/dev/null
  ) || return 1

  for pane in $panes; do
    if "$H" pane process-info --pane "$pane" 2>/dev/null |
      jq -e '
        def base: split("/") | last;
        [.result.process_info.foreground_processes[]?
          | select((((.argv0 // "") | base) == "herdr-reviewr")
              or (((((.argv // [])[0] // "") | base) == "herdr-reviewr")))]
        | length > 0' >/dev/null 2>&1; then
      printf '%s\n' "$pane"
      return 0
    fi
  done
  return 1
}

# Invocation queues the action and returns before its command settles. If this
# is a close, there is no PTY-size workaround to perform.
existing=$(find_reviewr || true)
"$H" plugin action invoke toggle --plugin persiyanov.reviewr >/dev/null || exit $?
[ -n "$existing" ] && exit 0

# On open, wait for reviewr's process and layout hooks (such as pane-balancer).
reviewr=""
attempt=0
while [ "$attempt" -lt 20 ] && [ -z "$reviewr" ]; do
  reviewr=$(find_reviewr || true)
  [ -n "$reviewr" ] || sleep 0.03
  attempt=$((attempt + 1))
done
[ -n "$reviewr" ] || exit 0
sleep 0.10

# reviewr's configured split direction is right. Focusing its left neighbor
# updates both PTYs; returning right leaves the keyboard where toggle put it.
neighbor=$(
  "$H" pane neighbor --direction left --pane "$reviewr" 2>/dev/null |
    jq -r '.result.neighbor.neighbor_pane_id // empty' 2>/dev/null
) || exit 0
[ -n "$neighbor" ] || exit 0

"$H" pane focus --direction left --pane "$reviewr" >/dev/null 2>&1 || exit 0
sleep 0.03
"$H" pane focus --direction right --pane "$neighbor" >/dev/null 2>&1 || exit 0

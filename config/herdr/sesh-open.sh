#!/bin/sh
# Regenerate the dynamic workspace list, validate it, then open herdr-sesh.
set -u

H=${HERDR_BIN_PATH:-herdr}
plugin=fullerzz.sesh
config_dir=$("$H" plugin config-dir "$plugin") || exit 1
plugin_root=$(
  "$H" plugin list --plugin "$plugin" --json 2>/dev/null |
    jq -r '.result.plugins[0].plugin_root // empty'
) || exit 1
[ -n "$plugin_root" ] || exit 1

mkdir -p "$config_dir" || exit 1
temporary="$config_dir/config.toml.tmp.$$"
trap 'rm -f "$temporary"' EXIT HUP INT TERM

"$HOME/.config/herdr/sesh-generate.py" >"$temporary" || exit 1
HERDR_PLUGIN_CONFIG_DIR="$config_dir" \
  "$plugin_root/bin/herdr-sesh" config validate "$temporary" >/dev/null || exit 1
chmod 600 "$temporary"
mv "$temporary" "$config_dir/config.toml"
trap - EXIT HUP INT TERM

workspace=${HERDR_ACTIVE_WORKSPACE_ID:-${HERDR_WORKSPACE_ID:-}}
tab=${HERDR_ACTIVE_TAB_ID:-${HERDR_TAB_ID:-}}
pane=${HERDR_ACTIVE_PANE_ID:-${HERDR_PANE_ID:-}}
cwd=${HERDR_ACTIVE_PANE_CWD:-$HOME}
[ -n "$workspace" ] || exit 1
[ -n "$pane" ] || exit 1

# Translate shell-keybinding context into the caller context consumed by the
# CLI. Overlay panes reject explicit workspace, target-pane, and cwd options.
export HERDR_WORKSPACE_ID=$workspace HERDR_PANE_ID=$pane
[ -z "$tab" ] || export HERDR_TAB_ID=$tab
cd "$cwd" || exit 1
"$H" plugin pane open --plugin "$plugin" --entrypoint picker \
  --placement overlay --focus >/dev/null

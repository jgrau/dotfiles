#!/bin/sh
# Open the selected PR head in a Herdr-managed worktree and start a direct Pax
# review session. Herdr owns the worktree/workspace; Pax owns the conversation.
set -eu

repo_name=${1:-}
repo_path=${2:-}
pr_number=${3:-}

case "$repo_name" in
  landfolk/landfolk) expected_path="$HOME/src/landfolk" ;;
  landfolk/pax) expected_path="$HOME/src/pax" ;;
  *)
    printf 'Pax review is only configured for landfolk/landfolk and landfolk/pax\n' >&2
    exit 1
    ;;
esac

case "$pr_number" in
  ''|*[!0-9]*)
    printf 'Invalid PR number: %s\n' "$pr_number" >&2
    exit 1
    ;;
esac

case "$repo_path" in
  '~/'*) repo_path="$HOME/${repo_path#\~/}" ;;
esac

repo_path=$(cd "$repo_path" 2>/dev/null && pwd -P) || {
  printf 'Repository path does not exist: %s\n' "$repo_path" >&2
  exit 1
}
expected_path=$(cd "$expected_path" && pwd -P)
if [ "$repo_path" != "$expected_path" ]; then
  printf 'Unexpected path for %s: %s\n' "$repo_name" "$repo_path" >&2
  exit 1
fi

metadata=$(gh pr view "$pr_number" --repo "$repo_name" --json headRefOid,url)
head_sha=$(printf '%s\n' "$metadata" | jq -r '.headRefOid')
pr_url=$(printf '%s\n' "$metadata" | jq -r '.url')

# Fetch GitHub's synthetic ref so same-repository and fork PRs both resolve to
# the exact selected head commit.
git -C "$repo_path" fetch --quiet --no-tags origin "pull/$pr_number/head"
fetched_sha=$(git -C "$repo_path" rev-parse FETCH_HEAD)
if [ "$fetched_sha" != "$head_sha" ]; then
  printf 'Fetched PR head does not match GitHub metadata; refresh gh-dash and retry\n' >&2
  exit 1
fi

PAX="$HOME/src/pax/bin/pax"
H=${HERDR_BIN_PATH:-herdr}
repo_short=${repo_name#*/}
short_sha=$(printf '%.8s' "$head_sha")
title="Review $repo_short #$pr_number"
branch="review/gh-dash-$repo_short-$pr_number-$short_sha"
prompt="/skill:code-review Review $pr_url in reviewer-assistance mode."

inventory=$("$H" worktree list --cwd "$repo_path")
open_workspace=$(printf '%s\n' "$inventory" | jq -r \
  --arg branch "$branch" \
  '.result.worktrees[] | select(.branch == $branch) | .open_workspace_id // empty')
if [ -n "$open_workspace" ]; then
  "$H" workspace focus "$open_workspace" >/dev/null
  exit 0
fi

existing_path=$(printf '%s\n' "$inventory" | jq -r \
  --arg branch "$branch" \
  '.result.worktrees[] | select(.branch == $branch) | .path // empty')
if [ -n "$existing_path" ]; then
  workspace=$("$H" worktree open \
    --cwd "$repo_path" \
    --path "$existing_path" \
    --label "$title" \
    --focus)
else
  workspace=$("$H" worktree create \
    --cwd "$repo_path" \
    --branch "$branch" \
    --base "$head_sha" \
    --label "$title" \
    --focus)
fi
pane_id=$(printf '%s\n' "$workspace" | jq -er '.result.root_pane.pane_id')
worktree=$(printf '%s\n' "$workspace" | jq -er '.result.worktree.path')

# Direct mode deliberately bypasses the supervised-session registry. Skip
# Pax's explicit cwd direnv import; the review can enter the development shell
# later if validation actually needs it.
"$H" pane run "$pane_id" \
  "env PAX_SKIP_CWD_DIRENV_IMPORT=1 \"$PAX\" direct --cwd \"$worktree\" -- \"$prompt\""

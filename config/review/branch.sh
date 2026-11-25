#!/usr/bin/env bash
# Review only this branch's changes, plus staged/unstaged edits.
set -euo pipefail

fail() {
  printf 'Branch review: %s\nPress Enter to close.\n' "$*" >&2
  read -r _ || true
  exit 1
}

git rev-parse --verify HEAD >/dev/null 2>&1 || fail 'Not a Git checkout with commits.'
branch=$(git symbolic-ref --quiet --short HEAD) || fail 'Check out a branch first.'

# Explicit override supports stacked branches and non-GitHub repositories.
base=$(git config --get "branch.$branch.reviewBase" || true)
if [[ -z "$base" ]] && command -v gh >/dev/null; then
  target=$(gh pr view --json baseRefName --jq .baseRefName 2>/dev/null || true)
  if [[ -n "$target" ]]; then
    if git rev-parse --verify "refs/remotes/origin/$target^{commit}" >/dev/null 2>&1; then
      base="refs/remotes/origin/$target"
    elif git rev-parse --verify "refs/heads/$target^{commit}" >/dev/null 2>&1; then
      base="refs/heads/$target"
    else
      fail "PR base '$target' is not available locally. Fetch it first."
    fi
  fi
fi
if [[ -z "$base" ]]; then
  base=$(git symbolic-ref --quiet refs/remotes/origin/HEAD || true)
fi
if [[ -z "$base" ]]; then
  for candidate in refs/remotes/origin/main refs/remotes/origin/master refs/heads/main refs/heads/master; do
    if git rev-parse --verify "$candidate^{commit}" >/dev/null 2>&1; then
      base=$candidate
      break
    fi
  done
fi
[[ -n "$base" ]] || fail "Cannot determine base. Set git config branch.$branch.reviewBase <base>."
ancestor=$(git merge-base "$base" HEAD) || fail "Cannot find merge base with $base."
head=$(git rev-parse HEAD)
printf 'Reviewing changes since %s (merge base %s), including uncommitted edits.\n' "$base" "$ancestor"

# tuicr rejects an empty commit range, even with -w.
if [[ "$ancestor" == "$head" ]]; then
  tuicr -w || fail 'tuicr exited unsuccessfully.'
else
  tuicr -r "$ancestor..HEAD" -w || fail 'tuicr exited unsuccessfully.'
fi

#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
target=$(mktemp -d)
trap 'rm -rf -- "$target"' EXIT
# Can test the newly built runtime before activating the Nix generation.
runtime=${DOTFILES_TEST_RUNTIME:-$HOME/.local/share/dotfiles-runtime}
export HOME="$target/home"
export XDG_CONFIG_HOME="$HOME/.config" XDG_CACHE_HOME="$HOME/.cache" XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state" ABBR_TMPDIR="$target/abbr-tmp"
export TERM=xterm-256color
mkdir -p "$HOME/.config/zsh" "$HOME/.local/share" "$HOME/src/pax/bin" "$target/plain"
ln -s "$runtime" "$HOME/.local/share/dotfiles-runtime"
cp "$root/home/.zshrc" "$HOME/.zshrc"
cp "$root/config/zsh/git-abbreviations.zsh" "$HOME/.config/zsh/"
cd "$target/plain"
zsh -ic '
  [[ $EDITOR == nvim && $PNPM_HOME == $HOME/Library/pnpm ]] || exit 1
  [[ ${aliases[vim]} == nvim && ${aliases[wtsm]} == "wt switch main" ]] || exit 1
  [[ -z ${aliases[ppr]-} ]] || exit 1
  (( $+functions[abbr] && $+functions[autopair-init] && $+functions[wt] )) || exit 1
  (( $+functions[tv-shell-history] || $+functions[_tv_shell_history] )) || exit 1
  [[ $(abbr expand gst) == "git status" ]] || exit 1
  [[ $(abbr expand gco) == "git checkout" ]] || exit 1
  (( ${precmd_functions[(Ie)_direnv_hook]} )) || exit 1
  [[ $STARSHIP_SHELL == zsh ]] || exit 1
  source ~/.zshrc
  [[ $(abbr expand gst) == "git status" ]] || exit 1
  [[ $(bindkey "^R") == *tv-shell-history* ]] || exit 1
  [[ $(bindkey "^T") == *tv-smart-autocomplete* ]] || exit 1
  (( ! $+functions[apici] && ! $+functions[pax] )) || exit 1
  print "zsh integrations, abbreviations, aliases and reload passed"
'
git init -q -b review/gh-dash-test "$target/review"
cd "$target/review"
zsh -ic '
  (( ! ${precmd_functions[(Ie)_direnv_hook]} )) || exit 1
  (( ! ${chpwd_functions[(Ie)_direnv_hook]} )) || exit 1
  print "review-worktree direnv exception passed"
'

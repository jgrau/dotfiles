typeset -U path cdpath fpath manpath
for profile in ${(z)NIX_PROFILES}; do
  fpath+=($profile/share/zsh/site-functions $profile/share/zsh/$ZSH_VERSION/functions $profile/share/zsh/vendor-completions)
done

HELPDIR="$HOME/.local/share/dotfiles-runtime/zsh/share/zsh/$ZSH_VERSION/help"

export EDITOR=nvim
export PNPM_HOME="$HOME/Library/pnpm"
path=("$PNPM_HOME" $path)
[[ -d "$HOME/src/pax/bin" ]] && path=("$HOME/src/pax/bin" $path)

autoload -U compinit && compinit
source "$HOME/.local/share/dotfiles-runtime/zsh-autosuggestions/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
ZSH_AUTOSUGGEST_STRATEGY=(history)




# History options should be set in .zshrc and after oh-my-zsh sourcing.
# See https://github.com/nix-community/home-manager/issues/177.
HISTSIZE="10000"
SAVEHIST="10000"

HISTFILE="$HOME/.zsh_history"
mkdir -p "$(dirname "$HISTFILE")"

setopt HIST_FCNTL_LOCK

# Enabled history options
enabled_opts=(
  HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY
)
for opt in "${enabled_opts[@]}"; do
  setopt "$opt"
done
unset opt enabled_opts

# Disabled history options
disabled_opts=(
  APPEND_HISTORY EXTENDED_HISTORY HIST_EXPIRE_DUPS_FIRST HIST_FIND_NO_DUPS
  HIST_IGNORE_ALL_DUPS HIST_SAVE_NO_DUPS
)
for opt in "${disabled_opts[@]}"; do
  unsetopt "$opt"
done
unset opt disabled_opts

if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
  source "$GHOSTTY_RESOURCES_DIR"/shell-integration/zsh/ghostty-integration
fi

# Match Fish's lightweight review-worktree startup. Remove a previous hook
# first so `reload` also respects the branch exception.
autoload -Uz add-zsh-hook
add-zsh-hook -d precmd _direnv_hook
add-zsh-hook -d chpwd _direnv_hook
if [[ "$(command git branch --show-current 2>/dev/null)" != review/gh-dash-* ]]; then
  eval "$(direnv hook zsh)"
fi

eval "$(zoxide init zsh)"

# Television owns Ctrl-R (history) and Ctrl-T (smart autocomplete).
(( $+commands[tv] )) && eval "$(tv init zsh)"
(( $+commands[wt] )) && eval "$(wt config shell init zsh)"

alias -- drb='darwin-rebuild build --flake ~/src/dotfiles#Jonass-MacBook-Pro'
alias -- drs='sudo /run/current-system/sw/bin/darwin-rebuild switch --flake ~/src/dotfiles#Jonass-MacBook-Pro'
alias -- g=git
alias -- ll='ls -lah'
alias vim=nvim
alias wm=workmux
alias wtc='wt switch --create'
alias wtl='wt list'
alias wts='wt switch'
alias wtsm='wt switch main'
alias reload='source ~/.zshrc'

# Match Fish's auto-connect behavior for bare tmux outside a session.
tmux() {
  if (( $# > 0 )) || [[ -n $TMUX ]]; then
    command tmux "$@"
  elif command tmux has-session 2>/dev/null; then
    command tmux attach-session
  else
    command tmux new-session
  fi
}

# Nix supplies plugin assets; Stow owns these settings and abbreviations.
if [[ -r "$HOME/.local/share/dotfiles-runtime/zsh-abbr/share/zsh/zsh-abbr/zsh-abbr.zsh" ]]; then
  (( $+functions[abbr] )) || source "$HOME/.local/share/dotfiles-runtime/zsh-abbr/share/zsh/zsh-abbr/zsh-abbr.zsh"
  [[ -r "$HOME/.config/zsh/git-abbreviations.zsh" ]] && ABBR_QUIETER=1 source "$HOME/.config/zsh/git-abbreviations.zsh"
fi
# Load after abbr so autopair's space widget delegates to abbreviation expansion.
if [[ -r "$HOME/.local/share/dotfiles-runtime/zsh-autopair/share/zsh/zsh-autopair/autopair.zsh" ]]; then
  (( $+functions[autopair-init] )) || source "$HOME/.local/share/dotfiles-runtime/zsh-autopair/share/zsh/zsh-autopair/autopair.zsh"
fi

# Use Starship's defaults: deliberately no custom prompt configuration.
(( $+commands[starship] )) && eval "$(starship init zsh)"

# Edit the command in the configured editor, then return it to the prompt.
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# Syntax highlighting must load after widgets and other shell integrations.
source "$HOME/.local/share/dotfiles-runtime/zsh-syntax-highlighting/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
ZSH_HIGHLIGHT_HIGHLIGHTERS+=()



# Commands that should be applied only for interactive shells.
[[ $- == *i* ]] || return

HISTFILESIZE=100000
HISTSIZE=10000

shopt -s histappend
shopt -s extglob
shopt -s globstar
shopt -s checkjobs

alias drb='darwin-rebuild build --flake ~/src/dotfiles#Jonass-MacBook-Pro'
alias drs='sudo /run/current-system/sw/bin/darwin-rebuild switch --flake ~/src/dotfiles#Jonass-MacBook-Pro'
alias g=git
alias ll='ls -lah'

if [[ ! -v BASH_COMPLETION_VERSINFO ]]; then
  . "$HOME/.local/share/dotfiles-runtime/bash-completion/etc/profile.d/bash_completion.sh"
fi

if [[ -n "${GHOSTTY_RESOURCES_DIR}" ]]; then
  builtin source "${GHOSTTY_RESOURCES_DIR}/shell-integration/bash/ghostty.bash"
fi

eval "$(zoxide init bash)"

eval "$(direnv hook bash)"

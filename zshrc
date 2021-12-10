source "$HOME/.zshrc.exports"
source "$HOME/.zshrc.credentials"
source "$HOME/.zshrc.gcl"
source "$HOME/.zshrc.kubectl_aliases"
source "$HOME/.zshrc.completions"
# source "$HOME/.zshrc.local"

setopt nonomatch
setopt append_history
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups # ignore duplication command history list
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history
setopt share_history # share command history data
setopt hist_ignore_all_dups

eval "$(direnv hook zsh)"

alias reload="source ~/.zshrc"
alias ppr="git push -u origin \$(git rev-parse --abbrev-ref HEAD) && gh pr create"
alias git-clean='git branch --merged | grep -v "\*" | grep -v master | grep -v development | xargs -n 1 git branch -d'
alias vim=nvim

# zplug
[[ -r "${HOME}/.zplug/init.zsh" ]] || git clone https://github.com/zplug/zplug.git "${HOME}/.zplug"
source "${HOME}/.zplug/init.zsh"

# let zplug manage itself
zplug 'zplug/zplug', hook-build:'zplug --self-manage'

# plugins
zplug "plugins/git", from:oh-my-zsh
zplug "plugins/z", from:oh-my-zsh
zplug "mafredri/zsh-async", from:github
zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme
zplug "junegunn/fzf-bin", from:gh-r, as:command, rename-to:fzf
zplug "kiurchv/asdf.plugin.zsh", defer:2
zplug "lukechilds/zsh-nvm"
zplug "plugins/tmux", from:oh-my-zsh

# Install if not installed
zplug check || zplug install

# Then, source plugins and add commands to $PATH
zplug load

## Command history configuration
if [ -z "$HISTFILE" ]; then
  HISTFILE=$HOME/.zsh_history
fi

HISTSIZE=10000
SAVEHIST=10000

# Show history
case $HIST_STAMPS in
  "mm/dd/yyyy") alias history='fc -fl 1' ;;
  "dd.mm.yyyy") alias history='fc -El 1' ;;
  "yyyy-mm-dd") alias history='fc -il 1' ;;
  *) alias history='fc -l 1' ;;
esac

# History search
bindkey '^R' history-incremental-search-backward

# Edit command line
# Enable Ctrl-x-e to edit command line
autoload -U edit-command-line

# Emacs style
# zle -N edit-command-line
# bindkey '^xe' edit-command-line
# bindkey '^x^e' edit-command-line

# Vi style:
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

if [[ ! -d ~/.tmux/plugins/tpm ]] ; then
  echo "tpm not available, set it up with 'tpm-install' (needs Git and Internet access)"
  tpm-install () {
  mkdir -p ~/.tmux/plugins
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  echo "not (re)start tmux and use 'C-b I' to install configured plugins"
  unfunction tpm-install
}
fi

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
test -e /Users/jgrau/.iterm2_shell_integration.zsh && source /Users/jgrau/.iterm2_shell_integration.zsh || true

# GPG
GPG_TTY=$(tty)
export GPG_TTY
. "/Users/jgrau/.acme.sh/acme.sh.env"

# rbenv
eval "$(rbenv init - zsh)"

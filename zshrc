source "$HOME/.zshrc.local"

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

export PATH="$HOME/bin:$HOME/go/bin:$PATH"
# export PATH="/usr/local/sbin:$PATH"
# export PATH="$HOME/.cargo/bin:$PATH"
# export ZPLUG_HOME=/usr/local/opt/zplug
# export DEFAULT_USER=jgrau
# export EDITOR='nvim'
# export VISUAL='nvim'
export TERMINAL='termite'
export EDITOR='vim'
export VISUAL='vim'
# export PURE_GIT_PULL=0
# export HOMEBREW_CASK_OPTS="--appdir=/Applications"
export DIGITALOCEAN_ACCESS_TOKEN=68503ad4e128d49df44d13e53122fa897f503d27a2bc0afc73394988325d7c50

# source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'
# source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'
# source <(kubectl completion zsh)
# source <(helm completion zsh)

eval "$(direnv hook zsh)"
# eval "$(rbenv init -)"

# alias vim="nvim"
alias reload="source ~/.zshrc"
alias ppr="git push -u origin \$(git rev-parse --abbrev-ref HEAD) && hub pull-request"
alias git-clean='git branch --merged | grep -v "\*" | grep -v master | grep -v development | xargs -n 1 git branch -d'
alias fix-structure-conflict='git checkout master -- db/structure.sql && make rebuild-database && rails db:migrate && git add db/structure.sql && git rebase --continue'
alias migr='rails db:migrate:with_data db:test:prepare'
alias fixt='rails db:fixtures:load'
alias t='rails test'

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

# Enable Ctrl-x-e to edit command line
autoload -U edit-command-line
# Emacs style
zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line
# Vi style:
# zle -N edit-command-line
# bindkey -M vicmd v edit-command-line

# History search
bindkey '^R' history-incremental-search-backward

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

source "$HOME/.antigen/antigen.zsh"

# Load the oh-my-zsh's library.
# antigen use oh-my-zsh
antigen bundle robbyrussell/oh-my-zsh lib/

antigen bundles <<EOBUNDLES
  # Theme
  mafredri/zsh-async
  sindresorhus/pure

  # # Git and github autocompletions and aliases
  git
  # git-extras
  git-flow

  # # Tools of the trade
  # brew
  # gem
  # capistrano

  # # More tools
  # vagrant
  # tmux

  # # Meta
  # tmuxinator
  # command-not-found
  # zsh-users/zsh-syntax-highlighting
  zsh-users/zsh-history-substring-search

  # colored-man
  # history
  # history-substring-search

  # # Utilities
  rupa/z
EOBUNDLES

# antigen-update
# antigen-selfupdate

# Tell antigen that you're done.
antigen apply

# Customize to your needs...
alias mvim="reattach-to-user-namespace mvim"
# alias vim="reattach-to-user-namespace mvim -v"
alias vim="nvim"
alias work="cd ~/Sites $1"
alias reload="source ~/.zshrc"
alias gff="git flow feature"
alias gffc="git flow feature checkout"
alias gffs="git flow feature start"
alias gfff="git flow feature finish"
alias gffp="git flow feature publish"
alias gfft="git flow feature track"
alias ppr="git flow feature publish \$(current_branch) && hub pull-request"
alias zshbench='reload && /usr/bin/time zsh -i -c exit'

setopt nonomatch
# export PATH=/usr/local/bin:/usr/local/share/npm/bin:$PATH:~/bin
# export PATH=$PATH:/Users/jgrau/pear/bin

### Added by the Heroku Toolbelt
# export PATH="/usr/local/heroku/bin:$PATH"
export DEFAULT_USER=jgrau
export EDITOR='mvim -v'
export PURE_GIT_PULL=0

bindkey '^R' history-incremental-search-backward

eval "$(direnv hook zsh)"
eval "$(rbenv init -)"

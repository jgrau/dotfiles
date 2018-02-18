export PATH="$HOME/.cargo/bin:$PATH"

source "$HOME/.antigen/antigen.zsh"

# Load the oh-my-zsh's library.
antigen use oh-my-zsh
# antigen bundle robbyrussell/oh-my-zsh lib/

antigen bundles <<EOBUNDLES
  # Theme
  mafredri/zsh-async
  sindresorhus/pure

  # # Git and github autocompletions and aliases
  git
  # git-extras
  # git-flow

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
alias ppr="git push -u origin \$(git rev-parse --abbrev-ref HEAD) && hub pull-request"
alias zshbench='reload && /usr/bin/time zsh -i -c exit'
alias git-clean='git branch --merged | grep -v "\*" | grep -v master | grep -v development | xargs -n 1 git branch -d'

alias docker-reload='eval "$(docker-machine env default)"'
alias docker-clean='docker rmi $(docker images -f "dangling=true" -q)'
alias dip='docker-reload && docker-machine ip default'
alias odip='open http://`dip`:3000 && open http://`dip`:4000 && open http:://`dip`:5000'
alias docker-open='docker-reload && docker-compose build && docker-compose up & echo "Waiting for docker..." && sleep 20 && odip && fg'
alias dc='docker-compose'
alias dcb='docker-compose build'
alias dcup='docker-compose up'
alias dcr='docker-compose run'
alias dcra='docker-compose run api'
alias dcrw='docker-compose run web'

alias fix-structure-conflict='git checkout master -- db/structure.sql && make rebuild-database && rails db:migrate && git add db/structure.sql && git rebase --continue'
alias migr='rails db:migrate db:test:prepare'
alias fixt='rails db:fixtures:load'
alias t='rails test'
alias prodcon='heroku run rails c -r production'
alias stagcon='heroku run rails c -r staging'

alias git recap='git log --all --oneline --no-merges --author=jonas.grau@gmail.com'
setopt nonomatch
# export PATH=/usr/local/bin:/usr/local/share/npm/bin:$PATH:~/bin
# export PATH=$PATH:/Users/jgrau/pear/bin

### Added by the Heroku Toolbelt
# export PATH="/usr/local/heroku/bin:$PATH"
export DEFAULT_USER=jgrau
export EDITOR='nvim'
export PURE_GIT_PULL=0
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
export DIGITALOCEAN_ACCESS_TOKEN=19d43d25db0ac54f33948fffa0cd7bb5d7e4bbc74df362d386a68c7aa6c99267

bindkey '^R' history-incremental-search-backward

# eval "$(thefuck --alias)"
eval "$(direnv hook zsh)"
eval "$(rbenv init -)"

source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'

source <(kubectl completion zsh)
source <(helm completion zsh)
export PATH="/usr/local/sbin:$PATH"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export PATH="/usr/local/opt/postgresql@9.6/bin:$PATH"
export PATH="$PATH:~/src/k8s-utils"

autoload -U colors; colors
source /usr/local/etc/zsh-kubectl-prompt/kubectl.zsh
RPROMPT='%{$fg[blue]%}($ZSH_KUBECTL_PROMPT)%{$reset_color%}'

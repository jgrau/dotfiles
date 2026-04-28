alias vim=nvim
alias reload="source ~/.config/fish/config.fish"
alias ppr="gh pr create"
fish_add_path /Users/jgrau/src/pax/bin
alias wts="wt switch"
alias wtsm="wt switch main"
alias wtc="wt switch --create"

set -gx EDITOR nvim

# Remove !!, git! and gh! as github-copilot-cli functions. See
# https://github.com/z11i/github-copilot-cli.fish
functions -e !! git! gh!

# pnpm
set -gx PNPM_HOME "/Users/jgrau/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

tv init fish | source

direnv hook fish | source

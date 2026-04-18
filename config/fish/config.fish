alias vim=nvim
alias reload="source ~/.config/fish/config.fish"
alias ppr="gh pr create"

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

direnv hook fish | source

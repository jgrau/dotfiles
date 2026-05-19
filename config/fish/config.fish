if test -d ~/src/pax/bin
  fish_add_path ~/src/pax/bin
end

alias vim=nvim
alias reload="source ~/.config/fish/config.fish"
alias ppr="gh pr create"
alias wts="wt switch"
alias wtsm="wt switch main"
alias wtc="wt switch --create"
alias wtl="wt list"

set -gx EDITOR nvim

# Remove !!, git! and gh! as github-copilot-cli functions. See
# https://github.com/z11i/github-copilot-cli.fish
functions -e !! git! gh!

# pnpm
set -gx PNPM_HOME "$HOME/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

tv init fish | source
direnv hook fish | source

# Tide prompt items
set -g tide_left_prompt_items pwd git newline character
set -g tide_right_prompt_items status cmd_duration jobs direnv ruby time

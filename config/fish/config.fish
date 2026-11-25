status is-login; and begin

    # Login shell initialisation

end

status is-interactive; and begin

    # Abbreviations

    # Aliases
    alias drb 'darwin-rebuild build --flake ~/src/dotfiles#$DOTFILES_HOST'
    alias drs 'sudo /run/current-system/sw/bin/darwin-rebuild switch --flake ~/src/dotfiles#$DOTFILES_HOST'
    alias g git
    alias ll 'ls -lah'
    alias ppr 'gh pr create'
    alias reload 'source ~/.config/fish/config.fish'
    alias vim nvim
    alias wtc 'wt switch --create'
    alias wtl 'wt list'
    alias wts 'wt switch'
    alias wtsm 'wt switch main'

    # Interactive shell initialisation
    zoxide init fish | source

    if set -q GHOSTTY_RESOURCES_DIR
        source "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
    end


    functions -e __direnv_export_eval __direnv_cd_hook
    set -l current_branch (command git branch --show-current 2>/dev/null)
    if not string match -q 'review/gh-dash-*' -- "$current_branch"
        direnv hook fish | source
    end

    if test -d ~/src/pax/bin
        fish_add_path ~/src/pax/bin
    end

    set -gx EDITOR nvim
    set -gx PNPM_HOME "$HOME/Library/pnpm"
    if not string match -q -- $PNPM_HOME $PATH
        fish_add_path --prepend $PNPM_HOME
    end

    if command -q tv
        tv init fish | source
    end

    # worktrunk shell integration (lets `wt switch` change the shell's CWD)
    if command -q wt
        wt config shell init fish | source
    end

    # Tide prompt items
    set -g tide_cmd_duration_threshold 3000
    set -g tide_cmd_duration_decimals 0
    set -g tide_left_prompt_items pwd git newline character
    set -g tide_right_prompt_items status cmd_duration jobs direnv ruby time

end

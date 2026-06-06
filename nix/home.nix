{ pkgs, lib, ... }:

{
  home.username = "jgrau";
  home.homeDirectory = "/Users/jgrau";

  # Keep this pinned to the Home Manager release used for the first activation.
  # Do not bump it just because the flake inputs are updated.
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    _1password-cli
    ack
    act
    difftastic
    direnv
    doctl
    fd
    fzf
    gh
    gitleaks
    go-task
    graphviz
    imagemagick
    jq
    nerd-fonts.meslo-lg
    neovim
    ripgrep
    tealdeer
    television
    tig
    tree
    watch
    wget
    zoxide
  ];

  programs.home-manager.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
  };

  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty-bin;
    enableFishIntegration = true;

    settings = {
      font-family = "MesloLGS Nerd Font Mono";
      font-size = 14;
      macos-titlebar-style = "tabs";
      window-padding-x = 8;
      window-padding-y = 8;
    };
  };

  programs.git = {
    enable = true;
    includes = [
      { path = "~/.gitconfig.local"; }
    ];
    settings = {
      user.name = "Jonas Grau";
      user.email = "jonas.grau@gmail.com";
      core = {
        excludesfile = "~/.gitignore";
        attributesfile = "~/.gitattributes";
      };
      pull.rebase = true;
      diff = {
        external = "difft";
        algorithm = "histogram";
      };
      merge.conflictStyle = "zdiff3";
      commit.verbose = true;
      rerere.enabled = true;
      rebase.autoStash = true;
      "diff \"rspec\"".xfuncname = "^[ \\t]*((RSpec|describe|context|it|before|after|around|feature|scenario)[ \\t].*)$";
    };
  };

  programs.fish = {
    enable = true;
    plugins = with pkgs.fishPlugins; [
      { name = "autopair"; src = autopair-fish.src; }
      { name = "done"; src = done.src; }
      { name = "fzf.fish"; src = fzf-fish.src; }
      {
        name = "plugin-git";
        src = pkgs.fetchFromGitHub {
          owner = "jhillyerd";
          repo = "plugin-git";
          rev = "dd1f559c01cde4cf0d16581b60e20d29f33c0665";
          sha256 = "sha256-ByEqv5mZ6S9K+Pkpf1Dybwfqh3x++3AhXaMtw0I3wDo=";
        };
      }
      {
        name = "fish-abbreviation-tips";
        src = pkgs.fetchFromGitHub {
          owner = "gazorby";
          repo = "fish-abbreviation-tips";
          rev = "8ed76a62bb044ba4ad8e3e6832640178880df485";
          sha256 = "sha256-F1t81VliD+v6WEWqj1c1ehFBXzqLyumx5vV46s/FZRU=";
        };
      }
      { name = "puffer"; src = puffer.src; }
      { name = "tide"; src = tide.src; }
      {
        name = "tmux";
        src = pkgs.fetchFromGitHub {
          owner = "budimanjojo";
          repo = "tmux.fish";
          rev = "db0030b7f4f78af4053dc5c032c7512406961ea5";
          sha256 = "sha256-rRibn+FN8VNTSC1HmV05DXEa6+3uOHNx03tprkcjjs8=";
        };
      }
    ];
    interactiveShellInit = ''
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

      # Tide prompt items
      set -g tide_cmd_duration_threshold 3000
      set -g tide_cmd_duration_decimals 0
      set -g tide_left_prompt_items pwd git newline character
      set -g tide_right_prompt_items status cmd_duration jobs direnv ruby time
    '';
    shellAliases = {
      drb = "darwin-rebuild build --flake ~/src/dotfiles#Jonass-MacBook-Pro";
      drs = "sudo /run/current-system/sw/bin/darwin-rebuild switch --flake ~/src/dotfiles#Jonass-MacBook-Pro";
      g = "git";
      ll = "ls -lah";
      ppr = "gh pr create";
      reload = "source ~/.config/fish/config.fish";
      vim = "nvim";
      wtc = "wt switch --create";
      wtl = "wt list";
      wts = "wt switch";
      wtsm = "wt switch main";
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      drb = "darwin-rebuild build --flake ~/src/dotfiles#Jonass-MacBook-Pro";
      drs = "sudo /run/current-system/sw/bin/darwin-rebuild switch --flake ~/src/dotfiles#Jonass-MacBook-Pro";
      g = "git";
      ll = "ls -lah";
    };
    initContent = ''
      eval "$(zoxide init zsh)"
    '';
  };

  programs.tmux = {
    enable = true;
    prefix = "C-f";
    keyMode = "vi";
    mouse = true;
    baseIndex = 1;
    escapeTime = 0;
    focusEvents = true;
    terminal = "tmux-256color";

    # Plugins are installed and wired up by nix (no TPM needed). Order matters:
    # catppuccin must load before the status-bar format lines in extraConfig
    # that reference its @thm_* variables.
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      pain-control
      vim-tmux-navigator
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor "mocha"
          set -g @catppuccin_pane_border_style "fg=#{@thm_overlay_0}"
          set -g @catppuccin_pane_active_border_style "fg=#{@thm_sky},bold"
        '';
      }
      {
        plugin = fzf-tmux-url;
        extraConfig = ''
          set -g @fzf-url-bind "u"
          set -g @fzf-url-history-limit "2000"
        '';
      }
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-processes 'vi vim nvim ssh psql mysql irb pry rails console node pnpm npm yarn make task "~bin/pax" "~bin/pax interactive" "~bin/pax-task" "~pi"'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
      }
    ];

    extraConfig = builtins.readFile ../tmux.conf;
  };

  home.file.".gitattributes".source = ../gitattributes;
  home.file.".gitignore".source = ../gitignore;
  home.file.".gemrc".source = ../gemrc;
  home.file.".tigrc".source = ../tigrc;

  # Deploy the Neovim (lazy.nvim) config from the repo into ~/.config/nvim.
  # We link individual files (recursive) rather than the whole dir, and
  # deliberately EXCLUDE lazy-lock.json: lazy.nvim needs to write that file
  # at runtime, but anything linked from the Nix store is read-only. Leaving
  # it out lets lazy own a normal, writable lockfile in ~/.config/nvim.
  xdg.configFile = let
    nvimSrc = ../config/nvim;
    # All files under config/nvim except the lazy lockfile.
    nvimFiles = lib.filterAttrs
      (name: _: name != "lazy-lock.json")
      (builtins.readDir nvimSrc);
  in lib.mapAttrs'
    (name: _: lib.nameValuePair "nvim/${name}" {
      source = nvimSrc + "/${name}";
      recursive = true;
    })
    nvimFiles;
}

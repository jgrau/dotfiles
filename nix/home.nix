{ pkgs, lib, inputs, ... }:

let
  # Caprine's bundled Electron 41.6.1 crashes on sign-in on macOS 26 (Tahoe)
  # — an upstream V8/MAP_JIT bug (electron/electron#49522). JIT-disabling
  # flags don't reach the crashing process, so rebuild against a newer,
  # non-EOL Electron (42) that includes the fix.
  #
  # NB: do NOT rename/modify or re-sign this bundle. macOS 26 only grants the
  # implicit JIT permission to the pristine ad-hoc linker-signed bundle; any
  # renamed/re-signed copy loses that grant and re-triggers the crash. (We
  # tried surfacing it as "Messenger" via both a renamed bundle and a separate
  # launcher .app — macOS 26 blocks both — so it stays branded "Caprine".)
  caprineApp = pkgs.caprine.override { electron = pkgs.electron_42; };

  # TomatoBar: menu bar pomodoro timer. The Homebrew cask is deprecated (fails
  # Gatekeeper) and the upstream build is only ad-hoc signed ("CI Code Signing",
  # no Team ID / notarization), so we fetch the release zip directly, pin it by
  # hash, and strip the quarantine xattr in a home.activation step below.
  tomatobarApp = pkgs.runCommand "tomatobar-3.6.1" {
    src = pkgs.fetchurl {
      url = "https://github.com/ivoronin/TomatoBar/releases/download/v3.6.1/TomatoBar-v3.6.1.zip";
      hash = "sha256-iA0fS0R0k1/KVyP/vaCZU3ZxbYvJTkmf9aVMvHub5wI=";
    };
    nativeBuildInputs = [ pkgs.unzip ];
  } ''
    mkdir -p "$out/Applications"
    unzip -q "$src" -d "$out/Applications"
  '';
in
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
    caprineApp   # Facebook Messenger desktop app (Caprine on Electron 42; see let block)
    difftastic
    direnv
    doctl
    duti  # set default macOS handlers (e.g. Ghostty for shell scripts)
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
    nodejs   # provides npm, used by `pi install` to fetch pi packages
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi  # pi coding agent
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
    config = {
      hide_env_diff = true;
      # Auto-trust .envrc in landfolk worktrees (siblings named landfolk.<branch>)
      # so newly-created worktrees load without a manual `direnv allow`. The
      # trailing dot keeps this from also matching landfolk-api-* etc.; the main
      # repo is whitelisted by its exact .envrc path.
      whitelist.prefix = [
        "/Users/jgrau/src/worktrees"
        "/Users/jgrau/src/landfolk."
      ];
      whitelist.exact = [
        "/Users/jgrau/src/landfolk/.envrc"
      ];
    };
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
  };

  # Make Ghostty the default app for shell-script file types (the closest macOS
  # equivalent to a "default terminal"). Re-applied on every activation; duti is
  # idempotent. macOS has no setting for the Finder "Open in Terminal" button —
  # Apple hardcodes that to Terminal.app — so this covers .sh/.command/etc.
  home.activation.ghosttyDefaultHandler =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      DUTI="${pkgs.duti}/bin/duti"
      GHOSTTY_ID="com.mitchellh.ghostty"
      for uti in \
        public.shell-script \
        public.unix-executable \
        com.apple.terminal.shell-script \
        public.zsh-script \
        public.csh-script \
        public.perl-script; do
        run "$DUTI" -s "$GHOSTTY_ID" "$uti" all || true
      done
      # Note: no `.terminal` — that extension is Terminal.app profile plists,
      # not a shell script, and has no registered UTI (duti errors with -50).
      for ext in sh command tool; do
        run "$DUTI" -s "$GHOSTTY_ID" ".$ext" all || true
      done
    '';

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

      # Animated trailing cursor (smear effect). Reloadable at runtime
      # (cmd+shift+,). Trail color follows `cursor-color`.
      custom-shader = "shaders/cursor_smear.glsl";

      # Quick terminal (Quake-style dropdown), centered on screen.
      keybind = "global:alt+tab=toggle_quick_terminal";
      quick-terminal-position = "center";
      # ~60% of the screen so it also fits comfortably on the laptop
      # display when the external monitor is unplugged.
      quick-terminal-size = "60%,60%";
    };
  };

  # TomatoBar menu bar pomodoro timer (see tomatobarApp in the let block).
  home.file."Applications/TomatoBar.app" = {
    source = "${tomatobarApp}/Applications/TomatoBar.app";
    recursive = true;
  };

  # The Nix-store copy of TomatoBar can carry the com.apple.quarantine xattr,
  # and the app is only ad-hoc signed, so Gatekeeper blocks it. Strip the
  # attribute from the linked bundle on every activation.
  home.activation.dequarantineTomatoBar =
    lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      run /usr/bin/xattr -dr com.apple.quarantine \
        "$HOME/Applications/TomatoBar.app" 2>/dev/null || true
    '';


  imports = [ inputs.hunk.homeManagerModules.default ];

  # hunk: review-first terminal diff viewer. enableGitIntegration sets it as
  # the git pager (core.pager = "hunk pager"); it does not touch diff.external
  # (difftastic), so the two coexist.
  programs.hunk = {
    enable = true;
    enableGitIntegration = true;
    settings = {
      theme = "auto";
      mode = "auto";
      line_numbers = true;
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
      # hunk (core.pager) intercepts diff/show output for its TUI, but plain
      # `git log` produces no diff and hangs in hunk's pager. Route `git log`
      # through less instead. Note: this also applies to `git log -p`.
      pager.log = "less -FRX";
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

      # worktrunk shell integration (lets `wt switch` change the shell's CWD)
      if command -q wt
        wt config shell init fish | source
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

  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      drb = "darwin-rebuild build --flake ~/src/dotfiles#Jonass-MacBook-Pro";
      drs = "sudo /run/current-system/sw/bin/darwin-rebuild switch --flake ~/src/dotfiles#Jonass-MacBook-Pro";
      g = "git";
      ll = "ls -lah";
    };
    initExtra = ''
      eval "$(zoxide init bash)"
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
      resurrect
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

  # Deploy the Neovim (vim.pack) config from the repo into ~/.config/nvim.
  # We link individual files (recursive) rather than the whole dir, and
  # deliberately EXCLUDE nvim-pack-lock.json: vim.pack needs to write that
  # file at runtime, but anything linked from the Nix store is read-only.
  # Leaving it out lets vim.pack own a normal, writable lockfile in
  # ~/.config/nvim.
  xdg.configFile = let
    nvimSrc = ../config/nvim;
    # All files under config/nvim except the vim.pack lockfile.
    nvimFiles = lib.filterAttrs
      (name: _: name != "nvim-pack-lock.json")
      (builtins.readDir nvimSrc);
    nvimConfig = lib.mapAttrs'
      (name: _: lib.nameValuePair "nvim/${name}" {
        source = nvimSrc + "/${name}";
        recursive = true;
      })
      nvimFiles;
  in nvimConfig // {
    "ghostty/pi-app".source = ../config/ghostty/pi-app;
    "ghostty/shaders/cursor_smear.glsl".source = ../config/ghostty/shaders/cursor_smear.glsl;
    "ghostty/pi.icns".source = ../config/ghostty/pi.icns;
  };
}

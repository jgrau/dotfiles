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
  fishPlugins = with pkgs.fishPlugins; [
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
  tmuxPlugins = with pkgs.tmuxPlugins; [ sensible yank pain-control vim-tmux-navigator catppuccin fzf-tmux-url ];
  runtimePackages = with pkgs; { inherit bash-completion zsh zsh-abbr zsh-autopair zsh-autosuggestions zsh-syntax-highlighting nix-direnv; };
  runtime = pkgs.linkFarm "dotfiles-runtime" (
    (map (p: { name = "fish-${p.name}"; path = p.src; }) fishPlugins)
    ++ (map (p: { name = p.pname; path = p; }) tmuxPlugins)
    ++ (lib.mapAttrsToList (name: path: { inherit name path; }) runtimePackages)
  );
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
    bat  # syntax-highlighting cat; used by herdr-plugin-sesh fzf picker preview
    bun  # required by herdr-plugin-gh-pr hooks (bun bin/*.ts)
    caprineApp   # Facebook Messenger desktop app (Caprine on Electron 42; see let block)
    difftastic
    direnv
    doctl
    duti  # set default macOS handlers (e.g. Ghostty for shell scripts)
    fd
    fzf
    gh
    gh-dash
    gitleaks
    go
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
    inputs.tuicr.packages.${pkgs.stdenv.hostPlatform.system}.default
    watch
    wget
    zoxide
    starship
    stow
    bashInteractive
    bash-completion
    fish
    git
    ghostty-bin
    tmux
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    nix-direnv
    inputs.hunk.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Home Manager owns software/assets only. Editable dotfiles live in stow/.
  programs.home-manager.enable = true;
  programs.man.enable = false;
  home.file.".local/share/dotfiles-runtime".source = runtime;
  xdg.dataFile."gh/extensions/gh-dash".source = "${pkgs.gh-dash}/bin";

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


}

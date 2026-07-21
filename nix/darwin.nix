{ self, lib, pkgs, inputs, ... }:

{
  # Pin Neovim to the unstable channel for a newer release than 25.11 ships.
  nixpkgs.overlays = [
    (final: prev: {
      neovim = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.neovim;
      neovim-unwrapped = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.neovim-unwrapped;
    })
  ];

  system.primaryUser = "jgrau";

  users.knownUsers = [ "jgrau" ];
  users.users.jgrau = {
    name = "jgrau";
    uid = 501;
    gid = 20;
    home = "/Users/jgrau";
    shell = pkgs.fish;
  };

  networking.hostName = "Jonass-MacBook-Pro";       # scutil --set HostName
  networking.localHostName = "Jonass-MacBook-Pro";  # scutil --set LocalHostName (Bonjour .local)
  networking.computerName = "Jonas’s MacBook Pro";   # scutil --set ComputerName (Finder/UI name)

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "1password-cli"
  ];

  nix.settings = {
    experimental-features = "nix-command flakes";
    trusted-users = [ "@admin" "jgrau" ];
  };

  environment.systemPackages = with pkgs; [
    vim
  ];

  programs.zsh.enable = true;
  programs.fish.enable = true;

  # Homebrew is managed declaratively via nix-homebrew (see flake.nix).
  # Add brews/casks here as needed.
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap"; # remove anything not listed below
      upgrade = true;
    };
    brews = [
      "worktrunk"  # `wt` — Git worktree management for parallel AI agent workflows
      "sox"         # audio recording — required by Raycast "Whisper Dictation" extension
      "whisper-cpp" # local speech-to-text engine — required by Raycast "Whisper Dictation" extension
    ];
    casks = [
      "1password"
      "brave-browser"
      "google-chrome"
      "iina"
      "lens"
      "linear"
      "mimestream"
      "notion"
      "raycast"
      "slack"
      "spotify"
      "telegram"
    ];
    # NOTE: TomatoBar's cask is deprecated (fails Gatekeeper); it's installed
    # declaratively from the GitHub release in nix/home.nix instead.
  };

  # Allow authenticating sudo (e.g. `drs`) with Touch ID / Apple Watch
  # instead of typing the password. Managed declaratively so it survives
  # macOS updates that would otherwise reset /etc/pam.d/sudo.
  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults.dock.autohide = true;

  system.defaults.NSGlobalDomain = {
    # Lower values are faster. Both were near the fastest macOS accepts,
    # causing duplicate characters. InitialKeyRepeat (delay before repeat
    # starts) bumped 10->15 and KeyRepeat (repeat rate) bumped 1->2 to give
    # a longer grace period and slower repeat while staying responsive.
    InitialKeyRepeat = 15;
    KeyRepeat = 2;
  };

  # Mouse tracking speed (System Settings > Mouse > Tracking speed).
  # 3.0 is the fastest the macOS slider goes; values above it have no effect.
  # Set to -1.0 to disable mouse acceleration entirely.
  system.defaults.".GlobalPreferences"."com.apple.mouse.scaling" = 3.0;

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility. Read `darwin-rebuild changelog` before changing.
  system.stateVersion = 6;
}

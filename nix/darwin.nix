{ self, lib, pkgs, ... }:

{
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
    brews = [ ];
    casks = [
      "1password"
      "brave-browser"
      "google-chrome"
      "lens"
      "linear"
      "mimestream"
      "raycast"
      "slack"
      "spotify"
      "telegram"
    ];
  };

  # Allow authenticating sudo (e.g. `drs`) with Touch ID / Apple Watch
  # instead of typing the password. Managed declaratively so it survives
  # macOS updates that would otherwise reset /etc/pam.d/sudo.
  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults.dock.autohide = true;

  system.defaults.NSGlobalDomain = {
    # Lower values are faster; these are the fastest macOS accepts
    # (below what the Settings slider exposes).
    InitialKeyRepeat = 10;
    KeyRepeat = 1;
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

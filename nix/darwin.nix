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

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "1password-cli"
    "brave"
    "raycast"
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
      "mimestream"
    ];
  };

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

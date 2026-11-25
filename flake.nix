{
  description = "Jonas' macOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";

    # Newer Neovim and maintained Colima/Lima than the stable channel ships.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # hunk: review-first terminal diff viewer (git difftool/pager)
    hunk.url = "github:modem-dev/hunk";
    hunk.inputs.nixpkgs.follows = "nixpkgs";

    # Workmux: agent worktree orchestration.
    llm-agents.url = "github:numtide/llm-agents.nix";

    # tuicr: terminal UI for reviewing code diffs.
    tuicr.url = "github:agavra/tuicr";
    tuicr.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, home-manager, nix-homebrew, ... }:
  let
    mkHost = host: nix-darwin.lib.darwinSystem {
      modules = [
        ./nix/darwin.nix
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = host.manageHomebrew;
            enableRosetta = false;
            user = "jgrau";
          };
        }
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "hm-backup";
          home-manager.extraSpecialArgs = { inherit inputs host; };
          home-manager.users.jgrau = import ./nix/home.nix;
        }
      ];
      specialArgs = { inherit inputs self host; };
    };
  in {
    darwinConfigurations = builtins.mapAttrs (name: host: mkHost (host // { profileName = name; })) (import ./nix/hosts.nix);
  };
}

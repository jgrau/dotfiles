#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
# path: includes new, not-yet-committed host modules during development.
nix eval --impure --json --expr '
let
  flake = builtins.getFlake ("path:" + toString ./.);
  main = flake.darwinConfigurations.jgrau-m5.config;
  old = flake.darwinConfigurations.jgrau-m1.config;
  names = c: map (p: p.pname or p.name) c.home-manager.users.jgrau.home.packages;
in
assert main.nix.enable && main.homebrew.enable && main.nix-homebrew.enable;
assert !old.nix.enable && !old.homebrew.enable && !old.nix-homebrew.enable;
assert main.networking.hostName == "Jonass-MacBook-Pro";
assert old.networking.hostName == "jgrau-mbp";
assert builtins.match ".*disablesleep 1.*" old.system.activationScripts.postActivation.text != null;
assert builtins.match ".*disablesleep.*" main.system.activationScripts.postActivation.text == null;
assert old.environment.variables.DOTFILES_HOST == "jgrau-m1";
assert main.environment.variables.DOTFILES_HOST == "jgrau-m5";
assert builtins.elem "caprine" (names main);
assert !(builtins.elem "caprine" (names old));
assert !(builtins.elem "colima" (names old));
assert builtins.elem "git" (names old);
assert builtins.elem "stow" (names old);
assert main.home-manager.users.jgrau.home.file."Applications/TomatoBar.app".enable;
assert !(old.home-manager.users.jgrau.home.file ? "Applications/TomatoBar.app");
{ main = flake.darwinConfigurations.jgrau-m5.system.drvPath;
  old = flake.darwinConfigurations.jgrau-m1.system.drvPath; }
'

#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
target=$(mktemp -d)
trap 'rm -rf -- "$target"' EXIT
# Exercise a copy so clutter fixtures never touch the real config sources.
mkdir -p "$target/repo/bin" "$target/home" "$target/elsewhere"
cp "$root/.stowrc" "$root/.gitignore" "$target/repo/"
cp "$root/bin/dotfiles" "$target/repo/bin/"
cp -R "$root/stow" "$target/repo/"
root="$target/repo"
export HOME="$target/home"
clutter=(
  .DS_Store .DS_StoreX ._metadata notes~ .notes.swp '#notes#' '.#notes'
  settings.local settings.secret .env .env.production
  .config/fish/fish_variables .config/nvim/nvim-pack-lock.json
  .config/herdr/plugins/example/plugin.lua .config/herdr/logs/test.txt
  .config/herdr/sessions/test.json .config/herdr/herdr.log
)
for file in "${clutter[@]}"; do
  mkdir -p "$(dirname "$root/stow/dotfiles/$file")"
  printf 'clutter\n' > "$root/stow/dotfiles/$file"
done
printf 'EXAMPLE=value\n' > "$root/stow/dotfiles/.env.example"
# Check matching Git exclusions independently of Stow's regex rules.
git init -q "$root"
for file in "${clutter[@]}"; do
  git -C "$root" check-ignore -q -- "stow/dotfiles/$file"
done
if git -C "$root" check-ignore -q -- stow/dotfiles/.env.example; then
  echo '.env.example should not be Git-ignored' >&2; exit 1
fi
# The helper must find the shared defaults from any working directory.
cd "$target/elsewhere"
"$root/bin/dotfiles" check
[[ ! -e "$HOME/.config" ]]
"$root/bin/dotfiles" apply
[[ -L "$HOME/.gitignore" ]]
[[ -L "$HOME/.config/herdr/config.toml" ]]
[[ ! -L "$HOME/.config/herdr" ]]
[[ ! -e "$HOME/.stow-local-ignore" ]]
[[ -L "$HOME/.env.example" ]]
for file in "${clutter[@]}"; do
  [[ ! -e "$HOME/$file" && ! -L "$HOME/$file" ]]
done
# Direct invocation uses exactly the same defaults as the helper.
(cd "$root" && stow --simulate dotfiles)
printf 'runtime state\n' > "$HOME/.config/herdr/state.json"
"$root/bin/dotfiles" apply
"$root/bin/dotfiles" unlink
[[ ! -e "$HOME/.config/herdr/config.toml" ]]
[[ -f "$HOME/.config/herdr/state.json" ]]
printf 'existing config\n' > "$HOME/.bashrc"
if "$root/bin/dotfiles" apply; then
  echo 'Expected a conflict for an existing unmanaged file' >&2
  exit 1
fi
[[ $(< "$HOME/.bashrc") == 'existing config' ]]
[[ ! -e "$HOME/.config/herdr/config.toml" ]]
echo 'Stow shared-defaults, clutter, dry-run, apply, idempotency, unlink, runtime-state and conflict tests passed.'

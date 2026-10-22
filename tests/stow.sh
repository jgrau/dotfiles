#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
target=$(mktemp -d)
trap 'rm -rf -- "$target"' EXIT
mkdir -p "$target/repo/bin" "$target/home" "$target/elsewhere"
cp "$root/.stowrc" "$root/.gitignore" "$target/repo/"
cp "$root/bin/dotfiles" "$target/repo/bin/"
# Exclude local/private state from the fixture copy.
(cd "$root" && tar --exclude=config/herdr/plugins -cf - home config) | (cd "$target/repo" && tar -xf -)
root="$target/repo"
export HOME="$target/home"
common=(.DS_Store .DS_StoreX ._metadata notes~ .notes.swp '#notes#' '.#notes' settings.local settings.secret .env .env.production)
clutter=()
for package in home config; do
  for file in "${common[@]}"; do clutter+=("$package/$file"); done
  printf 'EXAMPLE=value\n' > "$root/$package/.env.example"
done
clutter+=(config/fish/fish_variables config/nvim/nvim-pack-lock.json config/herdr/plugins/example/plugin.lua config/herdr/logs/test.txt config/herdr/sessions/test.json config/herdr/herdr.log)
for file in "${clutter[@]}"; do
  mkdir -p "$(dirname "$root/$file")"
  printf 'clutter\n' > "$root/$file"
done
git init -q "$root"
for file in "${clutter[@]}"; do git -C "$root" check-ignore -q -- "$file"; done
for file in home/.env.example config/.env.example config/direnv/direnv.toml; do
  if git -C "$root" check-ignore -q -- "$file"; then
    echo "$file should not be Git-ignored" >&2; exit 1
  fi
done
cd "$target/elsewhere"
"$root/bin/dotfiles" check
[[ ! -e "$HOME/.config" && ! -e "$HOME/.zshrc" ]]
"$root/bin/dotfiles" apply
[[ -L "$HOME/.gitignore" && -L "$HOME/.zshrc" ]]
[[ -L "$HOME/.config/herdr/config.toml" && ! -L "$HOME/.config/herdr" ]]
[[ ! -e "$HOME/.stow-local-ignore" && ! -e "$HOME/.config/.stow-local-ignore" ]]
[[ -L "$HOME/.env.example" && -L "$HOME/.config/.env.example" ]]
[[ "$HOME/.zshrc" -ef "$root/home/.zshrc" ]]
[[ "$HOME/.config/herdr/config.toml" -ef "$root/config/herdr/config.toml" ]]
for file in "${clutter[@]}"; do
  case "$file" in
    home/*) dest="$HOME/${file#home/}" ;;
    config/*) dest="$HOME/.config/${file#config/}" ;;
  esac
  [[ ! -e "$dest" && ! -L "$dest" ]]
done
(cd "$root" && stow --dir=. --target="$HOME" --simulate --restow home && stow --dir=. --target="$HOME/.config" --simulate --restow config)
printf 'runtime state\n' > "$HOME/.config/herdr/state.json"
"$root/bin/dotfiles" apply
"$root/bin/dotfiles" unlink
[[ ! -e "$HOME/.config/herdr/config.toml" && ! -e "$HOME/.zshrc" ]]
[[ -f "$HOME/.config/herdr/state.json" ]]
# Either package's conflicts must prevent changes to BOTH targets.
for conflict in "$HOME/.bashrc" "$HOME/.config/herdr/config.toml"; do
  printf 'existing config\n' > "$conflict"
  if "$root/bin/dotfiles" apply; then
    echo "Expected conflict for $conflict" >&2; exit 1
  fi
  [[ $(< "$conflict") == 'existing config' ]]
  [[ ! -e "$HOME/.zshrc" && ! -e "$HOME/.config/ghostty/config" ]]
  rm -- "$conflict"
done
"$root/bin/dotfiles" apply
"$root/bin/dotfiles" check
"$root/bin/dotfiles" unlink
echo 'Stow targets, exclusions, dry-run, apply, idempotency, unlink, runtime-state and cross-package conflict tests passed.'

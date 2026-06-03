# Dotfiles

Personal macOS dotfiles managed with [nix-darwin](https://github.com/nix-darwin/nix-darwin) and [Home Manager](https://github.com/nix-community/home-manager).

The old rcm/Homebrew files are kept as migration reference while the Nix setup becomes the source of truth.

## Install

```sh
sudo darwin-rebuild switch --flake ~/src/dotfiles#Jonass-MacBook-Pro
```

The first activation may back up existing Home Manager-managed files with the `.hm-backup` suffix.

## Validate

```sh
nix flake check

darwin-rebuild build --flake ~/src/dotfiles#Jonass-MacBook-Pro
```

Review the files before applying them on a new machine. Some tools assume macOS.

## Local-only configuration

Machine-specific, work-specific, and secret-bearing settings should live outside this repository, usually in local include files such as:

- `~/.gitconfig.local` for Git identity
- tool-specific `*.local` files where supported
- environment managers or secret stores for credentials

Do not commit API keys, tokens, `.env` files, generated editor state, or private workplace configuration.

## Secret scanning

This repo uses a tracked pre-commit hook in `.githooks/pre-commit` that runs `gitleaks` before commits.

Enable it after cloning:

```sh
git config core.hooksPath .githooks
```

The hook uses a local `gitleaks` binary when available, otherwise it falls back to `nix run nixpkgs#gitleaks`.

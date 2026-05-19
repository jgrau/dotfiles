# Dotfiles

Personal dotfiles managed with [rcm](https://github.com/thoughtbot/rcm).

## Install

```sh
rcup
```

Review the files before applying them on a new machine. Some tools assume macOS and Homebrew.

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

# Dotfiles

Editable dotfiles are managed by **GNU Stow**. Nix-darwin manages macOS and software; Home Manager remains only for user packages, application assets, and activation tasks—not shell/tool configuration.

## Layout

- `stow/dotfiles/` mirrors `$HOME`: `.config/herdr/config.toml`, `.config/fish/config.fish`, `.zshrc`, etc. Edit these files directly; no Nix rebuild is needed for config edits.
- Root `.stowrc` centralizes `--dir=stow`, `--target=~`, and `--no-folding`, linking individual files instead of whole directories. `bin/dotfiles` loads these defaults from any working directory. Mutable Herdr state, Fish variables and Neovim lockfiles remain outside Git.
- `nix/home.nix` installs user software and exposes versioned plugin assets through `~/.local/share/dotfiles-runtime`. Fish/tmux plugin versions still come from Nix; their editable initialization and settings live in Stow.
- Some old `config/` paths are compatibility symlinks. Remaining rcm/Homebrew files and old Fish/Git/tmux configs are historical references, not deployment inputs. Do not run rcm over this repository.

## First migration from Home Manager

The migration is prepared in the repository, but **must be activated in this order**:

```sh
cd ~/src/dotfiles
darwin-rebuild build --flake .#Jonass-MacBook-Pro
sudo darwin-rebuild switch --flake .#Jonass-MacBook-Pro
./bin/dotfiles check
./bin/dotfiles apply
```

The switch removes Home Manager's old configuration symlinks and installs Stow plus runtime plugin assets. Stow then links the editable sources. Keep the current shell open until both steps succeed. Review all existing Nix changes before switching: activation applies the entire working configuration.

Stow refuses conflicting files. Inspect and back up a conflict before moving it aside; never use `--adopt` or blindly delete files. The initial preparation backup is under `~/.local/state/dotfiles-migration/` and contains the previous Nix configuration and repo configs (including uncommitted edits).

Open a fresh shell afterward. Reload Herdr with `herdr server reload-config`, Ghostty with Cmd+Shift+comma, and tmux with `tmux source-file ~/.config/tmux/tmux.conf` if running.

## Everyday use

```sh
./bin/dotfiles check   # preview links, no changes
./bin/dotfiles apply   # link new files; existing source edits need no relinking
./bin/dotfiles unlink  # remove Stow links without deleting source files
```

Or use Stow directly from the repository root (the package name is `dotfiles`, not `.`):

```sh
cd ~/src/dotfiles
stow --simulate --verbose dotfiles
stow --restow dotfiles
stow --delete dotfiles  # unlink only when wanted
```

`.gitignore` prevents committing clutter; `stow/dotfiles/.stow-local-ignore` independently prevents deploying it. Both exclude macOS metadata, editor backups, local/private settings, and selected Fish/Neovim/Herdr runtime files. `.env.example` remains eligible. Stow deliberately includes the home-level `.gitignore`; its standard ignore list would exclude it. Keep these two exclusion lists and their tests aligned. Ignore rules are not a substitute for secret scanning and do not remove files already tracked or linked.

For a new config, put it at its home-relative path inside `stow/dotfiles/`, then check/apply. Do not add dotfile declarations or `programs.*` config generators to Home Manager. Software changes still use `darwin-rebuild build` / `switch`.

## Zsh

Zsh is the login shell declared in `nix/darwin.nix`; changing the running account requires a Nix switch. Fish and its existing configuration remain installed as a fallback. Shell settings live in `stow/dotfiles/.zshrc`, not Home Manager.

The setup uses **Starship's default prompt**, except the AWS, Node.js, Nix shell, package and Python modules are disabled in `stow/dotfiles/.config/starship.toml`. It retains autosuggestions, syntax highlighting, Ghostty, zoxide, shared history and basic completion, and adds:

- `zsh-abbr` with the 154 static Git abbreviations from the former Fish Git plugin. Definitions in `.config/zsh/git-abbreviations.zsh` are session-only; helper-dependent abbreviations are intentionally omitted. Nix classifies zsh-abbr as unfree, so only that package is added to the existing allowlist.
- Autopair, loaded after abbreviations so its space widget can expand them.
- Television on Ctrl-R (history) and Ctrl-T (smart autocomplete), and Worktrunk's directory-changing shell integration.
- `EDITOR=nvim`, PNPM and Pax executable paths; no Fish `pax` wrapper.
- `vim`, `wtc`, `wtl`, `wts`, `wtsm`, and zsh-specific `reload`, alongside `drb`, `drs`, `g`, and `ll`.
- The Fish startup exception that avoids the direnv hook on `review/gh-dash-*` branches. This is a startup/reload check, not continuous branch detection.

No `ppr`, `apici`, Git helper functions, Puffer, long-command notifications, abbreviation reminders, or extra Fish-style navigation are ported. The default Starship modules decide which contextual information to show.

After building, activate the shell/packages and link any new files:

```sh
sudo darwin-rebuild switch --flake ~/src/dotfiles#Jonass-MacBook-Pro
cd ~/src/dotfiles
./bin/dotfiles check
./bin/dotfiles apply
exec /run/current-system/sw/bin/zsh -l
```

Existing terminal/multiplexer processes may still inherit `SHELL=fish`; a fresh login or application session picks up the account change. Do not stop a multiplexer server containing active work merely to change shells. Test with `bash tests/zsh.sh` after activation (or set `DOTFILES_TEST_RUNTIME` to the built runtime and put the built Starship binary on PATH beforehand).

## Herdr review workflow

Herdr creates new worktrees under `~/src/worktrees`. Ctrl-f then Shift-C opens tuicr in a right-hand split; gh-dash's `C` review action opens the selected PR there using zsh-compatible shell syntax. Ctrl-f then Shift-T opens the local Work Hub overlay when its separately installed Landfolk plugin is available; Ctrl-f then `s` still opens Sesh. The work-specific plugin is not distributed with these dotfiles.

## Validation and rollback

```sh
nix flake check
darwin-rebuild build --flake .#Jonass-MacBook-Pro
bash tests/stow.sh
./bin/dotfiles check
```

The Stow tests use a temporary repository copy and home directory. They cover shared defaults, invocation from another directory, Git/Stow clutter exclusions, dry-run, apply, repeated application, unlink, runtime-state preservation and refusal to overwrite conflicts.

To return to a prior Home Manager generation, first `./bin/dotfiles unlink`, then activate the previous Nix generation. Restore the prior `nix/home.nix` from the migration backup before rebuilding that configuration. Do not leave Stow and Home Manager competing for the same files.

## Local-only configuration

Git identity lives in `~/.gitconfig.local`, included by the Stow Git config. Machine-specific, work-specific and secret-bearing settings belong outside this public repository. Never commit credentials, `.env` files, generated editor state or private workplace configuration.

## Secret scanning

Enable the tracked gitleaks hook:

```sh
git config core.hooksPath .githooks
```

The hook uses a local `gitleaks` binary, falling back to `nix run nixpkgs#gitleaks`.

# Dotfiles

Editable dotfiles are managed by **GNU Stow**. Nix-darwin manages macOS and software; Home Manager remains only for user packages, application assets, and activation tasks—not shell/tool configuration.

## Layout

- `config/` mirrors `~/.config`: `ghostty/config`, `herdr/config.toml`, `nvim/`, etc.
- `home/` contains home-level dotfiles such as `.zshrc` and `.gitignore`.
- Edit these sources directly; no Nix rebuild is needed for config edits. `bin/dotfiles` deploys both packages from any working directory and preflights both targets before applying either. Root `.stowrc` supplies `--no-folding` so runtime directories stay writable. Mutable Herdr state, Fish variables and Neovim lockfiles remain outside Git.
- `nix/home.nix` installs user software and exposes versioned plugin assets through `~/.local/share/dotfiles-runtime`. Fish/tmux plugin versions still come from Nix; their editable initialization and settings live in Stow.
- The old rcm/Brewfile layout, compatibility links and superseded configs have been retired. Git history retains the historical versions; do not run rcm over this repository.

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

Prefer the wrapper, which checks both targets before changing links. For direct Stow use, specify each package's target explicitly (never `stow .`):

```sh
cd ~/src/dotfiles
# ~/.config must exist for direct invocation.
stow --dir=. --target="$HOME" --simulate --restow home
stow --dir=. --target="$HOME/.config" --simulate --restow config
```

Remove `--simulate` to apply, or replace `--restow` with `--delete` to unlink only when wanted. The wrapper targets `~/.config` intentionally, regardless of `XDG_CONFIG_HOME`.

### Migrating from the nested layout

Before updating an existing checkout that still has `stow/dotfiles/`, run its `bin/dotfiles unlink`. Then update the checkout and run `bin/dotfiles check` followed by `bin/dotfiles apply`. No Nix rebuild is needed for this layout change. Back up uncommitted work before updating; never adopt or overwrite conflicting files.

`.gitignore` prevents committing clutter; `home/.stow-local-ignore` and `config/.stow-local-ignore` independently prevent deploying it. Both exclude macOS metadata, editor backups, local/private settings, and selected Fish/Neovim/Herdr runtime files. `.env.example` remains eligible. Stow deliberately includes the home-level `.gitignore`; its standard ignore list would exclude it. Keep the Git and Stow exclusion rules and their tests aligned. Ignore rules are not a substitute for secret scanning and do not remove files already tracked or linked.

For a new config, use `config/` for paths relative to `~/.config`, or `home/` for home-level dotfiles, then check/apply. Do not add dotfile declarations or `programs.*` config generators to Home Manager. Software changes still use `darwin-rebuild build` / `switch`.

## Zsh

Zsh is the login shell declared in `nix/darwin.nix`; changing the running account requires a Nix switch. Fish and its existing configuration remain installed as a fallback. Shell settings live in `home/.zshrc`, not Home Manager.

The setup uses **Starship's default prompt**, except the AWS, Docker context, Node.js, Nix shell, package and Python modules are disabled in `config/starship.toml`. It retains autosuggestions, syntax highlighting, Ghostty, zoxide, shared history and basic completion, and adds:

- `zsh-abbr` with the 154 static Git abbreviations from the former Fish Git plugin. Definitions in `.config/zsh/git-abbreviations.zsh` are session-only; helper-dependent abbreviations are intentionally omitted. Nix classifies zsh-abbr as unfree, so only that package is added to the existing allowlist.
- Autopair, loaded after abbreviations so its space widget can expand them.
- Television on Ctrl-R (history) and Ctrl-T (smart autocomplete), and Worktrunk's directory-changing shell integration.
- `EDITOR=nvim`, PNPM and `~/.local/bin` executable paths. `~/src/pax/bin` comes first so `pax` uses the development checkout rather than the installed release; no Fish `pax` wrapper.
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

## Pi

Pi is installed separately with the official installer, not Home Manager, so updates do not require a Nix rebuild. Node.js and npm remain Nix-managed.

```sh
curl -fsSL https://pi.dev/install.sh | sh
pi update
```

The managed installation lives under `~/.pi/agent/install`, with its launcher exposed through `~/.local/bin/pi` (already on the Zsh PATH). Configuration, credentials and sessions remain in `~/.pi/agent/`, outside this repository.

When migrating from the old Nix package, build and switch first to remove it, then run the installer.

## Local Docker daemon

Nix installs Colima, which provides Docker's Linux daemon without Docker Desktop.
Start it when needed; no background service starts automatically:

```sh
colima start --vm-type vz --cpu 4 --memory 8 --disk 60
docker info
colima stop
```

On Apple Silicon, add `--vz-rosetta` for faster `linux/amd64` container builds.
Colima owns its VM and generated configuration under `~/.colima`; do not put that
runtime state under Stow. Stopping the VM stops any containers running inside it.

## Control / Escape keys

Karabiner-Elements is installed through the Nix-managed Homebrew casks. It replaces the macOS Caps Lock-to-Control mapping: **Caps Lock and left Control** send Escape when tapped alone within 250 ms, and act as Control when held or used in a shortcut. Right Control is unchanged.

After reviewing pending Nix changes, build and switch the configuration, then run `bin/dotfiles check` and `bin/dotfiles apply`. Open Karabiner-Elements and follow its permission prompts (background services, Accessibility/Input Monitoring, and the virtual keyboard driver). Under **Complex Modifications → Add predefined rule**, enable **Caps Lock and left Control: hold for Control, tap for Escape (250 ms)**. Enable this immediately after switching so Caps Lock resumes acting as Control.

Stow owns only `.config/karabiner/assets/complex_modifications/control_escape.json`; Karabiner owns its live `karabiner.json` and runtime state outside Git. After editing the rule asset, remove and re-add the enabled rule in Karabiner to load the change. Verify tapping either key cancels a menu, double-tapping opens Pi's tree, and holding either key with another key still performs Control shortcuts.

## Tmux task popup

Ctrl-f then Ctrl-a opens a Workmux task popup in the active pane's directory. Enter submits the description; Esc or an empty description cancels. Workmux creates a new branch from local `main`, using the global Workmux auto-name configuration (Pax) to generate its name. The binding passes the originating pane explicitly through the popup environment, because popups do not set `TMUX_PANE`. The helper resolves that pane's session and explicitly uses window mode so creation opens a window in that session, not a new session. Creation errors stay visible until a key is pressed. This replaces the previous-pane binding on Ctrl-a.

## Tmux and Rex branch review

Both use the shared `config/review/branch.sh` helper. Rex's `config/rex/init.lua` is Stow-managed; after edits, run `rex config check` and `rex config reload`. Its **Review Branch in tuicr** action is also available in the command palette. Ctrl-f then `v` remains available for a plain right-hand split.

Ctrl-f then `r` opens tuicr in a right-hand split in the active pane's directory. It reviews commits since the merge base with the base branch, plus staged/unstaged edits (`-r <merge-base>..HEAD -w`); with no branch commits it uses `-w` alone. Quitting closes the pane.

Base selection: `branch.<current-branch>.reviewBase` Git config override, GitHub PR target (via `gh`), cached `origin/HEAD`, then `origin/main`, `origin/master`, local `main` or `master`. PR targets prefer the origin remote-tracking ref, falling back to a local branch. No automatic fetch: run `git fetch origin` to refresh refs. Without an accessible PR, stacked/non-default branches need an explicit override, e.g. `git config branch.my-feature.reviewBase parent-branch`.

## Herdr review workflow

Herdr creates new worktrees under `~/src/worktrees`. Ctrl-f then Shift-C opens tuicr in a right-hand split, reviewing `$(git merge-base refs/remotes/origin/main HEAD)..HEAD` plus uncommitted changes (`-w`) from the active pane's directory. When HEAD equals the merge base, it uses `-w` alone because tuicr rejects an empty commit range even with uncommitted changes. Uncommitted changes include both staged and unstaged changes. It uses the locally cached `origin/main` remote-tracking ref (run `git fetch origin` to refresh it), and aborts before splitting if the merge base cannot be resolved; gh-dash's `C` review action opens the selected PR there using zsh-compatible shell syntax. Ctrl-f then Shift-T opens the local Work Hub overlay when its separately installed Landfolk plugin is available; Ctrl-f then `s` still opens Sesh. The work-specific plugin is not distributed with these dotfiles.

In gh-dash, `m` uses the default built-in merge action. Restart gh-dash after editing its config.

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

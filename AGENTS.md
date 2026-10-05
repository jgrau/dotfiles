# Dotfiles guardrails

- Read README.md first. Editable dotfiles are owned by GNU Stow, not Home Manager.
- Edit `stow/dotfiles/` at the home-relative path. Some old `config/` paths are compatibility symlinks; other legacy files are historical only.
- Home Manager in `nix/home.nix` owns packages, plugin assets and application activation tasks only. Do not reintroduce shell/tool configuration generators there.
- Use `bin/dotfiles check` before `bin/dotfiles apply`; never use Stow `--adopt` or overwrite conflicts without inspection and backup.
- Use `--no-folding` to leave application runtime directories writable and outside Git.
- Keep secrets and Git identity in local includes outside this public repository; run gitleaks before committing.
- Preserve unrelated changes. Document changes to setup, deployment and ownership in README.md.

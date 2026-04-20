return {
  -- Loads the direnv environment inside Neovim on a per-directory basis.
  -- Without this, LSP servers only get the correct PATH/GEM_PATH/etc. if
  -- Neovim was launched from a shell that already had direnv activated.
  -- With this, switching directories inside Neovim re-evaluates .envrc
  -- automatically, so ruby-lsp picks up the right nix Ruby and gems.
  {
    "direnv/direnv.vim",
    lazy = false,
  },
}

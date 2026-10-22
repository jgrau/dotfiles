-- Ruby LSP (Shopify ruby-lsp). Configured the native Neovim 0.11+ way:
-- files under `lsp/` are picked up by `vim.lsp.enable("ruby_lsp")`.
--
-- The command is launched through `direnv exec <root>` so that the server
-- always runs inside the project's direnv/Nix shell (correct Ruby version,
-- `ruby-lsp` on PATH, project gems). This is robust against the timing race
-- with the direnv.vim plugin: native LSP starts servers on the first Ruby
-- buffer, which can fire BEFORE direnv.vim has finished injecting PATH. By
-- shelling out through `direnv exec` we resolve the environment at spawn time
-- instead of relying on Neovim's ambient PATH.
--
-- `direnv` itself is always on PATH (Nix profile), so `cmd[1]` passes Neovim's
-- executability check. direnv resolves the nearest `.envrc` from the spawn cwd,
-- which Neovim sets to `root_dir` (the dir containing Gemfile / the .envrc).
local lsp = require("config.lsp_util")

---@type vim.lsp.Config
return {
  cmd = lsp.direnv_cmd({ "ruby-lsp" }),
  filetypes = { "ruby", "eruby" },
  root_markers = { "Gemfile", ".git" },
  init_options = {
    formatter = "syntax_tree",
    linters = { "rubocop" },
  },
}

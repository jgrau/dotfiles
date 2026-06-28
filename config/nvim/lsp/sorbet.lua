-- Sorbet type checker LSP. Runs through Bundler so it uses the repo's pinned
-- sorbet version, and through `direnv exec <root>` so Bundler runs under the
-- project's Ruby (not the macOS system Ruby 2.6, which can't satisfy the
-- Gemfile.lock bundler version). See lsp/ruby_lsp.lua for the rationale behind
-- the direnv wrapper. Enabled via `vim.lsp.enable("sorbet")`.
local lsp = require("config.lsp_util")

---@type vim.lsp.Config
return {
  cmd = lsp.direnv_cmd({ "bundle", "exec", "srb", "tc", "--lsp" }),
  filetypes = { "ruby", "eruby" },
  root_markers = { "Gemfile", ".git" },
  offset_encoding = "utf-8",
}

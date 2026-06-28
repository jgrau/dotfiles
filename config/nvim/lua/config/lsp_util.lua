-- Helpers shared by the LSP server definitions under `lsp/`.
local M = {}

-- Wrap an LSP command so it launches inside the project's direnv environment.
--
-- Returns a `cmd` FUNCTION (the form native LSP supports: it receives
-- `(dispatchers, config)` and must return an rpc client). We read the resolved
-- `config.root_dir` — the directory Neovim picked from `root_markers` — and run
-- `direnv exec <root_dir> <base...>`, starting the rpc transport via
-- `vim.lsp.rpc.start`.
--
-- Why a function instead of a static `{ "direnv", "exec", ".", ... }` array:
--   * We pass the ABSOLUTE root_dir, so direnv always resolves the intended
--     `.envrc` regardless of the process cwd.
--   * It avoids any dependence on the direnv.vim plugin having populated PATH
--     before the server starts (the original bug: servers spawned with the
--     macOS system Ruby 2.6 / no `ruby-lsp`, so clients failed to attach).
--
-- `direnv` is always on PATH via the Nix profile, so this never hits the
-- "executable not found" validation that bare `ruby-lsp` / `bundle` did.
---@param base string[]  -- e.g. { "ruby-lsp" } or { "bundle", "exec", "srb", "tc", "--lsp" }
---@return fun(dispatchers: vim.lsp.rpc.Dispatchers, config: vim.lsp.ClientConfig): vim.lsp.rpc.PublicClient
function M.direnv_cmd(base)
  return function(dispatchers, config)
    local root = config.root_dir or vim.fn.getcwd()
    local cmd = { "direnv", "exec", root }
    vim.list_extend(cmd, base)
    return vim.lsp.rpc.start(cmd, dispatchers, { cwd = root })
  end
end

return M

-- Native LSP setup (Neovim 0.11+). No nvim-lspconfig / mason required.
--
-- Server definitions live in `lsp/<name>.lua` and are activated here with
-- `vim.lsp.enable`. Buffer-local keymaps are wired up on LspAttach.

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_keymaps", { clear = true }),
  callback = function(event)
    local b = { buffer = event.buf, silent = true }
    local bind = vim.keymap.set

    bind("n", "gd", vim.lsp.buf.definition, b)
    bind("n", "gD", vim.lsp.buf.declaration, b)
    bind("n", "gr", vim.lsp.buf.references, b)
    bind("n", "K", vim.lsp.buf.hover, b)
    bind("n", "<leader>rn", vim.lsp.buf.rename, b)
    bind("n", "<leader>ca", vim.lsp.buf.code_action, b)
    bind("n", "[d", vim.diagnostic.goto_prev, b)
    bind("n", "]d", vim.diagnostic.goto_next, b)
  end,
})

-- Activate the servers defined under `lsp/`.
vim.lsp.enable({ "ruby_lsp", "sorbet" })

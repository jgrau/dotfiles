local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup("init_cmds", { clear = true })

-- Close these filetypes with q
autocmd("FileType", {
  group = augroup,
  pattern = { "qf", "help", "man", "lspinfo", "harpoon", "null-ls-info" },
  command = "nnoremap <buffer> q <cmd>quit<cr>",
})

local prose_filetypes = { "text", "markdown", "gitcommit" }

local function use_builtin_text_wrapping()
  vim.opt_local.textwidth = 80
  vim.opt_local.formatexpr = ""
  vim.opt_local.formatprg = ""
end

-- Text width for prose files. Clear formatter hooks so visual `gq` uses
-- Vim's built-in wrapping instead of LSP/formatprg formatting.
autocmd("FileType", {
  group = augroup,
  pattern = prose_filetypes,
  callback = use_builtin_text_wrapping,
})

autocmd("LspAttach", {
  group = augroup,
  callback = function()
    if vim.tbl_contains(prose_filetypes, vim.bo.filetype) then
      use_builtin_text_wrapping()
    end
  end,
})

-- console.log shortcut for JS/TS
autocmd("FileType", {
  group = augroup,
  pattern = { "javascript", "typescript" },
  command = "nmap <Leader>cl yiwoconsole.log('<C-r>\"', <C-r>\")<esc>^",
})

-- Auto-format Ruby files on save with ruby-lsp using Syntax Tree.
-- Keep this to a single formatter so writes stay as quick as possible.
autocmd("BufWritePre", {
  group = augroup,
  pattern = "*.rb",
  callback = function()
    vim.lsp.buf.format({ name = "ruby_lsp", async = false, timeout_ms = 5000 })
  end,
})

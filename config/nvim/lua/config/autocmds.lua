local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup("init_cmds", { clear = true })

-- Close these filetypes with q
autocmd("FileType", {
  group = augroup,
  pattern = { "qf", "help", "man", "lspinfo", "harpoon", "null-ls-info" },
  command = "nnoremap <buffer> q <cmd>quit<cr>",
})

-- Text width for prose files
autocmd("FileType", {
  group = augroup,
  pattern = { "text", "markdown" },
  command = "setlocal textwidth=80",
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

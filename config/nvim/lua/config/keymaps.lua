local bind = vim.keymap.set
local opts = { silent = true, noremap = true }

-- Quickly switch between the two most recent buffers (like alt-tab)
bind("n", "<leader><leader>", "<c-^>")

-- Yell at you for using arrow keys in normal mode — forces hjkl muscle memory
local printError = vim.api.nvim_err_writeln
bind("n", "<Left>",  function() printError("Use h") end)
bind("n", "<Right>", function() printError("Use l") end)
bind("n", "<Up>",    function() printError("Use k") end)
bind("n", "<Down>",  function() printError("Use j") end)

-- Navigate between Neovim splits and tmux panes with the same keys.
-- The <C-hjkl> mappings and lazy-loading live in the plugin spec
-- (lua/plugins/editor.lua). Disable the plugin's own default maps so
-- only our explicit ones apply.
vim.g.tmux_navigator_no_mappings = 1

-- Stay in visual mode after indenting a selection
bind("v", "<", "<gv")
bind("v", ">", ">gv")

-- Write the current file without having to type :w<cr>
bind("n", "<leader>w", "<cmd>w<cr>")

-- Open and reload this config file
bind("n", "<leader>ce", "<cmd>e $MYVIMRC<cr>")
bind("n", "<leader>cr", "<cmd>source $MYVIMRC<cr>")

-- Disable EX mode (Q) — easy to hit accidentally, rarely useful
bind("n", "Q", "<nop>")

-- Exit insert/command mode by typing jj or jk (home-row friendly)
bind({ "i", "c" }, "jj", "<esc>")
bind({ "i", "c" }, "jk", "<esc>")

-- Exit terminal mode with Esc
bind("t", "<esc>", "<C-\\><C-n>")

-- Clear search highlight by pressing Esc in normal mode
bind("n", "<esc>", ":noh<return><esc>", opts)

-- Show the full diagnostic message for the current line in a floating window
bind("n", "<leader>e", vim.diagnostic.open_float, opts)

-- Manually trigger Ruby formatting through ruby-lsp (Syntax Tree)
bind("n", "<leader>fm", function()
  vim.lsp.buf.format({ name = "ruby_lsp", async = false, timeout_ms = 5000 })
end, { desc = "Format file" })

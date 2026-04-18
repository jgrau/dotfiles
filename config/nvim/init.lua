local bind = vim.keymap.set
local opts = { silent = true, noremap = true }
local set = vim.opt

vim.g.mapleader = " "

-- Allow netrw to remove non-empty local directories
vim.g.netrw_localrmdir = "rm -r"

set.number = true
set.clipboard = "unnamedplus"
set.updatetime = 300

-- Colorscheme
set.termguicolors = true
vim.cmd("colorscheme onedark")

-- Open new split panes to right and bottom, which feels more natural
set.splitright = true
set.splitbelow = true

-- Softtabs, 2 spaces
set.tabstop = 2
set.shiftwidth = 2
set.softtabstop = 2
set.expandtab = true

set.wrap = false
set.list = true
set.listchars = "tab:»·,trail:·"
set.swapfile = false
set.showmatch = true
set.colorcolumn = "80"
set.undofile = true
set.writebackup = false
set.errorbells = false
set.visualbell = false
set.scrolloff = 10
set.fileformats = "unix,dos,mac"

-- Install packer
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
local is_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	is_bootstrap = true
	vim.fn.execute("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
	vim.cmd([[packadd packer.nvim]])
end

require("packer").startup(function(use)
	use("wbthomason/packer.nvim")

	use("kyazdani42/nvim-web-devicons")
	use({
		"nvim-lualine/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons", opt = true },
	})

	use("AndrewRadev/switch.vim")
	use("christoomey/vim-tmux-navigator")
	use("joshdick/onedark.vim")
	use("junegunn/goyo.vim")
	use("spf13/vim-autoclose")
	use("tomtom/tcomment_vim")
	use("tpope/vim-abolish")
	use("tpope/vim-fugitive")
	use("tpope/vim-repeat")
	use("tpope/vim-surround")
	use("tpope/vim-unimpaired")
	use("tpope/vim-vinegar")
  use("yegappan/greplace")

	use({
		"folke/trouble.nvim",
		requires = "kyazdani42/nvim-web-devicons",
		config = function()
			require("nvim-web-devicons").setup({})
		end,
	})

	if is_bootstrap then
		require("packer").sync()
	end
end)

-- When we are bootstrapping a configuration, it doesn't
-- make sense to execute the rest of the init.lua.
--
-- You'll need to restart nvim, and then it will work.
if is_bootstrap then
	print("==================================")
	print("    Plugins are being installed")
	print("    Wait until Packer completes,")
	print("       then restart nvim")
	print("==================================")
	return
end

-- Automatically source and re-compile packer whenever you save this init.lua
-- local packer_group = vim.api.nvim_create_augroup("Packer", { clear = true })
-- vim.api.nvim_create_autocmd("BufWritePost", {
-- 	command = "source <afile> | PackerCompile",
-- 	group = packer_group,
-- 	pattern = vim.fn.expand("$MYVIMRC"),
-- })

-- Keybindings
--------------------------------------------------------------------------------
bind("n", "<leader><leader>", "<c-^>") -- Switch between the last two files

local printError = vim.api.nvim_err_writeln
bind("n", "<Left>", function()
	printError("Use h")
end)
bind("n", "<Right>", function()
	printError("Use l")
end)
bind("n", "<Up>", function()
	printError("Use k")
end)
bind("n", "<Down>", function()
	printError("Use j")
end)

-- Quicker window movement
bind("n", "<C-h>", "<C-w>h")
bind("n", "<C-j>", "<C-w>j")
bind("n", "<C-k>", "<C-w>k")
bind("n", "<C-l>", "<C-w>l")

-- Reselect visual block after indent/outdent
bind("v", "<", "<gv")
bind("v", ">", ">gv")

-- Fast saving
bind("n", "<leader>w", "<cmd>w<cr>")

-- Vim config
bind("n", "<leader>cr", "<cmd>source $MYVIMRC<cr>")
bind("n", "<leader>ce", "<cmd>e $MYVIMRC<cr>")

-- disable EX mode for now. Enable when I'm an adult and know how to use my editor
bind("n", "Q", "<nop>")

bind({ "i", "c" }, "jj", "<esc>")
bind({ "i", "c" }, "jk", "<esc>")

-- Use esc to exit terminal mode
bind("t", "<esc>", "<C-\\><C-n>")

-- Clear search highlight on hitting esc
bind("n", "<esc>", ":noh<return><esc>", opts)

-- Tmux
--------------------------------------------------------------------------------

vim.g.tmux_navigator_no_mappings = 1
bind("n", "<C-h>", ":TmuxNavigateLeft<cr>", opts)
bind("n", "<C-j>", ":TmuxNavigateDown<cr>", opts)
bind("n", "<C-k>", ":TmuxNavigateUp<cr>", opts)
bind("n", "<C-l>", ":TmuxNavigateRight<cr>", opts)


-- Lualine
--------------------------------------------------------------------------------
require("lualine").setup()

print("Neovim Config Loaded")

-- Misc
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup("init_cmds", { clear = true })

autocmd("FileType", {
	group = augroup,
	pattern = { "qf", "help", "man", "lspinfo", "harpoon", "null-ls-info" },
	command = "nnoremap <buffer> q <cmd>quit<cr>",
})

autocmd("FileType", {
	group = augroup,
	pattern = { "text", "markdown" },
	command = "setlocal textwidth=80",
})

autocmd("FileType", {
	group = augroup,
	pattern = { "javascript", "typescript" },
	command = "nmap <Leader>cl yiwoconsole.log('<C-r>\"', <C-r>\")<esc>^",
})

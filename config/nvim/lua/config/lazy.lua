-- Bootstrap lazy.nvim
-- Checks if lazy.nvim is already installed; if not, clones it from GitHub.
-- Uses vim.uv (Neovim 0.10+) with a fallback to vim.loop for older versions.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Leader keys must be set before lazy loads any plugins, otherwise plugin
-- mappings that reference <leader> will bind to the wrong key.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Load options, keymaps and autocommands before plugins
require("config.options")
require("config.keymaps")
require("config.autocmds")

require("lazy").setup({
  spec = {
    -- Auto-import all files under lua/plugins/
    { import = "plugins" },
  },
  -- Colorscheme used while plugins are being installed for the first time
  install = { colorscheme = { "catppuccin", "habamax" } },
  -- Automatically notify you when plugin updates are available
  checker = { enabled = true },
  -- Rounded borders on the lazy.nvim UI popup
  ui = { border = "rounded" },
})

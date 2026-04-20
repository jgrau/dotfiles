return {
  -- Colorscheme: Catppuccin (a warm, pastel theme).
  -- priority=1000 ensures it loads before other plugins so colors are set early.
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("catppuccin") -- variants: catppuccin-latte/frappe/macchiato/mocha
    end,
  },

  -- Statusline at the bottom of each window.
  -- Shows mode, filename, git branch (via fugitive), diagnostics, filetype etc.
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup()
    end,
  },

  -- Diagnostics panel: a prettier replacement for the quickfix list.
  -- Open with :Trouble, shows LSP errors/warnings/references in a split.
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },

  -- File type icons used by lualine, trouble, and other UI plugins.
  -- lazy=true means it only loads when another plugin requests it.
  { "nvim-tree/nvim-web-devicons", lazy = true },
}

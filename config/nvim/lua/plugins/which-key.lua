return {
  -- Discover keybindings as you type. Press <leader> and pause to see what is available.
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Show buffer-local keymaps",
      },
    },
    opts = {
      preset = "modern",
      delay = 500,
      spec = {
        { "<leader>c", group = "config" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>o", group = "GitHub" },
      },
    },
  },
}

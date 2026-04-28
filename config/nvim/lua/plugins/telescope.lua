return {
  {
    "nvim-telescope/telescope.nvim",
    version = "*",
    dependencies = {
      -- Required: utility functions used by telescope internally
      "nvim-lua/plenary.nvim",
      -- Optional but recommended: native fzf sorter for much better performance.
      -- Requires `make` to compile — run :checkhealth telescope if it doesn't work.
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")

      telescope.setup({
        defaults = {
          -- Show results starting from the top rather than the bottom
          sorting_strategy = "ascending",
          layout_config = {
            prompt_position = "top",
          },
        },
      })

      -- Load the fzf extension for faster fuzzy sorting
      telescope.load_extension("fzf")

      -- Keymaps
      local bind = vim.keymap.set
      -- Find files tracked by git (faster than find_files in large repos)
      bind("n", "<leader>ff", builtin.git_files, { desc = "Find git files" })
      -- Find all files (including untracked)
      bind("n", "<leader>fF", builtin.find_files, { desc = "Find all files" })
      -- Live grep across the project (requires ripgrep)
      bind("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
      -- Search open buffers
      bind("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
      -- Search recently opened files
      bind("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
      -- Search help tags
      bind("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
      -- Search word under cursor across the project
      bind("n", "<leader>fw", builtin.grep_string, { desc = "Find word under cursor" })
    end,
  },
}

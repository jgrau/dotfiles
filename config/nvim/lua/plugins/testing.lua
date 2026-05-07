return {
  {
    "vim-test/vim-test",
    dependencies = {
      "preservim/vimux",
    },
    config = function()
      vim.g["test#strategy"] = "vimux"
      vim.g["test#preserve_screen"] = 1
      vim.g["test#echo_command"] = 1

      vim.g.VimuxRunnerType = "pane"
      vim.g.VimuxRunnerName = "nvim-tests"
      vim.g.VimuxOrientation = "v"
      vim.g.VimuxHeight = "15%"

      vim.keymap.set("n", "<leader>R", "<cmd>TestNearest<cr>", { desc = "Run nearest spec" })
      vim.keymap.set("n", "<leader>r", "<cmd>TestFile<cr>", { desc = "Run spec file" })
      vim.keymap.set("n", "<leader>a", "<cmd>TestSuite<cr>", { desc = "Run spec suite" })
      vim.keymap.set("n", "<leader>l", "<cmd>TestLast<cr>", { desc = "Run last spec" })
    end,
  },
}

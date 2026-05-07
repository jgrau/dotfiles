return {
  -- Official GitHub Copilot plugin. Accept ghost-text suggestions with <Tab>.
  {
    "github/copilot.vim",
    event = "InsertEnter",
    init = function()
      vim.g.copilot_node_command = "/opt/homebrew/bin/node"
    end,
  },
}

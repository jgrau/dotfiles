return {
  -- Pick and run go-task tasks from Taskfile.yml / Taskfile.yaml.
  {
    "s0cks/taskfile.nvim",
    version = "*",
    dependencies = {
      "folke/snacks.nvim",
    },
    lazy = false,
    keys = {
      {
        "<leader>tt",
        function()
          local taskfile = vim.fs.find({ "Taskfile.yml", "Taskfile.yaml" }, {
            upward = true,
            path = vim.fn.expand("%:p:h"),
          })[1]

          if not taskfile then
            vim.notify("No Taskfile.yml found", vim.log.levels.WARN)
            return
          end

          vim.cmd.edit(vim.fn.fnameescape(taskfile))
          vim.defer_fn(function()
            require("taskfile.picker").task_picker({
              req = { fsPath = taskfile },
              run = { cwd = vim.fs.dirname(taskfile) },
            })
          end, 500)
        end,
        desc = "Taskfile tasks",
      },
    },
    opts = {},
  },
}

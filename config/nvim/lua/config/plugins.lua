-- Per-plugin configuration, translated from the old lazy.nvim specs.
-- Runs after vim.pack.add() has loaded every plugin.

local bind = vim.keymap.set

-- ─── Colorscheme ────────────────────────────────────────────────────────────
-- variants: catppuccin-latte/frappe/macchiato/mocha
vim.cmd.colorscheme("catppuccin")

-- ─── Statusline ─────────────────────────────────────────────────────────────
require("lualine").setup()

-- ─── Diagnostics panel ──────────────────────────────────────────────────────
require("trouble").setup({})

-- ─── Telescope ──────────────────────────────────────────────────────────────
do
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

  -- Native fzf sorter for much better performance (compiled via PackChanged
  -- hook in config/pack.lua). Run :checkhealth telescope if this fails.
  pcall(telescope.load_extension, "fzf")

  bind("n", "<leader>ff", builtin.git_files, { desc = "Find git files" })
  bind("n", "<leader>fF", builtin.find_files, { desc = "Find all files" })
  bind("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
  bind("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
  bind("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
  bind("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
  bind("n", "<leader>fw", builtin.grep_string, { desc = "Find word under cursor" })
end

-- ─── Gitsigns ───────────────────────────────────────────────────────────────
do
  local gs = require("gitsigns")
  gs.setup({})

  bind("n", "]c", function() gs.nav_hunk("next") end, { desc = "Next git hunk" })
  bind("n", "[c", function() gs.nav_hunk("prev") end, { desc = "Previous git hunk" })
  bind("n", "<leader>gp", function() gs.preview_hunk() end, { desc = "Preview git hunk" })
  bind("n", "<leader>gs", function() gs.stage_hunk() end, { desc = "Stage git hunk" })
  bind("n", "<leader>gr", function() gs.reset_hunk() end, { desc = "Reset git hunk" })
  bind("n", "<leader>gb", function() gs.blame_line({ full = true }) end, { desc = "Blame git line" })
end

-- ─── Octo (GitHub PRs/issues) ───────────────────────────────────────────────
do
  require("octo").setup({
    picker = "telescope",
    enable_builtin = true,
  })

  bind("n", "<leader>op", "<cmd>Octo pr list<cr>", { desc = "List GitHub PRs" })
  bind("n", "<leader>oi", "<cmd>Octo issue list<cr>", { desc = "List GitHub issues" })
  bind("n", "<leader>on", "<cmd>Octo notification list<cr>", { desc = "List GitHub notifications" })
  bind("n", "<leader>os", function()
    require("octo.utils").create_base_search_command({ include_current_repo = true })
  end, { desc = "Search GitHub" })
  bind("n", "<leader>or", "<cmd>Octo review start<cr>", { desc = "Start PR review" })
  bind("n", "<leader>oc", "<cmd>Octo review comments<cr>", { desc = "Pending PR review comments" })
end

-- ─── Projectionist (source ↔ spec) ──────────────────────────────────────────
vim.g.projectionist_heuristics = vim.tbl_deep_extend("force", vim.g.projectionist_heuristics or {}, {
  ["apps/api/app/&apps/api/spec/"] = {
    ["apps/api/app/*.rb"] = { alternate = "apps/api/spec/{}_spec.rb" },
    ["apps/api/spec/*_spec.rb"] = { alternate = "apps/api/app/{}.rb" },
    ["apps/api/lib/*.rb"] = { alternate = "apps/api/spec/lib/{}_spec.rb" },
    ["apps/api/spec/lib/*_spec.rb"] = { alternate = "apps/api/lib/{}.rb" },
  },
  ["app/&spec/"] = {
    ["app/*.rb"] = { alternate = "spec/{}_spec.rb" },
    ["spec/*_spec.rb"] = { alternate = "app/{}.rb" },
    ["lib/*.rb"] = { alternate = "spec/lib/{}_spec.rb" },
    ["spec/lib/*_spec.rb"] = { alternate = "lib/{}.rb" },
  },
})

-- ─── tmux navigator ─────────────────────────────────────────────────────────
-- Plugin's own default maps are disabled in config/keymaps.lua
-- (vim.g.tmux_navigator_no_mappings = 1). Wire up <C-hjkl> explicitly.
bind("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>", { silent = true })
bind("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>", { silent = true })
bind("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>", { silent = true })
bind("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", { silent = true })

-- ─── Copilot ────────────────────────────────────────────────────────────────
vim.g.copilot_node_command = "/opt/homebrew/bin/node"

-- ─── vim-test (+ vimux) ─────────────────────────────────────────────────────
do
  vim.g["test#strategy"] = "vimux"
  vim.g["test#preserve_screen"] = 1
  vim.g["test#echo_command"] = 1

  vim.g.VimuxRunnerType = "pane"
  vim.g.VimuxRunnerName = "nvim-tests"
  vim.g.VimuxOrientation = "v"
  vim.g.VimuxHeight = "15%"

  bind("n", "<leader>R", "<cmd>TestNearest<cr>", { desc = "Run nearest spec" })
  bind("n", "<leader>r", "<cmd>TestFile<cr>", { desc = "Run spec file" })
  bind("n", "<leader>a", "<cmd>TestSuite<cr>", { desc = "Run spec suite" })
  bind("n", "<leader>l", "<cmd>TestLast<cr>", { desc = "Run last spec" })
end

-- ─── Taskfile ───────────────────────────────────────────────────────────────
do
  require("taskfile").setup({})

  bind("n", "<leader>tt", function()
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
  end, { desc = "Taskfile tasks" })
end

-- ─── which-key ──────────────────────────────────────────────────────────────
do
  local wk = require("which-key")
  wk.setup({
    preset = "modern",
    delay = 500,
    spec = {
      { "<leader>c", group = "config" },
      { "<leader>f", group = "find" },
      { "<leader>g", group = "git" },
      { "<leader>o", group = "GitHub" },
    },
  })

  bind("n", "<leader>?", function()
    wk.show({ global = false })
  end, { desc = "Show buffer-local keymaps" })
end

-- ─── pax-nvim (local extension, optional) ───────────────────────────────────
do
  local pax_nvim = vim.fn.expand("~/src/pax/packages/pi-resources/extensions/pax-nvim/nvim")
  if vim.fn.isdirectory(pax_nvim) == 1 then
    -- Make the local plugin available, then set it up.
    vim.opt.rtp:append(pax_nvim)
    require("pax-nvim").setup({
      mappings = { "<leader>p" },
    })
  end
end

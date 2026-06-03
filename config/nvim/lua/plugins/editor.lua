return {
  -- Toggle between related words: true↔false, yes↔no, &&↔||, etc.
  "AndrewRadev/switch.vim",

  -- Navigate seamlessly between Neovim splits and tmux panes using <C-hjkl>.
  -- Load on the TmuxNavigate* commands so the plugin (and its <C-hjkl>
  -- mappings) is available when those keys are pressed.
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
    },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>" },
    },
  },

  -- Distraction-free writing mode. :Goyo to toggle.
  "junegunn/goyo.vim",

  -- Auto-close brackets, quotes, and parens as you type.
  "spf13/vim-autoclose",

  -- Toggle comments on lines or motions. gc<motion> or gcc for current line.
  "tomtom/tcomment_vim",

  -- Case-preserving substitution (:S) and abbreviations (:Abolish).
  -- e.g. :%S/blog_post/article/ will also change BlogPost → Article.
  "tpope/vim-abolish",

  -- Git gutter signs, hunk preview, hunk staging/resetting, and inline blame.
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    keys = {
      { "]c", function() require("gitsigns").nav_hunk("next") end, desc = "Next git hunk" },
      { "[c", function() require("gitsigns").nav_hunk("prev") end, desc = "Previous git hunk" },
      { "<leader>gp", function() require("gitsigns").preview_hunk() end, desc = "Preview git hunk" },
      { "<leader>gs", function() require("gitsigns").stage_hunk() end, desc = "Stage git hunk" },
      { "<leader>gr", function() require("gitsigns").reset_hunk() end, desc = "Reset git hunk" },
      { "<leader>gb", function() require("gitsigns").blame_line({ full = true }) end, desc = "Blame git line" },
    },
    opts = {},
  },

  -- Git integration. :Git (or :G) to open the git summary, :GBlame, etc.
  "tpope/vim-fugitive",

  -- GitHub issues and pull requests inside Neovim. Requires `gh auth login`.
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>op", "<cmd>Octo pr list<cr>", desc = "List GitHub PRs" },
      { "<leader>oi", "<cmd>Octo issue list<cr>", desc = "List GitHub issues" },
      { "<leader>on", "<cmd>Octo notification list<cr>", desc = "List GitHub notifications" },
      { "<leader>os", function() require("octo.utils").create_base_search_command({ include_current_repo = true }) end, desc = "Search GitHub" },
      { "<leader>or", "<cmd>Octo review start<cr>", desc = "Start PR review" },
      { "<leader>oc", "<cmd>Octo review comments<cr>", desc = "Pending PR review comments" },
    },
    opts = {
      picker = "telescope",
      enable_builtin = true,
    },
  },

  -- Jump between source files and their alternates, e.g. Ruby files ↔ specs with :A.
  {
    "tpope/vim-projectionist",
    config = function()
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
    end,
  },

  -- Makes the . (repeat) command work with plugin mappings, not just native ones.
  "tpope/vim-repeat",

  -- Add/change/delete surrounding characters. cs"' changes "word" to 'word',
  -- ds" deletes quotes, ysiw) wraps word in parens.
  "tpope/vim-surround",

  -- Pairs of handy bracket mappings: ]q/[q (quickfix), ]b/[b (buffers),
  -- ]<Space>/[<Space> (blank lines), ]e/[e (exchange lines), and more.
  "tpope/vim-unimpaired",

  -- Enhances netrw (built-in file browser) with - to open the directory of
  -- the current file, making it easy to explore the project tree.
  "tpope/vim-vinegar",

  -- Project-wide search and replace across files. :Greplace to start.
  "yegappan/greplace",
}

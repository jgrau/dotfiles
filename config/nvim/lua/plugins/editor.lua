return {
  -- Toggle between related words: true↔false, yes↔no, &&↔||, etc.
  "AndrewRadev/switch.vim",

  -- Navigate seamlessly between Neovim splits and tmux panes using <C-hjkl>.
  -- Keybindings are defined in config/keymaps.lua.
  "christoomey/vim-tmux-navigator",

  -- Distraction-free writing mode. :Goyo to toggle.
  "junegunn/goyo.vim",

  -- Auto-close brackets, quotes, and parens as you type.
  "spf13/vim-autoclose",

  -- Toggle comments on lines or motions. gc<motion> or gcc for current line.
  "tomtom/tcomment_vim",

  -- Case-preserving substitution (:S) and abbreviations (:Abolish).
  -- e.g. :%S/blog_post/article/ will also change BlogPost → Article.
  "tpope/vim-abolish",

  -- Git integration. :Git (or :G) to open the git summary, :GBlame, etc.
  "tpope/vim-fugitive",

  -- LazyGit terminal UI inside Neovim. <leader>gg opens the Git cockpit.
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
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

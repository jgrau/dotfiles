local function set_ruby_test_keymaps(buf)
  local map = function(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, {
      buffer = buf,
      silent = true,
      desc = desc,
    })
  end

  map("<leader>R", "<cmd>TestNearest<cr>", "Run spec nearest to the cursor")
  map("<leader>r", "<cmd>TestFile<cr>", "Run the current spec file")
  map("<leader>a", "<cmd>TestSuite<cr>", "Run the full spec suite")
  map("<leader>l", "<cmd>TestLast<cr>", "Re-run the last spec command")
  map("<leader>o", "<cmd>A<cr>", "Jump to the matching spec or source file")
end

return {
  {
    -- Test runner commands such as :TestNearest and :TestFile.
    "vim-test/vim-test",
    ft = { "ruby" },
    dependencies = {
      -- Run test commands inside a reusable tmux pane.
      "preservim/vimux",
      -- Let test.vim resolve the matching spec when invoked from app code.
      "tpope/vim-projectionist",
    },
    init = function()
      -- Send test runs to tmux instead of Neovim's built-in terminal.
      vim.g["test#strategy"] = "vimux"

      -- Keep prior output visible between runs so failures stay on screen.
      vim.g["test#preserve_screen"] = 1

      -- Print the exact RSpec command in the tmux pane before executing it.
      vim.g["test#echo_command"] = 1

      -- Open the tmux runner as a pane below the current one.
      vim.g.VimuxOrientation = "v"

      -- Give the tmux runner enough space to read failures comfortably.
      vim.g.VimuxHeight = "25%"

      -- Teach projectionist how this Ruby/Rails layout maps code to specs.
      vim.g.projectionist_heuristics = vim.tbl_deep_extend("force", vim.g.projectionist_heuristics or {}, {
        ["Gemfile|*.gemspec"] = {
          ["app/*.rb"] = { alternate = "spec/{}_spec.rb", type = "source" },
          ["lib/*.rb"] = { alternate = "spec/lib/{}_spec.rb", type = "source" },
          ["spec/*_spec.rb"] = { alternate = "app/{}.rb", type = "test" },
          ["spec/lib/*_spec.rb"] = { alternate = "lib/{}.rb", type = "test" },
        },
      })
    end,
    config = function()
      -- The plugin loads on a Ruby buffer, so wire the current one immediately.
      if vim.bo.filetype == "ruby" then
        set_ruby_test_keymaps(0)
      end

      -- Also add the same mappings for Ruby buffers opened later in the session.
      local group = vim.api.nvim_create_augroup("ruby_test_keymaps", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "ruby",
        callback = function(event)
          set_ruby_test_keymaps(event.buf)
        end,
      })
    end,
  },
}

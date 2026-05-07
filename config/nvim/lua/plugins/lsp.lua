return {
  { "williamboman/mason.nvim", config = true },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {},
      automatic_installation = false,
      automatic_enable = false,
    },
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason-lspconfig.nvim" },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local b = { buffer = event.buf, silent = true }
          local bind = vim.keymap.set

          bind("n", "gd", vim.lsp.buf.definition, b)
          bind("n", "gD", vim.lsp.buf.declaration, b)
          bind("n", "gr", vim.lsp.buf.references, b)
          bind("n", "K", vim.lsp.buf.hover, b)
          bind("n", "<leader>rn", vim.lsp.buf.rename, b)
          bind("n", "<leader>ca", vim.lsp.buf.code_action, b)
          bind("n", "[d", vim.diagnostic.goto_prev, b)
          bind("n", "]d", vim.diagnostic.goto_next, b)
        end,
      })

      -- Assumes Neovim was started from the repo shell/direnv environment.
      vim.lsp.config("ruby_lsp", {
        init_options = {
          formatter = "syntax_tree",
          linters = { "rubocop" },
        },
      })
      vim.lsp.enable("ruby_lsp")

      vim.lsp.config("sorbet", {
        cmd = { "bundle", "exec", "srb", "tc", "--lsp" },
        filetypes = { "ruby", "eruby" },
        root_markers = { "Gemfile", ".git" },
        offset_encoding = "utf-8",
      })
      vim.lsp.enable("sorbet")
    end,
  },
}

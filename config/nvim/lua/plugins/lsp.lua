return {
  { "williamboman/mason.nvim", config = true },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {},
      automatic_installation = false,
      automatic_enable = {
        exclude = { "ruby_lsp", "rubocop", "sorbet" },
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason-lspconfig.nvim" },
    config = function()
      local function with_direnv(root_dir, cmd)
        if root_dir and vim.fn.executable("direnv") == 1 then
          return vim.list_extend({
            "env",
            "DIRENV_LOG_FORMAT=",
            "LANDFOLK_SKIP_PROXY=1",
            "direnv",
            "exec",
            root_dir,
          }, cmd)
        end

        return cmd
      end

      local function start_with_direnv(cmd)
        return function(dispatchers, config)
          local root_dir = config and (config.cmd_cwd or config.root_dir)

          if config and root_dir and not config.cmd_cwd then
            config.cmd_cwd = root_dir
          end

          return vim.lsp.rpc.start(
            with_direnv(root_dir, cmd),
            dispatchers,
            root_dir and { cwd = root_dir } or nil
          )
        end
      end

      local function reuse_by_root(client, config)
        return client.name == config.name and client.config.root_dir == config.root_dir
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local b = { buffer = event.buf, silent = true }
          local bind = vim.keymap.set
          bind("n", "gd",         vim.lsp.buf.definition, b)
          bind("n", "gD",         vim.lsp.buf.declaration, b)
          bind("n", "gr",         vim.lsp.buf.references, b)
          bind("n", "K",          vim.lsp.buf.hover, b)
          bind("n", "<leader>rn", vim.lsp.buf.rename, b)
          bind("n", "<leader>ca", vim.lsp.buf.code_action, b)
          bind("n", "[d",         vim.diagnostic.goto_prev, b)
          bind("n", "]d",         vim.diagnostic.goto_next, b)
        end,
      })

      -- ruby-lsp: navigation, hover, Syntax Tree formatting, and RuboCop
      -- diagnostics through the Ruby LSP add-on.
      -- Run through direnv so opening Neovim from the monorepo root still uses
      -- the app-specific Ruby environment instead of the host/system Ruby.
      vim.lsp.config("ruby_lsp", {
        cmd = start_with_direnv({ "ruby-lsp" }),
        init_options = {
          formatter = "syntax_tree",
          linters = { "rubocop" },
        },
        reuse_client = reuse_by_root,
      })
      vim.lsp.enable("ruby_lsp")

      -- sorbet: type checker. Force UTF-8 to match ruby_lsp.
      vim.lsp.config("sorbet", {
        cmd = start_with_direnv({ "bundle", "exec", "srb", "tc", "--lsp" }),
        offset_encoding = "utf-8",
        reuse_client = reuse_by_root,
      })
      vim.lsp.enable("sorbet")
    end,
  },
}

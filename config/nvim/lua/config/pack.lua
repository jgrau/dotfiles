-- Plugin management with Neovim 0.12's built-in vim.pack.
--
-- Unlike lazy.nvim, vim.pack has no lazy loading, no keymap/command specs,
-- and no config/opts hooks. It is "just a function": vim.pack.add() installs
-- (if missing) and loads each plugin immediately. We therefore list every
-- plugin in one add() call, then configure them with plain Lua afterwards.
--
-- The lockfile lives at ~/.config/nvim/nvim-pack-lock.json and is owned by
-- vim.pack at runtime (see nix/home.nix, which keeps it out of the read-only
-- Nix store link so it stays writable).

-- Leader keys must be set before any plugin loads, otherwise plugin mappings
-- that reference <leader> bind to the wrong key.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Load core config before plugins.
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Build hook for telescope-fzf-native (needs `make` to compile the C sorter).
-- The autocommand must be registered BEFORE vim.pack.add so it fires on the
-- very first install, including a fresh bootstrap from the lockfile.
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    if ev.data.spec.name == "telescope-fzf-native.nvim" and ev.data.kind ~= "delete" then
      local dir = ev.data.path
      vim.notify("Building telescope-fzf-native…", vim.log.levels.INFO)
      vim.system({ "make" }, { cwd = dir }, function(out)
        local level = out.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
        vim.schedule(function()
          vim.notify(
            out.code == 0 and "telescope-fzf-native built" or ("fzf-native build failed:\n" .. (out.stderr or "")),
            level
          )
        end)
      end)
    end
  end,
})

local gh = function(repo)
  return "https://github.com/" .. repo
end

vim.pack.add({
  -- UI / colorscheme
  { src = gh("catppuccin/nvim"), name = "catppuccin" },
  { src = gh("nvim-lualine/lualine.nvim") },
  { src = gh("folke/trouble.nvim") },
  { src = gh("nvim-tree/nvim-web-devicons") },

  -- Telescope + deps
  { src = gh("nvim-lua/plenary.nvim") },
  { src = gh("nvim-telescope/telescope.nvim") },
  { src = gh("nvim-telescope/telescope-fzf-native.nvim") },

  -- Editor / git / tpope
  { src = gh("AndrewRadev/switch.vim") },
  { src = gh("christoomey/vim-tmux-navigator") },
  { src = gh("junegunn/goyo.vim") },
  { src = gh("spf13/vim-autoclose") },
  { src = gh("tomtom/tcomment_vim") },
  { src = gh("tpope/vim-abolish") },
  { src = gh("lewis6991/gitsigns.nvim") },
  { src = gh("tpope/vim-fugitive") },
  { src = gh("pwntester/octo.nvim") },
  { src = gh("tpope/vim-projectionist") },
  { src = gh("tpope/vim-repeat") },
  { src = gh("tpope/vim-surround") },
  { src = gh("tpope/vim-unimpaired") },
  { src = gh("tpope/vim-vinegar") },
  { src = gh("yegappan/greplace") },

  -- Completion / AI
  { src = gh("github/copilot.vim") },

  -- Testing
  { src = gh("vim-test/vim-test") },
  { src = gh("preservim/vimux") },

  -- Tasks (taskfile.nvim depends on snacks.nvim)
  { src = gh("folke/snacks.nvim") },
  { src = gh("s0cks/taskfile.nvim") },

  -- which-key
  { src = gh("folke/which-key.nvim") },

  -- direnv integration
  { src = gh("direnv/direnv.vim") },
})

-- Configure plugins now that they are all loaded.
require("config.plugins")

-- Native LSP (replaces nvim-lspconfig + mason).
require("config.lsp")

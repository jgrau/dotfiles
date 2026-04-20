local set = vim.opt

-- Allow netrw (built-in file browser) to delete non-empty directories
vim.g.netrw_localrmdir = "rm -r"

-- Show line numbers in the gutter
set.number = true

-- Use the system clipboard for all yank/paste operations (no separate registers)
set.clipboard = "unnamedplus"

-- Reduce delay before CursorHold event fires (used by LSP for hover/diagnostics)
set.updatetime = 300

-- Enable 24-bit RGB colors (required for most modern colorschemes)
set.termguicolors = true

-- Open vertical splits to the right, horizontal splits below (more natural)
set.splitright = true
set.splitbelow = true

-- Soft tabs: use spaces instead of tab characters, 2 spaces wide
set.tabstop = 2      -- how wide a \t character appears
set.shiftwidth = 2   -- how wide >> / << indents
set.softtabstop = 2  -- how wide Tab key feels in insert mode
set.expandtab = true -- insert spaces instead of \t

-- Don't wrap long lines
set.wrap = false

-- Show invisible characters (tabs and trailing spaces)
set.list = true
set.listchars = "tab:»·,trail:·"

-- No swap files (avoids annoying .swp clutter)
set.swapfile = false

-- Briefly highlight the matching bracket when cursor is on one
set.showmatch = true

-- Show a vertical ruler at column 80 as a line-length guide
set.colorcolumn = "80"

-- Persist undo history across sessions (stored in ~/.local/state/nvim/undo)
set.undofile = true

-- Don't keep a backup copy when overwriting a file
set.writebackup = false

-- Silence error bells (both audio and visual flash)
set.errorbells = false
set.visualbell = false

-- Keep at least 10 lines visible above/below the cursor when scrolling
set.scrolloff = 10

-- Prefer Unix line endings, fall back to DOS/Mac
set.fileformats = "unix,dos,mac"

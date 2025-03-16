-- ~/.config/nvim/lua/config/options.lua
-- Global Vim options

local opt = vim.opt

-- Indentation and tabs
opt.expandtab = true        -- Use spaces instead of tabs
opt.shiftwidth = 2          -- Number of spaces for each indentation
opt.tabstop = 2             -- Number of spaces a tab counts for
opt.softtabstop = 2         -- Number of spaces a tab counts for when editing
opt.smartindent = true      -- Insert indents automatically
opt.autoindent = true       -- Copy indent from current line when starting a new line

-- Line display
opt.number = true           -- Show line numbers
opt.relativenumber = true   -- Show relative line numbers
opt.cursorline = true       -- Highlight current line
opt.wrap = true             -- Wrap lines
opt.linebreak = true        -- Break lines at word boundaries
opt.showmode = false        -- Don't show mode in command line (statusline shows it)
opt.ruler = true            -- Show cursor position

-- Search settings
opt.hlsearch = true         -- Highlight search matches
opt.incsearch = false       -- Don't show partial matches as you type
opt.ignorecase = true       -- Ignore case in search patterns
opt.smartcase = true        -- Override ignorecase when search contains uppercase

-- Window splitting
opt.splitbelow = true       -- Open new horizontal splits below current buffer
opt.splitright = true       -- Open new vertical splits to the right of current buffer

-- User interface
opt.mouse = 'a'             -- Enable mouse for all modes
opt.pumheight = 10          -- Max height of popup menu
opt.showtabline = 2         -- Always show tabline
opt.scrolloff = 5           -- Keep 5 lines above/below cursor visible
opt.sidescrolloff = 5       -- Keep 5 columns left/right of cursor visible

-- Folds
opt.foldenable = true       -- Enable folding
opt.foldmethod = "marker"   -- Use markers for folding

-- File handling
opt.autowriteall = true     -- Automatically save before commands like :next
opt.backup = false          -- Don't create backup files
opt.swapfile = false        -- Don't create swap files
opt.undofile = true         -- Persist undo history across sessions
opt.undolevels = 10000      -- Maximum number of changes that can be undone

-- Clipboard
opt.clipboard = 'unnamedplus' -- Use system clipboard

-- Characters and encodings
opt.fileencoding = "utf-8"  -- Use UTF-8 for file encoding
opt.encoding = "utf-8"      -- Use UTF-8 for vim encoding

-- Terminal options
opt.termguicolors = true    -- Enable 24-bit RGB colors

-- Python provider
vim.g.python3_host_prog = '/usr/bin/python3'

-- Add command to reload config
vim.api.nvim_create_user_command('ReloadConfig', function()
  vim.cmd('source ' .. vim.env.MYVIMRC)
  print('Configuration reloaded!')
end, {})

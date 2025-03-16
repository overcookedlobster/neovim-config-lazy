-- ~/.config/nvim/lua/personal/beamer.lua
-- Beamer folding system for LaTeX presentations

local M = {}

-- Function to determine fold level for beamer frames
local function beamer_fold(lnum)
  local line = vim.fn.getline(lnum)

  if line:match("\\begin{frame}") then
    return ">1"  -- Start a fold at level 1
  elseif line:match("\\end{frame}") then
    return "<1"  -- End a fold at level 1
  else
    return "="   -- Keep current fold level
  end
end

-- Function to set up folding for the current buffer
local function setup_folding()
  vim.wo.foldmethod = "expr"
  vim.wo.foldexpr = "v:lua.require'personal.beamer'.fold(v:lnum)"
  vim.wo.foldlevel = 0  -- Close all folds by default
  vim.cmd("normal! zx")  -- Refresh folds
end

-- Expose the fold function for use in foldexpr
function M.fold(lnum)
  return beamer_fold(lnum)
end

-- Setup function
function M.setup()
  -- Create command to manually activate beamer folding
  vim.api.nvim_create_user_command("BeamerFold", function()
    setup_folding()
  end, {})

  -- Auto-setup for TeX files
  vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = "*.tex",
    callback = function()
      -- Check if this is a beamer document
      local content = vim.api.nvim_buf_get_lines(0, 0, 50, false)
      local is_beamer = false

      for _, line in ipairs(content) do
        if line:match("\\documentclass%s*%[?%s*beamer%s*%]?") or line:match("\\begin{frame}") then
          is_beamer = true
          break
        end
      end

      if is_beamer then
        setup_folding()
      end
    end
  })

  -- Map a key to toggle all folds in a beamer document
  vim.keymap.set('n', '<leader>bf', ':BeamerFold<CR>zM',
    {noremap = true, silent = true, desc = "Set up beamer folding and close all folds"})

  -- Map a key to open all folds
  vim.keymap.set('n', '<leader>bo', 'zR',
    {noremap = true, silent = true, desc = "Open all folds"})

  -- Map a key to close all folds
  vim.keymap.set('n', '<leader>bc', 'zM',
    {noremap = true, silent = true, desc = "Close all folds"})
end

-- Return the module
return M

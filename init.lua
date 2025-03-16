-- ~/.config/nvim/init.lua
-- Main entry point for Neovim configuration
-- Add this to your init.lua (at the very top)
vim.g.jukit_enable_textcell_bg = 0  -- Disable the feature causing errors
vim.g.jukit_text_syntax_file = vim.fn.expand('$VIMRUNTIME/syntax/text.vim')
-- Set leader keys early to ensure consistent behavior
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
-- Ensure vim-jukit can find Python
vim.g.jukit_python_mode = 1
vim.g.jukit_shell_cmd = 'ipython3'

-- Add a small delay before initializing jukit
-- CHECK IF JUKIT HAVING PROBLEM
-- vim.defer_fn(function()
--   if vim.fn.has('python3') == 1 then
--     vim.notify("Python3 support confirmed for vim-jukit")
--   end
-- end, 1000)
-- Load initialization hooks early
require("init-hook").setup()
-- Set the Python provider path explicitly
-- Add near the top of init.lua (before loading lazy.nvim)
vim.g.python3_host_prog = '/usr/bin/python3'

-- Create a Python status check function
-- CHECK IF JUKIT HAVING PROBLEM
-- vim.defer_fn(function()
--   if vim.fn.has('python3') == 1 then
--     vim.notify("Python3 support confirmed")
--   else
--     vim.notify("Python3 support is NOT available!", vim.log.levels.WARN)
--   end
-- end, 500)
-- Optionally disable the health check
-- vim.g.loaded_python3_provider = 1
-- Detect operating system
local has = vim.fn.has
vim.g.os_current = nil
if has("mac") == 1 or has("macunix") == 1 then
  vim.g.os_current = "Darwin"
elseif has("unix") == 1 then
  vim.g.os_current = "Linux"
elseif has("win32") == 1 or has("win64") == 1 then
  vim.g.os_current = "Windows"
end

-- Bootstrap lazy.nvim
require("config.lazy")

-- Load core modules
require("config.options")  -- Vim options
require("config.keymaps")  -- Global keymaps
require("config.autocmds") -- Autocommands

-- Load utility modules
require("utils")

-- Load personal modules
local ok, personal_module = pcall(require, "personal")
if ok and personal_module then
  personal_module.setup()
else
  vim.notify("Failed to load personal modules: " .. tostring(personal_module), vim.log.levels.WARN)
end



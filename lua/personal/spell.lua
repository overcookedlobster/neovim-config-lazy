-- ~/.config/nvim/lua/personal/spell.lua
-- Spell checking utilities

local M = {}

-- Default spellchecking settings
M.config = {
  default_lang = 'en',      -- Default language
  secondary_lang = 'sl',    -- Secondary language (Slovene in this case)
  auto_enable_filetypes = { -- Filetypes to automatically enable spell checking
    'markdown',
    'text',
    'tex',
    'latex',
    'mail',
    'gitcommit',
  },
}

-- Flag to track if Slovene spell checking is enabled
local slovene_spell_enabled = false

-- Function to toggle Slovene spell checking
function M.toggle_slovene_spell()
  if slovene_spell_enabled then
    -- If Slovene spelling is on, turn it off and switch to English
    vim.opt.spelllang:remove('sl')
    vim.opt.spelllang:append('en')
    slovene_spell_enabled = false
    vim.notify("Switched to English spell checking")
  else
    -- If Slovene spelling is off, turn it on and remove English
    vim.opt.spelllang:remove('en')
    vim.opt.spelllang:append('sl')
    slovene_spell_enabled = true
    vim.notify("Switched to Slovene spell checking")
  end
end

-- Function to toggle spell checking
function M.toggle_spell()
  vim.opt.spell = not vim.opt.spell:get()
  vim.notify("Spell checking " .. (vim.opt.spell:get() and "enabled" or "disabled"))
end

-- Function to auto-enable spell checking for specific filetypes
local function setup_auto_spell()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = M.config.auto_enable_filetypes,
    callback = function()
      vim.opt_local.spell = true
      vim.opt_local.spelllang = M.config.default_lang
    end,
  })
end

-- Setup function
function M.setup(opts)
  -- Merge user options with defaults
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  -- Set up global defaults
  vim.opt.spelllang = M.config.default_lang

  -- Set up auto spell checking
  setup_auto_spell()

  -- Create user commands
  vim.api.nvim_create_user_command('SpellToggle', function()
    M.toggle_spell()
  end, {})

  vim.api.nvim_create_user_command('SpellSlovene', function()
    M.toggle_slovene_spell()
  end, {})

  -- Set up key mappings
  vim.keymap.set('n', '<leader>zz', M.toggle_spell,
    {noremap = true, silent = true, desc = "Toggle spell checking"})
  vim.keymap.set('n', '<leader>zs', M.toggle_slovene_spell,
    {noremap = true, silent = true, desc = "Toggle Slovene spell checking"})

  -- Spell checking suggestions mappings
  vim.keymap.set('n', '<leader>zn', ']s',
    {noremap = true, silent = true, desc = "Next misspelled word"})
  vim.keymap.set('n', '<leader>zp', '[s',
    {noremap = true, silent = true, desc = "Previous misspelled word"})
  vim.keymap.set('n', '<leader>za', 'zg',
    {noremap = true, silent = true, desc = "Add word to dictionary"})
  vim.keymap.set('n', '<leader>z?', function()
    vim.cmd('normal! z=')
  end, {noremap = true, silent = true, desc = "Show spelling suggestions"})
end

-- Return the module
return M

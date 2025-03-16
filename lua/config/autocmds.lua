-- ~/.config/nvim/lua/config/autocmds.lua
-- Global autocommands

-- Create autocommand groups
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- General settings group
local general_group = augroup("GeneralSettings", { clear = true })

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
  group = general_group,
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

-- Terminal handling
autocmd("BufEnter", {
  pattern = "term://*",
  command = "startinsert",
})

autocmd("BufLeave", {
  pattern = "term://*",
  command = "stopinsert",
})

-- Disable auto-commenting on new lines
autocmd("FileType", {
  group = general_group,
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- Enable spelling for certain file types
autocmd("FileType", {
  group = general_group,
  pattern = { "markdown", "text", "tex", "latex" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
})

-- Set custom comment color
autocmd("ColorScheme", {
  group = general_group,
  callback = function()
    vim.api.nvim_set_hl(0, "Comment", { fg = "#5f87af", bg = "NONE" })
  end,
})

-- LaTeX settings group
local latex_group = augroup("LaTeXSettings", { clear = true })

-- VimTeX omnifunc
autocmd("FileType", {
  group = latex_group,
  pattern = "tex",
  callback = function()
    vim.bo.omnifunc = 'vimtex#complete#omnifunc'
  end,
})

-- SystemVerilog settings group
local sv_group = augroup("SystemVerilog", { clear = true })

-- Load SystemVerilog snippets
autocmd("FileType", {
  pattern = "systemverilog",
  group = sv_group,
  callback = function()
    require("luasnip.loaders.from_lua").load({paths = vim.fn.stdpath('config') .. "/snippets/sv/"})
  end,
})

-- Handle diagnostic updates on tab switching for SystemVerilog files
local tab_switching = false

autocmd("TabLeave", {
  group = sv_group,
  callback = function()
    tab_switching = true
  end,
})

autocmd("BufEnter", {
  group = sv_group,
  pattern = {"*.sv", "*.v"},
  callback = function()
    if tab_switching then
      -- Ignore diagnostic updates on tab switch
      tab_switching = false
    else
      -- Perform diagnostic updates
      vim.diagnostic.show()
      -- We'll move this function to the utils module later
      -- require("utils").refresh_diagnostics()
    end
  end,
})

-- Filetype detection
autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*.sv,*.svh",
  command = "set filetype=systemverilog",
})

-- Reload plugins when plugins.lua is saved
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins/*.lua source <afile>
  augroup end
]])

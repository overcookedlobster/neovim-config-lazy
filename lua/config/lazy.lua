-- ~/.config/nvim/lua/config/lazy.lua
-- Bootstrap and configure lazy.nvim

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Configure lazy.nvim
require("lazy").setup({
  spec = {
    -- Import plugin specifications from separate files
    { import = "plugins.ui" },     -- UI-related plugins
    { import = "plugins.editor" }, -- Editor enhancement plugins
    { import = "plugins.coding" }, -- Coding-related plugins
    { import = "plugins.lsp" },    -- LSP configurations
    { import = "plugins.tex" },    -- LaTeX tools
    { import = "plugins.tools" },  -- Utilities and tools
  },
  defaults = {
    lazy = false,                  -- Load plugins on startup by default
    version = false,               -- Use latest git commit by default
  },
  install = {
    colorscheme = { "gruvbox-material" }, -- Colorscheme to use during installation
  },
  checker = { 
    enabled = true,                -- Check for plugin updates
    frequency = 3600,              -- Check once per hour
  },
  change_detection = {
    enabled = true,                -- Auto-reload config on changes
    notify = false,                -- Don't show notifications on changes
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

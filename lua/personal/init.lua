-- ~/.config/nvim/lua/personal/init.lua
-- Personal modules loader

local M = {}

-- Helper function to safely require a module
local function safe_require(module_name)
  local ok, module = pcall(require, module_name)
  if not ok then
    vim.notify("Failed to load " .. module_name .. ": " .. tostring(module), vim.log.levels.WARN)
    return nil
  end
  return module
end

-- Function to safely setup a module if it exists
local function safe_setup(module_name, opts)
  local module = safe_require(module_name)
  if module and type(module.setup) == "function" then
    local setup_ok, err = pcall(function()
      if opts then
        module.setup(opts)
      else
        module.setup()
      end
    end)

    if not setup_ok then
      vim.notify("Error setting up " .. module_name .. ": " .. tostring(err), vim.log.levels.ERROR)
    end
  end
end

-- Set up all personal modules
function M.setup()
  -- vim.notify("Setting up personal modules...")

  -- Set up modules with error handling
  safe_setup("personal.transient", {
    width = 0.6,  -- 60% of screen width
    height = 0.7, -- 70% of screen height
    notes_dir = vim.fn.expand('~/Documents/my_notes/'),
  })

  safe_setup("personal.checklist")
  safe_setup("personal.beamer")
  safe_setup("personal.concat")
  safe_setup("personal.spell")

  -- vim.notify("Personal modules setup complete")
end

-- Return the module table (THIS LINE IS CRITICAL)
return M

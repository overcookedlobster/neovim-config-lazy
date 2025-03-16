-- ~/.config/nvim/lua/utils/dependency.lua
-- Dependency checking utilities

local M = {}

-- Function to check if a command exists
M.check_command = function(command)
  local handle = io.popen('command -v ' .. command .. ' 2>/dev/null')
  local result = handle:read('*a')
  handle:close()
  return result ~= ''
end

-- Function to check a dependency and notify if missing
M.check_dependency = function(name, check_func)
  local ok = check_func()
  if not ok then
    vim.notify('Dependency ' .. name .. ' not found. Some features may not work.', vim.log.levels.WARN)
  end
  return ok
end

-- Check all required dependencies at once
M.check_dependencies = function()
  -- List of dependencies to check
  local dependencies = {
    { name = "git", check = function() return M.check_command('git') end },
    { name = "nodejs", check = function() return M.check_command('node') end },
    { name = "python3", check = function() return M.check_command('python3') end },
    { name = "ripgrep", check = function() return M.check_command('rg') end },
    { name = "xclip", check = function() return M.check_command('xclip') end },
    { name = "zathura", check = function() return M.check_command('zathura') end },
  }

  -- Add SystemVerilog-specific dependencies if working with SV files
  local ft = vim.bo.filetype
  if ft == 'systemverilog' or ft == 'verilog' then
    table.insert(dependencies, {
      name = "verilator",
      check = function() return M.check_command('verilator') end
    })
    table.insert(dependencies, {
      name = "svls",
      check = function() return M.check_command('svls') end
    })
  end

  -- Check each dependency
  local results = {}
  for _, dep in ipairs(dependencies) do
    results[dep.name] = M.check_dependency(dep.name, dep.check)
  end

  return results
end

-- Return the module
return M

-- ~/.config/nvim/lua/utils/init.lua
-- Utilities loader

-- Load utility modules
local M = {}

-- Setup function to initialize all utilities
function M.setup()
  -- Load dependency check utilities
  require("utils.dependency").check_dependencies()

  -- Load helper functions
  require("utils.functions").setup()

  -- Load diagnostic utilities if in a SystemVerilog file
  if vim.bo.filetype == "systemverilog" or vim.bo.filetype == "verilog" then
    M.refresh_diagnostics()
  end
end

-- Function to check if the current buffer is a SystemVerilog file
M.is_sv_file = function()
  local ft = vim.bo.filetype
  return ft == 'systemverilog' or ft == 'verilog'
end

-- Function to run Verilator diagnostics for SystemVerilog files
M.verilator_diagnostics = function()
  if not M.is_sv_file() then return end

  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local cmd = string.format("verilator --lint-only -Wall %s 2>&1", filename)
  local output = vim.fn.system(cmd)
  local diagnostics = {}

  for line in output:gmatch("[^\r\n]+") do
    local lnum, col, type, msg = line:match("(%d+):(%d+):%s*(%w+):%s*(.*)")
    if lnum and col and type and msg then
      table.insert(diagnostics, {
        lnum = tonumber(lnum) - 1,
        col = tonumber(col) - 1,
        severity = type == "Error" and vim.diagnostic.severity.ERROR or vim.diagnostic.severity.WARN,
        message = msg,
        source = "Verilator"
      })
    end
  end

  local namespace = vim.api.nvim_create_namespace("verilator")
  vim.diagnostic.reset(namespace, bufnr)
  vim.diagnostic.set(namespace, bufnr, diagnostics)
end

-- Function to refresh diagnostics
M.refresh_diagnostics = function()
  if not M.is_sv_file() then return end

  local bufnr = vim.api.nvim_get_current_buf()

  local current_diagnostics = vim.diagnostic.get(bufnr)

  if #current_diagnostics == 0 then
    M.verilator_diagnostics()
  end

  current_diagnostics = vim.diagnostic.get(bufnr)

  -- Log diagnostics to the messages buffer
  for _, diagnostic in ipairs(current_diagnostics) do
    vim.notify(string.format("Line %d: %s", diagnostic.lnum + 1, diagnostic.message))
  end
end

-- Return the module
return M

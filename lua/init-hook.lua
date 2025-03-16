-- ~/.config/nvim/lua/init-hook.lua
local M = {}

function M.setup()
  -- Python provider configuration
  vim.g.python3_host_prog = vim.fn.exepath('python3')

  -- Check and notify about Python status
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      -- Check Python support status
      local has_python = vim.fn.has('python3') == 1

      if not has_python then
        vim.notify([[
Python3 support is missing! For vim-jukit to work:

1. Install Python and pynvim:
   pip install pynvim

2. Verify Python path in init.lua:
   vim.g.python3_host_prog = ']] .. vim.g.python3_host_prog .. [['

3. Run :checkhealth provider
        ]], vim.log.levels.WARN)
      end
    end,
    once = true,
  })
end

return M

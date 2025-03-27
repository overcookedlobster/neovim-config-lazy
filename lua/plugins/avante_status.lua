-- ~/.config/nvim/lua/plugins/avante_status.lua
-- Set global status line when Avante is active

return {
  {
    "yetone/avante.nvim",
    init = function()
      -- Set global status line when Avante is loaded
      vim.opt.laststatus = 3
    end,
  }
}

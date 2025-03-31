-- ~/.config/nvim/lua/plugins/avante_resize.lua
-- Add resize keybindings for Avante bars

return {
  {
    "yetone/avante.nvim",
    keys = {
      -- Horizontal resize
      {"<leader>a[", function()
        -- Add a small delay
        vim.defer_fn(function()
          -- Find Avante window by filetype
          local wins = vim.api.nvim_list_wins()
          for _, win in ipairs(wins) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == 'Avante' then
              local current_width = vim.api.nvim_win_get_width(win)
              local new_width = math.max(40, current_width - 10) -- Minimum width of 40
              vim.api.nvim_win_set_width(win, new_width)
              vim.notify("Avante width: " .. new_width, vim.log.levels.INFO)
              return
            end
          end
          vim.notify("Avante window not found", vim.log.levels.WARN)
        end, 200) -- Delay of 200ms
      end, desc = "Decrease Avante width"},

      {"<leader>a]", function()
        -- Add a small delay
        vim.defer_fn(function()
          -- Find Avante window by filetype
          local wins = vim.api.nvim_list_wins()
          for _, win in ipairs(wins) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == 'Avante' then
              local current_width = vim.api.nvim_win_get_width(win)
              local new_width = math.min(120, current_width + 10) -- Maximum width of 120
              vim.api.nvim_win_set_width(win, new_width)
              vim.notify("Avante width: " .. new_width, vim.log.levels.INFO)
              return
            end
          end
          vim.notify("Avante window not found", vim.log.levels.WARN)
        end, 200) -- Delay of 200ms
      end, desc = "Increase Avante width"},

      -- Vertical resize
      {"<leader>a-", function()
        -- Add a small delay
        vim.defer_fn(function()
          -- Find Avante window by filetype
          local wins = vim.api.nvim_list_wins()
          for _, win in ipairs(wins) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == 'Avante' then
              local current_height = vim.api.nvim_win_get_height(win)
              local new_height = math.max(10, current_height - 5) -- Minimum height of 10
              vim.api.nvim_win_set_height(win, new_height)
              vim.notify("Avante height: " .. new_height, vim.log.levels.INFO)
              return
            end
          end
          vim.notify("Avante window not found", vim.log.levels.WARN)
        end, 200) -- Delay of 200ms
      end, desc = "Decrease Avante height"},

      {"<leader>a=", function()
        -- Add a small delay
        vim.defer_fn(function()
          -- Find Avante window by filetype
          local wins = vim.api.nvim_list_wins()
          for _, win in ipairs(wins) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == 'Avante' then
              local current_height = vim.api.nvim_win_get_height(win)
              local new_height = math.min(40, current_height + 5) -- Maximum height of 40
              vim.api.nvim_win_set_height(win, new_height)
              vim.notify("Avante height: " .. new_height, vim.log.levels.INFO)
              return
            end
          end
          vim.notify("Avante window not found", vim.log.levels.WARN)
        end, 200) -- Delay of 200ms
      end, desc = "Increase Avante height"},
    },
  }
}

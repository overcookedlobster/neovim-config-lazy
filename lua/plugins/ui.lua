-- ~/.config/nvim/lua/plugins/ui.lua
-- UI-related plugins

return {
  -- Colorscheme: Gruvbox Material
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000, -- Load colorscheme before other plugins
    config = function()
      -- Configure Gruvbox Material
      vim.g.gruvbox_material_background = "soft"
      vim.g.gruvbox_material_ui_contrast = "high"
      vim.g.gruvbox_material_foreground = "original"
      vim.g.gruvbox_material_enable_italic = 1
      vim.g.gruvbox_material_enable_bold = 1
      vim.g.gruvbox_material_better_performance = 1

      -- Set the colorscheme
      vim.cmd("colorscheme gruvbox-material")
    end,
  },

  -- Statusline: Lualine
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = "auto",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = {},
          always_divide_middle = true,
          globalstatus = false,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "encoding", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" }
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {}
        },
        tabline = {},
        extensions = {}
      })
    end,
  },

  -- Notifications: nvim-notify
  {
    "rcarriga/nvim-notify",
    config = function()
      require("notify").setup({
        background_colour = "#000000",
        render = "compact",
        top_down = false,
      })

      -- Set nvim-notify as the default notification handler
      vim.notify = require("notify")
    end,
  },

  -- Trouble: Better diagnostics window
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "Trouble", "TroubleToggle" },
    config = function()
      require("trouble").setup({
        -- Default configuration
      })

      -- Keymaps
      vim.keymap.set("n", "<leader>xx", "<cmd>Trouble<cr>",
        { silent = true, noremap = true, desc = "Trouble: Open diagnostics" })
    end,
  },

  -- Other UI-related plugins
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },

  -- Colorscheme collection for variety
  {
    "kepano/flexoki",
    lazy = true,
    priority = 900,
  },

  {
    "Shatur/neovim-ayu",
    lazy = true,
    priority = 900,
  },

  {
    "cideM/yui",
    lazy = true,
    priority = 900,
  },

  {
    "jsit/toast.vim",
    lazy = true,
    priority = 900,
  },
}

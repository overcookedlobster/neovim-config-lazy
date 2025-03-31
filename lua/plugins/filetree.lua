-- ~/.config/nvim/lua/plugins/filetree.lua
-- File explorer plugin configuration

return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons", -- optional, for file icons
    },
    version = "*", -- Use the latest stable release
    config = function()
      -- Disable netrw completely
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      -- Set termguicolors to enable highlight groups
      vim.opt.termguicolors = true

      require("nvim-tree").setup({
        sort_by = "case_sensitive",
        view = {
          width = 30,
          adaptive_size = false,
        },
        renderer = {
          group_empty = true,
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
          },
        },
        filters = {
          dotfiles = false,
        },
        git = {
          enable = true,
          ignore = false,
          timeout = 500,
        },
        actions = {
          open_file = {
            quit_on_open = false,
            resize_window = true,
            window_picker = {
              enable = true,
            },
          },
        },
      })

      -- Keymaps
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true, desc = "Toggle NvimTree" })
      vim.keymap.set("n", "<leader>fe", ":NvimTreeFindFile<CR>", { silent = true, desc = "Find file in NvimTree" })
    end,
  },
}

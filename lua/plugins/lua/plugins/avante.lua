-- ~/.config/nvim/lua/plugins/avante.lua
-- Avante AI assistant configuration

return {
  -- Avante AI assistant
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    keys = {
      {"<leader>ar", "<cmd>AvanteClear<CR>", desc="Clear/Reset Avante Chat"},
      {"<leader>aa", "<cmd>Avante<CR>", desc="Open Avante Chat"},
      {"<leader>as", "<cmd>AvanteSelection<CR>", desc="Send Selection to Avante"},
    },
    version = false, -- Never set this value to "*"! Never!
    opts = {
      provider = "claude", -- Default AI provider

      -- OpenAI configuration
      openai = {
        endpoint = "https://api.openai.com/v1",
        model = "gpt-4o", -- your desired model
        timeout = 30000, -- Timeout in milliseconds
        temperature = 0,
        max_completion_tokens = 8192,
        reasoning_effort = "medium", -- low|medium|high, only for reasoning models
      },

      -- Claude configuration (if you use it)
      claude = {
        endpoint = "https://api.anthropic.com/v1/messages",
        model = "claude-3-opus-20240229", -- or claude-3-sonnet/haiku
        timeout = 60000,
        temperature = 0,
        max_completion_tokens = 8192,
      },

      -- UI configuration
      ui = {
        width = 0.8, -- Width of the Avante window (0-1 for percentage)
        height = 0.8, -- Height of the Avante window (0-1 for percentage)
        border = "rounded", -- Border style: "none", "single", "double", "rounded"
        winblend = 0, -- Window transparency (0-100)
      },

      -- File handling
      file_picker = "telescope", -- "telescope", "fzf", or "mini.pick"

      -- Keybindings in Avante buffer
      keymaps = {
        close = "q",
        submit = "<C-s>",
        submit_and_close = "<C-Enter>",
        stop = "<C-c>",
        new_chat = "<C-n>",
      },

      -- Image handling
      images = {
        max_width = 50, -- Maximum width of images in cells
        max_height = 20, -- Maximum height of images in cells
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "echasnovski/mini.pick", -- for file_selector provider mini.pick
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
}


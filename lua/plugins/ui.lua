-- ~/.config/nvim/lua/plugins/ui.lua
-- UI-related plugins

return {
	-- Which-key - Show available keybindings
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		config = function()
			local wk = require("which-key")
			wk.setup({
				-- your configuration comes here
				-- or leave it empty to use the default settings
			})
		end,
	},
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
					lualine_z = { "location" },
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = { { "filename", path = 1 } },
					lualine_x = { "location" },
					lualine_y = {},
					lualine_z = {},
				},
				tabline = {},
				extensions = {},
			})
		end,
	},

	-- Modern UI for messages, cmdline and popupmenu: noice.nvim
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		config = function()
			require("noice").setup({
				lsp = {
					-- Override markdown rendering so that **cmp** and other plugins use **Treesitter**
					override = {
						["vim.lsp.util.convert_input_to_markdown_lines"] = true,
						["vim.lsp.util.stylize_markdown"] = true,
						["cmp.entry.get_documentation"] = true,
					},
				},
				-- You can enable a preset for easier configuration
				presets = {
					bottom_search = true, -- Use a classic bottom cmdline for search
					command_palette = true, -- Position the cmdline and popupmenu together
					long_message_to_split = true, -- Long messages will be sent to a split
					inc_rename = false, -- Enables an input dialog for inc-rename.nvim
					lsp_doc_border = false, -- Add a border to hover docs and signature help
				},
				-- Configure the cmdline to appear at the top
				cmdline = {
					enabled = true, -- Enable cmdline UI
					view = "cmdline_popup", -- View for rendering the cmdline
					opts = {}, -- Global options for the cmdline
					format = {
						-- Conceal the long command line text
						cmdline = { pattern = "^:", icon = "", lang = "vim" },
						search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
						search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
						filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
						lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
						help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
						input = {}, -- Used by input()
					},
				},
				messages = {
					-- NOTE: If you enable messages, then the cmdline is enabled automatically.
					-- This is a current Neovim limitation.
					enabled = false, -- Disable noice messages to let nvim-notify handle notifications
					view = "notify", -- Default view for messages
					view_error = "notify", -- View for errors
					view_warn = "notify", -- View for warnings
					view_history = "messages", -- View for :messages
					view_search = "virtualtext", -- View for search count messages
				},
				popupmenu = {
					enabled = true, -- Enable popupmenu UI
					backend = "nui", -- Backend to use to show regular cmdline completions
					kind_icons = {}, -- Set to `false` to disable icons
				},
				-- Disable noice notify to prevent interference with nvim-notify
				notify = {
					enabled = false, -- Disable noice notify completely
				},
				-- Configure views
				views = {
					cmdline_popup = {
						position = {
							row = 5,
							col = "50%",
						},
						size = {
							width = 60,
							height = "auto",
						},
					},
					popupmenu = {
						relative = "editor",
						position = {
							row = 8,
							col = "50%",
						},
						size = {
							width = 60,
							height = 10,
						},
						border = {
							style = "rounded",
							padding = { 0, 1 },
						},
						win_options = {
							winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
						},
					},
				},
			})

			-- Ensure nvim-notify remains the notification handler after noice setup
			local notify = require("notify")
			vim.notify = notify
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
			vim.keymap.set(
				"n",
				"<leader>xx",
				"<cmd>Trouble<cr>",
				{ silent = true, noremap = true, desc = "Trouble: Open diagnostics" }
			)
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

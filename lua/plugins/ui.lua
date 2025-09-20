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

			-- Define leader key groups for better organization
			wk.add({
				-- AI operations (Avante) - <leader>a reserved for Avante
				{ "<leader>a", group = "AI (Avante)" },
				{ "<leader>aa", desc = "Avante: Ask question" },
				{ "<leader>ac", desc = "Avante: Open chat" },
				{ "<leader>ae", desc = "Avante: Edit with AI" },
				{ "<leader>at", desc = "Avante: Toggle panel" },
				{ "<leader>ar", desc = "Avante: Refresh" },
				{ "<leader>ax", desc = "Avante: Clear session" },
				{ "<leader>ap", desc = "Avante: Switch provider" },
				{ "<leader>am", desc = "Avante: Switch model" },
				{ "<leader>al", desc = "Avante: Load conversation" },
				{ "<leader>as", desc = "Avante: Save conversation" },
				{ "<leader>ad", desc = "Avante: Delete conversation" },
				{ "<leader>ah", group = "Avante History" },
				{ "<leader>ahl", desc = "Avante: List conversation history" },
				{ "<leader>ahs", desc = "Avante: Search conversation history" },
				{ "<leader>ahc", desc = "Avante: Clear conversation history" },
				{ "<leader>ahe", desc = "Avante: Export conversation history" },

				-- Buffer operations
				{ "<leader>b", group = "Buffers" },

				-- Code/Config operations
				{ "<leader>c", group = "Code/Config" },

				-- Explorer (single key)
				{ "<leader>e", desc = "Explorer: Toggle NvimTree" },

				-- File operations
				{ "<leader>f", group = "Files" },

				-- Git operations
				{ "<leader>g", group = "Git" },

				-- Help/Documentation
				{ "<leader>h", group = "Help/Documentation" },
				{ "<leader>hm", desc = "Help: Open Mason" },
				{ "<leader>hM", desc = "Help: Mason update" },
				{ "<leader>hi", desc = "Help: Mason install" },
				{ "<leader>hc", desc = "Help: ConformInfo" },
				{ "<leader>hl", desc = "Help: LspInfo" },
				{ "<leader>hr", desc = "Help: LspRestart" },

				-- Jump/Navigation
				{ "<leader>j", group = "Jump/Navigation" },
				{ "<leader>jh", desc = "Jump: Switch to header/source" },
				{ "<leader>jf", desc = "Jump: Find related files" },

				-- LeetCode operations
				{ "<leader>L", group = "LeetCode" },
				{ "<leader>Ll", desc = "LeetCode: List problems" },
				{ "<leader>Lr", desc = "LeetCode: Run code" },
				{ "<leader>Ls", desc = "LeetCode: Submit" },
				{ "<leader>Lt", desc = "LeetCode: Test" },
				{ "<leader>Li", desc = "LeetCode: Problem info" },
				{ "<leader>Ld", desc = "LeetCode: Daily problem" },
				{ "<leader>Lc", desc = "LeetCode: Console toggle" },
				{ "<leader>Lm", desc = "LeetCode: Menu" },
				{ "<leader>Lo", desc = "LeetCode: Open problem" },
				{ "<leader>Lp", desc = "LeetCode: Pick problem" },
				{ "<leader>Lq", desc = "LeetCode: Close" },

				-- Mason/Tools management
				{ "<leader>m", group = "Mason/Tools" },
				{ "<leader>mm", desc = "Mason: Open Mason" },
				{ "<leader>mu", desc = "Mason: Update all" },
				{ "<leader>mi", desc = "Mason: Install package" },
				{ "<leader>ml", desc = "Lint: Run linter" },
				{ "<leader>mf", desc = "Format: Format buffer" },

				-- Notes operations
				{ "<leader>n", group = "Notes" },

				-- OpenCode AI operations
				{ "<leader>o", group = "OpenCode AI" },

				-- AI operations (Parrot) - moved to <leader>p to avoid conflict
				{ "<leader>p", group = "AI (Parrot)" },

				-- Search operations (Telescope)
				{ "<leader>s", group = "Search (Telescope)" },

				-- Terminal/Tab operations
				{ "<leader>t", group = "Terminal/Tabs" },

				-- Utilities
				{ "<leader>u", group = "Utilities" },
				{ "<leader>uc", group = "Convert" },
				{ "<leader>ucd", desc = "Convert: To decimal" },
				{ "<leader>uch", desc = "Convert: To hexadecimal" },
				{ "<leader>uco", desc = "Convert: To octal" },
				{ "<leader>ucb", desc = "Convert: To binary" },
				{ "<leader>ucs", desc = "Convert: To string" },
				{ "<leader>ucB", desc = "Convert: Bytes" },
				{ "<leader>ucf", desc = "Convert: Fahrenheit" },
				{ "<leader>ucC", desc = "Convert: Celsius" },
				{ "<leader>ui", desc = "Utilities: Paste image from clipboard" },
				{ "<leader>uj", group = "Jupyter (Jukit)" },
				{ "<leader>ujs", desc = "Jukit: Start output split" },
				{ "<leader>ujr", desc = "Jukit: Run current cell" },
				{ "<leader>ujR", desc = "Jukit: Run all cells" },
				{ "<leader>ujd", desc = "Jukit: Delete current cell" },
				{ "<leader>ujc", desc = "Jukit: Create new cell" },

				-- Theme operations
				{ "<leader>ut", group = "UI Themes" },
				{ "<leader>ug", desc = "UI: Gruvbox Material theme" },
				{ "<leader>ut1", desc = "UI: Tokyo Night theme" },
				{ "<leader>ut2", desc = "UI: Catppuccin Mocha theme" },
				{ "<leader>ut3", desc = "UI: Rose Pine theme" },
				{ "<leader>ut4", desc = "UI: Kanagawa Wave theme" },
				{ "<leader>ut5", desc = "UI: Nightfox theme" },
				{ "<leader>ut6", desc = "UI: VSCode theme" },
				{ "<leader>ut7", desc = "UI: OneDark theme" },
				{ "<leader>ut8", desc = "UI: Material theme" },
				{ "<leader>ut9", desc = "UI: GitHub Dark theme" },
				{ "<leader>utt", desc = "UI: Toggle light/dark theme" },
				{ "<leader>uti", desc = "UI: Show current theme info" },
				{ "<leader>utr", desc = "UI: Random theme" },
				{ "<leader>utc", desc = "UI: Cycle favorite themes" },

				-- Window operations
				{ "<leader>w", group = "Windows" },

				-- Development/Debug operations
				{ "<leader>d", group = "Debug/Development" },

				-- Diagnostics/Trouble
				{ "<leader>x", group = "Diagnostics" },

				-- Spell checking operations
				{ "<leader>z", group = "Spell Checking" },
			})

			-- Filetype-specific which-key groups
			-- TeX/LaTeX specific keymaps (only active when editing .tex files)
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "tex",
				callback = function()
					wk.add({
						-- LaTeX group with intuitive <leader>l prefix
						{ "<leader>l", group = "LaTeX", buffer = 0 },
						{ "<leader>lc", desc = "LaTeX: Compile document", buffer = 0 },
						{ "<leader>lr", desc = "LaTeX: Recompile document", buffer = 0 },
						{ "<leader>lv", desc = "LaTeX: View PDF", buffer = 0 },
						{ "<leader>li", desc = "LaTeX: Show info", buffer = 0 },
						{ "<leader>lt", desc = "LaTeX: Toggle table of contents", buffer = 0 },
						{ "<leader>le", desc = "LaTeX: Toggle shell escape", buffer = 0 },
						{ "<leader>lk", desc = "LaTeX: Stop compilation", buffer = 0 },
						{ "<leader>ll", desc = "LaTeX: Start continuous compilation", buffer = 0 },
						{ "<leader>lx", desc = "LaTeX: Clean auxiliary files", buffer = 0 },
						{ "<leader>lX", desc = "LaTeX: Clean all files", buffer = 0 },
						{ "<leader>ls", desc = "LaTeX: Show status", buffer = 0 },
						{ "<leader>lg", desc = "LaTeX: Show log", buffer = 0 },

						-- TeX text object operations
						{ "ds", group = "Delete Surrounding (TeX)", buffer = 0 },
						{ "dse", desc = "TeX: Delete surrounding environment", buffer = 0 },
						{ "dsc", desc = "TeX: Delete surrounding command", buffer = 0 },
						{ "dsm", desc = "TeX: Delete surrounding math", buffer = 0 },
						{ "dsd", desc = "TeX: Delete surrounding delimiters", buffer = 0 },

						{ "cs", group = "Change Surrounding (TeX)", buffer = 0 },
						{ "cse", desc = "TeX: Change surrounding environment", buffer = 0 },
						{ "csc", desc = "TeX: Change surrounding command", buffer = 0 },
						{ "csm", desc = "TeX: Change surrounding math", buffer = 0 },
						{ "csd", desc = "TeX: Change surrounding delimiters", buffer = 0 },

						{ "ts", group = "Toggle (TeX)", buffer = 0 },
						{ "tsf", desc = "TeX: Toggle fraction command", buffer = 0 },
						{ "tsc", desc = "TeX: Toggle command star", buffer = 0 },
						{ "tse", desc = "TeX: Toggle environment star", buffer = 0 },
						{ "tsd", desc = "TeX: Toggle delimiter modifier", buffer = 0 },
						{ "tsD", desc = "TeX: Toggle delimiter modifier (reverse)", buffer = 0 },
						{ "tsm", desc = "TeX: Toggle math environment", buffer = 0 },

						-- TeX motions
						{ "]", group = "Next (TeX)", buffer = 0 },
						{ "]]", desc = "TeX: Next section start", buffer = 0 },
						{ "][", desc = "TeX: Next section end", buffer = 0 },
						{ "]m", desc = "TeX: Next section", buffer = 0 },
						{ "]M", desc = "TeX: Next section end", buffer = 0 },
						{ "]n", desc = "TeX: Next environment", buffer = 0 },
						{ "]N", desc = "TeX: Next environment end", buffer = 0 },
						{ "]r", desc = "TeX: Next item", buffer = 0 },
						{ "]R", desc = "TeX: Next item end", buffer = 0 },
						{ "]/", desc = "TeX: Next comment", buffer = 0 },
						{ "]*", desc = "TeX: Next comment end", buffer = 0 },

						{ "[", group = "Previous (TeX)", buffer = 0 },
						{ "[]", desc = "TeX: Previous section end", buffer = 0 },
						{ "[[", desc = "TeX: Previous section start", buffer = 0 },
						{ "[m", desc = "TeX: Previous section", buffer = 0 },
						{ "[M", desc = "TeX: Previous section end", buffer = 0 },
						{ "[n", desc = "TeX: Previous environment", buffer = 0 },
						{ "[N", desc = "TeX: Previous environment end", buffer = 0 },
						{ "[r", desc = "TeX: Previous item", buffer = 0 },
						{ "[R", desc = "TeX: Previous item end", buffer = 0 },
						{ "[/", desc = "TeX: Previous comment", buffer = 0 },
						{ "[*", desc = "TeX: Previous comment end", buffer = 0 },
					})
				end,
			})

			-- CSV/TSV specific keymaps (only active when editing .csv/.tsv files)
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "csv", "tsv" },
				callback = function()
					wk.add({
						-- CSV operations under Code/Config group
						{ "<leader>cv", desc = "CSV: Toggle CSV view", buffer = 0 },
						{ "<leader>ce", desc = "CSV: Enable CSV view", buffer = 0 },
						{ "<leader>cd", desc = "CSV: Disable CSV view", buffer = 0 },
						{ "<leader>cb", desc = "CSV: Toggle with border mode", buffer = 0 },
						{ "<leader>ch", desc = "CSV: Toggle with highlight mode", buffer = 0 },
					})
				end,
			})
		end,
	},
	-- Colorscheme: Kanagawa Wave (Default)
	{
		"rebelot/kanagawa.nvim",
		lazy = false,
		priority = 1000, -- Load colorscheme before other plugins
		config = function()
			require("kanagawa").setup({
				compile = false,
				undercurl = true,
				commentStyle = { italic = true },
				functionStyle = {},
				keywordStyle = { italic = true },
				statementStyle = { bold = true },
				typeStyle = {},
				transparent = false,
				dimInactive = false,
				terminalColors = true,
				colors = {
					palette = {},
					theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
				},
				overrides = function(colors)
					return {}
				end,
				theme = "wave", -- Load "wave" theme when 'background' option is not set
				background = {
					dark = "wave", -- try "dragon" !
					light = "lotus",
				},
			})

			-- Set default colorscheme (themery will handle persistence)
			vim.cmd("colorscheme kanagawa-wave")
		end,
	},

	-- Colorscheme: Gruvbox Material (Available via Themery)
	{
		"sainnhe/gruvbox-material",
		lazy = true,
		priority = 900,
		config = function()
			-- Configure Gruvbox Material
			vim.g.gruvbox_material_background = "soft"
			vim.g.gruvbox_material_ui_contrast = "high"
			vim.g.gruvbox_material_foreground = "original"
			vim.g.gruvbox_material_enable_italic = 1
			vim.g.gruvbox_material_enable_bold = 1
			vim.g.gruvbox_material_better_performance = 1
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

			-- Keymaps moved to main keymaps.lua for better organization
		end,
	},

	-- Themery: Theme switcher with persistence and live preview
	{
		"zaldih/themery.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("themery").setup({
				themes = {
					-- Modern Popular Themes
					{
						name = "Tokyo Night",
						colorscheme = "tokyonight",
					},
					{
						name = "Tokyo Night Storm",
						colorscheme = "tokyonight-storm",
					},
					{
						name = "Tokyo Night Moon",
						colorscheme = "tokyonight-moon",
					},
					{
						name = "Tokyo Night Day",
						colorscheme = "tokyonight-day",
					},

					-- Catppuccin Variants
					{
						name = "Catppuccin Mocha",
						colorscheme = "catppuccin-mocha",
					},
					{
						name = "Catppuccin Latte",
						colorscheme = "catppuccin-latte",
					},
					{
						name = "Catppuccin Frappe",
						colorscheme = "catppuccin-frappe",
					},
					{
						name = "Catppuccin Macchiato",
						colorscheme = "catppuccin-macchiato",
					},

					-- Rose Pine Variants
					{
						name = "🌹 Rose Pine",
						colorscheme = "rose-pine",
					},
					{
						name = "🌙 Rose Pine Moon",
						colorscheme = "rose-pine-moon",
					},
					{
						name = "🌅 Rose Pine Dawn",
						colorscheme = "rose-pine-dawn",
					},

					-- Kanagawa Variants
					{
						name = "🌊 Kanagawa Wave",
						colorscheme = "kanagawa-wave",
					},
					{
						name = "🐉 Kanagawa Dragon",
						colorscheme = "kanagawa-dragon",
					},
					{
						name = "🪷 Kanagawa Lotus",
						colorscheme = "kanagawa-lotus",
					},

					-- Nightfox Family
					{
						name = "🦊 Nightfox",
						colorscheme = "nightfox",
					},
					{
						name = "🌅 Dawnfox",
						colorscheme = "dawnfox",
					},
					{
						name = "☀️ Dayfox",
						colorscheme = "dayfox",
					},
					{
						name = "🌆 Duskfox",
						colorscheme = "duskfox",
					},
					{
						name = "❄️ Nordfox",
						colorscheme = "nordfox",
					},
					{
						name = "🌍 Terafox",
						colorscheme = "terafox",
					},
					{
						name = "⚫ Carbonfox",
						colorscheme = "carbonfox",
					},

					-- Professional Themes
					{
						name = "💻 VSCode Dark",
						colorscheme = "vscode",
					},
					{
						name = "⚫ OneDark",
						colorscheme = "onedark",
					},
					{
						name = "🎨 Material",
						colorscheme = "material",
					},
					{
						name = "🌑 Material Darker",
						colorscheme = "material-darker",
					},
					{
						name = "🌊 Material Oceanic",
						colorscheme = "material-oceanic",
					},
					{
						name = "🌃 Material Palenight",
						colorscheme = "material-palenight",
					},
					{
						name = "🌌 Material Deep Ocean",
						colorscheme = "material-deep-ocean",
					},

					-- GitHub Themes
					{
						name = "🐙 GitHub Dark",
						colorscheme = "github_dark",
					},
					{
						name = "🌫️ GitHub Dark Dimmed",
						colorscheme = "github_dark_dimmed",
					},
					{
						name = "⚡ GitHub Dark High Contrast",
						colorscheme = "github_dark_high_contrast",
					},
					{
						name = "☀️ GitHub Light",
						colorscheme = "github_light",
					},
					{
						name = "💡 GitHub Light High Contrast",
						colorscheme = "github_light_high_contrast",
					},

					-- OneDarkPro Variants
					{
						name = "🎯 OneDark Vivid",
						colorscheme = "onedark_vivid",
					},
					{
						name = "🖤 OneDark Dark",
						colorscheme = "onedark_dark",
					},

					-- Gruvbox Material (Default)
					{
						name = "🏔️ Gruvbox Material",
						colorscheme = "gruvbox-material",
					},

					-- Specialty Themes
					-- {
					-- 	name = "📜 Flexoki",
					-- 	colorscheme = "flexoki",
					-- },
					{
						name = "🎨 Ayu Dark",
						colorscheme = "ayu-dark",
					},
					{
						name = "🌅 Ayu Light",
						colorscheme = "ayu-light",
					},
					{
						name = "🌫️ Ayu Mirage",
						colorscheme = "ayu-mirage",
					},
					{
						name = "⚪ Yui",
						colorscheme = "yui",
					},
					{
						name = "🍞 Toast",
						colorscheme = "toast",
					},
				},
				livePreview = true, -- Apply theme while picking
			})
		end,
	},

	-- Other UI-related plugins
	{
		"nvim-tree/nvim-web-devicons",
		lazy = true,
	},

	-- ============================================================================
	-- BEAUTIFUL COLORSCHEME COLLECTION
	-- ============================================================================

	-- Modern and Popular Themes
	{
		"folke/tokyonight.nvim",
		lazy = true,
		priority = 900,
		config = function()
			require("tokyonight").setup({
				style = "night", -- storm, moon, night, day
				light_style = "day",
				transparent = false,
				terminal_colors = true,
				styles = {
					comments = { italic = true },
					keywords = { italic = true },
					functions = {},
					variables = {},
					sidebars = "dark",
					floats = "dark",
				},
				sidebars = { "qf", "help" },
				day_brightness = 0.3,
				hide_inactive_statusline = false,
				dim_inactive = false,
				lualine_bold = false,
			})
		end,
	},

	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = true,
		priority = 900,
		config = function()
			require("catppuccin").setup({
				flavour = "mocha", -- latte, frappe, macchiato, mocha
				background = {
					light = "latte",
					dark = "mocha",
				},
				transparent_background = false,
				show_end_of_buffer = false,
				term_colors = false,
				dim_inactive = {
					enabled = false,
					shade = "dark",
					percentage = 0.15,
				},
				no_italic = false,
				no_bold = false,
				no_underline = false,
				styles = {
					comments = { "italic" },
					conditionals = { "italic" },
					loops = {},
					functions = {},
					keywords = {},
					strings = {},
					variables = {},
					numbers = {},
					booleans = {},
					properties = {},
					types = {},
					operators = {},
				},
				color_overrides = {},
				custom_highlights = {},
				integrations = {
					cmp = true,
					gitsigns = true,
					nvimtree = true,
					treesitter = true,
					notify = false,
					mini = {
						enabled = true,
						indentscope_color = "",
					},
				},
			})
		end,
	},

	{
		"rose-pine/neovim",
		name = "rose-pine",
		lazy = true,
		priority = 900,
		config = function()
			require("rose-pine").setup({
				variant = "auto", -- auto, main, moon, or dawn
				dark_variant = "main", -- main, moon, or dawn
				dim_inactive_windows = false,
				extend_background_behind_borders = true,
				enable = {
					terminal = true,
					legacy_highlights = true,
					migrations = true,
				},
				styles = {
					bold = true,
					italic = true,
					transparency = false,
				},
				groups = {
					border = "muted",
					link = "iris",
					panel = "surface",
					error = "love",
					hint = "iris",
					info = "foam",
					note = "pine",
					todo = "rose",
					warn = "gold",
					git_add = "foam",
					git_change = "rose",
					git_delete = "love",
					git_dirty = "rose",
					git_ignore = "muted",
					git_merge = "iris",
					git_rename = "pine",
					git_stage = "iris",
					git_text = "rose",
					git_untracked = "subtle",
				},
				highlight_groups = {
					Comment = { fg = "foam" },
					VertSplit = { fg = "muted", bg = "muted" },
				},
			})
		end,
	},


	{
		"EdenEast/nightfox.nvim",
		lazy = true,
		priority = 900,
		config = function()
			require("nightfox").setup({
				options = {
					compile_path = vim.fn.stdpath("cache") .. "/nightfox",
					compile_file_suffix = "_compiled",
					transparent = false,
					terminal_colors = true,
					dim_inactive = false,
					module_default = true,
					colorblind = {
						enable = false,
						simulate_only = false,
						severity = {
							protan = 0,
							deutan = 0,
							tritan = 0,
						},
					},
					styles = {
						comments = "italic",
						conditionals = "NONE",
						constants = "NONE",
						functions = "NONE",
						keywords = "NONE",
						numbers = "NONE",
						operators = "NONE",
						strings = "NONE",
						types = "NONE",
						variables = "NONE",
					},
					inverse = {
						match_paren = false,
						visual = false,
						search = false,
					},
				},
				palettes = {},
				specs = {},
				groups = {},
			})
		end,
	},

	{
		"Mofiqul/vscode.nvim",
		lazy = true,
		priority = 900,
		config = function()
			require("vscode").setup({
				transparent = false,
				italic_comments = true,
				disable_nvimtree_bg = true,
				color_overrides = {
					vscLineNumber = "#FFFFFF",
				},
				group_overrides = {
					Cursor = { fg = "#FFFFFF", bg = "#000000", bold = true },
				},
			})
		end,
	},

	{
		"navarasu/onedark.nvim",
		lazy = true,
		priority = 900,
		config = function()
			require("onedark").setup({
				style = "dark", -- dark, darker, cool, deep, warm, warmer, light
				transparent = false,
				term_colors = true,
				ending_tildes = false,
				cmp_itemkind_reverse = false,
				toggle_style_key = nil,
				toggle_style_list = { "dark", "darker", "cool", "deep", "warm", "warmer", "light" },
				code_style = {
					comments = "italic",
					keywords = "none",
					functions = "none",
					strings = "none",
					variables = "none",
				},
				lualine = {
					transparent = false,
				},
				colors = {},
				highlights = {},
				diagnostics = {
					darker = true,
					undercurl = true,
					background = true,
				},
			})
		end,
	},

	{
		"marko-cerovac/material.nvim",
		lazy = true,
		priority = 900,
		config = function()
			require("material").setup({
				contrast = {
					terminal = false,
					sidebars = false,
					floating_windows = false,
					cursor_line = false,
					non_current_windows = false,
					filetypes = {},
				},
				styles = {
					comments = { italic = true },
					strings = { bold = true },
					keywords = { underline = true },
					functions = { bold = true, undercurl = true },
					variables = {},
					operators = {},
					types = {},
				},
				plugins = {
					"dap",
					"gitsigns",
					"indent-blankline",
					"lspsaga",
					"mini",
					"nvim-cmp",
					"nvim-navic",
					"nvim-tree",
					"nvim-web-devicons",
					"telescope",
					"trouble",
					"which-key",
				},
				disable = {
					colored_cursor = false,
					borders = false,
					background = false,
					term_colors = false,
					eob_lines = false,
				},
				high_visibility = {
					lighter = false,
					darker = false,
				},
				lualine_style = "default",
				async_loading = true,
				custom_colors = nil,
				custom_highlights = {},
			})
		end,
	},

	{
		"projekt0n/github-nvim-theme",
		lazy = true,
		priority = 900,
		config = function()
			require("github-theme").setup({
				options = {
					compile_path = vim.fn.stdpath("cache") .. "/github-theme",
					compile_file_suffix = "_compiled",
					hide_end_of_buffer = true,
					hide_nc_statusline = true,
					transparent = false,
					terminal_colors = true,
					dim_inactive = false,
					module_default = true,
					styles = {
						comments = "italic",
						functions = "NONE",
						keywords = "bold",
						variables = "NONE",
						conditionals = "NONE",
						constants = "NONE",
						numbers = "NONE",
						operators = "NONE",
						strings = "NONE",
						types = "NONE",
					},
					inverse = {
						match_paren = false,
						visual = false,
						search = false,
					},
					darken = {
						floats = false,
						sidebars = {
							enable = true,
							list = {},
						},
					},
				},
				palettes = {},
				specs = {},
				groups = {},
			})
		end,
	},

	{
		"olimorris/onedarkpro.nvim",
		lazy = true,
		priority = 900,
		config = function()
			require("onedarkpro").setup({
				colors = {},
				highlights = {},
				styles = {
					types = "NONE",
					methods = "NONE",
					numbers = "NONE",
					strings = "NONE",
					comments = "italic",
					keywords = "bold,italic",
					constants = "NONE",
					functions = "italic",
					operators = "NONE",
					variables = "NONE",
					parameters = "NONE",
					conditionals = "italic",
					virtual_text = "NONE",
				},
				plugins = {
					gitsigns = true,
					nvim_cmp = true,
					nvim_lsp = true,
					nvim_tree = true,
					telescope = true,
					treesitter = true,
					trouble = true,
					which_key = true,
				},
				options = {
					cursorline = false,
					transparency = false,
					terminal_colors = true,
					lualine_transparency = false,
					highlight_inactive_windows = false,
				},
			})
		end,
	},

	-- Existing themes (keeping for variety)
	-- {
	-- 	"kepano/flexoki",
	-- 	lazy = true,
	-- 	priority = 900,
	-- },

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

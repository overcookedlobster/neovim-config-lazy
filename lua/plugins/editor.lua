-- ~/.config/nvim/lua/plugins/editor.lua
-- Editor enhancement plugins

return {
	-- Telescope: Fuzzy finder
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-file-browser.nvim",
			"crispgm/telescope-heading.nvim",
		},
		branch = "0.1.x",
		config = function()
			require("telescope").setup({
				defaults = {
					file_ignore_patterns = { "node_modules" },
					layout_strategy = "vertical",
					layout_config = { height = 0.95, width = 0.95 },
				},
				pickers = {
					find_files = {
						theme = "dropdown",
						layout_config = {
							width = 0.9, -- 90% of screen width
						},
					},
				},
				extensions = {
					file_browser = {
						theme = "ivy",
						hijack_netrw = true,
					},
				},
			})

			-- Load extensions
			require("telescope").load_extension("file_browser")
			require("telescope").load_extension("heading")
		end,
	},

	-- Comment.nvim: Easy commenting
	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup({
				padding = true,
				sticky = true,
				ignore = nil,
				toggler = {
					line = "gll",
					block = "gcc",
				},
				opleader = {
					line = "gl",
					block = "gc",
				},
				extra = {
					above = "gcO",
					below = "gco",
					eol = "gcA",
				},
				mappings = {
					basic = true,
					extra = true,
					extended = false,
				},
			})
		end,
	},

	-- Surround: Handle surrounding delimiters
	{
		"kylechui/nvim-surround",
		version = "*",
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({
				-- Configuration here, or leave empty for defaults
			})
		end,
	},

	-- CSV.vim: CSV file handling
	{
		"chrisbra/csv.vim",
		ft = { "csv", "tsv" },
		config = function()
			-- Recognize .tsv files as CSV with tab delimiter
			vim.g.csv_extensions = { "csv", "tsv" }

			-- Set tab as the default delimiter for .tsv files
			vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
				pattern = "*.tsv",
				callback = function()
					vim.b.csv_delimiter = "\t"
				end,
			})

			-- Create a command for non-.tsv files
			vim.api.nvim_create_user_command("TSV", function()
				vim.bo.filetype = "csv"
				vim.b.csv_delimiter = "\t"
			end, {})

			-- Set up key mappings for CSV mode
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "csv",
				callback = function()
					local opts = { noremap = true, silent = true, buffer = true }
					vim.keymap.set("n", "<C-k>", "<Plug>CSV_KernelSort", opts)
					vim.keymap.set("n", "<C-j>", "<Plug>CSV_WhatColumn", opts)
					vim.keymap.set("n", "<C-h>", "<Plug>CSV_HiColumn", opts)
					vim.keymap.set("n", "<C-l>", "<Plug>CSV_NrColumns", opts)
				end,
			})
		end,
	},

	-- Ranger integration
	{
		"kevinhwang91/rnvimr",
		config = function()
			-- Make Ranger replace Netrw and be the file explorer
			vim.g.rnvimr_enable_ex = 1

			-- Make Ranger to be hidden after picking a file
			vim.g.rnvimr_enable_picker = 1

			-- Replace `$EDITOR` candidate with this command to open the selected file
			vim.g.rnvimr_edit_cmd = "drop"

			-- Disable a border for floating window
			vim.g.rnvimr_draw_border = 0

			-- Hide the files included in gitignore
			vim.g.rnvimr_hide_gitignore = 1

			-- Make Neovim wipe the buffers corresponding to the files deleted by Ranger
			vim.g.rnvimr_enable_bw = 1

			-- Add a shadow window, value is equal to 100 will disable shadow
			vim.g.rnvimr_shadow_winblend = 70
		end,
	},

	-- Rooter: Change working directory to project root
	{
		"airblade/vim-rooter",
		config = function()
			vim.g.rooter_patterns = { ".git", "Makefile", "package.json", ".root", "build/env.sh" }
			vim.g.rooter_manual_only = 1

			-- Keymapping
			vim.keymap.set(
				"",
				"<Leader>tr",
				"<Cmd>Rooter<CR>",
				{ noremap = true, silent = true, desc = "Change to project root" }
			)
		end,
	},

	-- Toggle Tasks: Project task management
	{
		"jedrzejboczar/toggletasks.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"akinsho/toggleterm.nvim",
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			require("toggletasks").setup({})
			require("telescope").load_extension("toggletasks")

			-- Function to spawn task by name
			local function spawn_by_name(name)
				local tasks = require("toggletasks.discovery").tasks():filter(function(task)
					return task.config.name == name
				end)

				if #tasks > 0 then
					tasks[1]:spawn()
					tasks[1].term:open()
				else
					print("No matching task with name", name)
				end
			end

			-- Function to spawn tasks with tag
			local function spawn_tasks_with_tag(tag)
				local tasks = require("toggletasks.discovery").tasks():filter(function(task)
					return vim.tbl_contains(task.config.tags or {}, tag)
				end)

				if #tasks > 0 then
					for _, task in pairs(tasks) do
						task:spawn()
						task.term:open()
					end
				else
					print("No matching tasks with tag", tag)
				end
			end

			-- Keymappings
			vim.keymap.set(
				"n",
				"<space>ts",
				require("telescope").extensions.toggletasks.spawn,
				{ desc = "Tasks: Open task picker" }
			)

			-- Run all tasks with the #serve tag
			vim.keymap.set("n", "<Leader>ts", function()
				vim.cmd("Rooter") -- switch to project root directory
				spawn_tasks_with_tag("serve")
				vim.cmd("wincmd k") -- Return cursor to original window
				vim.cmd("stopinsert") -- Return to normal mode
			end, { desc = "Tasks: Run serve tasks" })

			-- Run all tasks with the #run tag
			vim.keymap.set("n", "<Leader>tp", function()
				vim.cmd("Rooter") -- switch to project root directory
				spawn_tasks_with_tag("run")
				vim.cmd("wincmd k") -- Return cursor to original window
				vim.cmd("stopinsert") -- Return to normal mode
			end, { desc = "Tasks: Run run tasks" })

			-- Run all tasks with the #build tag
			vim.keymap.set("n", "<Leader>to", function()
				vim.cmd("Rooter") -- switch to project root directory
				spawn_tasks_with_tag("build")
				vim.cmd("wincmd k") -- Return cursor to original window
				vim.cmd("stopinsert") -- Return to normal mode
			end, { desc = "Tasks: Run build tasks" })

			-- Run all tasks with the #view tag
			vim.keymap.set("n", "<Leader>ti", function()
				vim.cmd("Rooter") -- switch to project root directory
				spawn_tasks_with_tag("view")
				vim.cmd("wincmd k") -- Return cursor to original window
				vim.cmd("stopinsert") -- Return to normal mode
			end, { desc = "Tasks: Run view tasks" })
		end,
	},

	-- ToggleTerm: Better terminal integration
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				-- shade_terminals = false,
				open_mapping = [[<c-\>]], -- or { [[<c-\>]], [[<c-¥>]] } if you also use a Japanese keyboard.
			})

			-- Keymappings
			vim.keymap.set(
				"n",
				"<Leader>tt",
				"<Cmd>ToggleTerm<CR>",
				{ noremap = true, silent = true, desc = "Toggle terminal" }
			)
			vim.keymap.set(
				"n",
				"<Leader>t1",
				"<Cmd>1ToggleTerm<CR>",
				{ noremap = true, silent = true, desc = "Toggle terminal 1" }
			)
			vim.keymap.set(
				"n",
				"<Leader>t2",
				"<Cmd>2ToggleTerm<CR>",
				{ noremap = true, silent = true, desc = "Toggle terminal 2" }
			)
		end,
	},

	-- Easy Align: Alignment tool
	{
		"junegunn/vim-easy-align",
		config = function()
			-- Start interactive EasyAlign in visual mode (e.g. vipga)
			vim.keymap.set("x", "ga", "<Plug>(EasyAlign)", { desc = "EasyAlign in visual mode" })

			-- Start interactive EasyAlign for a motion/text object (e.g. gaip)
			vim.keymap.set("n", "ga", "<Plug>(EasyAlign)", { desc = "EasyAlign for motion" })
		end,
	},


	-- Indent guides: Show indentation levels with lines
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {
			indent = {
				char = "│",
				tab_char = "│",
			},
			scope = {
				enabled = true,
				show_start = true,
				show_end = true,
				injected_languages = false,
				highlight = { "Function", "Label" },
				priority = 500,
			},
			exclude = {
				filetypes = {
					"help",
					"alpha",
					"dashboard",
					"neo-tree",
					"Trouble",
					"trouble",
					"lazy",
					"mason",
					"notify",
					"toggleterm",
					"lazyterm",
				},
			},
		},
		config = function(_, opts)
			require("ibl").setup(opts)
		end,
	},

	-- Rainbow brackets: Colorize matching brackets
	{
		"HiPhish/rainbow-delimiters.nvim",
		config = function()
			local rainbow_delimiters = require("rainbow-delimiters")

			vim.g.rainbow_delimiters = {
				strategy = {
					[""] = rainbow_delimiters.strategy["global"],
					vim = rainbow_delimiters.strategy["local"],
				},
				query = {
					[""] = "rainbow-delimiters",
					lua = "rainbow-blocks",
				},
				priority = {
					[""] = 110,
					lua = 210,
				},
				highlight = {
					"RainbowDelimiterRed",
					"RainbowDelimiterYellow",
					"RainbowDelimiterBlue",
					"RainbowDelimiterOrange",
					"RainbowDelimiterGreen",
					"RainbowDelimiterViolet",
					"RainbowDelimiterCyan",
				},
			}
		end,
	},


	-- Matchup: Enhanced % matching
	{
		"andymass/vim-matchup",
		event = { "BufReadPost" },
		config = function()
			vim.g.matchup_matchparen_offscreen = { method = "popup" }
			vim.g.matchup_matchparen_deferred = 1
			vim.g.matchup_matchparen_hi_surround_always = 1
		end,
	},

	-- Additional useful editor plugins
	{
		"tpope/vim-fugitive", -- Git integration
	},

	{
		"tpope/vim-surround", -- Surround text objects
	},

	{
		"mg979/vim-visual-multi", -- Multiple cursors
	},
}

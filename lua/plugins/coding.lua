-- ~/.config/nvim/lua/plugins/coding.lua
-- Coding-related plugins

return {
	-- Completion: nvim-cmp
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp", -- LSP source
			"hrsh7th/cmp-buffer", -- Buffer source
			"hrsh7th/cmp-path", -- Path source
			"hrsh7th/cmp-cmdline", -- Command line source
			"hrsh7th/cmp-omni", -- Omni completion source
			"saadparwaiz1/cmp_luasnip", -- Snippet source
			"L3MON4D3/LuaSnip", -- Snippet engine
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<C-k>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<C-j>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "omni" },
					{ name = "buffer" },
					{ name = "path" },
				}),
				completion = {
					autocomplete = false, -- Disable automatic popup globally
				},
				experimental = {
					ghost_text = true,
				},
			})

			-- Use buffer source for `/` and `?`
			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			-- Use cmdline & path source for ':'
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
			})

			-- Set up a keymap to manually trigger completion
			vim.keymap.set("i", "<C-Space>", function()
				if cmp.visible() then
					cmp.close()
				else
					cmp.complete()
				end
			end, { silent = true, desc = "Completion: Toggle completion menu" })

			-- Special configuration for SystemVerilog files
			cmp.setup.filetype("systemverilog", {
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "omni" },
					{ name = "buffer" },
					{ name = "path" },
				}),
				completion = {
					autocomplete = { "TextChanged" }, -- Specify events for auto-completion
				},
			})

			-- Special configuration for LaTeX files
			cmp.setup.filetype("tex", {
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "omni" },
					{ name = "vimtex" },
					{ name = "buffer" },
					{ name = "path" },
				}),
				completion = {
					autocomplete = { "TextChanged" }, -- Enable automatic popup for tex files
				},
			})
		end,
	},

	-- Snippets: LuaSnip
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		build = "make install_jsregexp",
		dependencies = {
			"rafamadriz/friendly-snippets", -- Collection of snippets
		},
		config = function()
			local ls = require("luasnip")

			ls.config.set_config({
				history = false, -- Don't store snippet history for less overhead
				enable_autosnippets = true, -- Allow autotrigger snippets
				store_selection_keys = "<Tab>", -- Use Tab for visual selection (original functionality)
				region_check_events = "InsertEnter", -- Event on which to check for exiting a snippet's region
				delete_check_events = "InsertLeave",
			})

			-- Load friendly-snippets
			require("luasnip.loaders.from_vscode").lazy_load()

			-- Load custom snippets
			require("luasnip.loaders.from_lua").lazy_load({ paths = vim.fn.stdpath("config") .. "/snippets/" })

			-- Keymaps for snippet navigation using Lua (more reliable)
			local luasnip = require("luasnip")

			-- Jump forward with jk (works with snippets and brackets/quotes)
			vim.keymap.set({ "i", "s" }, "jk", function()
				if luasnip.jumpable(1) then
					luasnip.jump(1)
				else
					-- Check if we're inside brackets/quotes and can jump out
					local line = vim.api.nvim_get_current_line()
					local col = vim.api.nvim_win_get_cursor(0)[2]
					local char_after = line:sub(col + 1, col + 1)

					-- If next character is a closing bracket/quote, jump over it
					if char_after:match("[%)%]%}\"'`]") then
						vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Right>", true, false, true), "n", false)
					else
						-- Otherwise just insert "jk"
						vim.api.nvim_feedkeys("jk", "n", false)
					end
				end
			end, { silent = true, desc = "LuaSnip: Jump forward in snippets or exit brackets/quotes" })

			-- Jump backward with jh (works with snippets and brackets/quotes)
			vim.keymap.set({ "i", "s" }, "jh", function()
				if luasnip.jumpable(-1) then
					luasnip.jump(-1)
				else
					-- Check if we're outside brackets/quotes and can jump back in
					local line = vim.api.nvim_get_current_line()
					local col = vim.api.nvim_win_get_cursor(0)[2]
					local char_before = line:sub(col, col)
					local char_before_that = line:sub(col - 1, col - 1)

					-- If current character is a closing bracket/quote, jump back inside
					if char_before:match("[%)%]%}\"'`]") then
						vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Left>", true, false, true), "n", false)
					-- If we're right after a pair of brackets/quotes, jump inside
					elseif char_before_that:match("[%(%[%{\"'`]") and char_before:match("[%)%]%}\"'`]") then
						vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Left>", true, false, true), "n", false)
					else
						-- Otherwise just insert "jh"
						vim.api.nvim_feedkeys("jh", "n", false)
					end
				end
			end, { silent = true, desc = "LuaSnip: Jump backward in snippets or enter brackets/quotes" })

			-- Cycle through choice nodes with Control-F
			vim.keymap.set({ "i", "s" }, "<C-f>", function()
				if luasnip.choice_active() then
					luasnip.change_choice(1)
				else
					-- If no choice active, scroll docs (cmp behavior)
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-f>", true, false, true), "n", false)
				end
			end, { silent = true, desc = "LuaSnip: Next choice or scroll docs" })

			-- Command to refresh snippets
			vim.keymap.set(
				"",
				"<Leader>U",
				'<Cmd>lua require("luasnip.loaders.from_lua").lazy_load({paths = "'
					.. vim.fn.stdpath("config")
					.. '/snippets/"})<CR><Cmd>echo "Snippets refreshed!"<CR>',
				{ desc = "Refresh snippets" }
			)
		end,
	},

	-- Syntax support for SystemVerilog
	{
		"vhda/verilog_systemverilog.vim",
		ft = { "verilog", "systemverilog" },
		config = function()
			vim.g.verilog_syntax_fold_lst = "block,function,task,specify,module,class,covergroup"
			vim.g.verilog_disable_indent_lst = "eos"
			vim.g.verilog_indent_modules = 1
			vim.g.verilog_indent_width = 2
		end,
	},

	-- In lua/plugins/coding.lua
	{
		"luk400/vim-jukit",
		lazy = true, -- Don't lazy load this plugin
		priority = 1000, -- Highest priority to load very early
		init = function() -- Execute before plugin loads
			-- Force the correct syntax file path
			vim.g.jukit_text_syntax_file = vim.fn.expand("$VIMRUNTIME/syntax/markdown.vim")

			-- Check if file exists and use fallback if needed
			if vim.fn.filereadable(vim.g.jukit_text_syntax_file) ~= 1 then
				vim.g.jukit_text_syntax_file = vim.fn.expand("$VIMRUNTIME/syntax/text.vim")
			end

			-- Other vim-jukit settings
			vim.g.python3_host_prog = "/usr/bin/python3"
			vim.g.jukit_shell_cmd = "ipython3"
			vim.g.jukit_terminal = "nvimterm"
			vim.g.jukit_auto_output_hist = 1
			vim.g.jukit_use_tcomment = 1
			vim.g.jukit_enable_textcell_bg = 0 -- Try disabling this feature

			-- Print path for debugging
			-- vim.api.nvim_create_autocmd("VimEnter", {
			--   callback = function()
			--     vim.notify("vim-jukit using syntax file: " .. vim.g.jukit_text_syntax_file)
			--   end,
			--   once = true
			-- })
		end,
	},
	-- Clipboard image saver
	{
		"postfen/clipboard-image.nvim",
		config = function()
			require("clipboard-image").setup({
				default = {
					img_dir = vim.fn.expand("~/Pictures/clipboard_images"),
					img_dir_txt = vim.fn.expand("~/Pictures/clipboard_images"),
					img_name = function()
						return "screenshot_" .. os.date("%Y%m%d%H%M%S") .. "_" .. math.random(1000)
					end,
					affix = "![clipboard_image](%s)",
				},
			})
		end,
	},

	-- Live preview for Markdown, HTML, AsciiDoc, SVG
	{
		"brianhuster/live-preview.nvim",
		ft = { "markdown", "html", "asciidoc", "svg" },
		cmd = { "LivePreview", "LivePreviewStop", "LivePreviewToggle" },
		config = function()
			require("livepreview").setup({
				-- Port for the preview server
				port = 5500,
				-- Auto-open browser when starting preview
				browser = "default",
				-- Dynamic title based on file name
				dynamic_title = true,
				-- File types to enable live preview
				file_types = { "markdown", "html", "asciidoc", "svg" },
			})
		end,
	},

	-- Markdown support
	{
		"preservim/vim-markdown",
		dependencies = { "godlygeek/tabular" },
		ft = { "markdown" },
		init = function()
			vim.g.vim_markdown_folding_disabled = 1
			vim.g.vim_markdown_conceal = 2
			vim.g.vim_markdown_conceal_code_blocks = 0
			vim.g.vim_markdown_math = 1
			vim.g.vim_markdown_frontmatter = 1
			vim.g.vim_markdown_strikethrough = 1
		end,
	},

	-- Additional coding tools
	{
		"jakemason/ouroboros", -- File navigation
	},

	-- FZF
	{
		"junegunn/fzf",
		build = function()
			vim.fn["fzf#install"]()
		end,
	},

	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
	-- Avante
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		version = false, -- Never set this value to "*"! Never!
		debug = true,
		opts = {
			-- add any opts here
			-- for example
			instructions_file = "avante.md",
			provider = "igpt", -- Changed from copilot to igpt since copilot is disabled
			auto_suggestions_provider = "igpt", -- Changed from copilot to igpt
			-- RAG Service Configuration
			rag_service = {
				enabled = false, -- Enable RAG service
				host_mount = os.getenv("HOME"), -- Mount home directory for file access
				-- host_mount = vim.fn.expand("~/RAG"), -- Mount RAG directory for file access
				runner = "docker", -- Use Docker to run RAG service
				-- LLM configuration for RAG service (for generating responses based on retrieved context)
				llm = {
					__inherited_from = "openai",
					endpoint = "http://localhost:8001/v1", -- Your igpt endpoint
					api_key = "IGPT_API_KEY", -- Environment variable name for API key
					model = "gpt-4o", -- Your igpt model name
					extra = {
						temperature = 0,
						max_tokens = 4096,
						reasoning_effort = "high",
					},
				},
				-- Embedding configuration for RAG service (for document indexing and similarity search)
				embed = {
					__inherited_from = "openai",
					-- Use localhost since we're using --network=host
					endpoint = "http://localhost:8001/v1", -- Your igpt endpoint accessible from Docker
					api_key = "IGPT_API_KEY", -- Same API key
					model = "text-embedding-3-large", -- Embedding model (adjust if your endpoint uses different model names)
					-- Option 2: Uncomment below to use OpenAI for embeddings instead
					-- endpoint = "https://api.openai.com/v1",
					-- api_key = "OPENAI_API_KEY",
					-- model = "text-embedding-3-large",
					extra = {
						-- Add any extra parameters for embedding requests
					},
				},
				docker_extra_args = "--network=host", -- Additional Docker arguments if needed
			},
			providers = {
				-- Explicitly disable copilot provider to prevent SSL errors
				copilot = {
					enabled = false, -- Disable copilot provider
					list_models = function()
						return {}
					end, -- Return empty model list
					parse_response = function()
						return ""
					end, -- Dummy response parser
					parse_stream_data = function()
						return ""
					end, -- Dummy stream parser
				},
				claude = {
					model = "claude-4-sonnet",
					-- thinking = {
					--   type = "enabled";
					--   budget_tokens = 2048;
					-- }
				},
				openai = {
					endpoint = "https://api.openai.com/v1",
					model = "gpt-4o", -- your desired model (or use gpt-4o, etc.)
					timeout = 30000, -- Timeout in milliseconds, increase this for reasoning models
					extra_request_body = {
						temperature = 0,
						max_completion_tokens = 8192, -- Increase this to include reasoning tokens (for reasoning models)
						reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
					},
				},
				xai = {
					__inherited_from = "openai",
					endpoint = "https://api.x.ai/v1",
					model = "grok-4",
					model_names = { "grok-4", "grok-3", "grok-3-mini" },
					api_key_name = "XAI_API_KEY",
					timeout = 50000,
					cache = true,
					extra_request_body = {
						temperature = 0,
						max_completion_tokens = 16384,
						reasoning_effort = "high",
					},
				},
				gemini_beta = {
					__inherited_from = "gemini",
					-- endpoint = "https://generativelanguage.googleapis.com/v1beta/openai",
					model = "gemini-2.5-pro-exp-03-25",
					api_key_name = "GEMINI_API_KEY",
					-- timeout = 50000,
					-- extra_request_body = {
					--   reasoning_effort = "high",
					-- },
				},
				igpt = {
					__inherited_from = "openai",
					endpoint = "http://localhost:8001/v1",
					model = "claude-sonnet-4",
					model_names = { "claude-sonnet-4", "gpt-4o", "gpt-35-turbo" },
					-- model = "gpt-4o",
					api_key_name = "IGPT_API_KEY",
					timeout = 50000,
					extra_request_body = {
						temperature = 0,
						max_completion_tokens = 16384,
						-- max_completion_tokens = 4096,
						reasoning_effort = "high",
					},
					-- disable_tools = true,
				},
				deepseek = {
					__inherited_from = "openai",
					endpoint = "https://api.deepseek.com",
					model = "deepseek-coder",
					model_names = { "deepseek-coder", "deepseek-reasoner" },
					api_key_name = "DEEPSEEK_API_KEY",
					cache = true,
					timeout = 50000,
					extra_request_body = {
						temperature = 0.5,
						max_completion_tokens = 10000,
						reasoning_effort = "medium",
					},
				},
			},
			-- MCPHub integration
			system_prompt = function()
				local hub = require("mcphub").get_hub_instance()
				return hub:get_active_servers_prompt()
			end,
			custom_tools = function()
				return {
					require("mcphub.extensions.avante").mcp_tool(),
				}
			end,
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
			-- GitHub Copilot - DISABLED due to company restrictions
			-- {
			-- 	"zbirenbaum/copilot.lua",
			-- 	cmd = "Copilot",
			-- 	event = "InsertEnter",
			-- 	config = function()
			-- 		require("copilot").setup({
			-- 			panel = {
			-- 				enabled = true,
			-- 				auto_refresh = true,
			-- 				keymap = {
			-- 					jump_prev = "[[",
			-- 					jump_next = "]]",
			-- 					accept = "<CR>",
			-- 					refresh = "gr",
			-- 					open = "<M-CR>",
			-- 				},
			-- 				layout = {
			-- 					position = "bottom", -- | top | left | right
			-- 					ratio = 0.4,
			-- 				},
			-- 			},
			-- 			suggestion = {
			-- 				enabled = false,
			-- 				auto_trigger = true,
			-- 				debounce = 75,
			-- 				keymap = {
			-- 					accept = "<M-l>",
			-- 					accept_word = "<M-w>",
			-- 					accept_line = "<M-j>",
			-- 					next = "<M-]>",
			-- 					prev = "<M-[>",
			-- 					dismiss = "<C-]>",
			-- 				},
			-- 			},
			-- 			filetypes = {
			-- 				markdown = true,
			-- 				help = false,
			-- 				gitcommit = false,
			-- 				gitrebase = false,
			-- 				["."] = false,
			-- 			},
			-- 			copilot_node_command = "node", -- Node.js version must be > 18
			-- 			server_opts_overrides = {
			-- 				trace = "verbose",
			-- 				settings = {
			-- 					advanced = {
			-- 						listCount = 10, -- #completions for panel
			-- 						inlineSuggestCount = 3, -- #completions for getCompletions
			-- 					},
			-- 				},
			-- 			},
			-- 		})
			-- 	end,
			-- },
			{
				-- support for image pasting
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy", -- next can try "InsertEnter" or "BufReadPost"""
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
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
			{
				"ravitemer/mcphub.nvim",
				dependencies = {
					"nvim-lua/plenary.nvim", -- Required for Job and HTTP requests
				},
				build = "npm install -g mcp-hub@latest", -- Installs required mcp-hub npm module
				event = "VeryLazy", -- Ensure it loads before avante.nvim
				config = function()
					require("mcphub").setup({
						-- Required options
						port = 3000, -- Port for MCP Hub server
						config = vim.fn.expand("~/mcpservers.json"), -- Absolute path to config file

						-- -- Optional options
						-- on_ready = function(hub)
						--   -- Called when hub is ready
						--   vim.notify("MCPHub is ready!", vim.log.levels.INFO)
						-- end,
						-- on_error = function(err)
						--   -- Called on errors
						--   vim.notify("MCPHub error: " .. err, vim.log.levels.ERROR)
						-- end,
						-- log = {
						--   level = vim.log.levels.WARN,
						--   to_file = true,
						--   file_path = vim.fn.expand("~/mcphub.log"),
						--   prefix = "MCPHub"
						-- },
					})
				end,
			},
		},
	},
	{
		"NickvanDyke/opencode.nvim",
		dependencies = {
			--Recommended for better prompt input, and required to use opencode.nvim's embedded terminal - otherwise optional
			{ "folke/snacks.nvim", opts = { input = { enabled = true } } },
		},
		---@type opencode.Opts
		opts = {
			-- Your configuration, if any - see lua/opencode/config.lua
		},
		keys = {
			-- Recommended keymaps
			{
				"<leader>oA",
				function()
					require("opencode").ask()
				end,
				desc = "Ask opencode",
			},
			{
				"<leader>oa",
				function()
					require("opencode").ask("@cursor: ")
				end,
				desc = "Ask opencode about this",
				mode = "n",
			},
			{
				"<leader>oa",
				function()
					require("opencode").ask("@selection: ")
				end,
				desc = "Ask opencode about selection",
				mode = "v",
			},
			{
				"<leader>ot",
				function()
					require("opencode").toggle()
				end,
				desc = "Toggle embedded opencode",
			},
			{
				"<leader>on",
				function()
					require("opencode").command("session_new")
				end,
				desc = "New session",
			},
			{
				"<leader>oy",
				function()
					require("opencode").command("messages_copy")
				end,
				desc = "Copy last message",
			},
			{
				"<S-C-u>",
				function()
					require("opencode").command("messages_half_page_up")
				end,
				desc = "Scroll messages up",
			},
			{
				"<S-C-d>",
				function()
					require("opencode").command("messages_half_page_down")
				end,
				desc = "Scroll messages down",
			},
			{
				"<leader>op",
				function()
					require("opencode").select_prompt()
				end,
				desc = "Select prompt",
				mode = { "n", "v" },
			},
			-- Example: keymap for custom prompt
			{
				"<leader>oe",
				function()
					require("opencode").prompt("Explain @cursor and its context")
				end,
				desc = "Explain code near cursor",
			},
		},
	},

	-- LeetCode plugin
	{
		"kawre/leetcode.nvim",
		build = ":TSUpdate html", -- Ensure HTML treesitter is installed
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-telescope/telescope.nvim", -- for picker
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {
			-- Use argument-based startup
			arg = "leetcode.nvim",

			-- Default language
			lang = "python",

			-- Storage configuration
			storage = {
				home = vim.fn.stdpath("data") .. "/leetcode",
				cache = vim.fn.stdpath("cache") .. "/leetcode",
			},

			-- Console configuration
			console = {
				open_on_runcode = true,
				dir = "row",
				size = {
					width = "90%",
					height = "75%",
				},
				result = {
					size = "60%",
				},
				testcase = {
					virt_text = true,
					size = "40%",
				},
			},

			-- Description panel configuration
			description = {
				position = "left",
				width = "40%",
				show_stats = true,
			},

			-- Use telescope as picker
			picker = {
				provider = "telescope",
			},

			-- Code injection for different languages
			injector = {
				["cpp"] = {
					imports = function()
						return { "#include <bits/stdc++.h>", "using namespace std;" }
					end,
				},
				["python3"] = {
					imports = function(default_imports)
						vim.list_extend(default_imports, { "from typing import *" })
						return default_imports
					end,
				},
				["c"] = {
					imports = function()
						return { "#include <stdio.h>", "#include <stdlib.h>", "#include <string.h>" }
					end,
				},
			},

			-- Editor settings
			editor = {
				reset_previous_code = true,
				fold_imports = true,
			},

			-- Enable logging for debugging
			logging = true,

			-- Cache settings
			cache = {
				update_interval = 60 * 60 * 24 * 7, -- 7 days
			},

			-- Authentication domain (use leetcode.com by default)
			domain = "com", -- or "cn" for leetcode.cn

			-- Hooks for better integration
			hooks = {
				["enter"] = {
					function()
						-- Ensure LeetCode commands are available
						local leetcode = require("leetcode")
						if leetcode.setup_cmds then
							leetcode.setup_cmds()
						end
					end,
				},
			},
		},
		cmd = "Leet", -- Lazy load on command
		config = function(_, opts)
			require("leetcode").setup(opts)

			-- Ensure commands are set up after plugin loads
			vim.defer_fn(function()
				local ok, leetcode = pcall(require, "leetcode")
				if ok and leetcode.setup_cmds then
					leetcode.setup_cmds()
				end
			end, 100)
		end,
	},
}

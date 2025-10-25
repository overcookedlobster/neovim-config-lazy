-- ~/.config/nvim/lua/plugins/lsp.lua
-- LSP-related plugins

return {
	-- LSP Configuration
	{
		"williamboman/mason.nvim", -- Portable package manager for Neovim
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp", -- LSP completion
			"WhoIsSethDaniel/mason-tool-installer.nvim", -- Auto-install tools
		},
		config = function()
			-- Set up Mason
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})
			-- Set up mason-tool-installer to automatically install tools
			require("mason-tool-installer").setup({
				ensure_installed = {
					-- Formatters
					"stylua", -- Lua formatter
					"prettier", -- JavaScript/TypeScript/JSON formatter
					"prettierd", -- Faster prettier
					-- "clang-format", -- C/C++ formatter
					"lua-language-server",
					-- Linters
					"flake8", -- Python linter (install via Mason)
					"eslint_d", -- JavaScript/TypeScript linter (eslint daemon)
					"luacheck", -- Lua linter
					"svls", -- Verilog and SV

					-- Note: verilator needs to be installed separately as it's not in Mason
					-- Install verilator with: sudo apt-get install verilator (Ubuntu/Debian)
					-- or: brew install verilator (macOS)
				},
				auto_update = false,
				run_on_start = true,
			})

			-- LSP handlers configuration
			local handlers = {
				["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" }),
				["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" }),
			}

			-- Set diagnostic signs using the modern API
			local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.api.nvim_set_hl(0, hl, { fg = "#ffffff" }) -- Set default colors if needed
			end

			-- Configure diagnostic signs in the diagnostic config
			vim.diagnostic.config({
				virtual_text = false,
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = signs.Error,
						[vim.diagnostic.severity.WARN] = signs.Warn,
						[vim.diagnostic.severity.HINT] = signs.Hint,
						[vim.diagnostic.severity.INFO] = signs.Info,
					},
				},
				underline = true,
				update_in_insert = true, -- Enable updates while typing
				severity_sort = true,
				float = {
					border = "rounded",
					source = "if_many",
					header = "",
					prefix = "",
				},
			})

			-- Global LSP on_attach function
			local on_attach = function(client, bufnr)
				-- Enable completion triggered by <c-x><c-o>
				vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

				-- Buffer local mappings
				local opts = { noremap = true, silent = true, buffer = bufnr }
				vim.keymap.set(
					"n",
					"gD",
					vim.lsp.buf.declaration,
					vim.tbl_extend("force", opts, { desc = "LSP: Go to declaration" })
				)
				vim.keymap.set(
					"n",
					"gd",
					vim.lsp.buf.definition,
					vim.tbl_extend("force", opts, { desc = "LSP: Go to definition" })
				)
				vim.keymap.set(
					"n",
					"K",
					vim.lsp.buf.hover,
					vim.tbl_extend("force", opts, { desc = "LSP: Hover information" })
				)
				vim.keymap.set(
					"n",
					"gi",
					vim.lsp.buf.implementation,
					vim.tbl_extend("force", opts, { desc = "LSP: Go to implementation" })
				)
				vim.keymap.set(
					"n",
					"<C-k>",
					vim.lsp.buf.signature_help,
					vim.tbl_extend("force", opts, { desc = "LSP: Signature help" })
				)
				vim.keymap.set(
					"n",
					"<space>D",
					vim.lsp.buf.type_definition,
					vim.tbl_extend("force", opts, { desc = "LSP: Type definition" })
				)
				vim.keymap.set(
					"n",
					"<space>rn",
					vim.lsp.buf.rename,
					vim.tbl_extend("force", opts, { desc = "LSP: Rename" })
				)
				vim.keymap.set(
					{ "n", "v" },
					"<space>ca",
					vim.lsp.buf.code_action,
					vim.tbl_extend("force", opts, { desc = "LSP: Code action" })
				)
				vim.keymap.set(
					"n",
					"gr",
					vim.lsp.buf.references,
					vim.tbl_extend("force", opts, { desc = "LSP: References" })
				)
				vim.keymap.set("n", "<space>f", function()
					vim.lsp.buf.format({ async = true })
				end, vim.tbl_extend("force", opts, { desc = "LSP: Format buffer" }))

				-- Enable inlay hints if supported (with proper version checking)
				if client.server_capabilities.inlayHintProvider then
					-- Check Neovim version for proper API support
					if vim.fn.has("nvim-0.10.0") == 1 then
						-- Safe call with pcall to prevent errors
						pcall(function()
							vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
						end)
					end
				end

				-- Set up document highlight
				if client.server_capabilities.documentHighlightProvider then
					local group = vim.api.nvim_create_augroup("LSPDocumentHighlight", { clear = false })
					vim.api.nvim_clear_autocmds({ buffer = bufnr, group = group })
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = bufnr,
						group = group,
						callback = vim.lsp.buf.document_highlight,
					})
					vim.api.nvim_create_autocmd("CursorMoved", {
						buffer = bufnr,
						group = group,
						callback = vim.lsp.buf.clear_references,
					})
				end
			end

			-- Default capabilities
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Configure LSP servers using vim.lsp.config (Neovim 0.11+)
			-- This replaces the deprecated require('lspconfig') approach
			-- Global configuration for all servers
			vim.lsp.config("*", {
				capabilities = capabilities,
				handlers = handlers,
				root_markers = { ".git" },
			})

			-- Lua Language Server
			vim.lsp.config("lua_ls", {
				cmd = { "lua-language-server" },
				filetypes = { "lua" },
				root_markers = { { ".luarc.json", ".luarc.jsonc" }, ".git" },
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" }, -- Recognize 'vim' global
						},
						workspace = {
							library = {
								vim.env.VIMRUNTIME,
								"${3rd}/luv/library",
								"${3rd}/busted/library",
							},
							checkThirdParty = false,
						},
						telemetry = {
							enable = false,
						},
					},
				},
			})

			-- Python Language Server
			vim.lsp.config("pyright", {
				cmd = { "pyright-langserver", "--stdio" },
				filetypes = { "python" },
				root_markers = {
					"pyproject.toml",
					"setup.py",
					"setup.cfg",
					"requirements.txt",
					"Pipfile",
					"pyrightconfig.json",
					".git",
				},
				settings = {
					python = {
						analysis = {
							typeCheckingMode = "basic",
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
						},
					},
				},
			})

			-- C/C++ Language Server
			vim.lsp.config("clangd", {
				cmd = {
					"clangd",
					"--background-index",
					"--suggest-missing-includes",
					"--clang-tidy",
					"--header-insertion=iwyu",
				},
				filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
				root_markers = {
					".clangd",
					".clang-tidy",
					".clang-format",
					"compile_commands.json",
					"compile_flags.txt",
					"configure.ac",
					".git",
				},
			})

			-- SystemVerilog Language Server
			vim.lsp.config("svls", {
				cmd = { "svls" },
				filetypes = { "systemverilog", "verilog" },
				root_markers = { ".svlint.toml", "svls.toml", ".svls.toml", ".git" },
				settings = {},
			})

						-- Xilinx Language Server
						vim.lsp.config("xilinx", {
						  cmd = { "xilinx-language-server" },
						  filetypes = { "xdc", "xsct" },
						  root_markers = { ".git" },
						  init_options = {
						    method = "builtin",
						  },
						})
				
			-- Enable LSP servers
			vim.lsp.enable("lua_ls")
			vim.lsp.enable("pyright")
			vim.lsp.enable("clangd")
			vim.lsp.enable("svls")
					vim.lsp.enable("xilinx")

			-- Set up LspAttach autocmd for buffer-local configurations
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					local client = vim.lsp.get_client_by_id(ev.data.client_id)
					local bufnr = ev.buf

					-- Call the on_attach function
					on_attach(client, bufnr)

					-- Special handling for SystemVerilog
					if client and client.name == "svls" then
						print("SystemVerilog LSP attached with enhanced context support")
					end
				end,
			})

			-- Add command to restart LSP servers
			vim.api.nvim_create_user_command("LspRestart", function()
				vim.lsp.stop_client(vim.lsp.get_clients())
				vim.defer_fn(function()
					-- Re-enable all servers
					vim.lsp.enable("lua_ls")
					vim.lsp.enable("pyright")
					vim.lsp.enable("clangd")
					vim.lsp.enable("svls")
				end, 1000)
			end, { desc = "Restart LSP servers" })
			vim.api.nvim_create_user_command("SvlsStatus", function()
				local clients = vim.lsp.get_active_clients({ name = "svls" })
				if #clients > 0 then
					print("SVLS is running. Root dir: " .. (clients[1].config.root_dir or "unknown"))
				else
					print("SVLS is not running")
				end
			end, { desc = "Check SVLS status" })
		end,
	},

	-- Formatting with conform.nvim (modern alternative to null-ls)
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				desc = "Format buffer",
			},
		},
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },
					python = { "isort", "black" },
					c = { "clang-format" },
					cpp = { "clang-format" },
					javascript = { { "prettierd", "prettier" } },
					typescript = { { "prettierd", "prettier" } },
					json = { { "prettierd", "prettier" } },
				},
				format_on_save = {
					timeout_ms = 500,
					lsp_fallback = true,
				},
			})
		end,
	},

	-- Linting with nvim-lint (modern alternative to null-ls)
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local lint = require("lint")

			-- Configure linters by filetype
			lint.linters_by_ft = {
				python = { "flake8" },
				javascript = { "eslint_d" },
				typescript = { "eslint_d" },
				lua = { "luacheck" },
				-- SystemVerilog/Verilog linting with verilator
				systemverilog = { "verilator" },
				verilog = { "verilator" },
			}

			-- Configure verilator linter with custom settings
			lint.linters.verilator = {
				cmd = "verilator",
				stdin = false,
				args = {
					"--lint-only",
					"-Wall",
					"-I" .. (os.getenv("UVM_HOME") or "") .. "/src",
					function()
						return vim.api.nvim_buf_get_name(0)
					end,
				},
				stream = "stderr",
				ignore_exitcode = true,
				parser = function(output, bufnr)
					local diagnostics = {}
					-- Parse verilator output format
					for line in output:gmatch("[^\n]+") do
						local file, line_num, col, severity, message = line:match("([^:]+):(%d+):(%d+): ([^:]+): (.+)")
						if file and line_num and message then
							local diagnostic = {
								lnum = tonumber(line_num) - 1,
								col = tonumber(col) - 1 or 0,
								message = message,
								severity = severity:lower():match("error") and vim.diagnostic.severity.ERROR
									or severity:lower():match("warning") and vim.diagnostic.severity.WARN
									or vim.diagnostic.severity.INFO,
								source = "verilator",
							}
							table.insert(diagnostics, diagnostic)
						end
					end
					return diagnostics
				end,
			}

			-- Helper function to check if a linter command exists
			local function linter_exists(cmd)
				return vim.fn.executable(cmd) == 1
			end

			-- Auto-lint on various events with error handling
			local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
			vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
				group = lint_augroup,
				callback = function()
					-- Get the current filetype
					local ft = vim.bo.filetype
					local linters = lint.linters_by_ft[ft] or {}

					-- Check if any linters are available for this filetype
					local available_linters = {}
					for _, linter_name in ipairs(linters) do
						local linter_config = lint.linters[linter_name]
						if linter_config and linter_exists(linter_config.cmd) then
							table.insert(available_linters, linter_name)
						end
					end

					-- Only run linting if we have available linters
					if #available_linters > 0 then
						lint.try_lint(available_linters)
					end
				end,
			})

			-- Manual lint command
			vim.api.nvim_create_user_command("Lint", function()
				lint.try_lint()
			end, { desc = "Trigger linting for current file" })
		end,
	},

	-- Enhanced text illumination
	{
		"RRethy/vim-illuminate",
		config = function()
			vim.cmd([[
        let g:Illuminate_useDeprecated = 1
        let g:Illuminate_ftwhitelist = ['python, c, php']
      ]])

			-- Set the highlighting style
			vim.api.nvim_command([[hi def link LspReferenceText CursorLine]])
			vim.api.nvim_command([[hi def link LspReferenceWrite CursorLine]])
			vim.api.nvim_command([[hi def link LspReferenceRead CursorLine]])
		end,
	},

	-- Debugging with DAP (Core functionality)
	{
		"mfussenegger/nvim-dap",
		config = function()
			-- Get the DAP module safely
			local status_ok, dap = pcall(require, "dap")
			if not status_ok then
				vim.notify("nvim-dap not available", vim.log.levels.WARN)
				return
			end

			-- Set up key mappings for DAP
			vim.keymap.set("n", "<Leader>dp", function()
				dap.continue()
			end, { desc = "Debug: Continue" })

			vim.keymap.set("n", "<Leader>dn", function()
				dap.step_over()
			end, { desc = "Debug: Step over" })
			vim.keymap.set("n", "<Leader>di", function()
				dap.step_into()
			end, { desc = "Debug: Step into" })
			vim.keymap.set("n", "<Leader>do", function()
				dap.step_out()
			end, { desc = "Debug: Step out" })

			vim.keymap.set("n", "<Leader>dd", function()
				dap.toggle_breakpoint()
			end, { desc = "Debug: Toggle breakpoint" })
			vim.keymap.set("n", "<Leader>dD", function()
				dap.set_breakpoint()
			end, { desc = "Debug: Set breakpoint" })
			vim.keymap.set("n", "<Leader>dl", function()
				dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
			end, { desc = "Debug: Set log point" })

			vim.keymap.set("n", "<Leader>dr", function()
				dap.repl.toggle()
			end, { desc = "Debug: Toggle REPL" })

			vim.keymap.set("n", "<Leader>dl", function()
				dap.run_last()
			end, { desc = "Debug: Run last" })
		end,
	},

	-- DAP UI - Enhanced debugging UI
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap", -- Explicit dependency
			"nvim-neotest/nvim-nio",
		},
		config = function()
			-- Safely load dapui module
			local status_ok, dapui = pcall(require, "dapui")
			if not status_ok then
				vim.notify("nvim-dap-ui not available", vim.log.levels.WARN)
				return
			end

			-- Set up DAPUI
			dapui.setup({
				-- Default configuration
				icons = { expanded = "▾", collapsed = "▸", current_frame = "→" },
				mappings = {
					expand = { "<CR>", "<2-LeftMouse>" },
					open = "o",
					remove = "d",
					edit = "e",
					repl = "r",
					toggle = "t",
				},
				layouts = {
					{
						elements = {
							{ id = "scopes", size = 0.25 },
							"breakpoints",
							"stacks",
							"watches",
						},
						size = 40,
						position = "left",
					},
					{
						elements = {
							"repl",
							"console",
						},
						size = 10,
						position = "bottom",
					},
				},
				floating = {
					max_height = nil,
					max_width = nil,
					border = "single",
					mappings = {
						close = { "q", "<Esc>" },
					},
				},
				windows = { indent = 1 },
				render = {
					max_type_length = nil,
					max_value_lines = 100,
				},
			})

			-- Now, safely get DAP for event handling
			local dap_status, dap = pcall(require, "dap")
			if dap_status then
				-- Set up automatic UI open/close with debugging sessions
				dap.listeners.after.event_initialized["dapui_config"] = function()
					dapui.open()
				end
				dap.listeners.before.event_terminated["dapui_config"] = function()
					dapui.close()
				end
				dap.listeners.before.event_exited["dapui_config"] = function()
					dapui.close()
				end
			end

			-- Additional keymaps for DAP UI
			vim.keymap.set({ "n", "v" }, "<Leader>dh", function()
				local widgets_status, widgets = pcall(require, "dap.ui.widgets")
				if widgets_status then
					widgets.hover()
				end
			end, { desc = "Debug: Hover" })

			vim.keymap.set({ "n", "v" }, "<Leader>dv", function()
				local widgets_status, widgets = pcall(require, "dap.ui.widgets")
				if widgets_status then
					widgets.preview()
				end
			end, { desc = "Debug: Preview" })

			vim.keymap.set("n", "<Leader>df", function()
				local widgets_status, widgets = pcall(require, "dap.ui.widgets")
				if widgets_status then
					widgets.centered_float(widgets.frames)
				end
			end, { desc = "Debug: Show frames" })

			vim.keymap.set("n", "<Leader>ds", function()
				local widgets_status, widgets = pcall(require, "dap.ui.widgets")
				if widgets_status then
					widgets.centered_float(widgets.scopes)
				end
			end, { desc = "Debug: Show scopes" })
		end,
	},

	-- DAP Virtual Text - Shows values on top of code while debugging
	{
		"theHamsta/nvim-dap-virtual-text",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			-- Safely load virtual text module
			local status_ok, virtual_text = pcall(require, "nvim-dap-virtual-text")
			if not status_ok then
				vim.notify("nvim-dap-virtual-text not available", vim.log.levels.WARN)
				return
			end

			-- Configure virtual text
			virtual_text.setup({
				enabled = true,
				enabled_commands = true,
				highlight_changed_variables = true,
				highlight_new_as_changed = false,
				show_stop_reason = true,
				commented = false,
				virt_text_pos = "eol",
				all_frames = false,
				virt_lines = false,
				virt_text_win_col = nil,
			})
		end,
	},
}

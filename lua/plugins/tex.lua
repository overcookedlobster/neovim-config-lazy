return {
	"lervag/vimtex",
	lazy = false, -- CRITICAL: Load on startup, not lazy-loaded
	priority = 1000, -- High priority to load before other plugins
	ft = { "tex", "latex" },
	init = function()
		-- OS detection (from tex.vim)
		if not vim.g.os_current then
			if vim.fn.has("win64") == 1 or vim.fn.has("win32") == 1 or vim.fn.has("win16") == 1 then
				vim.g.os_current = "Windows"
			else
				vim.g.os_current = vim.fn.system("uname"):gsub("\n", "")
			end
		end

		-- From tex.vim
		vim.g.tex_flavor = "latex" -- recognize tex files as latex
		vim.g.tex_indent_items = 0 -- Turn off automatic indenting in enumerated environments

		-- From vimtex.vim - compiler settings
		vim.g.vimtex_compiler_method = "latexmk"
		vim.g.vimtex_compiler_latexmk = {
			build_dir = "",
			options = {
				"-pdf",
				"-shell-escape",
				"-verbose",
				"-file-line-error",
				"-synctex=1",
				"-interaction=nonstopmode",
			},
		}

		-- CRITICAL SETTINGS TO FIX SYNTAX HIGHLIGHTING
		vim.g.vimtex_syntax_enabled = 1
		vim.g.vimtex_syntax_conceal_enable = 1

		-- VimTeX view settings
		-- Zathura is a good choice for X11/Wayland with synctex support.
		vim.g.vimtex_view_method = "zathura"
		-- This option ensures Zathura knows where to look for the source file and line.
		-- It's used for the *forward* search part of the view command.
		vim.g.vimtex_view_general_options = [[--unique file:@pdf\#src:@line@tex]]
		-- For *inverse* search (PDF -> Neovim), Zathura must be configured separately to call 'nvr'.
		-- The command would look something like:
		-- zathura-pdf-viewer --synctex-editor-command "nvr --servername $NVIM_LISTEN_ADDRESS --remote-silent +\%{line} \%{input}"

		-- Compiler settings - ensure nvr is used for server for inverse search
		-- This is CRITICAL for Wayland compatibility (and generally better for X11 too).
		vim.g.vimtex_compiler_progname = "nvr"

		-- QuickFix settings
		vim.g.vimtex_quickfix_open_on_warning = 0
		vim.g.vimtex_quickfix_ignore_filters = {
			"Underfull \\hbox",
			"Overfull \\hbox",
			"LaTeX Warning: .\\+ float specifier changed to",
			"LaTeX hooks Warning",
			'Package siunitx Warning: Detected the "physics" package:',
			"Package hyperref Warning: Token not allowed in a PDF string",
		}
	end,
	config = function()
		-- Create a TeX settings group
		local tex_group = vim.api.nvim_create_augroup("vimtex_config", { clear = true })

		-- TeX file detection
		vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
			pattern = { "*.tex", "*.sty", "*.dtx", "*.ltx", "*.cls" },
			callback = function()
				vim.bo.filetype = "tex"
			end,
		})

		-- Set up TeX indentation (from tex.vim)
		vim.api.nvim_create_autocmd("FileType", {
			group = tex_group,
			pattern = "tex",
			callback = function()
				vim.opt_local.expandtab = true
				vim.opt_local.autoindent = true
				vim.opt_local.tabstop = 4
				vim.opt_local.softtabstop = 4
				vim.opt_local.shiftwidth = 4

				-- Ensure VimTeX is initialized
				if vim.fn.exists("*vimtex#init") == 1 then
					vim.cmd("call vimtex#init()")
				end

				-- Enable syntax highlighting
				vim.cmd("syntax enable")

				-- Write inverse search target (from tex.vim)
				-- This is not standard but harmless; often used for custom inverse search scripts.
				vim.fn.system("echo TEX > /tmp/inverse-search-target.txt")
			end,
		})

		-- *** REMOVED UNRELIABLE XDOTOOL LOGIC ***
		-- The lines below are removed as they are fragile and Wayland-incompatible:
		-- `vim.g.vim_window_id = vim.fn.system("xdotool getactivewindow")`
		-- The entire "VimtexEventView" autocmd which contained `vim.cmd("!xdotool windowfocus " .. vim.g.vim_window_id)`

		-- Forward search implementation (from tex.vim)
		-- Removed the Linux-specific, xdotool-based 'VimtexEventView' autocmd.
		-- Vimtex's default view mechanism is generally sufficient to bring the viewer to the foreground.

		-- The only change for Darwin (macOS) is to ensure Alacritty opens, which is fine as a simple command.
		if vim.g.os_current == "Darwin" then
			vim.api.nvim_create_autocmd("User", {
				group = tex_group,
				pattern = "VimtexEventViewReverse",
				callback = function()
					vim.cmd("!open -a Alacritty")
					vim.cmd("redraw!")
				end,
			})
		end

		-- Close viewers when VimTeX buffers are closed (from vimtex.vim)
		-- Swapping out the unreliable xdotool window close with a less aggressive approach.
		-- The viewer should generally be closed manually or by the compile method.
		-- If you insist on closing the viewer on Neovim exit, you will need to find
		-- a Wayland-compatible utility or rely on the compile method's cleanup.
		-- I am removing the Xdotool logic to prevent errors, as it won't work on Wayland.
		vim.api.nvim_create_autocmd("User", {
			group = tex_group,
			pattern = "VimtexEventQuit",
			callback = function()
				-- The original code used xdotool, which is not Wayland-compatible.
				-- If you want to close the viewer automatically, you need a different
				-- mechanism. For general compatibility, we remove the block.
				-- if vim.fn.executable("xdotool") == 1 and ... then
				--   vim.fn.system("xdotool windowclose " .. vim.b.vimtex.viewer.xwin_id)
				-- end
			end,
		})

		-- Toggle shell escape function (from vimtex.vim)
		local function toggle_shell_escape()
			if not vim.g.vimtex_compiler_latexmk or not vim.g.vimtex_compiler_latexmk.options then
				vim.notify("VimTeX compiler options not properly set up", vim.log.levels.ERROR)
				return
			end

			local options = vim.g.vimtex_compiler_latexmk.options
			local shell_escape_index = nil

			for i, option in ipairs(options) do
				if option == "-shell-escape" then
					shell_escape_index = i
					break
				end
			end

			if shell_escape_index then
				-- Disable shell escape
				table.remove(options, shell_escape_index)
				vim.notify("Shell escape disabled")
			else
				-- Enable shell escape
				table.insert(options, "-shell-escape")
				vim.notify("Shell escape enabled")
			end

			vim.cmd("VimtexReload")
			vim.cmd("VimtexClean")
		end

		-- Register the TexToggleShellEscape command
		vim.api.nvim_create_user_command("TexToggleShellEscape", toggle_shell_escape, {})

		-- Set up key mappings (from tex.vim and vimtex.vim)
		vim.api.nvim_create_autocmd("FileType", {
			group = tex_group,
			pattern = "tex",
			callback = function()
				-- LaTeX commands with intuitive <leader>l prefix
				vim.keymap.set(
					"n",
					"<leader>lc",
					"<Cmd>update<CR><Cmd>VimtexCompileSS<CR>",
					{ buffer = true, desc = "LaTeX: Compile document" }
				)
				vim.keymap.set(
					"n",
					"<leader>lr",
					"<Cmd>update<CR><Cmd>VimtexCompileSS<CR>",
					{ buffer = true, desc = "LaTeX: Recompile document" }
				)
				vim.keymap.set("n", "<leader>lv", "<plug>(vimtex-view)", { buffer = true, desc = "LaTeX: View PDF" })
				vim.keymap.set("n", "<leader>li", "<plug>(vimtex-info)", { buffer = true, desc = "LaTeX: Show info" })
				vim.keymap.set(
					"n",
					"<leader>lt",
					"<Cmd>VimtexTocToggle<CR>",
					{ buffer = true, desc = "LaTeX: Toggle table of contents" }
				)
				vim.keymap.set(
					"n",
					"<leader>le",
					"<Cmd>TexToggleShellEscape<CR>",
					{ buffer = true, desc = "LaTeX: Toggle shell escape" }
				)
				vim.keymap.set(
					"n",
					"<leader>lk",
					"<Cmd>VimtexStop<CR>",
					{ buffer = true, desc = "LaTeX: Stop compilation" }
				)
				vim.keymap.set(
					"n",
					"<leader>ll",
					"<Cmd>VimtexCompile<CR>",
					{ buffer = true, desc = "LaTeX: Start continuous compilation" }
				)
				vim.keymap.set(
					"n",
					"<leader>lx",
					"<Cmd>VimtexClean<CR>",
					{ buffer = true, desc = "LaTeX: Clean auxiliary files" }
				)
				vim.keymap.set(
					"n",
					"<leader>lX",
					"<Cmd>VimtexClean!<CR>",
					{ buffer = true, desc = "LaTeX: Clean all files" }
				)
				vim.keymap.set(
					"n",
					"<leader>ls",
					"<Cmd>VimtexStatus<CR>",
					{ buffer = true, desc = "LaTeX: Show status" }
				)
				vim.keymap.set("n", "<leader>lg", "<Cmd>VimtexLog<CR>", { buffer = true, desc = "LaTeX: Show log" })

				-- Define mappings (from vimtex.vim)
				-- Delete mappings
				vim.keymap.set(
					"n",
					"dse",
					"<plug>(vimtex-env-delete)",
					{ buffer = true, desc = "TeX: Delete surrounding environment" }
				)
				vim.keymap.set(
					"n",
					"dsc",
					"<plug>(vimtex-cmd-delete)",
					{ buffer = true, desc = "TeX: Delete surrounding command" }
				)
				vim.keymap.set(
					"n",
					"dsm",
					"<plug>(vimtex-env-delete-math)",
					{ buffer = true, desc = "TeX: Delete surrounding math environment" }
				)
				vim.keymap.set(
					"n",
					"dsd",
					"<plug>(vimtex-delim-delete)",
					{ buffer = true, desc = "TeX: Delete surrounding delimiters" }
				)

				-- Change mappings
				vim.keymap.set(
					"n",
					"cse",
					"<plug>(vimtex-env-change)",
					{ buffer = true, desc = "TeX: Change surrounding environment" }
				)
				vim.keymap.set(
					"n",
					"csc",
					"<plug>(vimtex-cmd-change)",
					{ buffer = true, desc = "TeX: Change surrounding command" }
				)
				vim.keymap.set(
					"n",
					"csm",
					"<plug>(vimtex-env-change-math)",
					{ buffer = true, desc = "TeX: Change surrounding math environment" }
				)
				vim.keymap.set(
					"n",
					"csd",
					"<plug>(vimtex-delim-change-math)",
					{ buffer = true, desc = "TeX: Change surrounding math delimiters" }
				)

				-- Toggle mappings
				vim.keymap.set(
					"n",
					"tsf",
					"<plug>(vimtex-cmd-toggle-frac)",
					{ buffer = true, desc = "TeX: Toggle fraction command" }
				)
				vim.keymap.set(
					"n",
					"tsc",
					"<plug>(vimtex-cmd-toggle-star)",
					{ buffer = true, desc = "TeX: Toggle command star variant" }
				)
				vim.keymap.set(
					"n",
					"tse",
					"<plug>(vimtex-env-toggle-star)",
					{ buffer = true, desc = "TeX: Toggle environment star variant" }
				)
				vim.keymap.set(
					"n",
					"tsd",
					"<plug>(vimtex-delim-toggle-modifier)",
					{ buffer = true, desc = "TeX: Toggle delimiter modifier" }
				)
				vim.keymap.set(
					"n",
					"tsD",
					"<plug>(vimtex-delim-toggle-modifier-reverse)",
					{ buffer = true, desc = "TeX: Toggle delimiter modifier (reverse)" }
				)
				vim.keymap.set(
					"n",
					"tsm",
					"<plug>(vimtex-env-toggle-math)",
					{ buffer = true, desc = "TeX: Toggle math environment" }
				)
				vim.keymap.set(
					"i",
					"]]",
					"<plug>(vimtex-delim-close)",
					{ buffer = true, desc = "TeX: Close delimiter" }
				)

				-- Text objects (from vimtex.vim)
				-- Command text objects
				vim.keymap.set("o", "ac", "<plug>(vimtex-ac)", { buffer = true, desc = "TeX: Around command" })
				vim.keymap.set("x", "ac", "<plug>(vimtex-ac)", { buffer = true, desc = "TeX: Around command" })
				vim.keymap.set("o", "ic", "<plug>(vimtex-ic)", { buffer = true, desc = "TeX: Inside command" })
				vim.keymap.set("x", "ic", "<plug>(vimtex-ic)", { buffer = true, desc = "TeX: Inside command" })

				-- Delimiter text objects
				vim.keymap.set("o", "ad", "<plug>(vimtex-ad)", { buffer = true, desc = "TeX: Around delimiters" })
				vim.keymap.set("x", "ad", "<plug>(vimtex-ad)", { buffer = true, desc = "TeX: Around delimiters" })
				vim.keymap.set("o", "id", "<plug>(vimtex-id)", { buffer = true, desc = "TeX: Inside delimiters" })
				vim.keymap.set("x", "id", "<plug>(vimtex-id)", { buffer = true, desc = "TeX: Inside delimiters" })

				-- Environment text objects
				vim.keymap.set("o", "ae", "<plug>(vimtex-ae)", { buffer = true, desc = "TeX: Around environment" })
				vim.keymap.set("x", "ae", "<plug>(vimtex-ae)", { buffer = true, desc = "TeX: Around environment" })
				vim.keymap.set("o", "ie", "<plug>(vimtex-ie)", { buffer = true, desc = "TeX: Inside environment" })
				vim.keymap.set("x", "ie", "<plug>(vimtex-ie)", { buffer = true, desc = "TeX: Inside environment" })

				-- Math text objects
				vim.keymap.set("o", "am", "<plug>(vimtex-a$)", { buffer = true, desc = "TeX: Around math" })
				vim.keymap.set("x", "am", "<plug>(vimtex-a$)", { buffer = true, desc = "TeX: Around math" })
				vim.keymap.set("o", "im", "<plug>(vimtex-i$)", { buffer = true, desc = "TeX: Inside math" })
				vim.keymap.set("x", "im", "<plug>(vimtex-i$)", { buffer = true, desc = "TeX: Inside math" })

				-- Item text objects
				vim.keymap.set("o", "ai", "<plug>(vimtex-am)", { buffer = true, desc = "TeX: Around item" })
				vim.keymap.set("x", "ai", "<plug>(vimtex-am)", { buffer = true, desc = "TeX: Around item" })
				vim.keymap.set("o", "ii", "<plug>(vimtex-im)", { buffer = true, desc = "TeX: Inside item" })
				vim.keymap.set("x", "ii", "<plug>(vimtex-im)", { buffer = true, desc = "TeX: Inside item" })

				-- Section/paragraph text objects
				vim.keymap.set("o", "aP", "<plug>(vimtex-aP)", { buffer = true, desc = "TeX: Around paragraph" })
				vim.keymap.set("x", "aP", "<plug>(vimtex-aP)", { buffer = true, desc = "TeX: Around paragraph" })
				vim.keymap.set("o", "iP", "<plug>(vimtex-iP)", { buffer = true, desc = "TeX: Inside paragraph" })
				vim.keymap.set("x", "iP", "<plug>(vimtex-iP)", { buffer = true, desc = "TeX: Inside paragraph" })

				-- Motion mappings
				vim.keymap.set("", "%", "<plug>(vimtex-%)", { buffer = true, desc = "TeX: Match delimiter" })
				vim.keymap.set("", "]]", "<plug>(vimtex-]])", { buffer = true, desc = "TeX: Next section start" })
				vim.keymap.set("", "][", "<plug>(vimtex-][)", { buffer = true, desc = "TeX: Next section end" })
				vim.keymap.set("", "[]", "<plug>(vimtex-[])", { buffer = true, desc = "TeX: Previous section end" })
				vim.keymap.set("", "[[", "<plug>(vimtex-[[)", { buffer = true, desc = "TeX: Previous section start" })

				-- Section motions
				vim.keymap.set("", "]m", "<plug>(vimtex-]m)", { buffer = true, desc = "TeX: Next section" })
				vim.keymap.set("", "]M", "<plug>(vimtex-]M)", { buffer = true, desc = "TeX: Next section end" })
				vim.keymap.set("", "[m", "<plug>(vimtex-[m)", { buffer = true, desc = "TeX: Previous section" })
				vim.keymap.set("", "[M", "<plug>(vimtex-[M)", { buffer = true, desc = "TeX: Previous section end" })

				-- Environment motions
				vim.keymap.set("", "]n", "<plug>(vimtex-]n)", { buffer = true, desc = "TeX: Next environment" })
				vim.keymap.set("", "]N", "<plug>(vimtex-]N)", { buffer = true, desc = "TeX: Next environment end" })
				vim.keymap.set("", "[n", "<plug>(vimtex-[n)", { buffer = true, desc = "TeX: Previous environment" })
				vim.keymap.set("", "[N", "<plug>(vimtex-[N)", { buffer = true, desc = "TeX: Previous environment end" })

				-- Item motions
				vim.keymap.set("", "]r", "<plug>(vimtex-]r)", { buffer = true, desc = "TeX: Next item" })
				vim.keymap.set("", "]R", "<plug>(vimtex-]R)", { buffer = true, desc = "TeX: Next item end" })
				vim.keymap.set("", "[r", "<plug>(vimtex-[r)", { buffer = true, desc = "TeX: Previous item" })
				vim.keymap.set("", "[R", "<plug>(vimtex-[R)", { buffer = true, desc = "TeX: Previous item end" })

				-- Comment motions
				vim.keymap.set("", "]/", "<plug>(vimtex-]/)", { buffer = true, desc = "TeX: Next comment" })
				vim.keymap.set("", "]*", "<plug>(vimtex-]star)", { buffer = true, desc = "TeX: Next comment end" })
				vim.keymap.set("", "[/", "<plug>(vimtex-[/)", { buffer = true, desc = "TeX: Previous comment" })
				vim.keymap.set("", "[*", "<plug>(vimtex-[star)", { buffer = true, desc = "TeX: Previous comment end" })

				-- Check for minted package and enable shell escape if needed
				local cmd = "head -n 20 " .. vim.fn.expand("%") .. ' | grep "minted" > /dev/null'
				local result = vim.fn.system(cmd)
				if vim.v.shell_error == 0 then -- minted found
					if not vim.tbl_contains(vim.g.vimtex_compiler_latexmk.options, "-shell-escape") then
						table.insert(vim.g.vimtex_compiler_latexmk.options, "-shell-escape")
						vim.notify("Shell escape enabled for minted package")
					end
				end
			end,
		})

		-- Add a debug command to check VimTeX status
		vim.api.nvim_create_user_command("CheckVimtex", function()
			vim.notify("VimTeX loaded: " .. tostring(vim.fn.exists("*vimtex#init")))
			local cmds = vim.fn.getcompletion("Vimtex", "cmdline")
			vim.notify("Available VimTeX commands: " .. vim.inspect(cmds))
			vim.notify("Current filetype: " .. vim.bo.filetype)
			vim.notify("Syntax enabled: " .. tostring(vim.g.syntax_on or vim.g.syntax_manual))
		end, {})
	end,
}

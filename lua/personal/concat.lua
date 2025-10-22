-- ~/.config/nvim/lua/personal/concat.lua
local M = {}

-- Check if telescope is available
local function has_telescope()
	return pcall(require, "telescope")
end

-- State management
local selected_files = {}
local config = {
	output_file = "concatenated.txt",
	max_size = nil,
	exclude_patterns = { ".git", "node_modules", ".DS_Store" },
}

-- Enhanced Telescope file picker with proper multi-select
local function telescope_file_picker()
	if not has_telescope() then
		vim.notify("Telescope not found, falling back to alternative method", vim.log.levels.WARN)
		return M.fallback_picker()
	end

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local previewers = require("telescope.previewers")

	-- Get files
	local files = {}
	local handle = io.popen("find . -type f ! -path '*/.*' ! -path '*/node_modules/*' ! -path '*/.git/*' | sort")
	if handle then
		for line in handle:lines() do
			table.insert(files, line)
		end
		handle:close()
	end

	-- Create a function to make the finder (so we can refresh it)
	local function make_finder()
		return finders.new_table({
			results = files,
			entry_maker = function(entry)
				local display_name
				-- Check selection status and update display
				if selected_files[entry] then
					display_name = "✅ " .. entry
				else
					display_name = "⬜ " .. entry
				end

				return {
					value = entry,
					display = display_name,
					ordinal = entry,
					path = entry,
				}
			end,
		})
	end

	-- Custom previewer that shows file info + selection status
	local custom_previewer = previewers.new_buffer_previewer({
		title = "File Preview & Selection Info",
		define_preview = function(self, entry, status)
			local file_path = entry.value
			local bufnr = self.state.bufnr

			-- File info
			local file_info = {}
			local stat = vim.loop.fs_stat(file_path)
			if stat then
				table.insert(file_info, "📁 File: " .. file_path)
				table.insert(file_info, "📏 Size: " .. stat.size .. " bytes")
				table.insert(file_info, "📅 Modified: " .. os.date("%Y-%m-%d %H:%M:%S", stat.mtime.sec))
				table.insert(file_info, "")

				-- Selection status
				if selected_files[file_path] then
					table.insert(file_info, "✅ SELECTED for concatenation")
				else
					table.insert(file_info, "⬜ Not selected (press <Tab> to select)")
				end
				table.insert(file_info, "")

				-- Current selection summary
				local selected_count = vim.tbl_count(selected_files)
				table.insert(file_info, "📊 Selection Summary:")
				table.insert(file_info, "   Selected files: " .. selected_count)
				if selected_count > 0 then
					table.insert(file_info, "   Selected files list:")
					local selected_list = vim.tbl_keys(selected_files)
					table.sort(selected_list)
					for i, selected_file in ipairs(selected_list) do
						if i <= 10 then -- Show max 10 files
							table.insert(file_info, "     " .. i .. ". " .. selected_file)
						elseif i == 11 then
							table.insert(file_info, "     ... and " .. (selected_count - 10) .. " more")
							break
						end
					end
				end
				table.insert(file_info, "")
				table.insert(file_info, "🔧 Controls:")
				table.insert(file_info, "   <Tab>    - Toggle selection")
				table.insert(file_info, "   <C-a>    - Select all files")
				table.insert(file_info, "   <C-d>    - Deselect all files")
				table.insert(file_info, "   <C-o>    - Go to options menu")
				table.insert(file_info, "   <Enter>  - Go to options menu")
				table.insert(file_info, "   <Esc>    - Cancel")
				table.insert(file_info, "")
				table.insert(file_info, string.rep("─", 50))
				table.insert(file_info, "")
			end

			-- Add file content preview
			local file_content = {}
			local f = io.open(file_path, "r")
			if f then
				local line_count = 0
				for line in f:lines() do
					table.insert(file_content, line)
					line_count = line_count + 1
					if line_count >= 30 then -- Limit preview lines
						table.insert(file_content, "... (truncated, showing first 30 lines)")
						break
					end
				end
				f:close()
			else
				table.insert(file_content, "❌ Cannot read file")
			end

			-- Combine info and content
			local all_lines = {}
			vim.list_extend(all_lines, file_info)
			vim.list_extend(all_lines, file_content)

			vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, all_lines)

			-- Set syntax highlighting for the preview
			vim.api.nvim_buf_set_option(bufnr, "filetype", "markdown")
		end,
	})

	-- Function to refresh picker with updated selection count
	local function refresh_picker(picker)
		local new_finder = make_finder()
		picker:refresh(new_finder, { reset_prompt = false })

		-- Update the prompt title to show current selection count
		local selected_count = vim.tbl_count(selected_files)
		picker.prompt_border:change_title(string.format("📁 File Concatenation (Selected: %d)", selected_count))
	end

	local picker = pickers.new({}, {
		prompt_title = string.format("📁 File Concatenation (Selected: %d)", vim.tbl_count(selected_files)),
		finder = make_finder(),
		sorter = conf.generic_sorter({}),
		previewer = custom_previewer,
		attach_mappings = function(prompt_bufnr, map)
			-- Toggle selection with Tab
			local function toggle_selection()
				local selection = action_state.get_selected_entry()
				if selection then
					local file_path = selection.value
					if selected_files[file_path] then
						selected_files[file_path] = nil
						vim.notify("❌ Removed: " .. vim.fn.fnamemodify(file_path, ":."), vim.log.levels.INFO)
					else
						selected_files[file_path] = true
						vim.notify("✅ Added: " .. vim.fn.fnamemodify(file_path, ":."), vim.log.levels.INFO)
					end

					-- Refresh the picker to update display
					local current_picker = action_state.get_current_picker(prompt_bufnr)
					refresh_picker(current_picker)
				end
			end

			map("i", "<Tab>", toggle_selection)
			map("n", "<Tab>", toggle_selection)

			-- Select all files with Ctrl+A
			local function select_all()
				local count_before = vim.tbl_count(selected_files)
				for _, file in ipairs(files) do
					selected_files[file] = true
				end
				local count_after = vim.tbl_count(selected_files)
				vim.notify(
					"✅ Selected all " .. #files .. " files (+" .. (count_after - count_before) .. " new)",
					vim.log.levels.INFO
				)

				-- Refresh the picker
				local current_picker = action_state.get_current_picker(prompt_bufnr)
				refresh_picker(current_picker)
			end

			map("i", "<C-a>", select_all)
			map("n", "<C-a>", select_all)

			-- Deselect all files with Ctrl+D
			local function deselect_all()
				local count = vim.tbl_count(selected_files)
				selected_files = {}
				vim.notify("❌ Deselected all files (" .. count .. " files)", vim.log.levels.INFO)

				-- Refresh the picker
				local current_picker = action_state.get_current_picker(prompt_bufnr)
				refresh_picker(current_picker)
			end

			map("i", "<C-d>", deselect_all)
			map("n", "<C-d>", deselect_all)

			-- Go to options with Ctrl+O
			local function go_to_options()
				actions.close(prompt_bufnr)
				M.show_options_menu()
			end

			map("i", "<C-o>", go_to_options)
			map("n", "<C-o>", go_to_options)

			-- Override Enter to go to options instead of selecting
			actions.select_default:replace(go_to_options)

			-- Add help mapping
			map("i", "<C-h>", function()
				vim.notify(
					[[
🔧 Telescope File Concatenation Controls:
  <Tab>    - Toggle file selection
  <C-a>    - Select all files
  <C-d>    - Deselect all files
  <C-o>    - Go to options menu
  <Enter>  - Go to options menu
  <C-h>    - Show this help
  <Esc>    - Cancel and exit
]],
					vim.log.levels.INFO
				)
			end)

			map("n", "?", function()
				vim.notify(
					[[
🔧 Telescope File Concatenation Controls:
  <Tab>    - Toggle file selection
  <C-a>    - Select all files
  <C-d>    - Deselect all files
  <C-o>    - Go to options menu
  <Enter>  - Go to options menu
  ?        - Show this help
  <Esc>    - Cancel and exit
]],
					vim.log.levels.INFO
				)
			end)

			return true
		end,
	})

	picker:find()
end

-- Enhanced options menu with back navigation
function M.show_options_menu()
	local file_count = vim.tbl_count(selected_files)

	if file_count == 0 then
		vim.ui.select({ "🔙 Go back to file selection", "❌ Cancel" }, {
			prompt = "No files selected! What would you like to do?",
		}, function(choice)
			if choice and choice:match("Go back") then
				telescope_file_picker()
			end
		end)
		return
	end

	local options = {
		string.format("📝 Set output filename (%s)", config.output_file),
		string.format("🚫 Manage exclude patterns (%d patterns)", #config.exclude_patterns),
		"📏 Set file size limit"
			.. (config.max_size and string.format(" (%d KB)", math.floor(config.max_size / 1024)) or " (unlimited)"),
		string.format("👀 Preview selection (%d files)", file_count),
		"🔙 Back to file selection",
		string.format("🚀 Start concatenation (%d files)", file_count),
		"❌ Cancel",
	}

	vim.ui.select(options, {
		prompt = string.format("Concatenation Options (Selected: %d files):", file_count),
		format_item = function(item)
			return item
		end,
	}, function(choice)
		if not choice then
			return
		end

		if choice:match("Set output filename") then
			M.set_output_filename()
		elseif choice:match("Manage exclude patterns") then
			M.manage_exclude_patterns()
		elseif choice:match("Set file size limit") then
			M.set_size_limit()
		elseif choice:match("Preview selection") then
			M.preview_selection()
		elseif choice:match("Back to file selection") then
			telescope_file_picker()
		elseif choice:match("Start concatenation") then
			M.execute_concatenation()
		else -- Cancel
			M.reset_state()
		end
	end)
end

-- Set output filename
function M.set_output_filename()
	vim.ui.input({
		prompt = "Output filename: ",
		default = config.output_file,
	}, function(input)
		if input and input ~= "" then
			config.output_file = input
			vim.notify("✅ Output filename set to: " .. input, vim.log.levels.INFO)
		end
		M.show_options_menu()
	end)
end

-- Manage exclude patterns
function M.manage_exclude_patterns()
	local current = table.concat(config.exclude_patterns, ", ")
	vim.ui.input({
		prompt = "Exclude patterns (comma-separated): ",
		default = current,
	}, function(input)
		if input then
			config.exclude_patterns = {}
			for pattern in input:gmatch("[^,]+") do
				table.insert(config.exclude_patterns, vim.trim(pattern))
			end
			vim.notify("✅ Exclude patterns updated", vim.log.levels.INFO)
		end
		M.show_options_menu()
	end)
end

-- Set file size limit
function M.set_size_limit()
	vim.ui.input({
		prompt = "Max file size in KB (0 for no limit): ",
		default = config.max_size and tostring(math.floor(config.max_size / 1024)) or "0",
	}, function(input)
		if input then
			local kb = tonumber(input) or 0
			config.max_size = kb > 0 and (kb * 1024) or nil
			local msg = config.max_size and ("✅ Size limit set to: " .. kb .. " KB") or "✅ Size limit removed"
			vim.notify(msg, vim.log.levels.INFO)
		end
		M.show_options_menu()
	end)
end

-- Preview selection
function M.preview_selection()
	local files = vim.tbl_keys(selected_files)
	table.sort(files)

	local lines = {
		"# 📁 Concatenation Preview",
		"",
		string.format("**Selected Files:** %d", #files),
		string.format("**Output File:** %s", config.output_file),
		string.format(
			"**Size Limit:** %s",
			config.max_size and (math.floor(config.max_size / 1024) .. " KB") or "unlimited"
		),
		string.format("**Exclude Patterns:** %s", table.concat(config.exclude_patterns, ", ")),
		"",
		"## 📋 File List:",
		"",
	}

	local total_size = 0
	for i, file in ipairs(files) do
		local size = vim.fn.getfsize(file)
		total_size = total_size + (size > 0 and size or 0)
		local size_str = size > 0 and string.format(" (%d bytes)", size) or " (unknown size)"
		table.insert(lines, string.format("%d. `%s`%s", i, file, size_str))
	end

	table.insert(lines, "")
	table.insert(lines, string.format("**Total Size:** ~%d KB", math.floor(total_size / 1024)))
	table.insert(lines, "")
	table.insert(lines, "---")
	table.insert(lines, "")
	table.insert(lines, "**Controls:**")
	table.insert(lines, "- `q` or `<Esc>` - Go back to options")
	table.insert(lines, "- `<Enter>` - Start concatenation")
	table.insert(lines, "- `e` - Edit selection")

	-- Create preview buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	vim.api.nvim_buf_set_option(buf, "filetype", "markdown")

	-- Calculate window size
	local width = math.min(100, vim.o.columns - 4)
	local height = math.min(#lines + 4, vim.o.lines - 4)

	-- Open floating window
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = (vim.o.columns - width) / 2,
		row = (vim.o.lines - height) / 2,
		style = "minimal",
		border = "rounded",
		title = " 📋 Concatenation Preview ",
		title_pos = "center",
	})

	-- Add keymaps for the preview buffer
	local opts = { buffer = buf, noremap = true, silent = true }
	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(win, true)
		M.show_options_menu()
	end, opts)

	vim.keymap.set("n", "<Esc>", function()
		vim.api.nvim_win_close(win, true)
		M.show_options_menu()
	end, opts)

	vim.keymap.set("n", "<CR>", function()
		vim.api.nvim_win_close(win, true)
		M.execute_concatenation()
	end, opts)

	vim.keymap.set("n", "e", function()
		vim.api.nvim_win_close(win, true)
		telescope_file_picker()
	end, opts)
end

-- Execute concatenation
function M.execute_concatenation()
	local files = vim.tbl_keys(selected_files)

	if #files == 0 then
		vim.notify("No files selected!", vim.log.levels.WARN)
		return
	end

	local content = {
		"# 📁 File Concatenation Report",
		"",
		"**Generated:** " .. os.date("%Y-%m-%d %H:%M:%S"),
		"**Total Files:** " .. #files,
		"**Output:** " .. config.output_file,
		"",
		"---",
		"",
	}

	local processed = 0
	local skipped = 0

	-- Show progress
	vim.notify("🔄 Processing " .. #files .. " files...", vim.log.levels.INFO)

	for _, file_path in ipairs(files) do
		-- Check if file should be excluded
		local should_skip = false
		for _, pattern in ipairs(config.exclude_patterns) do
			if file_path:match(pattern) then
				should_skip = true
				break
			end
		end

		if should_skip then
			skipped = skipped + 1
			goto continue
		end

		-- Check file size
		if config.max_size then
			local size = vim.fn.getfsize(file_path)
			if size > config.max_size then
				vim.notify("⏭️  Skipping " .. file_path .. ": exceeds size limit", vim.log.levels.WARN)
				skipped = skipped + 1
				goto continue
			end
		end

		-- Read and add file content
		local file_lines = {}
		local f = io.open(file_path, "r")
		if f then
			for line in f:lines() do
				table.insert(file_lines, line)
			end
			f:close()

			-- Add file section
			table.insert(content, "## 📄 " .. file_path)
			table.insert(content, "")
			-- Detect file type for syntax highlighting
			local ext = file_path:match("%.([^%.]+)$")
			local lang = ext and ext or ""
			table.insert(content, "```" .. lang)
			vim.list_extend(content, file_lines)
			table.insert(content, "```")
			table.insert(content, "")

			processed = processed + 1
		else
			vim.notify("❌ Failed to read: " .. file_path, vim.log.levels.ERROR)
			skipped = skipped + 1
		end

		::continue::
	end

	-- Write output
	local f = io.open(config.output_file, "w")
	if f then
		f:write(table.concat(content, "\n"))
		f:close()

		vim.notify(
			string.format(
				"✅ Concatenation complete!\n📄 Processed: %d files\n⏭️  Skipped: %d files\n📁 Output: %s",
				processed,
				skipped,
				config.output_file
			),
			vim.log.levels.INFO
		)

		-- Ask to open file
		vim.ui.select({ "📖 Open file", "📁 Open in split", "❌ Close" }, {
			prompt = "Concatenation complete! What would you like to do?",
		}, function(choice)
			if choice and choice:match("Open file") then
				vim.cmd("edit " .. config.output_file)
			elseif choice and choice:match("Open in split") then
				vim.cmd("vsplit " .. config.output_file)
			end
		end)
	else
		vim.notify("❌ Failed to write: " .. config.output_file, vim.log.levels.ERROR)
	end

	M.reset_state()
end

-- Reset state
function M.reset_state()
	selected_files = {}
end

-- Fallback for when Telescope is not available
function M.fallback_picker()
	vim.notify("Using fallback file picker (install Telescope for better experience)", vim.log.levels.INFO)

	local files = {}
	local handle = io.popen("find . -type f ! -path '*/.*' ! -path '*/node_modules/*' | head -50")
	if handle then
		for line in handle:lines() do
			table.insert(files, line)
		end
		handle:close()
	end

	if #files == 0 then
		vim.notify("No files found", vim.log.levels.WARN)
		return
	end

	M.select_files_recursive(files, 1)
end

function M.select_files_recursive(files, index)
	if index > #files then
		M.show_options_menu()
		return
	end

	local file = files[index]
	local selected_count = vim.tbl_count(selected_files)
	local status = selected_files[file] and "✅ SELECTED" or "⬜ Not selected"

	vim.ui.select({
		string.format("✅ Include (%s)", status),
		"⏭️  Skip this file",
		"🎯 Select all remaining",
		string.format("✅ Done selecting (%d selected)", selected_count),
		"❌ Cancel",
	}, {
		prompt = string.format("File %d/%d: %s", index, #files, file),
	}, function(choice)
		if not choice then
			return
		end

		if choice:match("Include") then
			selected_files[file] = true
			vim.notify("✅ Added: " .. file)
			M.select_files_recursive(files, index + 1)
		elseif choice:match("Skip") then
			M.select_files_recursive(files, index + 1)
		elseif choice:match("Select all remaining") then
			for i = index, #files do
				selected_files[files[i]] = true
			end
			vim.notify("✅ Added " .. (#files - index + 1) .. " remaining files")
			M.show_options_menu()
		elseif choice:match("Done selecting") then
			M.show_options_menu()
		else -- Cancel
			M.reset_state()
		end
	end)
end

function M.setup()
	vim.api.nvim_create_user_command("ConcatFiles", function()
		M.reset_state()
		if has_telescope() then
			telescope_file_picker()
		else
			M.fallback_picker()
		end
	end, { desc = "Interactive file concatenation with multi-select" })

	vim.keymap.set("n", "<leader>cf", ":ConcatFiles<CR>", {
		noremap = true,
		silent = true,
		desc = "Interactive file concatenation",
	})

	-- Additional keymaps for quick access
	vim.keymap.set("n", "<leader>cF", function()
		M.reset_state()
		-- Quick mode: select all files and go to options
		local files = {}
		local handle = io.popen("find . -type f ! -path '*/.*' ! -path '*/node_modules/*' ! -path '*/.git/*'")
		if handle then
			for line in handle:lines() do
				selected_files[line] = true
				table.insert(files, line)
			end
			handle:close()
		end
		vim.notify("✅ Auto-selected " .. #files .. " files")
		M.show_options_menu()
	end, {
		noremap = true,
		silent = true,
		desc = "Quick concatenation (select all files)",
	})

	-- vim.no--[[ t ]]ify(
	-- "📁 Enhanced file concatenation plugin loaded!\n🔧 Commands: :ConcatFiles, <leader>cf (interactive), <leader>cF (quick)",
	-- vim.log.levels.INFO
	-- )
end

return M

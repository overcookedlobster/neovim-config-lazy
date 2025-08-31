-- ~/.config/nvim/lua/config/custom_notify.lua
-- Custom notification system that properly positions notifications in top-right

local M = {}

-- Configuration
local config = {
	timeout = 3000,
	max_width = 50,
	max_height = 10,
	border = "rounded",
	position = "top_right",
	offset = { row = 2, col = 2 }, -- Offset from screen edges
}

-- Active notifications tracking
local active_notifications = {}
local notification_id = 0

-- Calculate position based on existing notifications
local function calculate_position(width, height)
	local screen_width = vim.o.columns
	local screen_height = vim.o.lines

	local col = screen_width - width - config.offset.col
	local row = config.offset.row

	-- Stack notifications vertically
	for _, notif in pairs(active_notifications) do
		if notif.win and vim.api.nvim_win_is_valid(notif.win) then
			local notif_config = vim.api.nvim_win_get_config(notif.win)
			if notif_config.row and notif_config.row >= row then
				row = notif_config.row + notif_config.height + 1
			end
		end
	end

	-- Ensure notification doesn't go off screen
	if row + height > screen_height - 2 then
		row = screen_height - height - 2
	end

	return { row = row, col = col }
end

-- Create notification window
local function create_notification(message, level, opts)
	opts = opts or {}

	-- Prepare message lines
	local lines = {}
	if opts.title then
		table.insert(lines, "▎" .. opts.title)
		table.insert(lines, "")
	end

	-- Split message into lines if needed
	local msg_lines = vim.split(tostring(message), "\n")
	for _, line in ipairs(msg_lines) do
		table.insert(lines, "  " .. line)
	end

	-- Calculate dimensions
	local width = math.min(config.max_width, vim.o.columns - 4)
	local height = math.min(#lines + 2, config.max_height) -- +2 for padding

	-- Adjust width based on content
	for _, line in ipairs(lines) do
		width = math.max(width, math.min(#line + 4, config.max_width))
	end

	-- Calculate position
	local pos = calculate_position(width, height)

	-- Create buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	-- Set buffer options
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

	-- Create window
	local win = vim.api.nvim_open_win(buf, false, {
		relative = "editor",
		width = width,
		height = height,
		row = pos.row,
		col = pos.col,
		style = "minimal",
		border = config.border,
		focusable = false,
	})

	-- Set window highlights based on level
	local hl_group = "Normal"
	if level == vim.log.levels.ERROR then
		hl_group = "ErrorMsg"
	elseif level == vim.log.levels.WARN then
		hl_group = "WarningMsg"
	elseif level == vim.log.levels.INFO then
		hl_group = "InfoMsg"
	end

	vim.api.nvim_win_set_option(win, "winhighlight", "Normal:" .. hl_group)

	-- Track notification
	notification_id = notification_id + 1
	local id = notification_id
	active_notifications[id] = {
		win = win,
		buf = buf,
		timeout = opts.timeout or config.timeout,
	}

	-- Auto-close notification
	vim.defer_fn(function()
		M.close_notification(id)
	end, active_notifications[id].timeout)

	return id
end

-- Close specific notification
function M.close_notification(id)
	local notif = active_notifications[id]
	if not notif then
		return
	end

	if notif.win and vim.api.nvim_win_is_valid(notif.win) then
		vim.api.nvim_win_close(notif.win, true)
	end

	if notif.buf and vim.api.nvim_buf_is_valid(notif.buf) then
		vim.api.nvim_buf_delete(notif.buf, { force = true })
	end

	active_notifications[id] = nil
end

-- Close all notifications
function M.dismiss_all()
	for id, _ in pairs(active_notifications) do
		M.close_notification(id)
	end
end

-- Main notification function
function M.notify(message, level, opts)
	level = level or vim.log.levels.INFO
	opts = opts or {}

	return create_notification(message, level, opts)
end

-- Setup function
function M.setup(user_config)
	config = vim.tbl_deep_extend("force", config, user_config or {})

	-- Replace vim.notify
	vim.notify = M.notify

	-- Add command to dismiss all notifications
	vim.api.nvim_create_user_command("NotifyDismissAll", function()
		M.dismiss_all()
	end, { desc = "Dismiss all notifications" })
end

return M

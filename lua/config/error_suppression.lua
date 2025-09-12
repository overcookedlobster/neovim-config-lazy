-- ~/.config/nvim/lua/config/error_suppression.lua
-- Error suppression and non-intrusive notification system

local M = {}

-- Configuration for error suppression
local config = {
	-- Patterns to suppress (case-insensitive)
	suppress_patterns = {
		"bad argument.*error converting Lua string to String.*invalid utf%-8",
		"avante.*tokenizers.*calculate_tokens",
		"avante.*llm.*calculate_tokens",
		"avante.*sidebar.*token_count",
		"Error executing vim%.schedule lua callback.*avante",
	},
	-- Show suppressed errors in a less intrusive way
	show_suppressed_as_popup = true,
	-- Timeout for popup notifications (ms)
	popup_timeout = 2000,
	-- Maximum number of popups to show simultaneously
	max_popups = 3,
	-- Enable debug mode to see what's being suppressed
	debug_mode = false,
}

-- Track active popups
local active_popups = {}
local popup_id_counter = 0

-- Create a non-intrusive popup notification
local function create_popup_notification(message, level)
	if #active_popups >= config.max_popups then
		-- Remove oldest popup if we're at the limit
		local oldest_id = next(active_popups)
		if oldest_id then
			M.close_popup(oldest_id)
		end
	end

	-- Prepare message for display
	local display_msg = "⚠️ Suppressed Error"
	if type(message) == "string" then
		-- Truncate long messages
		local short_msg = message:sub(1, 60)
		if #message > 60 then
			short_msg = short_msg .. "..."
		end
		display_msg = "⚠️ " .. short_msg
	end

	-- Calculate position (top-right corner, stacked)
	local width = math.min(50, vim.o.columns - 4)
	local height = 3
	local col = vim.o.columns - width - 2
	local row = 1 + (#active_popups * (height + 1))

	-- Ensure popup doesn't go off screen
	if row + height > vim.o.lines - 2 then
		row = vim.o.lines - height - 2
	end

	-- Create buffer
	local buf = vim.api.nvim_create_buf(false, true)
	local lines = {
		" " .. display_msg .. " ",
		" (Press <Esc> to dismiss) ",
	}
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

	-- Create window
	local win = vim.api.nvim_open_win(buf, false, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		focusable = false,
		zindex = 1000, -- High z-index to appear above other windows
	})

	-- Set highlight based on level
	local hl_group = "WarningMsg"
	if level == vim.log.levels.ERROR then
		hl_group = "ErrorMsg"
	elseif level == vim.log.levels.INFO then
		hl_group = "InfoMsg"
	end

	vim.api.nvim_win_set_option(win, "winhighlight", "Normal:" .. hl_group .. ",FloatBorder:" .. hl_group)

	-- Track popup
	popup_id_counter = popup_id_counter + 1
	local popup_id = popup_id_counter
	active_popups[popup_id] = {
		win = win,
		buf = buf,
		created_at = vim.loop.hrtime(),
	}

	-- Auto-close after timeout
	vim.defer_fn(function()
		M.close_popup(popup_id)
	end, config.popup_timeout)

	-- Allow manual dismissal with Escape key
	vim.keymap.set("n", "<Esc>", function()
		M.dismiss_all_popups()
	end, { buffer = buf, silent = true })

	return popup_id
end

-- Close specific popup
function M.close_popup(popup_id)
	local popup = active_popups[popup_id]
	if not popup then
		return
	end

	if popup.win and vim.api.nvim_win_is_valid(popup.win) then
		vim.api.nvim_win_close(popup.win, true)
	end

	if popup.buf and vim.api.nvim_buf_is_valid(popup.buf) then
		vim.api.nvim_buf_delete(popup.buf, { force = true })
	end

	active_popups[popup_id] = nil
end

-- Dismiss all popups
function M.dismiss_all_popups()
	for popup_id, _ in pairs(active_popups) do
		M.close_popup(popup_id)
	end
end

-- Check if message should be suppressed
local function should_suppress(message)
	if type(message) ~= "string" then
		return false
	end

	local msg_lower = message:lower()
	for _, pattern in ipairs(config.suppress_patterns) do
		if msg_lower:match(pattern:lower()) then
			return true
		end
	end

	return false
end

-- Original vim.notify function
local original_notify = vim.notify

-- Custom notify function that filters errors
local function filtered_notify(message, level, opts)
	level = level or vim.log.levels.INFO
	opts = opts or {}

	-- Check if this message should be suppressed
	if should_suppress(message) then
		if config.debug_mode then
			print("[DEBUG] Suppressed error: " .. tostring(message))
		end

		-- Show as non-intrusive popup if enabled
		if config.show_suppressed_as_popup then
			create_popup_notification(message, level)
		end

		return
	end

	-- Use original notify for non-suppressed messages
	return original_notify(message, level, opts)
end

-- Setup function
function M.setup(user_config)
	config = vim.tbl_deep_extend("force", config, user_config or {})

	-- Replace vim.notify with filtered version
	vim.notify = filtered_notify

	-- Create commands for managing error suppression
	vim.api.nvim_create_user_command("ErrorSuppressionToggle", function()
		if vim.notify == filtered_notify then
			vim.notify = original_notify
			print("Error suppression disabled")
		else
			vim.notify = filtered_notify
			print("Error suppression enabled")
		end
	end, { desc = "Toggle error suppression" })

	vim.api.nvim_create_user_command("ErrorSuppressionDismiss", function()
		M.dismiss_all_popups()
	end, { desc = "Dismiss all error popups" })

	vim.api.nvim_create_user_command("ErrorSuppressionDebug", function()
		config.debug_mode = not config.debug_mode
		print("Error suppression debug mode: " .. (config.debug_mode and "enabled" or "disabled"))
	end, { desc = "Toggle error suppression debug mode" })

	vim.api.nvim_create_user_command("ErrorSuppressionStatus", function()
		print("Error suppression status:")
		print("  Enabled: " .. (vim.notify == filtered_notify and "yes" or "no"))
		print("  Debug mode: " .. (config.debug_mode and "yes" or "no"))
		print("  Show popups: " .. (config.show_suppressed_as_popup and "yes" or "no"))
		print("  Active popups: " .. #vim.tbl_keys(active_popups))
		print("  Suppression patterns: " .. #config.suppress_patterns)
	end, { desc = "Show error suppression status" })

	-- Add keymaps for quick access
	vim.keymap.set("n", "<leader>ed", ":ErrorSuppressionDismiss<CR>", {
		silent = true,
		desc = "Dismiss error popups",
	})

	vim.keymap.set("n", "<leader>et", ":ErrorSuppressionToggle<CR>", {
		silent = true,
		desc = "Toggle error suppression",
	})

end

-- Add pattern to suppress specific errors
function M.add_suppress_pattern(pattern)
	table.insert(config.suppress_patterns, pattern)
end

-- Remove pattern from suppression list
function M.remove_suppress_pattern(pattern)
	for i, p in ipairs(config.suppress_patterns) do
		if p == pattern then
			table.remove(config.suppress_patterns, i)
			break
		end
	end
end

-- Get current configuration
function M.get_config()
	return vim.deepcopy(config)
end

return M
-- Error suppression and non-intrusive notification system

local M = {}

-- Store original vim.notify function
local original_notify = vim.notify

-- Error patterns to suppress or make less intrusive
local suppressed_patterns = {
  "bad argument #1: error converting Lua string to String %(invalid utf%-8 sequence",
  "avante%.nvim.*tokenizers%.lua.*calculate_tokens",
  "avante%.nvim.*llm%.lua.*calculate_tokens",
  "avante%.nvim.*sidebar%.lua.*get_generate_prompts_options",
  "avante%.nvim.*sidebar%.lua.*initialize_token_count",
  "avante%.nvim.*sidebar%.lua.*show_input_hint",
  "Error executing vim%.schedule lua callback.*avante",
}

-- Patterns that should use non-blocking popups instead of blocking errors
local popup_patterns = {
  "avante",
  "tokenizer",
  "utf%-8",
  "encoding",
}

-- Counter for suppressed messages
local suppressed_count = 0
local last_suppressed_time = 0

-- Function to check if a message should be suppressed
local function should_suppress(msg)
  if type(msg) ~= "string" then
    return false
  end

  for _, pattern in ipairs(suppressed_patterns) do
    if msg:match(pattern) then
      return true
    end
  end

  return false
end

-- Function to check if a message should use popup instead of blocking
local function should_use_popup(msg)
  if type(msg) ~= "string" then
    return false
  end

  for _, pattern in ipairs(popup_patterns) do
    if msg:lower():match(pattern:lower()) then
      return true
    end
  end

  return false
end

-- Create a non-blocking popup notification
local function create_popup_notification(msg, level)
  -- Only show popup if nvim-notify is available
  local has_notify, notify = pcall(require, "notify")
  if has_notify then
    notify(msg, level, {
      title = "Avante Warning",
      timeout = 3000, -- 3 seconds
      render = "compact", -- Use compact rendering
      stages = "fade", -- Fade in/out animation
      on_open = function(win)
        -- Make the popup non-focusable
        vim.api.nvim_win_set_config(win, { focusable = false })
      end,
    })
  else
    -- Fallback to a simple echo that doesn't block
    vim.schedule(function()
      vim.api.nvim_echo({{ "[Avante] " .. msg, "WarningMsg" }}, false, {})
    end)
  end
end

-- Custom notify function that handles error suppression
local function custom_notify(msg, level, opts)
  -- Convert level to number if it's a string
  if type(level) == "string" then
    local levels = {
      ["ERROR"] = vim.log.levels.ERROR,
      ["WARN"] = vim.log.levels.WARN,
      ["INFO"] = vim.log.levels.INFO,
      ["DEBUG"] = vim.log.levels.DEBUG,
    }
    level = levels[level:upper()] or vim.log.levels.INFO
  end
  level = level or vim.log.levels.INFO

  -- Check if message should be completely suppressed
  if should_suppress(msg) then
    suppressed_count = suppressed_count + 1
    last_suppressed_time = vim.loop.now()

    -- Optionally log suppressed messages to a file for debugging
    if vim.g.avante_debug_log then
      local log_file = vim.fn.stdpath("cache") .. "/avante_suppressed.log"
      local file = io.open(log_file, "a")
      if file then
        file:write(os.date("%Y-%m-%d %H:%M:%S") .. " [SUPPRESSED] " .. msg .. "\n")
        file:close()
      end
    end

    return
  end

  -- Check if message should use non-blocking popup
  if should_use_popup(msg) and (level == vim.log.levels.WARN or level == vim.log.levels.ERROR) then
    create_popup_notification(msg, level)
    return
  end

  -- For all other messages, use the original notify function
  return original_notify(msg, level, opts)
end

-- Function to show suppressed message count
local function show_suppressed_count()
  if suppressed_count > 0 then
    local time_diff = (vim.loop.now() - last_suppressed_time) / 1000 -- Convert to seconds
    local msg = string.format(
      "Suppressed %d Avante tokenizer warnings (last: %.1fs ago)",
      suppressed_count,
      time_diff
    )
    vim.notify(msg, vim.log.levels.INFO, { title = "Error Suppression" })
  else
    vim.notify("No messages have been suppressed", vim.log.levels.INFO, { title = "Error Suppression" })
  end
end

-- Function to reset suppressed count
local function reset_suppressed_count()
  suppressed_count = 0
  last_suppressed_time = 0
  vim.notify("Suppressed message count reset", vim.log.levels.INFO, { title = "Error Suppression" })
end

-- Function to temporarily disable suppression
local function disable_suppression(duration)
  duration = duration or 60 -- Default 60 seconds

  -- Restore original notify
  vim.notify = original_notify

  vim.notify(
    string.format("Error suppression disabled for %d seconds", duration),
    vim.log.levels.INFO,
    { title = "Error Suppression" }
  )

  -- Re-enable after duration
  vim.defer_fn(function()
    vim.notify = custom_notify
    vim.notify(
      "Error suppression re-enabled",
      vim.log.levels.INFO,
      { title = "Error Suppression" }
    )
  end, duration * 1000)
end

-- Function to add custom suppression patterns
local function add_suppression_pattern(pattern)
  table.insert(suppressed_patterns, pattern)
  vim.notify(
    "Added suppression pattern: " .. pattern,
    vim.log.levels.INFO,
    { title = "Error Suppression" }
  )
end

-- Setup function to initialize error suppression
function M.setup(opts)
  opts = opts or {}

  -- Allow customization of suppressed patterns
  if opts.additional_patterns then
    for _, pattern in ipairs(opts.additional_patterns) do
      table.insert(suppressed_patterns, pattern)
    end
  end

  -- Allow customization of popup patterns
  if opts.additional_popup_patterns then
    for _, pattern in ipairs(opts.additional_popup_patterns) do
      table.insert(popup_patterns, pattern)
    end
  end

  -- Enable debug logging if requested
  if opts.debug_log then
    vim.g.avante_debug_log = true
  end

  -- Replace vim.notify with our custom function
  vim.notify = custom_notify

  -- Create user commands for managing suppression
  vim.api.nvim_create_user_command("ErrorSuppressionStatus", show_suppressed_count, {
    desc = "Show count of suppressed error messages"
  })

  vim.api.nvim_create_user_command("ErrorSuppressionReset", reset_suppressed_count, {
    desc = "Reset suppressed message count"
  })

  vim.api.nvim_create_user_command("ErrorSuppressionDisable", function(args)
    local duration = tonumber(args.args) or 60
    disable_suppression(duration)
  end, {
    desc = "Temporarily disable error suppression",
    nargs = "?"
  })

  vim.api.nvim_create_user_command("ErrorSuppressionAdd", function(args)
    if args.args and args.args ~= "" then
      add_suppression_pattern(args.args)
    else
      vim.notify("Please provide a pattern to suppress", vim.log.levels.ERROR)
    end
  end, {
    desc = "Add a new error suppression pattern",
    nargs = 1
  })

  -- Show periodic summary of suppressed messages (optional)
  if opts.show_periodic_summary then
    local timer = vim.loop.new_timer()
    timer:start(300000, 300000, vim.schedule_wrap(function() -- Every 5 minutes
      if suppressed_count > 0 then
        local msg = string.format("Suppressed %d Avante warnings in the last period", suppressed_count)
        create_popup_notification(msg, vim.log.levels.INFO)
        suppressed_count = 0
      end
    end))
  end
end

-- Function to restore original notify (for cleanup)
function M.restore_original_notify()
  vim.notify = original_notify
end

-- Export functions for manual use
M.show_suppressed_count = show_suppressed_count
M.reset_suppressed_count = reset_suppressed_count
M.disable_suppression = disable_suppression
M.add_suppression_pattern = add_suppression_pattern
M.create_popup_notification = create_popup_notification

return M

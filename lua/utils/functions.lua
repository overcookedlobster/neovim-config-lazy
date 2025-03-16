-- ~/.config/nvim/lua/utils/functions.lua
-- General helper functions

local M = {}

-- Helper function to check if a file exists
M.file_exists = function(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

-- Helper function to get the content of a file
M.read_file = function(file)
  if not M.file_exists(file) then return nil end
  local f = io.open(file, "rb")
  local content = f:read("*all")
  f:close()
  return content
end

-- Helper function to write to a file
M.write_file = function(file, content)
  local f = io.open(file, "w")
  if not f then return false end
  f:write(content)
  f:close()
  return true
end

-- Helper function to find the root directory of a project
M.find_project_root = function(markers)
  markers = markers or {'.git', '.root', 'Makefile', 'package.json'}

  local current_path = vim.fn.expand('%:p:h')
  local path = current_path

  -- From the current directory, search upwards for a project marker
  while path ~= '/' do
    for _, marker in ipairs(markers) do
      if vim.fn.filereadable(path .. '/' .. marker) == 1 or
         vim.fn.isdirectory(path .. '/' .. marker) == 1 then
        return path
      end
    end
    path = vim.fn.fnamemodify(path, ':h')
  end

  -- If no root is found, return the current directory
  return current_path
end

-- Function to open a floating window with a file
M.open_in_float = function(file, opts)
  opts = opts or {}
  local width = opts.width or 0.8
  local height = opts.height or 0.8

  -- Calculate dimensions
  local win_width = math.floor(vim.o.columns * width)
  local win_height = math.floor(vim.o.lines * height)
  local row = math.floor((vim.o.lines - win_height) / 2)
  local col = math.floor((vim.o.columns - win_width) / 2)

  -- Create a buffer and window
  local buf = vim.api.nvim_create_buf(false, true)

  -- Set buffer options
  if opts.filetype then
    vim.api.nvim_buf_set_option(buf, 'filetype', opts.filetype)
  end

  -- If file exists, read its content
  if file and M.file_exists(file) then
    local content = M.read_file(file)
    if content then
      content = vim.split(content, '\n')
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
    end
  end

  -- Create the window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
  })

  -- Set window options
  if opts.title then
    vim.api.nvim_win_set_option(win, 'winblend', 0)
    vim.api.nvim_win_set_option(win, 'title', opts.title)
    vim.api.nvim_win_set_option(win, 'titlelen', string.len(opts.title) + 10)
  end

  -- Return buffer and window IDs
  return buf, win
end

-- Function to center a string for title display
M.center = function(str)
  local width = vim.api.nvim_get_option("columns")
  local shift = math.floor(width / 2) - math.floor(string.len(str) / 2)
  return string.rep(' ', shift) .. str
end

-- Function to right-justify a string
M.right_justify = function(str)
  local width = vim.api.nvim_get_option("columns")
  local shift = width - string.len(str)
  return string.rep(' ', shift) .. str
end

-- Function to create directory if it doesn't exist
M.ensure_directory = function(path)
  if vim.fn.isdirectory(path) == 0 then
    vim.fn.mkdir(path, "p")
    return true
  end
  return false
end

-- Function to get current timestamp
M.get_timestamp = function(format)
  format = format or "%Y-%m-%d %H:%M:%S"
  return os.date(format)
end

-- Function to sanitize a string for use as a filename
M.sanitize_filename = function(str)
  -- Replace non-alphanumeric characters with underscores
  local sanitized = str:gsub("[^%w%-_.]", "_")
  -- Replace multiple underscores with a single one
  sanitized = sanitized:gsub("_+", "_")
  -- Trim leading/trailing underscores
  sanitized = sanitized:gsub("^_+", ""):gsub("_+$", "")
  return sanitized
end

-- Function to show cheatsheet for current filetype
M.open_cheatsheet = function()
  local filetype = vim.bo.filetype
  local config_path = vim.fn.stdpath('config')
  local cheatsheet_path = string.format("%s/cheatsheets/%s_cheatsheet.md", config_path, filetype)

  if M.file_exists(cheatsheet_path) then
    M.open_in_float(cheatsheet_path, {
      title = filetype:upper() .. " Cheatsheet",
      filetype = "markdown",
      width = 0.9,
      height = 0.9,
    })

    -- Set up keymaps for the cheatsheet window
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':close<CR>', {noremap = true, silent = true})
  else
    vim.notify(string.format("No cheatsheet found for filetype: %s", filetype), vim.log.levels.WARN)
  end
end

-- Function to open Git cheatsheet
M.git_cheatsheet = function()
  local config_path = vim.fn.stdpath('config')
  local cheatsheet_path = string.format("%s/cheatsheets/git_cheatsheet.md", config_path)

  if M.file_exists(cheatsheet_path) then
    M.open_in_float(cheatsheet_path, {
      title = "Git Cheatsheet",
      filetype = "markdown",
      width = 0.9,
      height = 0.9,
    })

    -- Set up keymaps for the cheatsheet window
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':close<CR>', {noremap = true, silent = true})
  else
    vim.notify("Git cheatsheet not found", vim.log.levels.WARN)
  end
end

-- Set up the module
function M.setup()
  -- Create commands for cheatsheets
  vim.api.nvim_create_user_command('Cheatsheet', function()
    M.open_cheatsheet()
  end, {})

  vim.api.nvim_create_user_command('GitCheatsheet', function()
    M.git_cheatsheet()
  end, {})

  -- Set up keymaps
  vim.keymap.set('n', '<leader>qq', M.open_cheatsheet,
    {noremap = true, silent = true, desc = "Open filetype cheatsheet"})
  vim.keymap.set('n', '<leader>qg', M.git_cheatsheet,
    {noremap = true, silent = true, desc = "Open Git cheatsheet"})
end

-- Return the module
return M

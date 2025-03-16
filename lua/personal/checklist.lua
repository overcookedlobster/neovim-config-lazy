-- ~/.config/nvim/lua/personal/checklist.lua
-- Checklist functionality

local M = {}

-- Configuration
M.config = {
  debug = false,
  checklist_dir = vim.fn.stdpath('config') .. "/checklists",
  pdf_dir = vim.fn.stdpath('config') .. '/books',
  pdf_viewer = 'zathura',
}

-- Helper function for debug printing
local function debug_print(message)
  if M.config.debug then
    vim.notify(message, vim.log.levels.DEBUG)
  end
end

-- Function to save the current buffer to file
local function save_buffer_to_file()
  local bufnr = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local f = io.open(filepath, "w")
  if f then
    f:write(table.concat(lines, "\n"))
    f:close()
    debug_print("Saved changes to " .. filepath)
    return true
  else
    vim.notify("Failed to write to file: " .. filepath, vim.log.levels.ERROR)
    return false
  end
end

-- Function to parse markdown and extract page offset
local function parse_markdown_and_get_offset(markdown_path)
  local page_offset = 0

  local f = io.open(markdown_path, "r")
  if not f then
    debug_print("Failed to open file: " .. markdown_path)
    return page_offset
  end

  for line in f:lines() do
    local offset = line:match('^Page Offset: (.+)$')
    if offset then
      page_offset = tonumber(offset) or 0
      break
    end
  end

  f:close()
  debug_print("Extracted page offset: " .. page_offset)
  return page_offset
end

-- Function to create a floating window
local function create_float()
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local win_id = vim.api.nvim_open_win(0, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = 'minimal',
    border = 'rounded',
  })
  return win_id
end

-- Function to safely edit a file, handling swap files
local function safe_edit(file_path)
  local ok, err = pcall(vim.cmd, "edit " .. file_path)
  if not ok then
    if err:match("E325") then
      -- Swap file exists, ask user what to do
      vim.notify("Swap file exists for " .. file_path)
      local choice = vim.fn.input("(E)dit anyway, (R)ecover, (Q)uit: ")
      if choice:lower() == "e" then
        vim.cmd("edit! " .. file_path)
      elseif choice:lower() == "r" then
        vim.cmd("recover " .. file_path)
      else
        vim.notify("Aborted opening the checklist.")
        return false
      end
    else
      -- Some other error occurred
      vim.notify("Error opening file: " .. err, vim.log.levels.ERROR)
      return false
    end
  end
  return true
end

-- Function to display checklist in a floating window
local function display_checklist(markdown_path)
  local bufnr = vim.fn.bufnr(markdown_path)
  local win_id = create_float()

  if bufnr == -1 then
    -- If the buffer doesn't exist, create it
    if not safe_edit(markdown_path) then
      return nil, nil
    end
    bufnr = vim.fn.bufnr(markdown_path)
  else
    -- If the buffer exists, set it as the current buffer for the new window
    vim.api.nvim_win_set_buf(win_id, bufnr)
  end

  -- Ensure the buffer is loaded
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    vim.api.nvim_buf_set_option(bufnr, 'buftype', '')
    vim.api.nvim_command('buffer ' .. bufnr)
  end

  -- Set up keybindings for the floating window
  local opts = { noremap = true, silent = true }
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<CR>', ':lua require("personal.checklist").toggle_item()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', ':q<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>p', ':lua require("personal.checklist").open_pdf()<CR>', opts)

  -- Set filetype to markdown
  vim.api.nvim_buf_set_option(bufnr, 'filetype', 'markdown')

  return bufnr, win_id
end

-- Function to toggle checklist items
function M.toggle_item()
  local line = vim.api.nvim_get_current_line()
  local new_line

  if line:match('^%s*- %[ %]') then
    new_line = line:gsub('^(%s*- )%[ %]', '%1[x]')
  elseif line:match('^%s*- %[x%]') then
    new_line = line:gsub('^(%s*- )%[x%]', '%1[ ]')
  end

  if new_line then
    vim.api.nvim_set_current_line(new_line)
    save_buffer_to_file()
  end
end

-- Function to save the checklist
function M.save_checklist()
  save_buffer_to_file()
  vim.api.nvim_command('setlocal nomodified')
end

-- Function to close the checklist
function M.close_checklist()
  save_buffer_to_file()
  vim.api.nvim_command('q')
end

-- Function to open PDF at the correct page
function M.open_pdf()
  local markdown_path = vim.api.nvim_buf_get_name(0)
  local pdf_name = vim.fn.fnamemodify(markdown_path, ':t:r') .. '.pdf'
  local pdf_path = M.config.pdf_dir .. '/' .. pdf_name

  -- Check if the PDF file exists
  if vim.fn.filereadable(pdf_path) == 0 then
    vim.notify("Error: PDF file not found: " .. pdf_path, vim.log.levels.ERROR)
    return
  end

  -- Get current line number
  local current_line = vim.api.nvim_win_get_cursor(0)[1]

  -- Parse the markdown file to get the page offset
  local page_offset = parse_markdown_and_get_offset(markdown_path)

  -- Find the nearest previous line with a page number
  local page_number = 1
  for i = current_line, 1, -1 do
    local line = vim.api.nvim_buf_get_lines(0, i-1, i, false)[1]
    local found_page = line:match("%(Page (%d+)%)")
    if found_page then
      page_number = tonumber(found_page)
      break
    end
  end

  -- Apply the page offset
  local adjusted_page = page_number + page_offset

  debug_print("Opening PDF: " .. pdf_path .. " at page " .. adjusted_page)
  vim.fn.system(M.config.pdf_viewer .. ' --page=' .. adjusted_page .. ' "' .. pdf_path .. '" &')
end

-- Function to list and select checklists
function M.list_checklists()
  local checklists = vim.fn.globpath(M.config.checklist_dir, '*.md', false, true)

  if #checklists == 0 then
    vim.notify("No checklists found in " .. M.config.checklist_dir, vim.log.levels.WARN)
    return
  end

  vim.ui.select(checklists, {
    prompt = 'Select a checklist:',
    format_item = function(item)
      return vim.fn.fnamemodify(item, ':t:r')
    end,
  }, function(choice)
    if choice then
      display_checklist(choice)
    end
  end)
end

-- Function to generate directory structure from a checklist
function M.generate_directory_structure()
  -- Ask the user to select a checklist
  local checklists = vim.fn.globpath(M.config.checklist_dir, '*.md', false, true)

  if #checklists == 0 then
    vim.notify("No checklists found in " .. M.config.checklist_dir, vim.log.levels.WARN)
    return
  end

  vim.ui.select(checklists, {
    prompt = 'Select a checklist to generate directory structure:',
    format_item = function(item)
      return vim.fn.fnamemodify(item, ':t:r')
    end,
  }, function(checklist_path)
    if not checklist_path then return end

    -- Get project name from checklist filename
    local project_name = vim.fn.fnamemodify(checklist_path, ':t:r')

    -- Ask for projects directory
    local projects_dir = vim.fn.input("Projects directory: ", vim.fn.expand('~/projects'), "dir")
    if projects_dir == "" then return end

    -- Create the base project directory
    local base_path = projects_dir .. '/' .. project_name
    if vim.fn.isdirectory(base_path) == 1 then
      local choice = vim.fn.input("Project directory already exists. Overwrite? [y/N] ")
      if choice:lower() ~= "y" then
        vim.notify("Operation cancelled.")
        return
      end
    end

    vim.fn.mkdir(base_path, "p")

    -- Helper function to sanitize folder names
    local function sanitize_name(name)
      return name:gsub("%s+", "_"):gsub("[^%w_-]", "")
    end

    -- Read the checklist file
    local f = io.open(checklist_path, "r")
    if not f then
      vim.notify("Failed to open checklist file: " .. checklist_path, vim.log.levels.ERROR)
      return
    end

    local current_chapter = nil

    for line in f:lines() do
      if line:match("^%- %[.?%] %*%*Chapter %d+:") then
        -- Chapter line
        local chapter_name = line:match("%*%*(.-)%*%*")
        current_chapter = sanitize_name(chapter_name)
        local chapter_path = base_path .. "/" .. current_chapter
        vim.fn.mkdir(chapter_path, "p")

        -- Create subfolders
        vim.fn.mkdir(chapter_path .. "/concepts", "p")
        vim.fn.mkdir(chapter_path .. "/examples", "p")
        vim.fn.mkdir(chapter_path .. "/exercises", "p")
      elseif line:match("^%s+%- %[.?%] %d+%.%d+") and current_chapter then
        -- Section line
        local section_name = line:match("%d+%.%d+%s+(.-) %(")
        if section_name then
          local section_path = base_path .. "/" .. current_chapter .. "/concepts/" .. sanitize_name(section_name)
          vim.fn.mkdir(section_path, "p")
        end
      end
    end

    f:close()

    vim.notify("Folder structure created successfully in '" .. base_path .. "'")
  end)
end

-- Function to toggle debugging
function M.toggle_debug()
  M.config.debug = not M.config.debug
  vim.notify("Checklist debugging " .. (M.config.debug and "enabled" or "disabled"))
end

-- Setup function
function M.setup()
  -- Ensure the checklist directory exists
  if vim.fn.isdirectory(M.config.checklist_dir) == 0 then
    vim.fn.mkdir(M.config.checklist_dir, "p")
  end

  -- Ensure the PDF directory exists
  if vim.fn.isdirectory(M.config.pdf_dir) == 0 then
    vim.fn.mkdir(M.config.pdf_dir, "p")
  end

  -- Create user commands
  vim.api.nvim_create_user_command('ChecklistOpen', function()
    M.list_checklists()
  end, {})

  vim.api.nvim_create_user_command('ChecklistGenerate', function()
    M.generate_directory_structure()
  end, {})

  vim.api.nvim_create_user_command('ChecklistDebug', function()
    M.toggle_debug()
  end, {})

  -- Set up keymaps
  vim.keymap.set('n', '<leader>cl', M.list_checklists,
    {noremap = true, silent = true, desc = "List checklists"})

  vim.keymap.set('n', '<leader>cg', M.generate_directory_structure,
    {noremap = true, silent = true, desc = "Generate directory structure from checklist"})
end

-- Return the module
return M

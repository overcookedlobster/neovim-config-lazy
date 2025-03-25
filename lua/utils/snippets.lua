-- Create this file at ~/.config/nvim/lua/utils/snippets.lua

local M = {}

-- Register to store visual selections
M.visual_reg = ""

-- Function to capture visual selection and store it in our custom register
function M.capture_visual_selection()
  -- Get the visual selection
  local visual_start = vim.fn.getpos("'<")
  local visual_end = vim.fn.getpos("'>")
  local lines = vim.fn.getline(visual_start[2], visual_end[2])

  -- Handle multi-line selections
  if #lines > 1 then
    lines[1] = string.sub(lines[1], visual_start[3], -1)
    lines[#lines] = string.sub(lines[#lines], 1, visual_end[3])
  else
    lines[1] = string.sub(lines[1], visual_start[3], visual_end[3])
  end

  -- Store the selection in our custom register
  M.visual_reg = table.concat(lines, "\n")

  -- Also store it in the "+ register for convenience
  vim.fn.setreg("+", M.visual_reg)

  return M.visual_reg
end

-- Function to handle bracket closing and content insertion
function M.handle_bracket(opening, closing)
  if vim.fn.mode() ~= 'i' then return end

  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line()
  local column = cursor_pos[2]

  -- Insert the opening bracket
  vim.api.nvim_set_current_line(
    line:sub(1, column) .. opening .. M.visual_reg .. closing .. line:sub(column + 1)
  )

  -- Move cursor after the content
  local new_pos = column + #opening + #M.visual_reg
  vim.api.nvim_win_set_cursor(0, {cursor_pos[1], new_pos})
end

-- Setup function to initialize keymaps and autocmds
function M.setup()
  -- Set up mapping for Tab in visual mode to capture selection
  vim.api.nvim_set_keymap('v', '<Tab>',
    [[<Esc>:lua require('utils.snippets').capture_visual_selection()<CR>gvi<Esc>]],
    {noremap = true, silent = true})

  -- Set up mappings for auto-closing brackets with content insertion
  for _, pair in ipairs({
    {'(', ')'},
    {'[', ']'},
    {'{', '}'},
    {'<', '>'},
    {'"', '"'},
    {"'", "'"},
  }) do
    vim.api.nvim_set_keymap('i', pair[1],
      string.format('<Cmd>lua require("utils.snippets").handle_bracket("%s", "%s")<CR>', pair[1], pair[2]),
      {noremap = true, silent = true})
  end

  -- Print a message to confirm setup is complete
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      vim.notify("Snippet utilities loaded")
    end,
    once = true
  })
end

return M

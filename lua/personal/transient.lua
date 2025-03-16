-- ~/.config/nvim/lua/personal/transient.lua
-- Transient notes system

local M = {}

-- Default configuration
M.config = {
    persistent_buffer_name = "PersistentNotes",
    temporary_buffer_name = "TemporaryNotes",
    random_buffer_name = "RandomNotes",
    file_type = "markdown",
    auto_save = true,
    auto_save_interval = 300, -- 5 minutes
    width = 0.5,  -- 50% of screen width
    height = 0.5, -- 50% of screen height
    notes_dir = vim.fn.expand('~/.local/share/nvim/transient_notes/'), -- Default directory for notes
    random_notes_dir = vim.fn.stdpath('data') .. '/random_notes/', -- Directory for random notes
}

-- Get helper functions
local utils = require("utils.functions")

-- Get the current project name (based on the current working directory)
local function get_project_name()
    local cwd = vim.fn.getcwd()
    return vim.fn.fnamemodify(cwd, ':t')
end

-- Get the full path for the persistent notes file for the current project
local function get_persistent_notes_path()
    local project_name = get_project_name()
    return M.config.notes_dir .. project_name .. '_notes.md'
end

-- Load persisted content from file
function M.load_persisted_content()
    local file_path = get_persistent_notes_path()
    local content = utils.read_file(file_path)
    if content then
        return vim.split(content, "\n")
    end
    return nil
end

-- New function for random notes
function M.open_random_note()
    local random_note_path = M.config.random_notes_dir .. os.date("%Y%m%d%H%M%S") .. ".md"

    -- Ensure the random notes directory exists
    utils.ensure_directory(M.config.random_notes_dir)

    -- Create a new buffer for the random note
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, random_note_path)
    vim.api.nvim_buf_set_option(buf, 'filetype', M.config.file_type)

    -- Calculate dimensions
    local width = math.floor(vim.o.columns * M.config.width)
    local height = math.floor(vim.o.lines * M.config.height)
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2)

    -- Open the buffer in a popup window
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        col = col,
        row = row,
        style = 'minimal',
        border = 'rounded'
    })

    -- Set window options
    vim.api.nvim_win_set_option(win, 'winblend', 15)
    vim.api.nvim_win_set_option(win, 'cursorline', true)

    -- Set buffer options
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    vim.api.nvim_buf_set_option(buf, 'buftype', '')  -- Allow saving
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'hide')

    -- Add a title and timestamp
    local title = utils.center("Random Note")
    local timestamp = utils.right_justify(os.date("%Y-%m-%d %H:%M:%S"))
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {title, timestamp, "", ""})
    vim.api.nvim_buf_add_highlight(buf, -1, 'Title', 0, 0, -1)
    vim.api.nvim_buf_add_highlight(buf, -1, 'Comment', 1, 0, -1)

    -- Set up autocommand to save the random note on buffer write
    vim.cmd(string.format([[
        augroup RandomNoteSave
            autocmd!
            autocmd BufWritePost <buffer=%d> silent! write %s
        augroup END
    ]], buf, random_note_path))
end

-- Save the persistent buffer content to a file
function M.save_persistent_buffer()
    local buf = vim.fn.bufnr(M.config.persistent_buffer_name)
    if buf ~= -1 then
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local file_path = get_persistent_notes_path()
        if utils.write_file(file_path, table.concat(lines, "\n")) then
            vim.notify("Persistent notes saved to " .. file_path)
        else
            vim.notify("Error: Could not save persistent notes.", vim.log.levels.ERROR)
        end
    end
end

-- Open a notes buffer (persistent or temporary)
function M.open_notes_buffer(persistent)
    local buffer_name = persistent and M.config.persistent_buffer_name or M.config.temporary_buffer_name
    local file_path = persistent and get_persistent_notes_path() or buffer_name

    -- Check if a buffer with this file path already exists
    local buf = vim.fn.bufnr(file_path)

    if buf == -1 or not vim.api.nvim_buf_is_valid(buf) then
        -- If the buffer doesn't exist or is invalid, create a new one
        buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_name(buf, file_path)
        vim.api.nvim_buf_set_option(buf, 'filetype', M.config.file_type)

        -- Load persisted content if it's the persistent buffer
        if persistent then
            local content = M.load_persisted_content()
            if content then
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
            end
            -- Set the buffer as unmodified after loading content
            vim.api.nvim_buf_set_option(buf, 'modified', false)
        end
    end

    -- Calculate dimensions
    local width = math.floor(vim.o.columns * M.config.width)
    local height = math.floor(vim.o.lines * M.config.height)
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2)

    -- Open the buffer in a popup window
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        col = col,
        row = row,
        style = 'minimal',
        border = 'rounded'
    })

    -- Set window options
    vim.api.nvim_win_set_option(win, 'winblend', 15)
    vim.api.nvim_win_set_option(win, 'cursorline', true)

    -- Set buffer options
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    vim.api.nvim_buf_set_option(buf, 'buftype', '')  -- Allow saving
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'hide')

    -- Add a title and timestamp if the buffer is empty
    if vim.api.nvim_buf_line_count(buf) == 1 and vim.api.nvim_buf_get_lines(buf, 0, -1, false)[1] == "" then
        local title = utils.center(persistent and "Persistent Notes (" .. get_project_name() .. ")" or "Temporary Notes")
        local timestamp = utils.right_justify(os.date("%Y-%m-%d %H:%M:%S"))
        local file_info = persistent and ("File: " .. file_path) or "Temporary buffer (not saved)"
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, {title, timestamp, file_info, ""})
        vim.api.nvim_buf_add_highlight(buf, -1, 'Title', 0, 0, -1)
        vim.api.nvim_buf_add_highlight(buf, -1, 'Comment', 1, 0, -1)
        vim.api.nvim_buf_add_highlight(buf, -1, 'Comment', 2, 0, -1)
    end
end

-- New function to grep random notes using Telescope
function M.grep_random_notes()
    local ok, telescope = pcall(require, 'telescope.builtin')
    if not ok then
        vim.notify("Telescope is not installed. Please install telescope.nvim to use this feature.", vim.log.levels.ERROR)
        return
    end

    telescope.live_grep({
        prompt_title = "Search Random Notes",
        search_dirs = {M.config.random_notes_dir},
        path_display = {"smart"},
    })
end

-- Global search functionality
function M.global_search_notes()
    local search_term = vim.fn.input("Search for: ")
    if search_term == "" then return end

    local results = {}
    local files = vim.fn.glob(M.config.notes_dir .. '*_notes.md', 0, 1)
    for _, file in ipairs(files) do
        local content = utils.read_file(file)
        if content then
            for line in content:gmatch("[^\r\n]+") do
                if line:lower():find(search_term:lower(), 1, true) then
                    table.insert(results, {filename = file, line = line})
                end
            end
        end
    end

    if #results == 0 then
        vim.notify("No results found.")
        return
    end

    -- Create a new buffer for search results
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(buf, 'swapfile', false)
    vim.api.nvim_buf_set_name(buf, "Search Results")

    -- Populate the buffer with search results
    local lines = {"Search results for: " .. search_term, ""}
    for _, result in ipairs(results) do
        table.insert(lines, result.filename .. ":")
        table.insert(lines, "    " .. result.line)
        table.insert(lines, "")
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- Open the buffer in a new window
    vim.cmd('split')
    vim.api.nvim_win_set_buf(0, buf)
end

-- Clipboard integration
function M.copy_to_clipboard()
    local buf = vim.api.nvim_get_current_buf()
    local start_line, end_line

    if vim.fn.mode() == 'v' or vim.fn.mode() == 'V' then
        start_line = vim.fn.line("'<")
        end_line = vim.fn.line("'>")
    else
        start_line = 1
        end_line = -1
    end

    local lines = vim.api.nvim_buf_get_lines(buf, start_line - 1, end_line, false)
    local content = table.concat(lines, "\n")
    vim.fn.setreg('+', content)
    vim.notify("Copied to clipboard.")
end

-- Setup function
function M.setup(opts)
    -- Merge user options with defaults
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})

    -- Ensure the notes directories exist
    utils.ensure_directory(M.config.notes_dir)
    utils.ensure_directory(M.config.random_notes_dir)

    -- Create commands
    vim.api.nvim_create_user_command('PersistentNotes', function()
        M.open_notes_buffer(true)
    end, {})

    vim.api.nvim_create_user_command('TemporaryNotes', function()
        M.open_notes_buffer(false)
    end, {})

    vim.api.nvim_create_user_command('RandomNote', function()
        M.open_random_note()
    end, {})

    vim.api.nvim_create_user_command('SavePersistentNotes', function()
        M.save_persistent_buffer()
    end, {})

    vim.api.nvim_create_user_command('SearchNotes', function()
        M.global_search_notes()
    end, {})

    vim.api.nvim_create_user_command('CopyNotesToClipboard', function()
        M.copy_to_clipboard()
    end, {})

    vim.api.nvim_create_user_command('GrepRandomNotes', function()
        M.grep_random_notes()
    end, {})

    -- Set up auto-save for persistent notes if enabled
    if M.config.auto_save then
        vim.fn.timer_start(M.config.auto_save_interval * 1000, function()
            M.save_persistent_buffer()
        end, {["repeat"] = -1})
    end

    -- Set up keybindings
    vim.keymap.set('n', '<leader>pn', ':PersistentNotes<CR>',
        {noremap = true, silent = true, desc = "Open persistent notes"})
    vim.keymap.set('n', '<leader>tn', ':TemporaryNotes<CR>',
        {noremap = true, silent = true, desc = "Open temporary notes"})
    vim.keymap.set('n', '<leader>rn', ':RandomNote<CR>',
        {noremap = true, silent = true, desc = "Create random note"})
    vim.keymap.set('n', '<leader>ns', ':SearchNotes<CR>',
        {noremap = true, silent = true, desc = "Search notes"})
    vim.keymap.set('n', '<leader>nc', ':CopyNotesToClipboard<CR>',
        {noremap = true, silent = true, desc = "Copy notes to clipboard"})
    vim.keymap.set('v', '<leader>nc', ':CopyNotesToClipboard<CR>',
        {noremap = true, silent = true, desc = "Copy selected notes to clipboard"})
    vim.keymap.set('n', '<leader>ng', ':GrepRandomNotes<CR>',
        {noremap = true, silent = true, desc = "Grep random notes"})

    -- Enable syntax highlighting for markdown in the notes buffers
    vim.cmd([[
        augroup TransientNotesSyntax
            autocmd!
            autocmd FileType markdown setlocal syntax=markdown
        augroup END
    ]])

    -- Add autocommand to save persistent notes on buffer write
    vim.cmd([[
        augroup PersistentNotesSave
            autocmd!
            autocmd BufWritePost PersistentNotes lua require('personal.transient').save_persistent_buffer()
        augroup END
    ]])
end

-- Return the module
return M

-- ~/.config/nvim/lua/config/keymaps.lua
-- Global keymaps

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Helper function for key mapping with description
local function desc_map(mode, lhs, rhs, description, map_opts)
  local merged_opts = vim.tbl_extend("force", 
    opts, 
    map_opts or {}, 
    { desc = description }
  )
  map(mode, lhs, rhs, merged_opts)
end

-- Window navigation
desc_map("n", "<C-h>", "<C-w>h", "Move to left window")
desc_map("n", "<C-j>", "<C-w>j", "Move to bottom window")
desc_map("n", "<C-k>", "<C-w>k", "Move to top window")
desc_map("n", "<C-l>", "<C-w>l", "Move to right window")

-- Terminal window navigation
desc_map("t", "<C-h>", "<C-\\><C-n><C-w>h", "Terminal: Move to left window")
desc_map("t", "<C-j>", "<C-\\><C-n><C-w>j", "Terminal: Move to bottom window")
desc_map("t", "<C-k>", "<C-\\><C-n><C-w>k", "Terminal: Move to top window")
desc_map("t", "<Esc>", "<C-\\><C-n>", "Terminal: Enter normal mode")

-- Tab management
desc_map("n", "<TAB>", ":tabnext<CR>", "Go to next tab")
desc_map("n", "<S-TAB>", ":tabprev<CR>", "Go to previous tab")
desc_map("n", "<C-t>", ":tabnew<CR>", "Create new tab")
desc_map("n", "<Leader>tn", ":tabnew<CR>", "Tab: Create new")
desc_map("n", "<Leader>tc", ":tabclose<CR>", "Tab: Close")
desc_map("n", "<Leader>l", ":tabnext<CR>", "Tab: Go next")
desc_map("n", "<Leader>h", ":tabprevious<CR>", "Tab: Go previous")
desc_map("n", "<A-l>", ":tabnext<CR>", "Tab: Go next (Alt)")
desc_map("n", "<A-h>", ":tabprevious<CR>", "Tab: Go previous (Alt)")
desc_map("n", "<Leader>tm", ":tabmove<Space>", "Tab: Move position", { noremap = true })
desc_map("n", "<Leader>to", ":tabedit<Space>", "Tab: Open file", { noremap = true })

-- Quick tab access (1-9)
for i = 1, 9 do
  desc_map("n", "<Leader>" .. i, i .. "gt", "Tab: Go to #" .. i)
end

-- Buffer management
desc_map("n", "<A-j>", ":bnext<CR>", "Buffer: Go next")
desc_map("n", "<A-k>", ":bprevious<CR>", "Buffer: Go previous")
desc_map("n", "<Leader>bn", ":bnext<CR>", "Buffer: Go next")
desc_map("n", "<Leader>bp", ":bprevious<CR>", "Buffer: Go previous")
desc_map("n", "<Leader>bd", ":bdelete<CR>", "Buffer: Delete")
desc_map("n", "<Leader>ba", ":badd<Space>", "Buffer: Add new", { noremap = true })
desc_map("n", "<Leader>bl", ":buffers<CR>", "Buffer: List all")
desc_map("n", "<Leader>bw", ":write<CR>:bdelete<CR>", "Buffer: Write and close")
desc_map("n", "<Leader>bs", ":<C-u>buffers<CR>:buffer<Space>", "Buffer: Switch to")

-- Quick buffer access (Alt+1-9)
for i = 1, 9 do
  desc_map("n", "<A-" .. i .. ">", ":buffer " .. i .. "<CR>", "Buffer: Go to #" .. i)
end

-- File management
desc_map("n", "<Leader>w", ":write<CR>", "Save file")
desc_map("n", "<Leader>q", ":quit<CR>", "Quit")
desc_map("n", "<Leader>wq", ":wq<CR>", "Save and quit")
desc_map("n", "<Leader>wa", ":wall<CR>", "Save all")
desc_map("n", "<Leader>qa", ":qall<CR>", "Quit all")

-- Telescope
desc_map("n", "<Leader>ff", function() require('telescope.builtin').find_files() end, "Find Files")
desc_map("n", "<Leader>fg", function() require('telescope.builtin').live_grep() end, "Find Text")
desc_map("n", "<Leader>fb", function() require('telescope.builtin').buffers() end, "Find Buffers")
desc_map("n", "<Leader>fh", function() require('telescope.builtin').help_tags() end, "Find Help")
desc_map("n", "<Leader>fr", function() require('telescope.builtin').oldfiles() end, "Find Recent")
desc_map("n", "<Leader>fc", function() require('telescope.builtin').current_buffer_fuzzy_find() end, "Find in Current Buffer")
desc_map("n", "<Leader>fm", function() require('telescope.builtin').marks() end, "Find Marks")
desc_map("n", "<Leader>fk", function() require('telescope.builtin').keymaps() end, "Find Keymaps")
desc_map("n", "<Leader>fs", function() require('telescope.builtin').git_status() end, "Find Git Status")

-- File explorer with Ranger
desc_map("n", "<Leader>rr", ":RnvimrToggle<CR>", "Toggle Ranger file explorer")

-- Markdown preview
desc_map("n", "<Leader>m", ":MarkdownPreview<CR>", "Markdown preview")

-- Reload config
desc_map("n", "<Leader>re", ":ReloadConfig<CR>", "Reload configuration")

-- Yank message history 
desc_map("n", "<leader>ym", [[:redir @+ | :message | :redir END<CR>]], "Yank message history to clipboard")

-- Parrot AI integration
desc_map("n", "<Leader>pr", ":PrtChatResponde<CR>", "AI: Chat respond")
desc_map("n", "<Leader>prr", ":PrtChatNew<CR>", "AI: New chat")
desc_map("n", "<Leader>pp", ":PrtProvider<CR>", "AI: Provider selection")
desc_map("n", "<Leader>pa", ":PrtAsk<CR>", "AI: Ask a question")
desc_map("n", "<Leader>pf", ":PrtChatFinder<CR>", "AI: Chat finder")
desc_map("n", "<Leader>pm", ":PrtModel<CR>", "AI: Model selection")
desc_map("n", "<Leader>pt", ":PrtThinking<CR>", "AI: Enable thinking")
desc_map("n", "<Leader>pts", ":PrtThinking status<CR>", "AI: Thinking status")

-- AI Visual mode shortcuts
local function keymapOptions(desc)
  return {
    noremap = true,
    silent = true,
    nowait = true,
    desc = "AI: " .. desc,
  }
end

map("v", "<C-p>r", ":<C-u>'<,'>PrtRewrite<cr>", keymapOptions("Visual Rewrite"))
map("v", "<C-p>a", ":<C-u>'<,'>PrtAppend<cr>", keymapOptions("Visual Append (after)"))
map("v", "<C-p>b", ":<C-u>'<,'>PrtPrepend<cr>", keymapOptions("Visual Prepend (before)"))
map("v", "<C-p>i", ":<C-u>'<,'>PrtImplement<cr>", keymapOptions("Implement selection"))
map("v", "<C-p>e", ":<C-u>'<,'>PrtExplain ", keymapOptions("Explain selection"))
map("v", "<C-p>ee", ":<C-u>'<,'>PrtExplainWithContext ", keymapOptions("Explain selection with context"))

-- Personal notes
desc_map("n", "<Leader>pn", ":PersistentNotes<CR>", "Open persistent notes")
desc_map("n", "<Leader>tn", ":TemporaryNotes<CR>", "Open temporary notes")
desc_map("n", "<Leader>rn", ":RandomNote<CR>", "Create random note")
desc_map("n", "<Leader>ns", ":SearchNotes<CR>", "Search in notes")
desc_map("n", "<Leader>ng", ":GrepRandomNotes<CR>", "Grep random notes")

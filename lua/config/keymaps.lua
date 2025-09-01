-- ~/.config/nvim/lua/config/keymaps.lua
-- Global keymaps

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Helper function for key mapping with description
local function desc_map(mode, lhs, rhs, description, map_opts)
	local merged_opts = vim.tbl_extend("force", opts, map_opts or {}, { desc = description })
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
desc_map("n", "<Leader>tn", ":tabnew<CR>", "Tabs: New tab")
desc_map("n", "<Leader>tc", ":tabclose<CR>", "Tabs: Close tab")
desc_map("n", "<Leader>tl", ":tabnext<CR>", "Tabs: Next tab")
desc_map("n", "<Leader>th", ":tabprevious<CR>", "Tabs: Previous tab")
desc_map("n", "<A-l>", ":tabnext<CR>", "Tab: Go next (Alt)")
desc_map("n", "<A-h>", ":tabprevious<CR>", "Tab: Go previous (Alt)")
desc_map("n", "<Leader>tm", ":tabmove<Space>", "Tabs: Move position", { noremap = true })
desc_map("n", "<Leader>to", ":tabedit<Space>", "Tabs: Open file", { noremap = true })

-- Quick tab access (1-9)
for i = 1, 9 do
	desc_map("n", "<Leader>" .. i, i .. "gt", "Tabs: Go to #" .. i)
end

-- Buffer management
desc_map("n", "<A-j>", ":bnext<CR>", "Buffer: Go next")
desc_map("n", "<A-k>", ":bprevious<CR>", "Buffer: Go previous")
desc_map("n", "<Leader>bn", ":bnext<CR>", "Buffers: Next buffer")
desc_map("n", "<Leader>bp", ":bprevious<CR>", "Buffers: Previous buffer")
desc_map("n", "<Leader>bd", ":bdelete<CR>", "Buffers: Delete buffer")
desc_map("n", "<Leader>ba", ":badd<Space>", "Buffers: Add new buffer", { noremap = true })
desc_map("n", "<Leader>bl", ":buffers<CR>", "Buffers: List all buffers")
desc_map("n", "<Leader>bw", ":write<CR>:bdelete<CR>", "Buffers: Write and close")
desc_map("n", "<Leader>bs", ":<C-u>buffers<CR>:buffer<Space>", "Buffers: Switch to buffer")

-- Quick buffer access (Alt+1-9)
for i = 1, 9 do
	desc_map("n", "<A-" .. i .. ">", ":buffer " .. i .. "<CR>", "Buffers: Go to #" .. i)
end

-- File management
desc_map("n", "<Leader>fs", ":write<CR>", "Files: Save file")
desc_map("n", "<Leader>fq", ":quit<CR>", "Files: Quit")
desc_map("n", "<Leader>fw", ":wq<CR>", "Files: Save and quit")
desc_map("n", "<Leader>fa", ":wall<CR>", "Files: Save all")
desc_map("n", "<Leader>fA", ":qall<CR>", "Files: Quit all")

-- Search (Telescope)
desc_map("n", "<Leader>sf", function()
	require("telescope.builtin").find_files()
end, "Search: Find files")
desc_map("n", "<Leader>sg", function()
	require("telescope.builtin").live_grep()
end, "Search: Live grep")
desc_map("n", "<Leader>sb", function()
	require("telescope.builtin").buffers()
end, "Search: Find buffers")
desc_map("n", "<Leader>sh", function()
	require("telescope.builtin").help_tags()
end, "Search: Help tags")
desc_map("n", "<Leader>sr", function()
	require("telescope.builtin").oldfiles()
end, "Search: Recent files")
desc_map("n", "<Leader>sc", function()
	require("telescope.builtin").current_buffer_fuzzy_find()
end, "Search: Current buffer")
desc_map("n", "<Leader>sm", function()
	require("telescope.builtin").marks()
end, "Search: Marks")
desc_map("n", "<Leader>sk", function()
	require("telescope.builtin").keymaps()
end, "Search: Keymaps")

-- File browser (Telescope)
desc_map("n", "<Leader>ft", function()
	require("telescope").extensions.file_browser.file_browser()
end, "Files: Telescope browser")
desc_map("n", "<Leader>fp", function()
	require("telescope").extensions.file_browser.file_browser({ path = vim.fn.expand("%:p:h") })
end, "Files: Browser from current path")

-- Git operations (Telescope integration)
desc_map("n", "<Leader>gs", function()
	require("telescope.builtin").git_status()
end, "Git: Status (Telescope)")
desc_map("n", "<Leader>gc", function()
	require("telescope.builtin").git_commits()
end, "Git: Commits (Telescope)")
desc_map("n", "<Leader>gC", function()
	require("telescope.builtin").git_bcommits()
end, "Git: Buffer commits (Telescope)")
desc_map("n", "<Leader>gb", function()
	require("telescope.builtin").git_branches()
end, "Git: Branches (Telescope)")
desc_map("n", "<Leader>gf", function()
	require("telescope.builtin").git_files()
end, "Git: Files (Telescope)")
desc_map("n", "<Leader>gt", function()
	require("telescope.builtin").git_stash()
end, "Git: Stash (Telescope)")

-- Basic Git operations
desc_map("n", "<Leader>ga", ":!git add .<CR>", "Git: Add all files")
desc_map("n", "<Leader>gA", ":!git add %<CR>", "Git: Add current file")
desc_map("n", "<Leader>gci", ":!git commit<CR>", "Git: Commit (interactive)")
desc_map("n", "<Leader>gcm", ":!git commit -m \"", "Git: Commit with message", { noremap = true })
desc_map("n", "<Leader>gca", ":!git commit --amend<CR>", "Git: Amend last commit")
desc_map("n", "<Leader>gp", ":!git push<CR>", "Git: Push")
desc_map("n", "<Leader>gP", ":!git pull<CR>", "Git: Pull")
desc_map("n", "<Leader>gF", ":!git fetch<CR>", "Git: Fetch")

-- Git diff operations
desc_map("n", "<Leader>gd", ":!git diff<CR>", "Git: Diff working tree")
desc_map("n", "<Leader>gD", ":!git diff --cached<CR>", "Git: Diff staged")
desc_map("n", "<Leader>gdh", ":!git diff HEAD<CR>", "Git: Diff against HEAD")
desc_map("n", "<Leader>gdf", ":!git diff %<CR>", "Git: Diff current file")

-- Git log operations
desc_map("n", "<Leader>gl", ":!git log --oneline -10<CR>", "Git: Log (last 10)")
desc_map("n", "<Leader>gL", ":!git log --graph --oneline --all -20<CR>", "Git: Log graph")
desc_map("n", "<Leader>gla", ":!git log --oneline --all<CR>", "Git: Log all branches")
desc_map("n", "<Leader>glf", ":!git log --follow -- %<CR>", "Git: Log current file")
desc_map("n", "<Leader>glp", ":!git log -p<CR>", "Git: Log with patches")

-- Git blame and show
desc_map("n", "<Leader>gB", ":!git blame %<CR>", "Git: Blame current file")
desc_map("n", "<Leader>gsh", ":!git show<CR>", "Git: Show last commit")
desc_map("n", "<Leader>gsf", ":!git show --name-only<CR>", "Git: Show files in last commit")

-- Git branch operations
desc_map("n", "<Leader>gbn", ":!git checkout -b ", "Git: New branch", { noremap = true })
desc_map("n", "<Leader>gbc", ":!git checkout ", "Git: Checkout branch", { noremap = true })
desc_map("n", "<Leader>gbm", ":!git merge ", "Git: Merge branch", { noremap = true })
desc_map("n", "<Leader>gbd", ":!git branch -d ", "Git: Delete branch", { noremap = true })
desc_map("n", "<Leader>gbD", ":!git branch -D ", "Git: Force delete branch", { noremap = true })
desc_map("n", "<Leader>gbl", ":!git branch -l<CR>", "Git: List branches")
desc_map("n", "<Leader>gbr", ":!git branch -r<CR>", "Git: List remote branches")
desc_map("n", "<Leader>gba", ":!git branch -a<CR>", "Git: List all branches")

-- Git stash operations
desc_map("n", "<Leader>gss", ":!git stash<CR>", "Git: Stash changes")
desc_map("n", "<Leader>gsp", ":!git stash pop<CR>", "Git: Stash pop")
desc_map("n", "<Leader>gsl", ":!git stash list<CR>", "Git: Stash list")
desc_map("n", "<Leader>gsd", ":!git stash drop<CR>", "Git: Stash drop")
desc_map("n", "<Leader>gsc", ":!git stash clear<CR>", "Git: Stash clear")
desc_map("n", "<Leader>gsS", ":!git stash save \"", "Git: Stash with message", { noremap = true })
desc_map("n", "<Leader>gsa", ":!git stash apply<CR>", "Git: Stash apply")

-- Git reset operations
desc_map("n", "<Leader>grh", ":!git reset --hard HEAD<CR>", "Git: Reset hard to HEAD")
desc_map("n", "<Leader>grs", ":!git reset --soft HEAD~1<CR>", "Git: Reset soft (undo last commit)")
desc_map("n", "<Leader>grm", ":!git reset --mixed HEAD~1<CR>", "Git: Reset mixed (undo last commit, keep changes)")
desc_map("n", "<Leader>grf", ":!git reset HEAD -- %<CR>", "Git: Unstage current file")
desc_map("n", "<Leader>grF", ":!git reset HEAD<CR>", "Git: Unstage all files")

-- Git remote operations
desc_map("n", "<Leader>gRf", ":!git fetch<CR>", "Git: Fetch from remote")
desc_map("n", "<Leader>gRp", ":!git remote -v<CR>", "Git: Show remotes")
desc_map("n", "<Leader>gRu", ":!git remote update<CR>", "Git: Update remotes")
desc_map("n", "<Leader>gRa", ":!git remote add ", "Git: Add remote", { noremap = true })
desc_map("n", "<Leader>gRr", ":!git remote remove ", "Git: Remove remote", { noremap = true })

-- Git rebase operations
desc_map("n", "<Leader>gri", ":!git rebase -i HEAD~", "Git: Interactive rebase", { noremap = true })
desc_map("n", "<Leader>grc", ":!git rebase --continue<CR>", "Git: Continue rebase")
desc_map("n", "<Leader>gra", ":!git rebase --abort<CR>", "Git: Abort rebase")
desc_map("n", "<Leader>grs", ":!git rebase --skip<CR>", "Git: Skip rebase")

-- Git merge operations
desc_map("n", "<Leader>gmc", ":!git merge --continue<CR>", "Git: Continue merge")
desc_map("n", "<Leader>gma", ":!git merge --abort<CR>", "Git: Abort merge")
desc_map("n", "<Leader>gmt", ":!git mergetool<CR>", "Git: Open merge tool")

-- Git tag operations
desc_map("n", "<Leader>gtl", ":!git tag -l<CR>", "Git: List tags")
desc_map("n", "<Leader>gtn", ":!git tag ", "Git: Create tag", { noremap = true })
desc_map("n", "<Leader>gtd", ":!git tag -d ", "Git: Delete tag", { noremap = true })
desc_map("n", "<Leader>gtp", ":!git push --tags<CR>", "Git: Push tags")

-- Git worktree operations
desc_map("n", "<Leader>gwl", ":!git worktree list<CR>", "Git: List worktrees")
desc_map("n", "<Leader>gwa", ":!git worktree add ", "Git: Add worktree", { noremap = true })
desc_map("n", "<Leader>gwr", ":!git worktree remove ", "Git: Remove worktree", { noremap = true })

-- Git clean operations
desc_map("n", "<Leader>gCn", ":!git clean -n<CR>", "Git: Clean (dry run)")
desc_map("n", "<Leader>gCf", ":!git clean -f<CR>", "Git: Clean untracked files")
desc_map("n", "<Leader>gCd", ":!git clean -fd<CR>", "Git: Clean files and directories")

-- Git status and info
desc_map("n", "<Leader>gS", ":!git status<CR>", "Git: Status (terminal)")
desc_map("n", "<Leader>gi", ":!git status --porcelain<CR>", "Git: Status (porcelain)")
desc_map("n", "<Leader>gw", ":!git whatchanged<CR>", "Git: What changed")

-- Git cherry-pick operations
desc_map("n", "<Leader>gcp", ":!git cherry-pick ", "Git: Cherry-pick", { noremap = true })
desc_map("n", "<Leader>gcpc", ":!git cherry-pick --continue<CR>", "Git: Continue cherry-pick")
desc_map("n", "<Leader>gcpa", ":!git cherry-pick --abort<CR>", "Git: Abort cherry-pick")

-- File explorer with Ranger
desc_map("n", "<Leader>fr", ":RnvimrToggle<CR>", "Files: Ranger explorer")

-- Markdown preview
desc_map("n", "<Leader>cm", ":MarkdownPreview<CR>", "Code: Markdown preview")

-- Reload config
desc_map("n", "<Leader>cr", ":ReloadConfig<CR>", "Config: Reload configuration")

-- Yank message history
desc_map("n", "<leader>cy", [[:redir @+ | :message | :redir END<CR>]], "Config: Yank message history")

-- Custom ChatFind command for parrot.nvim chat files
vim.api.nvim_create_user_command("ChatFind", function()
	local fzf = require("fzf-lua")
	local chat_dir = vim.fn.stdpath("data") .. "/parrot/chats"

	-- Check if directory exists
	local stat = vim.loop.fs_stat(chat_dir)
	if not stat then
		vim.notify("Chat directory not found: " .. chat_dir, vim.log.levels.ERROR)
		return
	end

	fzf.files({
		prompt = "Parrot Chat Files> ",
		cwd = chat_dir,
		file_icons = true,
		color_icons = true,
		preview = "cat {}",
		actions = {
			["default"] = function(selected)
				if selected and #selected > 0 then
					local file_path = chat_dir .. "/" .. selected[1]
					vim.cmd("edit " .. vim.fn.fnameescape(file_path))
				end
			end,
			["ctrl-v"] = function(selected)
				if selected and #selected > 0 then
					local file_path = chat_dir .. "/" .. selected[1]
					vim.cmd("vsplit " .. vim.fn.fnameescape(file_path))
				end
			end,
			["ctrl-x"] = function(selected)
				if selected and #selected > 0 then
					local file_path = chat_dir .. "/" .. selected[1]
					vim.cmd("split " .. vim.fn.fnameescape(file_path))
				end
			end,
		},
	})
end, { desc = "Find and open parrot chat files" })

-- AI (Parrot) - Using <Leader>p to avoid conflict with Avante's <Leader>a
desc_map("n", "<Leader>pr", ":PrtChatResponde<CR>", "AI: Chat respond (Parrot)")
desc_map("n", "<Leader>pn", ":PrtChatNew<CR>", "AI: New chat (Parrot)")
desc_map("n", "<Leader>pp", ":PrtProvider<CR>", "AI: Provider selection (Parrot)")
desc_map("n", "<Leader>pa", ":PrtAsk<CR>", "AI: Ask question (Parrot)")
desc_map("n", "<Leader>pf", ":ChatFind<CR>", "AI: Find chats (Parrot)")
desc_map("n", "<Leader>pm", ":PrtModel<CR>", "AI: Model selection (Parrot)")
desc_map("n", "<Leader>pt", ":PrtThinking<CR>", "AI: Enable thinking (Parrot)")
desc_map("n", "<Leader>ps", ":PrtThinking status<CR>", "AI: Thinking status (Parrot)")

-- AI Visual mode shortcuts (Parrot) - Using <C-p> to avoid conflict with Avante
local function keymapOptions(desc)
	return {
		noremap = true,
		silent = true,
		nowait = true,
		desc = "AI: " .. desc .. " (Parrot)",
	}
end

map("v", "<C-p>r", ":<C-u>'<,'>PrtRewrite<cr>", keymapOptions("Visual Rewrite"))
map("v", "<C-p>a", ":<C-u>'<,'>PrtAppend<cr>", keymapOptions("Visual Append (after)"))
map("v", "<C-p>b", ":<C-u>'<,'>PrtPrepend<cr>", keymapOptions("Visual Prepend (before)"))
map("v", "<C-p>i", ":<C-u>'<,'>PrtImplement<cr>", keymapOptions("Implement selection"))
map("v", "<C-p>e", ":<C-u>'<,'>PrtExplain ", keymapOptions("Explain selection"))
map("v", "<C-p>c", ":<C-u>'<,'>PrtExplainWithContext ", keymapOptions("Explain selection with context"))

-- Notes
desc_map("n", "<Leader>np", ":PersistentNotes<CR>", "Notes: Open persistent notes")
desc_map("n", "<Leader>nt", ":TemporaryNotes<CR>", "Notes: Open temporary notes")
desc_map("n", "<Leader>nr", ":RandomNote<CR>", "Notes: Create random note")
desc_map("n", "<Leader>ns", ":SearchNotes<CR>", "Notes: Search in notes")
desc_map("n", "<Leader>ng", ":GrepRandomNotes<CR>", "Notes: Grep random notes")

-- Terminal (ToggleTerm)
desc_map("n", "<Leader>tt", ":ToggleTerm<CR>", "Terminal: Toggle terminal (ToggleTerm)")
desc_map("n", "<Leader>t1", ":1ToggleTerm<CR>", "Terminal: Toggle terminal 1 (ToggleTerm)")
desc_map("n", "<Leader>t2", ":2ToggleTerm<CR>", "Terminal: Toggle terminal 2 (ToggleTerm)")
desc_map("n", "<Leader>tr", ":Rooter<CR>", "Terminal: Change to project root (Rooter)")

-- Window operations
desc_map("n", "<Leader>wh", "<C-w>h", "Windows: Move to left window")
desc_map("n", "<Leader>wj", "<C-w>j", "Windows: Move to bottom window")
desc_map("n", "<Leader>wk", "<C-w>k", "Windows: Move to top window")
desc_map("n", "<Leader>wl", "<C-w>l", "Windows: Move to right window")
desc_map("n", "<Leader>ws", "<C-w>s", "Windows: Split horizontal")
desc_map("n", "<Leader>wv", "<C-w>v", "Windows: Split vertical")
desc_map("n", "<Leader>wc", "<C-w>c", "Windows: Close window")
desc_map("n", "<Leader>wo", "<C-w>o", "Windows: Close other windows")
desc_map("n", "<Leader>w=", "<C-w>=", "Windows: Equalize sizes")

-- File Explorer (NvimTree)
desc_map("n", "<Leader>e", ":NvimTreeToggle<CR>", "Explorer: Toggle NvimTree")
desc_map("n", "<Leader>fe", ":NvimTreeFindFile<CR>", "Files: Find file in NvimTree")
desc_map("n", "<Leader>fc", ":NvimTreeFindFileToggle<CR>", "Files: Find and focus in NvimTree")
desc_map("n", "<Leader>ff", ":NvimTreeFocus<CR>", "Files: Focus NvimTree")

-- Easy Align
desc_map("x", "ga", "<Plug>(EasyAlign)", "Align: Interactive align (visual)")
desc_map("n", "ga", "<Plug>(EasyAlign)", "Align: Interactive align (motion)")

-- Development/Debug operations
desc_map("n", "<Leader>dd", ":ChecklistDebug<CR>", "Debug: Toggle checklist debugging")
desc_map("n", "<Leader>dc", ":ChecklistOpen<CR>", "Debug: Open checklist")
desc_map("n", "<Leader>dg", ":ChecklistGenerate<CR>", "Debug: Generate directory structure")

-- Spell checking operations
desc_map("n", "<Leader>zz", function()
	require("personal.spell").toggle_spell()
end, "Spell: Toggle spell checking")
desc_map("n", "<Leader>zs", function()
	require("personal.spell").toggle_slovene_spell()
end, "Spell: Toggle Slovene spell checking")
desc_map("n", "<Leader>zn", "]s", "Spell: Next misspelled word")
desc_map("n", "<Leader>zp", "[s", "Spell: Previous misspelled word")
desc_map("n", "<Leader>za", "zg", "Spell: Add word to dictionary")
desc_map("n", "<Leader>z?", function()
	vim.cmd("normal! z=")
end, "Spell: Show spelling suggestions")

-- Thesaurus operations
desc_map("n", "<Leader>zr", ":ThesaurusQueryReplaceCurrentWord<CR>", "Thesaurus: Replace current word with synonym")
desc_map("n", "<Leader>zl", ":ThesaurusQueryLookupCurrentWord<CR>", "Thesaurus: Lookup synonyms for current word")

-- Diagnostics (Trouble)
desc_map("n", "<Leader>xx", ":Trouble<CR>", "Diagnostics: Open trouble (Trouble)")
desc_map("n", "<Leader>xw", ":Trouble workspace_diagnostics<CR>", "Diagnostics: Workspace diagnostics (Trouble)")
desc_map("n", "<Leader>xd", ":Trouble document_diagnostics<CR>", "Diagnostics: Document diagnostics (Trouble)")
desc_map("n", "<Leader>xl", ":Trouble loclist<CR>", "Diagnostics: Location list (Trouble)")
desc_map("n", "<Leader>xq", ":Trouble quickfix<CR>", "Diagnostics: Quickfix list (Trouble)")

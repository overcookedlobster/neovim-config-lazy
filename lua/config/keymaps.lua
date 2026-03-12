-- ~/.config/nvim/lua/config/keymaps.lua
-- Global keymaps

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Helper function for key mapping with description
local function desc_map(mode, lhs, rhs, description, map_opts)
	local merged_opts = vim.tbl_extend("force", opts, map_opts or {}, { desc = description })
	map(mode, lhs, rhs, merged_opts)
end
-- Structural Trace: See where a signal goes without jumping
vim.keymap.set("n", "<leader>st", function()
	require("telescope.builtin").lsp_references({
		include_declaration = true,
		show_line = true,
		fname_width = 40,
	})
end, { desc = "Signal Trace: Find all structural references" })
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
desc_map("n", "<Leader>gts", function()
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

-- Basic Git operations (Fugitive)
desc_map("n", "<Leader>ga", ":Git add .<CR>", "Git: Add all files")
desc_map("n", "<Leader>gA", ":Git add %<CR>", "Git: Add current file")
desc_map("n", "<Leader>gci", ":Git commit<CR>", "Git: Commit (interactive)")
desc_map("n", "<Leader>gcm", ":Git commit -m ", "Git: Commit with message", { noremap = true })
desc_map("n", "<Leader>gca", ":Git commit --amend<CR>", "Git: Amend last commit")
desc_map("n", "<Leader>gp", ":Git push<CR>", "Git: Push")
desc_map("n", "<Leader>gP", ":Git pull<CR>", "Git: Pull")
desc_map("n", "<Leader>gF", ":Git fetch<CR>", "Git: Fetch")

-- Git diff operations (Fugitive)
desc_map("n", "<Leader>gd", ":Gdiffsplit<CR>", "Git: Diff working tree (split)")
desc_map("n", "<Leader>gD", ":Gdiffsplit --cached<CR>", "Git: Diff staged (split)")
desc_map("n", "<Leader>gdh", ":Gdiffsplit HEAD<CR>", "Git: Diff against HEAD (split)")
desc_map("n", "<Leader>gdf", ":Gdiffsplit", "Git: Diff current file (split)")
desc_map("n", "<Leader>gdv", ":Gvdiffsplit", "Git: Diff vertical split")
desc_map("n", "<Leader>gdt", ":Git difftool<CR>", "Git: Open difftool")

-- Git log operations (Fugitive)
desc_map("n", "<Leader>gl", ":Git log --oneline -10<CR>", "Git: Log (last 10)")
desc_map("n", "<Leader>gL", ":Git log --graph --oneline --all -20<CR>", "Git: Log graph")
desc_map("n", "<Leader>gla", ":Git log --oneline --all<CR>", "Git: Log all branches")
desc_map("n", "<Leader>glf", ":Git log --follow -- %<CR>", "Git: Log current file")
desc_map("n", "<Leader>glp", ":Git log -p<CR>", "Git: Log with patches")

-- Git blame and show (Fugitive)
desc_map("n", "<Leader>gB", ":Git blame<CR>", "Git: Blame current file")
desc_map("n", "<Leader>gsh", ":Git show<CR>", "Git: Show last commit")
desc_map("n", "<Leader>gsf", ":Git show --name-only<CR>", "Git: Show files in last commit")

-- Git branch operations (Fugitive)
desc_map("n", "<Leader>gbn", ":Git checkout -b ", "Git: New branch", { noremap = true })
desc_map("n", "<Leader>gbc", ":Git checkout ", "Git: Checkout branch", { noremap = true })
desc_map("n", "<Leader>gbm", ":Git merge ", "Git: Merge branch", { noremap = true })
desc_map("n", "<Leader>gbd", ":Git branch -d ", "Git: Delete branch", { noremap = true })
desc_map("n", "<Leader>gbD", ":Git branch -D ", "Git: Force delete branch", { noremap = true })
desc_map("n", "<Leader>gbl", ":Git branch -l<CR>", "Git: List branches")
desc_map("n", "<Leader>gbr", ":Git branch -r<CR>", "Git: List remote branches")
desc_map("n", "<Leader>gba", ":Git branch -a<CR>", "Git: List all branches")

-- Git stash operations (Fugitive)
desc_map("n", "<Leader>gss", ":Git stash<CR>", "Git: Stash changes")
desc_map("n", "<Leader>gsp", ":Git stash pop<CR>", "Git: Stash pop")
desc_map("n", "<Leader>gsl", ":Git stash list<CR>", "Git: Stash list")
desc_map("n", "<Leader>gsd", ":Git stash drop<CR>", "Git: Stash drop")
desc_map("n", "<Leader>gsc", ":Git stash clear<CR>", "Git: Stash clear")
desc_map("n", "<Leader>gsS", ':Git stash save "', "Git: Stash with message", { noremap = true })
desc_map("n", "<Leader>gsa", ":Git stash apply<CR>", "Git: Stash apply")

-- Git reset operations (Fugitive)
desc_map("n", "<Leader>grh", ":Git reset --hard HEAD<CR>", "Git: Reset hard to HEAD")
desc_map("n", "<Leader>grs", ":Git reset --soft HEAD~1<CR>", "Git: Reset soft (undo last commit)")
desc_map("n", "<Leader>grm", ":Git reset --mixed HEAD~1<CR>", "Git: Reset mixed (undo last commit, keep changes)")
desc_map("n", "<Leader>grf", ":Git reset HEAD -- %<CR>", "Git: Unstage current file")
desc_map("n", "<Leader>grF", ":Git reset HEAD<CR>", "Git: Unstage all files")

-- Git remote operations (Fugitive)
desc_map("n", "<Leader>gRf", ":Git fetch<CR>", "Git: Fetch from remote")
desc_map("n", "<Leader>gRp", ":Git remote -v<CR>", "Git: Show remotes")
desc_map("n", "<Leader>gRu", ":Git remote update<CR>", "Git: Update remotes")
desc_map("n", "<Leader>gRa", ":Git remote add ", "Git: Add remote", { noremap = true })
desc_map("n", "<Leader>gRr", ":Git remote remove ", "Git: Remove remote", { noremap = true })

-- Git rebase operations (Fugitive)
desc_map("n", "<Leader>gri", ":Git rebase -i HEAD~", "Git: Interactive rebase", { noremap = true })
desc_map("n", "<Leader>grc", ":Git rebase --continue<CR>", "Git: Continue rebase")
desc_map("n", "<Leader>gra", ":Git rebase --abort<CR>", "Git: Abort rebase")
desc_map("n", "<Leader>grs", ":Git rebase --skip<CR>", "Git: Skip rebase")

-- Git merge operations (Fugitive)
desc_map("n", "<Leader>gmc", ":Git merge --continue<CR>", "Git: Continue merge")
desc_map("n", "<Leader>gma", ":Git merge --abort<CR>", "Git: Abort merge")
desc_map("n", "<Leader>gmt", ":Git mergetool<CR>", "Git: Open merge tool")

-- Git tag operations (Fugitive)
desc_map("n", "<Leader>gtl", ":Git tag -l<CR>", "Git: List tags")
desc_map("n", "<Leader>gtn", ":Git tag ", "Git: Create tag", { noremap = true })
desc_map("n", "<Leader>gtd", ":Git tag -d ", "Git: Delete tag", { noremap = true })
desc_map("n", "<Leader>gtp", ":Git push --tags<CR>", "Git: Push tags")

-- Git worktree operations (Fugitive)
desc_map("n", "<Leader>gwl", ":Git worktree list<CR>", "Git: List worktrees")
desc_map("n", "<Leader>gwa", ":Git worktree add ", "Git: Add worktree", { noremap = true })
desc_map("n", "<Leader>gwr", ":Git worktree remove ", "Git: Remove worktree", { noremap = true })

-- Git clean operations (Fugitive)
desc_map("n", "<Leader>gCn", ":Git clean -n<CR>", "Git: Clean (dry run)")
desc_map("n", "<Leader>gCf", ":Git clean -f<CR>", "Git: Clean untracked files")
desc_map("n", "<Leader>gCd", ":Git clean -fd<CR>", "Git: Clean files and directories")

-- Git status and info (Fugitive)
desc_map("n", "<Leader>gS", ":Git status<CR>", "Git: Status (terminal)")
desc_map("n", "<Leader>gi", ":Git status --porcelain<CR>", "Git: Status (porcelain)")
desc_map("n", "<Leader>gwc", ":Git whatchanged<CR>", "Git: What changed")

-- Git cherry-pick operations (Fugitive)
desc_map("n", "<Leader>gcp", ":Git cherry-pick ", "Git: Cherry-pick", { noremap = true })
desc_map("n", "<Leader>gcpc", ":Git cherry-pick --continue<CR>", "Git: Continue cherry-pick")
desc_map("n", "<Leader>gcpa", ":Git cherry-pick --abort<CR>", "Git: Abort cherry-pick")

-- Fugitive-specific commands
desc_map("n", "<Leader>G", ":G<CR>", "Git: Interactive status (Fugitive)")
desc_map("n", "<Leader>gr", ":Gread<CR>", "Git: Read index version (checkout)")
desc_map("n", "<Leader>gw", ":Gwrite<CR>", "Git: Write and stage file")
desc_map("n", "<Leader>gR", ":Gremove<CR>", "Git: Remove file from git and buffer")
desc_map("n", "<Leader>gM", ":Gmove ", "Git: Move/rename file", { noremap = true })
desc_map("n", "<Leader>go", ":GBrowse<CR>", "Git: Open in browser (GitHub/GitLab)")
desc_map("v", "<Leader>go", ":GBrowse<CR>", "Git: Open selection in browser")

-- Git object browsing (Fugitive)
desc_map("n", "<Leader>ge", ":Gedit ", "Git: Edit git object", { noremap = true })
desc_map("n", "<Leader>gE", ":Gedit HEAD<CR>", "Git: Edit HEAD commit")
desc_map("n", "<Leader>gs", ":Gsplit ", "Git: Split with git object", { noremap = true })
desc_map("n", "<Leader>gv", ":Gvsplit ", "Git: Vertical split with git object", { noremap = true })
desc_map("n", "<Leader>gT", ":Gtabedit ", "Git: Tab edit git object", { noremap = true })
desc_map("n", "<Leader>gH", ":Glog<CR>", "Git: File history (quickfix)")
desc_map("n", "<Leader>gq", ":Glog --<CR>", "Git: Repository log (quickfix)")
desc_map("n", "<Leader>gO", ":Glog -- %<CR>", "Git: Current file log (quickfix)")

-- Git conflict resolution (Fugitive)
desc_map("n", "<Leader>gD3", ":Gvdiffsplit!<CR>", "Git: 3-way merge conflict resolution")
desc_map("n", "<Leader>gdl", ":diffget //2<CR>", "Git: Get change from left (local)")
desc_map("n", "<Leader>gdr", ":diffget //3<CR>", "Git: Get change from right (remote)")
desc_map("n", "<Leader>gdp", ":diffput<CR>", "Git: Put change to other buffer")
desc_map("n", "<Leader>gdn", "]c", "Git: Next conflict marker")
desc_map("n", "<Leader>gdN", "[c", "Git: Previous conflict marker")
desc_map("n", "<Leader>gdu", ":diffupdate<CR>", "Git: Update diff highlighting")

-- File explorer with Ranger
desc_map("n", "<Leader>fr", ":RnvimrToggle<CR>", "Files: Ranger explorer")

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

-- ============================================================================
-- LEETCODE KEYMAPS
-- ============================================================================

-- LeetCode operations
desc_map("n", "<Leader>Ll", ":Leet list<CR>", "LeetCode: List problems")
desc_map("n", "<Leader>Lr", ":Leet run<CR>", "LeetCode: Run code")
desc_map("n", "<Leader>Ls", ":Leet submit<CR>", "LeetCode: Submit")
desc_map("n", "<Leader>Lt", ":Leet test<CR>", "LeetCode: Test")
desc_map("n", "<Leader>Li", ":Leet info<CR>", "LeetCode: Problem info")
desc_map("n", "<Leader>Ld", ":Leet daily<CR>", "LeetCode: Daily problem")
desc_map("n", "<Leader>Lc", ":Leet console<CR>", "LeetCode: Console toggle")
desc_map("n", "<Leader>Lm", ":Leet menu<CR>", "LeetCode: Menu")
desc_map("n", "<Leader>Lo", ":Leet open<CR>", "LeetCode: Open problem")
desc_map("n", "<Leader>Lp", ":Leet pick<CR>", "LeetCode: Pick problem")
desc_map("n", "<Leader>Lq", ":Leet close<CR>", "LeetCode: Close")

-- LeetCode authentication and setup
desc_map("n", "<Leader>LA", function()
	-- Create a custom authentication helper
	local function show_auth_instructions()
		local lines = {
			"������ LeetCode Authentication Guide",
			"",
			"To use LeetCode features, you need to authenticate:",
			"",
			"Method 1: Browser Authentication (Recommended)",
			"1. Run ':Leet' command",
			"2. This will open LeetCode interface",
			"3. Follow any authentication prompts that appear",
			"4. Login through your browser if prompted",
			"",
			"Method 2: Manual Cookie Setup",
			"1. Login to leetcode.com in your browser",
			"2. Open Developer Tools (F12)",
			"3. Go to Application/Storage > Cookies",
			"4. Copy the 'LEETCODE_SESSION' cookie value",
			"5. Set it in your environment or config",
			"",
			"After authentication, all LeetCode commands will work!",
			"",
			"Available commands:",
			"• <Leader>Ll - List problems",
			"• <Leader>Lp - Pick a problem",
			"• <Leader>Lr - Run code",
			"• <Leader>Lt - Test code",
			"• <Leader>Ls - Submit solution",
			"• <Leader>Ld - Daily challenge",
			"",
			"Press 'q' to close this help, or Enter to start authentication",
		}

		-- Create a scratch buffer for instructions
		local buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
		vim.api.nvim_buf_set_option(buf, "modifiable", false)
		vim.api.nvim_buf_set_option(buf, "filetype", "markdown")

		-- Create a floating window
		local width = 70
		local height = #lines + 2
		local row = math.floor((vim.o.lines - height) / 2)
		local col = math.floor((vim.o.columns - width) / 2)

		local win = vim.api.nvim_open_win(buf, true, {
			relative = "editor",
			width = width,
			height = height,
			row = row,
			col = col,
			style = "minimal",
			border = "rounded",
			title = " LeetCode Setup ",
			title_pos = "center",
		})

		-- Set up keymaps for the help window
		local opts = { buffer = buf, silent = true }
		vim.keymap.set("n", "q", function()
			vim.api.nvim_win_close(win, true)
		end, opts)

		vim.keymap.set("n", "<CR>", function()
			vim.api.nvim_win_close(win, true)
			vim.cmd("Leet")
		end, opts)

		vim.keymap.set("n", "<Esc>", function()
			vim.api.nvim_win_close(win, true)
		end, opts)
	end

	show_auth_instructions()
end, "LeetCode: Authentication help")

-- LeetCode language switching
desc_map("n", "<Leader>LL", function()
	local languages = { "c", "cpp", "python3", "java", "javascript", "typescript", "go", "rust" }
	vim.ui.select(languages, {
		prompt = "Select LeetCode language:",
	}, function(choice)
		if choice then
			-- Update the language in leetcode config
			local ok, leetcode = pcall(require, "leetcode")
			if ok then
				-- This will require a restart or reconfiguration
				vim.notify("Language set to: " .. choice, vim.log.levels.INFO)
				vim.notify(
					"Note: You may need to restart Neovim for language change to take effect",
					vim.log.levels.WARN
				)
			end
		end
	end)
end, "LeetCode: Select language")

-- ============================================================================
-- AI OPERATIONS
-- ============================================================================

-- AI (Avante) - Primary AI assistant using <Leader>a
desc_map("n", "<Leader>aa", ":AvanteAsk<CR>", "AI: Ask Avante")
desc_map("n", "<Leader>ac", ":AvanteChat<CR>", "AI: Chat with Avante")
desc_map("n", "<Leader>ae", ":AvanteEdit<CR>", "AI: Edit with Avante")
desc_map("n", "<Leader>at", ":AvanteToggle<CR>", "AI: Toggle Avante panel")
desc_map("n", "<Leader>ar", ":AvanteRefresh<CR>", "AI: Refresh Avante")
desc_map("n", "<Leader>ax", ":AvanteClear<CR>", "AI: Clear Avante session")
desc_map("n", "<Leader>ap", ":AvanteProvider<CR>", "AI: Switch Avante provider")
desc_map("n", "<Leader>am", ":AvanteModel<CR>", "AI: Switch Avante model")
desc_map("n", "<Leader>al", ":AvanteConversationLoad<CR>", "AI: Load Avante conversation")
desc_map("n", "<Leader>as", ":AvanteConversationSave<CR>", "AI: Save Avante conversation")
desc_map("n", "<Leader>ad", ":AvanteConversationDelete<CR>", "AI: Delete Avante conversation")

-- Avante History operations (using telescope for file browsing since no specific history commands exist)
desc_map("n", "<Leader>ahl", function()
	local avante_dir = vim.fn.stdpath("data") .. "/avante"
	if vim.fn.isdirectory(avante_dir) == 1 then
		require("telescope.builtin").find_files({
			prompt_title = "Avante Conversation History",
			cwd = avante_dir,
			find_command = { "find", avante_dir, "-type", "f", "-name", "*.md" },
		})
	else
		vim.notify("Avante data directory not found", vim.log.levels.WARN)
	end
end, "AI: List Avante conversation history")

desc_map("n", "<Leader>ahs", function()
	local avante_dir = vim.fn.stdpath("data") .. "/avante"
	if vim.fn.isdirectory(avante_dir) == 1 then
		require("telescope.builtin").live_grep({
			prompt_title = "Search Avante Conversations",
			cwd = avante_dir,
		})
	else
		vim.notify("Avante data directory not found", vim.log.levels.WARN)
	end
end, "AI: Search Avante conversation history")

desc_map("n", "<Leader>ahc", function()
	local avante_dir = vim.fn.stdpath("data") .. "/avante"
	if vim.fn.isdirectory(avante_dir) == 1 then
		local choice = vim.fn.confirm("Clear all Avante conversation history?", "&Yes\n&No", 2)
		if choice == 1 then
			vim.fn.system("rm -rf " .. vim.fn.shellescape(avante_dir) .. "/*")
			vim.notify("Avante conversation history cleared", vim.log.levels.INFO)
		end
	else
		vim.notify("Avante data directory not found", vim.log.levels.WARN)
	end
end, "AI: Clear Avante conversation history")

desc_map("n", "<Leader>ahe", function()
	local avante_dir = vim.fn.stdpath("data") .. "/avante"
	if vim.fn.isdirectory(avante_dir) == 1 then
		local export_dir = vim.fn.expand("~/avante_export_" .. os.date("%Y%m%d_%H%M%S"))
		vim.fn.system("cp -r " .. vim.fn.shellescape(avante_dir) .. " " .. vim.fn.shellescape(export_dir))
		vim.notify("Avante conversations exported to: " .. export_dir, vim.log.levels.INFO)
	else
		vim.notify("Avante data directory not found", vim.log.levels.WARN)
	end
end, "AI: Export Avante conversation history")

-- AI (Parrot) - Secondary AI assistant using <Leader>p to avoid conflict with Avante's <Leader>a
desc_map("n", "<Leader>pr", ":PrtChatResponde<CR>", "AI: Chat respond (Parrot)")
desc_map("n", "<Leader>pn", ":PrtChatNew<CR>", "AI: New chat (Parrot)")
desc_map("n", "<Leader>pp", ":PrtProvider<CR>", "AI: Provider selection (Parrot)")
desc_map("n", "<Leader>pa", ":PrtAsk<CR>", "AI: Ask question (Parrot)")
desc_map("n", "<Leader>pf", ":ChatFind<CR>", "AI: Find chats (Parrot)")
desc_map("n", "<Leader>pm", ":PrtModel<CR>", "AI: Model selection (Parrot)")
desc_map("n", "<Leader>pt", ":PrtThinking<CR>", "AI: Enable thinking (Parrot)")
desc_map("n", "<Leader>ps", ":PrtThinking status<CR>", "AI: Thinking status (Parrot)")
desc_map("n", "<Leader>px", ":PrtChatStop<CR>", "AI: Stop chat (Parrot)")

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

-- ============================================================================
-- ADDITIONAL UNMAPPED PLUGIN FUNCTIONS
-- ============================================================================

-- Mason/Tools management
desc_map("n", "<Leader>mm", ":Mason<CR>", "Mason: Open Mason")
desc_map("n", "<Leader>mu", ":MasonUpdate<CR>", "Mason: Update all")
desc_map("n", "<Leader>mi", ":MasonInstall ", "Mason: Install package")
desc_map("n", "<Leader>ml", ":Lint<CR>", "Lint: Run linter")
desc_map("n", "<Leader>mf", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, "Format: Format buffer")

-- Numeric conversion utilities (nvim-conv)
desc_map("n", "<Leader>ucd", ":ConvDec<CR>", "Convert: To decimal")
desc_map("n", "<Leader>uch", ":ConvHex<CR>", "Convert: To hexadecimal")
desc_map("n", "<Leader>uco", ":ConvOct<CR>", "Convert: To octal")
desc_map("n", "<Leader>ucb", ":ConvBin<CR>", "Convert: To binary")
desc_map("n", "<Leader>ucs", ":ConvStr<CR>", "Convert: To string")
desc_map("n", "<Leader>ucB", ":ConvBytes<CR>", "Convert: Bytes")
desc_map("n", "<Leader>ucf", ":ConvFarenheit<CR>", "Convert: Fahrenheit")
desc_map("n", "<Leader>ucC", ":ConvCelsius<CR>", "Convert: Celsius")

-- Clipboard image utilities
desc_map("n", "<Leader>ui", function()
	require("clipboard-image").paste_img()
end, "Utilities: Paste image from clipboard")

-- Jupyter (Jukit) operations
desc_map("n", "<Leader>ujs", ":call jukit#splits#output()<CR>", "Jukit: Start output split")
desc_map("n", "<Leader>ujr", ":call jukit#send#section(0)<CR>", "Jukit: Run current cell")
desc_map("n", "<Leader>ujR", ":call jukit#send#all()<CR>", "Jukit: Run all cells")
desc_map("n", "<Leader>ujd", ":call jukit#cells#delete()<CR>", "Jukit: Delete current cell")
desc_map("n", "<Leader>ujc", ":call jukit#cells#create_below(0)<CR>", "Jukit: Create new cell")

-- Ouroboros (file navigation)
desc_map("n", "<Leader>jh", function()
	require("ouroboros").switch()
end, "Jump: Switch to header/source")
desc_map("n", "<Leader>jf", function()
	require("ouroboros").find_related()
end, "Jump: Find related files")

-- ToggleTasks (project task management)
desc_map("n", "<Leader>tT", ":Telescope toggletasks<CR>", "Tasks: Toggle tasks")
desc_map("n", "<Leader>ts", function()
	require("toggletasks").spawn_by_name("serve")
end, "Tasks: Start serve task")
desc_map("n", "<Leader>tb", function()
	require("toggletasks").spawn_by_name("build")
end, "Tasks: Start build task")
desc_map("n", "<Leader>td", function()
	require("toggletasks").spawn_by_name("dev")
end, "Tasks: Start dev task")

-- Live Preview for Markdown, HTML, AsciiDoc, SVG
desc_map("n", "<Leader>cm", ":LivePreview start<CR>", "Code: Live preview")
desc_map("n", "<Leader>cM", ":LivePreview close<CR>", "Code: Close live preview")
desc_map("n", "<Leader>ct", ":LivePreviewToggle<CR>", "Code: Toggle live preview")

-- Help/Documentation shortcuts
desc_map("n", "<Leader>hm", ":Mason<CR>", "Help: Open Mason")
desc_map("n", "<Leader>hM", ":MasonUpdate<CR>", "Help: Mason update")
desc_map("n", "<Leader>hi", ":MasonInstall ", "Help: Mason install")
desc_map("n", "<Leader>hc", ":ConformInfo<CR>", "Help: ConformInfo")
desc_map("n", "<Leader>hl", ":LspInfo<CR>", "Help: LspInfo")
desc_map("n", "<Leader>hr", ":LspRestart<CR>", "Help: LspRestart")

-- ============================================================================
-- THEME SWITCHING (Using Themery.nvim)
-- ============================================================================

-- Main theme picker with live preview and persistence
desc_map("n", "<Leader>ut", ":Themery<CR>", "UI: Theme picker (Themery)")

-- Quick theme switching functions using Themery API
local function quick_switch_theme(theme_name)
	local themery_ok, themery = pcall(require, "themery")
	if not themery_ok then
		vim.notify("Themery not available", vim.log.levels.ERROR)
		return
	end

	local success, error_msg = pcall(function()
		themery.setThemeByName(theme_name, true) -- true = make persistent
	end)

	if not success then
		vim.notify(
			"Failed to switch to theme: " .. theme_name .. "\nError: " .. tostring(error_msg),
			vim.log.levels.ERROR
		)
	else
		vim.notify("Switched to: " .. theme_name, vim.log.levels.INFO)
	end
end

-- Get available themes and find by colorscheme
local function switch_by_colorscheme(colorscheme_name)
	local themery_ok, themery = pcall(require, "themery")
	if not themery_ok then
		vim.notify("Themery not available", vim.log.levels.ERROR)
		return
	end

	local themes = themery.getAvailableThemes()
	if not themes then
		vim.notify("No themes available", vim.log.levels.ERROR)
		return
	end

	for _, theme in ipairs(themes) do
		if theme.colorscheme == colorscheme_name then
			quick_switch_theme(theme.name)
			return
		end
	end

	vim.notify("Theme with colorscheme '" .. colorscheme_name .. "' not found", vim.log.levels.WARN)
end

-- Quick theme shortcuts (most popular themes) - using colorscheme names for reliability
desc_map("n", "<Leader>ug", function()
	switch_by_colorscheme("gruvbox-material")
end, "UI: Gruvbox Material theme")

desc_map("n", "<Leader>ut1", function()
	switch_by_colorscheme("tokyonight")
end, "UI: Tokyo Night theme")

desc_map("n", "<Leader>ut2", function()
	switch_by_colorscheme("catppuccin-mocha")
end, "UI: Catppuccin Mocha theme")

desc_map("n", "<Leader>ut3", function()
	switch_by_colorscheme("rose-pine")
end, "UI: Rose Pine theme")

desc_map("n", "<Leader>ut4", function()
	switch_by_colorscheme("kanagawa-wave")
end, "UI: Kanagawa Wave theme")

desc_map("n", "<Leader>ut5", function()
	switch_by_colorscheme("nightfox")
end, "UI: Nightfox theme")

desc_map("n", "<Leader>ut6", function()
	switch_by_colorscheme("vscode")
end, "UI: VSCode theme")

desc_map("n", "<Leader>ut7", function()
	switch_by_colorscheme("onedark")
end, "UI: OneDark theme")

desc_map("n", "<Leader>ut8", function()
	switch_by_colorscheme("material")
end, "UI: Material theme")

desc_map("n", "<Leader>ut9", function()
	switch_by_colorscheme("github_dark")
end, "UI: GitHub Dark theme")

-- Improved Light/Dark mode toggle with better theme family detection
desc_map("n", "<Leader>utt", function()
	local themery_ok, themery = pcall(require, "themery")
	if not themery_ok then
		vim.notify("Themery not available", vim.log.levels.ERROR)
		return
	end

	local current_colorscheme = vim.g.colors_name or ""
	local themes = themery.getAvailableThemes()

	if not themes then
		vim.notify("No themes available", vim.log.levels.ERROR)
		return
	end

	-- Define theme families with their light/dark pairs
	local theme_pairs = {
		-- Tokyo Night family
		["tokyonight"] = "tokyonight-day",
		["tokyonight-storm"] = "tokyonight-day",
		["tokyonight-moon"] = "tokyonight-day",
		["tokyonight-day"] = "tokyonight",

		-- Catppuccin family
		["catppuccin-mocha"] = "catppuccin-latte",
		["catppuccin-frappe"] = "catppuccin-latte",
		["catppuccin-macchiato"] = "catppuccin-latte",
		["catppuccin-latte"] = "catppuccin-mocha",

		-- Rose Pine family
		["rose-pine"] = "rose-pine-dawn",
		["rose-pine-moon"] = "rose-pine-dawn",
		["rose-pine-dawn"] = "rose-pine",

		-- Kanagawa family
		["kanagawa-wave"] = "kanagawa-lotus",
		["kanagawa-dragon"] = "kanagawa-lotus",
		["kanagawa-lotus"] = "kanagawa-wave",

		-- GitHub family
		["github_dark"] = "github_light",
		["github_dark_dimmed"] = "github_light",
		["github_dark_high_contrast"] = "github_light_high_contrast",
		["github_light"] = "github_dark",
		["github_light_high_contrast"] = "github_dark_high_contrast",

		-- Nightfox family
		["nightfox"] = "dawnfox",
		["carbonfox"] = "dawnfox",
		["duskfox"] = "dayfox",
		["nordfox"] = "dawnfox",
		["terafox"] = "dawnfox",
		["dawnfox"] = "nightfox",
		["dayfox"] = "duskfox",

		-- Ayu family
		["ayu-dark"] = "ayu-light",
		["ayu-mirage"] = "ayu-light",
		["ayu-light"] = "ayu-dark",

		-- Material family
		["material"] = "material",
		["material-darker"] = "material",
		["material-oceanic"] = "material",
		["material-palenight"] = "material",
		["material-deep-ocean"] = "material",

		-- OneDark family
		["onedark"] = "onedark",
		["onedark_vivid"] = "onedark",
		["onedark_dark"] = "onedark",

		-- Default fallbacks
		["gruvbox-material"] = "tokyonight-day",
		["vscode"] = "github_light",
	}

	local target_colorscheme = theme_pairs[current_colorscheme]
	if target_colorscheme then
		switch_by_colorscheme(target_colorscheme)
	else
		-- Fallback to Tokyo Night if no pair found
		switch_by_colorscheme("tokyonight")
		vim.notify("No light/dark pair found for current theme, switched to Tokyo Night", vim.log.levels.INFO)
	end
end, "UI: Toggle light/dark theme")

-- Show current theme info
desc_map("n", "<Leader>uti", function()
	local themery_ok, themery = pcall(require, "themery")
	if not themery_ok then
		vim.notify("Themery not available", vim.log.levels.ERROR)
		return
	end

	local currentTheme = themery.getCurrentTheme()
	local current_colorscheme = vim.g.colors_name or "none"

	if currentTheme and currentTheme.name then
		vim.notify(
			"Current theme: " .. currentTheme.name .. "\nColorscheme: " .. current_colorscheme,
			vim.log.levels.INFO
		)
	else
		vim.notify("No theme selected\nColorscheme: " .. current_colorscheme, vim.log.levels.WARN)
	end
end, "UI: Show current theme info")

-- Random theme selector
desc_map("n", "<Leader>utr", function()
	local themery_ok, themery = pcall(require, "themery")
	if not themery_ok then
		vim.notify("Themery not available", vim.log.levels.ERROR)
		return
	end

	local themes = themery.getAvailableThemes()
	if not themes or #themes == 0 then
		vim.notify("No themes available", vim.log.levels.ERROR)
		return
	end

	-- Get random theme
	math.randomseed(os.time())
	local random_theme = themes[math.random(#themes)]
	quick_switch_theme(random_theme.name)
end, "UI: Random theme")

-- Cycle through favorite themes
local favorite_themes = {
	"tokyonight",
	"catppuccin-mocha",
	"rose-pine",
	"kanagawa-wave",
	"gruvbox-material",
	"nightfox",
}

desc_map("n", "<Leader>utc", function()
	local current_colorscheme = vim.g.colors_name or ""
	local current_index = 1

	-- Find current theme in favorites
	for i, theme in ipairs(favorite_themes) do
		if theme == current_colorscheme then
			current_index = i
			break
		end
	end

	-- Get next theme (cycle back to 1 if at end)
	local next_index = (current_index % #favorite_themes) + 1
	switch_by_colorscheme(favorite_themes[next_index])
end, "UI: Cycle favorite themes")
desc_map("n", "<Leader>zl", ":ThesaurusQueryLookupCurrentWord<CR>", "Thesaurus: Lookup synonyms for current word")

-- CSV Viewer (csvview.nvim)
desc_map("n", "<Leader>cv", ":CsvViewToggle<CR>", "CSV: Toggle CSV view")
desc_map("n", "<Leader>ce", ":CsvViewEnable<CR>", "CSV: Enable CSV view")
desc_map("n", "<Leader>cd", ":CsvViewDisable<CR>", "CSV: Disable CSV view")
desc_map("n", "<Leader>cb", ":CsvViewToggle display_mode=border<CR>", "CSV: Toggle with border mode")
desc_map("n", "<Leader>ch", ":CsvViewToggle display_mode=highlight<CR>", "CSV: Toggle with highlight mode")

-- Diagnostics (Trouble)
desc_map("n", "<Leader>xx", ":Trouble<CR>", "Diagnostics: Open trouble (Trouble)")
desc_map("n", "<Leader>xw", ":Trouble workspace_diagnostics<CR>", "Diagnostics: Workspace diagnostics (Trouble)")
desc_map("n", "<Leader>xd", ":Trouble document_diagnostics<CR>", "Diagnostics: Document diagnostics (Trouble)")
desc_map("n", "<Leader>xl", ":Trouble loclist<CR>", "Diagnostics: Location list (Trouble)")
desc_map("n", "<Leader>xq", ":Trouble quickfix<CR>", "Diagnostics: Quickfix list (Trouble)")

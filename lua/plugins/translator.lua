-- ~/.config/nvim/lua/plugins/translator.lua
-- vim-translator: async popup translations with dictionary meanings.
-- Script detection + keybindings live in lua/utils/translate.lua
--
-- NOTE: The google engine's get_explains() crashes with IndexError when the
-- returned POS string is empty (Google occasionally returns entries with a
-- blank word-class). patch_google_parser() applies a defensive fix to the
-- installed script/translator.py; lazy.nvim re-runs it on install/update.

-- Defensive fixes for the fragile Google response parser (idempotent).
local function patch_google_parser()
	local file = vim.fn.stdpath("data") .. "/lazy/vim-translator/script/translator.py"
	if vim.fn.filereadable(file) ~= 1 then
		return
	end
	local content = table.concat(vim.fn.readfile(file), "\n")
	local new = content
		:gsub(
			'for x in obj%[1%]:\n                expl = "%[{}%] "%.format%(x%[0%]%[0%]%)',
			'for x in obj[1]:\n                if not x or not x[0]:\n                    continue\n                expl = "[{}] ".format(x[0])'
		)
		:gsub('expl = "%[{}%] "%.format%(x%[0%]%[0%]%)', 'expl = "[{}] ".format(x[0])')
		:gsub("for i in x%[2%]:", "for i in (x[2] if len(x) > 2 and x[2] else []):")
		:gsub("if i%[0%] != definition:", "if i and i[0] != definition:")
		:gsub("for y in x%[1%]:", "for y in (x[1] if len(x) > 1 and x[1] else []):")
	if new ~= content then
		vim.fn.writefile(vim.fn.split(new, "\n"), file)
	end
end

return {
	{
		"voldikss/vim-translator",
		event = "VeryLazy",
		build = patch_google_parser,
		init = function()
			vim.g.translator_source_lang = "auto"
			vim.g.translator_target_lang = "en"
			vim.g.translator_default_engines = { "google" }
			vim.g.translator_window_type = "popup"
			vim.g.translator_window_max_width = 0.6
			vim.g.translator_window_max_height = 0.6
			vim.g.translator_history_enable = true
		end,
	},
}

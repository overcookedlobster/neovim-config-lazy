-- ~/.config/nvim/lua/utils/translate.lua
-- Detect foreign-language text (Korean, Japanese, Chinese, ...) in the current
-- visual selection or word under the cursor and show its English meaning /
-- translation in a floating popup (via vim-translator).
-- Latin/English text is intentionally ignored (detection returns nil).
--
-- The translation text is captured here and handed to vim-translator's core
-- function directly (not through a :'<,'>TranslateW range). Passing the range
-- would hit two plugin bugs: the '< / '> marks are one selection behind inside
-- a visual-mode callback, and the range slice drops the last character of
-- multibyte (CJK) selections because col("'>") points at the first byte of the
-- final character.

local M = {}

local TARGET_LANG = "en"
local ENGINES = { "google" }

-- { source_lang, script name, Vim regex over Unicode code-point ranges }
local SCRIPTS = {
	{ "ko", "Korean (Hangul)", "[\\u1100-\\u11FF\\u3130-\\u318F\\uAC00-\\uD7AF\\uA960-\\uA97F\\uD7B0-\\uD7FF]" },
	{ "ja", "Japanese (Kana)", "[\\u3040-\\u30FF\\u31F0-\\u31FF\\uFF66-\\uFF9F]" },
	{ "zh", "Chinese (Han)", "[\\u3400-\\u4DBF\\u4E00-\\u9FFF\\uF900-\\uFAFF]" },
	{ "auto", "Cyrillic", "[\\u0400-\\u04FF\\u0500-\\u052F]" },
	{ "auto", "Greek", "[\\u0370-\\u03FF\\u1F00-\\u1FFF]" },
	{ "auto", "Arabic", "[\\u0600-\\u06FF\\u0750-\\u077F\\u08A0-\\u08FF]" },
	{ "auto", "Hebrew", "[\\u0590-\\u05FF]" },
	{ "auto", "Thai", "[\\u0E00-\\u0E7F]" },
	{ "auto", "Devanagari", "[\\u0900-\\u097F\\u1CD0-\\u1CFF]" },
	{ "auto", "Tamil", "[\\u0B80-\\u0BFF]" },
	{ "auto", "Bengali", "[\\u0980-\\u09FF]" },
}

--- Detect the script of `text`.
--- @param text string
--- @return string|nil source_lang
--- @return string script_name
function M.detect(text)
	if not text or text == "" then
		return nil
	end
	for _, s in ipairs(SCRIPTS) do
		if vim.fn.match(text, "\\C" .. s[3]) >= 0 then
			return s[1], s[2]
		end
	end
	return nil
end

--- Show `text` translated into the target language in a popup window.
--- @param text string
--- @param source_lang string
local function show_translation(text, source_lang)
	-- translator#translate is an autoload function; the first call loads it.
	-- (vim.fn.exists("*translator#translate") reports 0 until loaded, so it
	-- cannot be used as a load guard.)
	local ok, err = pcall(vim.fn["translator#translate"], {
		target_lang = TARGET_LANG,
		source_lang = source_lang,
		text = text,
		engines = ENGINES,
	}, "window")
	if not ok then
		vim.notify("vim-translator not loaded: " .. tostring(err), vim.log.levels.ERROR)
	end
end

--- Extract the current visual selection text (from the '< / '> marks) as a
--- UTF-8 string. Char-based positions (getcharpos) + strcharpart are used so
--- multibyte (CJK) text keeps its final character intact.
--- @return string|nil
local function visual_text()
	local l1 = vim.fn.line("'<")
	local l2 = vim.fn.line("'>")
	if l1 <= 0 or l2 <= 0 then
		return nil
	end
	local lines = vim.fn.getline(l1, l2)
	if not lines or #lines == 0 then
		return nil
	end
	local c1 = vim.fn.getcharpos("'<")[3]
	local c2 = vim.fn.getcharpos("'>")[3]
	if #lines == 1 then
		local maxc = vim.fn.strchars(lines[1])
		if c2 > maxc then
			c2 = maxc
		end
		if c2 < c1 then
			return nil
		end
		return vim.fn.strcharpart(lines[1], c1 - 1, c2 - c1 + 1)
	end
	lines[1] = vim.fn.strcharpart(lines[1], c1 - 1)
	local last = lines[#lines]
	local maxc = vim.fn.strchars(last)
	if c2 > maxc then
		c2 = maxc
	end
	lines[#lines] = vim.fn.strcharpart(last, 0, c2)
	return table.concat(lines, " ")
end

--- Translate the current visual selection into a popup.
function M.selection()
	-- Exit visual mode so Vim finalizes the '< and '> marks. Inside a
	-- visual-mode callback the marks still hold the PREVIOUS selection,
	-- which would translate the n-1 block instead of the current one.
	-- NOTE: must be :execute "normal! \<Esc>" — ":normal! <Esc>" types the
	-- literal characters (s,c,>) into the buffer as "c>".
	if vim.fn.mode():find("[vV\x16]") then
		vim.cmd('silent! execute "normal! \\<Esc>"')
	end
	local text = visual_text()
	if not text then
		return
	end
	text = text:gsub("^%s+", ""):gsub("%s+$", "")
	if text == "" then
		return
	end
	local src = M.detect(text)
	if not src then
		vim.notify("Selected text looks like Latin/English - nothing to translate", vim.log.levels.INFO)
		return
	end
	show_translation(text, src)
end

--- Translate the word under the cursor into a popup.
function M.word()
	local text = vim.fn.expand("<cword>")
	if text == "" then
		return
	end
	local src = M.detect(text)
	if not src then
		vim.notify("Word looks like Latin/English - nothing to translate", vim.log.levels.INFO)
		return
	end
	show_translation(text, src)
end

return M

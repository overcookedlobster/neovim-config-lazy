-- ~/.config/nvim/lua/config/which-key-tex.lua
-- Filetype-specific which-key configuration for TeX files

local M = {}

function M.setup()
	local wk = require("which-key")

	-- TeX-specific which-key groups (only active for TeX files)
	wk.add({
		-- Main TeX operations
		{ "<leader>c", desc = "TeX: Compile document", ft = "tex" },
		{ "<leader>r", desc = "TeX: Recompile document", ft = "tex" },
		{ "<leader>v", desc = "TeX: View PDF", ft = "tex" },
		{ "<leader>i", desc = "TeX: Show info", ft = "tex" },
		{ "<leader>t", group = "TeX Tools", ft = "tex" },
		{ "<leader>te", desc = "TeX: Toggle shell escape", ft = "tex" },

		-- TeX Delete operations
		{ "ds", group = "TeX Delete Surrounding", ft = "tex" },
		{ "dse", desc = "TeX: Delete surrounding environment", ft = "tex" },
		{ "dsc", desc = "TeX: Delete surrounding command", ft = "tex" },
		{ "dsm", desc = "TeX: Delete surrounding math environment", ft = "tex" },
		{ "dsd", desc = "TeX: Delete surrounding delimiters", ft = "tex" },

		-- TeX Change operations
		{ "cs", group = "TeX Change Surrounding", ft = "tex" },
		{ "cse", desc = "TeX: Change surrounding environment", ft = "tex" },
		{ "csc", desc = "TeX: Change surrounding command", ft = "tex" },
		{ "csm", desc = "TeX: Change surrounding math environment", ft = "tex" },
		{ "csd", desc = "TeX: Change surrounding math delimiters", ft = "tex" },

		-- TeX Toggle operations
		{ "ts", group = "TeX Toggle", ft = "tex" },
		{ "tsf", desc = "TeX: Toggle fraction command", ft = "tex" },
		{ "tsc", desc = "TeX: Toggle command star variant", ft = "tex" },
		{ "tse", desc = "TeX: Toggle environment star variant", ft = "tex" },
		{ "tsd", desc = "TeX: Toggle delimiter modifier", ft = "tex" },
		{ "tsD", desc = "TeX: Toggle delimiter modifier (reverse)", ft = "tex" },
		{ "tsm", desc = "TeX: Toggle math environment", ft = "tex" },

		-- TeX Text Objects (visual and operator-pending)
		{ "a", group = "TeX Around Text Objects", mode = { "o", "x" }, ft = "tex" },
		{ "ac", desc = "TeX: Around command", mode = { "o", "x" }, ft = "tex" },
		{ "ad", desc = "TeX: Around delimiters", mode = { "o", "x" }, ft = "tex" },
		{ "ae", desc = "TeX: Around environment", mode = { "o", "x" }, ft = "tex" },
		{ "am", desc = "TeX: Around math", mode = { "o", "x" }, ft = "tex" },
		{ "ai", desc = "TeX: Around item", mode = { "o", "x" }, ft = "tex" },
		{ "aP", desc = "TeX: Around paragraph", mode = { "o", "x" }, ft = "tex" },

		{ "i", group = "TeX Inside Text Objects", mode = { "o", "x" }, ft = "tex" },
		{ "ic", desc = "TeX: Inside command", mode = { "o", "x" }, ft = "tex" },
		{ "id", desc = "TeX: Inside delimiters", mode = { "o", "x" }, ft = "tex" },
		{ "ie", desc = "TeX: Inside environment", mode = { "o", "x" }, ft = "tex" },
		{ "im", desc = "TeX: Inside math", mode = { "o", "x" }, ft = "tex" },
		{ "ii", desc = "TeX: Inside item", mode = { "o", "x" }, ft = "tex" },
		{ "iP", desc = "TeX: Inside paragraph", mode = { "o", "x" }, ft = "tex" },

		-- TeX Motions
		{ "]", group = "TeX Next Motions", ft = "tex" },
		{ "]]", desc = "TeX: Next section start", ft = "tex" },
		{ "][", desc = "TeX: Next section end", ft = "tex" },
		{ "]m", desc = "TeX: Next section", ft = "tex" },
		{ "]M", desc = "TeX: Next section end", ft = "tex" },
		{ "]n", desc = "TeX: Next environment", ft = "tex" },
		{ "]N", desc = "TeX: Next environment end", ft = "tex" },
		{ "]r", desc = "TeX: Next item", ft = "tex" },
		{ "]R", desc = "TeX: Next item end", ft = "tex" },
		{ "]/", desc = "TeX: Next comment", ft = "tex" },
		{ "]*", desc = "TeX: Next comment end", ft = "tex" },

		{ "[", group = "TeX Previous Motions", ft = "tex" },
		{ "[]", desc = "TeX: Previous section end", ft = "tex" },
		{ "[[", desc = "TeX: Previous section start", ft = "tex" },
		{ "[m", desc = "TeX: Previous section", ft = "tex" },
		{ "[M", desc = "TeX: Previous section end", ft = "tex" },
		{ "[n", desc = "TeX: Previous environment", ft = "tex" },
		{ "[N", desc = "TeX: Previous environment end", ft = "tex" },
		{ "[r", desc = "TeX: Previous item", ft = "tex" },
		{ "[R", desc = "TeX: Previous item end", ft = "tex" },
		{ "[/", desc = "TeX: Previous comment", ft = "tex" },
		{ "[*", desc = "TeX: Previous comment end", ft = "tex" },

		-- Special TeX keys
		{ "%", desc = "TeX: Match delimiter", ft = "tex" },
	})
end

return M

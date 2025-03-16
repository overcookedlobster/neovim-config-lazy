local ls = require("luasnip")

-- Define the shorthand functions
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep

-- Load helper functions
local helpers = require('personal.luasnip-helper-funcs')
local get_visual = helpers.get_visual

-- Math context detection
local tex = {}
tex.in_mathzone = function() return vim.fn['vimtex#syntax#in_mathzone']() == 1 end
tex.in_text = function() return not tex.in_mathzone() end

-- Helper function to load snippets from a file
local function load_snippets(file)
    local status, snippets = pcall(function()
        -- Create a new environment with the shorthand functions and other necessities
        local env = {
            s = s, sn = sn, t = t, i = i, f = f, d = d, c = c,
            fmt = fmt, fmta = fmta, rep = rep,
            ls = ls,  -- Also pass the entire luasnip module
            vim = vim,  -- Pass vim module for vim.fn calls
            require = require,  -- Include the require function
            get_visual = get_visual,  -- Pass the get_visual function
            tex = tex  -- Pass the tex table with its functions
        }
        -- Set the environment's metatable to fall back to the global environment
        setmetatable(env, {__index = _G})

        -- Load the file in this environment
        local fn = vim.fn
        local config_path = fn.stdpath('config')
        local chunk, err = loadfile(config_path .. "/snippets/tex/" .. file .. ".lua", "t", env)
        if chunk then
            return chunk()
        else
            error(err)
        end
    end)
    if status then
        return snippets
    else
        print("Error loading " .. file .. ".lua: " .. snippets)
        return {}
    end
end

-- Load all snippet files
local delimiter = load_snippets("delimiter")
local environments = load_snippets("environments")
local fonts = load_snippets("fonts")
local greek = load_snippets("greek")
local luatex = load_snippets("luatex")
local math = load_snippets("math")
local static = load_snippets("static")
local system = load_snippets("system")
local test = load_snippets("test")
local tmp = load_snippets("tmp")

-- Combine all snippets
local snippets = {}
for _, snip_table in ipairs({
    delimiter, environments, fonts, greek, luatex,
    math, static, system, test, tmp
}) do
    for _, snip in ipairs(snip_table) do
        table.insert(snippets, snip)
    end
end

-- You can add any additional snippets directly in tex.lua if you want
table.insert(snippets, s("texmain", {
    t("\\documentclass{article}\n\\begin{document}\n\n"),
    i(1),
    t("\n\n\\end{document}")
}))

-- Return the snippets for use by LuaSnip's loader
return snippets

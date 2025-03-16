-- At the beginning of the file
print("Loading SystemVerilog snippets")

-- After loading each file
print("Loaded " .. (non_syn and #non_syn or 0) .. " non-synthesizable snippets")
print("Loaded " .. (syn and #syn or 0) .. " synthesizable snippets")
print("Loaded " .. (uvm and #uvm or 0) .. " UVM snippets")

-- Before returning
print("Returning " .. #snippets .. " total SystemVerilog snippets")local ls = require("luasnip")

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
        }
        -- Set the environment's metatable to fall back to the global environment
        setmetatable(env, {__index = _G})

        local fn = vim.fn
        local config_path = fn.stdpath('config')
        local chunk, err = loadfile(config_path .. "/snippets/sv/" .. file .. ".lua", "t", env)
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
local non_syn = load_snippets("non_synthesizable")
local syn = load_snippets("synthesizable")
local uvm = load_snippets("uvm")

-- Combine all snippets
local snippets = {}
for _, snip_table in ipairs({syn, non_syn, uvm}) do
    for _, snip in ipairs(snip_table) do
        table.insert(snippets, snip)
    end
end

-- Return the snippets for use by LuaSnip's loader
return snippets

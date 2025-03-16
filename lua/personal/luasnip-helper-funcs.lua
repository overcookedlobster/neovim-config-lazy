-- ~/.config/nvim/lua/personal/luasnip-helper-funcs.lua
local ls = require("luasnip")

local M = {}

-- Helper function for working with visual selections
M.get_visual = function(args, parent)
    if (#parent.snippet.env.SELECT_RAW > 0) then
        return ls.snippet_node(nil, {
            ls.insert_node(1, parent.snippet.env.SELECT_RAW)
        })
    else
        return ls.snippet_node(nil, {
            ls.insert_node(1, '')
        })
    end
end

-- Get the current date in ISO format
M.get_ISO_8601_date = function()
    return os.date("%Y-%m-%d")
end

-- Get current filename
M.get_filename = function()
    return vim.fn.expand("%:t")
end

-- Get current filepath
M.get_filepath = function()
    return vim.fn.expand("%:p")
end

return M

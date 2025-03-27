-- ~/.config/nvim/snippets/all.lua
-- Global snippets available in all file types

local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta

-- Helper function to get the current date in ISO format
local function get_ISO_8601_date()
  return os.date("%Y-%m-%d")
end

-- Helper function for working with visual selections
local function get_visual(args, parent)
  if (#parent.snippet.env.SELECT_RAW > 0) then
    return sn(nil, i(1, parent.snippet.env.SELECT_RAW))
  else
    return sn(nil, i(1, ''))
  end
end

-- Snippets
return {
  -- Date insertion
  s("date", {
    f(function() return os.date("%Y-%m-%d") end, {}),
  }),

  -- Date and time insertion
  s("datetime", {
    f(function() return os.date("%Y-%m-%d %H:%M:%S") end, {}),
  }),

  -- Todo comment
  s("todo", fmt("TODO: {} ({})", {
    i(1, "Description"),
    f(get_ISO_8601_date),
  })),

  -- Fixme comment
  s("fixme", fmt("FIXME: {} ({})", {
    i(1, "Description"),
    f(get_ISO_8601_date),
  })),

  -- Note comment
  s("note", fmt("NOTE: {} ({})", {
    i(1, "Description"),
    f(get_ISO_8601_date),
  })),

  -- Simple header box
  s("box", fmt([[
/*
 * {}
 * {}
 */
]], {
    i(1, "Title"),
    i(2, "Description"),
  })),

  -- Markdown header with auto-timestamp
  s("mdheader", fmt([[
# {}

> Created: {}
> Last Updated: {}

{}

]], {
    i(1, "Title"),
    f(get_ISO_8601_date),
    f(get_ISO_8601_date),
    i(2, "Content"),
  })),

  -- Visual selection snippets
  s({trig = "box*", snippetType = "autosnippet"}, fmt([[
/*
 * {}
 */
]], {
    d(1, get_visual),
  })),

  -- Visual selection with bold markdown
  s({trig = "bold"}, fmt("**{}**", {
    d(1, get_visual),
  })),

  -- Visual selection with italic markdown
  s({trig = "ital"}, fmt("*{}*", {
    d(1, get_visual),
  })),

  -- Visual selection with code markdown
  s({trig = "code"}, fmt("`{}`", {
    d(1, get_visual),
  })),

  -- License header for code files
  s("license", fmt([[
/**
 * {}
 *
 * Copyright (c) {} {}
 *
 * {}
 */
]], {
    i(1, "Description"),
    f(function() return os.date("%Y") end, {}),
    i(2, "Author Name"),
    c(3, {
      t("MIT License"),
      t("Apache License 2.0"),
      t("GNU General Public License v3.0"),
      t("BSD 3-Clause License"),
      i(nil, "License"),
    }),
  })),
  -- Parentheses with visual selection
  s({trig = "(", snippetType = "autosnippet"}, fmt("({})", {
    d(1, get_visual),
  })),

  -- Curly braces with visual selection
  s({trig = "{", snippetType = "autosnippet"}, fmt("{{{}}}", {
    d(1, get_visual),
  })),
  -- Square brackets with visual selection
  s({trig = "[", snippetType = "autosnippet"}, fmt("[{}]", {
    d(1, get_visual),
  })),

  -- Double quotes with visual selection
  s({trig = "\"", snippetType = "autosnippet"}, fmt("\"{}\"", {
    d(1, get_visual),
  })),

  s({trig = "\'"}, fmt("\'{}\'",{
    d(1, get_visual)
  })),
}

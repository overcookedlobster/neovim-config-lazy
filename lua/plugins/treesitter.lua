-- File: lua/plugins/treesitter.lua
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  priority = 600,  -- Load before most plugins but after critical ones
  config = function()
    require("nvim-treesitter.configs").setup({
      -- A list of parser names, or "all" (parsers with maintainers)
      ensure_installed = {
        "lua",      -- For Neovim config files
        "vim",      -- For Vim script files
        "vimdoc",   -- For help files
        "latex",    -- For LaTeX files
        "bibtex",   -- For BibTeX files
        "markdown", -- For documentation
        "bash",     -- For shell scripts
        "python",   -- If you work with Python
      },

      -- Install parsers synchronously (only applied to `ensure_installed`)
      sync_install = false,

      -- Automatically install missing parsers when entering buffer
      auto_install = true,

      -- List of parsers to ignore installing (for "all")
      ignore_install = {},

      highlight = {
        enable = true,  -- Enable TreeSitter highlighting

        -- Disable highlighting for specific filetypes
        disable = {},

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Using this option may slow down your editor, and you may see duplicate highlights.
        additional_vim_regex_highlighting = false,
      },

      indent = {
        enable = true,  -- Enable TreeSitter-based indentation
        disable = {"tex"}, -- Disable TS indentation for tex files as VimTeX handles this better
      },
    })
  end,
}

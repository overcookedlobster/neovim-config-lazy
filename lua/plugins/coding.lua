-- ~/.config/nvim/lua/plugins/coding.lua
-- Coding-related plugins

return {
  -- Completion: nvim-cmp
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",     -- LSP source
      "hrsh7th/cmp-buffer",       -- Buffer source
      "hrsh7th/cmp-path",         -- Path source
      "hrsh7th/cmp-cmdline",      -- Command line source
      "hrsh7th/cmp-omni",         -- Omni completion source
      "saadparwaiz1/cmp_luasnip", -- Snippet source
      "L3MON4D3/LuaSnip",         -- Snippet engine
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ["<C-k>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'omni' },
          { name = 'buffer' },
          { name = 'path' },
        }),
        completion = {
          autocomplete = false, -- Disable automatic popup globally
        },
        experimental = {
          ghost_text = false,
        },
      })

      -- Use buffer source for `/` and `?`
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })

      -- Use cmdline & path source for ':'
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        })
      })

      -- Set up a keymap to manually trigger completion
      vim.keymap.set('i', '<C-Space>', function()
        if cmp.visible() then
          cmp.close()
        else
          cmp.complete()
        end
      end, { silent = true })

      -- Special configuration for SystemVerilog files
      cmp.setup.filetype('systemverilog', {
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'omni' },
          { name = 'buffer' },
          { name = 'path' },
        }),
        completion = {
          autocomplete = { 'TextChanged' } -- Specify events for auto-completion
        },
      })

      -- Special configuration for LaTeX files
      cmp.setup.filetype('tex', {
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'omni' },
          { name = 'vimtex' },
          { name = 'buffer' },
          { name = 'path' },
        }),
        completion = {
          autocomplete = { 'TextChanged' } , -- Enable automatic popup for tex files
        },
      })
    end,
  },

  -- Snippets: LuaSnip
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    dependencies = {
      "rafamadriz/friendly-snippets", -- Collection of snippets
    },
    config = function()
      local ls = require("luasnip")

      ls.config.set_config({
        history = false,             -- Don't store snippet history for less overhead
        enable_autosnippets = true,  -- Allow autotrigger snippets
        store_selection_keys = "<Tab>", -- For equivalent of UltiSnips visual selection
        region_check_events = 'InsertEnter', -- Event on which to check for exiting a snippet's region
        delete_check_events = 'InsertLeave',
      })

      -- Load friendly-snippets
      require("luasnip.loaders.from_vscode").lazy_load()

      -- Load custom snippets
      require("luasnip.loaders.from_lua").lazy_load({paths = vim.fn.stdpath('config') .. "/snippets/"})

      -- Keymaps for snippet navigation
      vim.cmd([[
        " Jump forward
        imap <silent><expr> jk luasnip#jumpable(1) ? '<Plug>luasnip-jump-next' : 'jk'
        smap <silent><expr> jk luasnip#jumpable(1) ? '<Plug>luasnip-jump-next' : 'jk'

        " Jump backward
        imap <silent><expr> jh luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : 'jh'
        smap <silent><expr> jh luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : 'jh'

        " Cycle forward through choice nodes with Control-F
        imap <silent><expr> <C-f> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-f>'
        smap <silent><expr> <C-f> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-f>'
      ]])

      -- Command to refresh snippets
      vim.keymap.set('', '<Leader>U',
        '<Cmd>lua require("luasnip.loaders.from_lua").lazy_load({paths = "' .. vim.fn.stdpath('config') .. '/snippets/"})<CR><Cmd>echo "Snippets refreshed!"<CR>',
        { desc = "Refresh snippets" })
    end,
  },

  -- Syntax support for SystemVerilog
  {
    "vhda/verilog_systemverilog.vim",
    ft = { "verilog", "systemverilog" },
    config = function()
      vim.g.verilog_syntax_fold_lst = "block,function,task,specify,module,class,covergroup"
      vim.g.verilog_disable_indent_lst = "eos"
      vim.g.verilog_indent_modules = 1
      vim.g.verilog_indent_width = 2
    end,
  },

  -- In lua/plugins/coding.lua
  {
    "luk400/vim-jukit",
    lazy = false,      -- Don't lazy load this plugin
    priority = 1000,   -- Highest priority to load very early
    init = function()  -- Execute before plugin loads
      -- Force the correct syntax file path
      vim.g.jukit_text_syntax_file = vim.fn.expand('$VIMRUNTIME/syntax/markdown.vim')

      -- Check if file exists and use fallback if needed
      if vim.fn.filereadable(vim.g.jukit_text_syntax_file) ~= 1 then
        vim.g.jukit_text_syntax_file = vim.fn.expand('$VIMRUNTIME/syntax/text.vim')
      end

      -- Other vim-jukit settings
      vim.g.python3_host_prog = '/usr/bin/python3'
      vim.g.jukit_shell_cmd = 'ipython3'
      vim.g.jukit_terminal = 'nvimterm'
      vim.g.jukit_auto_output_hist = 1
      vim.g.jukit_use_tcomment = 1
      vim.g.jukit_enable_textcell_bg = 0  -- Try disabling this feature

      -- Print path for debugging
      -- vim.api.nvim_create_autocmd("VimEnter", {
      --   callback = function()
      --     vim.notify("vim-jukit using syntax file: " .. vim.g.jukit_text_syntax_file)
      --   end,
      --   once = true
      -- })
    end
  },
  -- Clipboard image saver
  {
    "postfen/clipboard-image.nvim",
    config = function()
      require('clipboard-image').setup {
        default = {
          img_dir = vim.fn.expand("~/Pictures/clipboard_images"),
          img_dir_txt = vim.fn.expand("~/Pictures/clipboard_images"),
          img_name = function()
            return "screenshot_" .. os.date("%Y%m%d%H%M%S") .. "_" .. math.random(1000)
          end,
          affix = "![clipboard_image](%s)"
        }
      }
    end,
  },

  -- Markdown preview
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop" },
    build = function() vim.fn["mkdp#util#install"]() end,
    init = function()
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_refresh_slow = 1
    end,
    ft = { "markdown" },
  },

  -- Markdown support
  {
    "preservim/vim-markdown",
    dependencies = { "godlygeek/tabular" },
    ft = { "markdown" },
    init = function()
      vim.g.vim_markdown_folding_disabled = 1
      vim.g.vim_markdown_conceal = 2
      vim.g.vim_markdown_conceal_code_blocks = 0
      vim.g.vim_markdown_math = 1
      vim.g.vim_markdown_frontmatter = 1
      vim.g.vim_markdown_strikethrough = 1
    end,
  },

  -- Additional coding tools
  {
    "jakemason/ouroboros",  -- File navigation
  },

  -- FZF
  {
    "junegunn/fzf",
    build = function() vim.fn['fzf#install']() end,
  },

  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
}

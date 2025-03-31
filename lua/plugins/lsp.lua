-- ~/.config/nvim/lua/plugins/lsp.lua
-- LSP-related plugins

return {
  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",            -- LSP completion
      "williamboman/mason.nvim",          -- Portable package manager for Neovim
      "williamboman/mason-lspconfig.nvim", -- Bridges mason.nvim with lspconfig
    },
    config = function()
      -- Set up Mason
      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      })

      -- Set up Mason-lspconfig
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",            -- Lua
          "pyright",           -- Python
          "clangd",            -- C/C++
        },
        automatic_installation = true,
      })

      -- LSP handlers configuration
      local handlers = {
        ["textDocument/hover"] = vim.lsp.with(
          vim.lsp.handlers.hover, { border = "rounded" }
        ),
        ["textDocument/signatureHelp"] = vim.lsp.with(
          vim.lsp.handlers.signature_help, { border = "rounded" }
        ),
      }

      -- Diagnostic configuration
      vim.diagnostic.config({
        virtual_text = false,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })

      -- Set diagnostic signs
      local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      -- Global LSP on_attach function
      local on_attach = function(client, bufnr)
        -- Enable completion triggered by <c-x><c-o>
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Buffer local mappings
        local opts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration,
          vim.tbl_extend("force", opts, { desc = "LSP: Go to declaration" }))
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition,
          vim.tbl_extend("force", opts, { desc = "LSP: Go to definition" }))
        vim.keymap.set('n', 'K', vim.lsp.buf.hover,
          vim.tbl_extend("force", opts, { desc = "LSP: Hover information" }))
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation,
          vim.tbl_extend("force", opts, { desc = "LSP: Go to implementation" }))
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help,
          vim.tbl_extend("force", opts, { desc = "LSP: Signature help" }))
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition,
          vim.tbl_extend("force", opts, { desc = "LSP: Type definition" }))
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename,
          vim.tbl_extend("force", opts, { desc = "LSP: Rename" }))
        vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action,
          vim.tbl_extend("force", opts, { desc = "LSP: Code action" }))
        vim.keymap.set('n', 'gr', vim.lsp.buf.references,
          vim.tbl_extend("force", opts, { desc = "LSP: References" }))
        vim.keymap.set('n', '<space>f', function()
          vim.lsp.buf.format { async = true }
        end, vim.tbl_extend("force", opts, { desc = "LSP: Format buffer" }))

        -- Enable inlay hints if supported (with proper version checking)
        if client.server_capabilities.inlayHintProvider then
          -- Check Neovim version for proper API support
          if vim.fn.has("nvim-0.10.0") == 1 then
            -- Safe call with pcall to prevent errors
            pcall(function()
              vim.lsp.inlay_hint.enable(bufnr, true)
            end)
          end
        end

        -- Set up document highlight
        if client.server_capabilities.documentHighlightProvider then
          local group = vim.api.nvim_create_augroup("LSPDocumentHighlight", { clear = false })
          vim.api.nvim_clear_autocmds({ buffer = bufnr, group = group })
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer = bufnr,
            group = group,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd("CursorMoved", {
            buffer = bufnr,
            group = group,
            callback = vim.lsp.buf.clear_references,
          })
        end
      end

      -- Default capabilities
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Configure individual language servers
      local lspconfig = require("lspconfig")

      -- Lua
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        handlers = handlers,
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" }, -- Recognize 'vim' global
            },
            workspace = {
              library = {
                vim.env.VIMRUNTIME,
                "${3rd}/luv/library",
                "${3rd}/busted/library",
              },
              checkThirdParty = false,
            },
            telemetry = {
              enable = false,
            },
          },
        },
      })

      -- Python
      lspconfig.pyright.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        handlers = handlers,
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
      })

      -- C/C++
      lspconfig.clangd.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        handlers = handlers,
        cmd = {
          "clangd",
          "--background-index",
          "--suggest-missing-includes",
          "--clang-tidy",
          "--header-insertion=iwyu",
        },
      })

      -- SystemVerilog
      lspconfig.svls.setup({
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          on_attach(client, bufnr)

          -- Disable diagnostics for SystemVerilog files
          vim.diagnostic.disable(bufnr)

          print("SystemVerilog LSP attached with enhanced context support")
        end,
        handlers = handlers,
        settings = {
          systemverilog = {
            -- File indexing configuration
            includeIndexing = {
              "**/*.sv",
              "**/*.svh",
              "**/*.v",
              "**/*.vh"
            },
            excludeIndexing = {
              "**/sim/**",
              "**/tb/**"
            },
            -- Library paths - important for finding built-in classes and methods
            libraryFiles = {
              "**/*.sv",
              "**/*.svh",
              "**/*.v",
              "**/*.vh"
            },
            -- Enhanced feature set
            features = {
              classContext = true,
              memberCompletion = true,
              hover = true,
              signatureHelp = true,
              -- Additional features for better context awareness
              semanticHighlighting = true,
              documentSymbols = true,
              documentFormatting = true
            },
            -- Parser configuration for better context understanding
            parser = {
              -- Enable class and covergroup parsing
              parseClassProperties = true,
              parseCovergroups = true,
              parseAssertions = true,
              parseConstraints = true
            },
            -- Type information
            typeHierarchy = {
              enabled = true,
              depth = 3
            }
          }
        },
        -- Improved workspace configuration
        root_dir = function(fname)
          local util = require('lspconfig.util')
          return util.root_pattern(
            'svls.toml',
            '.svls.toml',
            '.git',
            'package.sv'
          )(fname) or util.path.dirname(fname)
        end
      })

      -- Disable automatic creation of svls.toml files
      local function ensure_svls_config()
        -- Function intentionally left empty to disable automatic config creation
      end

      -- Automatically create SVLS config
      ensure_svls_config()
    end,
  },

  -- Null-LS - Additional diagnostics, formatting, and code actions
  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      local null_ls = require("null-ls")

      -- Verilator diagnostic for SystemVerilog
      local verilator = null_ls.builtins.diagnostics.verilator.with({
        extra_args = { "--lint-only", "-Wall", "-I" .. (os.getenv("UVM_HOME") or "") .. "/src"},
        method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
      })

      local update_in_progress = false

      null_ls.setup({
        sources = { verilator },
        on_attach = function(client, bufnr)
          local augroup = vim.api.nvim_create_augroup("NullLsDiagnostics", { clear = true })
          vim.api.nvim_create_autocmd({ "CursorHold", "BufWritePost" }, {
            group = augroup,
            buffer = bufnr,
            callback = function()
              if not update_in_progress then
                update_in_progress = true
                vim.defer_fn(function()
                  vim.diagnostic.show()
                  update_in_progress = false
                end, 100)  -- 100ms delay
              end
            end,
          })
        end,
      })
    end,
  },

  -- Enhanced text illumination
  {
    "RRethy/vim-illuminate",
    config = function()
      vim.cmd [[
        let g:Illuminate_useDeprecated = 1
        let g:Illuminate_ftwhitelist = ['python, c, php']
      ]]

      -- Set the highlighting style
      vim.api.nvim_command [[hi def link LspReferenceText CursorLine]]
      vim.api.nvim_command [[hi def link LspReferenceWrite CursorLine]]
      vim.api.nvim_command [[hi def link LspReferenceRead CursorLine]]
    end,
  },

  -- Debugging with DAP (Core functionality)
  {
    "mfussenegger/nvim-dap",
    config = function()
      -- Get the DAP module safely
      local status_ok, dap = pcall(require, "dap")
      if not status_ok then
        vim.notify("nvim-dap not available", vim.log.levels.WARN)
        return
      end

      -- Set up key mappings for DAP
      vim.keymap.set('n', '<Leader>dp', function() dap.continue() end,
        { desc = "Debug: Continue" })

      vim.keymap.set('n', '<Leader>dn', function() dap.step_over() end,
        { desc = "Debug: Step over" })
      vim.keymap.set('n', '<Leader>di', function() dap.step_into() end,
        { desc = "Debug: Step into" })
      vim.keymap.set('n', '<Leader>do', function() dap.step_out() end,
        { desc = "Debug: Step out" })

      vim.keymap.set('n', '<Leader>dd', function() dap.toggle_breakpoint() end,
        { desc = "Debug: Toggle breakpoint" })
      vim.keymap.set('n', '<Leader>dD', function() dap.set_breakpoint() end,
        { desc = "Debug: Set breakpoint" })
      vim.keymap.set('n', '<Leader>dl', function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end,
        { desc = "Debug: Set log point" })

      vim.keymap.set('n', '<Leader>dr', function() dap.repl.toggle() end,
        { desc = "Debug: Toggle REPL" })

      vim.keymap.set('n', '<Leader>dl', function() dap.run_last() end,
        { desc = "Debug: Run last" })
    end,
  },

  -- DAP UI - Enhanced debugging UI
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap", -- Explicit dependency
      "nvim-neotest/nvim-nio"
    },
    config = function()
      -- Safely load dapui module
      local status_ok, dapui = pcall(require, "dapui")
      if not status_ok then
        vim.notify("nvim-dap-ui not available", vim.log.levels.WARN)
        return
      end

      -- Set up DAPUI
      dapui.setup({
        -- Default configuration
        icons = { expanded = "▾", collapsed = "▸", current_frame = "→" },
        mappings = {
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              "breakpoints",
              "stacks",
              "watches",
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              "repl",
              "console",
            },
            size = 10,
            position = "bottom",
          },
        },
        floating = {
          max_height = nil,
          max_width = nil,
          border = "single",
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
        windows = { indent = 1 },
        render = {
          max_type_length = nil,
          max_value_lines = 100,
        }
      })

      -- Now, safely get DAP for event handling
      local dap_status, dap = pcall(require, "dap")
      if dap_status then
        -- Set up automatic UI open/close with debugging sessions
        dap.listeners.after.event_initialized["dapui_config"] = function()
          dapui.open()
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
          dapui.close()
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
          dapui.close()
        end
      end

      -- Additional keymaps for DAP UI
      vim.keymap.set({'n', 'v'}, '<Leader>dh', function()
        local widgets_status, widgets = pcall(require, 'dap.ui.widgets')
        if widgets_status then
          widgets.hover()
        end
      end, { desc = "Debug: Hover" })

      vim.keymap.set({'n', 'v'}, '<Leader>dv', function()
        local widgets_status, widgets = pcall(require, 'dap.ui.widgets')
        if widgets_status then
          widgets.preview()
        end
      end, { desc = "Debug: Preview" })

      vim.keymap.set('n', '<Leader>df', function()
        local widgets_status, widgets = pcall(require, 'dap.ui.widgets')
        if widgets_status then
          widgets.centered_float(widgets.frames)
        end
      end, { desc = "Debug: Show frames" })

      vim.keymap.set('n', '<Leader>ds', function()
        local widgets_status, widgets = pcall(require, 'dap.ui.widgets')
        if widgets_status then
          widgets.centered_float(widgets.scopes)
        end
      end, { desc = "Debug: Show scopes" })
    end,
  },

  -- DAP Virtual Text - Shows values on top of code while debugging
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      -- Safely load virtual text module
      local status_ok, virtual_text = pcall(require, "nvim-dap-virtual-text")
      if not status_ok then
        vim.notify("nvim-dap-virtual-text not available", vim.log.levels.WARN)
        return
      end

      -- Configure virtual text
      virtual_text.setup {
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        commented = false,
        virt_text_pos = 'eol',
        all_frames = false,
        virt_lines = false,
        virt_text_win_col = nil
      }
    end,
  },
}

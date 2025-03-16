-- File: lua/plugins/tex.lua
return {
  "lervag/vimtex",
  lazy = false,      -- CRITICAL: Load on startup, not lazy-loaded
  priority = 1000,   -- High priority to load before other plugins
  ft = {"tex", "latex"},
  init = function()
    -- OS detection (from tex.vim)
    if not vim.g.os_current then
      if vim.fn.has("win64") == 1 or vim.fn.has("win32") == 1 or vim.fn.has("win16") == 1 then
        vim.g.os_current = "Windows"
      else
        vim.g.os_current = vim.fn.system('uname'):gsub('\n', '')
      end
    end

    -- From tex.vim
    vim.g.tex_flavor = 'latex'  -- recognize tex files as latex
    vim.g.tex_indent_items = 0  -- Turn off automatic indenting in enumerated environments

    -- From vimtex.vim - compiler settings
    vim.g.vimtex_compiler_method = 'latexmk'
    vim.g.vimtex_compiler_latexmk = {
      build_dir = '',
      options = {
        '-pdf',
        '-shell-escape',
        '-verbose',
        '-file-line-error',
        '-synctex=1',
        '-interaction=nonstopmode',
      },
    }

    -- CRITICAL SETTINGS TO FIX SYNTAX HIGHLIGHTING
    vim.g.vimtex_syntax_enabled = 1
    vim.g.vimtex_syntax_conceal_enable = 1

    -- VimTeX view settings
    vim.g.vimtex_view_method = 'zathura'
    vim.g.vimtex_view_general_options = [[--unique file:@pdf\#src:@line@tex]]

    -- Compiler settings - ensure nvr is used for server
    vim.g.vimtex_compiler_progname = 'nvr'

    -- QuickFix settings
    vim.g.vimtex_quickfix_open_on_warning = 0
    vim.g.vimtex_quickfix_ignore_filters = {
      'Underfull \\hbox',
      'Overfull \\hbox',
      'LaTeX Warning: .\\+ float specifier changed to',
      'LaTeX hooks Warning',
      'Package siunitx Warning: Detected the "physics" package:',
      'Package hyperref Warning: Token not allowed in a PDF string',
    }
  end,
  config = function()
    -- Create a TeX settings group
    local tex_group = vim.api.nvim_create_augroup("vimtex_config", { clear = true })

    -- TeX file detection
    vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
      pattern = {"*.tex", "*.sty", "*.dtx", "*.ltx", "*.cls"},
      callback = function()
        vim.bo.filetype = "tex"
      end,
    })

    -- Set up TeX indentation (from tex.vim)
    vim.api.nvim_create_autocmd("FileType", {
      group = tex_group,
      pattern = "tex",
      callback = function()
        vim.opt_local.expandtab = true
        vim.opt_local.autoindent = true
        vim.opt_local.tabstop = 4
        vim.opt_local.softtabstop = 4
        vim.opt_local.shiftwidth = 4

        -- Ensure VimTeX is initialized
        if vim.fn.exists('*vimtex#init') == 1 then
          vim.cmd('call vimtex#init()')
        end

        -- Enable syntax highlighting
        vim.cmd('syntax enable')

        -- Write inverse search target (from tex.vim)
        vim.fn.system('echo TEX > /tmp/inverse-search-target.txt')
      end
    })

    -- Get Vim's window ID for switching focus from Zathura to Vim using xdotool.
    if vim.g.os_current == "Linux" and not vim.g.vim_window_id then
      vim.g.vim_window_id = vim.fn.system("xdotool getactivewindow")
    end

    -- Forward search implementation (from tex.vim)
    if vim.g.os_current == "Linux" then
      vim.api.nvim_create_autocmd("User", {
        group = tex_group,
        pattern = "VimtexEventView",
        callback = function()
          -- Give window manager time to recognize focus moved to Zathura
          vim.cmd("sleep 200m")
          vim.cmd("!xdotool windowfocus " .. vim.g.vim_window_id)
          vim.cmd("redraw!")
        end
      })
    elseif vim.g.os_current == "Darwin" then
      vim.api.nvim_create_autocmd("User", {
        group = tex_group,
        pattern = "VimtexEventViewReverse",
        callback = function()
          vim.cmd("!open -a Alacritty")
          vim.cmd("redraw!")
        end
      })
    end

    -- Close viewers when VimTeX buffers are closed (from vimtex.vim)
    vim.api.nvim_create_autocmd("User", {
      group = tex_group,
      pattern = "VimtexEventQuit",
      callback = function()
        if vim.fn.executable('xdotool') == 1 and
           vim.b.vimtex and vim.b.vimtex.viewer and
           vim.b.vimtex.viewer.xwin_id and
           vim.b.vimtex.viewer.xwin_id > 0 then
          vim.fn.system('xdotool windowclose ' .. vim.b.vimtex.viewer.xwin_id)
        end
      end
    })

    -- Toggle shell escape function (from vimtex.vim)
    local function toggle_shell_escape()
      if not vim.g.vimtex_compiler_latexmk or not vim.g.vimtex_compiler_latexmk.options then
        vim.notify("VimTeX compiler options not properly set up", vim.log.levels.ERROR)
        return
      end

      local options = vim.g.vimtex_compiler_latexmk.options
      local shell_escape_index = nil

      for i, option in ipairs(options) do
        if option == '-shell-escape' then
          shell_escape_index = i
          break
        end
      end

      if shell_escape_index then
        -- Disable shell escape
        table.remove(options, shell_escape_index)
        vim.notify("Shell escape disabled")
      else
        -- Enable shell escape
        table.insert(options, '-shell-escape')
        vim.notify("Shell escape enabled")
      end

      vim.cmd("VimtexReload")
      vim.cmd("VimtexClean")
    end

    -- Register the TexToggleShellEscape command
    vim.api.nvim_create_user_command('TexToggleShellEscape', toggle_shell_escape, {})

    -- Set up key mappings (from tex.vim and vimtex.vim)
    vim.api.nvim_create_autocmd("FileType", {
      group = tex_group,
      pattern = "tex",
      callback = function()
        -- Compilation commands (from tex.vim)
        vim.keymap.set("n", "<leader>c", "<Cmd>update<CR><Cmd>VimtexCompileSS<CR>", {buffer = true})
        vim.keymap.set("n", "<leader>r", "<Cmd>update<CR><Cmd>VimtexCompileSS<CR>", {buffer = true})
        vim.keymap.set("n", "<leader>v", "<plug>(vimtex-view)", {buffer = true})
        vim.keymap.set("n", "<leader>i", "<plug>(vimtex-info)", {buffer = true})
        vim.keymap.set("n", "<leader>t", "<Cmd>VimtexTocToggle<CR>", {buffer = true})
        vim.keymap.set("n", "<leader>te", "<Cmd>TexToggleShellEscape<CR>", {buffer = true})

        -- Define mappings (from vimtex.vim)
        -- Delete mappings
        vim.keymap.set("n", "dse", "<plug>(vimtex-env-delete)", {buffer = true})
        vim.keymap.set("n", "dsc", "<plug>(vimtex-cmd-delete)", {buffer = true})
        vim.keymap.set("n", "dsm", "<plug>(vimtex-env-delete-math)", {buffer = true})
        vim.keymap.set("n", "dsd", "<plug>(vimtex-delim-delete)", {buffer = true})

        -- Change mappings
        vim.keymap.set("n", "cse", "<plug>(vimtex-env-change)", {buffer = true})
        vim.keymap.set("n", "csc", "<plug>(vimtex-cmd-change)", {buffer = true})
        vim.keymap.set("n", "csm", "<plug>(vimtex-env-change-math)", {buffer = true})
        vim.keymap.set("n", "csd", "<plug>(vimtex-delim-change-math)", {buffer = true})

        -- Toggle mappings
        vim.keymap.set("n", "tsf", "<plug>(vimtex-cmd-toggle-frac)", {buffer = true})
        vim.keymap.set("n", "tsc", "<plug>(vimtex-cmd-toggle-star)", {buffer = true})
        vim.keymap.set("n", "tse", "<plug>(vimtex-env-toggle-star)", {buffer = true})
        vim.keymap.set("n", "tsd", "<plug>(vimtex-delim-toggle-modifier)", {buffer = true})
        vim.keymap.set("n", "tsD", "<plug>(vimtex-delim-toggle-modifier-reverse)", {buffer = true})
        vim.keymap.set("n", "tsm", "<plug>(vimtex-env-toggle-math)", {buffer = true})
        vim.keymap.set("i", "]]", "<plug>(vimtex-delim-close)", {buffer = true})

        -- Text objects (from vimtex.vim)
        -- Command text objects
        vim.keymap.set("o", "ac", "<plug>(vimtex-ac)", {buffer = true})
        vim.keymap.set("x", "ac", "<plug>(vimtex-ac)", {buffer = true})
        vim.keymap.set("o", "ic", "<plug>(vimtex-ic)", {buffer = true})
        vim.keymap.set("x", "ic", "<plug>(vimtex-ic)", {buffer = true})

        -- Delimiter text objects
        vim.keymap.set("o", "ad", "<plug>(vimtex-ad)", {buffer = true})
        vim.keymap.set("x", "ad", "<plug>(vimtex-ad)", {buffer = true})
        vim.keymap.set("o", "id", "<plug>(vimtex-id)", {buffer = true})
        vim.keymap.set("x", "id", "<plug>(vimtex-id)", {buffer = true})

        -- Environment text objects
        vim.keymap.set("o", "ae", "<plug>(vimtex-ae)", {buffer = true})
        vim.keymap.set("x", "ae", "<plug>(vimtex-ae)", {buffer = true})
        vim.keymap.set("o", "ie", "<plug>(vimtex-ie)", {buffer = true})
        vim.keymap.set("x", "ie", "<plug>(vimtex-ie)", {buffer = true})

        -- Math text objects
        vim.keymap.set("o", "am", "<plug>(vimtex-a$)", {buffer = true})
        vim.keymap.set("x", "am", "<plug>(vimtex-a$)", {buffer = true})
        vim.keymap.set("o", "im", "<plug>(vimtex-i$)", {buffer = true})
        vim.keymap.set("x", "im", "<plug>(vimtex-i$)", {buffer = true})

        -- Item text objects
        vim.keymap.set("o", "ai", "<plug>(vimtex-am)", {buffer = true})
        vim.keymap.set("x", "ai", "<plug>(vimtex-am)", {buffer = true})
        vim.keymap.set("o", "ii", "<plug>(vimtex-im)", {buffer = true})
        vim.keymap.set("x", "ii", "<plug>(vimtex-im)", {buffer = true})

        -- Section/paragraph text objects
        vim.keymap.set("o", "aP", "<plug>(vimtex-aP)", {buffer = true})
        vim.keymap.set("x", "aP", "<plug>(vimtex-aP)", {buffer = true})
        vim.keymap.set("o", "iP", "<plug>(vimtex-iP)", {buffer = true})
        vim.keymap.set("x", "iP", "<plug>(vimtex-iP)", {buffer = true})

        -- Motion mappings
        vim.keymap.set("", "%", "<plug>(vimtex-%)", {buffer = true})
        vim.keymap.set("", "]]", "<plug>(vimtex-]])", {buffer = true})
        vim.keymap.set("", "][", "<plug>(vimtex-][)", {buffer = true})
        vim.keymap.set("", "[]", "<plug>(vimtex-[])", {buffer = true})
        vim.keymap.set("", "[[", "<plug>(vimtex-[[)", {buffer = true})

        -- Section motions
        vim.keymap.set("", "]m", "<plug>(vimtex-]m)", {buffer = true})
        vim.keymap.set("", "]M", "<plug>(vimtex-]M)", {buffer = true})
        vim.keymap.set("", "[m", "<plug>(vimtex-[m)", {buffer = true})
        vim.keymap.set("", "[M", "<plug>(vimtex-[M)", {buffer = true})

        -- Environment motions
        vim.keymap.set("", "]n", "<plug>(vimtex-]n)", {buffer = true})
        vim.keymap.set("", "]N", "<plug>(vimtex-]N)", {buffer = true})
        vim.keymap.set("", "[n", "<plug>(vimtex-[n)", {buffer = true})
        vim.keymap.set("", "[N", "<plug>(vimtex-[N)", {buffer = true})

        -- Item motions
        vim.keymap.set("", "]r", "<plug>(vimtex-]r)", {buffer = true})
        vim.keymap.set("", "]R", "<plug>(vimtex-]R)", {buffer = true})
        vim.keymap.set("", "[r", "<plug>(vimtex-[r)", {buffer = true})
        vim.keymap.set("", "[R", "<plug>(vimtex-[R)", {buffer = true})

        -- Comment motions
        vim.keymap.set("", "]/", "<plug>(vimtex-]/)", {buffer = true})
        vim.keymap.set("", "]*", "<plug>(vimtex-]star)", {buffer = true})
        vim.keymap.set("", "[/", "<plug>(vimtex-[/)", {buffer = true})
        vim.keymap.set("", "[*", "<plug>(vimtex-[star)", {buffer = true})

        -- Check for minted package and enable shell escape if needed
        local cmd = 'head -n 20 ' .. vim.fn.expand('%') .. ' | grep "minted" > /dev/null'
        local result = vim.fn.system(cmd)
        if vim.v.shell_error == 0 then -- minted found
          if not vim.tbl_contains(vim.g.vimtex_compiler_latexmk.options, '-shell-escape') then
            table.insert(vim.g.vimtex_compiler_latexmk.options, '-shell-escape')
            vim.notify("Shell escape enabled for minted package")
          end
        end
      end
    })

    -- Add a debug command to check VimTeX status
    vim.api.nvim_create_user_command('CheckVimtex', function()
      vim.notify("VimTeX loaded: " .. tostring(vim.fn.exists('*vimtex#init')))
      local cmds = vim.fn.getcompletion('Vimtex', 'cmdline')
      vim.notify("Available VimTeX commands: " .. vim.inspect(cmds))
      vim.notify("Current filetype: " .. vim.bo.filetype)
      vim.notify("Syntax enabled: " .. tostring(vim.g.syntax_on or vim.g.syntax_manual))
    end, {})
  end
}

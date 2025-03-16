-- ~/.config/nvim/lua/plugins/config/jukit.lua
local M = {}

function M.setup()
  -- Explicitly set the Python path
  vim.g.python3_host_prog = '/usr/bin/python3'

  -- Force vim-jukit to use Python directly instead of through Neovim's interface
  vim.g.jukit_python_configured = 1  -- Tell jukit we're handling Python ourselves
  vim.g.jukit_shell_cmd = 'ipython3' -- Use IPython

  -- Set terminal type
  vim.g.jukit_terminal = 'nvimterm'

  -- Other jukit settings
  vim.g.jukit_auto_output_hist = 1
  vim.g.jukit_use_tcomment = 1
  vim.g.jukit_enable_textcell_bg = 1
  vim.g.jukit_text_syntax_file = 'markdown'

  -- Initialize the plugin with a delay to ensure Python provider is ready
  vim.defer_fn(function()
    -- Create a force-initialization command
    vim.api.nvim_create_user_command("JukitInitialize", function()
      -- This forces jukit to initialize using our settings
      vim.cmd("let g:jukit_python3_support = 1")
      vim.cmd("runtime plugin/jukit.vim")
      vim.notify("vim-jukit initialized with Python support")
    end, {})

    -- Run initialization
    vim.cmd("JukitInitialize")
  end, 1000)  -- 1 second delay
end

return M

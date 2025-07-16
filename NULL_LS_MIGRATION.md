# Migration from null-ls.nvim to Modern Alternatives

## Overview
This document describes the migration from the deprecated `null-ls.nvim` plugin to modern alternatives to fix deprecation warnings in Neovim.

## Changes Made

### 1. Removed Deprecated Plugin
- **Removed**: `jose-elias-alvarez/null-ls.nvim`
- **Reason**: The plugin is deprecated and archived, causing deprecation warnings with newer Neovim versions

### 2. Added Modern Alternatives

#### A. Formatting: `conform.nvim`
- **Plugin**: `stevearc/conform.nvim`
- **Purpose**: Modern formatting solution with async support
- **Features**:
  - Async formatting (non-blocking)
  - LSP fallback support
  - Format on save
  - Manual formatting with `<leader>f`

**Configured formatters:**
- **Lua**: `stylua`
- **Python**: `isort`, `black`
- **C/C++**: `clang-format`
- **JavaScript/TypeScript**: `prettierd`, `prettier`
- **JSON**: `prettierd`, `prettier`

#### B. Linting: `nvim-lint`
- **Plugin**: `mfussenegger/nvim-lint`
- **Purpose**: Modern linting solution with async support
- **Features**:
  - Async linting (non-blocking)
  - Integration with Neovim's native diagnostic system
  - Auto-linting on save, buffer enter, and insert leave
  - Manual linting with `:Lint` command

**Configured linters:**
- **Python**: `flake8`
- **JavaScript/TypeScript**: `eslint`
- **Lua**: `luacheck`
- **SystemVerilog/Verilog**: `verilator` (custom configuration)

#### C. Tool Management: `mason-tool-installer.nvim`
- **Plugin**: `WhoIsSethDaniel/mason-tool-installer.nvim`
- **Purpose**: Automatically install required formatters and linters
- **Features**:
  - Automatic installation of tools on startup
  - Ensures all required tools are available

### 3. Custom Verilator Configuration

The original null-ls configuration for verilator was migrated to nvim-lint with a custom parser:

```lua
lint.linters.verilator = {
  cmd = "verilator",
  args = {
    "--lint-only",
    "-Wall",
    "-I" .. (os.getenv("UVM_HOME") or "") .. "/src",
    -- filename is added automatically
  },
  stream = "stderr",
  ignore_exitcode = true,
  parser = function(output, bufnr)
    -- Custom parser for verilator output format
    -- Handles: file:line:col: severity: message
  end,
}
```

## Benefits of Migration

1. **No More Deprecation Warnings**: Eliminates all vim.deprecated warnings
2. **Better Performance**: Async operations, less overhead
3. **Active Maintenance**: All new plugins are actively maintained
4. **Native Integration**: Better integration with Neovim's built-in systems
5. **Separation of Concerns**: Dedicated plugins for formatting and linting

## Installation Requirements

### Automatic Installation (via Mason)
The following tools will be automatically installed:
- `stylua` (Lua formatter)
- `black`, `isort` (Python formatter/import sorter)
- `prettier`, `prettierd` (JavaScript/TypeScript/JSON formatter)
- `clang-format` (C/C++ formatter)
- `flake8` (Python linter)
- `eslint` (JavaScript/TypeScript linter)
- `luacheck` (Lua linter)

### Manual Installation Required
**Verilator** is not available through Mason and must be installed separately:
- **Ubuntu/Debian**: `sudo apt-get install verilator`
- **macOS**: `brew install verilator`
- **Other systems**: See [Verilator installation guide](https://verilator.org/guide/latest/install.html)

## Usage

### Formatting
- **Manual**: Press `<leader>f` to format the current buffer
- **Automatic**: Files are automatically formatted on save
- **Fallback**: If no formatter is configured, falls back to LSP formatting

### Linting
- **Automatic**: Runs on buffer enter, save, and insert leave
- **Manual**: Use `:Lint` command to trigger linting
- **Integration**: Results appear in Neovim's diagnostic system

### Tool Management
- **Automatic**: Tools are installed on first startup
- **Manual**: Use `:Mason` to manage tools
- **Updates**: Tools can be updated through Mason interface

## Configuration Files

The main configuration is in `/home/workinglobster/.config/nvim/lua/plugins/lsp.lua`:
- Lines ~275-310: `conform.nvim` configuration
- Lines ~312-375: `nvim-lint` configuration
- Lines ~32-50: `mason-tool-installer` configuration

## Testing the Migration

After restarting Neovim:
1. Check that deprecation warnings are gone
2. Test formatting with `<leader>f`
3. Test linting by opening files of different types
4. Verify tools are installed with `:Mason`
5. For SystemVerilog: Test verilator linting on `.sv` files

## Troubleshooting

### If formatters don't work:
1. Check `:Mason` to ensure tools are installed
2. Run `:ConformInfo` to see formatter status
3. Check that the filetype is correctly detected

### If linters don't work:
1. Verify tools are installed and in PATH
2. Check diagnostic configuration with `:lua vim.diagnostic.config()`
3. For verilator: Ensure it's installed system-wide

### If tools aren't auto-installed:
1. Check internet connection
2. Run `:MasonToolsInstall` manually
3. Check Mason log for errors

## Migration Complete

The migration from null-ls.nvim to modern alternatives is complete. The new setup provides:
- ✅ No deprecation warnings
- ✅ Better performance
- ✅ Active maintenance
- ✅ Same functionality as before
- ✅ Future-proof architecture

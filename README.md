# Neovim Configuration with LazyVim Features

A modern Neovim configuration built with lazy.nvim, featuring LazyVim-style UI enhancements and professional development tools.

## Features

### LazyVim-Style UI
- **Top-positioned Command Line**: Modern command palette that appears at the top center
- **Upper-right Notifications**: Clean notification system with fade animations
- **Indent Guides**: Visual indentation lines showing code structure
- **Rainbow Brackets**: Color-coded nested brackets for better code readability
- **Scope Highlighting**: Current code block/function scope visualization

### Core Functionality
- **LSP Integration**: Full Language Server Protocol support with Mason
- **Smart Completion**: Context-aware autocompletion with nvim-cmp
- **Treesitter**: Advanced syntax highlighting and code understanding
- **Fuzzy Finding**: Telescope for file/text searching
- **Git Integration**: Built-in Git support with Fugitive
- **Terminal Integration**: Integrated terminal with ToggleTerm

### Coding Features
- **Auto-pairing**: Smart bracket and quote completion
- **Enhanced Matching**: Jump between matching brackets/keywords with %
- **Snippet Support**: LuaSnip with friendly-snippets collection
- **Code Formatting**: Conform.nvim for consistent code style
- **Linting**: nvim-lint for code quality checks

### Language Support
- **LaTeX**: VimTeX integration for academic writing
- **SystemVerilog**: Hardware description language support
- **Python**: Jupyter notebook support with vim-jukit
- **Markdown**: Live preview and enhanced editing
- **CSV/TSV**: Structured data file handling

### Productivity Tools
- **File Explorer**: nvim-tree for project navigation
- **Task Management**: ToggleTasks for project automation
- **Multiple Cursors**: vim-visual-multi for bulk editing
- **Surround Operations**: Easy text object manipulation
- **Comment Toggling**: Smart commenting with Comment.nvim
- **Inline Translation**: Language detection with popup translations (Korean, Japanese, Chinese, ... → English)

## Installation

1. **Backup existing config** (if any):
   ```bash
   mv ~/.config/nvim ~/.config/nvim.backup
   ```

2. **Clone this repository**:
   ```bash
   git clone <repository-url> ~/.config/nvim
   ```

3. **Start Neovim**:
   ```bash
   nvim
   ```

   Lazy.nvim will automatically install all plugins on first launch.

## Key Bindings

### General
- `<Space>` - Leader key
- `<Leader>ff` - Find files
- `<Leader>fg` - Live grep
- `<Leader>fb` - Browse buffers
- `<Leader>tt` - Toggle terminal

### Code Navigation
- `%` - Jump to matching bracket/keyword
- `gd` - Go to definition
- `gr` - Go to references
- `K` - Show hover documentation

### Editing
- `gcc` - Toggle line comment
- `gc` - Toggle block comment
- `ys` - Surround text object
- `cs` - Change surrounding
- `ds` - Delete surrounding

### Visual Enhancements
- Indent guides automatically show code structure
- Rainbow brackets color-code nested parentheses
- Notifications appear in upper-right corner
- Command line appears at top when typing `:`

### Translation
- `<Leader>tv` - Translate the visual selection (Korean, Japanese, Chinese, ... → English popup)
- `<Leader>tw` - Translate the word under the cursor (non-Latin scripts → English popup)
- Latin/English text is detected and ignored automatically

## Configuration Structure

```
~/.config/nvim/
├── init.lua                 # Main entry point
├── lua/
│   ├── config/
│   │   ├── lazy.lua        # Lazy.nvim setup
│   │   ├── options.lua     # Vim options
│   │   ├── keymaps.lua     # Key mappings
│   │   └── autocmds.lua    # Auto commands
│   ├── plugins/
│   │   ├── ui.lua          # UI plugins (notifications, noice)
│   │   ├── editor.lua      # Editor enhancements (indent guides, brackets)
│   │   ├── coding.lua      # Coding tools (completion, snippets)
│   │   ├── lsp.lua         # Language server configuration
│   │   ├── treesitter.lua  # Syntax highlighting
│   │   └── ...
│   └── utils/              # Utility functions
└── snippets/               # Custom snippets
```

## Visual Features in Detail

### Indent Guides
- Vertical lines (`│`) show indentation levels
- Current scope highlighting with different colors
- Smart exclusions for special file types

### Rainbow Brackets
- 7-color rotation: Red, Yellow, Blue, Orange, Green, Violet, Cyan
- Treesitter-based accurate bracket matching
- Language-aware strategies

### Modern UI
- Command line popup at top center (row 5)
- Notifications with fade-in/slide-out animations
- Consistent with LazyVim's aesthetic

## Customization

The configuration is modular and easy to customize:

1. **Add new plugins**: Create files in `lua/plugins/`
2. **Modify keymaps**: Edit `lua/config/keymaps.lua`
3. **Change options**: Update `lua/config/options.lua`
4. **Custom snippets**: Add to `snippets/` directory

## Requirements

- Neovim >= 0.9.0
- Git
- A Nerd Font (for icons)
- ripgrep (for telescope grep)
- Node.js (for some LSP servers)

## Contributing

Feel free to submit issues and pull requests to improve this configuration.

## License

This configuration is open source and available under the MIT License.

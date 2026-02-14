# Neovim Configuration Guide

This guide covers all the plugins, settings, and keybindings in this Neovim configuration.

## Table of Contents
- [Basic Settings](#basic-settings)
- [Leader Keys](#leader-keys)
- [Plugins](#plugins)
- [LSP Configuration](#lsp-configuration)
- [Keybindings Reference](#keybindings-reference)

## Basic Settings

### Line Numbers
- **Absolute line numbers**: Enabled
- **Relative line numbers**: Enabled (shows distance from current line)

### Indentation
- **Tab width**: 2 spaces
- **Expand tabs to spaces**: Yes
- **Smart indent**: Enabled (auto-indents new lines)

### Search
- **Highlight search**: Enabled (highlights all matches)
- **Incremental search**: Enabled (shows matches as you type)
- **Ignore case**: Yes (unless you type uppercase)
- **Smart case**: Enabled (case-sensitive if you type uppercase)

### Other Settings
- **Clipboard**: Synced with system clipboard (`"+y` to copy, `"+p` to paste)
- **Persistent undo**: Enabled (undo history saved between sessions)
- **Swap files**: Disabled
- **Mouse support**: Enabled
- **True color**: Enabled

## Leader Keys

- **Leader**: `Space`
- **Local Leader**: `\`

Use leader key for custom commands. Example: `<Space>ff` opens file finder.

## Plugins

### 1. Vesper Theme
**Plugin**: `datsfilipe/vesper.nvim`

A beautiful dark theme with transparent background and italic styling.

**Features**:
- Transparent background (works with terminal transparency)
- Italics for comments, keywords, functions, strings, and variables

**Usage**: Theme is automatically applied on startup.

---

### 2. Lualine (Status Line)
**Plugin**: `nvim-lualine/lualine.nvim`

Modern statusline showing file info, git branch, diagnostics, and more.

**Features**:
- Shows current mode (NORMAL, INSERT, VISUAL, etc.)
- File path and modification status
- Git branch and changes
- LSP diagnostics (errors, warnings)
- File encoding and type
- Cursor position

**Usage**: Always visible at the bottom of the screen.

---

### 3. Treesitter (Syntax Highlighting)
**Plugin**: `nvim-treesitter/nvim-treesitter`

Advanced syntax highlighting and code understanding.

**Pre-installed Languages**:
- C
- Lua
- Vim
- Markdown
- TypeScript/TSX
- Python

**Features**:
- Superior syntax highlighting
- Smart indentation
- Auto-tagging (for HTML/JSX)
- Code folding support

**Usage**: Works automatically. Run `:TSUpdate` to update parsers.

**Installing new languages**:
```vim
:TSInstall javascript
:TSInstall rust
```

---

### 4. LSP (Language Server Protocol)
**Plugins**:
- `neovim/nvim-lspconfig`
- `williamboman/mason.nvim`
- `williamboman/mason-lspconfig.nvim`

Provides IDE-like features: autocomplete, go-to-definition, hover docs, etc.

**Pre-configured Servers**:
- `lua_ls` (Lua) - with Neovim-specific configuration
- `pyright` (Python) - configured for Python 3.10/3.11/3.12

**Adding More Language Servers**:
1. Open Mason: `:Mason`
2. Search for your language server (use `/` to search)
3. Press `i` to install
4. Add configuration in `init.lua`:
```lua
vim.lsp.config("pyright", { capabilities = capabilities })
vim.lsp.enable("pyright")
```

**LSP Keybindings**:
- `gd` - Go to definition
- `K` - Peek fold or show LSP hover documentation (context-aware)
- `<Space>rn` - Rename symbol
- `<Space>ca` - Code actions

**Common Language Servers**:
- Python: `pyright` (pre-configured) or `pylsp`
- JavaScript/TypeScript: `ts_ls`
- Go: `gopls`
- Rust: `rust_analyzer`
- C/C++: `clangd`

**Note**: This configuration searches for Python in the following order: python3.12, python3.11, python3.10, then falls back to python3.

---

### 5. nvim-cmp (Autocompletion)
**Plugin**: `hrsh7th/nvim-cmp`

Intelligent autocompletion with multiple sources.

**Completion Sources**:
1. LSP (context-aware completions)
2. LuaSnip (code snippets)
3. Buffer (words from open files)
4. Path (file system paths)

**Keybindings** (in insert mode):
- `Ctrl+Space` - Trigger completion manually
- `Tab` - Select next item / expand snippet
- `Shift+Tab` - Select previous item / jump back in snippet
- `Enter` - Confirm selection
- `Ctrl+e` - Close completion menu
- `Ctrl+f` - Scroll docs down
- `Ctrl+b` - Scroll docs up

**Usage**: Start typing and suggestions appear automatically.

---

### 6. Telescope (Fuzzy Finder)
**Plugin**: `nvim-telescope/telescope.nvim`

Powerful fuzzy finder for files, text, buffers, and more.

**Keybindings**:
- `<Space>ff` - Find files (searches by filename)
- `<Space>fg` - Live grep (search text in files)
- `<Space>fb` - Find buffers (switch between open files)
- `<Space>fh` - Help tags (search Vim help)

**Inside Telescope**:
- `Ctrl+j/k` or `Down/Up` - Navigate results
- `Enter` - Open selection
- `Ctrl+x` - Open in horizontal split
- `Ctrl+v` - Open in vertical split
- `Ctrl+t` - Open in new tab
- `Esc` - Close Telescope

**Tips**:
- Fuzzy matching: type parts of filename (e.g., "conit" finds "config/init.lua")
- Use `live_grep` to search within file contents
- Prefix with `!` to exclude (e.g., "foo !bar" finds "foo" but not "bar")

---

### 7. Neo-tree (File Explorer)
**Plugin**: `nvim-neo-tree/neo-tree.nvim`

Modern file explorer with git integration and tree view.

**Keybindings**:
- `-` - Toggle Neo-tree
- `<Space>e` - Focus Neo-tree

**Inside Neo-tree**:
- `Enter` or `o` - Open file or toggle directory
- `a` - Add new file/directory (end with `/` for directory)
- `d` - Delete file/directory
- `r` - Rename file/directory
- `y` - Copy file/directory
- `x` - Cut file/directory
- `p` - Paste file/directory
- `c` - Copy file to clipboard
- `m` - Move file
- `q` - Close Neo-tree
- `R` - Refresh tree
- `H` - Toggle hidden files
- `?` - Show help

**Features**:
- Tree-style file navigation
- Git status indicators (modified, added, deleted files)
- Automatic file watching (updates when files change)
- Follows current file automatically
- Icons for file types
- Closes automatically if it's the last window

---

### 8. Comment.nvim
**Plugin**: `numToStr/Comment.nvim`

Easy code commenting with smart language detection.

**Keybindings**:
- `gcc` - Toggle line comment
- `gc` - Toggle comment (in visual mode)
- `gbc` - Toggle block comment
- `gb` - Toggle block comment (in visual mode)

**Examples**:
- `gcc` on a line: toggles single line comment
- `gc3j` - Comment current line + 3 lines below
- Visual select + `gc` - Comment all selected lines

**Language-aware**: Automatically uses correct comment syntax (e.g., `//` for JS, `#` for Python).

---

### 9. nvim-autopairs
**Plugin**: `windwp/nvim-autopairs`

Auto-close brackets, quotes, and more.

**Features**:
- Type `(` and get `()` with cursor in middle
- Type `)` when next to `)` moves cursor forward (doesn't insert duplicate)
- Works with: `()`, `[]`, `{}`, `''`, `""`, ` `` `
- Press `Enter` between brackets for formatted expansion:
  ```javascript
  function() {|} // cursor at |
  // Press Enter:
  function() {
    |
  }
  ```

**Smart features**:
- Deletes pairs together (backspace after `(` deletes both `(` and `)`)
- Integrates with nvim-cmp (pairs work in completion)

---

### 10. Gitsigns
**Plugin**: `lewis6991/gitsigns.nvim`

Git integration showing changes in the gutter.

**Features**:
- Added lines: Green `+` in gutter
- Modified lines: Blue `~` in gutter
- Removed lines: Red `_` in gutter
- Git blame information
- Diff preview

**Default Keybindings** (can be customized):
- `]c` - Next hunk (git change)
- `[c` - Previous hunk
- `<leader>hs` - Stage hunk
- `<leader>hu` - Undo stage hunk
- `<leader>hr` - Reset hunk
- `<leader>hp` - Preview hunk
- `<leader>hb` - Blame line

**Usage**: Changes appear automatically in the sign column (gutter).

---

### 11. Trouble (Diagnostics Panel)
**Plugin**: `folke/trouble.nvim`

Beautiful diagnostics panel to view and navigate all errors and warnings.

**Keybindings**:
- `<Space>xx` - Toggle diagnostics panel (all workspace issues)
- `<Space>xX` - Buffer diagnostics (current file only)
- `<Space>cs` - Show symbols (functions, variables in current file)
- `<Space>cl` - LSP definitions and references
- `<Space>xL` - Location list
- `<Space>xQ` - Quickfix list

**Inside Trouble Panel**:
- `j/k` or `Down/Up` - Navigate through issues
- `Enter` - Jump to the issue location
- `q` - Close Trouble panel
- `?` - Show help

**Features**:
- Clean list view of all diagnostics
- Filter by severity (errors, warnings, info, hints)
- Jump directly to each issue
- Shows error messages and locations
- Icons for different diagnostic types
- Auto-updates as you code

**Usage**: Press `<Space>xx` to see all diagnostics in your workspace. Navigate with `j/k` and press `Enter` to jump to any issue.

---

### 12. which-key (Keymap Helper)
**Plugin**: `folke/which-key.nvim`

Shows available keybindings in a popup as you type.

**Usage**:
- `<Space>?` - Show all keymaps
- `<Space><Space>` - Show leader keymaps
- Press any key prefix (like `<Space>` or `z`) and wait 500ms to see available completions

**Features**:
- Modern, clean interface
- Organized by groups (Find/Files, Diagnostics, Code/LSP, etc.)
- Shows key descriptions for easy discovery
- Helpful for learning new keybindings

---

### 13. dressing.nvim (Better UI)
**Plugin**: `stevearc/dressing.nvim`

Improves the default Neovim UI for inputs and selections.

**Features**:
- Better input prompts (like rename dialog)
- Integrates with Telescope for selections
- Rounded borders and cleaner appearance
- Improved visibility and usability

**Usage**: Works automatically when plugins request user input or selections.

---

### 14. Satellite (Scrollbar)
**Plugin**: `lewis6991/satellite.nvim`

Displays a scrollbar with decorations showing search matches, diagnostics, git changes, and cursor position.

**Features**:
- Visual scrollbar on the right side
- Search match indicators
- Diagnostic locations (errors/warnings)
- Git change locations
- Mark positions
- Cursor position indicator

**Usage**: Always visible on the right side of the window.

---

### 15. UFO (Code Folding)
**Plugins**: 
- `kevinhwang91/nvim-ufo`
- `kevinhwang91/promise-async`

Advanced code folding with Treesitter and LSP support.

**Features**:
- Intelligent folding based on code structure
- Folds functions, classes, objects, arrays, loops, etc.
- Preview folded content on hover
- Works with all Treesitter-supported languages
- Beautiful fold column indicator

**Keybindings**:
- `za` - Toggle fold under cursor
- `zc` - Close fold under cursor
- `zo` - Open fold under cursor
- `zR` - Open all folds in buffer
- `zM` - Close all folds in buffer
- `zr` - Open folds except certain kinds
- `zm` - Close folds with specific criteria
- `zj` - Move to next fold
- `zk` - Move to previous fold
- `K` - Peek folded content (or show LSP hover if not on fold)

**Usage**: 
1. Navigate to a function or code block
2. Press `zc` to close/fold it
3. Press `zo` to open/unfold it
4. Hover over a fold and press `K` to preview its contents without unfolding
5. Use `zM` to fold everything, `zR` to unfold everything

**Tips**:
- Folds are based on syntax, so they work intelligently for each language
- The fold column on the left shows fold indicators
- All folds start open by default (foldlevel=99)
- Preview window appears when you press `K` on a folded line

---

### 16. Harpoon (Quick File Marks)
**Plugin**: `ThePrimeagen/harpoon`

Fast file navigation using persistent marks for frequently accessed files.

**Features**:
- Mark up to 5 frequently used files for instant access
- Quick menu to view and manage all marks
- Navigate between marks with single keystrokes
- Project-specific mark persistence
- Faster than fuzzy finding for files you access repeatedly

**Keybindings**:
- `<Space>oa` - Add current file to Harpoon marks
- `<Space>oo` - Open Harpoon quick menu
- `<Space>o1` - Jump to mark 1
- `<Space>o2` - Jump to mark 2
- `<Space>o3` - Jump to mark 3
- `<Space>o4` - Jump to mark 4
- `<Space>o5` - Jump to mark 5
- `<Space>on` - Navigate to next mark
- `<Space>op` - Navigate to previous mark

**Inside Harpoon Menu**:
- `j/k` or `Down/Up` - Navigate through marks
- `Enter` - Jump to selected file
- `dd` - Remove mark from list
- `q` or `Esc` - Close menu

**Usage**:
1. Open a file you frequently access
2. Press `<Space>oa` to add it to Harpoon
3. Repeat for up to 5 important files in your project
4. Use `<Space>o1` through `<Space>o5` to instantly jump between them
5. Press `<Space>oo` to see all your marks and manage them

**Workflow Tip**: Mark your most-edited files (main file, config, types, tests, etc.) and switch between them instantly without fuzzy finding.

---

### 17. Markdown Preview
**Plugin**: `iamcco/markdown-preview.nvim`

Browser-based live preview for markdown files with auto-refresh.

**Features**:
- Real-time preview in your default browser
- Auto-scrolls to cursor position
- Supports GitHub-flavored markdown
- Renders code blocks with syntax highlighting
- Shows images, tables, and diagrams
- Live updates as you type

**Keybindings**:
- `<Space>mp` - Toggle markdown preview in browser

**Usage**:
1. Open a markdown file
2. Press `<Space>mp` to launch preview in browser
3. Edit your markdown - preview updates automatically
4. Preview shows exactly where your cursor is
5. Press `<Space>mp` again to close preview

**Tips**:
- Great for writing documentation, READMEs, or blog posts
- Preview stays synced even when switching between files
- Works alongside render-markdown for in-editor previewing

---

### 18. Render Markdown
**Plugin**: `MeanderingProgrammer/render-markdown.nvim`

In-buffer markdown rendering with beautiful syntax and icons.

**Features**:
- Renders markdown directly in Neovim (no browser needed)
- Code blocks with language-specific styling
- Custom bullet point icons
- Heading colors matching Vesper theme
- Concealment of markdown syntax (shows formatted result)
- Tables, links, and emphasis rendering
- Checkbox rendering for task lists

**Keybindings**:
- `<Space>tr` - Toggle render markdown on/off

**Auto-enabled for**:
- All `.md` files automatically show rendered markdown
- Concealment level set to hide syntax when not editing
- Word wrap enabled for comfortable reading

**Usage**:
- Open any markdown file - rendering is automatic
- Press `<Space>tr` to toggle between raw and rendered view
- Edit normally - syntax is revealed when cursor is on a line
- See formatted preview without leaving Neovim

**Features in Detail**:
- **Code blocks**: Highlighted with custom icons
- **Headings**: Color-coded (H1-H6) using Vesper theme colors
- **Lists**: Custom bullet icons for better readability
- **Links**: Concealed to show just the link text
- **Emphasis**: Italics and bold rendered properly

---

### 19. Image.nvim
**Plugin**: `3rd/image.nvim`

Inline image viewing within Neovim using Kitty graphics protocol.

**Features**:
- Display images directly in Neovim (Kitty terminal required)
- Automatic image rendering in markdown files
- Download and cache remote images
- Supports PNG, JPG, GIF formats
- Markdown integration (shows `![alt](image.png)` images)
- PDF and Office file external opening support

**Keybindings**:
- `<Space>io` - Open file externally (for PDFs, Office docs, etc.)

**Supported External Files**:
- PDFs (`.pdf`)
- Office documents (`.docx`, `.xlsx`, `.pptx`)
- Other binary files

**Usage**:
1. In markdown files, images are automatically displayed inline
2. For PDFs or Office files, press `<Space>io` to open in default app
3. Remote images in markdown are downloaded and cached automatically
4. Works seamlessly while editing documentation

**Requirements**:
- Kitty terminal for inline image display
- ImageMagick for image processing
- Default system apps for external file opening

**Tips**:
- Great for viewing diagrams while editing documentation
- Automatically handles both local and remote images
- Falls back gracefully if Kitty terminal is not available

---

### 20. Rainbow CSV
**Plugin**: `cameron-wags/rainbow_csv.nvim`

Syntax highlighting for CSV and TSV files with column visualization.

**Features**:
- Auto-detects CSV and TSV files
- Color-codes each column differently
- Makes data structure immediately visible
- Lightweight and fast
- Works with various delimiters

**Supported Formats**:
- CSV (comma-separated values)
- TSV (tab-separated values)
- Other delimiter-separated files

**Usage**:
- Open any `.csv` or `.tsv` file
- Columns automatically get different colors
- Navigate and edit data with visual column separation
- No configuration needed

**Benefits**:
- Easier to read and edit tabular data
- Quickly identify column boundaries
- Reduces errors when working with data files
- Essential for data analysis and manipulation

---

## LSP Configuration

### What is LSP?
Language Server Protocol provides IDE features like:
- **Autocomplete**: Smart suggestions based on code context
- **Go to Definition**: Jump to where functions/variables are defined
- **Hover Documentation**: See function signatures and docs
- **Diagnostics**: Real-time error and warning detection
- **Rename**: Safely rename symbols across files
- **Code Actions**: Quick fixes and refactoring

### Managing Language Servers with Mason

**Open Mason**:
```vim
:Mason
```

**Mason Interface**:
- Use `/` to search
- Press `i` on a server to install
- Press `X` on a server to uninstall
- Press `U` to update all installed servers
- Press `g?` for help

**Recommended Setup Flow**:
1. Install server via Mason (`:Mason`)
2. Add to config in `init.lua`:
```lua
vim.lsp.config("server_name", { capabilities = capabilities })
vim.lsp.enable("server_name")
```
3. Restart Neovim

---

## Keybindings Reference

### General Vim
- `i` - Insert mode
- `Esc` or `Ctrl+[` - Normal mode
- `v` - Visual mode
- `V` - Visual line mode
- `Ctrl+v` - Visual block mode
- `:w` - Save
- `:q` - Quit
- `:wq` or `ZZ` - Save and quit
- `:q!` - Quit without saving
- `u` - Undo
- `Ctrl+r` - Redo

### General Editor
- `<Space>w` - Save file
- `<Space>q` - Quit window
- `<Space>cr` - Check and reload files
- `<Space>tw` - Toggle word wrap
- `gh` - Jump back in history
- `gl` - Jump forward in history
- `Esc` - Clear search highlights

### Navigation
- `h/j/k/l` - Left/Down/Up/Right
- `w` - Next word
- `b` - Previous word
- `0` - Start of line
- `$` - End of line
- `gg` - Top of file
- `G` - Bottom of file
- `{number}G` - Go to line number
- `%` - Jump to matching bracket
- `Ctrl+d` - Scroll half page down
- `Ctrl+u` - Scroll half page up

### Editing
- `dd` - Delete line
- `yy` - Yank (copy) line
- `p` - Paste after cursor
- `P` - Paste before cursor
- `x` - Delete character
- `r` - Replace character
- `cw` - Change word
- `ciw` - Change inside word
- `ci(` - Change inside parentheses
- `.` - Repeat last command

### Windows/Splits
- `:split` or `:sp` - Horizontal split
- `:vsplit` or `:vs` - Vertical split
- `Ctrl+w h/j/k/l` - Navigate between splits
- `<Space>h` - Move to left split
- `<Space>j` - Move to bottom split
- `<Space>k` - Move to top split
- `<Space>l` - Move to right split
- `Ctrl+w =` - Equal size splits
- `Ctrl+w q` - Close current split

### LSP (configured in this setup)
- `gd` - Go to definition
- `K` - Peek fold or LSP hover documentation
- `<Space>rn` - Rename symbol
- `<Space>ca` - Code actions

### Telescope (configured in this setup)
- `<Space>ff` - Find files
- `<Space>fg` - Live grep (search in files)
- `<Space>fb` - Find buffers
- `<Space>fh` - Help tags

### File Explorer (Neo-tree)
- `-` - Toggle Neo-tree
- `<Space>e` - Focus Neo-tree

### Which-key (Keymap Discovery)
- `<Space>?` - Show all keymaps
- `<Space><Space>` - Show leader keymaps only

### Comments
- `gcc` - Toggle line comment
- `gc` - Toggle comment (visual mode)

### Completion (Insert mode)
- `Ctrl+Space` - Trigger completion
- `Tab` - Next item / expand snippet
- `Shift+Tab` - Previous item
- `Enter` - Confirm
- `Ctrl+e` - Close menu

### Code Folding
- `za` - Toggle fold under cursor
- `zc` - Close fold under cursor
- `zo` - Open fold under cursor
- `zR` - Open all folds
- `zM` - Close all folds
- `zr` - Open folds except kinds
- `zm` - Close folds with criteria
- `zj` - Next fold
- `zk` - Previous fold

### Harpoon (Quick Marks)
- `<Space>oa` - Add file to Harpoon marks
- `<Space>oo` - Open Harpoon menu
- `<Space>o1` - Jump to mark 1
- `<Space>o2` - Jump to mark 2
- `<Space>o3` - Jump to mark 3
- `<Space>o4` - Jump to mark 4
- `<Space>o5` - Jump to mark 5
- `<Space>on` - Navigate to next mark
- `<Space>op` - Navigate to previous mark

### Markdown
- `<Space>mp` - Toggle markdown preview (browser)
- `<Space>tr` - Toggle render markdown (in-buffer)

### Images and External Files
- `<Space>io` - Open file externally (PDFs, Office docs)

### Visual Mode
- `*` - Search for selected text
- `gc` - Toggle comment on selection
- `gb` - Toggle block comment on selection

---

## Tips and Tricks

### Workflow Tips

1. **Quick File Switching**:
   - Use Harpoon for your 5 most-accessed files: `<Space>oa` to mark, `<Space>o1-5` to jump
   - `<Space>ff` to find files by name (for everything else)
   - `<Space>fb` to switch between recent buffers
   - `-` to toggle Neo-tree file explorer for project navigation

2. **Search Across Project**:
   - `<Space>fg` then type search term
   - Use LSP features: `gd` to jump to definitions
   - Visual select + `*` to search for selected text

3. **Multiple Cursors Alternative**:
   - Use `cgn` pattern: search with `/pattern`, then `cgn` to change next match, `.` to repeat

4. **Quick Edits**:
   - `ciw` - change word under cursor
   - `ci"` - change inside quotes
   - `ci{` - change inside braces
   - `dt,` - delete until comma

5. **Git Workflow**:
   - View changes in gutter with Gitsigns
   - Use `:Git` if you have vim-fugitive installed
   - See file history with `<Space>fg` and search for filename

6. **Markdown Editing**:
   - In-buffer rendering with `<Space>tr` for quick previews
   - Browser preview with `<Space>mp` for final review
   - Images display automatically in Kitty terminal
   - Use `<Space>io` to open PDFs or Office docs externally

7. **Code Navigation with Folding**:
   - Open a large file and press `zM` to fold everything
   - Scan the structure, then `zo` on sections you need to see
   - Use `K` to peek inside folds without opening them
   - Combine with Harpoon: mark files, use folding to understand structure

### Plugin-Specific Tips

**Telescope**:
- Use `Ctrl+/` in Telescope to see all keybindings
- `<Space>fg` searches file contents - great for finding TODO comments
- Chain with other commands: `<Space>ff`, select file, `Ctrl+x` for horizontal split

**Neo-tree**:
- Press `?` inside Neo-tree to see all available commands
- Use `H` to toggle hidden files (like `.gitignore`, `.env`)
- Create nested directories with `a`: type `folder/subfolder/` and press Enter
- Git indicators show file status at a glance

**LSP**:
- `:LspInfo` - Check LSP status for current buffer
- `:LspLog` - View LSP logs for debugging
- Hover (`K`) twice to enter hover window (useful for long docs)

**Treesitter**:
- `:InspectTree` - See syntax tree (great for debugging highlighting)
- `:Inspect` - Show highlight groups under cursor

**Code Folding (UFO)**:
- Use `zM` to fold all code, then `zo` to selectively open sections you're working on
- Press `K` on a folded line to preview its contents without opening
- Combine with Telescope: `<Space>ff` to find file, then `zM` to collapse all functions
- Great for understanding code structure at a glance
- Folds automatically work for functions, classes, objects, arrays, and more

**Harpoon**:
- Mark your 5 most-edited files in a project for instant access
- Use numeric marks (`<Space>o1-5`) instead of fuzzy finding for core project files
- Common pattern: 1=main/index, 2=config, 3=types, 4=tests, 5=utils
- Perfect for switching between related files during feature development
- Much faster than Telescope for files you access constantly

**Markdown Workflow**:
- Use `<Space>tr` for in-buffer preview while editing
- Use `<Space>mp` for browser preview when sharing or presenting
- Both can be used together - in-buffer for quick checks, browser for final review
- Images render inline automatically in markdown files
- Great for writing documentation, READMEs, or technical blog posts

**Rainbow CSV**:
- Open any `.csv` or `.tsv` file to see automatic column highlighting
- Each column gets a different color for easy visual separation
- Navigate with standard Vim motions - colors make it easier to track columns
- Essential when editing configuration data or analyzing datasets

### Learning Resources

- Vim Tutor: Run `vimtutor` in terminal
- Neovim Docs: Press `<Space>fh` and search
- Plugin Docs: Visit GitHub repos linked above
- Practice: Try `vim-be-good` plugin for interactive exercises

---

## Troubleshooting

### LSP not working
1. Check if server is running: `:LspInfo`
2. Verify server is installed: `:Mason`
3. Check logs: `:LspLog`
4. Restart LSP: `:LspRestart`

### Completion not appearing
1. Ensure LSP is running (`:LspInfo`)
2. Check if you're in insert mode
3. Try `Ctrl+Space` to trigger manually
4. Verify cmp sources: `:lua print(vim.inspect(require('cmp').get_config().sources))`

### Telescope not finding files
1. Make sure you're in the right directory (`:pwd`)
2. Check if files are gitignored (Telescope respects `.gitignore`)
3. Use `:Telescope find_files hidden=true` for hidden files

### Colors look wrong
1. Check terminal supports true color: `:echo has('termguicolors')`
2. Set terminal to use true color (most modern terminals do)
3. Try different terminal (iTerm2, Alacritty, WezTerm recommended)

---

## Customization

This configuration uses `lazy.nvim` as the plugin manager. All config is in `nvim/init.lua`.

**To add a new plugin**:
1. Add to the `require("lazy").setup({})` table in `init.lua`
2. Restart Neovim or run `:Lazy sync`

**To modify keybindings**:
Look for `vim.keymap.set()` calls in `init.lua` and modify as needed.

**To add LSP servers**:
1. Install via `:Mason`
2. Add config in the LSP section using the pattern shown for `lua_ls`

---

## Quick Reference Card

| Command | Action |
|---------|--------|
| `<Space>w` | Save file |
| `<Space>q` | Quit window |
| `<Space>ff` | Find files |
| `<Space>fg` | Search in files |
| `<Space>fb` | Find buffers |
| `-` | Toggle file explorer |
| `<Space>e` | Focus file explorer |
| `<Space>xx` | Toggle diagnostics panel |
| `gd` | Go to definition |
| `K` | Peek fold or hover docs |
| `<Space>rn` | Rename |
| `<Space>ca` | Code actions |
| `gcc` | Toggle comment |
| `za` | Toggle fold |
| `zM` | Close all folds |
| `zR` | Open all folds |
| `<Space>h/j/k/l` | Window navigation |
| `<Space>oa` | Add Harpoon mark |
| `<Space>oo` | Harpoon menu |
| `<Space>o1-5` | Jump to mark 1-5 |
| `<Space>on/op` | Next/previous mark |
| `<Space>mp` | Markdown preview |
| `<Space>tr` | Toggle markdown render |
| `<Space>io` | Open file externally |
| `gh/gl` | Jump history back/forward |
| `<Space>tw` | Toggle word wrap |
| `<Space>?` | Show all keymaps |
| `<Space><Space>` | Show leader keymaps |
| `:Mason` | Manage LSP servers |
| `:Lazy` | Manage plugins |

---

**Made with Neovim** - Happy coding!

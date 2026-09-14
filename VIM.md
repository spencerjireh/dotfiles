# Neovim Configuration Guide

This guide covers the plugins, settings, and keybindings in this Neovim configuration (`nvim/init.lua`, Neovim 0.11+).

## Table of Contents
- [Basic Settings](#basic-settings)
- [Leader Keys](#leader-keys)
- [Plugins](#plugins)
- [LSP Configuration](#lsp-configuration)
- [Keybindings Reference](#keybindings-reference)
- [Tips and Tricks](#tips-and-tricks)
- [Troubleshooting](#troubleshooting)
- [Customization](#customization)
- [Quick Reference Card](#quick-reference-card)

## Basic Settings

### Line Numbers
- **Absolute line numbers**: Enabled
- **Relative line numbers**: Enabled (shows distance from current line)
- **Sign column**: Always on, so git and diagnostic signs never shift the text

### Indentation
- **Tab width**: 2 spaces
- **Expand tabs to spaces**: Yes
- **Smart indent**: Enabled; Treesitter provides `indentexpr` for filetypes with a parser

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
- **Word wrap**: Off by default (`<Space>tw` toggles); on for markdown
- **External changes**: Files changed on disk reload silently (`autoread` + `checktime` on focus and buffer enter). A notification appears only when the buffer also has unsaved edits; use `<Space>fu` (undo history) to reconcile.
- **Remote-plugin providers**: Python, Perl, Ruby and Node providers are disabled. Nothing in this config uses them.

## Leader Keys

- **Leader**: `Space`
- **Local Leader**: `\`

Use leader key for custom commands. Example: `<Space>ff` opens file finder.

## Plugins

### 1. Vesper Theme
**Plugin**: `datsfilipe/vesper.nvim`

Dark theme with transparent background and italic styling.

**Features**:
- Transparent background (works with terminal transparency)
- Italics for comments, keywords, functions, strings, and variables
- Custom highlight overrides so which-key, floats, snacks windows and LSP reference matches use the same palette

**Usage**: Theme is automatically applied on startup.

---

### 2. snacks.nvim (Explorer, Picker, UI, Editor Helpers)
**Plugin**: `folke/snacks.nvim`

One plugin providing several modules. Enabled here: `explorer`, `picker`, `notifier`, `input`, `words`, `indent`, `scroll`, `bigfile`, `quickfile`.

**Explorer** (right sidebar, width 30, follows the current file, git status, trash on delete):
- `-` - Toggle explorer
- `<Space>e` - Focus explorer

Inside the explorer:
- `Enter` or `l` - Open file or expand directory
- `h` - Collapse directory
- `a` - Add new file/directory (end with `/` for directory)
- `d` - Delete (sends to trash)
- `r` - Rename
- `c` - Copy file(s)
- `m` - Move file(s)
- `x` - Cut
- `y` - Yank path
- `p` - Paste
- `H` - Toggle hidden files
- `I` - Toggle ignored files
- `q` - Close explorer
- `?` - Show help

**Picker** (fuzzy finder, replaces Telescope):
- `<Space>ff` - Find files
- `<Space>fg` - Live grep (search text in files)
- `<Space>fb` - Find buffers
- `<Space>fh` - Help tags
- `<Space>fu` - Undo history (`Enter` restores that state, `Ctrl+y` yanks added lines, `Ctrl+Shift+y` yanks removed lines)
- `<Space>ft` - Find TODO/FIXME/NOTE comments (todo-comments source)

Inside a picker:
- `Ctrl+j/k` or `Down/Up` - Navigate results
- `Enter` - Open selection
- `Ctrl+s` - Open in horizontal split
- `Ctrl+v` - Open in vertical split
- `Ctrl+t` - Open in new tab
- `Tab` - Select multiple items
- `?` - Show all picker keys
- `Esc` - Close

Other pickers are available with `:lua Snacks.picker()` (a picker of pickers), for example `git_status`, `diagnostics`, `lsp_symbols`, `zoxide`.

**Words** (highlights other references of the symbol under the cursor via LSP):
- `]]` - Jump to next reference
- `[[` - Jump to previous reference

**Indent**: Indent guides with the current scope highlighted. Animation is off.

**Scroll**: Smooth scrolling for all scroll commands.

**Bigfile**: Files over 1.5 MB open with Treesitter, LSP-heavy features and folding trimmed.

**Notifier and input**:
- `<Space>nd` - Dismiss all notifications
- `<Space>nh` - Notification history
- ERROR-level notifications are sticky and must be dismissed manually
- Input prompts (for example LSP rename) use a floating window

---

### 3. auto-save.nvim
**Plugin**: `okuuva/auto-save.nvim`

Writes the buffer to disk one second after you stop editing, and immediately on leaving the buffer or losing focus. Skips special buffers, read-only files, and files over 1 MB.

Auto-save does **not** format. Formatting runs only on `<Space>w` (see conform.nvim).

---

### 4. Lualine (Status Line)
**Plugin**: `nvim-lualine/lualine.nvim`

Statusline showing mode, file path and status, git branch and changes, LSP diagnostics, encoding, filetype, and cursor position.

---

### 5. Treesitter (Syntax Highlighting, Indentation, Text Objects)
**Plugins**:
- `nvim-treesitter/nvim-treesitter` (`main` branch)
- `nvim-treesitter/nvim-treesitter-textobjects` (`main` branch)
- `nvim-treesitter/nvim-treesitter-context`

The `main` branch of nvim-treesitter is only a parser and query installer. Highlighting and indentation are enabled per buffer by a `FileType` autocmd in `init.lua` for any filetype that has a parser.

**Parsers installed automatically**: c, cpp, lua, vim, vimdoc, query, markdown, markdown_inline, tsx, typescript, javascript, python, go, rust, java, json, yaml, toml, bash, html, css.

Missing parsers install asynchronously on the first start; reopen affected buffers with `:e` when the notification appears. `dotup` runs the install synchronously. Compiling parsers requires the `tree-sitter` CLI (`tree-sitter-cli` in the Brewfile).

**Commands**:
```vim
:TSInstall zig      " add a parser
:TSUpdate           " update all parsers
:TSUninstall zig
:TSLog              " install log
```

**Text objects** (selection is provided by mini.ai using Treesitter queries; movement and swapping by textobjects):
- `af` / `if` - Around / inside function
- `ac` / `ic` - Around / inside class
- `aa` / `ia` - Around / inside argument
- `ai` / `ii` - Around / inside conditional
- `]f` / `[f` - Next / previous function
- `]c` / `[c` - Next / previous class
- `]a` / `[a` - Next / previous argument
- `]l` / `[l` - Next / previous loop
- `]s` / `[s` - Swap argument with next / previous

**Context**: The enclosing function or class header stays pinned at the top of the window (up to 3 lines).

`vim.g.no_plugin_maps` is set, so built-in filetype plugin maps (for example Python's `]]`) are not defined; `]]` and `[[` belong to snacks.words.

---

### 6. LSP (Language Server Protocol)
**Plugins**:
- `neovim/nvim-lspconfig`
- `mason-org/mason.nvim`
- `mason-org/mason-lspconfig.nvim`

Provides IDE-like features: autocomplete, go-to-definition, hover docs, rename, code actions, diagnostics.

**Servers installed by Mason**: `lua_ls`, `pyright`, `ts_ls`, `gopls`, `rust_analyzer`, `jdtls`, `clangd`.

mason-lspconfig enables every installed server automatically. `vim.lsp.config("*", ...)` sets the completion capabilities for all of them; only `lua_ls` has extra settings.

**Keybindings** (buffer-local, set when a server attaches):
- `gd` - Go to definition
- `K` - Peek fold or show LSP hover documentation (context-aware)
- `<Space>rn` - Rename symbol
- `<Space>ca` - Code actions

**Neovim built-in LSP keys** (also available):
- `grn` - Rename
- `gra` - Code action
- `grr` - References
- `gri` - Implementation
- `grt` - Type definition
- `gO` - Document symbols
- `Ctrl+s` (insert mode) - Signature help

**Diagnostics**: Shown as virtual text at the end of the line and as underlines; no gutter signs. `<Space>xx` opens the Trouble panel.

---

### 7. nvim-cmp (Autocompletion)
**Plugin**: `hrsh7th/nvim-cmp`

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

---

### 8. conform.nvim (Formatting)
**Plugin**: `stevearc/conform.nvim`

Formatting runs only when you press `<Space>w`: format the buffer, then write it. Falls back to LSP formatting when no formatter is configured for the filetype.

**Formatters by filetype** (all installed via the Brewfile):
- Lua: `stylua`
- Python: `ruff_organize_imports`, `ruff_format`
- JavaScript / TypeScript / JSX / TSX: `prettierd` (falls back to `prettier`)
- Go: `gofmt`
- Java: `google-java-format`
- C / C++: `clang-format`
- Rust: `rustfmt`

`:ConformInfo` shows which formatters apply to the current buffer and whether they are available.

---

### 9. nvim-lint (Linting)
**Plugin**: `mfussenegger/nvim-lint`

Runs on read, write, and leaving insert mode. Only linters found on `PATH` are run.
- Python: `ruff`
- JavaScript / TypeScript / JSX / TSX: `eslint_d`

---

### 10. nvim-autopairs
**Plugin**: `windwp/nvim-autopairs`

Auto-close brackets, quotes, and more.

**Features**:
- Type `(` and get `()` with cursor in middle
- Type `)` when next to `)` moves cursor forward (does not insert a duplicate)
- Works with: `()`, `[]`, `{}`, `''`, `""`, ` `` `
- Press `Enter` between brackets for formatted expansion
- Deletes pairs together (backspace after `(` deletes both `(` and `)`)

---

### 11. nvim-surround
**Plugin**: `kylechui/nvim-surround`

Add, change, and delete surrounding characters.
- `ys{motion}{char}` - Add surround (`ysiw"` wraps the word in quotes)
- `cs{old}{new}` - Change surround (`cs"'` changes double quotes to single)
- `ds{char}` - Delete surround (`ds(` removes parentheses)
- `S{char}` (visual mode) - Surround selection

---

### 12. mini.ai (Text Objects)
**Plugin**: `echasnovski/mini.ai`

Extends `a`/`i` text objects. Searches up to 500 lines forward for the nearest object when the cursor is not inside one.

- `af if ac ic aa ia ai ii` - Treesitter-backed function, class, argument, conditional (see Treesitter)
- `an` / `in` and `al` / `il` - Next / last instance of any object (for example `cin(` changes inside the next parentheses)
- `a?` / `i?` - Prompt for a custom delimiter
- `g[` / `g]` - Move to the start / end of the surrounding object

---

### 13. multicursor.nvim
**Plugin**: `jake-stewart/multicursor.nvim`

VS Code-style multiple cursors.
- `Ctrl+n` - Add a cursor at the next match of the word under the cursor (or selection)
- `Ctrl+p` - Skip the current match, add the next one
- `<Space>A` - Add cursors to all matches
- `Esc` - Clear cursors; with no cursors active, clears search highlights

---

### 14. flash.nvim (Jump)
**Plugin**: `folke/flash.nvim`

- `s` - Jump: type characters, then the label shown next to the target
- `S` - Treesitter select: pick a syntax node by label

Works in normal, visual, and operator-pending mode (`ds<label>` deletes up to a target).

---

### 15. Comments
Neovim built-in (no plugin).
- `gcc` - Toggle line comment
- `gc{motion}` - Toggle comment over a motion (`gc3j`, `gcap`)
- `gc` (visual mode) - Toggle comment on selection

Comment strings come from the filetype (`commentstring`).

---

### 16. Gitsigns
**Plugin**: `lewis6991/gitsigns.nvim`

Git change markers in the sign column, hunk actions, and blame.

**Keybindings**:
- `]h` / `[h` - Next / previous hunk
- `<Space>gs` - Stage hunk
- `<Space>gr` - Reset hunk
- `<Space>gp` - Preview hunk
- `<Space>gb` - Blame line
- `<Space>gd` - Diff this file

---

### 17. Trouble (Diagnostics Panel)
**Plugin**: `folke/trouble.nvim`

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

---

### 18. todo-comments
**Plugin**: `folke/todo-comments.nvim`

Highlights `TODO`, `FIXME`, `HACK`, `NOTE`, `PERF`, `WARN` comments.
- `<Space>ft` - Search all TODO comments in the project (snacks picker)
- `]t` / `[t` - Next / previous TODO comment

---

### 19. which-key (Keymap Helper)
**Plugin**: `folke/which-key.nvim`

Shows available keybindings in a popup as you type.

**Usage**:
- `<Space>?` - Show all keymaps
- `<Space><Space>` - Show leader keymaps
- Press any key prefix (like `<Space>`, `z`, `g`, `]`) and wait 500ms to see available completions

Groups: `<Space>f` Find, `<Space>x` Diagnostics, `<Space>c` Code/LSP, `<Space>g` Git, `<Space>o` Harpoon, `<Space>n` Notifications, `<Space>t` Toggle, `<Space>m` Markdown, `<Space>i` Images/Files.

---

### 20. Satellite (Scrollbar)
**Plugin**: `lewis6991/satellite.nvim`

Scrollbar on the right of each window showing cursor position, search matches, diagnostics, git changes, and marks.

---

### 21. UFO (Code Folding)
**Plugins**:
- `kevinhwang91/nvim-ufo`
- `kevinhwang91/promise-async`

Folding from Treesitter queries with an indent fallback. Folded lines show the first line plus a line count. All folds start open.

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

---

### 22. Harpoon (Quick File Marks)
**Plugin**: `ThePrimeagen/harpoon` (harpoon2)

Per-project list of up to 5 files you jump to with one key.

**Keybindings**:
- `<Space>oa` - Add current file to Harpoon marks
- `<Space>oo` - Open Harpoon quick menu
- `<Space>o1` to `<Space>o5` - Jump to mark 1 to 5
- `<Space>on` - Navigate to next mark
- `<Space>op` - Navigate to previous mark

**Inside Harpoon Menu**:
- `j/k` or `Down/Up` - Navigate through marks
- `Enter` - Jump to selected file
- `dd` - Remove mark from list
- `q` or `Esc` - Close menu

---

### 23. vim-tmux-navigator
**Plugin**: `christoomey/vim-tmux-navigator`

- `Ctrl+h/j/k/l` - Move between Neovim splits and, at the edge of Neovim, into the neighbouring tmux pane

Pairs with the `is_vim` check in `tmux/tmux.conf`, which forwards the same keys into Neovim when a pane runs it.

---

### 24. Render Markdown
**Plugin**: `MeanderingProgrammer/render-markdown.nvim`

In-buffer markdown rendering: code blocks with borders, custom bullets, heading colors from the Vesper palette (headings use native Treesitter highlights).

**Keybindings**:
- `<Space>tr` - Toggle render markdown on/off
- `<Space>mp` - Open the markdown file in the default browser

Markdown buffers also get `conceallevel=2`, word wrap, and spell check.

---

### 25. Image.nvim
**Plugin**: `3rd/image.nvim`

Inline image display through the Kitty graphics protocol (Ghostty supports it; tmux has `allow-passthrough on`).

**Features**:
- Renders the image under the cursor in markdown files
- Opens `.png`, `.jpg`, `.jpeg`, `.gif`, `.webp` files as images
- Requires ImageMagick (`imagemagick` in the Brewfile)

**External files**:
- `<Space>io` - Open the current file with the system default application
- PDFs and Office documents (`.pdf`, `.docx`, `.xlsx`, `.pptx`, `.doc`, `.xls`, `.ppt`) are detected on open with a hint to use `<Space>io`

---

### 26. noice.nvim (Command Line and Messages)
**Plugin**: `folke/noice.nvim`

Replaces the command line with a centered popup, routes messages through the snacks notifier, adds borders to LSP hover and signature windows, and shows LSP progress.

---

### 27. nvim-colorizer
**Plugin**: `catgoose/nvim-colorizer.lua`

Highlights color codes (`#RGB`, `#RRGGBB`, `#RRGGBBAA`, `rgb()`, `hsl()`) with their color in every filetype. Color names are not highlighted.

---

### 28. Rainbow CSV
**Plugin**: `cameron-wags/rainbow_csv.nvim`

Colors each column of `.csv` and `.tsv` files differently. Loads only for those filetypes.

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

**Adding a server**:
1. Add its name to `ensure_installed` in the LSP section of `init.lua` (or install it once via `:Mason`)
2. Restart Neovim. mason-lspconfig enables it automatically; no `vim.lsp.enable` call is needed
3. For server-specific settings, add a `vim.lsp.config("server_name", { settings = { ... } })` block next to the `lua_ls` one

Formatters and linters are not managed by Mason. They come from the Brewfile so they are on `PATH` for the shell too. `dotdoctor` reports any that are missing.

---

## Keybindings Reference

### General Vim
- `i` - Insert mode
- `Esc` or `Ctrl+[` - Normal mode
- `v` - Visual mode
- `V` - Visual line mode
- `Ctrl+v` - Visual block mode
- `:w` - Save (without formatting)
- `:q` - Quit
- `:wq` or `ZZ` - Save and quit
- `:q!` - Quit without saving
- `u` - Undo
- `Ctrl+r` - Redo

### General Editor
- `<Space>w` - Format and save
- `<Space>q` - Quit window
- `<Space>cr` - Check and reload files
- `<Space>tw` - Toggle word wrap
- `gh` - Jump back in history
- `gl` - Jump forward in history
- `Esc` - Clear multicursors, then search highlights

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
- `s` - Flash jump
- `S` - Flash Treesitter select
- `]]` / `[[` - Next / previous LSP reference of the word under cursor
- `]f` `[f` `]c` `[c` `]a` `[a` `]l` `[l` - Treesitter function / class / argument / loop motions
- `]h` / `[h` - Next / previous git hunk
- `]t` / `[t` - Next / previous TODO comment

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
- `cin(` - Change inside the next parentheses (mini.ai)
- `daf` / `dif` - Delete a function / its body (Treesitter)
- `]s` / `[s` - Swap argument with next / previous
- `ys` `cs` `ds` - Add / change / delete surround
- `Ctrl+n` - Add multicursor at next match
- `.` - Repeat last command

### Windows/Splits
- `:split` or `:sp` - Horizontal split
- `:vsplit` or `:vs` - Vertical split
- `Ctrl+h/j/k/l` - Navigate splits and tmux panes
- `<Space>h/j/k/l` - Navigate splits
- `Ctrl+w =` - Equal size splits
- `Ctrl+w q` - Close current split

### LSP (configured in this setup)
- `gd` - Go to definition
- `K` - Peek fold or LSP hover documentation
- `<Space>rn` - Rename symbol
- `<Space>ca` - Code actions
- `grr` / `gri` / `grt` / `gO` - References / implementation / type definition / document symbols (built-in)

### Find (snacks picker)
- `<Space>ff` - Find files
- `<Space>fg` - Live grep (search in files)
- `<Space>fb` - Find buffers
- `<Space>fh` - Help tags
- `<Space>fu` - Undo history
- `<Space>ft` - Find TODO comments

### File Explorer (snacks)
- `-` - Toggle explorer
- `<Space>e` - Focus explorer

### Which-key (Keymap Discovery)
- `<Space>?` - Show all keymaps
- `<Space><Space>` - Show leader keymaps only

### Comments
- `gcc` - Toggle line comment
- `gc{motion}` - Toggle comment over a motion
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

### Git (gitsigns)
- `<Space>gs` - Stage hunk
- `<Space>gr` - Reset hunk
- `<Space>gp` - Preview hunk
- `<Space>gb` - Blame line
- `<Space>gd` - Diff this file

### Harpoon (Quick Marks)
- `<Space>oa` - Add file to Harpoon marks
- `<Space>oo` - Open Harpoon menu
- `<Space>o1` to `<Space>o5` - Jump to mark 1 to 5
- `<Space>on` - Navigate to next mark
- `<Space>op` - Navigate to previous mark

### Diagnostics (Trouble)
- `<Space>xx` - Workspace diagnostics
- `<Space>xX` - Buffer diagnostics
- `<Space>cs` - Symbols
- `<Space>cl` - LSP definitions and references
- `<Space>xL` / `<Space>xQ` - Location list / quickfix list

### Notifications
- `<Space>nd` - Dismiss notifications
- `<Space>nh` - Notification history

### Markdown
- `<Space>mp` - Open markdown file in browser
- `<Space>tr` - Toggle render markdown (in-buffer)

### Images and External Files
- `<Space>io` - Open file externally (PDFs, Office docs)

### Visual Mode
- `*` - Search for selected text
- `gc` - Toggle comment on selection
- `S{char}` - Surround selection
- `Ctrl+n` - Add multicursor at next match of the selection
- `<Space>A` - Add cursors to all matches

---

## Tips and Tricks

### Workflow Tips

1. **Quick File Switching**:
   - Use Harpoon for your 5 most-accessed files: `<Space>oa` to mark, `<Space>o1-5` to jump
   - `<Space>ff` to find files by name (for everything else)
   - `<Space>fb` to switch between open buffers
   - `-` to toggle the explorer for project navigation

2. **Search Across Project**:
   - `<Space>fg` then type search term
   - `gd` to jump to definitions, `grr` to list references
   - Visual select + `*` to search for selected text
   - `]]` / `[[` to walk through references of the symbol under the cursor

3. **Multiple Cursors**:
   - `Ctrl+n` on a word to add a cursor at the next occurrence, repeat as needed, then edit
   - `<Space>A` to grab every occurrence at once
   - The `cgn` pattern still works: search with `/pattern`, then `cgn` to change the next match, `.` to repeat

4. **Quick Edits**:
   - `ciw` - change word under cursor
   - `ci"` - change inside quotes
   - `cin{` - change inside the next braces even when the cursor is outside them
   - `cif` - change a function body
   - `]s` - swap two arguments without retyping

5. **Saving and Formatting**:
   - Edits are written to disk automatically after a second of idle time
   - `<Space>w` formats and writes when you want the formatter to run

6. **Markdown Editing**:
   - In-buffer rendering with `<Space>tr` for quick previews
   - Open in browser with `<Space>mp` for final review
   - Images render inline (Kitty graphics protocol)
   - Use `<Space>io` to open PDFs or Office docs externally

7. **Code Navigation with Folding**:
   - Open a large file and press `zM` to fold everything
   - Scan the structure, then `zo` on sections you need to see
   - Use `K` to peek inside folds without opening them

### Plugin-Specific Tips

**Picker**:
- `?` inside any picker lists its keys
- `<Space>fg` also finds TODO comments, but `<Space>ft` groups them by type
- `:lua Snacks.picker.git_status()` and `:lua Snacks.picker.diagnostics()` are two useful pickers without a mapping

**Explorer**:
- Press `?` inside the explorer to see all available commands
- Use `H` to toggle hidden files (like `.gitignore`, `.env`)
- Create nested directories with `a`: type `folder/subfolder/` and press Enter

**LSP**:
- `:checkhealth vim.lsp` - Check LSP status for current buffer
- `:LspLog` - View LSP logs for debugging
- Hover (`K`) twice to enter hover window (useful for long docs)

**Treesitter**:
- `:InspectTree` - See syntax tree (great for debugging highlighting)
- `:Inspect` - Show highlight groups under cursor
- `:TSLog` - See why a parser install failed

**Code Folding (UFO)**:
- Use `zM` to fold all code, then `zo` to selectively open sections you're working on
- Press `K` on a folded line to preview its contents without opening

**Harpoon**:
- Common pattern: 1=main/index, 2=config, 3=types, 4=tests, 5=utils
- Marks are stored per working directory

**Rainbow CSV**:
- Open any `.csv` or `.tsv` file to see automatic column highlighting
- `:RainbowDelim` sets a custom delimiter

### Learning Resources

- Vim Tutor: Run `vimtutor` in terminal
- Neovim Docs: Press `<Space>fh` and search
- Plugin Docs: Visit GitHub repos linked above

---

## Troubleshooting

### LSP not working
1. Check if server is running: `:checkhealth vim.lsp`
2. Verify server is installed: `:Mason`
3. Check logs: `:LspLog`
4. Restart LSP: `:LspRestart`

### Completion not appearing
1. Ensure LSP is running (`:checkhealth vim.lsp`)
2. Check if you're in insert mode
3. Try `Ctrl+Space` to trigger manually
4. Verify cmp sources: `:lua print(vim.inspect(require('cmp').get_config().sources))`

### No syntax highlighting or text objects for a language
1. Check the parser is installed: `:lua print(vim.inspect(require('nvim-treesitter').get_installed('parsers')))`
2. Install it: `:TSInstall <lang>`, then reopen the buffer with `:e`
3. If the install fails, check `:TSLog` and that `tree-sitter` is on `PATH` (`dotdoctor`)

### Formatting does nothing on `<Space>w`
1. `:ConformInfo` shows the formatters for the buffer and whether they are available
2. Run `dotdoctor` to see which formatter binaries are missing; `brew bundle` installs them

### Picker not finding files
1. Make sure you're in the right directory (`:pwd`)
2. Check if files are gitignored (the files picker respects `.gitignore`)
3. Press `?` inside the picker to find the toggle for hidden and ignored files

### Ctrl+h/j/k/l does not leave Neovim into tmux
1. Confirm tmux runs the config from this repo (`prefix + r` to reload)
2. Inside Neovim, `:TmuxNavigateLeft` should exist; if not, run `:Lazy sync`

### Colors look wrong
1. Check terminal supports true color: `:echo has('termguicolors')`
2. Inside tmux, confirm `default-terminal` is `tmux-256color` and the RGB override is set (both are in `tmux.conf`)

---

## Customization

This configuration uses `lazy.nvim` as the plugin manager. All config is in `nvim/init.lua`.

**To add a new plugin**:
1. Add to the `require("lazy").setup({})` table in `init.lua`
2. Restart Neovim or run `:Lazy sync`

**To modify keybindings**:
Look for `vim.keymap.set()` calls in `init.lua` and modify as needed. Keys defined in a plugin's `keys = {}` table load that plugin on first use.

**To add LSP servers**:
Add the server name to `ensure_installed` in the LSP section. Settings go in a `vim.lsp.config("name", {...})` block.

**To add a formatter or linter**:
1. Add the binary to the `Brewfile` and run `brew bundle`
2. Add it to `formatters_by_ft` (conform) or `linters_by_ft` (nvim-lint) in `init.lua`

---

## Quick Reference Card

| Command | Action |
|---------|--------|
| `<Space>w` | Format and save |
| `<Space>q` | Quit window |
| `<Space>ff` | Find files |
| `<Space>fg` | Search in files |
| `<Space>fb` | Find buffers |
| `<Space>fu` | Undo history |
| `<Space>ft` | Find TODOs |
| `-` | Toggle file explorer |
| `<Space>e` | Focus file explorer |
| `<Space>xx` | Toggle diagnostics panel |
| `gd` | Go to definition |
| `K` | Peek fold or hover docs |
| `<Space>rn` | Rename |
| `<Space>ca` | Code actions |
| `grr` | References |
| `]]` / `[[` | Next / previous reference |
| `gcc` | Toggle comment |
| `s` | Flash jump |
| `Ctrl+n` | Add multicursor |
| `za` | Toggle fold |
| `zM` | Close all folds |
| `zR` | Open all folds |
| `Ctrl+h/j/k/l` | Split and tmux pane navigation |
| `<Space>h/j/k/l` | Split navigation |
| `<Space>gs` / `gr` / `gp` / `gb` | Stage / reset / preview / blame hunk |
| `<Space>oa` | Add Harpoon mark |
| `<Space>oo` | Harpoon menu |
| `<Space>o1-5` | Jump to mark 1-5 |
| `<Space>on/op` | Next/previous mark |
| `<Space>mp` | Open markdown in browser |
| `<Space>tr` | Toggle markdown render |
| `<Space>io` | Open file externally |
| `gh/gl` | Jump history back/forward |
| `<Space>tw` | Toggle word wrap |
| `<Space>?` | Show all keymaps |
| `<Space><Space>` | Show leader keymaps |
| `:Mason` | Manage LSP servers |
| `:Lazy` | Manage plugins |
| `:TSInstall <lang>` | Install a Treesitter parser |
| `:ConformInfo` | Show formatters for this buffer |

# Neovim Configuration Guide

This guide covers the plugins, settings, and keybindings in this Neovim configuration (Neovim 0.11+).

Layout: `nvim/init.lua` holds options, autocmds, plugin-free keymaps and the lazy.nvim bootstrap. Every plugin lives in its own file under `nvim/lua/plugins/` (for example `lsp.lua`, `git.lua`, `debug.lua`), loaded through `{ import = "plugins" }`. Show this file from the shell with `dot keys nvim`.

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
- **Word wrap**: Off by default (`<Space>tw` toggles); on for markdown, with `breakindent` so wrapped lines keep their indent
- **Splits**: New vertical splits open to the right, horizontal splits below; 8 lines of context are kept above and below the cursor (`scrolloff`)
- **Stock plugins**: netrw, gzip, tar, zip, tohtml and tutor are not loaded. The snacks explorer opens directories; `gx` (open URL under cursor) is a core mapping
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

One plugin providing several modules. Enabled here: `explorer`, `picker`, `notifier`, `input`, `words`, `indent`, `scroll`, `bigfile`, `quickfile`, `zen`, `scratch`, `dim`, plus `toggle`, `gitbrowse`, `lazygit` and `bufdelete` which need no setup.

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
- `<Space>fr` - Recent files
- `<Space>fs` - Document symbols (LSP)
- `<Space>fd` - Diagnostics
- `<Space>fk` - Keymaps
- `<Space>fn` - Notification history (searchable, with preview)
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

LSP navigation (`gd`, `grr`, `gri`) also opens pickers, see the LSP section. Other pickers are available with `:lua Snacks.picker()` (a picker of pickers), for example `git_status`, `zoxide`, `lsp_workspace_symbols`.

**Words** (highlights other references of the symbol under the cursor via LSP):
- `]]` - Jump to next reference
- `[[` - Jump to previous reference

**Indent**: Indent guides with the current scope highlighted. Animation is off.

**Scroll**: Smooth scrolling for all scroll commands.

**Bigfile**: Files over 1.5 MB open with Treesitter, LSP-heavy features and folding trimmed.

**Toggles** (`Snacks.toggle`; which-key shows the current state of each):
- `<Space>tw` - Wrap
- `<Space>ts` - Spelling
- `<Space>tn` - Relative numbers
- `<Space>td` - Diagnostics
- `<Space>th` - Inlay hints
- `<Space>ti` - Indent guides
- `<Space>tD` - Dim everything outside the current scope
- `<Space>tz` - Zen mode (distraction-free, current window only)
- `<Space>tT` - Treesitter highlighting

**Git and scratch**:
- `<Space>gg` - Lazygit (full TUI in a floating window; `q` closes)
- `<Space>gl` - Lazygit log for the current file
- `<Space>go` - Open the current file, or selected lines, on GitHub in the browser
- `<Space>.` - Scratch buffer (persisted per project and filetype; run Lua with `<CR>`)
- `<Space>S` - Pick a scratch buffer

**Buffers** (`Snacks.bufdelete` closes a file without collapsing its window):
- `<Space>bd` - Close the current buffer, keep the window layout
- `<Space>bo` - Close every other buffer
- `Shift+h` / `Shift+l` - Previous / next buffer (defined in `init.lua`)

**Notifier and input** (`fancy` style: title bar with icon, source and time, message below; toasts stack bottom-right, wrap long lines, and grow to at most half the width and 60 percent of the height, with a "↓ N lines" footer beyond that):
- `<Space>fn` - Searchable notification history (picker; the preview shows the full text)
- `<Space>nh` - Notification history as a plain float
- `<Space>nd` - Dismiss all notifications
- Timeouts: INFO 3 s, WARN 8 s, ERROR sticky until dismissed
- Routine Vim messages (file written, yank/undo line counts, search wrap, "pattern not found") show as a fading one-liner bottom-right instead of a toast; see noice below
- Input prompts (for example LSP rename) use a floating window
- A one-line hint ("Space = menu | Space fk = search keys | dot keys nvim in the shell") shows on every start. It is marked temporary in `init.lua`; delete the `dotfiles_hint` block once the keys are familiar

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

The `main` branch of nvim-treesitter is only a parser and query installer. Highlighting and indentation are enabled per buffer by a `FileType` autocmd in `lua/plugins/treesitter.lua` for any filetype that has a parser.

**Parsers installed automatically**: c, cpp, lua, vim, vimdoc, query, markdown, markdown_inline, tsx, typescript, javascript, python, go, rust, java, json, yaml, toml, bash, html, css, regex (snacks picker input), latex (render-markdown math).

Missing parsers install asynchronously on the first start; reopen affected buffers with `:e` when the notification appears. `dot update` runs the install synchronously. Compiling parsers requires the `tree-sitter` CLI (`tree-sitter-cli` in the Brewfile).

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

**Servers installed by Mason**: `lua_ls`, `pyright`, `tsgo` (TypeScript 7 native server), `gopls`, `rust_analyzer`, `jdtls`, `clangd`. Mason needs `node`, `go` and `java` on `PATH` to install them; the Brewfile provides all three.

**ruff** also runs as a language server for Python. Its binary comes from the Brewfile, not Mason, so `lua/plugins/lsp.lua` enables it explicitly. It supplies the fix-all and organize-imports code actions under `<Space>ca`; its hover is disabled so `K` shows pyright only.

mason-lspconfig enables every Mason-installed server automatically. `vim.lsp.config("*", ...)` sets the completion capabilities (from blink.cmp) for all of them; only `lua_ls` has extra settings. All of this is in `lua/plugins/lsp.lua`.

**Keybindings** (buffer-local, set when a server attaches):
- `gd` - Go to definition (snacks picker with preview; jumps directly when there is one result)
- `grr` - References (snacks picker)
- `gri` - Implementations (snacks picker)
- `K` - Peek fold or show LSP hover documentation (context-aware)
- `<Space>rn` - Rename symbol with a live preview (inc-rename; `Enter` applies, `Esc` cancels)
- `<Space>ca` - Code actions
- `<Space>th` - Toggle inlay hints (snacks toggle)

**Rust** is handled by rustaceanvim rather than mason-lspconfig: it starts `rust-analyzer` (the binary still comes from Mason), adds `:RustLsp` commands (`runnables`, `expandMacro`, `openCargo`), and supplies the debugger and test adapter used below. `rust_analyzer` is excluded from mason-lspconfig's auto-enable so only one client attaches.

**Lua** gets `lazydev.nvim`: `lua_ls` and blink see only the runtime and plugin modules a file references, instead of loading every runtime file up front.

**Neovim built-in LSP keys** (also available):
- `grn` - Rename
- `gra` - Code action
- `grt` - Type definition
- `gO` - Document symbols
- `Ctrl+s` (insert mode) - Signature help

**Diagnostics**: Shown as virtual text at the end of the line and as underlines; no gutter signs. `<Space>xx` opens the Trouble panel.

---

### 7. blink.cmp (Autocompletion)
**Plugin**: `saghen/blink.cmp`

One plugin for completion, with a prebuilt Rust fuzzy matcher (downloaded on first install; `:Lazy build blink.cmp` rebuilds it, or set `build = "cargo build --release"` if the download fails).

**Completion Sources**:
1. LSP (context-aware completions)
2. Path (file system paths)
3. Snippets (LSP-provided, expanded with the built-in `vim.snippet`)
4. Buffer (words from open files)

**Keybindings** (in insert mode):
- `Ctrl+Space` - Trigger completion manually
- `Tab` - Select next item / jump to next snippet placeholder
- `Shift+Tab` - Select previous item / jump to previous placeholder
- `Enter` - Confirm selection (first item is preselected)
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
- JavaScript / TypeScript / JSX / TSX: `eslint_d`, only inside a project that has an eslint config (`eslint.config.*` or `.eslintrc*`)

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
- `<Space>xs` - Show symbols (functions, variables in current file)
- `<Space>xl` - LSP definitions and references
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
- Press any key prefix (like `<Space>`, `z`, `g`, `]`) and wait 200 ms to see available completions
- `<Space>fk` - Searchable picker of every mapping with its description (type a word like "fold" or "harpoon")
- `?` inside a picker, the explorer, Trouble or Mason lists that window's own keys
- From the shell: `dot keys nvim` pages this guide

Every keymap carries a `desc`, which is what which-key shows; `lua/plugins/which-key.lua` only defines the groups below and a few built-in keys.

Groups: `<Space>f` Find, `<Space>b` Buffer, `<Space>x` Diagnostics (Trouble), `<Space>c` Code actions, `<Space>g` Git, `<Space>h` Harpoon, `<Space>n` Notifications, `<Space>t` Toggle / tools, `<Space>m` Markdown, `<Space>i` Images/Files, `<Space>a` Claude, `<Space>d` Debug/Test.

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
- `<Space>ha` - Add current file to Harpoon marks
- `<Space>hh` - Open Harpoon quick menu
- `<Space>h1` `<Space>h2` `<Space>h3` `<Space>h4` `<Space>h5` - Jump to mark 1 to 5
- `<Space>hn` - Navigate to next mark
- `<Space>hp` - Navigate to previous mark

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

Routine messages are routed to the `mini` view (a fading one-liner bottom-right, the same place as LSP progress) so they never stack up as toasts: "written", "N lines yanked", "N fewer/more lines", undo/redo counters, "search hit BOTTOM/TOP", and E486 "Pattern not found". They still appear in `:messages` and `:Noice history`. Messages over 20 lines open in a split (`long_message_to_split`).

---

### 27. nvim-colorizer
**Plugin**: `catgoose/nvim-colorizer.lua`

Highlights color codes (`#RGB`, `#RRGGBB`, `#RRGGBBAA`, `rgb()`, `hsl()`) with their color in every filetype. Color names are not highlighted.

---

### 28. Rainbow CSV
**Plugin**: `cameron-wags/rainbow_csv.nvim`

Colors each column of `.csv` and `.tsv` files differently. Loads only for those filetypes.

---

### 29. claudecode.nvim (Claude Code in Neovim)
**Plugin**: `coder/claudecode.nvim`

Runs Claude Code in a snacks terminal split on the right (35 percent) using the same flags as the `ccd` shell alias (`--dangerously-skip-permissions`, so Claude never prompts, including for shell commands). Neovim speaks the same protocol as the VS Code extension: Claude sees the file and selection you send, and proposes edits as diffs you accept or reject inside Neovim.

**Keybindings** (`<Space>a` group):
- `<Space>ac` - Toggle the Claude terminal
- `<Space>af` - Focus the Claude terminal (or toggle if already focused)
- `<Space>ar` - Resume a previous session (`claude --resume`)
- `<Space>aC` - Continue the last session (`claude --continue`)
- `<Space>am` - Select the Claude model
- `<Space>ab` - Add the current buffer to Claude's context
- `<Space>as` (visual) - Send the selection to Claude
- `<Space>as` (in the explorer) - Add the file under the cursor
- `<Space>aa` / `<Space>ad` - Accept / deny the diff Claude proposed

Commands: `:ClaudeCode`, `:ClaudeCodeAdd <file> [start] [end]`, `:ClaudeCodeSendText {text}`, `:ClaudeCodeStatus`.

---

### 30. Debugging (nvim-dap + dap-ui)
**Plugins**: `mfussenegger/nvim-dap`, `rcarriga/nvim-dap-ui`, `jay-babu/mason-nvim-dap.nvim`

Adapters are installed by Mason on first start: `debugpy` (Python), `delve` (Go), `js-debug-adapter` (Node / JS / TS, registered as `pwa-node`), `codelldb` (Rust via rustaceanvim, also C/C++). The UI (scopes, breakpoints, stack, watches, REPL, console) opens when a session starts and closes when it ends.

**Keybindings** (`<Space>d` group, plus function keys like VS Code):
- `<Space>db` / `<Space>dB` - Toggle breakpoint / conditional breakpoint
- `<Space>dc` or `F5` - Continue (starts a session; pick a launch config on first run)
- `<Space>do` or `F10` - Step over
- `<Space>di` or `F11` - Step into
- `<Space>dO` or `Shift+F11` - Step out
- `<Space>de` - Evaluate the expression under the cursor or selection
- `<Space>dr` - Toggle the REPL
- `<Space>dl` - Run the last configuration again
- `<Space>du` - Toggle the debug UI
- `<Space>dx` - Terminate

Launch configs: Python runs the current file with the active venv's interpreter; Go offers file, test and package configs; JS/TS offer "Launch file (node)" and "Attach to node process"; Rust builds and debugs through `:RustLsp debuggables`.

---

### 31. Tests (neotest)
**Plugins**: `nvim-neotest/neotest` with `neotest-python`, `neotest-golang`, `neotest-vitest`, `neotest-jest`, and rustaceanvim's adapter

Runs the test under the cursor and shows results inline and in a summary tree.

**Keybindings**:
- `<Space>dt` - Run the nearest test
- `<Space>dT` - Run the current file
- `<Space>dD` - Debug the nearest test (uses nvim-dap)
- `<Space>ds` - Toggle the summary tree
- `<Space>dp` - Toggle the output panel
- `<Space>dS` - Stop

Python uses pytest with the interpreter from `$VIRTUAL_ENV`, else `.venv/bin/python` found upward from the cwd, else `python3`. Open uv projects from inside the project so the venv is found.

---

### 32. Small helpers
- `folke/lazydev.nvim` - see the LSP section (Lua workspace library on demand).
- `smjonas/inc-rename.nvim` - `:IncRename <name>` renames with a live preview; bound to `<Space>rn` when a server attaches. noice renders the prompt.
- `vim.o.winborder = "rounded"` - every floating window (hover, signature help, pickers) gets the same border.

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
1. Add its name to `ensure_installed` in `lua/plugins/lsp.lua` (or install it once via `:Mason`)
2. Restart Neovim. mason-lspconfig enables it automatically; no `vim.lsp.enable` call is needed
3. For server-specific settings, add a `vim.lsp.config("server_name", { settings = { ... } })` block next to the `lua_ls` one

Formatters and linters are not managed by Mason. They come from the Brewfile so they are on `PATH` for the shell too. `dot doctor` reports any that are missing.

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
- `<Space>q` - Close the current window; on the last window, quit Neovim (asks about unsaved buffers)
- `<Space>Q` - Quit everything (asks about unsaved buffers)
- `<Space>tR` - Reload files from disk (checktime)
- `<Space>tw` / `<Space>ts` / `<Space>tn` / `<Space>td` / `<Space>th` / `<Space>ti` / `<Space>tD` / `<Space>tz` / `<Space>tT` - Toggles: wrap, spelling, relative numbers, diagnostics, inlay hints, indent guides, dim, zen, treesitter
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

### Buffers
- `Shift+h` / `Shift+l` - Previous / next open file
- `<Space>bd` - Close the current file, keep the split
- `<Space>bo` - Close all other files
- `<Space>fb` - Pick an open file
- `<Space>fr` - Recent files

### Windows/Splits
- `:split` or `:sp` - Horizontal split
- `:vsplit` or `:vs` - Vertical split
- `Ctrl+h/j/k/l` - Navigate splits and tmux panes
- `Ctrl+w =` - Equal size splits
- `<Space>q` or `Ctrl+w q` - Close current split (`<Space>q` quits when it is the last one)

### LSP (configured in this setup)
- `gd` - Go to definition (picker)
- `grr` / `gri` - References / implementations (picker)
- `K` - Peek fold or LSP hover documentation
- `<Space>rn` - Rename symbol (live preview)
- `<Space>ca` - Code actions (includes ruff fixes in Python)
- `<Space>th` - Toggle inlay hints
- `grt` / `gO` - Type definition / document symbols (built-in)
- `:RustLsp runnables` / `debuggables` / `expandMacro` - rustaceanvim extras (Rust only)

### Claude Code
- `<Space>ac` / `af` - Toggle / focus the Claude terminal
- `<Space>ar` / `aC` - Resume / continue a session
- `<Space>ab` - Add the current buffer as context
- `<Space>as` - Send the visual selection (or add the explorer file)
- `<Space>aa` / `ad` - Accept / deny the proposed diff

### Debugging and Tests
- `<Space>db` / `dB` - Toggle / conditional breakpoint
- `<Space>dc` `F5` / `do` `F10` / `di` `F11` / `dO` `Shift+F11` - Continue / over / into / out
- `<Space>de` / `dr` / `dl` / `du` / `dx` - Eval / REPL / run last / toggle UI / terminate
- `<Space>dt` / `dT` / `dD` - Test nearest / file / debug nearest
- `<Space>ds` / `dp` / `dS` - Test summary / output panel / stop

### Find (snacks picker)
- `<Space>ff` - Find files
- `<Space>fg` - Live grep (search in files)
- `<Space>fb` - Find buffers
- `<Space>fh` - Help tags
- `<Space>fu` - Undo history
- `<Space>fr` - Recent files
- `<Space>fs` - Document symbols
- `<Space>fd` - Diagnostics
- `<Space>fk` - Keymaps
- `<Space>fn` - Notification history (searchable)
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
- `Tab` - Next item / next snippet placeholder
- `Shift+Tab` - Previous item / previous placeholder
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

### Git (gitsigns and snacks)
- `<Space>gs` - Stage hunk
- `<Space>gr` - Reset hunk
- `<Space>gp` - Preview hunk
- `<Space>gb` - Blame line
- `<Space>gd` - Diff this file
- `<Space>gg` - Lazygit
- `<Space>gl` - Lazygit log for this file
- `<Space>go` - Open file or selection on GitHub

### Scratch
- `<Space>.` - Scratch buffer
- `<Space>S` - Pick a scratch buffer

### Harpoon (Quick Marks)
- `<Space>ha` - Add file to Harpoon marks
- `<Space>hh` - Open Harpoon menu
- `<Space>h1` to `<Space>h5` - Jump to mark 1 to 5
- `<Space>hn` - Navigate to next mark
- `<Space>hp` - Navigate to previous mark

### Diagnostics (Trouble)
- `<Space>xx` - Workspace diagnostics
- `<Space>xX` - Buffer diagnostics
- `<Space>xs` - Symbols
- `<Space>xl` - LSP definitions and references
- `<Space>xL` / `<Space>xQ` - Location list / quickfix list

### Notifications
- `<Space>nd` - Dismiss notifications
- `<Space>nh` - Notification history (float)
- `<Space>fn` - Notification history (searchable picker)

### Markdown
- `<Space>mp` - Open markdown file in browser
- `<Space>tr` - Toggle render markdown (in-buffer)

### Images and External Files
- `<Space>io` - Open file externally (PDFs, Office docs; uses `open` on macOS, `xdg-open` on Linux)
- `gx` - Open the URL or path under the cursor in the system handler

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
   - Use Harpoon for your 5 most-accessed files: `<Space>ha` to mark, `<Space>h1` to `<Space>h5` to jump
   - `<Space>ff` to find files by name (for everything else)
   - `Shift+h` / `Shift+l` to step through open files, `<Space>fb` to pick one
   - `<Space>bd` to close a file when you are done with it (the split stays)
   - `-` to toggle the explorer for project navigation
   - `<Space>q` closes windows one at a time and quits on the last one; `<Space>Q` quits everything at once

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
4. Check blink loaded and its fuzzy binary is present: `:checkhealth blink.cmp`

### No syntax highlighting or text objects for a language
1. Check the parser is installed: `:lua print(vim.inspect(require('nvim-treesitter').get_installed('parsers')))`
2. Install it: `:TSInstall <lang>`, then reopen the buffer with `:e`
3. If the install fails, check `:TSLog` and that `tree-sitter` is on `PATH` (`dot doctor`)

### Debugger does not start
1. `:checkhealth mason` and `ls ~/.local/share/nvim/mason/bin` should show `debugpy`, `dlv`, `js-debug-adapter`, `codelldb`; `dot doctor` lists them. `:MasonInstall <name>` installs one by hand
2. Mason downloads some adapters with `wget` (in the Brewfile)
3. `:DapShowLog` shows adapter output; for Python make sure the venv interpreter is the one with your dependencies

### Tests are not discovered
1. neotest needs the parser for the language (`:TSInstall`) and a recognised test file name (`test_*.py`, `*_test.go`, `*.test.ts`)
2. `<Space>ds` opens the summary; `:Neotest summary` errors show adapter problems
3. Python: run from inside the project so `.venv` is found, or activate it before starting Neovim

### JavaScript/TypeScript has no LSP or shows an initialize error
1. `tsgo` must be installed: `:Mason`, or `:MasonInstall tsgo`
2. It needs `node` on `PATH` (`dot doctor`); the Brewfile installs it
3. The older `ts_ls` server is not used: its Mason bundle pulls TypeScript 7, which no longer ships the JS `tsserver` it needs

### Formatting does nothing on `<Space>w`
1. `:ConformInfo` shows the formatters for the buffer and whether they are available
2. Run `dot doctor` to see which formatter binaries are missing; `brew bundle` installs them

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

This configuration uses `lazy.nvim` as the plugin manager. `nvim/init.lua` holds options, autocmds and plugin-free keymaps; each plugin is a file in `nvim/lua/plugins/`.

**To add a new plugin**:
1. Create `nvim/lua/plugins/<name>.lua` that returns a lazy.nvim spec table (or a list of them), for example `return { "author/plugin.nvim", opts = {} }`
2. Restart Neovim or run `:Lazy sync` (commit the updated `lazy-lock.json`)

**To modify keybindings**:
Plugin-free keymaps are `vim.keymap.set()` calls in `init.lua`; plugin keymaps live in that plugin's file under `lua/plugins/`. Keys defined in a plugin's `keys = {}` table load that plugin on first use. Give every mapping a `desc`: which-key shows it and `dot keys nvim` documents it.

**To add LSP servers**:
Add the server name to `ensure_installed` in `lua/plugins/lsp.lua`. Settings go in a `vim.lsp.config("name", {...})` block next to `lua_ls`.

**To add a formatter or linter**:
1. Add the binary to the `Brewfile` and run `brew bundle`
2. Add it to `formatters_by_ft` in `lua/plugins/format.lua` (conform) or `linters_by_ft` in `lua/plugins/lint.lua` (nvim-lint)

---

## Quick Reference Card

| Command | Action |
|---------|--------|
| `<Space>w` | Format and save |
| `<Space>q` | Close window (quit if last) |
| `<Space>Q` | Quit all |
| `<Space>bd` | Close buffer, keep window |
| `Shift+h` / `Shift+l` | Previous / next buffer |
| `<Space>ff` | Find files |
| `<Space>fg` | Search in files |
| `<Space>fb` | Find buffers |
| `<Space>fu` | Undo history |
| `<Space>fr` | Recent files |
| `<Space>fd` | Diagnostics |
| `<Space>ft` | Find TODOs |
| `-` | Toggle file explorer |
| `<Space>e` | Focus file explorer |
| `<Space>xx` | Toggle diagnostics panel |
| `<Space>xs` / `<Space>xl` | Symbols / LSP panels (Trouble) |
| `gd` | Go to definition (picker) |
| `K` | Peek fold or hover docs |
| `<Space>rn` | Rename |
| `<Space>ca` | Code actions |
| `<Space>th` | Toggle inlay hints |
| `grr` / `gri` | References / implementations (picker) |
| `]]` / `[[` | Next / previous reference |
| `gcc` | Toggle comment |
| `s` | Flash jump |
| `Ctrl+n` | Add multicursor |
| `za` | Toggle fold |
| `zM` | Close all folds |
| `zR` | Open all folds |
| `Ctrl+h/j/k/l` | Split and tmux pane navigation |
| `<Space>gs` / `gr` / `gp` / `gb` | Stage / reset / preview / blame hunk |
| `<Space>gg` / `go` | Lazygit / open on GitHub |
| `<Space>ac` / `as` | Toggle Claude / send selection |
| `<Space>aa` / `ad` | Accept / deny Claude diff |
| `<Space>db` / `F5` / `F10` / `F11` | Breakpoint / continue / step over / step into |
| `<Space>du` / `de` | Debug UI / eval |
| `<Space>dt` / `dT` / `ds` | Test nearest / file / summary |
| `<Space>.` | Scratch buffer |
| `<Space>ha` | Add Harpoon mark |
| `<Space>hh` | Harpoon menu |
| `<Space>h1` to `<Space>h5` | Jump to mark 1-5 |
| `<Space>hn` / `<Space>hp` | Next/previous mark |
| `<Space>mp` | Open markdown in browser |
| `<Space>tr` | Toggle markdown render |
| `<Space>io` | Open file externally |
| `gh/gl` | Jump history back/forward |
| `<Space>tw` / `ts` / `tz` / `tD` | Toggle wrap / spell / zen / dim |
| `<Space>fn` / `<Space>nh` | Notification history (picker / float) |
| `<Space>?` | Show all keymaps |
| `<Space><Space>` | Show leader keymaps |
| `:Mason` | Manage LSP servers |
| `:Lazy` | Manage plugins |
| `:TSInstall <lang>` | Install a Treesitter parser |
| `:ConformInfo` | Show formatters for this buffer |

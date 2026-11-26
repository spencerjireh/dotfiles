# Neovim Keys and Plugins

Configuration: `nvim/` (linked to `~/.config/nvim`), Neovim 0.11+. `nvim/init.lua` holds
options, autocmds and plugin-free keymaps; each plugin is a file under `nvim/lua/plugins/`.
`dot keys nvim` shows this file, `dot keys nvim --sheet` only the key tables.

Leader is `Space`, local leader is `\`. In the editor, `<Space>?` shows every keymap,
`<Space><Space>` the leader ones, and `<Space>fk` searches them by description. `?` inside a
picker, the explorer, Trouble or Mason lists that window's own keys.

The `Space` layer uses the same verbs as tmux's `prefix` layer (direction, previous/next, split,
close, find, help, slot). The table is in [tmux.md](tmux.md) under "Mental model".

| Group | Purpose | Group | Purpose |
|-------|---------|-------|---------|
| `<Space>f` | Find | `<Space>g` | Git |
| `<Space>b` | Buffers | `<Space>x` | Diagnostics (Trouble) |
| `<Space>c` | Code actions | `<Space>d` | Debug and tests |
| `<Space>m` | Harpoon marks | `<Space>s` | Sessions |
| `<Space>t` | Toggles and tools | `<Space>n` | Notifications |
| `<Space>i` | Images and files | `<Space>a` | Claude |

## Save, quit, windows

| Action | Keys |
|--------|------|
| Format and save | `<Space>w` |
| Format changed hunks, then save | `<Space>W` |
| Close the window (quits on the last) | `<Space>q` |
| Quit everything | `<Space>Q` |
| Move to a split or tmux pane | `Ctrl+h/j/k/l` |
| Split right / below / equalize | `<Space>\|` / `<Space>-` / `<Space>=` |
| Previous / next buffer | `Shift+h` / `Shift+l` |
| Close this buffer, keep the split | `<Space>bd` |
| Close every other buffer | `<Space>bo` |
| Jump back / forward in history | `gh` / `gl` |
| Reload files from disk | `<Space>tR` |

Split with `<Space>|` and `<Space>-`, the same keys as tmux; `<Space>h` / `<Space>j` / `<Space>k` /
`<Space>l` also move between splits. Edits are written to disk one second
after you stop typing (auto-save); auto-save never formats, only `<Space>w` and `<Space>W` do.

## Find

| Action | Keys |
|--------|------|
| Smart find (buffers, recent, project files) | `<Space>ff` |
| Project files only | `<Space>fF` |
| Live grep | `<Space>fg` |
| Grep the word under the cursor or the selection | `<Space>fw` |
| Reopen the last picker | `<Space>fl` |
| Projects (changes directory, restores the session) | `<Space>fp` |
| Buffers / recent files | `<Space>fb` / `<Space>fr` |
| Document / workspace symbols | `<Space>fs` / `<Space>fS` |
| Diagnostics | `<Space>fd` |
| TODO comments | `<Space>ft` |
| Help tags / keymaps | `<Space>fh` / `<Space>fk` |
| Undo history | `<Space>fu` |
| Notification history | `<Space>fn` |
| Find and replace across the project | `<Space>fR` |
| Search for the visual selection | `*` (visual) |

In a picker: `Ctrl+j/k` move, `Enter` opens, `Ctrl+s` / `Ctrl+v` / `Ctrl+t` open in a split,
vertical split or tab, `Tab` selects several. `:lua Snacks.picker()` lists every picker. In the
find-and-replace buffer, `<localleader>r` replaces all and `?` lists the rest.

## Explorer

| Action | Keys |
|--------|------|
| Toggle / focus the explorer | `-` / `<Space>e` |
| Open or expand / collapse | `Enter` or `l` / `h` |
| Add (end with `/` for a directory) | `a` |
| Rename / delete to trash | `r` / `d` |
| Copy / move / cut / paste | `c` / `m` / `x` / `p` |
| Yank the path | `y` |
| Toggle hidden / ignored files | `H` / `I` |

## Code

| Action | Keys |
|--------|------|
| Go to definition | `gd` |
| References / implementations | `grr` / `gri` |
| Type definition / document symbols | `grt` / `gO` |
| Hover, or peek a closed fold | `K` |
| Rename with live preview | `<Space>rn` |
| Code actions (ruff fixes in Python) | `<Space>ca` |
| Next / previous reference of this symbol | `]]` / `[[` |
| Signature help (insert mode) | `Ctrl+s` |
| LSP status: what attached and why not | `<Space>tl` |

Completion (blink.cmp, insert mode): `Ctrl+n` opens the menu, `Tab` / `Shift+Tab` move through
items and snippet placeholders, `Enter` confirms, `Ctrl+e` closes. `Ctrl+Space` does not reach
Neovim inside tmux.

## Editing

| Action | Keys |
|--------|------|
| Jump to a label / select a node | `s` / `S` |
| Cursor at the next match / skip it | `Ctrl+n` / `Ctrl+p` |
| Cursors on every match | `<Space>A` |
| Clear cursors, then highlights | `Esc` |
| Add / change / delete a surround | `ys` / `cs` / `ds` (`ysiw"`, `cs"'`) |
| Surround the selection | `S{char}` (visual) |
| Function / class objects | `af` `if` / `ac` `ic` |
| Argument / conditional objects | `aa` `ia` / `ai` `ii` |
| Next / last object (`cin(`) | `an` `in` / `al` `il` |
| Start / end of the object | `g[` / `g]` |
| Next / previous function, class | `]f` `[f` / `]c` `[c` |
| Next / previous argument, loop | `]a` `[a` / `]l` `[l` |
| Swap argument with next / previous | `]s` / `[s` |
| Next / previous TODO comment | `]t` / `[t` |
| Toggle a comment | `gcc`, `gc{motion}`, `gc` (visual) |
| Scratch buffer / pick one | `<Space>.` / `<Space>S` |

## Git

| Action | Keys |
|--------|------|
| Next / previous hunk | `]h` / `[h` |
| Stage / reset / preview the hunk | `<Space>gs` / `<Space>gr` / `<Space>gp` |
| Blame the line / diff this file | `<Space>gb` / `<Space>gd` |
| Lazygit / its log for this file | `<Space>gg` / `<Space>gl` |
| Open the file or selection on GitHub | `<Space>go` |
| Commits / status / branches pickers | `<Space>gc` / `<Space>gS` / `<Space>gB` |
| Diffview: open / close | `<Space>gv` / `<Space>gV` |
| History of this file / of the repo | `<Space>gh` / `<Space>gH` |

Lazygit is for staging; diffview is for reading a change (`:DiffviewOpen main..HEAD` for a
branch). `<Space>gh` in visual mode shows the history of the selected lines.

## Diagnostics

| Action | Keys |
|--------|------|
| Workspace / buffer diagnostics | `<Space>xx` / `<Space>xX` |
| Symbols / LSP definitions and references | `<Space>xs` / `<Space>xl` |
| Location list / quickfix list | `<Space>xL` / `<Space>xQ` |
| Notifications: history / dismiss | `<Space>nh` / `<Space>nd` |

Diagnostics show as virtual text and underlines, with no gutter signs. Notifications time out
after 3 s (info) or 8 s (warning); errors stay until dismissed.

## Debug and tests

| Action | Keys |
|--------|------|
| Breakpoint / conditional breakpoint | `<Space>db` / `<Space>dB` |
| Continue (starts a session) | `<Space>dc` or `F5` |
| Step over / into / out | `<Space>do` / `<Space>di` / `<Space>dO` |
| The same on function keys | `F10` / `F11` / `Shift+F11` |
| Evaluate / REPL / run last | `<Space>de` / `<Space>dr` / `<Space>dl` |
| Toggle the debug UI / terminate | `<Space>du` / `<Space>dx` |
| Test nearest / file / debug nearest | `<Space>dt` / `<Space>dT` / `<Space>dD` |
| Test summary / output / stop | `<Space>ds` / `<Space>dp` / `<Space>dS` |

Adapters come from Mason: debugpy, delve, js-debug-adapter, codelldb. Tests run through neotest
(pytest, Go, vitest, jest, Rust). Python uses `$VIRTUAL_ENV`, else the nearest `.venv`, so open
uv projects from inside the project. Without Mason the debug keys are absent; test keys remain.

## Sessions and marks

| Action | Keys |
|--------|------|
| Restore this directory's / the last session | `<Space>ss` / `<Space>sl` |
| Do not save this session on exit | `<Space>sd` |
| Add a Harpoon mark / open the menu | `<Space>ma` / `<Space>mm` |
| Jump to mark 1 to 5 | `<Space>1` to `<Space>5` |
| Next / previous mark | `<Space>mn` / `<Space>mp` |

Sessions are saved per directory on exit and never restored automatically.

## Folding

| Action | Keys |
|--------|------|
| Toggle / close / open the fold | `za` / `zc` / `zo` |
| Open all / close all | `zR` / `zM` |
| Next / previous fold | `zj` / `zk` |

## Toggles

| Action | Keys |
|--------|------|
| Wrap / spelling / relative numbers | `<Space>tw` / `<Space>ts` / `<Space>tn` |
| Diagnostics / inlay hints / indent guides | `<Space>td` / `<Space>th` / `<Space>ti` |
| Dim outside the scope / zen mode | `<Space>tD` / `<Space>tz` |
| Treesitter highlighting | `<Space>tT` |
| Render Markdown / open it in the browser | `<Space>tr` / `<Space>tm` |
| Open with the system application | `<Space>io` |

Images render inline in Markdown and when opened directly (Kitty graphics protocol; needs
imagemagick). PDFs and Office files show a hint to use `<Space>io`.

## Claude

| Action | Keys |
|--------|------|
| Toggle / focus the Claude terminal | `<Space>ac` / `<Space>af` |
| Resume / continue a session | `<Space>ar` / `<Space>aC` |
| Select the model | `<Space>am` |
| Add this buffer to the context | `<Space>ab` |
| Send the selection, or the explorer file | `<Space>as` |
| Accept / deny the proposed diff | `<Space>aa` / `<Space>ad` |

Runs with the same flags as the `ccd` alias, so it never prompts. The plugin and these keys are
absent when the machine's agent is not Claude (`DOTFILES_AGENT`, see [install.md](install.md)).

## Languages

Everything follows the repo being edited. The statusline shows the result for the current
buffer: `lsp:<clients> fmt:<formatters|none> lint:<linters>`.

| Language | Server | Formatter (needs its config in the repo) | Linter |
|----------|--------|------------------------------------------|--------|
| Python | pyright, ruff | black (`[tool.black]`), else ruff (`[tool.ruff]`, `ruff.toml`) | ruff |
| JS / TS | tsgo (deno where `deno.json`) | biome, deno fmt, or prettier, by config file | eslint_d |
| Lua | lua_ls | stylua (`stylua.toml`) | |
| Go | gopls | gofmt | |
| Rust | rust-analyzer (rustaceanvim) | rustfmt | |
| Java | jdtls | google-java-format | |
| C / C++ | clangd | clang-format (`.clang-format`) | |
| Shell | on demand | shfmt (`.editorconfig`) | shellcheck |
| JSON, YAML, CSS, HTML, Markdown | on demand | biome or prettier, by config file | |
| Dockerfile | on demand | | hadolint |

- **Servers**: the first seven are installed by Mason at first start. Servers for other
  filetypes (the `on_demand` table in `lua/plugins/lsp.lua`) install the first time such a file
  opens. To add one, put it in `ensure_installed` or `on_demand`; settings go in a
  `vim.lsp.config("name", {...})` block.
- **Formatting** runs only on `<Space>w`. A formatter runs only when the repo carries its config;
  otherwise the file is saved as is and the statusline says `fmt:none`. Repo-local binaries
  (`node_modules/.bin`, `.venv/bin`) win over the brew ones. LSP formatting is never a fallback.
  `:ConformInfo` explains the choice for a buffer.
- **Linting** runs on read, write and leaving insert mode, with the same repo-config rule.
- **Formatters and linters come from the Brewfile**, not Mason, so the shell has them too.
- **Rust** goes through rustaceanvim: `:RustLsp runnables`, `debuggables`, `expandMacro`.
- **Per-repo overrides**: a `.nvim.lua` in the working directory is sourced after `:trust`.
- **Indentation** is detected per file (guess-indent); `.editorconfig` wins when present.
- **Parsers**: 23 Treesitter parsers install on first start; `:TSInstall <lang>` adds one and
  needs the `tree-sitter` CLI.
- **Without Mason** (`DOTFILES_MASON=0`, the `work` profile): nothing is downloaded. Servers
  already on `PATH` are enabled: pyright, lua-language-server, TypeScript (`tsgo`, else
  TypeScript 7's `tsc --lsp`), and the bash, JSON, YAML, HTML, CSS, Markdown, TOML and Dockerfile
  servers if present. Settings are listed in [install.md](install.md).

## Plugins

| Plugin | Purpose | Spec file |
|--------|---------|-----------|
| vesper.nvim | Colour scheme, transparent background | `colorscheme.lua` |
| snacks.nvim | Explorer, pickers, notifier, toggles, lazygit, scratch, zen, smooth scroll | `snacks.lua` |
| which-key.nvim | Key popup; defines the groups | `which-key.lua` |
| lualine.nvim | Statusline with the `lsp: fmt: lint:` segment | `lualine.lua` |
| noice, satellite, colorizer | Command line popup, scrollbar, colour previews | `ui.lua` |
| nvim-treesitter (+ textobjects, context) | Highlighting, indent, motions, pinned scope header | `treesitter.lua` |
| lspconfig, mason, SchemaStore, lazydev, inc-rename | Language servers | `lsp.lua` |
| blink.cmp, nvim-autopairs | Completion and bracket pairs | `completion.lua` |
| conform.nvim | Formatting | `format.lua` |
| nvim-lint | Linting | `lint.lua` |
| guess-indent.nvim | Indent detection | `indent.lua` |
| auto-save.nvim | Write after one idle second | `autosave.lua` |
| surround, mini.ai, multicursor, flash, todo-comments, rainbow_csv | Editing helpers | `editing.lua` |
| nvim-ufo | Folding | `folds.lua` |
| gitsigns.nvim | Hunks and blame | `git.lua` |
| diffview.nvim | Diffs and history | `diffview.lua` |
| trouble.nvim | Diagnostics panel | `trouble.lua` |
| harpoon | File marks | `harpoon.lua` |
| persistence.nvim | Sessions | `sessions.lua` |
| grug-far.nvim | Find and replace | `replace.lua` |
| render-markdown, image.nvim | Markdown rendering, inline images | `markdown.lua` |
| vim-tmux-navigator | `Ctrl+h/j/k/l` across splits and tmux panes | `tmux-navigator.lua` |
| nvim-dap, dap-ui, mason-nvim-dap | Debugging | `debug.lua` |
| neotest, rustaceanvim | Tests, Rust tooling | `test.lua` |
| claudecode.nvim | Claude Code terminal and diffs | `claudecode.lua` |

To add a plugin, create `nvim/lua/plugins/<name>.lua` returning a lazy.nvim spec, run
`:Lazy sync`, and commit `lazy-lock.json`. Every keymap needs a `desc`.

## Troubleshooting

- **No language server**: `<Space>tl`, then `:Mason`, `:LspLog`, `:LspRestart`
- **JS / TS server missing**: `:MasonInstall tsgo`; it needs `node` on `PATH`. `ts_ls` is not used
- **`<Space>w` does not format**: `fmt:none` means the repo has no formatter config, by design. `:ConformInfo` says why
- **No highlighting for a language**: `:TSInstall <lang>`, reopen with `:e`; `:TSLog` on failure
- **Completion missing**: `Ctrl+n` opens it by hand; `:checkhealth blink.cmp`
- **Debugger does not start**: `dot doctor` lists the adapters; `:MasonInstall <name>`; `:DapShowLog`
- **Tests not found**: The parser must be installed and the file name recognised; Python needs `.venv` in reach
- **`Ctrl+h/j/k/l` stays inside Neovim**: Reload tmux (`prefix + r`); `:TmuxNavigateLeft` must exist, else `:Lazy sync`
- **Colours look wrong**: The terminal needs true colour; tmux sets `tmux-256color` and the RGB override

`dot doctor` reports missing binaries (formatters, linters, runtimes, adapters).

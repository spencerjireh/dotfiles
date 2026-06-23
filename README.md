# Dotfiles

Personal development environment for macOS and Linux.

## What's Inside

- **Ghostty** - GPU-accelerated terminal (renderer only, titlebar hidden)
- **tmux** - Window/pane management, vi-style copy mode
- **Zsh** - Shell with Oh My Zsh, Powerlevel10k, and vi mode
- **Neovim** - Single-file config (`init.lua`) with lazy.nvim

All tools share the **Vesper** color scheme (`#101010` bg, `#ffffff` fg, `#ffc799` accent).

## Installation

### Prerequisites

None — the installer bootstraps its own foundation. On a fresh machine it installs **Homebrew** (may prompt for your password once), **zsh**, **Oh My Zsh**, and **gum** before the TUI appears. `git` and `curl` (preinstalled on macOS / most Linux) are all you need to start.

### Setup

```bash
git clone git@github.com:spencerjireh/dotfiles.git
cd dotfiles
./install.sh
```

### What the Install Script Does

The installer runs a **TUI up front** (powered by [`gum`](https://github.com/charmbracelet/gum), auto-bootstrapped on first run, cross-platform on macOS + Linux): you tick which components to install and fill in any inputs (GitHub/Git name + email), confirm a summary, and then it **runs unattended** — no more mid-install prompts. If `gum` can't be installed it falls back to plain text prompts.

Selectable components (all pre-selected by default):

| Component | What it does |
|-----------|--------------|
| Homebrew CLI packages | neovim, tmux, fzf, fd, eza, bat, ripgrep, git-delta, zoxide, pyenv, imagemagick, rust, trash |
| Ghostty terminal | Installs the Ghostty app (cask on macOS) + symlinks `ghostty/config` |
| Claude Code | Installs via the official native installer (self-updating) |
| Nerd Font | GohuFont Nerd Font (cask on macOS, downloaded on Linux) |
| Neovim config | Symlinks `nvim/` → `~/.config/nvim` |
| tmux + TPM | Symlinks `tmux.conf`, installs TPM + plugins |
| Zsh + Oh My Zsh | Symlinks `.zshrc`/`.p10k.zsh`, installs autosuggestions/syntax-highlighting/powerlevel10k |
| GitHub SSH + CLI | Generates an ed25519 key, writes `~/.ssh/config`, installs `gh` |
| Git global config | name/email, delta pager, git aliases |
| macOS defaults | Fastest key repeat + repeat-on-hold, Finder, Dock, trackpad, screenshots (macOS only) |

Symlinks are created with **automatic backup** of any existing file.

Packages live in a declarative **`Brewfile`** (installed via `brew bundle`); casks that are individually toggleable in the TUI (Ghostty, font, `gh`) stay in `install.sh`.

### Maintenance

Two helpers are symlinked onto your PATH (`~/.local/bin`) during install:

```bash
dotup       # pull dotfiles, brew bundle + upgrade, update tmux/zsh/nvim plugins, update Claude
dotdoctor   # health check: verifies every symlink + that assumed tools exist
```

### Machine-specific config

Anything machine- or work-specific (per-machine PATHs, tool installers, private aliases) goes in **`~/.zshrc.local`** (untracked), sourced at the end of `.zshrc`. Install seeds it from `zsh/.zshrc.local.example` if absent — so the tracked `.zshrc` stays clean and portable.

### Tests

```bash
./tests/run.sh   # dependency-free; runs in a sandbox, installs nothing
```

Covers script linting, the `lib/` helpers, and `install.sh`'s symlink/selection logic. Runs in CI (GitHub Actions) on every push.

### Uninstallation

```bash
./uninstall.sh  # Removes symlinks, restores backups
```

## Directory Structure

```
├── ghostty/
│   └── config
├── tmux/
│   └── tmux.conf
├── zsh/
│   ├── .zshrc
│   └── .p10k.zsh
├── nvim/
│   ├── init.lua
│   └── lazy-lock.json
├── git/
│   └── aliases
├── lib/
│   ├── log.sh        # logging helpers
│   └── tui.sh        # gum-backed TUI helpers (with plain fallback)
├── tests/
│   └── run.sh        # dependency-free test suite
├── .github/workflows/
│   └── test.yml      # CI: runs the suite + shellcheck
├── Brewfile          # declarative package list (brew bundle)
├── install.sh
├── uninstall.sh
├── update.sh         # `dotup` — update everything
└── doctor.sh         # `dotdoctor` — health check
```

## tmux Keybinds

Prefix: `Cmd+Shift+Space` (Ghostty translates to `Ctrl+Space`)

### Navigation

| Action | Keys |
|--------|------|
| Seamless pane/vim nav | `C-h/j/k/l` (no prefix) |
| Navigate panes | `prefix + h/j/k/l` |
| Window by number | `Alt+1-9` (no prefix) |
| Next/prev window | `prefix + n/p` |

### Copy Mode

| Action | Keys |
|--------|------|
| Enter copy mode | `prefix + Enter` |
| Start selection | `v` |
| Select line | `V` |
| Yank to clipboard | `y` |
| Exit | `Escape` |

### Management

| Action | Keys |
|--------|------|
| Split vertical | `prefix + v` or `\|` |
| Split horizontal | `prefix + s` or `-` |
| Resize panes | `prefix + H/J/K/L` |
| New window | `prefix + c` |
| Close window | `prefix + X` |
| Close pane | `prefix + x` |
| New session | `prefix + S` |
| Session tree | `prefix + w` |
| Kill session | `prefix + q` |
| Toggle status bar | `prefix + b` |
| Reload config | `prefix + r` |

tmux auto-starts when opening Ghostty, attaching to the `main` session.

## Shell Aliases

```bash
# tmux
tm              # attach or create session
tls             # list sessions
tks <name>      # kill session

# editors & tools
v               # nvim
cld             # claude
ccd             # claude --dangerously-skip-permissions

# modern replacements
ls → eza        # with icons and git status
cat → bat       # with syntax highlighting
rm → trash      # safe delete
```

## Troubleshooting

**Symlinks not working** — Re-run `./install.sh`

**tmux colors wrong** — Ensure terminal reports 256-color. Config sets `default-terminal` to `tmux-256color`.

**tmux plugins not loaded** — Press `prefix + I` inside tmux to install plugins via TPM.

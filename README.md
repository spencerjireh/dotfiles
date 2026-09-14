# Dotfiles

Personal development environment for macOS and Linux.

## What's Inside

- **Ghostty** - GPU-accelerated terminal (renderer only, titlebar hidden)
- **tmux** - Window/pane management, vi-style copy mode
- **Zsh** - Shell with Oh My Zsh, Powerlevel10k, and vi mode
- **Neovim** - lazy.nvim, one plugin spec per file under `nvim/lua/plugins/`
- **Superfile** - TUI file manager (`spf`) with vim-style hotkeys, cd-on-quit, bat previews, zoxide

All tools share the **Vesper** color scheme (`#101010` bg, `#ffffff` fg, `#ffc799` accent).

Keybinding and alias references live in [`docs/`](docs/) and are shown by `dot keys`:

| Topic | File | In-app help |
|-------|------|-------------|
| Neovim | [docs/nvim.md](docs/nvim.md) | `<Space>?` (which-key), `<Space>fk` (keymap picker) |
| tmux | [docs/tmux.md](docs/tmux.md) | `prefix + ?` (opens the same file in a popup) |
| Zsh | [docs/zsh.md](docs/zsh.md) | `dot keys zsh` |
| Superfile | [docs/superfile.md](docs/superfile.md) | `?` inside `spf` |

## Installation

### Prerequisites

None. The installer bootstraps its own foundation. On a fresh machine it installs **Homebrew** (may prompt for your password once) and **gum** before the TUI appears; **zsh** and **Oh My Zsh** are installed with the Zsh component. `git` and `curl` (preinstalled on macOS / most Linux) are all you need to start.

### Setup

```bash
git clone git@github.com:spencerjireh/dotfiles.git
cd dotfiles
./install.sh
```

`./install.sh` forwards to `bin/dot install`. After the first run, `dot` is on your PATH.

### What the Install Script Does

The installer runs a **TUI up front** (powered by [`gum`](https://github.com/charmbracelet/gum), auto-bootstrapped on first run, cross-platform on macOS + Linux): you tick which components to install and fill in any inputs (GitHub/Git name + email), confirm a summary, and then it **runs unattended**. If `gum` can't be installed it falls back to plain text prompts.

Selectable components (all pre-selected by default):

| Component | What it does |
|-----------|--------------|
| Homebrew CLI packages | neovim, tree-sitter-cli, tmux, fzf, fd, eza, bat, ripgrep, git-delta, zoxide, uv, imagemagick, rustup (+ `rustup default stable`), trash, lazygit, wget, language runtimes for the LSP servers (node, go, openjdk), plus formatters/linters (stylua, ruff, prettierd, eslint_d, clang-format, google-java-format) |
| Ghostty terminal | Installs the Ghostty app (cask on macOS) + symlinks `ghostty/config` (opens maximized, Option acts as Alt, Cmd keys mapped to tmux) |
| Claude Code | Installs via the official native installer (self-updating) |
| Nerd Font | GohuFont Nerd Font (cask on macOS, downloaded on Linux) |
| Neovim config | Symlinks `nvim/` to `~/.config/nvim` |
| Superfile file manager | Installs `superfile` (brew) + symlinks config, hotkeys, and Vesper theme |
| tmux + TPM | Symlinks `tmux.conf`, installs TPM + plugins (resurrect, thumbs; headless, no tmux session needed) |
| Zsh + Oh My Zsh | Symlinks `.zshrc`/`.p10k.zsh`, installs autosuggestions/syntax-highlighting/powerlevel10k |
| GitHub SSH + CLI | Generates an ed25519 key, writes a `~/.ssh/config` host block (agent + keychain), installs `gh` |
| Git global config | name/email prompts; everything else (delta pager, pull.rebase, autoSetupRemote, aliases) is tracked in `git/config` and included via `include.path`; `git/ignore` becomes the global ignore |
| Karabiner (Caps Lock as Esc/Ctrl) | Installs Karabiner-Elements + links `karabiner/` to `~/.config/karabiner`: Caps Lock is Escape when tapped, Control when held (macOS only) |
| macOS defaults | Fastest key repeat + repeat-on-hold, Finder, Dock, trackpad, screenshots (macOS only) |

Symlinks are created with **automatic backup** of any existing file. The selection is recorded in `~/.config/dotfiles/components` so `dot doctor` checks only what this machine has; re-running the installer merges new selections into it.

Packages live in a declarative **`Brewfile`** (installed via `brew bundle`); casks that are individually toggleable in the TUI (Ghostty, font, `gh`) stay in `cmd/install.sh`.

### The `dot` command

Linked to `~/.local/bin/dot` during install. Every script in the repo is reachable through it:

```bash
dot install          # the installer (same as ./install.sh)
dot update           # pull dotfiles, brew bundle + upgrade, tmux/zsh/nvim plugins, mason registry, tmux-thumbs, Claude
dot doctor           # health check for the recorded components: symlinks, tools, runtimes, formatters, LSP servers, adapters, TPM plugins
dot doctor --links   # only the symlinks/dirs the installer creates (used by CI)
dot keys             # list reference topics; dot keys tmux | nvim | zsh | superfile | all
dot edit [query]     # fzf over the repo's tracked files, open in $EDITOR (zshconfig, nvimconfig, tmuxconfig are shortcuts)
dot uninstall        # remove the symlinks, restore backups
dot dir              # print the repo path: cd "$(dot dir)"
```

`dotup` and `dotdoctor` remain as zsh aliases for `dot update` and `dot doctor`.

### Non-interactive install

For CI or scripted machines, skip the TUI and pass the component list by name:

```bash
DOTFILES_NONINTERACTIVE=1 \
DOTFILES_COMPONENTS="Neovim config,tmux + TPM,Zsh + Oh My Zsh,Git global config" \
GIT_NAME="Your Name" GIT_EMAIL="you@example.com" ./install.sh
```

Labels match the TUI checklist exactly. Nothing prompts, the login shell is not changed, and the GitHub login step is skipped.

### Commit signing

Commits and tags are signed with the GitHub SSH key (`gpg.format = ssh` in `git/config`); the installer writes `~/.config/git/allowed_signers` so `git log --show-signature` verifies locally. For the Verified badge, add the same public key on GitHub as a **signing** key: `gh ssh-key add ~/.ssh/id_ed25519_github.pub --type signing`.

The installer generates the key without a passphrase. To protect it, regenerate with one; the host block already loads it into the agent and keychain:

```bash
ssh-keygen -t ed25519 -C "you@example.com" -f ~/.ssh/id_ed25519_github   # choose a passphrase
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_github
gh ssh-key add ~/.ssh/id_ed25519_github.pub --type authentication --title "$(hostname)"
gh ssh-key add ~/.ssh/id_ed25519_github.pub --type signing --title "$(hostname) signing"
dot install   # Git global config component: rewrites allowed_signers for the new key
```

Then delete the old key at github.com/settings/keys.

### Machine-specific config

Anything machine- or work-specific (per-machine PATHs, tool installers, private aliases) goes in **`~/.zshrc.local`** (untracked), sourced at the end of `.zshrc`. Install seeds it from `zsh/.zshrc.local.example` if absent, so the tracked zsh config stays clean and portable.

### Tests

```bash
./tests/run.sh   # dependency-free; runs in a sandbox, installs nothing
```

Covers script linting (shellcheck at warning level), the `lib/` helpers, `bin/dot` dispatch, the installer's symlink/selection/component logic, stylua formatting of `nvim/`, `zsh -n` on the zsh files, booting `tmux.conf` on an isolated server, and drift guards that fail when a keymap, alias or tmux binding is missing from its `docs/` file. CI (GitHub Actions) runs it on Ubuntu on every push, and an install job on both macOS and Ubuntu runs `install.sh` non-interactively for the config components, checks the links with `dot doctor --links`, restores the Neovim plugins with parsers compiled, and confirms TPM installed its plugins.

### Uninstallation

```bash
dot uninstall   # removes symlinks, restores backups, drops the git include and component record
```

## Directory Structure

```
├── bin/dot             # the dot command (symlinked to ~/.local/bin/dot)
├── install.sh          # shim: ./install.sh -> dot install
├── cmd/
│   ├── install.sh      # TUI installer
│   ├── update.sh       # dot update
│   ├── doctor.sh       # dot doctor
│   ├── uninstall.sh    # dot uninstall
│   ├── keys.sh         # dot keys
│   └── edit.sh         # dot edit
├── lib/
│   ├── log.sh          # logging helpers
│   ├── env.sh          # repo-root resolver, brew/rustup PATH loading
│   ├── components.sh   # ~/.config/dotfiles/components read/write, is_selected
│   ├── tui.sh          # gum-backed TUI helpers (with plain fallback)
│   └── tmux.sh         # tpm_run (TPM scripts on a throwaway server), tmux_thumbs_build
├── docs/
│   ├── nvim.md         # Neovim plugins and keys
│   ├── tmux.md         # tmux keys (shown by prefix + ?)
│   ├── zsh.md          # aliases and functions
│   └── superfile.md    # superfile hotkeys
├── ghostty/config
├── tmux/tmux.conf
├── zsh/
│   ├── .zshrc          # thin: instant prompt, tmux autostart, Oh My Zsh, then sources *.zsh
│   ├── 10-options.zsh  # history, navigation, vi mode, completion, env
│   ├── 20-path.zsh     # brew, rustup, ~/.local/bin, go
│   ├── 30-tools.zsh    # highlight colors, Ghostty integration, zoxide, fzf, delta
│   ├── 40-aliases.zsh
│   ├── 50-functions.zsh
│   ├── .p10k.zsh
│   └── .zshrc.local.example
├── nvim/
│   ├── init.lua        # options, autocmds, keymaps, lazy.nvim bootstrap
│   ├── lua/plugins/    # one spec per file (snacks.lua, lsp.lua, ...)
│   ├── lazy-lock.json
│   └── .stylua.toml
├── superfile/          # config.toml, hotkeys.toml, theme/vesper.toml
├── git/                # config (included from ~/.gitconfig), ignore (global)
├── karabiner/          # karabiner.json (directory linked to ~/.config/karabiner)
├── tests/run.sh        # dependency-free test suite
├── .github/workflows/test.yml
├── Brewfile            # declarative package list (brew bundle)
└── CLAUDE.md           # conventions for Claude Code sessions in this repo
```

## Troubleshooting

**Symlinks not working** - Run `dot doctor`, then `dot install` to repair.

**`dot: command not found`** - `~/.local/bin` is added to PATH by `zsh/20-path.zsh`; open a new shell, or run `./bin/dot` from the repo.

**tmux colors wrong** - Ensure terminal reports 256-color. Config sets `default-terminal` to `tmux-256color`.

**tmux plugins not loaded** - Run `dot update` (or `dot install` with the tmux component) to install them headlessly, or press `prefix + I` inside tmux. `dot doctor` lists any missing plugin directories.

**`prefix + t` (tmux-thumbs) shows an installer prompt** - The Rust binary is missing. `dot update` builds it with cargo (`rustup` is in the Brewfile); `dot doctor` reports the missing binary.

**`prefix + ?` shows "dot is not installed"** - The popup runs `~/.local/bin/dot`; run `dot install` (any component) to create the link.

**Karabiner rule does nothing** - Open Karabiner-Elements once and grant Input Monitoring plus the driver extension in System Settings. The rule is in the "Default" profile, which the tracked config selects.

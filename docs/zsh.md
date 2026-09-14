# Zsh Reference

Configuration: `zsh/.zshrc` (linked to `~/.zshrc`) plus the modules in
`zsh/*.zsh`. Show this file with `dot keys zsh`.

## Shell basics

- Oh My Zsh with the `git`, `docker`, `zsh-autosuggestions` and
  `zsh-syntax-highlighting` plugins; Powerlevel10k prompt (`p10k configure`
  or `p10kconfig` to change it).
- Line editor starts in vi mode. `Esc` enters normal mode; the cursor is a
  beam in insert mode and a block in normal mode. `vim-mode` toggles between
  the vi and emacs keymaps for the current shell.
- Typing a directory name changes into it (`AUTO_CD`); `cd -` and the
  directory stack (`dirs`, `pushd`, `popd`) work without duplicates.
- History is shared between shells, timestamped, 50000 lines; commands that
  start with a space are not saved.
- Completion is case-insensitive, fuzzy (up to two typos), menu-driven and
  grouped by type.

## fzf keys

| Key | Action |
|-----|--------|
| `Ctrl+R` | Search command history |
| `Ctrl+T` | Insert a file path (uses `fd`, includes hidden files) |
| `Alt+C` | cd into a directory (in Ghostty, Option acts as Alt) |

## Aliases

### Dotfiles and config

| Alias | Runs |
|-------|------|
| `dotup` | `dot update` (pull, brew bundle, plugins, Claude) |
| `dotdoctor` | `dot doctor` (health check) |
| `zshconfig` | `dot edit zsh/` (pick a zsh file to edit) |
| `nvimconfig` | `dot edit nvim/` |
| `tmuxconfig` | `dot edit tmux/` |
| `p10kconfig` | `nvim ~/.p10k.zsh` |
| `src` | `source ~/.zshrc` |

### Editors and AI tools

| Alias | Runs |
|-------|------|
| `v`, `vi`, `vim` | `nvim` |
| `cld` | `claude` |
| `ccd` | `claude --dangerously-skip-permissions` |
| `opc` | `opencode` |

### tmux

| Alias | Runs |
|-------|------|
| `tm` | Attach to tmux, or create a session |
| `tls` | List sessions |
| `tks` | Kill a session (`tks <name>`) |

### Navigation

| Alias | Runs |
|-------|------|
| `..`, `...`, `....` | Up one, two, three directories |
| `-` | `cd -` (previous directory) |

### Modern replacements

| Alias | Runs |
|-------|------|
| `ls` | `eza` |
| `ll` | `eza -lah --git --icons=always` |
| `la` | `eza -a` |
| `lt` | `eza --tree --level=2` |
| `l` | `ls -CF` (only when eza is absent) |
| `cat` | `bat --paging=never` |
| `catp` | `bat` with paging |
| `rm` | Function: sends files to the trash (`trash`). `-r`, `-f`, `-d` are dropped; `rm -i` runs the real `rm` |

### Docker

| Alias | Runs |
|-------|------|
| `dps`, `dpsa` | `docker ps`, `docker ps -a` |
| `dimg` | `docker images` |
| `dex` | `docker exec -it` |
| `dlog` | `docker logs -f` |
| `dprune` | `docker system prune -af` |
| `docker-desktop` | Open Docker Desktop (macOS) |

### Network and misc

| Alias | Runs |
|-------|------|
| `myip` | Public IP (`ifconfig.me`) |
| `localip` | LAN IP |
| `cls` | `clear` |
| `h` | `history` |
| `py` | `python3` (use `uv` for interpreters, venvs and tools) |
| `empty-trash` | Empty the macOS Trash |

### Git (Oh My Zsh git plugin)

Common ones: `gst` status, `ga` / `gaa` add, `gc` / `gcmsg` commit, `gp` push,
`gl` pull, `glog` graph log, `gd` diff, `gco` checkout, `gb` branch.
`alias | grep "^g"` lists all of them. Repo-tracked git aliases (`git undo`,
`git wowow`, `git branches`, `git nuke`) live in `git/config`.

## Functions

fzf helpers (need `fzf`):

| Function | Description |
|----------|-------------|
| `fbr` | Interactive git branch checkout |
| `flog` | Interactive git log browser with commit preview |
| `fkill` | Pick a process and kill it (TERM, then KILL if it survives) |
| `fe` | Find a file (`fd`, or `find`) and open it in `$EDITOR`; optional start directory |
| `frg` | Grep file contents with ripgrep and open the match in `$EDITOR` |
| `fdock` | Pick a docker container, then logs / exec / stop / remove / inspect it |

Utilities:

| Function | Description |
|----------|-------------|
| `mkcd` | Create a directory and cd into it |
| `spf` | superfile with cd-on-quit (the shell follows the last directory opened); see `docs/superfile.md` |
| `backup` | Copy a file to `<file>.backup-<timestamp>` |
| `f` | Find files by name substring under the current directory |
| `port` | Show what is listening on a port |
| `killport` | Kill whatever listens on a port (TERM, then KILL if it survives) |
| `serve` | Serve the current directory over HTTP (default port 8000) |
| `extract` | Extract any archive by extension (tar, zip, 7z, rar, xz, zst, ...) |
| `proj` | Create a directory, cd into it, and `git init` |
| `note` | Open `~/notes/<name>.md` in `$EDITOR`, or list notes with no argument |
| `weather` | Weather report from wttr.in (optional location) |
| `cheat` | cheat.sh lookup for a command or topic |
| `vim-mode` | Toggle the line editor between vi and emacs keymaps |

## Profiling

| Function | Description |
|----------|-------------|
| `zsh_profile` | Start an interactive zsh with zprof enabled and print the startup report |
| `timezsh` | Time ten interactive shell startups (optional shell argument) |

## Machine-local config

Anything machine- or work-specific (extra PATH entries, tool installers,
private aliases, credentials) goes in `~/.zshrc.local`, which is untracked and
sourced last. The installer seeds it from `zsh/.zshrc.local.example`.

## File layout

| File | Contents |
|------|----------|
| `zsh/.zshrc` | p10k instant prompt, tmux auto-attach in Ghostty, Oh My Zsh, then sources the modules below in order, then p10k and `~/.zshrc.local` |
| `zsh/10-options.zsh` | History, directory navigation, vi mode and cursor shape, completion styles, `LANG`, `EDITOR`, colored man pages |
| `zsh/20-path.zsh` | Homebrew (macOS and Linuxbrew), openjdk, `~/.local/bin`, Go, Rust (`~/.cargo/bin`, keg-only rustup) |
| `zsh/30-tools.zsh` | Syntax-highlighting colors, Ghostty shell integration, zoxide, delta pager, fzf options and key bindings |
| `zsh/40-aliases.zsh` | Every alias above and the `rm` trash wrapper |
| `zsh/50-functions.zsh` | Every function above, each with a `# desc:` line |
| `zsh/.p10k.zsh` | Powerlevel10k prompt (generated by `p10k configure`) |
| `zsh/.zshrc.local.example` | Template for `~/.zshrc.local` |

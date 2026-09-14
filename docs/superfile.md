# superfile Reference

superfile is the TUI file manager, started with `spf`. Show this file with
`dot keys superfile`.

## What is configured

- `spf` is a shell function (`zsh/50-functions.zsh`) that runs superfile and
  then changes the shell into the last directory you were in (cd-on-quit).
  Quit with `q` to keep the shell where it was, or `Q` to cd there.
- File previews use `bat`; images preview inline; hidden files are shown with
  `.`.
- `z` opens a zoxide jump prompt (same database as the shell's `z`).
- Vesper theme (`superfile/theme/vesper.toml`), transparent background, Nerd
  Font icons, rounded borders.
- Auto-update check is off; Homebrew updates superfile (`dot update`).

Config files:

| File | Linked to |
|------|-----------|
| `superfile/config.toml` | `~/Library/Application Support/superfile/config.toml` (macOS), `~/.config/superfile/config.toml` (Linux) |
| `superfile/hotkeys.toml` | same directory, `hotkeys.toml` |
| `superfile/theme/vesper.toml` | same directory, `theme/vesper.toml` |

## Hotkeys

A vim-style hybrid: `y` / `x` / `p` / `d` for file operations, `a` / `r` to
create and rename, `h` / `j` / `k` / `l` to move. The upstream ctrl combos are
kept as alternates.

### Basics

| Key | Action |
|-----|--------|
| `Enter`, `l`, `Right` | Open file or enter directory |
| `h`, `Left`, `Backspace` | Parent directory |
| `q`, `Esc` | Quit (shell stays where it was) |
| `Q` | Quit and cd into the current directory |
| `?` | Help menu |
| `:` | Command line |
| `>` | superfile prompt |

### Navigation

| Key | Action |
|-----|--------|
| `j` / `k`, `Down` / `Up` | Move down / up |
| `PgDown` / `PgUp` | Page down / up |
| `/` | Search in the current panel |
| `z` | zoxide jump |
| `.` | Toggle hidden files |
| `o` | Sort options |
| `R` | Reverse sort order |

### Panels and focus

| Key | Action |
|-----|--------|
| `n` | New file panel |
| `N` | Split file panel |
| `w` | Close file panel |
| `Tab` / `L` | Next panel |
| `Shift+Left` / `H` | Previous panel |
| `f` | Toggle preview panel |
| `F` | Toggle footer |
| `s` | Focus sidebar |
| `m` | Focus metadata |
| `Ctrl+p` | Focus process bar |
| `P` | Pinned directories |

### File operations

| Key | Action |
|-----|--------|
| `a` (`Ctrl+n`) | Create file or directory (end the name with `/` for a directory) |
| `r` (`Ctrl+r`) | Rename |
| `y` (`Ctrl+c`) | Copy |
| `x` (`Ctrl+x`) | Cut |
| `p` (`Ctrl+v`) | Paste |
| `d`, `Delete` | Delete (to trash) |
| `D` | Delete permanently |
| `Ctrl+a` | Compress |
| `Ctrl+e` | Extract |
| `Y` | Copy path to clipboard |
| `c` | Copy current directory path |

### Editor

| Key | Action |
|-----|--------|
| `e` | Open file in `$EDITOR` (nvim) |
| `E` | Open current directory in the editor |

### Selection mode

| Key | Action |
|-----|--------|
| `v` | Toggle selection mode |
| `J` / `K`, `Shift+Down` / `Shift+Up` | Extend selection down / up |
| `A` | Select all |

### Typing (inputs)

| Key | Action |
|-----|--------|
| `Enter` | Confirm |
| `Esc`, `Ctrl+c` | Cancel |

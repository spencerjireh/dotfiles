# tmux Keybindings

Configuration: `tmux/tmux.conf` (linked to `~/.tmux.conf`). `prefix + ?` shows a
cheat sheet built from the tables in this file (`dot keys tmux --sheet`);
`dot keys tmux` shows the whole file.

## Prefix

The prefix is `C-Space`. In Ghostty, `Cmd+Shift+Space` is translated to
`C-Space` (`ghostty/config`), so either works. `prefix + C-Space` sends a
literal `C-Space` to the pane.

## Mental model

Two layers, same verbs. `prefix` (tmux) owns sessions, windows and panes.
`Space` (Neovim, see `docs/nvim.md`) owns files, buffers and code. Ghostty only
translates Cmd keys into tmux sequences. Inside each layer the same key means
the same thing:

| Verb | tmux (`prefix +`) | Neovim (`Space`) |
|------|-------------------|------------------|
| Move in a direction | `C-h/j/k/l` without prefix (panes) | `h` / `j` / `k` / `l` (splits, crosses into tmux); `Ctrl+h/j/k/l` |
| Previous / next in the list | `k` / `j` (windows; also `p` / `n`); `Cmd+Shift+K` / `Cmd+Shift+J` (or `Cmd+Shift+A` / `Cmd+Shift+D`) | `Shift+h` / `Shift+l` (buffers) |
| Reorder | `h` / `l` move the window left / right; `Cmd+Shift+H` / `Cmd+Shift+L` | |
| Split | `\|` / `-` | `\|` / `-`, `=` equalize |
| Close the smallest thing / more | `q` pane, `X` window, `Q` session | `q` window (quits on the last), `Q` all, `bd` buffer |
| Find in a list | `f` windows, `F` sessions, `o` projects | `f` + letter (files, buffers, grep, ...); `fp` projects |
| Jump to slot N | `Cmd+N` / `Alt+N` (window N) | `Space N` (Harpoon mark N) |
| New | `c` window, `S` session | |
| Scratch | `g` popup terminal | `.` scratch buffer |
| Help | `?` | `?` |

With the prefix, `h/j/k/l` act on windows (h/l reorder, j/k switch). Without
it, `C-h/j/k/l` move between panes.

## Panes

| Action | Keys |
|--------|------|
| Split side by side / stacked | `prefix + \|` / `prefix + -` |
| Move to a pane | `C-h` / `C-j` / `C-k` / `C-l` (no prefix) |
| Resize | `prefix + H` / `prefix + J` / `prefix + K` / `prefix + L` (repeatable) |
| Close pane | `prefix + q` |

Split side by side with `prefix + |`, stacked with `prefix + -`; splits open in
the current pane's directory. Pane moves cross into Neovim splits
(vim-tmux-navigator). `H` / `J` / `K` / `L` resize left / down / up / right by 5 cells. Neovim uses the same `|`, `-`
and `q` under `Space`.

## Windows

| Action | Keys |
|--------|------|
| New window | `prefix + c` |
| Next / previous window | `prefix + j` / `prefix + k` (also `prefix + n` / `prefix + p`) |
| Move window left / right | `prefix + h` / `prefix + l` |
| Jump to window N | `M-1` to `M-9` (no prefix) |
| Find a window in any session | `prefix + f` (fzf) |
| Close window | `prefix + X` |
| Toggle status bar | `prefix + b` |

New windows open after the current one, in its directory. `j`, `k`, `h` and
`l` are repeatable. Windows are numbered from 1 and renumbered when one
closes. The status bar is off by default; when on, it shows only the window
tabs: a window shows as its directory name, plus the running command in
brackets when it is not the shell.

## Sessions

| Action | Keys |
|--------|------|
| New session | `prefix + S` (prompts for a name) |
| Open a project as a session | `prefix + o` (fzf over `~/Projects`; creates or switches) |
| Switch session | `prefix + F` (fzf; `C-x` kills the highlighted one) |
| Kill session | `prefix + Q` (asks first) |
| Detach | `prefix + d` |
| Save / restore layout | `prefix + C-s` / `prefix + C-r` |

Opening Ghostty attaches to the running tmux server, or starts one with a
timestamped session (for example `sep14-0930`) if none is running.
`prefix + o` lists the directories under `~/Projects` (or
`DOTFILES_PROJECT_DIRS` from `~/.zshrc.local`) and opens the pick as a session
named after the directory; the shell function `fproj` does the same. Sessions
are saved by tmux-resurrect on detach and on every window or pane change, and
the last save is restored automatically when the tmux server starts.
tmux-continuum is not used because its timer lives in the status line, which
is off.

## Copy mode (vi keys)

| Action | Keys |
|--------|------|
| Enter copy mode | `prefix + Enter` |
| Select / select line / block | `v` / `V` / `C-v` |
| Yank to clipboard | `y` |
| Word motions | `w` / `b` / `e` |
| Start / end of line | `0` / `$` (also `H` / `L`) |
| Top / bottom of history | `g` / `G` |
| Swap selection end | `o` |
| Exit copy mode | `Escape` |

Yank uses pbcopy on macOS and xclip on Linux. Mouse selection also copies
(`set-clipboard on`).

## Popups

| Action | Keys |
|--------|------|
| Scratch terminal (current directory) | `prefix + g` |
| Copy hints for paths, URLs, hashes | `prefix + t` (tmux-thumbs) |
| Install TPM plugins | `prefix + I` |

`dot update` installs TPM plugins headlessly.

## Other

| Action | Keys |
|--------|------|
| Copy last command output | `prefix + y` |
| Reload config | `prefix + r` |
| Clear screen | `prefix + C-l` |
| This reference | `prefix + ?` |

`prefix + y` copies the text between the last two prompt marks to the
clipboard. Plain `C-l` is pane navigation, so clear needs the prefix.

## Ghostty

Ghostty sends these Cmd keys to tmux as the matching prefix key (or `M-N`), so
window management stays in tmux:

| Action | Ghostty key |
|--------|-------------|
| Prefix | `Cmd+Shift+Space` |
| Move window left / right | `Cmd+Shift+H` / `Cmd+Shift+L` |
| Next / previous window | `Cmd+Shift+J` / `Cmd+Shift+K` |
| Jump to window N | `Cmd+1` to `Cmd+9` |

`Cmd+Shift+D` / `Cmd+Shift+A` are left-hand aliases for next / previous window.
Ghostty's own split key `Cmd+D` is unbound so it cannot open a split outside
tmux. If a Ghostty split does appear, `Cmd+W` closes the focused one.

On Linux, Ghostty's `cmd` is the Super key and GNOME reserves Super+Shift+Space
and Super+1-9, so use `C-Space` (the real prefix) and `Alt+1-9` there.

## Plugins (TPM)

- `tmux-resurrect`: save / restore sessions, including pane contents.
- `tmux-thumbs`: `prefix + t` copy hints. Its Rust binary is built by the
  installer and by `dot update`; `dot doctor` reports it when missing.

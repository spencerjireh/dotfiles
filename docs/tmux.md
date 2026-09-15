# tmux Keybindings

Configuration: `tmux/tmux.conf` (linked to `~/.tmux.conf`). Show this file
inside tmux with `prefix + ?`, or in the shell with `dot keys tmux`.

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

## Ghostty translations

Ghostty maps a few Cmd keys to tmux sequences so window management stays in tmux:

| Ghostty key | Sent to tmux | Effect |
|-------------|--------------|--------|
| `Cmd+Shift+Space` | `C-Space` | Prefix |
| `Cmd+Shift+H` | `prefix + h` | Move window left |
| `Cmd+Shift+L` | `prefix + l` | Move window right |
| `Cmd+Shift+J` | `prefix + j` | Next window |
| `Cmd+Shift+K` | `prefix + k` | Previous window |
| `Cmd+Shift+D` | `prefix + j` | Next window (left-hand alias) |
| `Cmd+Shift+A` | `prefix + k` | Previous window (left-hand alias) |
| `Cmd+1` to `Cmd+9` | `M-1` to `M-9` | Jump to window |

Ghostty's own split key `Cmd+D` is unbound so it cannot open a split outside
tmux. If a Ghostty split does appear, `Cmd+W` closes the focused one.

On Linux, Ghostty's `cmd` is the Super key and GNOME reserves Super+Shift+Space
and Super+1-9, so use `C-Space` (the real prefix) and `Alt+1-9` there.

## Navigation

| Action | Keys |
|--------|------|
| Pane left / down / up / right | `C-h` / `C-j` / `C-k` / `C-l` (no prefix; forwarded into Neovim by vim-tmux-navigator) |
| Next / previous window | `prefix + j` / `prefix + k` (repeatable; also `prefix + n` / `prefix + p`; `Cmd+Shift+J` / `Cmd+Shift+K` in Ghostty) |
| Move window left / right | `prefix + h` / `prefix + l` (repeatable; `Cmd+Shift+H` / `Cmd+Shift+L` in Ghostty) |
| Window by number | `M-1` to `M-9` (Alt+number, or Cmd+number in Ghostty) |
| Window switcher, all sessions | `prefix + f` (fzf) |

## Copy mode (vi keys)

| Action | Keys |
|--------|------|
| Enter copy mode | `prefix + Enter` |
| Start selection | `v` |
| Select line | `V` |
| Block selection | `C-v` |
| Yank to system clipboard | `y` (pbcopy on macOS, xclip on Linux) |
| Word motions | `w` / `b` / `e` |
| Start / end of line | `0` / `$`, also `H` / `L` |
| Top / bottom of history | `g` / `G` |
| Swap selection end | `o` |
| Exit copy mode | `Escape` |

Mouse selection also copies (`set-clipboard on`).

## Panes

| Action | Keys |
|--------|------|
| Split stacked (horizontal) | `prefix + -` |
| Move to a pane | `C-h` / `C-j` / `C-k` / `C-l` (no prefix) |
| Resize left / down / up / right | `prefix + H` / `prefix + J` / `prefix + K` / `prefix + L` (5 cells, repeatable) |
| Close pane | `prefix + q` |

Split side by side with `prefix + |`. Splits open in the current pane's
directory. Neovim uses the same `|`, `-` and `q` under `Space`.

## Windows

| Action | Keys |
|--------|------|
| New window (after the current one, same directory) | `prefix + c` |
| Next / previous window | `prefix + j` / `prefix + k` (also `prefix + n` / `prefix + p`) |
| Move window left / right | `prefix + h` / `prefix + l` |
| Find a window in any session | `prefix + f` (fzf) |
| Close window | `prefix + X` |
| Toggle status bar | `prefix + b` (off by default; shows the window tabs only) |

Windows are numbered from 1 and renumbered when one closes. With the status
bar on, a window shows as its directory name, plus the running command in
brackets when it is not the shell.

## Sessions

| Action | Keys |
|--------|------|
| New session | `prefix + S` (prompts for a name) |
| Open a project as a session | `prefix + o` (fzf over `~/Projects`; creates or switches) |
| Session switcher | `prefix + F` (fzf; shows the current session, `C-x` kills the highlighted one) |
| Kill session | `prefix + Q` (asks for confirmation) |
| Detach | `prefix + d` |
| Save / restore layout | `prefix + C-s` / `prefix + C-r` (tmux-resurrect) |

Opening Ghostty attaches to the running tmux server, or starts one with a
timestamped session (for example `sep14-0930`) if none is running.
`prefix + o` lists the directories under `~/Projects` (or
`DOTFILES_PROJECT_DIRS` from `~/.zshrc.local`) and opens the pick as a session
named after the directory; the shell function `fproj` does the same. Sessions
are saved by tmux-resurrect on detach and on every window or pane change, and
the last save is restored automatically when the tmux server starts.
tmux-continuum is not used because its timer lives in the status line, which
is off.

## Popups and search

| Action | Keys |
|--------|------|
| Scratch terminal popup (current directory) | `prefix + g` |
| Copy hints for paths, URLs, hashes (tmux-thumbs) | `prefix + t` |
| Window switcher across sessions | `prefix + f` |
| Session switcher | `prefix + F` |
| Install TPM plugins | `prefix + I` (`dot update` does this headlessly) |

## Other

| Action | Keys |
|--------|------|
| Copy last command output to clipboard | `prefix + y` (text between the last two `❯` prompt marks) |
| Reload config | `prefix + r` |
| Clear screen | `prefix + C-l` (plain `C-l` is pane navigation) |
| Toggle status bar | `prefix + b` |
| This reference | `prefix + ?` |

## Plugins (TPM)

- `tmux-resurrect`: save / restore sessions, including pane contents.
- `tmux-thumbs`: `prefix + t` copy hints. Its Rust binary is built by the
  installer and by `dot update`; `dot doctor` reports it when missing.

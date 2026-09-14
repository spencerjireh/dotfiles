# tmux Keybindings

Configuration: `tmux/tmux.conf` (linked to `~/.tmux.conf`). Show this file
inside tmux with `prefix + ?`, or in the shell with `dot keys tmux`.

## Prefix

The prefix is `C-Space`. In Ghostty, `Cmd+Shift+Space` is translated to
`C-Space` (`ghostty/config`), so either works. `prefix + C-Space` sends a
literal `C-Space` to the pane.

## Ghostty translations

Ghostty maps a few Cmd keys to tmux sequences so window management stays in tmux:

| Ghostty key | Sent to tmux | Effect |
|-------------|--------------|--------|
| `Cmd+Shift+Space` | `C-Space` | Prefix |
| `Cmd+Shift+A` | `prefix + h` | Previous window |
| `Cmd+Shift+D` | `prefix + l` | Next window |
| `Cmd+1` to `Cmd+9` | `M-1` to `M-9` | Jump to window |

## Navigation

| Action | Keys |
|--------|------|
| Pane left / down / up / right | `C-h` / `C-j` / `C-k` / `C-l` (no prefix; forwarded into Neovim by vim-tmux-navigator) |
| Previous / next window | `prefix + h` / `prefix + l` (repeatable) |
| Move window left / right | `prefix + k` / `prefix + j` (repeatable) |
| Window by number | `M-1` to `M-9` (Alt+number, or Cmd+number in Ghostty) |
| Window switcher, all sessions | `prefix + p` (fzf) |

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
| Split side by side (vertical) | `prefix + v` |
| Split stacked (horizontal) | `prefix + s` |
| Resize left / down / up / right | `prefix + H` / `prefix + J` / `prefix + K` / `prefix + L` (5 cells, repeatable) |
| Close pane | `prefix + x` |

Alternate split keys: `prefix + |` (side by side) and `prefix + -` (stacked).
Splits open in the current pane's directory.

## Windows

| Action | Keys |
|--------|------|
| New window (after the current one, same directory) | `prefix + c` |
| Previous / next window | `prefix + h` / `prefix + l` |
| Reorder window | `prefix + j` / `prefix + k` |
| Close window | `prefix + X` |
| Toggle status bar | `prefix + b` (off by default) |

Windows are numbered from 1 and renumbered when one closes. With the status
bar on, a window shows as its directory name, plus the running command in
brackets when it is not the shell.

## Sessions

| Action | Keys |
|--------|------|
| New session | `prefix + S` (prompts for a name) |
| Session switcher | `prefix + w` (fzf; shows the current session, `C-x` kills the highlighted one) |
| Kill session | `prefix + q` (asks for confirmation) |
| Detach | `prefix + d` |
| Save / restore layout | `prefix + C-s` / `prefix + C-r` (tmux-resurrect) |

Opening Ghostty attaches to the running tmux server, or starts one with a
timestamped session (for example `sep14-0930`) if none is running. Sessions
are saved by tmux-resurrect on detach and on every window or pane change, and
the last save is restored automatically when the tmux server starts.
tmux-continuum is not used because its timer lives in the status line, which
is off.

## Popups and search

| Action | Keys |
|--------|------|
| Scratch terminal popup (current directory) | `prefix + g` |
| Copy hints for paths, URLs, hashes (tmux-thumbs) | `prefix + t` |
| Window switcher across sessions | `prefix + p` |
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

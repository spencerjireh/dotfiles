# Dotfiles

Personal terminal setup for macOS and Linux (including WSL): Ghostty, tmux, zsh, Neovim and
superfile, all in the Vesper colour scheme. One installer links everything into `$HOME`.

## Install

```bash
git clone https://github.com/spencerjireh/dotfiles.git ~/dotfiles
```

```bash
~/dotfiles/install.sh
```

You tick the components you want, answer a few questions (git name and email), confirm, and the
rest runs unattended. Existing files are backed up before they are replaced. Only `git` and
`curl` are needed to start; the installer brings Homebrew and its own prompt tool.

After the first run, `dot` is on your PATH. Running `dot install` again is safe.

## Variants

| Profile | For | What you get |
|---------|-----|--------------|
| `default` | Personal machines | Everything below |
| `work` | A locked-down machine: WSL with Homebrew already installed | Brew formulae and git clones only. No apps, no admin rights, no Claude, no personal GitHub key |

```bash
~/dotfiles/install.sh --profile work
```

On WSL, clone inside the Linux home, not under `/mnt/c`. What `work` changes and how to add a
variant: [docs/install.md](docs/install.md).

## Components

| Component | What it sets up |
|-----------|-----------------|
| Homebrew CLI packages | The tools in `Brewfile` (`Brewfile.work` for the work profile) |
| Ghostty terminal | The app and its config |
| Claude Code | The CLI, through its own installer |
| Nerd Font | GohuFont Nerd Font |
| Neovim config | `nvim/`, plugins through lazy.nvim |
| Superfile file manager | `spf`, with config and theme |
| tmux + TPM | `tmux.conf` and plugins |
| Zsh + Oh My Zsh | zsh config, Powerlevel10k, plugins |
| GitHub SSH + CLI | An SSH key, a host block, `gh` |
| Git global config | Name and email; the rest is tracked in `git/config` |
| Karabiner (Caps Lock as Esc/Ctrl) | Escape when tapped, Control when held (macOS) |
| macOS defaults | Key repeat, Finder, Dock, trackpad, screenshots (macOS) |

## The `dot` command

```bash
dot install      # run the installer again
dot update       # pull, upgrade packages and plugins
dot doctor       # check that everything this machine selected is in place
dot keys         # key and alias reference: dot keys nvim | tmux | zsh | superfile
dot edit         # pick a tracked file and open it in $EDITOR
dot uninstall    # remove the links and restore the backups
dot dir          # print where the repo lives
```

## Reference

| Topic | File | Inside the tool |
|-------|------|-----------------|
| Install, profiles, settings | [docs/install.md](docs/install.md) | `dot install --help` |
| Neovim | [docs/nvim.md](docs/nvim.md) | `<Space>?`, `<Space>fk` |
| tmux | [docs/tmux.md](docs/tmux.md) | `prefix + ?` |
| Zsh | [docs/zsh.md](docs/zsh.md) | `dot keys zsh` |
| Superfile | [docs/superfile.md](docs/superfile.md) | `?` inside `spf` |

## When something is off

Run `dot doctor` first; it names what is missing, and `dot install` repairs links. Three things
it cannot see:

- **`dot: command not found`**: open a new shell, or run `./bin/dot` from the repo.
- **Karabiner does nothing**: open Karabiner-Elements once and grant Input Monitoring and the
  driver extension in System Settings.
- **Colours look wrong**: the terminal must support true colour.

## Working on this repo

`./tests/run.sh` runs the test suite in a sandbox and installs nothing. Conventions, layout and
how to add a key, alias, package or setting are in [AGENTS.md](AGENTS.md), written for both
people and coding agents.

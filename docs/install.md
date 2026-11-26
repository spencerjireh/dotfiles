# Install Reference

Details behind `dot install`. The short version is in the [README](../README.md).

## What the installer does

1. Bootstraps Homebrew and `gum` (the prompt tool) if they are missing. Homebrew may ask for
   your password once. Without `gum` the prompts fall back to plain text.
2. Asks which variant, which components, and for a git name and email; then runs unattended.
3. Links config files into `$HOME`, moving any existing file to a backup first.
4. Records the choices in `~/.config/dotfiles/`: `components`, `profile`, and `settings`.
   `dot doctor` and `dot update` act only on what is recorded. A later run merges new choices.

## Components

| Component | Details |
|-----------|---------|
| Homebrew CLI packages | `brew bundle` on the profile's Brewfile: editors, search tools, runtimes, formatters, linters; `rustup default stable` |
| Ghostty terminal | Cask on macOS; links `ghostty/config` (opens maximized, Cmd keys mapped to tmux) |
| Claude Code | Official native installer, self-updating |
| Nerd Font | Cask on macOS, downloaded on Linux |
| Neovim config | Links `nvim/` to `~/.config/nvim` |
| Superfile file manager | Brew formula; links config, hotkeys and theme |
| tmux + TPM | Links `tmux.conf`; installs TPM and plugins without a running tmux |
| Zsh + Oh My Zsh | Links `.zshrc` and `.p10k.zsh`; installs Oh My Zsh, Powerlevel10k, autosuggestions, syntax highlighting; offers to make zsh the login shell |
| GitHub SSH + CLI | ed25519 key, `~/.ssh/config` host block, `gh` |
| Git global config | Name and email in `~/.gitconfig`, which includes the tracked `git/config`; `git/ignore` is the global ignore |
| Karabiner (Caps Lock as Esc/Ctrl) | Karabiner-Elements and `karabiner/` (macOS) |
| macOS defaults | Key repeat, Finder, Dock, trackpad, screenshots (macOS) |

## Profiles

A profile is a file, `profiles/<name>.conf`. It decides which components are offered and ticked,
which Brewfile is bundled, and whether the installer may use `sudo`.

```bash
dot install --list-profiles
dot install --profile work      # or DOTFILES_PROFILE=work
```

Without `--profile` the installer reuses the recorded profile, or asks on the first run.

What `work` changes, compared with `default`:

| Area | In `work` |
|------|-----------|
| Components | Brew packages, Neovim, tmux, Zsh and Git config are ticked; Superfile is optional; Ghostty, Claude Code, Nerd Font, GitHub SSH + CLI, Karabiner and macOS defaults are not offered |
| Packages | `Brewfile.work`: core CLI tools plus Python and JS/TS tooling. No Go, Java, Rust, C tooling or imagemagick |
| Homebrew | Must already be installed; the installer stops instead of bootstrapping it |
| `sudo` | Only after an explicit yes, never in a scripted run |
| Login shell | No `chsh`. A marked block in `~/.bashrc` starts zsh in interactive terminals; `DOTFILES_NO_ZSH=1 bash` gives a plain bash |
| Neovim | No Mason, no debug adapters, no Claude plugin. Language servers come from brew or `PATH` |
| tmux | tmux-thumbs is not built and its key is unbound. Under WSL, copy goes through the terminal to the Windows clipboard |
| Plugin binaries | None are downloaded: the prompt uses `vcs_info` instead of `gitstatusd` (slower in very large repos), completion uses a Lua matcher |
| Git | Commit signing is off. Use the work name and email when asked |
| Icons | The installer shows three icons and asks whether they render; if not, plain characters are used |
| Updates | `dot update` restores Neovim plugins to `lazy-lock.json` instead of syncing, so the clone stays clean |

**Adding a variant**: copy `profiles/work.conf` to `profiles/<name>.conf` and edit it. The keys
and their defaults are in `profile_defaults` in `lib/profile.sh`. Add a `Brewfile.<name>` if the
package set differs.

## Settings

A profile's switches are written to `~/.config/dotfiles/settings`. zsh sources the file, tmux
and Neovim read it. No file means every default. Edit it by hand to change one machine.

| Setting | Effect | Read by |
|---------|--------|---------|
| `DOTFILES_MASON=0` | No Mason; language servers from `PATH`; no debug adapters | Neovim |
| `DOTFILES_AGENT=kiro` | No Claude plugin or keys (default `claude`) | Neovim |
| `DOTFILES_GLYPHS=0` | Plain characters instead of Nerd Font icons | Neovim, zsh (`ll`) |
| `DOTFILES_PREBUILT=0` | Plugins fetch no prebuilt binaries (`gitstatusd`, blink.cmp matcher) | zsh, Neovim |
| `DOTFILES_TMUX_THUMBS=0` | tmux-thumbs is not built; `prefix + t` is unbound | tmux, installer |

## Scripted install

```bash
DOTFILES_NONINTERACTIVE=1 \
DOTFILES_COMPONENTS="Neovim config,tmux + TPM,Zsh + Oh My Zsh,Git global config" \
GIT_NAME="Your Name" GIT_EMAIL="you@example.com" ./install.sh
```

Component names match the table above exactly. Without `DOTFILES_COMPONENTS` the profile's own
list is used. Nothing prompts, the login shell is not changed, and the GitHub login is skipped.

## Commit signing

On the default profile, commits and tags are signed with the GitHub SSH key (`gpg.format = ssh`
in `git/config`), and the installer writes `~/.config/git/allowed_signers` so
`git log --show-signature` verifies locally. For the Verified badge on GitHub, add the same key
as a signing key:

```bash
gh ssh-key add ~/.ssh/id_ed25519_github.pub --type signing
```

The key is generated without a passphrase. To use one, regenerate it at the same path with
`ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_github`, add it to GitHub as both an authentication
and a signing key, run `dot install` with the Git component to rewrite `allowed_signers`, and
delete the old key on GitHub.

## Machine-local config

Anything specific to one machine (extra PATH entries, private aliases, credentials) goes in
`~/.zshrc.local`, which is untracked and sourced last. The installer seeds it from
`zsh/.zshrc.local.example`.

## Uninstall

`dot uninstall` removes the links, restores the backups, and drops the git include, the
`~/.bashrc` block and the recorded state. Installed packages stay.

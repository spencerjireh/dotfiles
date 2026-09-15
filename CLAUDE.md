# Dotfiles repo: notes for Claude Code

Personal macOS/Linux environment: Ghostty, tmux, zsh (Oh My Zsh + p10k), Neovim (lazy.nvim),
superfile, git, Karabiner. Everything is symlinked from this repo into `$HOME` by the installer.

## Layout

| Path | Role |
|------|------|
| `bin/dot` | Single CLI. `install`, `update`, `doctor`, `uninstall`, `keys`, `edit`, `dir`, `help` |
| `install.sh` | Shim for `dot install` (fresh-machine entry point, used by CI) |
| `cmd/*.sh` | One script per subcommand; each sources `lib/` itself and runs standalone |
| `lib/` | `log.sh` (log_info/warn/error), `env.sh` (repo root resolver, brew + rustup PATH), `components.sh` (`~/.config/dotfiles/components`, `is_selected`), `tui.sh` (gum with plain fallback), `tmux.sh` (TPM headless helpers) |
| `docs/` | Source of truth for keys and aliases: `nvim.md`, `tmux.md`, `zsh.md`, `superfile.md`. Shown by `dot keys` and tmux `prefix + ?` |
| `nvim/init.lua` | Options, autocmds, plain keymaps, lazy bootstrap with `{ import = "plugins" }` |
| `nvim/lua/plugins/*.lua` | One plugin spec (or one tight group) per file |
| `zsh/.zshrc` | Thin; sources `zsh/NN-*.zsh` in order (options, path, tools, aliases, functions) |
| `tests/run.sh` | Sandboxed suite; CI runs it plus a non-interactive install on macOS and Ubuntu |

## Conventions

- Every Neovim keymap has a `desc`; which-key reads it. Groups are defined once in `lua/plugins/which-key.lua`.
- Every zsh function is preceded by a `# desc:` comment.
- tmux (`prefix`) and Neovim (`Space`) share one key model, documented in `docs/tmux.md` "Mental model": `Ctrl+h/j/k/l` is a direction (also `Space h/j/k/l` in Neovim; `prefix h/l` reorder windows, `prefix j/k` switch), `j/k` or Shift+h/l is previous/next, `|`/`-` split, `q` closes and `Q` closes more, `f` finds, `?` helps, numbers jump to slots. New bindings must fit it.
- Docs never drift: `tests/run.sh` fails when a `<leader>` mapping, an alias/function name, or a tmux prefix binding is missing from its `docs/*.md`. Update the doc in the same change.
- Formatting and lint: `stylua nvim/` (config in `nvim/.stylua.toml`), `shellcheck -S warning` on every shell file, `zsh -n` on zsh files. Run `./tests/run.sh` before committing.
- Shell scripts are bash 3.2 compatible (macOS default): no namerefs, no associative arrays.
- Package list lives in `Brewfile`; casks that are toggleable in the installer stay in `cmd/install.sh`.
- Commit messages: conventional prefix (`feat(nvim):`, `fix(doctor):`, `docs:`), no session links.

## Do not

- Reference `~/.dotfiles`; the repo can live anywhere (`dot dir` prints it).
- Duplicate settings between `zsh/` and `git/config` (for example the pager: `core.pager` only).
- Install rust via the `rust` formula; `rustup` (keg-only) is the toolchain and the two conflict.
- Put machine-specific PATHs or secrets in tracked zsh files; they go in `~/.zshrc.local`.

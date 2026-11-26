# Working on this repo

For people and coding agents. Personal macOS/Linux/WSL environment: Ghostty, tmux, zsh
(Oh My Zsh + p10k), Neovim (lazy.nvim), superfile, git, Karabiner. The installer symlinks
everything from this repo into `$HOME`.

## Layout

| Path | Role |
|------|------|
| `bin/dot` | Single CLI: `install`, `update`, `doctor`, `uninstall`, `keys`, `edit`, `dir`, `help` |
| `install.sh` | Shim for `dot install` (fresh-machine entry point, used by CI) |
| `cmd/*.sh` | One script per subcommand; each sources `lib/` itself and runs standalone |
| `lib/` | `log.sh` (log_info/warn/error), `env.sh` (repo root, brew and rustup PATH, `is_wsl`), `components.sh` (component record, `is_selected`), `profile.sh` (profiles, settings file, `run_sudo`, `.bashrc` zsh block), `tui.sh` (gum with plain fallback), `tmux.sh` (TPM without a session) |
| `profiles/*.conf` | Install variants (`default`, `work`): sourced `PROFILE_*` keys, defaults in `profile_defaults` |
| `Brewfile`, `Brewfile.work` | Package lists, one per profile that needs its own |
| `docs/` | Source of truth for keys and aliases (`nvim.md`, `tmux.md`, `zsh.md`, `superfile.md`, shown by `dot keys`) and for the installer (`install.md`) |
| `nvim/init.lua` | Options, autocmds, plain keymaps, lazy bootstrap |
| `nvim/lua/plugins/*.lua` | One plugin spec, or one tight group, per file |
| `nvim/lua/dotfiles/` | `settings.lua` (machine settings), `project.lua` (per-repo formatter and linter gates) |
| `zsh/.zshrc` | Thin; sources `zsh/NN-*.zsh` in order (options, path, tools, aliases, functions) |
| `tmux/`, `ghostty/`, `superfile/`, `git/`, `karabiner/` | One tool's tracked config each |
| `tests/run.sh` | Sandboxed test suite; CI runs it plus real installs on macOS, Ubuntu and WSL |

## Before committing

```bash
./tests/run.sh
```

It runs shellcheck (`-S warning`), `stylua --check nvim/`, `zsh -n`, the unit tests and the doc
guards. Format Lua with `stylua nvim/`. Commit messages use a conventional prefix
(`feat(nvim):`, `fix(doctor):`, `docs:`), with no session links or agent attribution.

## Rules

- Shell scripts are bash 3.2 compatible (macOS default): no namerefs, no associative arrays.
- Docs never drift. The tests fail when a `<leader>` mapping, an alias or function name, a tmux
  prefix binding, an installer component or a profile is missing from its doc, or when a doc
  link points nowhere. Change the doc in the same commit.
- Docs stay short: say a thing once, keys in two-column `| Action | Keys |` tables under `##`
  headings (`dot keys --sheet` reads exactly those), no emojis.
- tmux (`prefix`) and Neovim (`Space`) share one key model, in `docs/tmux.md` "Mental model".
  New bindings must fit it.
- Profiles act at install time only. Tracked configs read `~/.config/dotfiles/settings` or check
  what is installed; they never test the profile name. No settings file means default behaviour.
- Any installer step that needs root goes through `run_sudo` (`lib/profile.sh`).

## Do not

- Reference `~/.dotfiles`; the repo can live anywhere (`dot dir` prints it).
- Duplicate settings between `zsh/` and `git/config` (the pager is `core.pager` only).
- Install Rust through the `rust` formula; `rustup` is the toolchain and the two conflict.
- Put machine-specific PATHs or secrets in tracked files; they go in `~/.zshrc.local`.

## Recipes

**Neovim keymap**: add it in the plugin's file under `nvim/lua/plugins/` (or `init.lua` if it
needs no plugin) with a `desc`. A new prefix group goes in `which-key.lua`. Add a row to the
matching table in `docs/nvim.md`, writing the key as `` `<Space>xy` ``.

**zsh alias or function**: aliases in `zsh/40-aliases.zsh`, functions in `zsh/50-functions.zsh`
with a `# desc:` comment above. Add a row to `docs/zsh.md`.

**tmux binding**: add it to `tmux/tmux.conf`, check it against the key model, and add a row to
`docs/tmux.md` as `` `prefix + KEY` ``.

**Package**: add it to `Brewfile`. If the work profile needs it, add it to `Brewfile.work` too.
A package that exists only in `Brewfile.work` must be listed in `WORK_ONLY` in `tests/run.sh`.
Casks the installer lets you toggle stay in `cmd/install.sh`.

**Setting** (`DOTFILES_*`): put it in `PROFILE_SETTINGS` in the profile that needs it, read it
where it applies (`$DOTFILES_X` in zsh, `require("dotfiles.settings")` in Neovim, the settings
file in tmux), keep the default behaviour when it is unset, and add a row to the table in
`docs/install.md`.

**Installer component**: add the label to `FEATURES` in `cmd/install.sh`, guard its steps with
`is_selected`, add its checks to `cmd/doctor.sh` and its cleanup to `cmd/uninstall.sh`, and add
a row to the component tables in `README.md` and `docs/install.md`.

**Neovim plugin**: create `nvim/lua/plugins/<name>.lua`, run `:Lazy sync`, commit
`nvim/lazy-lock.json`, and add a row to the plugin table in `docs/nvim.md`.

# Brewfile — declarative package list for the core CLI toolset.
#
# Installed via `brew bundle` (see cmd/install.sh, or run `brew bundle` directly).
# This is the source of truth for formulae; casks that are individually
# toggleable in the installer (Ghostty, Nerd Font, gh) stay in cmd/install.sh.
#
# Tip: `brew bundle cleanup --file=Brewfile` lists packages NOT in this file.

# --- Core CLI tools ---
brew "neovim"
brew "tree-sitter-cli" # required by nvim-treesitter (main) to compile parsers
brew "tmux"
brew "fzf"
brew "fd"
brew "eza"
brew "bat"
brew "ripgrep"
brew "git-delta"
brew "zoxide"
brew "uv"          # Python toolchain (replaces pyenv)
brew "mise"        # per-project runtimes (.nvmrc, .node-version, .python-version, .tool-versions, .mise.toml); brew node/go/java stay the defaults
brew "direnv"      # per-directory env (.envrc); hooked in zsh/30-tools.zsh
brew "imagemagick"
brew "rustup"      # keg-only; install.sh runs `rustup default stable`, zsh/20-path.zsh adds it to PATH

# --- Language runtimes (mason-installed LSP servers depend on these) ---
brew "node"        # pyright, tsgo
brew "go"          # gopls
brew "openjdk"     # jdtls, google-java-format

# --- Formatters / linters (conform.nvim + nvim-lint) ---
brew "stylua"
brew "ruff"
brew "black"       # Python repos with [tool.black]; a .venv copy wins when present
brew "prettierd"
brew "eslint_d"
brew "clang-format"
brew "google-java-format"
brew "shfmt"       # shell formatting via conform (only where .editorconfig exists)
brew "hadolint"    # Dockerfile linting via nvim-lint

# --- Installer / dev tooling ---
brew "lazygit"     # Snacks.lazygit (<leader>gg)
brew "wget"        # mason downloads some adapters (js-debug, codelldb) with wget
brew "gum"         # TUI used by cmd/install.sh
brew "shellcheck"  # used by tests/run.sh

# --- Platform-specific trash utility ---
brew "trash" if OS.mac?
brew "trash-cli" unless OS.mac?

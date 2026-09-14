# Brewfile — declarative package list for the core CLI toolset.
#
# Installed via `brew bundle` (see install.sh, or run `brew bundle` directly).
# This is the source of truth for formulae; casks that are individually
# toggleable in the installer (Ghostty, Nerd Font, gh) stay in install.sh.
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
brew "imagemagick"
brew "rust"

# --- Language runtimes (mason-installed LSP servers depend on these) ---
brew "node"        # pyright, tsgo
brew "go"          # gopls
brew "openjdk"     # jdtls, google-java-format

# --- Formatters / linters (conform.nvim + nvim-lint) ---
brew "stylua"
brew "ruff"
brew "prettierd"
brew "eslint_d"
brew "clang-format"
brew "google-java-format"

# --- Installer / dev tooling ---
brew "lazygit"     # Snacks.lazygit (<leader>gg)
brew "gum"         # TUI used by install.sh
brew "shellcheck"  # used by tests/run.sh

# --- Platform-specific trash utility ---
brew "trash" if OS.mac?
brew "trash-cli" unless OS.mac?

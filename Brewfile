# Brewfile — declarative package list for the core CLI toolset.
#
# Installed via `brew bundle` (see install.sh, or run `brew bundle` directly).
# This is the source of truth for formulae; casks that are individually
# toggleable in the installer (Ghostty, Nerd Font, gh) stay in install.sh.
#
# Tip: `brew bundle cleanup --file=Brewfile` lists packages NOT in this file.

# --- Core CLI tools ---
brew "neovim"
brew "tmux"
brew "fzf"
brew "fd"
brew "eza"
brew "bat"
brew "ripgrep"
brew "git-delta"
brew "zoxide"
brew "pyenv"
brew "imagemagick"
brew "rust"

# --- Installer / dev tooling ---
brew "gum"         # TUI used by install.sh
brew "shellcheck"  # used by tests/run.sh

# --- Platform-specific trash utility ---
brew "trash" if OS.mac?
brew "trash-cli" unless OS.mac?

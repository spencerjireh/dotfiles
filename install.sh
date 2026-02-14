#!/bin/bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC}  $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

create_symlink() {
    local src="$1"
    local dest="$2"

    if [ ! -e "$src" ]; then
        log_error "Source does not exist: $src"
        return 1
    fi

    if [ -L "$dest" ]; then
        local current_target
        current_target="$(readlink "$dest")"
        if [ "$current_target" = "$src" ]; then
            log_warn "Symlink already correct, skipping: $dest"
            return 0
        else
            log_warn "Replacing existing symlink: $dest -> $current_target"
        fi
    elif [ -e "$dest" ]; then
        local backup="${dest}.backup.$(date +%Y%m%d_%H%M%S)"
        log_warn "File exists at $dest, backing up to $backup"
        mv "$dest" "$backup"
    fi

    ln -sf "$src" "$dest"
    log_info "Linked: $dest -> $src"
}

# OS detection
case "$(uname -s)" in
    Darwin) OS="macos" ;;
    Linux)  OS="linux" ;;
    *)      log_error "Unsupported OS: $(uname -s)"; exit 1 ;;
esac

echo ""
echo "Installing dotfiles from $DOTFILES_DIR ($OS)"
echo "========================================"

# Pre-flight checks
if ! command -v brew &>/dev/null; then
    log_error "Homebrew is not installed. Install it first: https://brew.sh"
    exit 1
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log_error "Oh My Zsh is not installed. Install it first: https://ohmyz.sh"
    exit 1
fi

# Brew packages
log_info "Installing Homebrew packages..."

BREW_FORMULAE=(
    neovim
    tmux
    fzf
    fd
    eza
    bat
    ripgrep
    git-delta
    zoxide
    pyenv
    imagemagick
)

# trash utility differs by platform
if [[ "$OS" == "macos" ]]; then
    BREW_FORMULAE+=(trash)
else
    BREW_FORMULAE+=(trash-cli)
fi

for formula in "${BREW_FORMULAE[@]}"; do
    if brew list "$formula" &>/dev/null; then
        log_warn "$formula already installed, skipping"
    else
        brew install "$formula"
        log_info "Installed $formula"
    fi
done

# Font installation (casks are macOS-only)
if [[ "$OS" == "macos" ]]; then
    BREW_CASKS=(font-gohufont-nerd-font)
    for cask in "${BREW_CASKS[@]}"; do
        if brew list --cask "$cask" &>/dev/null; then
            log_warn "$cask already installed, skipping"
        else
            brew install --cask "$cask"
            log_info "Installed $cask"
        fi
    done
else
    FONT_DIR="$HOME/.local/share/fonts"
    FONT_NAME="GohuFont"
    if fc-list | grep -qi "$FONT_NAME"; then
        log_warn "$FONT_NAME already installed, skipping"
    else
        log_info "Installing $FONT_NAME Nerd Font..."
        mkdir -p "$FONT_DIR"
        curl -fLo "/tmp/Gohu.tar.xz" \
            "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Gohu.tar.xz"
        tar -xf "/tmp/Gohu.tar.xz" -C "$FONT_DIR"
        rm -f "/tmp/Gohu.tar.xz"
        fc-cache -fv
        log_info "Installed $FONT_NAME Nerd Font"
    fi
fi

# TPM (tmux plugin manager)
log_info "Setting up TPM..."
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    git -C "$HOME/.tmux/plugins/tpm" pull --quiet
    log_info "Updated TPM"
else
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    log_info "Installed TPM"
fi
"$HOME/.tmux/plugins/tpm/bin/install_plugins"
log_info "Installed TPM plugins"

# Ghostty
log_info "Setting up Ghostty..."
if [[ "$OS" == "macos" ]]; then
    GHOSTTY_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
else
    GHOSTTY_DIR="$HOME/.config/ghostty"
fi
mkdir -p "$GHOSTTY_DIR"
create_symlink "$DOTFILES_DIR/ghostty/config" "$GHOSTTY_DIR/config"

# Zsh
log_info "Setting up Zsh..."
create_symlink "$DOTFILES_DIR/zsh/.zshrc" ~/.zshrc
create_symlink "$DOTFILES_DIR/zsh/.p10k.zsh" ~/.p10k.zsh

# Neovim
log_info "Setting up Neovim..."
mkdir -p ~/.config
create_symlink "$DOTFILES_DIR/nvim" ~/.config/nvim

# tmux
log_info "Setting up tmux..."
create_symlink "$DOTFILES_DIR/tmux/tmux.conf" ~/.tmux.conf

# Oh My Zsh plugins and theme
log_info "Setting up Oh My Zsh plugins and theme..."

OMZ_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$OMZ_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$OMZ_CUSTOM/plugins/zsh-autosuggestions"
    log_info "Installed zsh-autosuggestions"
else
    git -C "$OMZ_CUSTOM/plugins/zsh-autosuggestions" pull --quiet
    log_info "Updated zsh-autosuggestions"
fi

if [ ! -d "$OMZ_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$OMZ_CUSTOM/plugins/zsh-syntax-highlighting"
    log_info "Installed zsh-syntax-highlighting"
else
    git -C "$OMZ_CUSTOM/plugins/zsh-syntax-highlighting" pull --quiet
    log_info "Updated zsh-syntax-highlighting"
fi

if [ ! -d "$OMZ_CUSTOM/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$OMZ_CUSTOM/themes/powerlevel10k"
    log_info "Installed powerlevel10k"
else
    git -C "$OMZ_CUSTOM/themes/powerlevel10k" pull --quiet
    log_info "Updated powerlevel10k"
fi

# GitHub SSH + CLI
read -rp "Set up GitHub SSH + CLI? [Y/n] " setup_github
setup_github="${setup_github:-Y}"

if [[ "$setup_github" =~ ^[Yy]$ ]]; then
    log_info "Setting up GitHub SSH..."
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh

    if [ -f "$HOME/.ssh/id_ed25519_github" ]; then
        log_warn "GitHub SSH key already exists, skipping generation"
    else
        read -rp "Enter your GitHub email: " github_email
        ssh-keygen -t ed25519 -C "$github_email" -f ~/.ssh/id_ed25519_github -N ""
        log_info "Generated GitHub SSH key"
    fi

    if grep -q "Host github.com" ~/.ssh/config 2>/dev/null; then
        log_warn "GitHub SSH config already exists, skipping"
    else
        cat >> ~/.ssh/config <<'EOF'

# Personal GitHub
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github
    IdentitiesOnly yes
EOF
        chmod 600 ~/.ssh/config
        log_info "Added GitHub host to ~/.ssh/config"
    fi

    if ! command -v gh &>/dev/null; then
        brew install gh
        log_info "Installed GitHub CLI"
    else
        log_warn "GitHub CLI already installed, skipping"
    fi
else
    log_warn "Skipping GitHub setup"
fi

# Git configuration
read -rp "Set up global Git config? [Y/n] " setup_git
setup_git="${setup_git:-Y}"

if [[ "$setup_git" =~ ^[Yy]$ ]]; then
    log_info "Setting up Git config..."

    current_name="$(git config --global user.name 2>/dev/null || true)"
    if [ -n "$current_name" ]; then
        log_warn "Git user.name already set to '$current_name', skipping"
    else
        read -rp "Enter your full name for Git: " git_name
        git config --global user.name "$git_name"
        log_info "Set git user.name"
    fi

    current_email="$(git config --global user.email 2>/dev/null || true)"
    if [ -n "$current_email" ]; then
        log_warn "Git user.email already set to '$current_email', skipping"
    else
        read -rp "Enter your email for Git: " git_email
        git config --global user.email "$git_email"
        log_info "Set git user.email"
    fi

    git config --global core.editor nvim
    log_info "Set core.editor to nvim"

    git config --global init.defaultBranch main
    log_info "Set init.defaultBranch to main"

    if command -v delta &>/dev/null; then
        git config --global core.pager delta
        git config --global interactive.diffFilter "delta --color-only"
        git config --global delta.navigate true
        git config --global delta.dark true
        git config --global delta.line-numbers true
        git config --global merge.conflictstyle diff3
        git config --global diff.colorMoved default
        log_info "Configured delta as Git pager"
    fi
else
    log_warn "Skipping Git config setup"
fi

# macOS defaults
if [[ "$OS" == "macos" ]]; then
    read -rp "Apply macOS developer defaults? [Y/n] " setup_macos
    setup_macos="${setup_macos:-Y}"

    if [[ "$setup_macos" =~ ^[Yy]$ ]]; then
        log_info "Applying macOS defaults..."

        # Keyboard: fast key repeat
        defaults write NSGlobalDomain KeyRepeat -int 2
        defaults write NSGlobalDomain InitialKeyRepeat -int 15
        log_info "Set fast key repeat rate"

        # Finder
        defaults write com.apple.finder AppleShowAllFiles -bool true
        log_info "Finder: show hidden files"

        defaults write com.apple.finder ShowPathbar -bool true
        log_info "Finder: show path bar"

        defaults write NSGlobalDomain AppleShowAllExtensions -bool true
        log_info "Finder: show all extensions"

        defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
        log_info "Finder: disable extension change warning"

        # Dock
        defaults write com.apple.dock autohide -bool true
        log_info "Dock: auto-hide enabled"

        defaults write com.apple.dock mineffect -string "scale"
        log_info "Dock: minimize effect set to scale"

        defaults write com.apple.dock show-recents -bool false
        log_info "Dock: hide recent apps"

        # Trackpad
        defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
        defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
        log_info "Trackpad: tap to click enabled"

        # Screenshots
        mkdir -p "$HOME/Screenshots"
        defaults write com.apple.screencapture location -string "$HOME/Screenshots"
        log_info "Screenshots: save to ~/Screenshots"

        defaults write com.apple.screencapture disable-shadow -bool true
        log_info "Screenshots: shadow disabled"

        # Restart affected apps
        killall Finder 2>/dev/null || true
        killall Dock 2>/dev/null || true
        log_info "Restarted Finder and Dock to apply changes"

        log_warn "Keyboard repeat rate change requires logout to take effect"
    else
        log_warn "Skipping macOS defaults"
    fi
fi

echo "========================================"
log_info "Dotfiles installed successfully!"
echo ""
log_info "Note: Restart your shell or run 'source ~/.zshrc' to apply changes."
echo ""
if command -v gh &>/dev/null && ! gh auth status &>/dev/null; then
    log_info "GitHub SSH post-setup steps:"
    if [[ "$OS" == "macos" ]]; then
        echo "  1. Copy your public key:  pbcopy < ~/.ssh/id_ed25519_github.pub"
    else
        echo "  1. Copy your public key:  xclip -selection clipboard < ~/.ssh/id_ed25519_github.pub"
    fi
    echo "  2. Add it to GitHub:      https://github.com/settings/keys"
    echo "  3. Authenticate gh CLI:   gh auth login -p ssh -h github.com -w"
fi

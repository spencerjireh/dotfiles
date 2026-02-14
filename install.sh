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

echo ""
echo "Installing dotfiles from $DOTFILES_DIR"
echo "========================================"

# Pre-flight checks
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log_error "Oh My Zsh is not installed. Install it first: https://ohmyz.sh"
    exit 1
fi

# Ghostty
log_info "Setting up Ghostty..."
mkdir -p ~/Library/Application\ Support/com.mitchellh.ghostty
create_symlink "$DOTFILES_DIR/ghostty/config" ~/Library/Application\ Support/com.mitchellh.ghostty/config

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
    log_warn "zsh-autosuggestions already installed, skipping"
fi

if [ ! -d "$OMZ_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$OMZ_CUSTOM/plugins/zsh-syntax-highlighting"
    log_info "Installed zsh-syntax-highlighting"
else
    log_warn "zsh-syntax-highlighting already installed, skipping"
fi

if [ ! -d "$OMZ_CUSTOM/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$OMZ_CUSTOM/themes/powerlevel10k"
    log_info "Installed powerlevel10k"
else
    log_warn "powerlevel10k already installed, skipping"
fi

echo "========================================"
log_info "Dotfiles installed successfully!"
echo ""
log_info "Note: Restart your shell or run 'source ~/.zshrc' to apply changes."

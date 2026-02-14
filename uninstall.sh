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

remove_symlink() {
    local dest="$1"
    local expected_src="$2"

    if [ -L "$dest" ]; then
        local current_target
        current_target="$(readlink "$dest")"
        if [ "$current_target" = "$expected_src" ]; then
            rm "$dest"
            log_info "Removed symlink: $dest"

            # Restore most recent backup if one exists
            local backup
            backup="$(ls -t "${dest}.backup."* 2>/dev/null | head -1 || true)"
            if [ -n "$backup" ]; then
                mv "$backup" "$dest"
                log_info "Restored backup: $backup -> $dest"
            fi
        else
            log_warn "Symlink $dest points to $current_target (not dotfiles), skipping"
        fi
    elif [ -e "$dest" ]; then
        log_warn "$dest exists but is not a symlink, skipping"
    else
        log_warn "$dest does not exist, nothing to remove"
    fi
}

echo ""
echo "Uninstalling dotfiles from $DOTFILES_DIR"
echo "========================================"

read -rp "Are you sure you want to remove dotfiles symlinks? [y/N] " confirm
confirm="${confirm:-N}"

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    log_info "Aborted."
    exit 0
fi

log_info "Removing symlinks..."

remove_symlink ~/Library/Application\ Support/com.mitchellh.ghostty/config \
    "$DOTFILES_DIR/ghostty/config"

remove_symlink ~/.zshrc "$DOTFILES_DIR/zsh/.zshrc"
remove_symlink ~/.p10k.zsh "$DOTFILES_DIR/zsh/.p10k.zsh"

remove_symlink ~/.config/nvim "$DOTFILES_DIR/nvim"

remove_symlink ~/.tmux.conf "$DOTFILES_DIR/tmux/tmux.conf"

echo "========================================"
log_info "Dotfiles symlinks removed."
echo ""
log_info "The following were NOT removed (manual cleanup if needed):"
echo "  - Homebrew packages"
echo "  - Oh My Zsh plugins (~/.oh-my-zsh/custom/plugins/)"
echo "  - TPM (~/.tmux/plugins/tpm)"
echo "  - SSH keys (~/.ssh/id_ed25519_github)"
echo "  - Git global config"
echo "  - macOS defaults"

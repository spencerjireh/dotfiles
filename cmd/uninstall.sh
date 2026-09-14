#!/bin/bash

set -euo pipefail

# Run as `dot uninstall`. Removes the symlinks the installer created and
# restores the most recent backup of each; leaves packages and plugins alone.
source "$(dirname "${BASH_SOURCE[0]}")/../lib/log.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/env.sh"
DOTFILES_DIR="${DOTFILES_DIR:-$(dotfiles_dir "${BASH_SOURCE[0]}")}"
source "$DOTFILES_DIR/lib/tui.sh"
source "$DOTFILES_DIR/lib/components.sh"
load_env

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

# gum only if it is already there; never install anything while uninstalling.
# shellcheck disable=SC2034  # read by the sourced lib/tui.sh helpers
command -v gum &>/dev/null && USE_GUM=1
if ! tui_confirm "Remove the dotfiles symlinks (backups are restored)?"; then
    log_info "Aborted."
    exit 0
fi

log_info "Removing symlinks..."

if [[ "$(uname -s)" == "Darwin" ]]; then
    GHOSTTY_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
    SPF_DIR="$HOME/Library/Application Support/superfile"
else
    GHOSTTY_DIR="$HOME/.config/ghostty"
    SPF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/superfile"
fi
remove_symlink "$GHOSTTY_DIR/config" "$DOTFILES_DIR/ghostty/config"
[[ "$(uname -s)" == "Darwin" ]] && remove_symlink "$HOME/.config/karabiner" "$DOTFILES_DIR/karabiner"
remove_symlink "$SPF_DIR/config.toml" "$DOTFILES_DIR/superfile/config.toml"
remove_symlink "$SPF_DIR/hotkeys.toml" "$DOTFILES_DIR/superfile/hotkeys.toml"
remove_symlink "$SPF_DIR/theme/vesper.toml" "$DOTFILES_DIR/superfile/theme/vesper.toml"

remove_symlink "$HOME/.zshrc" "$DOTFILES_DIR/zsh/.zshrc"
remove_symlink "$HOME/.p10k.zsh" "$DOTFILES_DIR/zsh/.p10k.zsh"

remove_symlink "$HOME/.config/nvim" "$DOTFILES_DIR/nvim"

remove_symlink "$HOME/.tmux.conf" "$DOTFILES_DIR/tmux/tmux.conf"

remove_symlink "$HOME/.gitconfig.dotfiles" "$DOTFILES_DIR/git/config"
remove_symlink "$HOME/.config/git/ignore" "$DOTFILES_DIR/git/ignore"

remove_symlink "$HOME/.local/bin/dot" "$DOTFILES_DIR/bin/dot"
# Legacy links from before the dot command
remove_symlink "$HOME/.local/bin/dotup" "$DOTFILES_DIR/update.sh"
remove_symlink "$HOME/.local/bin/dotdoctor" "$DOTFILES_DIR/doctor.sh"

# Git: drop the include of the (now removed) tracked config and the signers file
if [ "$(git config --global --get include.path 2>/dev/null)" = "$HOME/.gitconfig.dotfiles" ]; then
    git config --global --unset include.path
    log_info "Removed include.path from ~/.gitconfig"
fi
if [ -f "$HOME/.config/git/allowed_signers" ]; then
    rm "$HOME/.config/git/allowed_signers"
    log_info "Removed ~/.config/git/allowed_signers"
fi

if [ -f "$COMPONENTS_FILE" ]; then
    rm "$COMPONENTS_FILE"
    log_info "Removed ${COMPONENTS_FILE/#$HOME/~}"
fi

echo "========================================"
log_info "Dotfiles symlinks removed."
echo ""
log_info "The following were NOT removed (manual cleanup if needed):"
echo "  - Homebrew packages"
echo "  - Oh My Zsh plugins (~/.oh-my-zsh/custom/plugins/)"
echo "  - TPM (~/.tmux/plugins/tpm)"
echo "  - SSH keys (~/.ssh/id_ed25519_github)"
echo "  - Git user.name / user.email"
echo "  - macOS defaults"
echo "  - ~/.zshrc.local (machine-specific overrides)"
echo "  - Claude Code (~/.local/bin/claude or installer location)"

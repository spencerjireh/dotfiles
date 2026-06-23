#!/bin/bash

# Update everything: dotfiles repo, brew packages, tmux/zsh/nvim plugins, Claude.
# Installed as `dotup` on your PATH by install.sh.

set -uo pipefail

# Resolve the real script dir even when invoked through a symlink.
SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SOURCE" ]; do
    DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ "$SOURCE" != /* ]] && SOURCE="$DIR/$SOURCE"
done
DOTFILES_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"

source "$DOTFILES_DIR/lib/log.sh"

echo ""
echo "Updating dotfiles environment"
echo "========================================"

# Dotfiles repo
log_info "Pulling dotfiles repo..."
git -C "$DOTFILES_DIR" pull --ff-only --quiet || log_warn "git pull skipped/failed"

# Homebrew
if command -v brew &>/dev/null; then
    log_info "Updating Homebrew + bundle..."
    brew update
    brew bundle --file="$DOTFILES_DIR/Brewfile"
    brew upgrade
    brew cleanup
fi

# tmux plugins (TPM)
if [ -x "$HOME/.tmux/plugins/tpm/bin/update_plugins" ]; then
    log_info "Updating tmux plugins..."
    "$HOME/.tmux/plugins/tpm/bin/update_plugins" all || log_warn "TPM update failed (is tmux running?)"
fi

# Oh My Zsh custom plugins + theme
OMZ_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
for repo in \
    "$OMZ_CUSTOM/plugins/zsh-autosuggestions" \
    "$OMZ_CUSTOM/plugins/zsh-syntax-highlighting" \
    "$OMZ_CUSTOM/themes/powerlevel10k"; do
    if [ -d "$repo/.git" ]; then
        log_info "Updating $(basename "$repo")..."
        git -C "$repo" pull --quiet || log_warn "Failed to update $(basename "$repo")"
    fi
done

# Neovim plugins (headless lazy.nvim sync)
if command -v nvim &>/dev/null; then
    log_info "Syncing Neovim plugins..."
    nvim --headless "+Lazy! sync" +qa 2>/dev/null || log_warn "nvim plugin sync skipped"
fi

# Claude Code self-update
if command -v claude &>/dev/null; then
    log_info "Updating Claude Code..."
    claude update 2>/dev/null || log_warn "Claude update skipped"
fi

echo "========================================"
log_info "Update complete. Run 'source ~/.zshrc' if shell config changed."

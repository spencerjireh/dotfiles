#!/bin/bash

# Update everything: dotfiles repo, brew packages, tmux/zsh/nvim plugins, Claude.
# Run as `dot update` (alias `dotup`).

set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/log.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/env.sh"
DOTFILES_DIR="${DOTFILES_DIR:-$(dotfiles_dir "${BASH_SOURCE[0]}")}"
load_env

source "$DOTFILES_DIR/lib/tmux.sh"
source "$DOTFILES_DIR/lib/profile.sh"

echo ""
echo "Updating dotfiles environment"
echo "========================================"

# Dotfiles repo
log_info "Pulling dotfiles repo..."
git -C "$DOTFILES_DIR" pull --ff-only --quiet || log_warn "git pull skipped/failed"

# After the pull, so a profile changed upstream is the one applied.
profile_load_recorded
log_info "Profile: $PROFILE_NAME"

# Homebrew
if command -v brew &>/dev/null; then
    log_info "Updating Homebrew + bundle..."
    brew update
    brew bundle --file="$(profile_brewfile)"
    brew upgrade
    brew cleanup
fi

# tmux plugins (TPM): install anything new in tmux.conf, then update all
if [ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
    log_info "Installing/updating tmux plugins..."
    tpm_run install_plugins || log_warn "TPM plugin install failed"
    tpm_run update_plugins all || log_warn "TPM plugin update failed"
    tpm_run clean_plugins || log_warn "TPM plugin clean failed"
    setting_off DOTFILES_TMUX_THUMBS || tmux_thumbs_build
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
    if [ "$PROFILE_READONLY" = 1 ]; then
        # Read-only clone: install exactly what nvim/lazy-lock.json pins and
        # never rewrite it, so the next pull stays a fast-forward.
        log_info "Restoring Neovim plugins to nvim/lazy-lock.json..."
        NVIM_TS_SYNC=1 nvim --headless "+Lazy! restore" +qa 2>/dev/null || log_warn "nvim plugin restore skipped"
    else
        log_info "Syncing Neovim plugins..."
        NVIM_TS_SYNC=1 nvim --headless "+Lazy! sync" +qa 2>/dev/null || log_warn "nvim plugin sync skipped"
    fi
    if ! setting_off DOTFILES_MASON; then
        # Refresh the mason registry (server binaries update only when reinstalled).
        nvim --headless -c 'lua require("mason-registry").refresh(function() vim.cmd.qa() end); vim.defer_fn(function() vim.cmd.qa() end, 30000)' \
            2>/dev/null || log_warn "mason registry refresh skipped"
    fi
    if [ -n "$(git -C "$DOTFILES_DIR" status --porcelain nvim/lazy-lock.json)" ]; then
        log_warn "nvim/lazy-lock.json changed: commit it in $DOTFILES_DIR"
    fi
fi

# Claude Code self-update
if command -v claude &>/dev/null; then
    log_info "Updating Claude Code..."
    claude update 2>/dev/null || log_warn "Claude update skipped"
fi

echo "========================================"
log_info "Update complete. Run 'source ~/.zshrc' if shell config changed."

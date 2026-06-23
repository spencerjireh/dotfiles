#!/bin/bash

# Health check: verify dotfiles symlinks point where they should and that the
# tools the configs assume are actually installed. Installed as `dotdoctor`.

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

case "$(uname -s)" in
    Darwin) OS="macos" ;;
    *)      OS="linux" ;;
esac

ISSUES=0

check_link() { # dest expected-target
    local dest="$1" expected="$2"
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$expected" ]; then
        log_info "link ok: ${dest/#$HOME/~}"
    elif [ -L "$dest" ]; then
        log_warn "link points elsewhere: ${dest/#$HOME/~} -> $(readlink "$dest")"
        ISSUES=$((ISSUES + 1))
    elif [ -e "$dest" ]; then
        log_warn "not a symlink (real file): ${dest/#$HOME/~}"
        ISSUES=$((ISSUES + 1))
    else
        log_warn "missing link: ${dest/#$HOME/~}"
        ISSUES=$((ISSUES + 1))
    fi
}

check_tool() { # cmd [note]
    if command -v "$1" &>/dev/null; then
        log_info "tool ok: $1"
    else
        log_warn "tool missing: $1${2:+ ($2)}"
        ISSUES=$((ISSUES + 1))
    fi
}

echo ""
echo "Dotfiles doctor ($OS)"
echo "========================================"

log_info "Checking symlinks..."
if [[ "$OS" == "macos" ]]; then
    check_link "$HOME/Library/Application Support/com.mitchellh.ghostty/config" "$DOTFILES_DIR/ghostty/config"
else
    check_link "$HOME/.config/ghostty/config" "$DOTFILES_DIR/ghostty/config"
fi
check_link "$HOME/.zshrc"              "$DOTFILES_DIR/zsh/.zshrc"
check_link "$HOME/.p10k.zsh"           "$DOTFILES_DIR/zsh/.p10k.zsh"
check_link "$HOME/.config/nvim"        "$DOTFILES_DIR/nvim"
check_link "$HOME/.tmux.conf"          "$DOTFILES_DIR/tmux/tmux.conf"
check_link "$HOME/.gitaliases"         "$DOTFILES_DIR/git/aliases"

echo ""
log_info "Checking tools..."
for t in nvim tmux fzf fd eza bat rg delta zoxide git; do
    check_tool "$t"
done
check_tool gh "GitHub SSH + CLI feature"
check_tool claude "Claude Code feature"

echo "========================================"
if [ "$ISSUES" -eq 0 ]; then
    log_info "All checks passed. ✨"
else
    log_warn "$ISSUES issue(s) found. Re-run ./install.sh to repair."
fi
[ "$ISSUES" -eq 0 ]

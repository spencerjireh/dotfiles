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

check_tool_optional() { # cmd [note] -- warn only, does not count as an issue
    if command -v "$1" &>/dev/null; then
        log_info "tool ok: $1"
    else
        log_warn "optional tool missing: $1${2:+ ($2)}"
    fi
}

check_file() { # file [note]
    if [ -f "$1" ]; then
        log_info "file ok: ${1/#$HOME/~}"
    else
        log_warn "missing file: ${1/#$HOME/~}${2:+ ($2)}"
        ISSUES=$((ISSUES + 1))
    fi
}

check_dir() { # dir [note]
    if [ -d "$1" ]; then
        log_info "dir ok: ${1/#$HOME/~}"
    else
        log_warn "missing dir: ${1/#$HOME/~}${2:+ ($2)}"
        ISSUES=$((ISSUES + 1))
    fi
}

echo ""
echo "Dotfiles doctor ($OS)"
echo "========================================"

log_info "Checking symlinks..."
if [[ "$OS" == "macos" ]]; then
    check_link "$HOME/Library/Application Support/com.mitchellh.ghostty/config" "$DOTFILES_DIR/ghostty/config"
    SPF_DIR="$HOME/Library/Application Support/superfile"
else
    check_link "$HOME/.config/ghostty/config" "$DOTFILES_DIR/ghostty/config"
    SPF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/superfile"
fi
check_link "$SPF_DIR/config.toml"      "$DOTFILES_DIR/superfile/config.toml"
check_link "$SPF_DIR/hotkeys.toml"     "$DOTFILES_DIR/superfile/hotkeys.toml"
check_link "$SPF_DIR/theme/vesper.toml" "$DOTFILES_DIR/superfile/theme/vesper.toml"
check_link "$HOME/.zshrc"              "$DOTFILES_DIR/zsh/.zshrc"
check_link "$HOME/.p10k.zsh"           "$DOTFILES_DIR/zsh/.p10k.zsh"
check_link "$HOME/.config/nvim"        "$DOTFILES_DIR/nvim"
check_link "$HOME/.tmux.conf"          "$DOTFILES_DIR/tmux/tmux.conf"
check_link "$HOME/.gitconfig.dotfiles" "$DOTFILES_DIR/git/config"
check_link "$HOME/.config/git/ignore"  "$DOTFILES_DIR/git/ignore"
check_link "$HOME/.local/bin/dotup"    "$DOTFILES_DIR/update.sh"
check_link "$HOME/.local/bin/dotdoctor" "$DOTFILES_DIR/doctor.sh"
check_file "$HOME/.zshrc.local" "seeded from zsh/.zshrc.local.example by install.sh"

echo ""
log_info "Checking Oh My Zsh custom plugins/theme..."
OMZ_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
for d in plugins/zsh-autosuggestions plugins/zsh-syntax-highlighting themes/powerlevel10k; do
    check_dir "$OMZ_CUSTOM/$d" "run ./install.sh (Zsh + Oh My Zsh)"
done

echo ""
log_info "Checking tools..."
for t in nvim tmux fzf fd eza bat rg delta zoxide git spf; do
    check_tool "$t"
done
check_tool gh "GitHub SSH + CLI feature"
check_tool claude "Claude Code feature"
for t in node go java; do
    check_tool "$t" "brew bundle (mason LSP servers need it)"
done
if [[ "$OS" == "macos" ]]; then
    if brew list --cask font-gohufont-nerd-font &>/dev/null; then
        log_info "font ok: GohuFont Nerd Font"
    else
        log_warn "optional font missing: GohuFont Nerd Font (Nerd Font feature)"
    fi
elif command -v fc-list &>/dev/null; then
    if fc-list | grep -qi gohu; then
        log_info "font ok: GohuFont Nerd Font"
    else
        log_warn "optional font missing: GohuFont Nerd Font (Nerd Font feature)"
    fi
fi

echo ""
log_info "Checking formatters/linters (nvim conform + nvim-lint)..."
for t in uv ruff stylua prettierd eslint_d tree-sitter; do
    check_tool "$t" "brew bundle"
done
check_tool_optional clang-format "C/C++ formatting via conform"
check_tool_optional google-java-format "Java formatting via conform"

echo ""
log_info "Checking LSP servers (mason, installed on first nvim start)..."
MASON_BIN="$HOME/.local/share/nvim/mason/bin"
for s in lua-language-server pyright-langserver tsgo gopls rust-analyzer jdtls clangd; do
    if [ -x "$MASON_BIN/$s" ]; then
        log_info "server ok: $s"
    else
        log_warn "optional server missing: $s (open nvim once, or :MasonInstall)"
    fi
done

echo ""
log_info "Checking tmux plugins (TPM)..."
for p in tpm tmux-resurrect tmux-thumbs; do
    check_dir "$HOME/.tmux/plugins/$p" "run ./install.sh (tmux + TPM) or dotup"
done

echo "========================================"
if [ "$ISSUES" -eq 0 ]; then
    log_info "All checks passed."
else
    log_warn "$ISSUES issue(s) found. Re-run ./install.sh to repair."
fi
[ "$ISSUES" -eq 0 ]

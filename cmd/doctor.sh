#!/bin/bash

# Health check: verify dotfiles symlinks point where they should and that the
# tools the configs assume are actually installed. Run as `dot doctor` (alias `dotdoctor`).

set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/log.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/env.sh"
DOTFILES_DIR="${DOTFILES_DIR:-$(dotfiles_dir "${BASH_SOURCE[0]}")}"
source "$DOTFILES_DIR/lib/components.sh"
load_env


case "$(uname -s)" in
    Darwin) OS="macos" ;;
    *)      OS="linux" ;;
esac

ISSUES=0
# --links: only check what install.sh creates (symlinks, dirs, files); skip
# tool/formatter/server checks. Used by CI, where the Brewfile is not installed.
LINKS_ONLY=0
[ "${1:-}" = "--links" ] && LINKS_ONLY=1

# Components recorded by install.sh. With no record, check everything.
SELECTED="$(components_load)"
if [ -n "$SELECTED" ]; then
    want() { is_selected "$1"; }
else
    want() { return 0; }
fi

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
if [ -n "$SELECTED" ]; then
    log_info "Checking components from ${COMPONENTS_FILE/#$HOME/~}: $(printf '%s' "$SELECTED" | tr '\n' ',' | sed 's/,/, /g')"
else
    log_warn "No component record (${COMPONENTS_FILE/#$HOME/~}); checking everything. Run ./install.sh to record it."
fi

log_info "Checking symlinks..."
check_link "$HOME/.local/bin/dot" "$DOTFILES_DIR/bin/dot"
# App-backed components (Ghostty, Karabiner) are checked only when the app is
# installed; a machine (or CI run) without them is not misconfigured.
if [[ "$OS" == "macos" ]]; then
    if want "Ghostty terminal"; then
        if [ -d "/Applications/Ghostty.app" ]; then
            check_link "$HOME/Library/Application Support/com.mitchellh.ghostty/config" "$DOTFILES_DIR/ghostty/config"
        else
            log_info "skip: Ghostty not installed"
        fi
    fi
    if want "Karabiner (Caps Lock as Esc/Ctrl)"; then
        if [ -d "/Applications/Karabiner-Elements.app" ]; then
            check_link "$HOME/.config/karabiner" "$DOTFILES_DIR/karabiner"
        else
            log_info "skip: Karabiner-Elements not installed"
        fi
    fi
    SPF_DIR="$HOME/Library/Application Support/superfile"
else
    if want "Ghostty terminal"; then
        if command -v ghostty &>/dev/null; then
            check_link "$HOME/.config/ghostty/config" "$DOTFILES_DIR/ghostty/config"
        else
            log_info "skip: Ghostty not installed"
        fi
    fi
    SPF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/superfile"
fi
if want "Superfile file manager"; then
    if command -v spf &>/dev/null; then
        check_link "$SPF_DIR/config.toml"      "$DOTFILES_DIR/superfile/config.toml"
        check_link "$SPF_DIR/hotkeys.toml"     "$DOTFILES_DIR/superfile/hotkeys.toml"
        check_link "$SPF_DIR/theme/vesper.toml" "$DOTFILES_DIR/superfile/theme/vesper.toml"
    else
        log_info "skip: superfile not installed"
    fi
fi
if want "Zsh + Oh My Zsh"; then
    check_link "$HOME/.zshrc"              "$DOTFILES_DIR/zsh/.zshrc"
    check_link "$HOME/.p10k.zsh"           "$DOTFILES_DIR/zsh/.p10k.zsh"
    check_file "$HOME/.zshrc.local" "seeded from zsh/.zshrc.local.example by install.sh"
fi
want "Neovim config" && check_link "$HOME/.config/nvim"   "$DOTFILES_DIR/nvim"
want "tmux + TPM"    && check_link "$HOME/.tmux.conf"     "$DOTFILES_DIR/tmux/tmux.conf"
if want "Git global config"; then
    check_link "$HOME/.gitconfig.dotfiles" "$DOTFILES_DIR/git/config"
    check_link "$HOME/.config/git/ignore"  "$DOTFILES_DIR/git/ignore"
fi
want "GitHub SSH + CLI" && check_file "$HOME/.ssh/id_ed25519_github" "GitHub SSH + CLI component"

if want "Zsh + Oh My Zsh"; then
echo ""
log_info "Checking Oh My Zsh custom plugins/theme..."
OMZ_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
for d in plugins/zsh-autosuggestions plugins/zsh-syntax-highlighting themes/powerlevel10k; do
    check_dir "$OMZ_CUSTOM/$d" "run ./install.sh (Zsh + Oh My Zsh)"
done
fi

if [ "$LINKS_ONLY" = 0 ]; then
if want "Homebrew CLI packages"; then
echo ""
log_info "Checking tools (Brewfile)..."
for t in nvim tmux fzf fd eza bat rg delta zoxide git lazygit; do
    check_tool "$t"
done
for t in node go java; do
    check_tool "$t" "brew bundle (mason LSP servers need it)"
done
check_tool rustup "brew bundle (keg-only; PATH via zsh/20-path.zsh)"
check_tool cargo "rustup default stable (builds tmux-thumbs)"

echo ""
log_info "Checking formatters/linters (nvim conform + nvim-lint)..."
for t in uv ruff stylua prettierd eslint_d tree-sitter; do
    check_tool "$t" "brew bundle"
done
check_tool_optional clang-format "C/C++ formatting via conform"
check_tool_optional google-java-format "Java formatting via conform"
fi

want "Superfile file manager" && check_tool spf "Superfile component"
want "GitHub SSH + CLI" && check_tool gh "GitHub SSH + CLI component"
want "Claude Code" && check_tool claude "Claude Code component"

if want "Nerd Font"; then
    if [[ "$OS" == "macos" ]]; then
        if brew list --cask font-gohufont-nerd-font &>/dev/null; then
            log_info "font ok: GohuFont Nerd Font"
        else
            log_warn "optional font missing: GohuFont Nerd Font (Nerd Font component)"
        fi
    elif command -v fc-list &>/dev/null; then
        if fc-list | grep -qi gohu; then
            log_info "font ok: GohuFont Nerd Font"
        else
            log_warn "optional font missing: GohuFont Nerd Font (Nerd Font component)"
        fi
    fi
fi

if want "Neovim config"; then
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
log_info "Checking debug adapters (mason-nvim-dap, installed on first nvim start)..."
for a in debugpy dlv js-debug-adapter codelldb; do
    if [ -x "$MASON_BIN/$a" ]; then
        log_info "adapter ok: $a"
    else
        log_warn "optional adapter missing: $a (open nvim once, or :MasonInstall)"
    fi
done
fi

fi # LINKS_ONLY

if want "tmux + TPM"; then
echo ""
log_info "Checking tmux plugins (TPM)..."
for p in tpm tmux-resurrect tmux-thumbs; do
    check_dir "$HOME/.tmux/plugins/$p" "run ./install.sh (tmux + TPM) or dot update"
done
[ "$LINKS_ONLY" = 0 ] && check_file "$HOME/.tmux/plugins/tmux-thumbs/target/release/thumbs" "dot update builds it (needs cargo)"
fi

echo "========================================"
if [ "$ISSUES" -eq 0 ]; then
    log_info "All checks passed."
else
    log_warn "$ISSUES issue(s) found. Re-run ./install.sh (dot install) to repair."
fi
[ "$ISSUES" -eq 0 ]

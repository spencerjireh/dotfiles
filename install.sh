#!/bin/bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$DOTFILES_DIR/lib/log.sh"
source "$DOTFILES_DIR/lib/tui.sh"

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

clone_or_pull() {
    local dest="$1"; shift
    if [ ! -d "$dest" ]; then
        git clone "$@" "$dest"
        log_info "Installed $(basename "$dest")"
    else
        git -C "$dest" pull --quiet
        log_info "Updated $(basename "$dest")"
    fi
}

brew_install() {
    local type="$1" pkg="$2"
    if brew list ${type:+--$type} "$pkg" &>/dev/null; then
        log_warn "$pkg already installed, skipping"
    else
        brew install ${type:+--$type} "$pkg"
        log_info "Installed $pkg"
    fi
}

# Make `brew` available in this shell session regardless of platform/arch.
load_brew_env() {
    if command -v brew &>/dev/null; then
        return
    elif [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
}

# Bootstrap the foundation a fresh machine lacks. Each is a no-op if present.
ensure_homebrew() {
    load_brew_env
    if command -v brew &>/dev/null; then
        log_info "Homebrew present"
        return
    fi
    log_warn "Homebrew not found; installing (may prompt for your password)..."
    NONINTERACTIVE=1 /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    load_brew_env
    command -v brew &>/dev/null || { log_error "Homebrew install failed"; exit 1; }
    log_info "Installed Homebrew"
}

ensure_zsh() {
    if command -v zsh &>/dev/null; then
        log_info "zsh present"
        return
    fi
    log_info "Installing zsh..."
    brew install zsh
    log_info "Installed zsh"
}

ensure_omz() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        log_info "Oh My Zsh present"
        return
    fi
    log_info "Installing Oh My Zsh..."
    # Non-interactive: don't switch shell, don't launch zsh, don't touch .zshrc
    # (we symlink our own afterward).
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
        || { log_error "Oh My Zsh install failed"; exit 1; }
    log_info "Installed Oh My Zsh"
}

# Membership test against the newline-separated $SELECTED list.
is_selected() {
    printf '%s\n' "$SELECTED" | grep -qxF "$1"
}

# Allow the test suite to source this file for its helper functions without
# running the installer. Everything below this guard is the actual install run.
if [ -n "${DOTFILES_SOURCE_ONLY:-}" ]; then
    return 0 2>/dev/null || true
fi

# OS detection
case "$(uname -s)" in
    Darwin) OS="macos" ;;
    Linux)  OS="linux" ;;
    *)      log_error "Unsupported OS: $(uname -s)"; exit 1 ;;
esac

echo ""
echo "Installing dotfiles from $DOTFILES_DIR ($OS)"
echo "========================================"

# ----------------------------------------------------------------------------
# Bootstrap: install the foundation a fresh machine lacks, before anything else.
# (Homebrew may prompt for your password; everything after the confirm is clean.)
# ----------------------------------------------------------------------------
log_info "Bootstrapping foundation (Homebrew, zsh, Oh My Zsh, gum)..."
ensure_homebrew
ensure_zsh
ensure_omz
ensure_gum   # TUI library, used by the prompts below

# ----------------------------------------------------------------------------
# Phase 1: collect every choice and input up front, then run unattended.
# ----------------------------------------------------------------------------
tui_header "Select what to install"

# Feature labels, built per-OS (some are macOS-only).
FEATURES=(
    "Homebrew CLI packages"
    "Ghostty terminal"
    "Claude Code"
    "Nerd Font"
    "Neovim config"
    "tmux + TPM"
    "Zsh + Oh My Zsh"
    "GitHub SSH + CLI"
    "Git global config"
)
if [[ "$OS" == "macos" ]]; then
    FEATURES+=("macOS defaults")
fi

tui_multiselect SELECTED "Components" "${FEATURES[@]}"

if [ -z "${SELECTED//[[:space:]]/}" ]; then
    log_warn "Nothing selected. Exiting."
    exit 0
fi

# Prefill text inputs now so the run never has to stop and ask.
GITHUB_EMAIL=""
GIT_NAME=""
GIT_EMAIL=""

if is_selected "GitHub SSH + CLI" && [ ! -f "$HOME/.ssh/id_ed25519_github" ]; then
    tui_input GITHUB_EMAIL "GitHub email (for the SSH key):"
fi

if is_selected "Git global config"; then
    current_name="$(git config --global user.name 2>/dev/null || true)"
    [ -z "$current_name" ] && tui_input GIT_NAME "Your full name for Git:"
    current_email="$(git config --global user.email 2>/dev/null || true)"
    [ -z "$current_email" ] && tui_input GIT_EMAIL "Your email for Git:"
fi

# Offer to switch the login shell to zsh (only if not already on it).
CHSH_ZSH=0
if is_selected "Zsh + Oh My Zsh" && [[ "$SHELL" != *zsh ]]; then
    if tui_confirm "Make zsh your default login shell? (needs your password)"; then
        CHSH_ZSH=1
    fi
fi

# Summary + single confirmation gate.
tui_header "Ready to install"
echo "Selected components:"
printf '%s\n' "$SELECTED" | sed '/^$/d;s/^/  - /'
echo ""

if ! tui_confirm "Proceed with installation?"; then
    log_info "Aborted by user."
    exit 0
fi

echo "========================================"
log_info "Running install (no further prompts)..."

# ----------------------------------------------------------------------------
# Phase 2: execution. Everything below is non-interactive.
# ----------------------------------------------------------------------------

# Brew packages (declarative via Brewfile)
if is_selected "Homebrew CLI packages"; then
    log_info "Installing Homebrew packages (brew bundle)..."
    brew bundle --file="$DOTFILES_DIR/Brewfile"
fi

# Ghostty (app + config)
if is_selected "Ghostty terminal"; then
    log_info "Setting up Ghostty..."
    if [[ "$OS" == "macos" ]]; then
        brew_install "cask" "ghostty"
        GHOSTTY_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
    else
        log_warn "Install the Ghostty app manually on Linux: https://ghostty.org/download"
        GHOSTTY_DIR="$HOME/.config/ghostty"
    fi
    mkdir -p "$GHOSTTY_DIR"
    create_symlink "$DOTFILES_DIR/ghostty/config" "$GHOSTTY_DIR/config"
fi

# Claude Code (native installer, self-updating)
if is_selected "Claude Code"; then
    log_info "Setting up Claude Code..."
    if command -v claude &>/dev/null; then
        log_warn "Claude Code already installed, skipping"
    else
        curl -fsSL https://claude.com/install.sh | bash
        log_info "Installed Claude Code"
    fi
fi

# Font installation
if is_selected "Nerd Font"; then
    log_info "Installing Nerd Font..."
    if [[ "$OS" == "macos" ]]; then
        brew_install "cask" "font-gohufont-nerd-font"
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
fi

# Neovim
if is_selected "Neovim config"; then
    log_info "Setting up Neovim..."
    mkdir -p "$HOME/.config"
    create_symlink "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
fi

# tmux + TPM
if is_selected "tmux + TPM"; then
    log_info "Setting up tmux..."
    create_symlink "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"

    log_info "Setting up TPM..."
    if [ -d "$HOME/.tmux/plugins/tpm" ]; then
        git -C "$HOME/.tmux/plugins/tpm" pull --quiet
        log_info "Updated TPM"
    else
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
        log_info "Installed TPM"
    fi
    "$HOME/.tmux/plugins/tpm/bin/install_plugins" || log_warn "TPM plugin install failed (is tmux running?)"
fi

# Zsh + Oh My Zsh plugins/theme
if is_selected "Zsh + Oh My Zsh"; then
    log_info "Setting up Zsh..."
    create_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
    create_symlink "$DOTFILES_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"

    # Seed machine-local overrides file (never tracked) if absent.
    if [ ! -f "$HOME/.zshrc.local" ]; then
        cp "$DOTFILES_DIR/zsh/.zshrc.local.example" "$HOME/.zshrc.local"
        log_info "Created ~/.zshrc.local from template (edit for machine-specific config)"
    else
        log_warn "~/.zshrc.local already exists, leaving it untouched"
    fi

    # Switch default login shell to zsh if the user opted in earlier.
    if [ "$CHSH_ZSH" = 1 ]; then
        zsh_path="$(command -v zsh)"
        if ! grep -qx "$zsh_path" /etc/shells 2>/dev/null; then
            echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
        fi
        if chsh -s "$zsh_path"; then
            log_info "Default login shell set to zsh ($zsh_path)"
        else
            log_warn "Could not change login shell (run: chsh -s $zsh_path)"
        fi
    fi

    log_info "Setting up Oh My Zsh plugins and theme..."
    OMZ_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    clone_or_pull "$OMZ_CUSTOM/plugins/zsh-autosuggestions" \
        https://github.com/zsh-users/zsh-autosuggestions
    clone_or_pull "$OMZ_CUSTOM/plugins/zsh-syntax-highlighting" \
        https://github.com/zsh-users/zsh-syntax-highlighting
    clone_or_pull "$OMZ_CUSTOM/themes/powerlevel10k" \
        --depth=1 https://github.com/romkatv/powerlevel10k.git
fi

# GitHub SSH + CLI
if is_selected "GitHub SSH + CLI"; then
    log_info "Setting up GitHub SSH..."
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    if [ -f "$HOME/.ssh/id_ed25519_github" ]; then
        log_warn "GitHub SSH key already exists, skipping generation"
    else
        ssh-keygen -t ed25519 -C "$GITHUB_EMAIL" -f "$HOME/.ssh/id_ed25519_github" -N ""
        log_info "Generated GitHub SSH key"
    fi

    touch "$HOME/.ssh/config"
    chmod 600 "$HOME/.ssh/config"

    if grep -q "Host github.com" "$HOME/.ssh/config" 2>/dev/null; then
        log_warn "GitHub SSH config already exists, skipping"
    else
        cat >> "$HOME/.ssh/config" <<'EOF'

# Personal GitHub
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github
    IdentitiesOnly yes
EOF
        log_info "Added GitHub host to $HOME/.ssh/config"
    fi

    if ! command -v gh &>/dev/null; then
        brew install gh
        log_info "Installed GitHub CLI"
    else
        log_warn "GitHub CLI already installed, skipping"
    fi
fi

# Git aliases (always wired up when git config is selected)
if is_selected "Git global config"; then
    log_info "Setting up Git aliases..."
    create_symlink "$DOTFILES_DIR/git/aliases" "$HOME/.gitaliases"

    log_info "Setting up Git config..."

    git config --global include.path "$HOME/.gitaliases"
    log_info "Included git aliases via include.path"

    current_name="$(git config --global user.name 2>/dev/null || true)"
    if [ -n "$current_name" ]; then
        log_warn "Git user.name already set to '$current_name', skipping"
    elif [ -n "$GIT_NAME" ]; then
        git config --global user.name "$GIT_NAME"
        log_info "Set git user.name"
    fi

    current_email="$(git config --global user.email 2>/dev/null || true)"
    if [ -n "$current_email" ]; then
        log_warn "Git user.email already set to '$current_email', skipping"
    elif [ -n "$GIT_EMAIL" ]; then
        git config --global user.email "$GIT_EMAIL"
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
fi

# macOS defaults
if is_selected "macOS defaults"; then
    log_info "Applying macOS defaults..."

    # Keyboard: fastest key repeat + repeat on hold (no accent menu popup)
    defaults write NSGlobalDomain KeyRepeat -int 1
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
    log_info "Set fastest key repeat + repeat-on-hold"

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
fi

# CLI helpers: `dotup` (update everything) and `dotdoctor` (health check),
# symlinked onto PATH via ~/.local/bin (already added to PATH in .zshrc).
log_info "Installing dotfiles CLI helpers (dotup, dotdoctor)..."
mkdir -p "$HOME/.local/bin"
create_symlink "$DOTFILES_DIR/update.sh" "$HOME/.local/bin/dotup"
create_symlink "$DOTFILES_DIR/doctor.sh" "$HOME/.local/bin/dotdoctor"

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

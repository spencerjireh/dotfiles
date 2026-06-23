#!/bin/bash

# TUI helpers for dotfiles install. Uses charmbracelet/gum when available,
# falling back to plain read-based prompts so the script never hard-breaks.
#
# Requires lib/log.sh to be sourced first (for log_info/log_warn).

USE_GUM=0

# Install gum if missing so the rest of the TUI has something to render with.
# Falls back to plain prompts when gum can't be installed.
ensure_gum() {
    if command -v gum &>/dev/null; then
        USE_GUM=1
        return
    fi
    log_info "Bootstrapping gum (TUI library)..."
    if command -v brew &>/dev/null && brew install gum &>/dev/null; then
        USE_GUM=1
        log_info "Installed gum"
    else
        USE_GUM=0
        log_warn "Could not install gum, falling back to plain text prompts"
    fi
}

# tui_header "text" — styled section banner (no-op flavor without gum).
tui_header() {
    if [ "$USE_GUM" = 1 ]; then
        gum style --foreground 215 --bold "$1"
    else
        echo ""
        echo "== $1 =="
    fi
}

# tui_multiselect VAR LABEL opt1 opt2 ... — present a checkbox list with every
# option pre-selected; assigns newline-separated chosen lines to VAR (nameref-free
# for bash 3.2 compatibility: writes to the global named by $1).
tui_multiselect() {
    local __var="$1"; shift
    local __label="$1"; shift
    local __result=""
    if [ "$USE_GUM" = 1 ]; then
        local __joined
        __joined="$(IFS=,; echo "$*")"
        __result="$(printf '%s\n' "$@" | gum choose --no-limit --height 18 \
            --header "$__label (space toggles, enter confirms)" \
            --selected "$__joined")"
    else
        echo ""
        echo "$__label"
        local opt ans
        for opt in "$@"; do
            read -rp "  Include '$opt'? [Y/n] " ans
            ans="${ans:-Y}"
            [[ "$ans" =~ ^[Yy]$ ]] && __result+="$opt"$'\n'
        done
    fi
    eval "$__var=\$__result"
}

# tui_input VAR PROMPT [DEFAULT] — prompt for a line of text, store in global VAR.
tui_input() {
    local __var="$1" __prompt="$2" __default="${3:-}"
    local __val
    if [ "$USE_GUM" = 1 ]; then
        __val="$(gum input --header "$__prompt" --value "$__default" \
            --placeholder "${__default:-type here}")"
    else
        read -rp "$__prompt " __val
    fi
    __val="${__val:-$__default}"
    eval "$__var=\$__val"
}

# tui_confirm "question" — returns 0 for yes, 1 for no. Defaults to yes.
tui_confirm() {
    if [ "$USE_GUM" = 1 ]; then
        gum confirm "$1"
    else
        local ans
        read -rp "$1 [Y/n] " ans
        ans="${ans:-Y}"
        [[ "$ans" =~ ^[Yy]$ ]]
    fi
}

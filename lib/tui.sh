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

# tui_multiselect VAR LABEL opt1 opt2 ... — present a checkbox list; assigns
# newline-separated chosen lines to VAR (nameref-free for bash 3.2
# compatibility: writes to the global named by $1). Every option starts
# selected unless TUI_PRESELECTED is set to a newline-separated list, in which
# case only those do.
tui_multiselect() {
    local __var="$1"; shift
    local __label="$1"; shift
    local __result=""
    if [ "$USE_GUM" = 1 ]; then
        local __joined
        if [ -n "${TUI_PRESELECTED+x}" ]; then
            __joined="$(printf '%s' "$TUI_PRESELECTED" | sed '/^$/d' | tr '\n' ',' | sed 's/,$//')"
        else
            __joined="$(IFS=,; echo "$*")"
        fi
        __result="$(printf '%s\n' "$@" | gum choose --no-limit --height 18 \
            --header "$__label (space toggles, enter confirms)" \
            --selected "$__joined")"
    else
        echo ""
        echo "$__label"
        local opt ans def
        for opt in "$@"; do
            def="Y"
            if [ -n "${TUI_PRESELECTED+x}" ] && ! printf '%s\n' "$TUI_PRESELECTED" | grep -qxF "$opt"; then
                def="N"
            fi
            if [ "$def" = "Y" ]; then
                read -rp "  Include '$opt'? [Y/n] " ans
            else
                read -rp "  Include '$opt'? [y/N] " ans
            fi
            ans="${ans:-$def}"
            [[ "$ans" =~ ^[Yy]$ ]] && __result+="$opt"$'\n'
        done
    fi
    eval "$__var=\$__result"
}

# tui_choose VAR LABEL opt1 opt2 ... — pick exactly one; the first option is the
# default. Stores the chosen line in the global VAR.
tui_choose() {
    local __var="$1"; shift
    local __label="$1"; shift
    local __val=""
    if [ "$USE_GUM" = 1 ]; then
        __val="$(printf '%s\n' "$@" | gum choose --header "$__label")"
    else
        echo ""
        echo "$__label"
        local i=1 opt ans
        for opt in "$@"; do
            echo "  $i) $opt"
            i=$((i + 1))
        done
        read -rp "Choice [1]: " ans
        ans="${ans:-1}"
        case "$ans" in
            *[!0-9]*) ans=1 ;;
        esac
        if [ "$ans" -ge 1 ] && [ "$ans" -le $# ]; then
            eval "__val=\${$ans}"
        fi
    fi
    __val="${__val:-$1}"
    eval "$__var=\$__val"
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

# tui_confirm "question" [no] — returns 0 for yes, 1 for no. Defaults to yes;
# pass "no" as the second argument to default to no.
tui_confirm() {
    local __def="${2:-yes}"
    if [ "$USE_GUM" = 1 ]; then
        if [ "$__def" = "no" ]; then
            gum confirm --default=false "$1"
        else
            gum confirm "$1"
        fi
    else
        local ans
        if [ "$__def" = "no" ]; then
            read -rp "$1 [y/N] " ans
            ans="${ans:-N}"
        else
            read -rp "$1 [Y/n] " ans
            ans="${ans:-Y}"
        fi
        [[ "$ans" =~ ^[Yy]$ ]]
    fi
}

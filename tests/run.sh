#!/bin/bash

# Dependency-free test suite for the dotfiles install machinery.
#
# Runs in a sandbox (its own temp HOME) and never installs anything or touches
# your real config. Covers: script linting, lib/log.sh + lib/tui.sh helpers, and
# install.sh's create_symlink / is_selected logic (sourced via DOTFILES_SOURCE_ONLY).
#
# Usage: ./tests/run.sh   (exit code 0 = all passed)

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

PASS=0
FAIL=0

GREEN='\033[0;32m'
RED='\033[0;31m'
DIM='\033[2m'
NC='\033[0m'

pass() { PASS=$((PASS + 1)); echo -e "  ${GREEN}✓${NC} $1"; }
fail() { FAIL=$((FAIL + 1)); echo -e "  ${RED}✗${NC} $1"; [ -n "${2:-}" ] && echo -e "    ${DIM}$2${NC}"; }

assert_eq() { # expected actual message
    if [ "$1" = "$2" ]; then pass "$3"; else fail "$3" "expected '$1', got '$2'"; fi
}
assert_contains() { # haystack needle message
    case "$1" in *"$2"*) pass "$3" ;; *) fail "$3" "'$1' missing '$2'" ;; esac
}
assert_success() { # message ; reads $? captured before call via $1=code
    if [ "$1" = "0" ]; then pass "$2"; else fail "$2" "exit code $1"; fi
}
assert_failure() {
    if [ "$1" != "0" ]; then pass "$2"; else fail "$2" "expected non-zero exit"; fi
}
assert_symlink_to() { # link target message
    if [ -L "$1" ] && [ "$(readlink "$1")" = "$2" ]; then pass "$3"
    else fail "$3" "'$1' not a symlink to '$2' (got '$(readlink "$1" 2>/dev/null)')"; fi
}

section() { echo ""; echo "── $1 ──"; }

# ---------------------------------------------------------------------------
section "Lint: bash -n on all scripts"
for f in install.sh uninstall.sh update.sh doctor.sh lib/log.sh lib/tui.sh lib/tmux.sh tests/run.sh; do
    if bash -n "$DOTFILES_DIR/$f" 2>/dev/null; then pass "$f parses"
    else fail "$f parses"; fi
done
if command -v shellcheck >/dev/null 2>&1; then
    if shellcheck -S warning "$DOTFILES_DIR/install.sh" "$DOTFILES_DIR/lib/tui.sh" "$DOTFILES_DIR/lib/tmux.sh" \
        "$DOTFILES_DIR/lib/log.sh" "$DOTFILES_DIR/uninstall.sh" "$DOTFILES_DIR/update.sh" "$DOTFILES_DIR/doctor.sh" \
        "$DOTFILES_DIR/tests/run.sh" >/dev/null 2>&1
    then pass "shellcheck (no warnings)"
    else fail "shellcheck (no warnings)" "$(shellcheck -S warning "$DOTFILES_DIR"/*.sh "$DOTFILES_DIR"/lib/*.sh "$DOTFILES_DIR"/tests/run.sh 2>&1 | grep -E "^In |SC[0-9]+" | head -6)"; fi
else
    echo -e "  ${DIM}· shellcheck not installed, skipped${NC}"
fi

# ---------------------------------------------------------------------------
section "lib/log.sh"
# shellcheck source=/dev/null
source "$DOTFILES_DIR/lib/log.sh"
assert_contains "$(log_info  'hi' 2>&1)" "[INFO]"  "log_info tags [INFO]"
assert_contains "$(log_warn  'hi' 2>&1)" "[WARN]"  "log_warn tags [WARN]"
assert_contains "$(log_error 'hi' 2>&1)" "[ERROR]" "log_error tags [ERROR]"

# ---------------------------------------------------------------------------
section "lib/tui.sh (plain-prompt fallback, USE_GUM=0)"
# shellcheck source=/dev/null
source "$DOTFILES_DIR/lib/tui.sh"
# shellcheck disable=SC2034  # read by the sourced tui_* helpers
USE_GUM=0

# Here-strings (not pipes) so the helper runs in this shell and its var sticks.
tui_input GOT "name?" "default-val" </dev/null
assert_eq "default-val" "$GOT" "tui_input falls back to default on empty"

tui_input GOT "name?" "default-val" <<< "spencer"
assert_eq "spencer" "$GOT" "tui_input takes typed value"

tui_multiselect SEL "pick" "Alpha" "Beta" <<< $'y\nn' >/dev/null
assert_contains "$SEL" "Alpha" "tui_multiselect includes accepted option"
case "$SEL" in *Beta*) fail "tui_multiselect excludes declined option" ;; *) pass "tui_multiselect excludes declined option" ;; esac

printf 'y\n' | tui_confirm "ok?"; assert_success "$?" "tui_confirm yes -> success"
printf 'n\n' | tui_confirm "ok?"; assert_failure "$?" "tui_confirm no -> failure"
printf '\n'  | tui_confirm "ok?"; assert_success "$?" "tui_confirm empty defaults to yes"

# ---------------------------------------------------------------------------
section "install.sh helpers (sourced)"
export DOTFILES_SOURCE_ONLY=1
# shellcheck source=/dev/null
source "$DOTFILES_DIR/install.sh"
unset DOTFILES_SOURCE_ONLY
# install.sh sets `set -euo pipefail`; undo it so intentional failures below
# (which we assert on) don't abort the test runner.
set +e +u +o pipefail

# is_selected against a newline list
# shellcheck disable=SC2034  # read by the sourced is_selected
SELECTED=$'Ghostty terminal\nClaude Code\nNeovim config'
( is_selected "Claude Code" ); assert_success "$?" "is_selected finds present item"
( is_selected "macOS defaults" ); assert_failure "$?" "is_selected rejects absent item"
( is_selected "Claude" ); assert_failure "$?" "is_selected requires exact (no substring) match"

# components_from_env: comma list -> newline list, trimmed, for non-interactive installs
SELECTED="$(components_from_env "Neovim config, tmux + TPM ,Zsh + Oh My Zsh,")"
assert_eq "3" "$(printf '%s\n' "$SELECTED" | grep -c .)" "components_from_env yields one line per component"
( is_selected "tmux + TPM" ); assert_success "$?" "components_from_env trims whitespace"
( is_selected "" ); assert_failure "$?" "components_from_env drops empty entries"

# ---------------------------------------------------------------------------
section "create_symlink (sandboxed)"
SANDBOX="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-test.XXXXXX")"
trap 'rm -rf "$SANDBOX"' EXIT

SRC="$SANDBOX/source.conf"
echo "real config" > "$SRC"

# 1. fresh link
DEST="$SANDBOX/link.conf"
create_symlink "$SRC" "$DEST" >/dev/null 2>&1
assert_symlink_to "$DEST" "$SRC" "creates a new symlink"

# 2. idempotent: re-linking the correct target keeps it
create_symlink "$SRC" "$DEST" >/dev/null 2>&1
assert_symlink_to "$DEST" "$SRC" "idempotent on already-correct symlink"

# 3. backs up a pre-existing real file
DEST2="$SANDBOX/existing.conf"
echo "pre-existing" > "$DEST2"
create_symlink "$SRC" "$DEST2" >/dev/null 2>&1
assert_symlink_to "$DEST2" "$SRC" "replaces existing file with symlink"
BACKUP="$(ls "$DEST2".backup.* 2>/dev/null | head -1)"
if [ -n "$BACKUP" ] && [ "$(cat "$BACKUP")" = "pre-existing" ]; then
    pass "backs up the displaced file"
else fail "backs up the displaced file"; fi

# 4. replaces a symlink pointing elsewhere
OTHER="$SANDBOX/other.conf"; echo other > "$OTHER"
DEST3="$SANDBOX/wrong.conf"; ln -s "$OTHER" "$DEST3"
create_symlink "$SRC" "$DEST3" >/dev/null 2>&1
assert_symlink_to "$DEST3" "$SRC" "repoints a symlink aimed elsewhere"

# 5. fails on missing source
( create_symlink "$SANDBOX/nope" "$SANDBOX/x" >/dev/null 2>&1 )
assert_failure "$?" "errors when source is missing"

# ---------------------------------------------------------------------------
section "nvim: stylua formatting"
if command -v stylua >/dev/null 2>&1; then
    if stylua --check "$DOTFILES_DIR/nvim/init.lua" >/dev/null 2>&1; then pass "init.lua is stylua-clean"
    else fail "init.lua is stylua-clean" "run: stylua nvim/init.lua"; fi
else
    echo -e "  ${DIM}· stylua not installed, skipped${NC}"
fi

# ---------------------------------------------------------------------------
section "tmux: config loads on an isolated server"
if command -v tmux >/dev/null 2>&1; then
    # Temp HOME so no TPM/plugins exist; bootstrap guard skips the resurrect restore.
    TMUX_HOME="$SANDBOX/tmux-home"; mkdir -p "$TMUX_HOME"
    TMUX_SOCK="dotfiles-test-$$"
    TMUX_ERR="$(HOME="$TMUX_HOME" DOTFILES_TMUX_BOOTSTRAP=1 \
        tmux -L "$TMUX_SOCK" -f "$DOTFILES_DIR/tmux/tmux.conf" new-session -d -s t -x 80 -y 24 2>&1)"
    if tmux -L "$TMUX_SOCK" has-session -t t 2>/dev/null; then
        pass "server starts with tmux.conf"
        assert_eq "C-Space" "$(tmux -L "$TMUX_SOCK" show-options -gv prefix)" "prefix is C-Space"
        assert_contains "$(tmux -L "$TMUX_SOCK" show-hooks -g)" "resurrect" "resurrect autosave hooks are set"
        assert_contains "$(tmux -L "$TMUX_SOCK" list-keys -T prefix)" "send-keys C-l" "prefix + C-l clears the screen"
        # Config lines that failed to parse show up as "unknown"/"invalid" errors
        case "$TMUX_ERR" in
            *"unknown"*|*"invalid"*|*"usage"*) fail "tmux.conf has no parse errors" "$TMUX_ERR" ;;
            *) pass "tmux.conf has no parse errors" ;;
        esac
        tmux -L "$TMUX_SOCK" kill-server 2>/dev/null
    else
        fail "server starts with tmux.conf" "$TMUX_ERR"
    fi
else
    echo -e "  ${DIM}· tmux not installed, skipped${NC}"
fi

# ---------------------------------------------------------------------------
echo ""
echo "════════════════════════════════════════"
echo -e "${GREEN}$PASS passed${NC}, $([ "$FAIL" -gt 0 ] && echo -e "${RED}$FAIL failed${NC}" || echo "$FAIL failed")"
[ "$FAIL" -eq 0 ]

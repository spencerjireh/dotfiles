#!/bin/bash

# Dependency-free test suite for the dotfiles install machinery.
#
# Runs in a sandbox (its own temp HOME) and never installs anything or touches
# your real config. Covers: script linting, lib/ helpers, bin/dot dispatch,
# cmd/install.sh's create_symlink / is_selected / components logic (sourced via
# DOTFILES_SOURCE_ONLY), zsh syntax, stylua, tmux boot, and docs drift guards.
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
SCRIPTS=("$DOTFILES_DIR"/bin/dot "$DOTFILES_DIR"/install.sh "$DOTFILES_DIR"/cmd/*.sh "$DOTFILES_DIR"/lib/*.sh "$DOTFILES_DIR"/profiles/*.conf "$DOTFILES_DIR"/tests/run.sh)
for f in "${SCRIPTS[@]}"; do
    if bash -n "$f" 2>/dev/null; then pass "${f#"$DOTFILES_DIR"/} parses"
    else fail "${f#"$DOTFILES_DIR"/} parses"; fi
done
if command -v shellcheck >/dev/null 2>&1; then
    if shellcheck -S warning "${SCRIPTS[@]}" >/dev/null 2>&1
    then pass "shellcheck (no warnings)"
    else fail "shellcheck (no warnings)" "$(shellcheck -S warning "${SCRIPTS[@]}" 2>&1 | grep -E "^In |SC[0-9]+" | head -6)"; fi
else
    echo -e "  ${DIM}· shellcheck not installed, skipped${NC}"
fi
if command -v zsh >/dev/null 2>&1; then
    for f in "$DOTFILES_DIR"/zsh/.zshrc "$DOTFILES_DIR"/zsh/*.zsh; do
        if zsh -n "$f" 2>/dev/null; then pass "${f#"$DOTFILES_DIR"/} parses (zsh -n)"
        else fail "${f#"$DOTFILES_DIR"/} parses (zsh -n)" "$(zsh -n "$f" 2>&1 | head -3)"; fi
    done
else
    echo -e "  ${DIM}· zsh not installed, skipped${NC}"
fi

# ---------------------------------------------------------------------------
section "bin/dot dispatch"
DOT="$DOTFILES_DIR/bin/dot"
OUT="$("$DOT" help 2>&1)"; assert_success "$?" "dot help exits 0"
for sub in install update doctor uninstall keys edit dir help; do
    assert_contains "$OUT" "dot $sub" "dot help mentions '$sub'"
done
OUT="$("$DOT" 2>&1)"; assert_success "$?" "dot with no args exits 0 (help)"
"$DOT" nope >/dev/null 2>&1; assert_failure "$?" "dot <unknown> exits 1"
assert_eq "$DOTFILES_DIR" "$("$DOT" dir)" "dot dir prints the repo root"
"$DOT" keys nope >/dev/null 2>&1; assert_failure "$?" "dot keys <unknown topic> exits 1"
OUT="$("$DOT" keys 2>&1)"; assert_success "$?" "dot keys lists topics"
for t in nvim tmux zsh superfile all; do assert_contains "$OUT" "$t" "dot keys lists '$t'"; done
for t in nvim tmux zsh superfile; do
    if [ -f "$DOTFILES_DIR/docs/$t.md" ]; then pass "docs/$t.md exists"; else fail "docs/$t.md exists"; fi
done
OUT="$("$DOT" keys tmux 2>&1 </dev/null | head -1)"; assert_contains "$OUT" "#" "dot keys tmux prints docs/tmux.md"
OUT="$("$DOT" keys tmux --sheet 2>&1 </dev/null)"; assert_success "$?" "dot keys tmux --sheet exits 0"
assert_contains "$OUT" "Close pane" "dot keys --sheet lists table rows"
assert_contains "$OUT" "Panes" "dot keys --sheet lists section headings"
case "$OUT" in *"prefix + "*) fail "dot keys --sheet drops 'prefix + ' from keys" ;; *) pass "dot keys --sheet drops 'prefix + ' from keys" ;; esac

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
printf '\n'  | tui_confirm "ok?" no; assert_failure "$?" "tui_confirm \"no\" default: empty means no"
printf 'y\n' | tui_confirm "ok?" no; assert_success "$?" "tui_confirm \"no\" default: y still means yes"

# TUI_PRESELECTED: only listed options default to yes
# shellcheck disable=SC2034  # read by the sourced tui_multiselect
TUI_PRESELECTED=$'Alpha'
tui_multiselect SEL "pick" "Alpha" "Beta" <<< $'\n\n' >/dev/null
assert_eq "Alpha" "$(printf '%s' "$SEL" | sed '/^$/d')" "tui_multiselect preselects only TUI_PRESELECTED"
tui_multiselect SEL "pick" "Alpha" "Beta" <<< $'\ny' >/dev/null
assert_contains "$SEL" "Beta" "tui_multiselect: a non-preselected option can still be ticked"
unset TUI_PRESELECTED

tui_choose GOT "which?" "one: first" "two: second" <<< "" >/dev/null
assert_eq "one: first" "$GOT" "tui_choose defaults to the first option"
tui_choose GOT "which?" "one: first" "two: second" <<< "2" >/dev/null
assert_eq "two: second" "$GOT" "tui_choose takes a number"
tui_choose GOT "which?" "one: first" "two: second" <<< "9" >/dev/null
assert_eq "one: first" "$GOT" "tui_choose falls back to the first option when out of range"

# ---------------------------------------------------------------------------
section "cmd/install.sh helpers (sourced)"
export DOTFILES_SOURCE_ONLY=1
# shellcheck source=/dev/null
source "$DOTFILES_DIR/cmd/install.sh"
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

# components state file: save merges + dedupes, load round-trips
COMP_HOME="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-comp.XXXXXX")"
# shellcheck disable=SC2034  # read by the sourced lib/components.sh helpers
COMPONENTS_FILE="$COMP_HOME/dotfiles/components"
SELECTED=$'Neovim config\ntmux + TPM'; components_save
SELECTED=$'tmux + TPM\nZsh + Oh My Zsh\n'; components_save
assert_eq "3" "$(components_load | grep -c .)" "components_save merges runs without duplicates"
SELECTED="$(components_load)"
( is_selected "Neovim config" ); assert_success "$?" "components_load keeps earlier components"
( is_selected "Zsh + Oh My Zsh" ); assert_success "$?" "components_load includes new components"
rm -rf "$COMP_HOME"

# ---------------------------------------------------------------------------
section "lib/profile.sh (profiles, settings, sudo policy)"
assert_contains "$(profile_list)" "default" "profile_list includes default"
assert_contains "$(profile_list)" "work" "profile_list includes work"

for p in $(profile_list); do
    ( profile_load "$p" ) >/dev/null 2>&1; assert_success "$?" "profile $p loads and validates"
done
( profile_load "nope" ) >/dev/null 2>&1; assert_failure "$?" "profile_load rejects an unknown profile"
( profile_load "../work" ) >/dev/null 2>&1; assert_failure "$?" "profile_load rejects a path as a name"
( profile_load "" ) >/dev/null 2>&1; assert_failure "$?" "profile_load rejects an empty name"

profile_load default
assert_eq "allow:Brewfile:1" "$PROFILE_SUDO:$PROFILE_BREWFILE:$PROFILE_BOOTSTRAP_BREW" "default profile keeps the stock behaviour"
assert_eq "" "$PROFILE_EXCLUDE$PROFILE_SETTINGS" "default profile excludes nothing and records no settings"
( brewfile_has rustup ); assert_success "$?" "brewfile_has finds rustup in the default Brewfile"

profile_load work
assert_eq "ask:Brewfile.work:0" "$PROFILE_SUDO:$PROFILE_BREWFILE:$PROFILE_BOOTSTRAP_BREW" "work profile: sudo asks, own Brewfile, no brew bootstrap"
( brewfile_has rustup ); assert_failure "$?" "work Brewfile has no rustup"
( brewfile_has neovim ); assert_success "$?" "work Brewfile has neovim"
( list_has "$PROFILE_EXCLUDE" "Claude Code" ); assert_success "$?" "work profile excludes Claude Code"
( list_has "$PROFILE_EXCLUDE" "Claude" ); assert_failure "$?" "list_has requires an exact match"
FILTERED="$(printf '%s\n' "Neovim config" "Claude Code" "Karabiner (Caps Lock as Esc/Ctrl)" "tmux + TPM" | filter_excluded)"
assert_eq $'Neovim config\ntmux + TPM' "$FILTERED" "filter_excluded drops the profile's excluded components"
# every label a profile names must be a real installer component
KNOWN_LABELS="$(sed -n '/^FEATURES=(/,/^fi/p' "$DOTFILES_DIR/cmd/install.sh" | grep -oE '"[^"$]+"' | tr -d '"')"
bad=""
for p in $(profile_list); do
    profile_load "$p"
    while IFS= read -r label; do
        [ -z "$label" ] && continue
        printf '%s\n' "$KNOWN_LABELS" | grep -qxF "$label" || bad="$bad [$p: $label]"
    done < <(components_from_env "$PROFILE_COMPONENTS,$PROFILE_EXCLUDE")
done
if [ -z "$bad" ]; then pass "profiles only name components the installer knows"
else fail "profiles only name components the installer knows" "unknown:$bad"; fi

# Brewfile.work must not drift: each formula is in Brewfile or is a known work-only one
WORK_ONLY="zsh pyright typescript lua-language-server"
missing=""
while IFS= read -r formula; do
    grep -qE "^brew \"$formula\"" "$DOTFILES_DIR/Brewfile" && continue
    case " $WORK_ONLY " in *" $formula "*) continue ;; esac
    missing="$missing $formula"
done < <(grep -oE '^brew "[^"]+"' "$DOTFILES_DIR/Brewfile.work" | sed 's/^brew "//; s/"$//')
if [ -z "$missing" ]; then pass "Brewfile.work formulae are in Brewfile or the work-only allowlist"
else fail "Brewfile.work formulae are in Brewfile or the work-only allowlist" "unexpected:$missing"; fi

# is_wsl: WSL_DISTRO_NAME is enough; without it the answer comes from the kernel string
( WSL_DISTRO_NAME=Ubuntu is_wsl ); assert_success "$?" "is_wsl is true when WSL_DISTRO_NAME is set"
if ! grep -qi microsoft /proc/version 2>/dev/null; then
    ( unset WSL_DISTRO_NAME; is_wsl ); assert_failure "$?" "is_wsl is false outside WSL"
fi

# profile + settings state files (sandboxed)
PROF_HOME="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-prof.XXXXXX")"
PROFILE_FILE="$PROF_HOME/dotfiles/profile"
SETTINGS_FILE="$PROF_HOME/dotfiles/settings"
assert_eq "" "$(profile_recorded)" "profile_recorded is empty with no record"
profile_load_recorded; assert_eq "default" "$PROFILE_NAME" "profile_load_recorded falls back to default"
profile_load work; profile_save
assert_eq "work" "$(profile_recorded)" "profile_save records the profile"
profile_load default; profile_load_recorded
assert_eq "work" "$PROFILE_NAME" "profile_load_recorded loads the recorded profile"
echo "gone" > "$PROFILE_FILE"; profile_load_recorded
assert_eq "default" "$PROFILE_NAME" "profile_load_recorded survives a profile that no longer exists"

assert_eq "" "$(settings_get DOTFILES_MASON)" "settings_get is empty with no file"
( setting_off DOTFILES_MASON ); assert_failure "$?" "setting_off is false when unset"
profile_load work; settings_apply_profile
assert_eq "0" "$(settings_get DOTFILES_MASON)" "settings_apply_profile records the profile's settings"
assert_eq "kiro" "$(settings_get DOTFILES_AGENT)" "settings_get reads a string value"
( setting_off DOTFILES_MASON ); assert_success "$?" "setting_off is true for 0"
settings_set DOTFILES_MASON 1; settings_set DOTFILES_GLYPHS 0
assert_eq "1" "$(settings_get DOTFILES_MASON)" "settings_set replaces an earlier value"
assert_eq "1" "$(grep -c '^DOTFILES_MASON=' "$SETTINGS_FILE")" "settings_set leaves one line per key"
( settings_set OTHER_KEY 1 ) 2>/dev/null; assert_failure "$?" "settings_set rejects keys outside DOTFILES_"
( settings_set DOTFILES_X '1; rm -rf x' ) 2>/dev/null; assert_failure "$?" "settings_set rejects unsafe values"
if command -v zsh >/dev/null 2>&1; then
    assert_eq "kiro" "$(zsh -c 'source "$1"; print -r -- $DOTFILES_AGENT' _ "$SETTINGS_FILE")" "the settings file is sourceable by zsh"
fi
settings_reset
assert_eq "" "$(settings_get DOTFILES_AGENT)" "settings_reset clears every setting"

# run_sudo: a fake sudo on PATH records whether it was called
mkdir -p "$PROF_HOME/bin"
printf '#!/bin/sh\necho called >> "%s/sudo.log"\n' "$PROF_HOME" > "$PROF_HOME/bin/sudo"
chmod +x "$PROF_HOME/bin/sudo"
OLD_PATH="$PATH"; PATH="$PROF_HOME/bin:$PATH"
sudo_calls() { [ -f "$PROF_HOME/sudo.log" ] && grep -c called "$PROF_HOME/sudo.log" || echo 0; }
PROFILE_SUDO=allow NONINTERACTIVE="" run_sudo "test" true >/dev/null 2>&1
assert_eq "1" "$(sudo_calls)" "run_sudo allow: runs sudo"
PROFILE_SUDO=never NONINTERACTIVE="" run_sudo "test" true >/dev/null 2>&1; assert_failure "$?" "run_sudo never: reports the step as skipped"
assert_eq "1" "$(sudo_calls)" "run_sudo never: sudo is not called"
PROFILE_SUDO=ask NONINTERACTIVE=1 run_sudo "test" true >/dev/null 2>&1; assert_failure "$?" "run_sudo ask, non-interactive: skipped"
assert_eq "1" "$(sudo_calls)" "run_sudo ask, non-interactive: sudo is not called"
PROFILE_SUDO=ask NONINTERACTIVE="" run_sudo "test" true <<< "" >/dev/null 2>&1; assert_failure "$?" "run_sudo ask: empty answer declines"
assert_eq "1" "$(sudo_calls)" "run_sudo ask: declined means sudo is not called"
PROFILE_SUDO=ask NONINTERACTIVE="" run_sudo "test" true <<< "y" >/dev/null 2>&1
assert_eq "2" "$(sudo_calls)" "run_sudo ask: an explicit yes runs sudo"
PATH="$OLD_PATH"

# ~/.bashrc zsh launcher block
BRC="$PROF_HOME/bashrc"
printf 'export KEEP=1\n' > "$BRC"
bashrc_zsh_install /bin/zsh "$BRC"; bashrc_zsh_install /bin/zsh "$BRC"
assert_eq "1" "$(grep -cxF "$BASHRC_ZSH_BEGIN" "$BRC")" "bashrc_zsh_install is idempotent"
assert_contains "$(cat "$BRC")" 'exec "/bin/zsh" -l' "bashrc_zsh_install writes the exec line"
if bash -n "$BRC" 2>/dev/null; then pass "the block is valid bash"; else fail "the block is valid bash"; fi
assert_eq "plain" "$(bash --rcfile "$BRC" -c 'echo plain' 2>&1)" "the block leaves non-interactive bash alone"
bashrc_zsh_remove "$BRC"
assert_eq "export KEEP=1" "$(cat "$BRC")" "bashrc_zsh_remove restores the file exactly"
rm -rf "$PROF_HOME"
profile_load default

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
    if stylua --check "$DOTFILES_DIR/nvim" >/dev/null 2>&1; then pass "nvim/ is stylua-clean"
    else fail "nvim/ is stylua-clean" "run: stylua nvim/"; fi
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
        assert_contains "$(tmux -L "$TMUX_SOCK" list-keys -T prefix)" "dot keys tmux --sheet" "prefix + ? opens the docs/tmux.md cheat sheet via dot keys"
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
section "docs drift: keys, aliases, bindings, components and links are documented"
# nvim: each "<leader>xy" literal in nvim/ must appear as `<Space>xy` in docs/nvim.md
missing=""
while read -r k; do
    grep -qF "\`$k\`" "$DOTFILES_DIR/docs/nvim.md" 2>/dev/null || missing="$missing $k"
done < <(grep -rhoE '"<leader>[^"]+"' "$DOTFILES_DIR/nvim/init.lua" "$DOTFILES_DIR/nvim/lua" 2>/dev/null \
         | tr -d '"' | sed 's/<leader>/<Space>/g' | sort -u)
if [ -z "$missing" ]; then pass "docs/nvim.md documents every <leader> mapping"
else fail "docs/nvim.md documents every <leader> mapping" "missing:$missing"; fi

# zsh: each alias and function name must appear as `name` in docs/zsh.md
missing=""
while read -r n; do
    [ -n "$n" ] || continue
    grep -qF "\`$n\`" "$DOTFILES_DIR/docs/zsh.md" || missing="$missing $n"
done < <({ grep -hoE '^[[:space:]]*alias (-- )?[^=]+=' "$DOTFILES_DIR"/zsh/*.zsh | sed -E 's/^[[:space:]]*alias (-- )?//; s/=$//';
           grep -hoE '^[[:space:]]*(function )?[A-Za-z_][A-Za-z0-9_-]*\(\)' "$DOTFILES_DIR"/zsh/*.zsh | sed -E 's/^[[:space:]]*(function )?//; s/\(\)//'; } | sort -u)
if [ -z "$missing" ]; then pass "docs/zsh.md documents every alias and function"
else fail "docs/zsh.md documents every alias and function" "missing:$missing"; fi

# tmux: each prefix-table bind key must appear as `prefix + KEY` in docs/tmux.md
missing=""
while read -r k; do
    grep -qF "\`prefix + $k\`" "$DOTFILES_DIR/docs/tmux.md" || missing="$missing $k"
done < <(grep -E '^bind( -r)? [^-]' "$DOTFILES_DIR/tmux/tmux.conf" | awk '{ if ($2=="-r") print $3; else print $2 }' | sort -u)
if [ -z "$missing" ]; then pass "docs/tmux.md documents every prefix binding"
else fail "docs/tmux.md documents every prefix binding" "missing:$missing"; fi

# README and docs/install.md: each installer component (FEATURES in cmd/install.sh)
# and each profile must be named.
for doc in README.md docs/install.md; do
    missing=""
    while IFS= read -r c; do
        [ -n "$c" ] || continue
        grep -qF "$c" "$DOTFILES_DIR/$doc" || missing="$missing [$c]"
    done < <(awk '/^FEATURES=\(/ { on = 1; next } on && /^\)/ { on = 0 } on || /FEATURES\+=\(/' "$DOTFILES_DIR/cmd/install.sh" \
             | grep -oE '"[^"]+"' | tr -d '"')
    for f in "$DOTFILES_DIR"/profiles/*.conf; do
        n="$(basename "$f" .conf)"
        grep -qF "\`$n\`" "$DOTFILES_DIR/$doc" || missing="$missing [profile $n]"
    done
    if [ -z "$missing" ]; then pass "$doc names every component and profile"
    else fail "$doc names every component and profile" "missing:$missing"; fi
done

# Relative Markdown links in the docs must point at files that exist.
missing=""
for doc in README.md AGENTS.md docs/*.md; do
    [ -f "$DOTFILES_DIR/$doc" ] || continue
    while IFS= read -r target; do
        target="${target%%#*}"
        [ -n "$target" ] || continue
        case "$target" in http://*|https://*|mailto:*) continue ;; esac
        [ -e "$DOTFILES_DIR/$(dirname "$doc")/$target" ] || missing="$missing $doc:$target"
    done < <(grep -oE '\]\([^)[:space:]]+\)' "$DOTFILES_DIR/$doc" | sed -E 's/^\]\(//; s/\)$//')
done
if [ -z "$missing" ]; then pass "doc links resolve"
else fail "doc links resolve" "missing:$missing"; fi

# CLAUDE.md only imports AGENTS.md, so every agent reads the same file.
if [ -f "$DOTFILES_DIR/AGENTS.md" ] && grep -qx '@AGENTS.md' "$DOTFILES_DIR/CLAUDE.md"; then
    pass "CLAUDE.md imports AGENTS.md"
else fail "CLAUDE.md imports AGENTS.md"; fi

# ---------------------------------------------------------------------------
echo ""
echo "════════════════════════════════════════"
echo -e "${GREEN}$PASS passed${NC}, $([ "$FAIL" -gt 0 ] && echo -e "${RED}$FAIL failed${NC}" || echo "$FAIL failed")"
[ "$FAIL" -eq 0 ]

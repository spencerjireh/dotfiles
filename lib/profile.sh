#!/bin/bash

# Install profiles (variants) and the runtime settings they record.
# Requires lib/log.sh, and $DOTFILES_DIR to be set. run_sudo also needs lib/tui.sh.
#
# Two layers:
#   profile   profiles/<name>.conf, read at install time: which components are
#             offered, which Brewfile, the sudo policy, what settings to record.
#   settings  ~/.config/dotfiles/settings, DOTFILES_KEY=value lines the tracked
#             configs read at runtime (zsh sources it, Neovim parses it, tmux
#             greps it). Configs react to settings, never to the profile name.
#             No file means the default behaviour.

PROFILE_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/profile"
SETTINGS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/settings"

# ---------------------------------------------------------------------------
# Profiles
# ---------------------------------------------------------------------------

# profile_list: print the available profile names, one per line.
profile_list() {
    local f
    for f in "$DOTFILES_DIR"/profiles/*.conf; do
        [ -f "$f" ] && basename "$f" .conf
    done
    return 0
}

# Every key a profile may set, with the value the default profile uses.
# shellcheck disable=SC2034  # read by cmd/*.sh after profile_load
profile_defaults() {
    PROFILE_NAME="default"
    PROFILE_DESC=""
    PROFILE_COMPONENTS=""      # comma list preselected in the installer; empty = all offered
    PROFILE_EXCLUDE=""         # comma list never offered
    PROFILE_BREWFILE="Brewfile"
    PROFILE_SUDO="allow"       # allow | ask | never
    PROFILE_BOOTSTRAP_BREW=1   # 0: Homebrew must already be installed
    PROFILE_LOGIN_SHELL="chsh" # chsh | bashrc (exec zsh from ~/.bashrc, no password)
    PROFILE_GIT_SIGNING=1      # 0: turn off the SSH commit signing git/config enables
    PROFILE_READONLY=0         # 1: update restores nvim/lazy-lock.json instead of syncing
    PROFILE_ASK_GLYPHS=0       # 1: ask whether Nerd Font glyphs render (DOTFILES_GLYPHS)
    PROFILE_SETTINGS=""        # space-separated DOTFILES_KEY=value pairs to record
}

# profile_load <name>: set the PROFILE_* globals from profiles/<name>.conf.
profile_load() {
    local name="${1:-}" file
    case "$name" in
        ''|*[!a-z0-9_-]*)
            log_error "Invalid profile name: '$name'"
            return 1
            ;;
    esac
    file="$DOTFILES_DIR/profiles/$name.conf"
    if [ ! -f "$file" ]; then
        log_error "Unknown profile: $name (available: $(profile_list | tr '\n' ' ' | sed 's/ $//'))"
        return 1
    fi
    profile_defaults
    # shellcheck source=/dev/null
    source "$file"
    PROFILE_NAME="$name"
    case "$PROFILE_SUDO" in
        allow|ask|never) ;;
        *) log_error "Profile $name: PROFILE_SUDO must be allow, ask or never"; return 1 ;;
    esac
    case "$PROFILE_LOGIN_SHELL" in
        chsh|bashrc) ;;
        *) log_error "Profile $name: PROFILE_LOGIN_SHELL must be chsh or bashrc"; return 1 ;;
    esac
    if [ ! -f "$DOTFILES_DIR/$PROFILE_BREWFILE" ]; then
        log_error "Profile $name: $PROFILE_BREWFILE does not exist"
        return 1
    fi
}

# profile_recorded: print the profile this machine was installed with (empty if none).
profile_recorded() {
    [ -f "$PROFILE_FILE" ] && head -n 1 "$PROFILE_FILE"
    return 0
}

# profile_load_recorded: load the recorded profile, or default when there is
# no record or the recorded one no longer exists. Used by doctor and update.
profile_load_recorded() {
    local name
    name="$(profile_recorded)"
    if [ -n "$name" ] && profile_load "$name" 2>/dev/null; then
        return 0
    fi
    profile_load default
}

profile_save() {
    mkdir -p "$(dirname "$PROFILE_FILE")"
    printf '%s\n' "$PROFILE_NAME" > "$PROFILE_FILE"
}

# list_has "<comma list>" "<item>": exact membership, whitespace around items ignored.
list_has() {
    printf '%s\n' "$1" | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -qxF "$2"
}

profile_brewfile() {
    echo "$DOTFILES_DIR/$PROFILE_BREWFILE"
}

# brewfile_has <formula>: is the formula in the active profile's Brewfile?
brewfile_has() {
    grep -qE "^brew \"$1\"" "$(profile_brewfile)"
}

# ---------------------------------------------------------------------------
# Settings
# ---------------------------------------------------------------------------

# settings_get KEY: print the recorded value (empty if unset or no file).
settings_get() {
    [ -f "$SETTINGS_FILE" ] || return 0
    sed -n "s/^$1=//p" "$SETTINGS_FILE" | tail -n 1
}

# settings_set KEY VALUE: record one setting, replacing an earlier value.
# The file is sourced by zsh, so keys and values are restricted to safe characters.
settings_set() {
    local key="$1" value="$2"
    case "$key" in
        DOTFILES_*) ;;
        *) log_error "settings_set: key must start with DOTFILES_: $key"; return 1 ;;
    esac
    case "$key$value" in
        *[!A-Za-z0-9_-]*) log_error "settings_set: unsafe characters in $key=$value"; return 1 ;;
    esac
    mkdir -p "$(dirname "$SETTINGS_FILE")"
    {
        [ -f "$SETTINGS_FILE" ] && grep -v "^$key=" "$SETTINGS_FILE"
        printf '%s=%s\n' "$key" "$value"
    } > "$SETTINGS_FILE.tmp"
    mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
}

# settings_reset: forget every setting (a profile switch starts clean).
settings_reset() {
    rm -f "$SETTINGS_FILE"
}

# setting_off KEY: true when the setting is recorded as 0.
setting_off() {
    [ "$(settings_get "$1")" = "0" ]
}

# settings_apply_profile: record each pair in PROFILE_SETTINGS.
settings_apply_profile() {
    local pair
    for pair in $PROFILE_SETTINGS; do
        settings_set "${pair%%=*}" "${pair#*=}" || return 1
    done
}

# ---------------------------------------------------------------------------
# sudo policy
# ---------------------------------------------------------------------------

# run_sudo "<what it is for>" cmd [args...]: run a command with sudo if the
# profile allows it. Returns 1 (and says so) when the step is skipped.
#   allow  run it
#   ask    confirm first, defaulting to no; skipped in non-interactive runs
#   never  always skipped
run_sudo() {
    local why="$1"; shift
    case "${PROFILE_SUDO:-allow}" in
        allow)
            sudo "$@"
            ;;
        ask)
            if [ -n "${NONINTERACTIVE:-}" ]; then
                log_warn "Skipped (needs sudo, nobody to ask): $why"
                return 1
            fi
            if tui_confirm "Use sudo to $why?" no; then
                sudo "$@"
            else
                log_warn "Skipped (sudo declined): $why"
                return 1
            fi
            ;;
        *)
            log_warn "Skipped (this profile never uses sudo): $why"
            return 1
            ;;
    esac
}

# ---------------------------------------------------------------------------
# Login shell without chsh: a marked block in ~/.bashrc that execs zsh
# ---------------------------------------------------------------------------

BASHRC_ZSH_BEGIN="# >>> dotfiles: start zsh >>>"
BASHRC_ZSH_END="# <<< dotfiles: start zsh <<<"

# bashrc_zsh_remove [file]: delete the block if present.
bashrc_zsh_remove() {
    local file="${1:-$HOME/.bashrc}"
    [ -f "$file" ] || return 0
    grep -qxF "$BASHRC_ZSH_BEGIN" "$file" || return 0
    sed "/^$BASHRC_ZSH_BEGIN\$/,/^$BASHRC_ZSH_END\$/d" "$file" > "$file.dotfiles.tmp"
    cat "$file.dotfiles.tmp" > "$file"   # keep the original file's mode and inode
    rm -f "$file.dotfiles.tmp"
}

# bashrc_zsh_install <zsh path> [file]: (re)write the block. Only interactive
# bash on a terminal hands over to zsh; `bash -c ...` and scripts are untouched,
# and DOTFILES_NO_ZSH=1 bash gives a plain bash when needed.
bashrc_zsh_install() {
    local zsh_path="$1" file="${2:-$HOME/.bashrc}"
    bashrc_zsh_remove "$file"
    cat >> "$file" <<EOF
$BASHRC_ZSH_BEGIN
case \$- in
    *i*)
        if [ -t 1 ] && [ -z "\${BASH_EXECUTION_STRING:-}" ] && [ -z "\${DOTFILES_NO_ZSH:-}" ] && [ -x "$zsh_path" ]; then
            exec "$zsh_path" -l
        fi
        ;;
esac
$BASHRC_ZSH_END
EOF
}

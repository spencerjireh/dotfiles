#!/bin/bash

# Which installer components this machine selected. install.sh records them so
# doctor/update check only what applies. Requires lib/log.sh.

COMPONENTS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/components"

# Membership test against the newline-separated $SELECTED list.
is_selected() {
    printf '%s\n' "${SELECTED:-}" | grep -qxF "$1"
}

# components_save: merge $SELECTED into the state file (sorted, unique) so a
# later partial re-run does not forget components installed earlier.
components_save() {
    mkdir -p "$(dirname "$COMPONENTS_FILE")"
    {
        [ -f "$COMPONENTS_FILE" ] && cat "$COMPONENTS_FILE"
        printf '%s\n' "${SELECTED:-}"
    } | sed '/^[[:space:]]*$/d' | sort -u > "$COMPONENTS_FILE.tmp"
    mv "$COMPONENTS_FILE.tmp" "$COMPONENTS_FILE"
}

# components_load: print the recorded components, one per line (empty if none).
components_load() {
    [ -f "$COMPONENTS_FILE" ] && cat "$COMPONENTS_FILE"
    return 0
}

#!/bin/bash

# dot keys [topic]: keybinding and alias reference, one Markdown file per tool
# in docs/. tmux's prefix + ? popup runs `dot keys tmux`.

set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/log.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/env.sh"
DOTFILES_DIR="${DOTFILES_DIR:-$(dotfiles_dir "${BASH_SOURCE[0]}")}"
DOCS="$DOTFILES_DIR/docs"

TOPICS=(nvim tmux zsh superfile)

list_topics() {
    echo "Usage: dot keys <topic>"
    echo ""
    local t
    for t in "${TOPICS[@]}"; do
        printf '  %-10s %s\n' "$t" "$(sed -n '1s/^# *//p' "$DOCS/$t.md" 2>/dev/null)"
    done
    printf '  %-10s %s\n' "all" "every topic, concatenated"
}

# page <file...>: bat when available (plain style, always paged), else less, else cat.
page() {
    if command -v bat &>/dev/null; then
        bat --style=plain --language=md --paging=always "$@"
    elif command -v less &>/dev/null; then
        cat "$@" | less -R
    else
        cat "$@"
    fi
}

topic="${1:-}"
case "$topic" in
    "")
        list_topics
        ;;
    all)
        files=()
        for t in "${TOPICS[@]}"; do files+=("$DOCS/$t.md"); done
        page "${files[@]}"
        ;;
    *)
        if [ -f "$DOCS/$topic.md" ]; then
            page "$DOCS/$topic.md"
        else
            log_error "Unknown topic: $topic"
            list_topics
            exit 1
        fi
        ;;
esac

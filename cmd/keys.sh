#!/bin/bash

# dot keys [topic] [--sheet]: keybinding and alias reference, one Markdown file
# per tool in docs/. --sheet prints a compact cheat sheet built from the doc's
# two-column tables; tmux's prefix + ? popup runs `dot keys tmux --sheet`.

set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/log.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/env.sh"
DOTFILES_DIR="${DOTFILES_DIR:-$(dotfiles_dir "${BASH_SOURCE[0]}")}"
DOCS="$DOTFILES_DIR/docs"

TOPICS=(nvim tmux zsh superfile)

list_topics() {
    echo "Usage: dot keys <topic> [--sheet]"
    echo ""
    local t
    for t in "${TOPICS[@]}"; do
        printf '  %-10s %s\n' "$t" "$(sed -n '1s/^# *//p' "$DOCS/$t.md" 2>/dev/null)"
    done
    printf '  %-10s %s\n' "all" "every topic, concatenated"
    echo ""
    echo "  --sheet    only the key tables, as a colored cheat sheet"
}

# pager: less with colors when stdout is a terminal, else pass through.
pager() {
    if [ -t 1 ] && command -v less &>/dev/null; then less -R; else cat; fi
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

# sheet <note> <file...>: cheat sheet from the docs. Keeps the H1, the ##
# headings and the rows of two-column tables (action | keys); skips prose and
# wider comparison tables. "prefix + " is dropped from keys (the note says it
# once), text in parentheses is dimmed. Colors are the Vesper palette from
# ghostty/config. Lays out two columns when the terminal is wide enough.
sheet() {
    local note="$1"; shift
    local cols
    cols="${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}"
    cat "$@" | awk -v cols="$cols" -v note="$note" '
    BEGIN {
        ORANGE = "\033[38;2;255;199;153m"; WHITE = "\033[38;2;255;255;255m"
        GREY = "\033[38;2;160;160;160m";   DIM = "\033[38;2;80;80;80m"
        BOLD = "\033[1m"; RST = "\033[0m"
        nrows = 0; intable = 0
    }
    function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
    function add(plain, colored, hdr) {
        n++; P[n] = plain; C[n] = colored; H[n] = hdr
        if (length(plain) > maxw) maxw = length(plain)
    }
    /^# / { if (!title) title = substr($0, 3); next }
    /^## / { section = substr($0, 4); intable = 0; next }
    /^\|/ {
        line = $0; gsub(/\\\|/, "\001", line)
        ncell = split(line, cell, "|") - 2
        if (!intable) { intable = 1; header = 1; skip = (ncell != 2); next }
        if (header) { header = 0; next }
        if (skip) next
        nrows++
        a = trim(cell[2]); k = trim(cell[3])
        gsub("\001", "|", a); gsub("\001", "|", k)
        gsub(/`/, "", a); gsub(/`/, "", k)
        gsub(/prefix \+ /, "", k)
        A[nrows] = a; K[nrows] = k; S[nrows] = section
        if (length(k) > kw[section]) kw[section] = length(k)
        next
    }
    { intable = 0 }
    END {
        n = 0; maxw = 0; cur = ""
        for (i = 1; i <= nrows; i++) {
            if (S[i] != cur) {
                if (n) add("", "", 0)
                add(S[i], BOLD ORANGE S[i] RST, 1); cur = S[i]
            }
            k = sprintf("%-" kw[S[i]] "s", K[i]); a = A[i]
            kc = k; gsub(/\([^)]*\)/, DIM "&" WHITE, kc)
            ac = a; gsub(/\([^)]*\)/, DIM "&" GREY, ac)
            add("  " k "  " a, "  " WHITE kc "  " GREY ac RST, 0)
        }
        printf "%s%s%s", BOLD, title, RST
        if (note != "") printf "  %s%s%s", DIM, note, RST
        printf "\n\n"
        gap = 4
        if (cols >= 2 * maxw + gap && n > 16) {
            best = 0; bd = n
            for (i = 2; i <= n; i++) if (H[i]) { d = (i - 1) - (n - i + 1); if (d < 0) d = -d; if (d < bd) { bd = d; best = i } }
            left = best - 2                     # drop the blank line before the split
            right = n - best + 1
            rows = left > right ? left : right
            for (r = 1; r <= rows; r++) {
                l = r; j = best + r - 1
                if (l <= left) printf "%s%" (maxw + gap - length(P[l])) "s", C[l], ""
                else printf "%" (maxw + gap) "s", ""
                if (j <= n) printf "%s", C[j]
                printf "\n"
            }
        } else {
            for (i = 1; i <= n; i++) print C[i]
        }
    }'
}

SHEET=0
topic=""
for arg in "$@"; do
    case "$arg" in
        -s|--sheet) SHEET=1 ;;
        *) topic="$arg" ;;
    esac
done

files=()
case "$topic" in
    "")
        list_topics
        exit 0
        ;;
    all)
        for t in "${TOPICS[@]}"; do files+=("$DOCS/$t.md"); done
        ;;
    *)
        if [ -f "$DOCS/$topic.md" ]; then
            files=("$DOCS/$topic.md")
        else
            log_error "Unknown topic: $topic"
            list_topics
            exit 1
        fi
        ;;
esac

if [ "$SHEET" = 1 ]; then
    note=""
    [ "$topic" = tmux ] && note="keys follow the prefix, C-Space, unless marked"
    sheet "$note" "${files[@]}" | pager
else
    page "${files[@]}"
fi

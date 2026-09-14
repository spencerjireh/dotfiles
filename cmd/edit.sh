#!/bin/bash

# dot edit [query]: pick a tracked file in the repo with fzf and open it in
# $EDITOR. Without fzf, a query that matches exactly one file opens it.

set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/log.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/env.sh"
DOTFILES_DIR="${DOTFILES_DIR:-$(dotfiles_dir "${BASH_SOURCE[0]}")}"

query="${*:-}"
cd "$DOTFILES_DIR" || exit 1

if command -v fzf &>/dev/null; then
    preview='cat {}'
    command -v bat &>/dev/null && preview='bat --color=always --style=numbers {}'
    file="$(git ls-files | fzf --query "$query" --select-1 --exit-0 \
        --height=80% --reverse --preview "$preview" --preview-window=right:60%)"
else
    matches="$(git ls-files | grep -F -- "$query")"
    count="$(printf '%s\n' "$matches" | grep -c .)"
    if [ "$count" -eq 1 ]; then
        file="$matches"
    else
        log_warn "fzf not installed; ${count} file(s) match '$query':"
        printf '%s\n' "$matches"
        exit 1
    fi
fi

[ -n "${file:-}" ] || exit 0
exec "${EDITOR:-nvim}" "$file"

#!/bin/bash

# Shared environment helpers. Requires lib/log.sh to be sourced first.

# dotfiles_dir <path-to-script>: print the repo root, resolving symlinks
# (the scripts are invoked through ~/.local/bin/dot, a symlink into the repo).
dotfiles_dir() {
    local source="$1" dir
    while [ -L "$source" ]; do
        dir="$(cd -P "$(dirname "$source")" && pwd)"
        source="$(readlink "$source")"
        [[ "$source" != /* ]] && source="$dir/$source"
    done
    dir="$(cd -P "$(dirname "$source")" && pwd)"
    # scripts live one level below the root (bin/, cmd/); tests/ too
    case "$(basename "$dir")" in
        bin|cmd|tests|lib) dirname "$dir" ;;
        *) echo "$dir" ;;
    esac
}

# Make `brew` available in this shell session regardless of platform/arch.
load_brew_env() {
    if command -v brew &>/dev/null; then
        :
    elif [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
}

# rustup is keg-only in Homebrew (it conflicts with the `rust` formula), so its
# bin dir and the cargo proxies are not on a bare PATH.
load_rust_env() {
    local prefix
    if command -v brew &>/dev/null; then
        prefix="$(brew --prefix)"
        [ -d "$prefix/opt/rustup/bin" ] && export PATH="$prefix/opt/rustup/bin:$PATH"
    fi
    [ -d "$HOME/.cargo/bin" ] && export PATH="$HOME/.cargo/bin:$PATH"
    return 0
}

# Everything a subcommand needs on PATH, in one call.
load_env() {
    load_brew_env
    load_rust_env
    export PATH="$HOME/.local/bin:$PATH"
}

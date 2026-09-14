#!/bin/bash

# Shared tmux/TPM helper. Requires lib/log.sh to be sourced first.
#
# TPM's bin scripts shell out to `tmux start-server \; show-environment ...`,
# which races on a session-less server (tpm's run-shell has not set
# TMUX_PLUGIN_MANAGER_PATH yet). Keeping a throwaway detached session alive
# for the duration makes them reliable from a plain shell.
tpm_run() { # <tpm bin script name> [args...]
    local script="$HOME/.tmux/plugins/tpm/bin/$1"
    shift
    if [ ! -x "$script" ]; then
        log_warn "TPM not installed (missing $script)"
        return 1
    fi
    local started=0 rc=0
    if ! tmux has-session 2>/dev/null; then
        # DOTFILES_TMUX_BOOTSTRAP is inherited by the new server; tmux.conf's
        # resurrect hooks and auto-restore check it so this throwaway server
        # neither restores old sessions nor overwrites the last saved layout.
        if ! DOTFILES_TMUX_BOOTSTRAP=1 tmux new-session -d -s _dotfiles_tpm -x 200 -y 50; then
            log_warn "Could not start a tmux server for TPM"
            return 1
        fi
        started=1
        # wait for tpm (run at the end of tmux.conf) to publish its path
        for _ in 1 2 3 4 5 6 7 8 9 10; do
            tmux show-environment -g TMUX_PLUGIN_MANAGER_PATH >/dev/null 2>&1 && break
            sleep 0.2
        done
    fi
    "$script" "$@" || rc=$?
    [ "$started" = 1 ] && tmux kill-session -t _dotfiles_tpm 2>/dev/null
    return "$rc"
}

# tmux-thumbs ships as Rust source and normally builds itself through an
# interactive prompt on first use. Build it here instead so prefix + t works
# straight away. Re-run after plugin updates (the binary must match the source).
tmux_thumbs_build() {
    local dir="$HOME/.tmux/plugins/tmux-thumbs"
    [ -f "$dir/Cargo.toml" ] || return 0
    if ! command -v cargo &>/dev/null; then
        log_warn "cargo not found; tmux-thumbs binary not built (brew bundle installs rust)"
        return 1
    fi
    log_info "Building tmux-thumbs..."
    if (cd "$dir" && cargo build --release --quiet); then
        log_info "Built tmux-thumbs"
    else
        log_warn "tmux-thumbs build failed"
        return 1
    fi
}

# Aliases and the rm-to-trash wrapper. Needs PATH from 20-path.zsh because
# several aliases exist only when the brew tool (eza, bat, trash) is present.
# Documented in docs/zsh.md (`dot keys zsh`).

# Dotfiles (see `dot help`)
alias dotup='dot update'
alias dotdoctor='dot doctor'

# Configuration shortcuts
alias zshconfig="dot edit zsh/"
alias nvimconfig="dot edit nvim/"
alias tmuxconfig="dot edit tmux/"
alias p10kconfig="nvim ~/.p10k.zsh"
alias src="source ~/.zshrc"

# nvim
alias vim='nvim'
alias vi='nvim'
alias v='nvim'

# vibe coding
alias opc="opencode"
alias cld="claude"
alias ccd="claude --dangerously-skip-permissions"

if command -v trash &>/dev/null; then
  unalias rm 2>/dev/null
  # rm sends to the trash; -r/-f/-d flags are dropped (trash is always recursive
  # and never prompts). -i keeps real rm so interactive deletes still prompt.
  function rm() {
    local args=() arg
    for arg in "$@"; do
      if [[ "$arg" == -i || "$arg" == --interactive* || "$arg" =~ ^-[a-zA-Z]*i[a-zA-Z]*$ ]]; then
        command rm "$@"
        return
      fi
    done
    for arg in "$@"; do
      [[ "$arg" =~ ^-[rRfdiPWv]+$ ]] && continue
      [[ "$arg" == --recursive || "$arg" == --force ]] && continue
      args+=("$arg")
    done
    (( ${#args[@]} )) && command trash "${args[@]}"
  }
fi

# tmux
alias tm="tmux attach || tmux new"
alias tls="tmux list-sessions"
alias tks="tmux kill-session -t"

# Navigation shortcuts
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias -- -="cd -"

# Enhanced ls commands (use eza if available)
if command -v eza &>/dev/null; then
  alias ls="eza"
  alias ll="eza -lah --git --icons=always"
  alias la="eza -a"
  alias lt="eza --tree --level=2"
else
  alias ll="ls -lah"
  alias la="ls -A"
  alias l="ls -CF"
fi

# Use bat for cat if available
if command -v bat &>/dev/null; then
  alias cat="bat --paging=never"
  alias catp="bat"  # With paging
fi

# Common shortcuts
alias cls="clear"
alias h="history"

# Git shortcuts come from the Oh My Zsh git plugin: gst, ga, gaa, gc, gcmsg,
# gp, gl (pull), glog, gd, gco, gb. See `alias | grep "^g"`.

# Python (uv manages interpreters and venvs; python3 is the system one)
alias py="python3"

# Docker shortcuts
alias dps="docker ps"
alias dpsa="docker ps -a"
alias dimg="docker images"
alias dex="docker exec -it"
alias dlog="docker logs -f"
alias dprune="docker system prune -af"
if [[ "$(uname -s)" == "Darwin" ]]; then
  alias docker-desktop="open /Applications/Docker.app"
  alias empty-trash="osascript -e 'tell application \"Finder\" to empty the trash'"
fi

# Network
alias myip="curl -s ifconfig.me"
alias localip="ipconfig getifaddr en0 2>/dev/null || hostname -I | awk '{print \$1}'"

# Shell functions: fzf helpers and small utilities. Every function carries a
# `# desc:` line; docs/zsh.md (`dot keys zsh`) lists them.

# ===========================
# FZF-Powered Functions
# ===========================

if command -v fzf &>/dev/null; then
  # desc: interactive git branch checkout
  fbr() {
    local branches branch
    branches=$(git branch --all | grep -v HEAD) &&
    branch=$(echo "$branches" | fzf --height=40% --reverse) &&
    git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
  }

  # desc: interactive git log browser with commit preview
  flog() {
    git log --oneline --color=always | fzf --ansi --preview 'git show --color=always {1}' --preview-window=right:60%
  }

  # desc: pick a process and kill it (TERM, then KILL if it survives)
  fkill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf --height=40% --reverse | awk '{print $2}')
    if [[ -n "$pid" ]]; then
      echo "Killing process $pid..."
      kill "$pid" 2>/dev/null
      sleep 1
      kill -0 "$pid" 2>/dev/null && kill -9 "$pid"
    fi
  }

  # desc: find a file (fd, or find) and open it in $EDITOR
  fe() {
    local file
    if command -v fd &>/dev/null; then
      file=$(fd --type f --hidden --exclude .git . "${1:-.}" 2>/dev/null | fzf --height=40% --reverse --preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {}')
    else
      file=$(find "${1:-.}" -type f 2>/dev/null | fzf --height=40% --reverse --preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {}')
    fi
    [[ -n "$file" ]] && $EDITOR "$file"
  }

  # Search file contents with ripgrep and fzf
  if command -v rg &>/dev/null; then
    # desc: grep file contents with ripgrep and open the match in $EDITOR
    frg() {
      local file line
      read -r file line <<< $(rg --line-number --no-heading . 2>/dev/null | fzf --delimiter=: --preview 'bat --style=numbers --color=always --highlight-line {2} {1} 2>/dev/null' | awk -F: '{print $1, $2}')
      if [[ -n "$file" ]]; then
        $EDITOR "$file" +$line
      fi
    }
  fi

  # desc: pick a docker container, then logs/exec/stop/remove/inspect it
  fdock() {
    local container
    container=$(docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Image}}" | tail -n +2 | fzf --height=40% --reverse | awk '{print $1}')
    if [[ -n "$container" ]]; then
      echo "Selected: $container"
      echo "Actions: [l]ogs, [e]xec, [s]top, [r]emove, [i]nspect"
      read -r "action?Action: "
      case "$action" in
        l) docker logs -f "$container" ;;
        e) docker exec -it "$container" /bin/sh ;;
        s) docker stop "$container" ;;
        r) docker rm "$container" ;;
        i) docker inspect "$container" | less ;;
        *) echo "Unknown action" ;;
      esac
    fi
  }
fi

# ===========================
# Custom Functions
# ===========================

# desc: create a directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# desc: superfile with cd-on-quit (shell follows the last directory opened)
# The shell can't inherit a cwd from a child process, so superfile writes its
# last directory to a file we source here.
spf() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    export SPF_LAST_DIR="$HOME/Library/Application Support/superfile/lastdir"
  else
    export SPF_LAST_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/superfile/lastdir"
  fi
  command spf "$@"
  [ ! -f "$SPF_LAST_DIR" ] || {
    . "$SPF_LAST_DIR"
    # command rm: bypass the rm-to-trash function above for this state file
    command rm -f -- "$SPF_LAST_DIR" >/dev/null
  }
}

# desc: copy a file to <file>.backup-<timestamp>
backup() {
  cp "$1" "$1.backup-$(date +%Y%m%d-%H%M%S)"
}

# desc: find files by name substring under the current directory
f() {
  if command -v fd &>/dev/null; then
    fd --hidden --exclude .git "$1" 2>/dev/null
  else
    find . -name "*$1*" 2>/dev/null
  fi
}

# desc: show what is listening on a port
port() {
  lsof -i :"$1"
}

# desc: kill whatever listens on a port (TERM, then KILL if it survives)
killport() {
  local pids
  pids=$(lsof -ti :"$1" 2>/dev/null)
  if [[ -z "$pids" ]]; then
    echo "No process on port $1"
    return 1
  fi
  echo "$pids" | xargs kill 2>/dev/null
  sleep 1
  local pid
  for pid in ${(f)pids}; do
    kill -0 "$pid" 2>/dev/null && kill -9 "$pid" 2>/dev/null
  done
  echo "Killed process on port $1"
}

# desc: serve the current directory over HTTP (default port 8000)
serve() {
  local port="${1:-8000}"
  echo "Serving on http://localhost:$port"
  python3 -m http.server "$port"
}

# desc: extract any archive by extension (tar, zip, 7z, rar, xz, zst, ...)
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.tar.xz)    tar xJf "$1"     ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unrar x "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *.xz)        unxz "$1"        ;;
      *.zst)       unzstd "$1"      ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# desc: create a directory, cd into it, and git init
proj() {
  mkdir -p "$1" && cd "$1" && git init
}

# desc: open ~/notes/<name>.md in $EDITOR, or list notes with no argument
note() {
  local note_dir="$HOME/notes"
  mkdir -p "$note_dir"
  if [ -z "$1" ]; then
    ls -la "$note_dir"
  else
    $EDITOR "$note_dir/$1.md"
  fi
}

# desc: weather report from wttr.in (optional location argument)
weather() {
  curl -s "wttr.in/${1:-}"
}

# desc: cheat.sh lookup for a command or topic
cheat() {
  curl -s "cheat.sh/$1"
}

# desc: open a project directory as a tmux session (fzf over $DOTFILES_PROJECT_DIRS, default ~/Projects)
fproj() {
  # $1 seeds the fzf query. DOTFILES_PROJECT_DIRS is colon-separated (~/.zshrc.local).
  # tmux's prefix + o runs this in a popup (sources only this file, see tmux.conf).
  local dirs dir name
  dirs=("${(s/:/)${DOTFILES_PROJECT_DIRS:-$HOME/Projects}}")
  if command -v fd &>/dev/null; then
    dir=$(fd --type d --max-depth 1 --min-depth 1 . "${dirs[@]}" 2>/dev/null \
      | fzf --reverse --query="${1:-}" --select-1 --exit-0)
  else
    dir=$(find "${dirs[@]}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null \
      | fzf --reverse --query="${1:-}" --select-1 --exit-0)
  fi
  [[ -n "$dir" ]] || return 0
  dir="${dir%/}"
  name="${${dir:t}//./_}"
  tmux has-session -t "=$name" 2>/dev/null || tmux new-session -ds "$name" -c "$dir"
  if [[ -n "$TMUX" ]]; then
    tmux switch-client -t "=$name"
  else
    tmux attach -t "=$name"
  fi
}

# ===========================
# Startup Time Profiler
# ===========================

# desc: start an interactive zsh with zprof enabled and print the startup report
zsh_profile() {
  ZPROF=true zsh -i -c exit
}

# desc: time ten interactive shell startups (optional shell argument)
timezsh() {
  shell=${1-$SHELL}
  for i in $(seq 1 10); do /usr/bin/time $shell -i -c exit; done
}

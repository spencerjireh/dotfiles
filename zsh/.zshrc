# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ===========================
# Startup Profiler (optional)
# ===========================
# Uncomment the next line to enable startup profiling
# zmodload zsh/zprof

# ===========================
# Oh My Zsh Configuration
# ===========================
export ZSH="$HOME/.oh-my-zsh"

# Using Powerlevel10k for a modern, informative prompt
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins (syntax-highlighting must be last)
plugins=(
  git
  docker
  docker-compose
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Compile completion dump for faster loading
if [[ -s "$ZSH_COMPDUMP" && (! -s "${ZSH_COMPDUMP}.zwc" || "$ZSH_COMPDUMP" -nt "${ZSH_COMPDUMP}.zwc") ]]; then
  zcompile "$ZSH_COMPDUMP"
fi

# ===========================
# History Configuration
# ===========================
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY       # Add timestamps to history
setopt HIST_IGNORE_DUPS       # Don't record duplicate commands
setopt HIST_FIND_NO_DUPS      # Don't show duplicates when searching
setopt HIST_IGNORE_SPACE      # Don't save commands starting with space
setopt HIST_VERIFY            # Show command before executing from history
setopt INC_APPEND_HISTORY     # Write immediately, not on exit
setopt SHARE_HISTORY          # Share history between sessions

# ===========================
# Directory Navigation
# ===========================
setopt AUTO_CD                # Type directory name to cd
setopt AUTO_PUSHD             # Push dirs to stack automatically
setopt PUSHD_IGNORE_DUPS      # No duplicates in dir stack
setopt PUSHD_SILENT           # Don't print dir stack after pushd/popd
DIRSTACKSIZE=10

# ===========================
# Vim Mode (Toggleable)
# ===========================
bindkey -v
export KEYTIMEOUT=1
ZSH_VIM_MODE=1

vim-mode() {
  if [[ $ZSH_VIM_MODE -eq 1 ]]; then
    bindkey -e
    ZSH_VIM_MODE=0
    typeset -g POWERLEVEL9K_VI_INSERT_MODE_STRING=''
    typeset -g POWERLEVEL9K_VI_COMMAND_MODE_STRING=''
    p10k reload
    echo "Switched to Emacs mode"
  else
    bindkey -v
    export KEYTIMEOUT=1
    ZSH_VIM_MODE=1
    typeset -g POWERLEVEL9K_VI_INSERT_MODE_STRING='INSERT'
    typeset -g POWERLEVEL9K_VI_COMMAND_MODE_STRING='NORMAL'
    p10k reload
    echo "Switched to Vim mode"
  fi
}

# Cursor shape indicator for vim mode
# function zle-keymap-select {
#   if [[ $KEYMAP == vicmd ]]; then
#     echo -ne '\e[2 q'  # Block cursor
#   else
#     echo -ne '\e[6 q'  # Beam cursor
#   fi
# }
# zle -N zle-keymap-select

# function zle-line-init {
#   echo -ne '\e[6 q'
# }
# zle -N zle-line-init

# ===========================
# Completion System
# ===========================
# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

# Partial completion suggestions
zstyle ':completion:*' list-suffixes true
zstyle ':completion:*' expand prefix suffix

# Fuzzy matching for mistyped completions
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 2 numeric

# Better completion menu
zstyle ':completion:*' menu select
zstyle ':completion:*' select-prompt '%SScrolling: %p%s'

# Group completions by type
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:corrections' format '%F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:messages' format '%F{purple}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'

# Better directory completion
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' squeeze-slashes true

# Color completion for files
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Cache completions for faster load
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.zsh/cache"

# ===========================
# Environment Variables
# ===========================
export LANG=en_US.UTF-8
export EDITOR='vim'

# Colored man pages - inherits from terminal theme
export LESS_TERMCAP_md=$'\e[1;36m'    # cyan for bold text
export LESS_TERMCAP_me=$'\e[0m'       # reset
export LESS_TERMCAP_us=$'\e[1;32m'    # green for underlined text
export LESS_TERMCAP_ue=$'\e[0m'       # reset

# ===========================
# Delta (better diffs)
# ===========================
if command -v delta &>/dev/null; then
  export GIT_PAGER='delta'
  export DELTA_PAGER='less -R'
fi

# ===========================
# Path Configuration
# ===========================
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# ===========================
# Pyenv (Lazy Loading)
# ===========================
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# Lazy load pyenv for faster shell startup
if command -v pyenv &>/dev/null; then
  pyenv() {
    unfunction pyenv
    eval "$(command pyenv init --path)"
    eval "$(command pyenv init -)"
    pyenv "$@"
  }
fi

# ===========================
# Syntax Highlighting Colors
# ===========================
# Customize zsh-syntax-highlighting to inherit from Ghostty Vesper theme
ZSH_HIGHLIGHT_STYLES[default]='fg=7'                      # white - default text
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=1'                # red - invalid commands
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=3'                # yellow - reserved words (if, then, etc)
ZSH_HIGHLIGHT_STYLES[alias]='fg=6'                        # cyan - aliases
ZSH_HIGHLIGHT_STYLES[builtin]='fg=6'                      # cyan - shell builtins
ZSH_HIGHLIGHT_STYLES[function]='fg=6'                     # cyan - functions
ZSH_HIGHLIGHT_STYLES[command]='fg=2'                      # green - valid commands
ZSH_HIGHLIGHT_STYLES[precommand]='fg=2,underline'         # green underlined - precommands (sudo, etc)
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=5'             # magenta - separators (|, &&, etc)
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=2'               # green - hashed commands
ZSH_HIGHLIGHT_STYLES[path]='fg=4'                         # blue - paths
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=4'           # blue - path separators
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=4,underline'        # blue underlined - path prefix
ZSH_HIGHLIGHT_STYLES[path_approx]='fg=4,underline'        # blue underlined - approximate paths
ZSH_HIGHLIGHT_STYLES[globbing]='fg=4'                     # blue - glob patterns
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=4'            # blue - history expansion
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=3'         # yellow - short options (-h)
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=3'         # yellow - long options (--help)
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=5'         # magenta - backticks
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=3'       # yellow - single quotes
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=3'       # yellow - double quotes
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=6' # cyan - variables in quotes
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=6'  # cyan - escaped chars in quotes
ZSH_HIGHLIGHT_STYLES[assign]='fg=5'                       # magenta - variable assignments
ZSH_HIGHLIGHT_STYLES[redirection]='fg=5'                  # magenta - redirections (>, <, etc)
ZSH_HIGHLIGHT_STYLES[comment]='fg=8'                      # grey - comments
ZSH_HIGHLIGHT_STYLES[arg0]='fg=2'                         # green - command name

# ===========================
# Tool Initialization
# ===========================
# Initialize zoxide (better cd)
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

# ===========================
# FZF Configuration
# ===========================
if command -v fzf &>/dev/null; then
  # FZF appearance - inherits from Ghostty Vesper theme
  export FZF_DEFAULT_OPTS="
    --height=40%
    --layout=reverse
    --border=rounded
    --info=inline
    --margin=1
    --padding=1
    --color=bg+:0,bg:-1,spinner:5,hl:1
    --color=fg:7,header:1,info:5,pointer:5
    --color=marker:5,fg+:7,prompt:5,hl+:1
    --prompt='> '
    --pointer='>'
    --marker='*'
  "

  # Use fd if available (faster than find)
  if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  fi
fi

# ===========================
# Aliases
# ===========================

# Configuration shortcuts
alias zshconfig="code ~/.zshrc"
alias src="source ~/.zshrc"
alias p10kconfig="code ~/.p10k.zsh"

# nvim
alias vim='nvim'
alias vi='nvim'
alias v='nvim'

# vibe coding
alias opc="opencode"
alias cld="claude"

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
alias hg="history | grep"

# Git shortcuts (complementing Oh My Zsh git plugin)
alias gs="git status"
alias ga="git add"
alias gaa="git add --all"
alias gc="git commit"
alias gcm="git commit -m"
alias gp="git push"
alias gpl="git pull"
alias gl="git log --oneline --graph --decorate"
alias gd="git diff"
alias gco="git checkout"
alias gb="git branch"

# Python shortcuts
alias py="python"
alias pip="python -m pip"
alias venv="python -m venv"
alias activate="source .venv/bin/activate"



# Docker shortcuts
alias dps="docker ps"
alias dpsa="docker ps -a"
alias dimg="docker images"
alias dex="docker exec -it"
alias dlog="docker logs -f"
alias dprune="docker system prune -af"
alias docker-desktop="open /Applications/Docker.app"

# Network
alias myip="curl -s ifconfig.me"
alias localip="ipconfig getifaddr en0 2>/dev/null || hostname -I | awk '{print \$1}'"

# ===========================
# FZF-Powered Functions
# ===========================

if command -v fzf &>/dev/null; then
  # Interactive git branch checkout
  fbr() {
    local branches branch
    branches=$(git branch --all | grep -v HEAD) &&
    branch=$(echo "$branches" | fzf --height=40% --reverse) &&
    git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
  }

  # Interactive git log browser
  flog() {
    git log --oneline --color=always | fzf --ansi --preview 'git show --color=always {1}' --preview-window=right:60%
  }

  # Interactive process killer
  fkill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf --height=40% --reverse | awk '{print $2}')
    if [[ -n "$pid" ]]; then
      echo "Killing process $pid..."
      kill -9 "$pid"
    fi
  }

  # Interactive directory navigation
  fcd() {
    local dir
    dir=$(find ${1:-.} -type d 2>/dev/null | fzf --height=40% --reverse --preview 'eza --tree --level=1 {} 2>/dev/null || ls -la {}') &&
    cd "$dir"
  }

  # Interactive file finder
  ff() {
    local file
    file=$(find ${1:-.} -type f 2>/dev/null | fzf --height=40% --reverse --preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {}') &&
    echo "$file"
  }

  # Interactive file finder and open in editor
  fe() {
    local file
    file=$(find ${1:-.} -type f 2>/dev/null | fzf --height=40% --reverse --preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {}') &&
    [[ -n "$file" ]] && $EDITOR "$file"
  }

  # Interactive history search
  fh() {
    local cmd
    cmd=$(history | sort -rn | awk '{$1=""; print substr($0,2)}' | fzf --height=40% --reverse)
    if [[ -n "$cmd" ]]; then
      print -z "$cmd"
    fi
  }

  # Search file contents with ripgrep and fzf
  if command -v rg &>/dev/null; then
    frg() {
      local file line
      read -r file line <<< $(rg --line-number --no-heading . 2>/dev/null | fzf --delimiter=: --preview 'bat --style=numbers --color=always --highlight-line {2} {1} 2>/dev/null' | awk -F: '{print $1, $2}')
      if [[ -n "$file" ]]; then
        $EDITOR "$file" +$line
      fi
    }
  fi

  # Interactive docker container management
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

# Create directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Quick backup of a file
backup() {
  cp "$1" "$1.backup-$(date +%Y%m%d-%H%M%S)"
}

# Quick find by name
f() {
  find . -name "*$1*" 2>/dev/null
}

# Check what's running on a port
port() {
  lsof -i :"$1"
}

# Kill process on port
killport() {
  lsof -ti :"$1" | xargs kill -9 2>/dev/null && echo "Killed process on port $1" || echo "No process on port $1"
}

# Quick server (Python HTTP)
serve() {
  local port="${1:-8000}"
  echo "Serving on http://localhost:$port"
  python -m http.server "$port"
}

# Extract any archive type
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

# Create a new directory and enter it (with git init option)
proj() {
  mkdir -p "$1" && cd "$1" && git init
}

# Quick notes
note() {
  local note_dir="$HOME/notes"
  mkdir -p "$note_dir"
  if [ -z "$1" ]; then
    ls -la "$note_dir"
  else
    $EDITOR "$note_dir/$1.md"
  fi
}

# Weather
weather() {
  curl -s "wttr.in/${1:-}"
}

# Cheatsheet
cheat() {
  curl -s "cheat.sh/$1"
}

# ===========================
# Startup Time Profiler
# ===========================
# Run 'zsh_profile' to see what's slowing down your shell
zsh_profile() {
  ZPROF=true zsh -i -c exit
}

# Function to time shell startup
timezsh() {
  shell=${1-$SHELL}
  for i in $(seq 1 10); do /usr/bin/time $shell -i -c exit; done
}


# ===========================
# Powerlevel10k Configuration
# ===========================
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ===========================
# End Profiler (if enabled)
# ===========================
# Uncomment the next line if you uncommented zmodload zsh/zprof at the top
# [[ -n "$ZPROF" ]] && zprof

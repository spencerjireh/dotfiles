# Shell options: history, directory navigation, vi mode, completion, and
# environment variables. No PATH changes and no tool init (see 20-, 30-).

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
setopt SHARE_HISTORY          # Share history between sessions (implies incremental append)

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

# desc: toggle the line editor between vi and emacs keymaps
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
function zle-keymap-select {
  if [[ $KEYMAP == vicmd ]]; then
    echo -ne '\e[2 q'  # Block cursor
  else
    echo -ne '\e[6 q'  # Beam cursor
  fi
}
zle -N zle-keymap-select

function zle-line-init {
  echo -ne '\e[6 q'
}
zle -N zle-line-init

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
export EDITOR='nvim'

# Colored man pages - inherits from terminal theme
export LESS_TERMCAP_md=$'\e[1;36m'    # cyan for bold text
export LESS_TERMCAP_me=$'\e[0m'       # reset
export LESS_TERMCAP_us=$'\e[1;32m'    # green for underlined text
export LESS_TERMCAP_ue=$'\e[0m'       # reset

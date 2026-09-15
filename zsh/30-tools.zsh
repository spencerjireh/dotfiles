# Tool initialization and theming: syntax-highlighting colors, Ghostty shell
# integration, zoxide, fzf, delta. Needs PATH from 20-path.zsh.

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
# Ghostty shell integration
# ===========================
# Prompt marks, sudo, title. Ghostty injects this only into the first shell.
# Not sourced inside tmux: Ghostty 1.3's script inserts OSC 133 marks after
# every newline in PS1, which splits the ${...} expressions in the p10k prompt
# and prints a literal ":-" and "}}" on the first prompt of each new pane.
# tmux does not forward the marks anyway, and cursor shape is set in
# 10-options.zsh. See https://github.com/ghostty-org/ghostty/discussions/11407
if [[ -z "$TMUX" && -n "$GHOSTTY_RESOURCES_DIR" && -r "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration" ]]; then
  builtin source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
fi

# ===========================
# zoxide (better cd)
# ===========================
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

# ===========================
# mise (per-project runtimes) and direnv (per-directory env)
# ===========================
# mise reads .nvmrc, .node-version, .python-version, .tool-versions and
# .mise.toml, so a repo that pins a version gets it; brew node/go/java stay the
# defaults elsewhere. direnv loads a trusted .envrc on cd (direnv allow once).
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi
if command -v direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
fi

# ===========================
# Delta (better diffs)
# ===========================
# git/config sets core.pager = delta; only the pager delta itself uses is set here.
if command -v delta &>/dev/null; then
  export DELTA_PAGER='less -R'
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

  # Shell integration: C-r history, C-t files, Alt-c cd (fzf >= 0.48)
  source <(fzf --zsh)
fi

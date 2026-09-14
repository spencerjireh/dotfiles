# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ===========================
# Auto-start tmux in Ghostty
# ===========================
# Attach to the running server if there is one (new Ghostty windows join it);
# otherwise start it with a timestamped session. prefix + S creates more.
if [[ -z "$TMUX" ]] && [[ -n "$GHOSTTY_RESOURCES_DIR" ]]; then
  exec tmux attach 2>/dev/null \
    || exec tmux new-session -s "$(date +%b%d-%H%M | tr '[:upper:]' '[:lower:]')" -c "$PWD"
fi

# ===========================
# Startup Profiler (optional)
# ===========================
# Enabled on demand: run `zsh_profile` (sets ZPROF=true) to see a startup report.
[[ -n "$ZPROF" ]] && zmodload zsh/zprof

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
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Compile completion dump for faster loading
if [[ -s "$ZSH_COMPDUMP" && (! -s "${ZSH_COMPDUMP}.zwc" || "$ZSH_COMPDUMP" -nt "${ZSH_COMPDUMP}.zwc") ]]; then
  zcompile "$ZSH_COMPDUMP"
fi

# ===========================
# Modular config
# ===========================
# Every zsh/*.zsh in the repo, in filename order (10-options, 20-path, 30-tools,
# 40-aliases, 50-functions). %x is this file; :A resolves the ~/.zshrc symlink
# back into the dotfiles repo. See docs/zsh.md (or `dot keys zsh`).
DOTFILES_ZSH="${${(%):-%x}:A:h}"
for f in "$DOTFILES_ZSH"/*.zsh; do source "$f"; done

# ===========================
# Powerlevel10k Configuration
# ===========================
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ===========================
# End Profiler (if enabled)
# ===========================
[[ -n "$ZPROF" ]] && zprof

# ===========================
# Machine-local overrides (untracked)
# ===========================
# Machine-specific config (per-machine PATHs, tool installers like opencode/kiro,
# work-only aliases) lives in ~/.zshrc.local so it never gets committed here.
# See zsh/.zshrc.local.example for the template.
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

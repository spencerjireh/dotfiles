# PATH setup. Loads before 30-tools and 40-aliases, which test `command -v`
# for brew-installed tools (eza, bat, trash, fzf, zoxide).

# Homebrew paths (differ by platform)
if [[ "$(uname -s)" == "Darwin" ]]; then
  # Apple Silicon brew isn't on the default PATH; load it if present.
  [[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
  export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
elif [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

export PATH="$HOME/.local/bin:$PATH"

# Go binaries
export PATH="$HOME/go/bin:$PATH"

# Rust: rustup is keg-only in Homebrew (it conflicts with the `rust` formula),
# so its bin dir is not linked; toolchain proxies (cargo, rustc) live in ~/.cargo/bin.
[[ -d "$HOME/.cargo/bin" ]] && export PATH="$HOME/.cargo/bin:$PATH"
if command -v brew &>/dev/null; then
  _rustup_bin="$(brew --prefix 2>/dev/null)/opt/rustup/bin"
  [[ -d "$_rustup_bin" ]] && export PATH="$_rustup_bin:$PATH"
  unset _rustup_bin
fi

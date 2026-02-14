# Dotfiles

Personal configuration files for my development environment.

## What's Inside

This repository contains configuration files for:

- **Ghostty** - Modern terminal emulator
- **Zsh** - Shell configuration with custom aliases and settings
- **Powerlevel10k** - Beautiful and functional Zsh theme
- **Neovim** - Text editor configuration

## Installation

### Fresh Installation

Clone this repository and run the install script:

```bash
git clone git@github-personal:spencerjirehcebrian/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

The install script will create symbolic links from your home directory to the files in this repository.

### What the Install Script Does

The script creates symlinks for:

- Ghostty config: `~/Library/Application Support/com.mitchellh.ghostty/config`
- Zsh configuration: `~/.zshrc`
- Powerlevel10k theme: `~/.p10k.zsh`
- Neovim configuration: `~/.config/nvim`

## Directory Structure

```
~/.dotfiles/
├── ghostty/
│   └── config              # Ghostty terminal configuration
├── zsh/
│   ├── .zshrc             # Zsh shell configuration
│   └── .p10k.zsh          # Powerlevel10k theme settings
├── nvim/
│   ├── init.lua           # Neovim configuration
│   └── lazy-lock.json     # Plugin lock file
└── install.sh             # Installation script
```

## Prerequisites

Before using these dotfiles, make sure you have the following installed:

- [Ghostty](https://ghostty.org/)
- [Zsh](https://www.zsh.org/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Neovim](https://neovim.io/)

## Making Changes

Since the files in your home directory are symlinked to this repository, any changes you make to your configs will automatically be reflected here.

To save your changes:

```bash
cd ~/.dotfiles
git add .
git commit -m "Description of changes"
git push
```

## Updating on Another Machine

To pull the latest changes on another machine:

```bash
cd ~/.dotfiles
git pull
```

The symlinks will automatically point to the updated files.

## Troubleshooting

### Symlinks Not Working

If symlinks aren't working, you can recreate them by running:

```bash
cd ~/.dotfiles
./install.sh
```

The `-sf` flags in the script will force overwrite any existing files.

### Permission Issues

Make sure the install script is executable:

```bash
chmod +x ~/.dotfiles/install.sh
```

## License

Feel free to use these configurations as inspiration for your own setup.

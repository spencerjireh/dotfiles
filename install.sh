#!/bin/bash

# Ghostty
mkdir -p ~/Library/Application\ Support/com.mitchellh.ghostty
ln -sf ~/.dotfiles/ghostty/config ~/Library/Application\ Support/com.mitchellh.ghostty/config

# Zsh
ln -sf ~/.dotfiles/zsh/.zshrc ~/.zshrc
ln -sf ~/.dotfiles/zsh/.p10k.zsh ~/.p10k.zsh

# Neovim
ln -sf ~/.dotfiles/nvim ~/.config/nvim

echo "Dotfiles installed!"

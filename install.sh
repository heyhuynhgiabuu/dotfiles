#!/bin/bash

echo "🛠️ Installing dotfiles..."

# Backup old dotfiles if exist
mv ~/.zshrc ~/.zshrc.backup 2>/dev/null
ln -sf ~/dotfiles/.zshrc ~/.zshrc

mkdir -p ~/.zsh
ln -sf ~/dotfiles/.zsh/* ~/.zsh/

# Tmux config
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf

# Neovim config
mkdir -p ~/.config/nvim
ln -sf ~/dotfiles/.config/nvim/init.lua ~/.config/nvim/init.lua

echo "✅ Done! Now run: source ~/.zshrc"


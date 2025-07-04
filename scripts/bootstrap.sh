#!/bin/bash

echo "🚀 Setting up symbolic links..."
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf
mkdir -p ~/.zsh
ln -sf ~/dotfiles/.zsh/aliases.zsh ~/.zsh/aliases.zsh
ln -sf ~/dotfiles/.zsh/env.zsh ~/.zsh/env.zsh
ln -sf ~/dotfiles/.zsh/functions.zsh ~/.zsh/functions.zsh
ln -sf ~/dotfiles/.zsh/starship.zsh ~/.zsh/starship.zsh

echo "📦 Cloning TPM (Tmux Plugin Manager)..."
if [ ! -d ~/.tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

echo "🔁 Reload tmux config"
tmux start-server
tmux new-session -d -s dummy
tmux send-keys -t dummy "tmux source-file ~/.tmux.conf" C-m
tmux kill-session -t dummy

echo "✅ Done. You may now run: tmux"


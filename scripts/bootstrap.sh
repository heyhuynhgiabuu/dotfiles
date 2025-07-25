#!/bin/bash

# Dotfiles bootstrap script for macOS using GNU Stow
# This script will install stow (if needed) and symlink your configs
# Usage: bash scripts/bootstrap.sh

set -e

# 1. Install stow if not present
if ! command -v stow &> /dev/null; then
  echo "Installing GNU Stow via Homebrew..."
  brew install stow
else
  echo "GNU Stow is already installed."
fi

# 2. Stow configs
DOTFILES_DIR="$HOME/dotfiles"
cd "$DOTFILES_DIR"

# List of config folders to stow
CONFIGS=(nvim tmux zsh aerospace wezterm)

for config in "${CONFIGS[@]}"; do
  echo "Stowing $config..."
  stow -v "$config"
done

# 3. Optional: Clone TPM (Tmux Plugin Manager)
echo "📦 Cloning TPM (Tmux Plugin Manager)..."
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# 4. Reload tmux config
echo "🔁 Reload tmux config"
tmux start-server
tmux new-session -d -s dummy
tmux send-keys -t dummy "tmux source-file ~/.tmux.conf" C-m
tmux kill-session -t dummy

echo "✅ Done! Your dotfiles are now symlinked with Stow."
echo "You may now run: tmux"

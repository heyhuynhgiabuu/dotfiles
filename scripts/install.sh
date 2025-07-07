#!/bin/bash

echo "🛠️ Installing dotfiles..."

# Backup old dotfiles if exist
echo "Backing up old dotfiles..."
mv ~/.zshrc ~/.zshrc.backup 2>/dev/null
ln -sf ~/dotfiles/.zshrc ~/.zshrc

mkdir -p ~/.zsh
ln -sf ~/dotfiles/.zsh/* ~/.zsh/

# Tmux config
echo "Symlinking tmux config..."
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf

# Neovim config
echo "Symlinking Neovim config..."
mkdir -p ~/.config/nvim
ln -sf ~/dotfiles/.config/nvim/init.lua ~/.config/nvim/init.lua

# Create bin directory and symlink scripts
echo "Setting up scripts..."
BIN_DIR="$HOME/.bin"
DOTFILES_SCRIPTS_DIR="$HOME/dotfiles/scripts"
mkdir -p "$BIN_DIR"

# Symlink all files from scripts directory to ~/.bin
# and make them executable.
for script in "$DOTFILES_SCRIPTS_DIR"/*; do
    if [ -f "$script" ]; then
        script_name=$(basename "$script")
        echo "Symlinking $script_name..."
        ln -sf "$script" "$BIN_DIR/$script_name"
        chmod +x "$BIN_DIR/$script_name"
    fi
done

echo "✅ Done! Now run: source ~/.zshrc"


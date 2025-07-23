#!/bin/bash

echo "🔄 Updating NvChad v2.0 while preserving custom configurations..."

# Check if NvChad is installed
if [ ! -d ~/.config/nvim ] || [ ! -f ~/.config/nvim/init.lua ]; then
    echo "❌ NvChad not found. Please run the main install script first."
    exit 1
fi

# Check if we're in a git repository (NvChad directory)
cd ~/.config/nvim
if [ ! -d .git ]; then
    echo "❌ NvChad directory is not a git repository. Cannot update."
    echo "   Please reinstall NvChad using the main install script."
    exit 1
fi

# Backup current custom configurations
echo "📦 Backing up current custom configurations..."
BACKUP_DIR="$HOME/dotfiles/nvchad-update-backup-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
if [ -d ~/.config/nvim/lua/custom ]; then
    cp -r ~/.config/nvim/lua/custom "$BACKUP_DIR/"
    echo "   Backup created at: $BACKUP_DIR"
fi

# Save current branch/commit info
echo "📋 Current NvChad info:"
git log --oneline -1
echo ""

# Update NvChad
echo "⬇️  Updating NvChad..."
git fetch origin
git reset --hard origin/v2.0

# Restore custom configuration symlinks
echo "🔗 Restoring custom configuration symlinks..."
mkdir -p ~/.config/nvim/lua/custom

# Remove any files that might have been added by the update
rm -rf ~/.config/nvim/lua/custom/*

# Recreate symlinks for all custom config files
if [ -d "$HOME/dotfiles/nvim/.config/nvim/lua/custom" ]; then
    for item in "$HOME/dotfiles/nvim/.config/nvim/lua/custom"/*; do
        if [ -e "$item" ]; then
            item_name=$(basename "$item")
            echo "   Symlinking custom/$item_name..."
            ln -sf "$item" ~/.config/nvim/lua/custom/"$item_name"
        fi
    done
fi

echo ""
echo "✅ NvChad update completed!"
echo "📋 Updated NvChad info:"
git log --oneline -1
echo ""
echo "📝 Notes:"
echo "  • Your custom configurations have been preserved"
echo "  • Backup created at: $BACKUP_DIR"
echo "  • If you encounter issues, you can restore from the backup"
echo "  • Your dotfiles custom configs remain unchanged"

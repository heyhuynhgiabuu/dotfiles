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

# Neovim config with NvChad v2.0 integration
echo "Setting up Neovim with NvChad v2.0..."

# Function to install NvChad if not present
install_nvchad() {
    if [ ! -d ~/.config/nvim ] || [ ! -f ~/.config/nvim/init.lua ]; then
        echo "Installing NvChad v2.0..."
        rm -rf ~/.config/nvim
        git clone --depth 1 -b v2.0 https://github.com/NvChad/NvChad.git ~/.config/nvim
    else
        echo "NvChad already installed, skipping..."
    fi
}

# Function to backup existing custom configs
backup_custom_configs() {
    if [ -d ~/.config/nvim/lua/custom ] && [ "$(ls -A ~/.config/nvim/lua/custom)" ]; then
        BACKUP_DIR="$HOME/dotfiles/nvim-backup-$(date +%Y%m%d_%H%M%S)"
        echo "Backing up existing custom configurations to: $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        cp -r ~/.config/nvim/lua/custom "$BACKUP_DIR/"
    fi
}

# Function to setup custom config symlinks
setup_custom_symlinks() {
    echo "Setting up custom configuration symlinks..."
    mkdir -p ~/.config/nvim/lua/custom

    # Remove existing symlinks/files in custom directory
    rm -rf ~/.config/nvim/lua/custom/*

    # Create symlinks for all custom config files
    if [ -d "$HOME/dotfiles/nvim/.config/nvim/lua/custom" ]; then
        for item in "$HOME/dotfiles/nvim/.config/nvim/lua/custom"/*; do
            if [ -e "$item" ]; then
                item_name=$(basename "$item")
                echo "Symlinking custom/$item_name..."
                ln -sf "$item" ~/.config/nvim/lua/custom/"$item_name"
            fi
        done
    fi
    
    # Create specific symlink for lspconfig (plugins.lua expects configs/lspconfig.lua)
    if [ -f "$HOME/dotfiles/nvim/.config/nvim/lua/custom/lsp-config.lua" ]; then
        echo "Creating lspconfig symlink..."
        mkdir -p ~/.config/nvim/lua/custom/configs
        ln -sf "$HOME/dotfiles/nvim/.config/nvim/lua/custom/lsp-config.lua" ~/.config/nvim/lua/custom/configs/lspconfig.lua
    fi
}

# Execute the setup
backup_custom_configs
install_nvchad
setup_custom_symlinks

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
echo ""
echo "📝 NvChad v2.0 Integration Notes:"
echo "  • NvChad is installed in ~/.config/nvim"
echo "  • Your custom configs are in ~/dotfiles/nvim/.config/nvim/lua/custom/"
echo "  • Custom configs are symlinked to NvChad's custom directory"
echo "  • To update NvChad: run 'update-nvchad' script"
echo "  • Your customizations are preserved in the dotfiles repo"


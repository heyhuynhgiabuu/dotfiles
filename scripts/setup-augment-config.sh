#!/bin/bash

# AugmentCode Setup Script for Cross-Platform Dotfiles
# Manages AugmentCode configuration with stow integration

echo "=== AugmentCode Configuration Setup ==="

# Check prerequisites
echo "Checking prerequisites..."

# Check if stow is available
if ! command -v stow >/dev/null 2>&1; then
    echo "❌ GNU Stow is required but not installed"
    echo "Install with:"
    echo "  macOS: brew install stow"
    echo "  Linux: sudo apt install stow (Debian/Ubuntu) or sudo yum install stow (RHEL/CentOS)"
    exit 1
fi

echo "✅ GNU Stow found: $(stow --version | head -1)"

# Check if we're in the dotfiles directory
if [[ ! -f "README.md" ]] || [[ ! -d "augment" ]]; then
    echo "❌ Please run this script from the dotfiles repository root"
    echo "Expected: cd ~/dotfiles && ./scripts/setup-augment-config.sh"
    exit 1
fi

echo "✅ Running from dotfiles directory"

# Check if AugmentCode plugin is installed in Neovim
echo "Checking AugmentCode plugin installation..."
if nvim --headless +"lua if pcall(function() vim.cmd('Augment status') end) then print('✅ AugmentCode plugin found') else print('❌ AugmentCode plugin not found') end" +qall 2>/dev/null | grep -q "✅"; then
    echo "✅ AugmentCode plugin is installed"
else
    echo "⚠️  AugmentCode plugin not found or not working"
    echo "Run: nvim +':Lazy sync' +qall to install/update plugins"
fi

# Backup existing AugmentCode configuration
echo "Backing up existing configuration..."
if [[ -d ~/.local/share/vim-augment ]]; then
    backup_dir=~/.local/share/vim-augment.backup.$(date +%Y%m%d_%H%M%S)
    mv ~/.local/share/vim-augment "$backup_dir"
    echo "✅ Backed up existing config to: $backup_dir"
fi

if [[ -d ~/.config/augment ]]; then
    backup_dir=~/.config/augment.backup.$(date +%Y%m%d_%H%M%S)
    mv ~/.config/augment "$backup_dir"
    echo "✅ Backed up existing config to: $backup_dir"
fi

# Remove existing symlinks if they exist
echo "Cleaning up existing symlinks..."
[[ -L ~/.local/share/vim-augment ]] && rm ~/.local/share/vim-augment
[[ -L ~/.config/augment ]] && rm ~/.config/augment

# Use stow to create symlinks
echo "Creating symlinks with stow..."
cd "$(dirname "$0")/.." || exit 1

if stow -v augment 2>&1; then
    echo "✅ Successfully created AugmentCode configuration symlinks"
else
    echo "❌ Failed to create symlinks with stow"
    exit 1
fi

# Verify symlinks were created correctly
echo "Verifying configuration..."

if [[ -L ~/.config/augment && -d ~/.config/augment ]]; then
    echo "✅ Global AugmentCode config symlinked: ~/.config/augment"
else
    echo "❌ Global config symlink failed"
fi

if [[ -L ~/.local/share/vim-augment && -d ~/.local/share/vim-augment ]]; then
    echo "✅ AugmentCode data directory symlinked: ~/.local/share/vim-augment"
else
    echo "❌ Data directory symlink failed"
fi

if [[ -f ~/.augmentignore ]]; then
    echo "✅ Global .augmentignore symlinked"
else
    echo "❌ .augmentignore symlink failed"
fi

# Test AugmentCode functionality
echo "Testing AugmentCode functionality..."
if command -v nvim >/dev/null; then
    echo "Run this to test AugmentCode:"
    echo "  nvim test.go"
    echo "  :Augment status"
    echo ""
    echo "Expected keymaps:"
    echo "  <leader>ai - Sign in"
    echo "  <leader>as - Show status"
    echo "  <leader>ac - Chat with AugmentCode"
    echo "  <Tab> or <C-l> - Accept completions"
else
    echo "⚠️  Neovim not found in PATH"
fi

echo ""
echo "🎉 AugmentCode configuration setup complete!"
echo ""
echo "📁 Configuration files:"
echo "  ~/.config/augment/          - Global settings and keymaps"
echo "  ~/.local/share/vim-augment/ - Data and cache"
echo "  ~/.augmentignore            - Global ignore patterns"
echo ""
echo "🔄 To update configuration:"
echo "  1. Edit files in ~/dotfiles/augment/"
echo "  2. Changes are immediately reflected (symlinked)"
echo ""
echo "🗑️  To remove:"
echo "  cd ~/dotfiles && stow -D augment"
echo ""
echo "📚 Documentation:"
echo "  https://docs.augmentcode.com/vim/"
#!/bin/bash

echo "🔍 NvChad Integration Health Check"
echo "=================================="

# Check if NvChad is installed
echo "📦 Checking NvChad installation..."
if [ -d ~/.config/nvim ] && [ -f ~/.config/nvim/init.lua ]; then
    echo "   ✅ NvChad is installed"
    cd ~/.config/nvim
    if [ -d .git ]; then
        echo "   ✅ NvChad git repository is present"
        echo "   📋 Current version: $(git log --oneline -1)"
    else
        echo "   ⚠️  NvChad directory is not a git repository"
    fi
else
    echo "   ❌ NvChad is not installed"
    exit 1
fi

echo ""
echo "🔗 Checking custom configuration symlinks..."
custom_dir="$HOME/.config/nvim/lua/custom"
dotfiles_custom_dir="$HOME/dotfiles/nvim/.config/nvim/lua/custom"

if [ ! -d "$custom_dir" ]; then
    echo "   ❌ Custom directory not found"
    exit 1
fi

if [ ! -d "$dotfiles_custom_dir" ]; then
    echo "   ❌ Dotfiles custom directory not found"
    exit 1
fi

echo "   📁 Custom directory exists"

# Check each symlink
broken_links=0
total_links=0

for item in "$custom_dir"/*; do
    if [ -L "$item" ]; then
        total_links=$((total_links + 1))
        item_name=$(basename "$item")
        if [ -e "$item" ]; then
            echo "   ✅ $item_name -> $(readlink "$item")"
        else
            echo "   ❌ $item_name -> $(readlink "$item") (BROKEN)"
            broken_links=$((broken_links + 1))
        fi
    elif [ -f "$item" ]; then
        item_name=$(basename "$item")
        echo "   ⚠️  $item_name (regular file, not symlinked)"
    fi
done

echo ""
echo "📊 Summary:"
echo "   Total symlinks: $total_links"
echo "   Broken symlinks: $broken_links"

if [ $broken_links -eq 0 ]; then
    echo "   ✅ All symlinks are working correctly"
else
    echo "   ❌ Some symlinks are broken - run install script to fix"
fi

echo ""
echo "📁 Dotfiles custom configuration files:"
if [ -d "$dotfiles_custom_dir" ]; then
    for item in "$dotfiles_custom_dir"/*; do
        if [ -e "$item" ]; then
            item_name=$(basename "$item")
            if [ -f "$item" ]; then
                echo "   📄 $item_name"
            elif [ -d "$item" ]; then
                echo "   📁 $item_name/"
            fi
        fi
    done
else
    echo "   ❌ Dotfiles custom directory not found"
fi

echo ""
if [ $broken_links -eq 0 ] && [ -d "$dotfiles_custom_dir" ]; then
    echo "🎉 NvChad integration is healthy!"
else
    echo "⚠️  Issues detected. Consider running the install script to fix."
fi

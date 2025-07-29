#!/bin/bash

# Test AugmentCode Configuration
# Verifies that the stow-managed configuration is working correctly

echo "=== AugmentCode Configuration Test ==="
echo

# Check symlinks
echo "📁 Checking symlinks..."
if [[ -L ~/.config/augment && -d ~/.config/augment ]]; then
    echo "✅ ~/.config/augment → $(readlink ~/.config/augment)"
else
    echo "❌ ~/.config/augment symlink missing"
fi

if [[ -L ~/.local/share/vim-augment && -d ~/.local/share/vim-augment ]]; then
    echo "✅ ~/.local/share/vim-augment → $(readlink ~/.local/share/vim-augment)"
else
    echo "❌ ~/.local/share/vim-augment symlink missing"
fi

if [[ -L ~/.augmentignore && -f ~/.augmentignore ]]; then
    echo "✅ ~/.augmentignore → $(readlink ~/.augmentignore)"
else
    echo "❌ ~/.augmentignore symlink missing"
fi

# Check configuration files
echo
echo "📝 Checking configuration files..."
config_files=(
    "~/.config/augment/settings.conf"
    "~/.config/augment/keymaps.conf"
    "~/.config/augment/workspace_folders.conf"
    "~/.config/augment/dotfiles-workspace.conf"
)

for file in "${config_files[@]}"; do
    expanded_file=$(eval echo "$file")
    if [[ -f "$expanded_file" ]]; then
        echo "✅ $file ($(wc -l < "$expanded_file") lines)"
    else
        echo "❌ $file missing"
    fi
done

# Test Neovim integration
echo
echo "🚀 Testing Neovim integration..."
if command -v nvim >/dev/null; then
    echo "Testing AugmentCode plugin loading..."
    
    # Test if commands are available
    if nvim --headless +"lua local cmds = vim.api.nvim_get_commands({}); for cmd, _ in pairs(cmds) do if cmd:lower():find('augment') then print('✅ ' .. cmd .. ' command found') end end" +qall 2>/dev/null | grep -q "Augment"; then
        echo "✅ AugmentCode commands available"
    else
        echo "⚠️  AugmentCode commands not found (run :Lazy sync)"
    fi
    
    # Test workspace configuration
    echo "Testing workspace configuration..."
    cd ~/dotfiles
    workspace_test=$(nvim --headless +"lua local folders = { vim.fn.getcwd() }; local common = {'~/projects', '~/code', '~/dev', '~/dotfiles'}; for _, dir in ipairs(common) do local expanded = vim.fn.expand(dir); if vim.fn.isdirectory(expanded) == 1 and expanded ~= vim.fn.getcwd() then table.insert(folders, expanded) end end; print('Would configure ' .. #folders .. ' workspace folders'); vim.g.augment_workspace_folders = folders; if vim.g.augment_workspace_folders then print('✅ Workspace folders set: ' .. vim.inspect(vim.g.augment_workspace_folders)) else print('❌ Failed to set workspace folders') end" +qall 2>&1)
    echo "$workspace_test"
else
    echo "❌ Neovim not found"
fi

# Test AugmentCode authentication status
echo
echo "🔐 Checking AugmentCode authentication..."
if [[ -f ~/.local/share/vim-augment/secrets.json ]]; then
    echo "✅ Authentication secrets found"
    if command -v nvim >/dev/null; then
        echo "Run this to check status: nvim test.go, then :Augment status"
    fi
else
    echo "⚠️  No authentication secrets found"
    echo "Run this to sign in: nvim test.go, then :Augment signin"
fi

# Test global ignore patterns
echo
echo "🚫 Testing global ignore patterns..."
ignore_file=~/.augmentignore
if [[ -f "$ignore_file" ]]; then
    ignore_count=$(grep -c "^[^#]" "$ignore_file" | grep -v "^$" || echo "0")
    echo "✅ Global .augmentignore loaded ($ignore_count patterns)"
    echo "Sample patterns:"
    head -5 "$ignore_file" | grep -v "^#" | sed 's/^/  /'
else
    echo "❌ Global .augmentignore not found"
fi

echo
echo "🎯 Next Steps:"
echo "1. Test in Neovim: nvim test.go"
echo "2. Check status: :Augment status"  
echo "3. Try chat: <leader>ac How do I optimize this code?"
echo "4. Check workspace: <leader>aw"
echo
echo "📚 Documentation: ~/dotfiles/augment/README.md"
echo "🔄 Update config: Edit files in ~/dotfiles/augment/"
echo "🗑️  Remove: cd ~/dotfiles && stow -D augment"
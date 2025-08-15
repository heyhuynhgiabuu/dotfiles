#!/usr/bin/env sh

# AugmentCode Configuration Test Script
# Verifies that the stow-managed configuration is working correctly
# Usage: bash scripts/test-augment-config.sh

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Configuration
readonly CONFIG_FILES=(
    "${HOME}/.config/augment/settings.conf"
    "${HOME}/.config/augment/keymaps.conf"
    "${HOME}/.config/augment/workspace_folders.conf"
    "${HOME}/.config/augment/dotfiles-workspace.conf"
)

readonly SYMLINK_TARGETS=(
    "${HOME}/.config/augment"
    "${HOME}/.local/share/vim-augment"
    "${HOME}/.augmentignore"
)

main() {
    log_header "AugmentCode Configuration Test"
    
    # Check symlinks
    check_symlinks
    
    # Check configuration files
    check_configuration_files
    
    # Test Neovim integration
    test_neovim_integration
    
    # Check authentication status
    check_authentication_status
    
    # Test global ignore patterns
    test_ignore_patterns
    
    # Show next steps
    show_next_steps
}

check_symlinks() {
    log_info "📁 Checking symlinks..."
    
    # Check augment config directory
    if [[ -L "${HOME}/.config/augment" && -d "${HOME}/.config/augment" ]]; then
        log_success "~/.config/augment → $(readlink "${HOME}/.config/augment")"
    else
        log_error "~/.config/augment symlink missing"
    fi
    
    # Check vim-augment directory
    if [[ -L "${HOME}/.local/share/vim-augment" && -d "${HOME}/.local/share/vim-augment" ]]; then
        log_success "~/.local/share/vim-augment → $(readlink "${HOME}/.local/share/vim-augment")"
    else
        log_error "~/.local/share/vim-augment symlink missing"
    fi
    
    # Check augmentignore file
    if [[ -L "${HOME}/.augmentignore" && -f "${HOME}/.augmentignore" ]]; then
        log_success "~/.augmentignore → $(readlink "${HOME}/.augmentignore")"
    else
        log_error "~/.augmentignore symlink missing"
    fi
}

check_configuration_files() {
    log_info "📝 Checking configuration files..."
    
    for file in "${CONFIG_FILES[@]}"; do
        local display_file
        display_file=$(echo "$file" | sed "s|${HOME}|~|")
        
        if [[ -f "$file" ]]; then
            local line_count
            line_count=$(wc -l < "$file")
            log_success "$display_file ($line_count lines)"
        else
            log_error "$display_file missing"
        fi
    done
}

test_neovim_integration() {
    log_info "🚀 Testing Neovim integration..."
    
    if ! cmd_exists nvim; then
        log_error "Neovim not found"
        return 1
    fi
    
    # Test AugmentCode plugin loading
    test_plugin_commands
    
    # Test workspace configuration
    test_workspace_configuration
}

test_plugin_commands() {
    log_step "Testing AugmentCode plugin loading..."
    
    # Test if commands are available
    local command_test
    command_test=$(nvim --headless +"lua local cmds = vim.api.nvim_get_commands({}); for cmd, _ in pairs(cmds) do if cmd:lower():find('augment') then print('✅ ' .. cmd .. ' command found') end end" +qall 2>/dev/null)
    
    if echo "$command_test" | grep -q "Augment"; then
        log_success "AugmentCode commands available"
        echo "$command_test" | sed 's/^/    /'
    else
        log_warning "AugmentCode commands not found (run :Lazy sync)"
    fi
}

test_workspace_configuration() {
    log_step "Testing workspace configuration..."
    
    cd "$DOTFILES_DIR"
    
    local workspace_test
    workspace_test=$(nvim --headless +"lua 
local folders = { vim.fn.getcwd() }
local common = {'~/projects', '~/code', '~/dev', '~/dotfiles'}
for _, dir in ipairs(common) do 
    local expanded = vim.fn.expand(dir)
    if vim.fn.isdirectory(expanded) == 1 and expanded ~= vim.fn.getcwd() then 
        table.insert(folders, expanded) 
    end 
end
print('Would configure ' .. #folders .. ' workspace folders')
vim.g.augment_workspace_folders = folders
if vim.g.augment_workspace_folders then 
    print('✅ Workspace folders configured successfully')
else 
    print('❌ Failed to set workspace folders') 
end" +qall 2>&1)
    
    echo "$workspace_test" | sed 's/^/    /'
}

check_authentication_status() {
    log_info "🔐 Checking AugmentCode authentication..."
    
    local secrets_file="${HOME}/.local/share/vim-augment/secrets.json"
    if [[ -f "$secrets_file" ]]; then
        log_success "Authentication secrets found"
        if cmd_exists nvim; then
            log_info "Run this to check status: nvim test.go, then :Augment status"
        fi
    else
        log_warning "No authentication secrets found"
        log_info "Run this to sign in: nvim test.go, then :Augment signin"
    fi
    
    # Test authentication status if possible
    if cmd_exists nvim && [[ -f "$secrets_file" ]]; then
        log_step "Testing authentication status..."
        if nvim --headless +"Augment status" +qall 2>/dev/null; then
            log_success "Authentication appears to be working"
        else
            log_warning "Authentication may need renewal"
        fi
    fi
}

test_ignore_patterns() {
    log_info "🚫 Testing global ignore patterns..."
    
    local ignore_file="${HOME}/.augmentignore"
    if [[ -f "$ignore_file" ]]; then
        local ignore_count
        ignore_count=$(grep -c "^[^#]" "$ignore_file" | grep -v "^$" || echo "0")
        log_success "Global .augmentignore loaded ($ignore_count patterns)"
        
        log_step "Sample patterns:"
        head -5 "$ignore_file" | grep -v "^#" | sed 's/^/    /'
        
        # Test pattern effectiveness
        log_step "Testing pattern matching..."
        if grep -q "node_modules" "$ignore_file"; then
            log_success "Standard ignore patterns included (node_modules, etc.)"
        else
            log_warning "Consider adding common ignore patterns"
        fi
    else
        log_error "Global .augmentignore not found"
    fi
}

show_next_steps() {
    echo
    log_header "Next Steps"
    echo "1. Test in Neovim: nvim test.go"
    echo "2. Check status: :Augment status"
    echo "3. Try chat: <leader>ac How do I optimize this code?"
    echo "4. Check workspace: <leader>aw"
    echo
    
    log_info "Useful commands:"
    echo "  • :Augment signin    - Authenticate with AugmentCode"
    echo "  • :Augment status    - Check connection status"
    echo "  • :Augment log       - View detailed logs"
    echo "  • <leader>ac         - Start chat conversation"
    echo "  • <leader>at         - Toggle chat panel"
    echo
    
    log_info "Configuration management:"
    echo "  📚 Documentation: ~/dotfiles/augment/README.md"
    echo "  🔄 Update config: Edit files in ~/dotfiles/augment/"
    echo "  🗑️  Remove: cd ~/dotfiles && stow -D augment"
    echo "  🔧 Troubleshoot: Run debug-augmentcode-auth.sh"
    echo
    
    log_warning "If tests failed:"
    echo "- Run: setup-augment-config.sh to fix configuration"
    echo "- Run: setup-augmentcode.sh to reinstall plugin"
    echo "- Check: augmentcode-auth-guide.sh for authentication help"
}

# Execute main function
main "$@"#!/bin/bash

# AugmentCode Configuration Test Script
# Verifies that the stow-managed configuration is working correctly
# Usage: bash scripts/test-augment-config.sh

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Configuration
readonly CONFIG_FILES=(
    "${HOME}/.config/augment/settings.conf"
    "${HOME}/.config/augment/keymaps.conf"
    "${HOME}/.config/augment/workspace_folders.conf"
    "${HOME}/.config/augment/dotfiles-workspace.conf"
)

readonly SYMLINK_TARGETS=(
    "${HOME}/.config/augment"
    "${HOME}/.local/share/vim-augment"
    "${HOME}/.augmentignore"
)

main() {
    log_header "AugmentCode Configuration Test"
    
    # Check symlinks
    check_symlinks
    
    # Check configuration files
    check_configuration_files
    
    # Test Neovim integration
    test_neovim_integration
    
    # Check authentication status
    check_authentication_status
    
    # Test global ignore patterns
    test_ignore_patterns
    
    # Show next steps
    show_next_steps
}

check_symlinks() {
    log_info "📁 Checking symlinks..."
    
    # Check augment config directory
    if [[ -L "${HOME}/.config/augment" && -d "${HOME}/.config/augment" ]]; then
        log_success "~/.config/augment → $(readlink "${HOME}/.config/augment")"
    else
        log_error "~/.config/augment symlink missing"
    fi
    
    # Check vim-augment directory
    if [[ -L "${HOME}/.local/share/vim-augment" && -d "${HOME}/.local/share/vim-augment" ]]; then
        log_success "~/.local/share/vim-augment → $(readlink "${HOME}/.local/share/vim-augment")"
    else
        log_error "~/.local/share/vim-augment symlink missing"
    fi
    
    # Check augmentignore file
    if [[ -L "${HOME}/.augmentignore" && -f "${HOME}/.augmentignore" ]]; then
        log_success "~/.augmentignore → $(readlink "${HOME}/.augmentignore")"
    else
        log_error "~/.augmentignore symlink missing"
    fi
}

check_configuration_files() {
    log_info "📝 Checking configuration files..."
    
    for file in "${CONFIG_FILES[@]}"; do
        local display_file
        display_file=$(echo "$file" | sed "s|${HOME}|~|")
        
        if [[ -f "$file" ]]; then
            local line_count
            line_count=$(wc -l < "$file")
            log_success "$display_file ($line_count lines)"
        else
            log_error "$display_file missing"
        fi
    done
}

test_neovim_integration() {
    log_info "🚀 Testing Neovim integration..."
    
    if ! cmd_exists nvim; then
        log_error "Neovim not found"
        return 1
    fi
    
    # Test AugmentCode plugin loading
    test_plugin_commands
    
    # Test workspace configuration
    test_workspace_configuration
}

test_plugin_commands() {
    log_step "Testing AugmentCode plugin loading..."
    
    # Test if commands are available
    local command_test
    command_test=$(nvim --headless +"lua local cmds = vim.api.nvim_get_commands({}); for cmd, _ in pairs(cmds) do if cmd:lower():find('augment') then print('✅ ' .. cmd .. ' command found') end end" +qall 2>/dev/null)
    
    if echo "$command_test" | grep -q "Augment"; then
        log_success "AugmentCode commands available"
        echo "$command_test" | sed 's/^/    /'
    else
        log_warning "AugmentCode commands not found (run :Lazy sync)"
    fi
}

test_workspace_configuration() {
    log_step "Testing workspace configuration..."
    
    cd "$DOTFILES_DIR"
    
    local workspace_test
    workspace_test=$(nvim --headless +"lua 
local folders = { vim.fn.getcwd() }
local common = {'~/projects', '~/code', '~/dev', '~/dotfiles'}
for _, dir in ipairs(common) do 
    local expanded = vim.fn.expand(dir)
    if vim.fn.isdirectory(expanded) == 1 and expanded ~= vim.fn.getcwd() then 
        table.insert(folders, expanded) 
    end 
end
print('Would configure ' .. #folders .. ' workspace folders')
vim.g.augment_workspace_folders = folders
if vim.g.augment_workspace_folders then 
    print('✅ Workspace folders configured successfully')
else 
    print('❌ Failed to set workspace folders') 
end" +qall 2>&1)
    
    echo "$workspace_test" | sed 's/^/    /'
}

check_authentication_status() {
    log_info "🔐 Checking AugmentCode authentication..."
    
    local secrets_file="${HOME}/.local/share/vim-augment/secrets.json"
    if [[ -f "$secrets_file" ]]; then
        log_success "Authentication secrets found"
        if cmd_exists nvim; then
            log_info "Run this to check status: nvim test.go, then :Augment status"
        fi
    else
        log_warning "No authentication secrets found"
        log_info "Run this to sign in: nvim test.go, then :Augment signin"
    fi
    
    # Test authentication status if possible
    if cmd_exists nvim && [[ -f "$secrets_file" ]]; then
        log_step "Testing authentication status..."
        if nvim --headless +"Augment status" +qall 2>/dev/null; then
            log_success "Authentication appears to be working"
        else
            log_warning "Authentication may need renewal"
        fi
    fi
}

test_ignore_patterns() {
    log_info "🚫 Testing global ignore patterns..."
    
    local ignore_file="${HOME}/.augmentignore"
    if [[ -f "$ignore_file" ]]; then
        local ignore_count
        ignore_count=$(grep -c "^[^#]" "$ignore_file" | grep -v "^$" || echo "0")
        log_success "Global .augmentignore loaded ($ignore_count patterns)"
        
        log_step "Sample patterns:"
        head -5 "$ignore_file" | grep -v "^#" | sed 's/^/    /'
        
        # Test pattern effectiveness
        log_step "Testing pattern matching..."
        if grep -q "node_modules" "$ignore_file"; then
            log_success "Standard ignore patterns included (node_modules, etc.)"
        else
            log_warning "Consider adding common ignore patterns"
        fi
    else
        log_error "Global .augmentignore not found"
    fi
}

show_next_steps() {
    echo
    log_header "Next Steps"
    echo "1. Test in Neovim: nvim test.go"
    echo "2. Check status: :Augment status"
    echo "3. Try chat: <leader>ac How do I optimize this code?"
    echo "4. Check workspace: <leader>aw"
    echo
    
    log_info "Useful commands:"
    echo "  • :Augment signin    - Authenticate with AugmentCode"
    echo "  • :Augment status    - Check connection status"
    echo "  • :Augment log       - View detailed logs"
    echo "  • <leader>ac         - Start chat conversation"
    echo "  • <leader>at         - Toggle chat panel"
    echo
    
    log_info "Configuration management:"
    echo "  📚 Documentation: ~/dotfiles/augment/README.md"
    echo "  🔄 Update config: Edit files in ~/dotfiles/augment/"
    echo "  🗑️  Remove: cd ~/dotfiles && stow -D augment"
    echo "  🔧 Troubleshoot: Run debug-augmentcode-auth.sh"
    echo
    
    log_warning "If tests failed:"
    echo "- Run: setup-augment-config.sh to fix configuration"
    echo "- Run: setup-augmentcode.sh to reinstall plugin"
    echo "- Check: augmentcode-auth-guide.sh for authentication help"
}

# Execute main function
main "$@"
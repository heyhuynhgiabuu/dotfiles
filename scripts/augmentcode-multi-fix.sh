#!/bin/bash

# AugmentCode Multiple Solutions Fix Script
# Provides comprehensive troubleshooting for authentication issues
# Usage: bash scripts/augmentcode-multi-fix.sh

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

main() {
    log_header "AugmentCode Authentication Fix - Multiple Solutions"
    
    # Setup environment
    setup_debug_environment
    
    # Show all available solutions
    show_solution_1_plugin_update
    show_solution_2_clear_cache
    show_solution_3_browser_compatibility
    show_solution_4_manual_account
    show_solution_5_json_debugging
    show_solution_6_alternative_install
    show_solution_7_workspace_config
    
    # Show immediate action plan
    show_action_plan
    show_debug_commands
}

setup_debug_environment() {
    log_info "Setting up debug environment..."
    
    # Load NVM and setup Node.js
    setup_nodejs "22"
}

show_solution_1_plugin_update() {
    log_info "SOLUTION 1: Plugin Update & Clean Install"
    echo "Many authentication issues are fixed in newer versions"
    echo
    echo "Steps:"
    echo "1. nvim"
    echo "2. :Lazy sync (update all plugins)"
    echo "3. :qa (quit completely)"
    echo "4. Restart terminal"
    echo "5. cd ~/dotfiles && nvim test.go"
    echo "6. :Augment signin"
    echo
}

show_solution_2_clear_cache() {
    log_info "SOLUTION 2: Clear Authentication Cache"
    echo "Remove any cached authentication data"
    echo
    echo "Steps:"
    echo "1. :Augment signout (if already signed in)"
    echo "2. Close Neovim completely"
    echo "3. Find and remove AugmentCode cache files:"
    echo "   ~/.cache/augment* (if exists)"
    echo "   ~/.local/share/augment* (if exists)"
    echo "4. Restart Neovim"
    echo "5. :Augment signin"
    echo
}

show_solution_3_browser_compatibility() {
    log_info "SOLUTION 3: Terminal/Browser Compatibility"
    echo "Use different browser or terminal"
    echo
    echo "Steps:"
    echo "1. Try in a different browser (Chrome, Firefox, Safari)"
    echo "2. Try in Terminal.app instead of WezTerm"
    echo "3. Disable browser extensions temporarily"
    echo "4. Use incognito/private browsing mode"
    echo
}

show_solution_4_manual_account() {
    log_info "SOLUTION 4: Manual Account Creation"
    echo "Create account via website first"
    echo
    echo "Steps:"
    echo "1. Go to https://augmentcode.com"
    echo "2. Sign up for account manually"
    echo "3. Verify email if required"
    echo "4. THEN try :Augment signin in Neovim"
    echo
}

show_solution_5_json_debugging() {
    log_info "SOLUTION 5: JSON Format Debugging"
    echo "Check exact JSON format from browser"
    echo
    echo "Expected format:"
    echo '{"code":"your_api_key","state":"session_state","tenant_url":"https://i0.api.augmentcode.com/"}'
    echo
    echo "Common issues:"
    echo "❌ Browser adds extra text before/after JSON"
    echo "❌ JSON is formatted with line breaks"
    echo "❌ Copying from wrong part of page"
    echo "❌ Unicode characters in JSON"
    echo
}

show_solution_6_alternative_install() {
    log_info "SOLUTION 6: Alternative Installation Method"
    echo "Try manual installation instead of Lazy.nvim"
    echo
    echo "Steps:"
    echo "1. Remove current plugin from Lazy config"
    echo "2. :Lazy clean"
    echo "3. Manual install:"
    echo "   git clone https://github.com/augmentcode/augment.vim.git \"
    echo "     ~/.config/nvim/pack/augment/start/augment.vim"
    echo "4. Restart Neovim"
    echo "5. :Augment signin"
    echo
}

show_solution_7_workspace_config() {
    log_info "SOLUTION 7: Workspace Configuration Issue"
    echo "Fix workspace folder configuration"
    echo
    echo "Current config: vim.g.augment_workspace_folders = { vim.fn.getcwd }"
    echo
    echo "Try static path instead:"
    echo "vim.g.augment_workspace_folders = { '/Users/killerkidbo/dotfiles' }"
    echo
}"
    echo
    echo "Try static path instead:"
    echo "vim.g.augment_workspace_folders = { '/Users/killerkidbo/dotfiles' }"
    echo
}

show_action_plan() {
    log_header "IMMEDIATE NEXT STEPS"
    echo "1. Try Solution 1 (Plugin Update) first"
    echo "2. If that fails, try Solution 2 (Clear Cache)"
    echo "3. For each attempt, check :Augment log for details"
    echo "4. If JSON parsing still fails, try Solution 4 (Manual Account)"
    echo
}

show_debug_commands() {
    log_info "DEBUG COMMANDS:"
    echo "  :Augment status  - Check current status"
    echo "  :Augment log     - See detailed error logs"
    echo "  :Lazy health     - Check plugin health"
    echo "  :checkhealth     - General Neovim health"
    echo
    
    log_warning "Remember to check logs after each solution attempt!"
}

# Execute main function
main "$@"
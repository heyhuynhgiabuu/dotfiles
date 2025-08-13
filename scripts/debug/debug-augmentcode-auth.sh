#!/bin/bash

# AugmentCode Authentication Debug Script
# Diagnoses authentication issues and provides troubleshooting
# Usage: bash scripts/debug-augmentcode-auth.sh

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

main() {
    log_header "AugmentCode Authentication Debug Script"
    
    # Setup environment
    setup_debug_environment
    
    # Run diagnostics
    run_environment_diagnostics
    run_plugin_diagnostics
    
    # Show troubleshooting guides
    show_authentication_troubleshooting
    show_manual_testing_instructions
}

setup_debug_environment() {
    log_info "Setting up debug environment..."
    
    # Load NVM and switch to Node.js v22
    if [[ -f "${HOME}/.nvm/nvm.sh" ]]; then
        source "${HOME}/.nvm/nvm.sh"
        nvm use v22.14.0 2>/dev/null || log_warning "Node.js v22.14.0 not available"
    fi
}

run_environment_diagnostics() {
    log_info "Environment Status:"
    
    # Check Node.js
    if cmd_exists node; then
        log_success "Node.js version: $(node --version)"
    else
        log_error "Node.js not found"
    fi
    
    # Check Neovim
    if cmd_exists nvim; then
        log_success "Neovim version: $(nvim --version | head -1)"
    else
        log_error "Neovim not found"
    fi
    
    log_info "Current directory: $(pwd)"
    echo
}

run_plugin_diagnostics() {
    log_info "Testing AugmentCode plugin status..."
    
    # Test plugin loading
    if nvim --headless +"lua print('✅ AugmentCode plugin loaded')" +qall 2>/dev/null; then
        log_success "Plugin loads successfully"
    else
        log_error "Plugin failed to load"
    fi
    
    # Test command availability
    log_info "Checking AugmentCode commands..."
    if nvim --headless +"Augment status" +qall 2>/dev/null; then
        log_success ":Augment command is available"
    else
        log_error ":Augment command not found"
    fi
    echo
}

show_authentication_troubleshooting() {
    log_header "Authentication Troubleshooting Steps"
    
    log_step "STEP 1: Clean authentication state"
    echo "  - Close all Neovim instances"
    echo "  - Clear any cached authentication"
    echo "  - Open a fresh terminal session"
    echo
    
    log_step "STEP 2: Proper sign-in process"
    echo "  1. cd ~/dotfiles"
    echo "  2. nvim test.go"
    echo "  3. In Neovim: :Augment signin"
    echo "  4. Complete sign-in in browser"
    echo "  5. Copy the COMPLETE authentication response"
    echo "  6. Paste in the SAME terminal where Neovim is running"
    echo
    
    log_step "STEP 3: Expected authentication flow"
    echo "  Browser should show: Complete authentication"
    echo "  AugmentCode should provide JSON with:"
    echo "    - code: API key"
    echo "    - state: Session state"
    echo "    - tenant_url: API endpoint"
    echo
    
    log_step "STEP 4: Common authentication mistakes"
    echo "  ❌ Pasting only part of the response"
    echo "  ❌ Switching to different terminal window"
    echo "  ❌ Browser showing different URL than expected"
    echo "  ❌ Copying from wrong place in browser"
    echo
    
    log_step "STEP 5: Verification"
    echo "  After successful auth: :Augment status"
    echo "  Should show: 'Signed in' status"
    echo
}

show_manual_testing_instructions() {
    log_header "Manual Testing Instructions"
    
    log_info "Ready to test? Follow these exact steps:"
    echo
    echo "1. Open NEW terminal window"
    echo "2. cd ~/dotfiles"
    echo "3. nvim test.go"
    echo "4. In Neovim type: :Augment signin"
    echo "5. Browser will open - complete authentication"
    echo "6. Copy ENTIRE JSON response from browser"
    echo "7. Return to SAME terminal with Neovim"
    echo "8. Paste the authentication response"
    echo "9. Check status: :Augment status"
    echo
    
    log_warning "If authentication still fails, run: :Augment log"
    echo "This will show detailed error information."
    echo
}

# Execute main function
main "$@"#!/bin/bash

# AugmentCode Authentication Debug Script
# Diagnoses authentication issues and provides troubleshooting
# Usage: bash scripts/debug-augmentcode-auth.sh

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

main() {
    log_header "AugmentCode Authentication Debug Script"
    
    # Setup environment
    setup_debug_environment
    
    # Run diagnostics
    run_environment_diagnostics
    run_plugin_diagnostics
    
    # Show troubleshooting guides
    show_authentication_troubleshooting
    show_manual_testing_instructions
}

setup_debug_environment() {
    log_info "Setting up debug environment..."
    
    # Load NVM and switch to Node.js v22
    if [[ -f "${HOME}/.nvm/nvm.sh" ]]; then
        source "${HOME}/.nvm/nvm.sh"
        nvm use v22.14.0 2>/dev/null || log_warning "Node.js v22.14.0 not available"
    fi
}

run_environment_diagnostics() {
    log_info "Environment Status:"
    
    # Check Node.js
    if cmd_exists node; then
        log_success "Node.js version: $(node --version)"
    else
        log_error "Node.js not found"
    fi
    
    # Check Neovim
    if cmd_exists nvim; then
        log_success "Neovim version: $(nvim --version | head -1)"
    else
        log_error "Neovim not found"
    fi
    
    log_info "Current directory: $(pwd)"
    echo
}

run_plugin_diagnostics() {
    log_info "Testing AugmentCode plugin status..."
    
    # Test plugin loading
    if nvim --headless +"lua print('✅ AugmentCode plugin loaded')" +qall 2>/dev/null; then
        log_success "Plugin loads successfully"
    else
        log_error "Plugin failed to load"
    fi
    
    # Test command availability
    log_info "Checking AugmentCode commands..."
    if nvim --headless +"Augment status" +qall 2>/dev/null; then
        log_success ":Augment command is available"
    else
        log_error ":Augment command not found"
    fi
    echo
}

show_authentication_troubleshooting() {
    log_header "Authentication Troubleshooting Steps"
    
    log_step "STEP 1: Clean authentication state"
    echo "  - Close all Neovim instances"
    echo "  - Clear any cached authentication"
    echo "  - Open a fresh terminal session"
    echo
    
    log_step "STEP 2: Proper sign-in process"
    echo "  1. cd ~/dotfiles"
    echo "  2. nvim test.go"
    echo "  3. In Neovim: :Augment signin"
    echo "  4. Complete sign-in in browser"
    echo "  5. Copy the COMPLETE authentication response"
    echo "  6. Paste in the SAME terminal where Neovim is running"
    echo
    
    log_step "STEP 3: Expected authentication flow"
    echo "  Browser should show: Complete authentication"
    echo "  AugmentCode should provide JSON with:"
    echo "    - code: API key"
    echo "    - state: Session state"
    echo "    - tenant_url: API endpoint"
    echo
    
    log_step "STEP 4: Common authentication mistakes"
    echo "  ❌ Pasting only part of the response"
    echo "  ❌ Switching to different terminal window"
    echo "  ❌ Browser showing different URL than expected"
    echo "  ❌ Copying from wrong place in browser"
    echo
    
    log_step "STEP 5: Verification"
    echo "  After successful auth: :Augment status"
    echo "  Should show: 'Signed in' status"
    echo
}

show_manual_testing_instructions() {
    log_header "Manual Testing Instructions"
    
    log_info "Ready to test? Follow these exact steps:"
    echo
    echo "1. Open NEW terminal window"
    echo "2. cd ~/dotfiles"
    echo "3. nvim test.go"
    echo "4. In Neovim type: :Augment signin"
    echo "5. Browser will open - complete authentication"
    echo "6. Copy ENTIRE JSON response from browser"
    echo "7. Return to SAME terminal with Neovim"
    echo "8. Paste the authentication response"
    echo "9. Check status: :Augment status"
    echo
    
    log_warning "If authentication still fails, run: :Augment log"
    echo "This will show detailed error information."
    echo
}

# Execute main function
main "$@"
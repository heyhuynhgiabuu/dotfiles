#!/bin/bash

# AugmentCode Environment Test Script
# Tests AugmentCode installation and environment
# Usage: bash scripts/test-augmentcode.sh

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

main() {
    log_header "AugmentCode Environment Test"
    
    # Setup test environment
    setup_test_environment
    
    # Run comprehensive tests
    run_environment_tests
    run_plugin_tests
    
    # Show manual testing instructions
    show_manual_testing_guide
}

setup_test_environment() {
    log_info "Setting up test environment..."
    
    # Load NVM and setup Node.js
    setup_nodejs "22"
}

run_environment_tests() {
    log_info "Running environment tests..."
    
    # Test Node.js
    if cmd_exists node; then
        log_success "Node.js version: $(node --version)"
    else
        log_error "Node.js not available"
    fi
    
    # Test NPM
    if cmd_exists npm; then
        log_success "NPM version: $(npm --version)"
    else
        log_error "NPM not available"
    fi
    
    # Test Neovim
    if cmd_exists nvim; then
        log_success "Neovim version: $(nvim --version | head -1)"
    else
        log_error "Neovim not available"
    fi
    echo
}

run_plugin_tests() {
    log_info "Testing AugmentCode plugin loading..."
    
    # Test plugin with comprehensive check
    nvim --headless -c "
lua print('Testing AugmentCode plugin...')
lua local commands = vim.api.nvim_get_commands({})
lua for cmd, _ in pairs(commands) do 
lua   if cmd:lower():find('augment') then 
lua     print('✅ AugmentCode command found: ' .. cmd) 
lua   end 
lua end
lua local handle = io.popen('node --version 2>&1')
lua local node_version = handle:read('*a'):gsub('
', '')
lua handle:close()
lua print('Node.js accessible from Neovim: ' .. node_version)
qall
"
    echo
}

show_manual_testing_guide() {
    log_header "Manual Testing Instructions"
    
    log_info "Follow these steps to test AugmentCode:"
    echo "1. Open Neovim: nvim test.go"
    echo "2. Try sign-in: :Augment signin"
    echo "3. If authentication fails, check the error message carefully"
    echo "4. Look for any Node.js related errors"
    echo
    
    log_info "Expected authentication flow:"
    echo "- AugmentCode will provide a JSON response with auth details"
    echo "- Copy the FULL response (may wrap multiple lines)"
    echo "- Paste it in the terminal when prompted"
    echo
    
    log_warning "If issues persist:"
    echo "- Run: debug-augmentcode-auth.sh for detailed diagnostics"
    echo "- Check: augmentcode-auth-guide.sh for step-by-step instructions"
}

# Execute main function
main "$@"#!/bin/bash

# AugmentCode Environment Test Script
# Tests AugmentCode installation and environment
# Usage: bash scripts/test-augmentcode.sh

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

main() {
    log_header "AugmentCode Environment Test"
    
    # Setup test environment
    setup_test_environment
    
    # Run comprehensive tests
    run_environment_tests
    run_plugin_tests
    
    # Show manual testing instructions
    show_manual_testing_guide
}

setup_test_environment() {
    log_info "Setting up test environment..."
    
    # Load NVM and setup Node.js
    setup_nodejs "22"
}

run_environment_tests() {
    log_info "Running environment tests..."
    
    # Test Node.js
    if cmd_exists node; then
        log_success "Node.js version: $(node --version)"
    else
        log_error "Node.js not available"
    fi
    
    # Test NPM
    if cmd_exists npm; then
        log_success "NPM version: $(npm --version)"
    else
        log_error "NPM not available"
    fi
    
    # Test Neovim
    if cmd_exists nvim; then
        log_success "Neovim version: $(nvim --version | head -1)"
    else
        log_error "Neovim not available"
    fi
    echo
}

run_plugin_tests() {
    log_info "Testing AugmentCode plugin loading..."
    
    # Test plugin with comprehensive check
    nvim --headless -c "
lua print('Testing AugmentCode plugin...')
lua local commands = vim.api.nvim_get_commands({})
lua for cmd, _ in pairs(commands) do 
lua   if cmd:lower():find('augment') then 
lua     print('✅ AugmentCode command found: ' .. cmd) 
lua   end 
lua end
lua local handle = io.popen('node --version 2>&1')
lua local node_version = handle:read('*a'):gsub('
', '')
lua handle:close()
lua print('Node.js accessible from Neovim: ' .. node_version)
qall
"
    echo
}

show_manual_testing_guide() {
    log_header "Manual Testing Instructions"
    
    log_info "Follow these steps to test AugmentCode:"
    echo "1. Open Neovim: nvim test.go"
    echo "2. Try sign-in: :Augment signin"
    echo "3. If authentication fails, check the error message carefully"
    echo "4. Look for any Node.js related errors"
    echo
    
    log_info "Expected authentication flow:"
    echo "- AugmentCode will provide a JSON response with auth details"
    echo "- Copy the FULL response (may wrap multiple lines)"
    echo "- Paste it in the terminal when prompted"
    echo
    
    log_warning "If issues persist:"
    echo "- Run: debug-augmentcode-auth.sh for detailed diagnostics"
    echo "- Check: augmentcode-auth-guide.sh for step-by-step instructions"
}

# Execute main function
main "$@"
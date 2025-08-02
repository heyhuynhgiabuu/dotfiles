#!/bin/bash

# AugmentCode JSON Parsing Debug Script
# Deep debugging for JSON authentication parsing errors
# Usage: bash scripts/debug-json-auth.sh

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

main() {
    log_header "AugmentCode Deep Debug - JSON Parsing Error"
    
    # Setup debug environment
    setup_debug_environment
    
    # Show environment status
    show_environment_status
    
    # Debug JSON format issues
    debug_json_format
    
    # Show testing procedures
    show_testing_steps
    
    # Show alternative methods
    show_alternative_methods
    
    # Show debugging questions
    show_debugging_questions
}

setup_debug_environment() {
    log_info "Setting up debug environment..."
    
    # Load NVM and setup Node.js
    setup_nodejs "22"
}

show_environment_status() {
    log_info "Environment Status:"
    
    if cmd_exists node; then
        echo "  Node.js: $(node --version)"
    else
        echo "  Node.js: Not found"
    fi
    
    if cmd_exists nvim; then
        echo "  Neovim: $(nvim --version | head -1)"
    else
        echo "  Neovim: Not found"
    fi
    echo
}

debug_json_format() {
    log_header "JSON Format Debugging"
    
    log_info "Expected JSON format:"
    echo '{"code":"xxxxxxxx","state":"xxxxxxxx","tenant_url":"https://i0.api.augmentcode.com/"}'
    echo
    
    log_error "Common JSON formatting issues:"
    echo "  ❌ Extra whitespace or newlines"
    echo "  ❌ Missing quotes around values"
    echo "  ❌ Incomplete JSON (missing brackets)"
    echo "  ❌ Special characters not properly escaped"
    echo "  ❌ Browser encoding issues (UTF-8)"
    echo "  ❌ Copy/paste corruption"
    echo
}

show_testing_steps() {
    log_header "Testing Steps"
    
    log_step "1. Try authentication again:"
    echo "   cd ~/dotfiles"
    echo "   nvim test.go"
    echo "   :Augment signin"
    echo
    
    log_step "2. Before pasting JSON:"
    echo "   - Check exact format in browser"
    echo "   - Look for any extra text before/after JSON"
    echo "   - Verify JSON is valid using browser dev tools"
    echo
    
    log_step "3. Copy procedure:"
    echo "   - Select ONLY the JSON object (no extra text)"
    echo "   - Avoid copying from page source if rendered differently"
    echo "   - Use plain text editor to verify format before pasting"
    echo
    
    log_step "4. If authentication fails:"
    echo "   - Immediately run: :Augment log"
    echo "   - Look for specific error messages"
    echo "   - Note the exact point of failure"
    echo
}

show_alternative_methods() {
    log_header "Alternative Methods"
    
    log_info "Method 1: Clear cache and retry"
    echo "  :Augment signout"
    echo "  Close Neovim completely"
    echo "  Clear cache files:"
    echo "    rm -rf ~/.cache/augment* 2>/dev/null"
    echo "    rm -rf ~/.local/share/augment* 2>/dev/null"
    echo "  Restart Neovim"
    echo "  :Augment signin"
    echo
    
    log_info "Method 2: Plugin update"
    echo "  In Neovim: :Lazy sync"
    echo "  Wait for all updates to complete"
    echo "  Restart Neovim completely"
    echo "  Try authentication again"
    echo
    
    log_info "Method 3: Different browser"
    echo "  Try authentication in:"
    echo "  - Chrome (incognito mode)"
    echo "  - Firefox (private mode)"
    echo "  - Safari (private mode)"
    echo "  Disable all browser extensions"
    echo
    
    log_info "Method 4: Manual account verification"
    echo "  1. Go to https://augmentcode.com"
    echo "  2. Sign in with your account"
    echo "  3. Verify account is active"
    echo "  4. Check for any pending verifications"
    echo "  5. Then try Neovim authentication"
    echo
}

show_debugging_questions() {
    log_header "Debugging Questions"
    
    log_info "Help us diagnose the issue:"
    echo "1. What does the exact JSON look like in your browser?"
    echo "2. Are you copying from the page source or rendered page?"
    echo "3. Does :Augment log show specific error details?"
    echo "4. Are you using any browser extensions that might modify JSON?"
    echo "5. Does the JSON validate when pasted into a JSON validator?"
    echo "6. Are you using the same terminal session for authentication?"
    echo "7. Is there any firewall or network proxy affecting the connection?"
    echo
    
    log_warning "Pro tip: Paste the JSON into https://jsonlint.com to validate format"
    echo
    
    log_info "Still having issues?"
    echo "- Run: augmentcode-multi-fix.sh for more solutions"
    echo "- Check: debug-augmentcode-auth.sh for general debugging"
    echo "- Review: augmentcode-auth-guide.sh for step-by-step instructions"
}

# Execute main function
main "$@"#!/bin/bash

# AugmentCode JSON Parsing Debug Script
# Deep debugging for JSON authentication parsing errors
# Usage: bash scripts/debug-json-auth.sh

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

main() {
    log_header "AugmentCode Deep Debug - JSON Parsing Error"
    
    # Setup debug environment
    setup_debug_environment
    
    # Show environment status
    show_environment_status
    
    # Debug JSON format issues
    debug_json_format
    
    # Show testing procedures
    show_testing_steps
    
    # Show alternative methods
    show_alternative_methods
    
    # Show debugging questions
    show_debugging_questions
}

setup_debug_environment() {
    log_info "Setting up debug environment..."
    
    # Load NVM and setup Node.js
    setup_nodejs "22"
}

show_environment_status() {
    log_info "Environment Status:"
    
    if cmd_exists node; then
        echo "  Node.js: $(node --version)"
    else
        echo "  Node.js: Not found"
    fi
    
    if cmd_exists nvim; then
        echo "  Neovim: $(nvim --version | head -1)"
    else
        echo "  Neovim: Not found"
    fi
    echo
}

debug_json_format() {
    log_header "JSON Format Debugging"
    
    log_info "Expected JSON format:"
    echo '{"code":"xxxxxxxx","state":"xxxxxxxx","tenant_url":"https://i0.api.augmentcode.com/"}'
    echo
    
    log_error "Common JSON formatting issues:"
    echo "  ❌ Extra whitespace or newlines"
    echo "  ❌ Missing quotes around values"
    echo "  ❌ Incomplete JSON (missing brackets)"
    echo "  ❌ Special characters not properly escaped"
    echo "  ❌ Browser encoding issues (UTF-8)"
    echo "  ❌ Copy/paste corruption"
    echo
}

show_testing_steps() {
    log_header "Testing Steps"
    
    log_step "1. Try authentication again:"
    echo "   cd ~/dotfiles"
    echo "   nvim test.go"
    echo "   :Augment signin"
    echo
    
    log_step "2. Before pasting JSON:"
    echo "   - Check exact format in browser"
    echo "   - Look for any extra text before/after JSON"
    echo "   - Verify JSON is valid using browser dev tools"
    echo
    
    log_step "3. Copy procedure:"
    echo "   - Select ONLY the JSON object (no extra text)"
    echo "   - Avoid copying from page source if rendered differently"
    echo "   - Use plain text editor to verify format before pasting"
    echo
    
    log_step "4. If authentication fails:"
    echo "   - Immediately run: :Augment log"
    echo "   - Look for specific error messages"
    echo "   - Note the exact point of failure"
    echo
}

show_alternative_methods() {
    log_header "Alternative Methods"
    
    log_info "Method 1: Clear cache and retry"
    echo "  :Augment signout"
    echo "  Close Neovim completely"
    echo "  Clear cache files:"
    echo "    rm -rf ~/.cache/augment* 2>/dev/null"
    echo "    rm -rf ~/.local/share/augment* 2>/dev/null"
    echo "  Restart Neovim"
    echo "  :Augment signin"
    echo
    
    log_info "Method 2: Plugin update"
    echo "  In Neovim: :Lazy sync"
    echo "  Wait for all updates to complete"
    echo "  Restart Neovim completely"
    echo "  Try authentication again"
    echo
    
    log_info "Method 3: Different browser"
    echo "  Try authentication in:"
    echo "  - Chrome (incognito mode)"
    echo "  - Firefox (private mode)"
    echo "  - Safari (private mode)"
    echo "  Disable all browser extensions"
    echo
    
    log_info "Method 4: Manual account verification"
    echo "  1. Go to https://augmentcode.com"
    echo "  2. Sign in with your account"
    echo "  3. Verify account is active"
    echo "  4. Check for any pending verifications"
    echo "  5. Then try Neovim authentication"
    echo
}

show_debugging_questions() {
    log_header "Debugging Questions"
    
    log_info "Help us diagnose the issue:"
    echo "1. What does the exact JSON look like in your browser?"
    echo "2. Are you copying from the page source or rendered page?"
    echo "3. Does :Augment log show specific error details?"
    echo "4. Are you using any browser extensions that might modify JSON?"
    echo "5. Does the JSON validate when pasted into a JSON validator?"
    echo "6. Are you using the same terminal session for authentication?"
    echo "7. Is there any firewall or network proxy affecting the connection?"
    echo
    
    log_warning "Pro tip: Paste the JSON into https://jsonlint.com to validate format"
    echo
    
    log_info "Still having issues?"
    echo "- Run: augmentcode-multi-fix.sh for more solutions"
    echo "- Check: debug-augmentcode-auth.sh for general debugging"
    echo "- Review: augmentcode-auth-guide.sh for step-by-step instructions"
}

# Execute main function
main "$@"
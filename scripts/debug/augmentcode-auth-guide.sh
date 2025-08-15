#!/usr/bin/env sh

# AugmentCode Authentication Step-by-Step Guide
# Provides detailed instructions for AugmentCode authentication
# Usage: bash scripts/augmentcode-auth-guide.sh

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

main() {
    log_header "AugmentCode Authentication Step-by-Step Guide"
    
    show_preparation_steps
    show_authentication_steps
    show_common_mistakes
    show_troubleshooting_tips
    
    log_info "Ready to test? Follow the steps above exactly!"
}

show_preparation_steps() {
    log_info "PREPARATION:"
    echo "1. Close all Neovim instances"
    echo "2. Open a fresh terminal"
    echo "3. Ensure Node.js v22 is active:"
    echo "   source ~/.nvm/nvm.sh && nvm use v22.14.0"
    echo
}

show_authentication_steps() {
    log_info "AUTHENTICATION STEPS:"
    echo
    log_step "STEP 1: Start authentication"
    echo "  cd ~/dotfiles"
    echo "  nvim test.go"
    echo "  :Augment signin"
    echo
    
    log_step "STEP 2: Manual URL handling"
    log_warning "The URL will appear in Neovim's message area"
    log_warning "You CANNOT click it or use 'gx' to open it"
    log_success "MANUALLY select and copy the entire URL"
    log_success "Paste it into your browser address bar"
    echo
    
    log_step "STEP 3: Browser authentication"
    echo "  - Complete sign-in in browser"
    echo "  - Accept terms if prompted"
    echo "  - Browser will show a JSON response"
    echo
    
    log_step "STEP 4: Copy complete JSON response"
    log_warning "Do NOT copy just the 'code' value"
    log_success "Copy the ENTIRE JSON object, example:"
    echo '     {"code":"xyz123","state":"abc456","tenant_url":"https://i0.api.augmentcode.com/"}'
    echo
    
    log_step "STEP 5: Return to terminal"
    echo "  - Go back to the SAME terminal where Neovim is running"
    echo "  - Paste the complete JSON when prompted"
    echo "  - Press Enter"
    echo
    
    log_step "STEP 6: Verify success"
    echo "  :Augment status"
    echo "  Should show: 'Signed in: true' or similar"
    echo
}

show_common_mistakes() {
    log_error "COMMON MISTAKES TO AVOID:"
    echo "  ❌ Trying to click the URL in Neovim"
    echo "  ❌ Using 'gx' command on the URL"
    echo "  ❌ Copying only the 'code' part"
    echo "  ❌ Switching to different terminal"
    echo "  ❌ Taking too long (session timeout)"
    echo
}

show_troubleshooting_tips() {
    log_info "TROUBLESHOOTING:"
    echo "  If still failing:"
    echo "  1. :Augment log (show detailed errors)"
    echo "  2. Try :Augment signout then :Augment signin"
    echo "  3. Restart Neovim and try again"
    echo "  4. Check Node.js version: node --version"
    echo
}

# Execute main function
main "$@"#!/bin/bash

# AugmentCode Authentication Step-by-Step Guide
# Provides detailed instructions for AugmentCode authentication
# Usage: bash scripts/augmentcode-auth-guide.sh

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

main() {
    log_header "AugmentCode Authentication Step-by-Step Guide"
    
    show_preparation_steps
    show_authentication_steps
    show_common_mistakes
    show_troubleshooting_tips
    
    log_info "Ready to test? Follow the steps above exactly!"
}

show_preparation_steps() {
    log_info "PREPARATION:"
    echo "1. Close all Neovim instances"
    echo "2. Open a fresh terminal"
    echo "3. Ensure Node.js v22 is active:"
    echo "   source ~/.nvm/nvm.sh && nvm use v22.14.0"
    echo
}

show_authentication_steps() {
    log_info "AUTHENTICATION STEPS:"
    echo
    log_step "STEP 1: Start authentication"
    echo "  cd ~/dotfiles"
    echo "  nvim test.go"
    echo "  :Augment signin"
    echo
    
    log_step "STEP 2: Manual URL handling"
    log_warning "The URL will appear in Neovim's message area"
    log_warning "You CANNOT click it or use 'gx' to open it"
    log_success "MANUALLY select and copy the entire URL"
    log_success "Paste it into your browser address bar"
    echo
    
    log_step "STEP 3: Browser authentication"
    echo "  - Complete sign-in in browser"
    echo "  - Accept terms if prompted"
    echo "  - Browser will show a JSON response"
    echo
    
    log_step "STEP 4: Copy complete JSON response"
    log_warning "Do NOT copy just the 'code' value"
    log_success "Copy the ENTIRE JSON object, example:"
    echo '     {"code":"xyz123","state":"abc456","tenant_url":"https://i0.api.augmentcode.com/"}'
    echo
    
    log_step "STEP 5: Return to terminal"
    echo "  - Go back to the SAME terminal where Neovim is running"
    echo "  - Paste the complete JSON when prompted"
    echo "  - Press Enter"
    echo
    
    log_step "STEP 6: Verify success"
    echo "  :Augment status"
    echo "  Should show: 'Signed in: true' or similar"
    echo
}

show_common_mistakes() {
    log_error "COMMON MISTAKES TO AVOID:"
    echo "  ❌ Trying to click the URL in Neovim"
    echo "  ❌ Using 'gx' command on the URL"
    echo "  ❌ Copying only the 'code' part"
    echo "  ❌ Switching to different terminal"
    echo "  ❌ Taking too long (session timeout)"
    echo
}

show_troubleshooting_tips() {
    log_info "TROUBLESHOOTING:"
    echo "  If still failing:"
    echo "  1. :Augment log (show detailed errors)"
    echo "  2. Try :Augment signout then :Augment signin"
    echo "  3. Restart Neovim and try again"
    echo "  4. Check Node.js version: node --version"
    echo
}

# Execute main function
main "$@"
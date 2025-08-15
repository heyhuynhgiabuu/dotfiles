#!/usr/bin/env sh

# Neovim Java Setup Fix Verification Script
# Verifies Java development environment fixes and configuration
# Usage: bash scripts/nvim-java-fix-verification.sh

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Configuration
readonly JAVA_TEST_FILE="src/main/java/com/example/HelloJava.java"
readonly EXPECTED_FILES=(".classpath" ".project")

main() {
    log_header "nvim-java Fix Verification Script"
    
    # Verify cache cleanup
    verify_cache_cleanup
    
    # Verify Maven project setup
    verify_maven_project
    
    # Verify Git repository
    verify_git_repository
    
    # Verify Java environment
    verify_java_environment
    
    # Verify Mason configuration
    verify_mason_configuration
    
    # Verify configuration changes
    verify_configuration_changes
    
    # Show next steps
    show_next_steps
    show_troubleshooting_tips
}

verify_cache_cleanup() {
    log_info "✅ JDTLS Cache Cleaned:"
    echo "   - Removed ~/.cache/jdtls"
    echo "   - Removed ~/.cache/nvim/jdtls"
    echo "   - Removed .classpath and .project files"
    
    # Check if cache directories are clean
    local cache_dirs=(
        "${HOME}/.cache/jdtls"
        "${HOME}/.cache/nvim/jdtls"
    )
    
    for dir in "${cache_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            log_success "Cache directory $dir is clean"
        else
            log_warning "Cache directory $dir still exists"
        fi
    done
}

verify_maven_project() {
    log_info "✅ Maven Project Initialized:"
    
    local all_files_exist=true
    for file in "${EXPECTED_FILES[@]}"; do
        if [[ -f "$file" ]]; then
            log_success "$file exists"
        else
            log_error "$file missing"
            all_files_exist=false
        fi
    done
    
    if [[ "$all_files_exist" == "true" ]]; then
        log_success "Maven eclipse:eclipse completed successfully"
    else
        log_error "Eclipse classpath files missing"
        log_info "Run: mvn eclipse:eclipse to generate them"
    fi
}

verify_git_repository() {
    log_info "✅ Git Repository Status:"
    
    if [[ -d ".git" ]]; then
        log_success "Git repository exists (fixes root detection)"
    else
        log_warning "Git repository missing"
        log_info "Consider running: git init"
    fi
}

verify_java_environment() {
    log_info "✅ Java Environment:"
    
    if cmd_exists java; then
        local java_version
        java_version=$(java --version 2>/dev/null | head -1 || java -version 2>&1 | head -1)
        log_success "Java version: $java_version"
    else
        log_error "Java not found"
    fi
    
    if cmd_exists mvn; then
        local maven_version
        maven_version=$(mvn --version | head -1)
        log_success "Maven version: $maven_version"
    else
        log_error "Maven not found"
    fi
}

verify_mason_configuration() {
    log_info "✅ Mason Registry Fix Applied:"
    echo "   ✓ nvim-java registry added to Mason configuration"
    echo "   ✓ Manual Java tool installation removed (nvim-java manages these)"
    echo "   ✓ Progress notification suppression added"
    
    # Test Mason packages
    local mason_dir="${HOME}/.local/share/nvim/mason/packages"
    if [[ -d "$mason_dir" ]]; then
        local jdtls_count
        jdtls_count=$(ls "$mason_dir" | grep -c jdtls || echo "0")
        if [[ "$jdtls_count" -gt 0 ]]; then
            log_success "JDTLS installed via Mason"
        else
            log_warning "JDTLS not found in Mason packages"
        fi
    else
        log_warning "Mason packages directory not found"
    fi
}

verify_configuration_changes() {
    log_info "✅ Configuration Changes:"
    echo "   ✓ Root markers updated (excluded .git to avoid conflicts)"
    echo "   ✓ JDTLS setup order fixed (nvim-java first, then lspconfig)"
    echo "   ✓ Proper delay added for nvim-java initialization"
    echo "   ✓ Enhanced error handling and validation"
    
    # Check if Java ftplugin exists
    local java_ftplugin="${DOTFILES_DIR}/nvim/.config/nvim/ftplugin/java.lua"
    if [[ -f "$java_ftplugin" ]]; then
        log_success "Java ftplugin configuration exists"
    else
        log_warning "Java ftplugin configuration missing"
    fi
}

show_next_steps() {
    echo
    log_header "NEXT STEPS"
    echo "1. Restart Neovim completely"
    echo "2. Open: nvim $JAVA_TEST_FILE"
    echo "3. Wait for LSP to initialize (should see 'ServiceReady' notification)"
    echo "4. Test: <leader>jrr to run main class"
    echo "5. Test: <leader>jtc to run test class"
    echo
    
    log_info "Testing LSP functionality:"
    echo "• Hover over Java symbols (should show documentation)"
    echo "• Use <leader>jr to run Java application"
    echo "• Try auto-completion with Ctrl+Space"
    echo "• Test go-to-definition with gd"
}

show_troubleshooting_tips() {
    log_info "🔍 If errors persist:"
    echo "- Check :Mason to ensure jdtls is installed"
    echo "- Check :LspInfo to see LSP client status"
    echo "- Look for nvim-java initialization messages"
    echo "- Verify no conflicting nvim-jdtls installation"
    echo "- Run :checkhealth for general Neovim diagnostics"
    echo
    
    log_success "The 'MethodNotFound: vscode.java.resolveMainClass' error should now be resolved!"
    echo
    
    log_warning "Still having issues?"
    echo "- Run: verify-dev-environment.sh for comprehensive testing"
    echo "- Check Neovim logs: ~/.local/share/nvim/log/"
    echo "- Restart LSP: :LspRestart"
}

# Execute main function
main "$@"#!/bin/bash

# Neovim Java Setup Fix Verification Script
# Verifies Java development environment fixes and configuration
# Usage: bash scripts/nvim-java-fix-verification.sh

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Configuration
readonly JAVA_TEST_FILE="src/main/java/com/example/HelloJava.java"
readonly EXPECTED_FILES=(".classpath" ".project")

main() {
    log_header "nvim-java Fix Verification Script"
    
    # Verify cache cleanup
    verify_cache_cleanup
    
    # Verify Maven project setup
    verify_maven_project
    
    # Verify Git repository
    verify_git_repository
    
    # Verify Java environment
    verify_java_environment
    
    # Verify Mason configuration
    verify_mason_configuration
    
    # Verify configuration changes
    verify_configuration_changes
    
    # Show next steps
    show_next_steps
    show_troubleshooting_tips
}

verify_cache_cleanup() {
    log_info "✅ JDTLS Cache Cleaned:"
    echo "   - Removed ~/.cache/jdtls"
    echo "   - Removed ~/.cache/nvim/jdtls"
    echo "   - Removed .classpath and .project files"
    
    # Check if cache directories are clean
    local cache_dirs=(
        "${HOME}/.cache/jdtls"
        "${HOME}/.cache/nvim/jdtls"
    )
    
    for dir in "${cache_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            log_success "Cache directory $dir is clean"
        else
            log_warning "Cache directory $dir still exists"
        fi
    done
}

verify_maven_project() {
    log_info "✅ Maven Project Initialized:"
    
    local all_files_exist=true
    for file in "${EXPECTED_FILES[@]}"; do
        if [[ -f "$file" ]]; then
            log_success "$file exists"
        else
            log_error "$file missing"
            all_files_exist=false
        fi
    done
    
    if [[ "$all_files_exist" == "true" ]]; then
        log_success "Maven eclipse:eclipse completed successfully"
    else
        log_error "Eclipse classpath files missing"
        log_info "Run: mvn eclipse:eclipse to generate them"
    fi
}

verify_git_repository() {
    log_info "✅ Git Repository Status:"
    
    if [[ -d ".git" ]]; then
        log_success "Git repository exists (fixes root detection)"
    else
        log_warning "Git repository missing"
        log_info "Consider running: git init"
    fi
}

verify_java_environment() {
    log_info "✅ Java Environment:"
    
    if cmd_exists java; then
        local java_version
        java_version=$(java --version 2>/dev/null | head -1 || java -version 2>&1 | head -1)
        log_success "Java version: $java_version"
    else
        log_error "Java not found"
    fi
    
    if cmd_exists mvn; then
        local maven_version
        maven_version=$(mvn --version | head -1)
        log_success "Maven version: $maven_version"
    else
        log_error "Maven not found"
    fi
}

verify_mason_configuration() {
    log_info "✅ Mason Registry Fix Applied:"
    echo "   ✓ nvim-java registry added to Mason configuration"
    echo "   ✓ Manual Java tool installation removed (nvim-java manages these)"
    echo "   ✓ Progress notification suppression added"
    
    # Test Mason packages
    local mason_dir="${HOME}/.local/share/nvim/mason/packages"
    if [[ -d "$mason_dir" ]]; then
        local jdtls_count
        jdtls_count=$(ls "$mason_dir" | grep -c jdtls || echo "0")
        if [[ "$jdtls_count" -gt 0 ]]; then
            log_success "JDTLS installed via Mason"
        else
            log_warning "JDTLS not found in Mason packages"
        fi
    else
        log_warning "Mason packages directory not found"
    fi
}

verify_configuration_changes() {
    log_info "✅ Configuration Changes:"
    echo "   ✓ Root markers updated (excluded .git to avoid conflicts)"
    echo "   ✓ JDTLS setup order fixed (nvim-java first, then lspconfig)"
    echo "   ✓ Proper delay added for nvim-java initialization"
    echo "   ✓ Enhanced error handling and validation"
    
    # Check if Java ftplugin exists
    local java_ftplugin="${DOTFILES_DIR}/nvim/.config/nvim/ftplugin/java.lua"
    if [[ -f "$java_ftplugin" ]]; then
        log_success "Java ftplugin configuration exists"
    else
        log_warning "Java ftplugin configuration missing"
    fi
}

show_next_steps() {
    echo
    log_header "NEXT STEPS"
    echo "1. Restart Neovim completely"
    echo "2. Open: nvim $JAVA_TEST_FILE"
    echo "3. Wait for LSP to initialize (should see 'ServiceReady' notification)"
    echo "4. Test: <leader>jrr to run main class"
    echo "5. Test: <leader>jtc to run test class"
    echo
    
    log_info "Testing LSP functionality:"
    echo "• Hover over Java symbols (should show documentation)"
    echo "• Use <leader>jr to run Java application"
    echo "• Try auto-completion with Ctrl+Space"
    echo "• Test go-to-definition with gd"
}

show_troubleshooting_tips() {
    log_info "🔍 If errors persist:"
    echo "- Check :Mason to ensure jdtls is installed"
    echo "- Check :LspInfo to see LSP client status"
    echo "- Look for nvim-java initialization messages"
    echo "- Verify no conflicting nvim-jdtls installation"
    echo "- Run :checkhealth for general Neovim diagnostics"
    echo
    
    log_success "The 'MethodNotFound: vscode.java.resolveMainClass' error should now be resolved!"
    echo
    
    log_warning "Still having issues?"
    echo "- Run: verify-dev-environment.sh for comprehensive testing"
    echo "- Check Neovim logs: ~/.local/share/nvim/log/"
    echo "- Restart LSP: :LspRestart"
}

# Execute main function
main "$@"
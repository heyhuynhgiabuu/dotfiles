#!/usr/bin/env bash
# Security verification script for dotfiles
# Checks for common security issues and provides recommendations

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

print_error() {
    printf "${RED}[ERROR]${NC} %s\n" "$1"
}

print_warning() {
    printf "${YELLOW}[WARN]${NC} %s\n" "$1"
}

print_success() {
    printf "${GREEN}[OK]${NC} %s\n" "$1"
}

print_header() {
    printf "\n${GREEN}=== %s ===${NC}\n" "$1"
}

check_file_permissions() {
    print_header "File Permissions Audit"
    
    local issues=0
    
    # Check sensitive files
    local sensitive_files=(
        "$HOME/.ssh/id_rsa"
        "$HOME/.ssh/id_ed25519"
        "$HOME/.aws/credentials"
        "$HOME/.netrc"
        "$DOTFILES_ROOT/.env"
    )
    
    for file in "${sensitive_files[@]}"; do
        if [[ -f "$file" ]]; then
            local perms
            perms=$(stat -f "%Lp" "$file" 2>/dev/null || stat -c "%a" "$file" 2>/dev/null)
            if [[ "$perms" != "600" ]]; then
                print_error "Insecure permissions on $file (current: $perms, should be: 600)"
                ((issues++))
            else
                print_success "Secure permissions on $file"
            fi
        fi
    done
    
    # Check SSH directory
    if [[ -d "$HOME/.ssh" ]]; then
        local ssh_perms
        ssh_perms=$(stat -f "%Lp" "$HOME/.ssh" 2>/dev/null || stat -c "%a" "$HOME/.ssh" 2>/dev/null)
        if [[ "$ssh_perms" != "700" ]]; then
            print_error "Insecure permissions on $HOME/.ssh (current: $ssh_perms, should be: 700)"
            ((issues++))
        else
            print_success "Secure permissions on $HOME/.ssh"
        fi
    fi
    
    return $issues
}

check_hardcoded_secrets() {
    print_header "Hardcoded Secrets Scan"
    
    local issues=0
    
    # Check for common secret patterns
    cd "$DOTFILES_ROOT"
    
    # High-entropy strings that could be API keys
    if rg -q "AKIA[0-9A-Z]{16}|[A-Za-z0-9+/]{40}|[0-9a-f]{32}|[0-9a-f]{64}" . 2>/dev/null; then
        print_error "Potential API keys or secrets found:"
        rg "AKIA[0-9A-Z]{16}|[A-Za-z0-9+/]{40}|[0-9a-f]{32}|[0-9a-f]{64}" . --max-count 5 || true
        ((issues++))
    fi
    
    # Common secret keywords (excluding documentation)
    if rg -q -i "password|secret|api[_-]?key|token|credential" --type-not md . 2>/dev/null; then
        print_warning "Potential credential references found (review manually):"
        rg -i "password|secret|api[_-]?key|token|credential" --type-not md . --max-count 5 || true
    fi
    
    if [[ $issues -eq 0 ]]; then
        print_success "No obvious hardcoded secrets found"
    fi
    
    return $issues
}

check_gitignore() {
    print_header "Git Ignore Configuration"
    
    local issues=0
    local gitignore="$DOTFILES_ROOT/.gitignore"
    
    local required_patterns=(
        ".env"
        "*.key"
        "*.pem"
        "*credentials*"
        "*secret*"
    )
    
    for pattern in "${required_patterns[@]}"; do
        if ! grep -q "^$pattern$" "$gitignore" 2>/dev/null; then
            print_warning "Missing gitignore pattern: $pattern"
            ((issues++))
        fi
    done
    
    if [[ $issues -eq 0 ]]; then
        print_success "Git ignore configuration looks good"
    fi
    
    return $issues
}

check_command_injection() {
    print_header "Command Injection Vulnerabilities"
    
    local issues=0
    
    # Look for potentially unsafe shell patterns
    cd "$DOTFILES_ROOT"
    
    # Unsafe command substitution patterns
    if rg -q '\$\([^)]*\$[^)]*\)' . 2>/dev/null; then
        print_warning "Potentially unsafe command substitution found (manual review needed):"
        rg '\$\([^)]*\$[^)]*\)' . --max-count 3 || true
    fi
    
    # eval usage (often dangerous)
    if rg -q '\beval\b' . 2>/dev/null; then
        print_warning "eval usage found (review for safety):"
        rg '\beval\b' . --max-count 3 || true
    fi
    
    print_success "Command injection check completed"
    
    return $issues
}

main() {
    printf "${GREEN}Dotfiles Security Verification${NC}\n"
    printf "Scanning: %s\n\n" "$DOTFILES_ROOT"
    
    local total_issues=0
    
    check_file_permissions || ((total_issues += $?))
    check_hardcoded_secrets || ((total_issues += $?))
    check_gitignore || ((total_issues += $?))
    check_command_injection || ((total_issues += $?))
    
    print_header "Summary"
    
    if [[ $total_issues -eq 0 ]]; then
        print_success "No critical security issues found!"
    else
        print_error "Found $total_issues security issues that need attention"
        printf "\nRecommendations:\n"
        printf "1. Fix file permissions: chmod 600 for sensitive files, chmod 700 for .ssh\n"
        printf "2. Move secrets to environment variables or secure credential stores\n"
        printf "3. Add missing patterns to .gitignore\n"
        printf "4. Review and sanitize command substitutions\n"
        return 1
    fi
}

main "$@"
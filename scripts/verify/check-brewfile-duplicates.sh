#!/usr/bin/env sh
#
# Check for duplicate packages across Brewfile layers
# Reports duplicates and suggests consolidation

set -e

# Source common utilities
SCRIPT_DIR="$(dirname "${0}")"
source "${SCRIPT_DIR}/../common.sh"

log_header "Checking Brewfile duplicates"

HOMEBREW_DIR="${DOTFILES_DIR}/homebrew"

if [[ ! -d "$HOMEBREW_DIR" ]]; then
    log_error "Homebrew directory not found: $HOMEBREW_DIR"
    exit 1
fi

log_info "Analyzing Brewfile packages..."

# Extract all packages from all Brewfiles
ALL_PACKAGES=$(cat "${HOMEBREW_DIR}"/Brewfile* 2>/dev/null | grep "^brew " | cut -d'"' -f2 | sort)

# Find duplicates
DUPLICATES=$(echo "$ALL_PACKAGES" | uniq -d)

if [[ -n "$DUPLICATES" ]]; then
    log_warning "Found duplicate packages across Brewfiles:"
    echo "$DUPLICATES" | while read -r package; do
        echo "  📦 $package"
        grep -l "brew \"$package\"" "${HOMEBREW_DIR}"/Brewfile* | sed 's|.*/||' | sed 's/^/    - /'
    done
    
    DUPLICATE_COUNT=$(echo "$DUPLICATES" | wc -l | tr -d ' ')
    log_warning "Total duplicates: $DUPLICATE_COUNT"
    
    log_info "Recommendations:"
    echo "  1. Keep packages in the most appropriate layer (min -> dev -> gui -> extra)"
    echo "  2. Remove duplicates from higher layers"
    echo "  3. Use comments to document layer rationale"
    
    exit 1
else
    log_success "No duplicate packages found across Brewfiles"
    exit 0
fi
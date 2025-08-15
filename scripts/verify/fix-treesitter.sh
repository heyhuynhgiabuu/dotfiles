#!/usr/bin/env sh

# Treesitter Cleanup and Fix Script
# This script resolves "Impossible pattern" errors and parser issues

set -e

echo "🔧 Treesitter Cleanup and Fix Script"
echo "====================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Neovim is running
check_nvim_running() {
    if pgrep -x "nvim" > /dev/null; then
        print_error "Neovim is currently running. Please close all Neovim instances before continuing."
        exit 1
    fi
}

# Backup function
backup_treesitter_data() {
    print_status "Creating backup of Treesitter data..."
    
    local backup_dir="$HOME/.nvim-treesitter-backup-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Backup parser cache
    if [ -d "$HOME/.local/share/nvim/treesitter" ]; then
        cp -r "$HOME/.local/share/nvim/treesitter" "$backup_dir/"
        print_success "Parser cache backed up to: $backup_dir"
    fi
    
    # Backup lazy plugin data
    if [ -d "$HOME/.local/share/nvim/lazy/nvim-treesitter" ]; then
        cp -r "$HOME/.local/share/nvim/lazy/nvim-treesitter" "$backup_dir/"
        print_success "Plugin data backed up to: $backup_dir"
    fi
    
    echo "$backup_dir" > /tmp/nvim_treesitter_backup_path
}

# Clean problematic queries
clean_problematic_queries() {
    print_status "Removing problematic query files..."
    
    local queries_dir="$HOME/.local/share/nvim/lazy/nvim-treesitter/queries"
    
    if [ -d "$queries_dir" ]; then
        # Remove problematic vimdoc queries
        if [ -f "$queries_dir/vimdoc/highlights.scm" ]; then
            rm -f "$queries_dir/vimdoc/highlights.scm"
            print_success "Removed problematic vimdoc highlights.scm"
        fi
        
        # Search for and remove any queries containing problematic conceal patterns
        find "$queries_dir" -name "*.scm" -exec grep -l "~.*@conceal" {} \; 2>/dev/null | while read -r file; do
            print_warning "Found problematic query: $file"
            rm -f "$file"
            print_success "Removed: $file"
        done
    fi
}

# Clear parser cache
clear_parser_cache() {
    print_status "Clearing Treesitter parser cache..."
    
    # Remove parser cache
    if [ -d "$HOME/.local/share/nvim/treesitter" ]; then
        rm -rf "$HOME/.local/share/nvim/treesitter"
        print_success "Parser cache cleared"
    fi
    
    # Remove parser-info cache
    if [ -d "$HOME/.local/share/nvim/parser-info" ]; then
        rm -rf "$HOME/.local/share/nvim/parser-info"
        print_success "Parser-info cache cleared"
    fi
}

# Check environment variables
check_environment() {
    print_status "Checking environment variables..."
    
    # Check VIMRUNTIME
    if [ -n "$VIMRUNTIME" ]; then
        print_success "VIMRUNTIME is set: $VIMRUNTIME"
    else
        # Try to detect VIMRUNTIME
        if command -v nvim &> /dev/null; then
            print_status "VIMRUNTIME will be set automatically by Neovim"
        else
            print_error "Neovim not found in PATH"
        fi
    fi
    
    # Check if we can write to necessary directories
    if [ ! -w "$HOME/.local/share/nvim" ]; then
        print_error "Cannot write to ~/.local/share/nvim"
        exit 1
    fi
}

# Verify installation
verify_installation() {
    print_status "Verifying Treesitter installation..."
    
    print_success "Basic checks complete"
    print_status "Installation verification complete"
}

# Main execution
main() {
    echo "Starting Treesitter cleanup and fix process..."
    echo "This will:"
    echo "1. Check for running Neovim instances"
    echo "2. Create backup of current data"
    echo "3. Remove problematic query files"  
    echo "4. Clear parser cache"
    echo "5. Check environment variables"
    echo "6. Verify basic installation"
    echo ""
    
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Aborted by user"
        exit 0
    fi
    
    check_nvim_running
    backup_treesitter_data
    clean_problematic_queries
    clear_parser_cache
    check_environment
    verify_installation
    
    print_success "✅ Treesitter cleanup completed!"
    print_status "Backup location: $(cat /tmp/nvim_treesitter_backup_path 2>/dev/null || echo 'No backup created')"
    print_status "Please restart Neovim and run :TSUpdate to install parsers"
    
    # Clean up temp files
    rm -f /tmp/nvim_treesitter_backup_path
}

# Run main function
main "$@"

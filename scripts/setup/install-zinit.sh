#!/usr/bin/env bash
# Security-hardened zinit installation script
# Replaces automatic git clone in .zshrc with explicit, validated installation

set -euo pipefail

ZINIT_DIR="$HOME/.local/share/zinit"
ZINIT_REPO="https://github.com/zdharma-continuum/zinit"
# Pin to specific commit for security (update as needed)
ZINIT_COMMIT="67697b89df5f9fef4ebab7a23ff0ed1dc3b5fbc4"  # Latest verified commit

print_status() {
    printf "\033[32m[INFO]\033[0m %s\n" "$1"
}

print_warning() {
    printf "\033[33m[WARN]\033[0m %s\n" "$1"
}

print_error() {
    printf "\033[31m[ERROR]\033[0m %s\n" "$1"
}

# Check if zinit is already installed
if [[ -f "$ZINIT_DIR/zinit.git/zinit.zsh" ]]; then
    print_warning "zinit is already installed at $ZINIT_DIR"
    printf "Do you want to reinstall? [y/N] "
    read -r response
    case "$response" in
        [yY]|[yY][eE][sS]) 
            print_status "Removing existing installation..."
            rm -rf "$ZINIT_DIR" ;;
        *) 
            print_status "Installation cancelled"
            exit 0 ;;
    esac
fi

# Create directory
print_status "Creating zinit directory: $ZINIT_DIR"
mkdir -p "$ZINIT_DIR"

# Clone with specific commit for security
print_status "Cloning zinit repository (pinned to commit $ZINIT_COMMIT)..."
if ! git clone "$ZINIT_REPO" "$ZINIT_DIR/zinit.git"; then
    print_error "Failed to clone zinit repository"
    exit 1
fi

# Checkout pinned commit
print_status "Checking out pinned commit for security..."
cd "$ZINIT_DIR/zinit.git"
if ! git checkout "$ZINIT_COMMIT"; then
    print_error "Failed to checkout pinned commit $ZINIT_COMMIT"
    exit 1
fi

# Verify installation
if [[ -f "$ZINIT_DIR/zinit.git/zinit.zsh" ]]; then
    print_status "zinit installed successfully!"
    print_status "Restart your shell or run 'source ~/.zshrc' to use zinit"
else
    print_error "Installation verification failed"
    exit 1
fi

# Security note
print_warning "Security: This installation is pinned to commit $ZINIT_COMMIT"
print_warning "To update, modify the ZINIT_COMMIT variable in this script and re-run"
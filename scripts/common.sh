#!/bin/bash
# 
# Common utilities and functions for dotfiles shell scripts
# Source this file in other scripts: source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
# Cross-platform compatible (macOS & Linux)

# Exit on error for scripts that source this
set -e

# Color definitions - standardized across all scripts
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_PURPLE='\033[0;35m'
readonly COLOR_CYAN='\033[0;36m'
readonly COLOR_WHITE='\033[1;37m'
readonly COLOR_RESET='\033[0m'

# Common directories - standardized paths
readonly DOTFILES_DIR="${HOME}/dotfiles"
readonly SCRIPTS_DIR="${DOTFILES_DIR}/scripts"
readonly NVIM_CONFIG_DIR="${HOME}/.config/nvim"
readonly NVIM_CUSTOM_DIR="${NVIM_CONFIG_DIR}/lua/custom"
readonly BIN_DIR="${HOME}/.bin"

# Platform detection
detect_platform() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux)  echo "linux" ;;
        *)      echo "unknown" ;;
    esac
}

readonly PLATFORM=$(detect_platform)

# Logging functions with consistent formatting
log_info() {
    echo -e "${COLOR_BLUE}📋 $1${COLOR_RESET}"
}

log_success() {
    echo -e "${COLOR_GREEN}✅ $1${COLOR_RESET}"
}

log_warning() {
    echo -e "${COLOR_YELLOW}⚠️  $1${COLOR_RESET}"
}

log_error() {
    echo -e "${COLOR_RED}❌ $1${COLOR_RESET}"
}

log_step() {
    echo -e "${COLOR_CYAN}🔄 $1${COLOR_RESET}"
}

log_header() {
    echo -e "${COLOR_WHITE}🚀 $1${COLOR_RESET}"
    echo "$(printf '=%.0s' {1..50})"
}

# Command existence check - centralized function
cmd_exists() {
    command -v "$1" &> /dev/null
}

# Version comparison utility
version_gte() {
    printf '%s\n%s\n' "$2" "$1" | sort -V -C
}

# Detect the first available package manager (prioritized)
# Returns: brew | apt | yum | pacman | unknown
# Usage:
#   manager=$(detect_package_manager)
#   if [[ $manager == "unknown" ]]; then
#       log_error "No supported package manager found"
#   else
#       log_info "Using package manager: $manager"
#   fi
detect_package_manager() {
    if cmd_exists brew; then
        echo "brew"
    elif cmd_exists apt-get; then
        echo "apt"
    elif cmd_exists yum; then
        echo "yum"
    elif cmd_exists pacman; then
        echo "pacman"
    else
        echo "unknown"
    fi
}

# Cross-platform package installation (refactored to use detect_package_manager)
install_package() {
    local package="$1"
    local alt_name="${2:-$package}"

    local manager
    manager=$(detect_package_manager)
    if [[ "$manager" == "unknown" ]]; then
        log_error "No supported package manager found. Please install $package manually."
        return 1
    fi

    case "$manager" in
        brew)
            if ! cmd_exists brew; then
                log_error "Homebrew not found. Please install $package manually."
                return 1
            fi
            log_info "Installing $package via Homebrew..."
            # Attempt install, fallback to upgrade if already installed
            brew install "$alt_name" || brew upgrade "$alt_name" || true
            ;;
        apt)
            log_info "Installing $package via apt..."
            sudo apt-get update -y && sudo apt-get install -y "$package"
            ;;
        yum)
            log_info "Installing $package via yum..."
            sudo yum install -y "$package"
            ;;
        pacman)
            log_info "Installing $package via pacman..."
            sudo pacman -S --noconfirm "$package"
            ;;
    esac
}

# Node.js and NVM utilities
setup_nodejs() {
    local required_version="${1:-22}"
    
    # Load NVM if available
    if [[ -f "${HOME}/.nvm/nvm.sh" ]]; then
        source "${HOME}/.nvm/nvm.sh"
        
        # Check if required version is available
        if nvm list | grep -q "v${required_version}"; then
            log_info "Switching to Node.js v${required_version}..."
            nvm use "v${required_version}"
        else
            log_info "Installing Node.js v${required_version}..."
            nvm install "${required_version}"
            nvm use "${required_version}"
        fi
    elif ! cmd_exists node; then
        log_warning "Node.js not found. Installing..."
        install_package "node" "node"
    fi
    
    if cmd_exists node; then
        local current_version
        current_version=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
        if [[ "$current_version" -ge "$required_version" ]]; then
            log_success "Node.js $(node --version) is ready"
            return 0
        else
            log_error "Node.js version $current_version is too old. Required: v${required_version}+"
            return 1
        fi
    else
        log_error "Node.js installation failed"
        return 1
    fi
}

# Neovim utilities
check_neovim_version() {
    local required_version="${1:-0.10.0}"
    
    if ! cmd_exists nvim; then
        log_error "Neovim is not installed"
        return 1
    fi
    
    local nvim_version
    nvim_version=$(nvim --version | head -n1 | cut -d'v' -f2 | cut -d' ' -f1)
    
    if version_gte "$nvim_version" "$required_version"; then
        log_success "Neovim $nvim_version meets requirements"
        return 0
    else
        log_error "Neovim $nvim_version is too old. Required: v${required_version}+"
        return 1
    fi
}

test_nvim_plugin() {
    local plugin_name="$1"
    local test_command="$2"
    
    log_info "Testing $plugin_name plugin..."
    if nvim --headless -c "$test_command" -c "qall" &> /dev/null; then
        log_success "$plugin_name plugin is working"
        return 0
    else
        log_warning "$plugin_name plugin test failed"
        return 1
    fi
}

# Tmux utilities
tmux_session_exists() {
    tmux has-session -t "$1" 2>/dev/null
}

create_tmux_session() {
    local session_name="$1"
    local project_path="${2:-$(pwd)}"
    
    if tmux_session_exists "$session_name"; then
        log_info "Session '$session_name' already exists. Attaching..."
        tmux attach-session -t "$session_name"
        return 0
    fi
    
    log_info "Creating tmux session: $session_name"
    tmux new-session -d -s "$session_name" -c "$project_path"
}

# File operations utilities
backup_file() {
    local file="$1"
    local backup_suffix="${2:-.backup}"
    
    if [[ -f "$file" ]]; then
        log_info "Backing up $file..."
        mv "$file" "${file}${backup_suffix}"
    fi
}

create_symlink() {
    local source="$1"
    local target="$2"
    
    if [[ -e "$target" || -L "$target" ]]; then
        rm -f "$target"
    fi
    
    mkdir -p "$(dirname "$target")"
    ln -sf "$source" "$target"
}

# Java utilities
setup_java_environment() {
    local java_version="${1:-17}"
    
    if ! cmd_exists java; then
        log_warning "Java not found. Installing OpenJDK $java_version..."
        install_package "openjdk@${java_version}" "openjdk@${java_version}"
    fi
    
    # Set JAVA_HOME if not already set
    if [[ -z "$JAVA_HOME" ]]; then
        local java_home_path
        if [[ "$PLATFORM" == "macos" ]]; then
            if [[ -d "/opt/homebrew/opt/openjdk@${java_version}" ]]; then
                java_home_path="/opt/homebrew/opt/openjdk@${java_version}"
            elif [[ -d "/usr/local/opt/openjdk@${java_version}" ]]; then
                java_home_path="/usr/local/opt/openjdk@${java_version}"
            fi
        elif [[ "$PLATFORM" == "linux" ]]; then
            java_home_path="/usr/lib/jvm/java-${java_version}-openjdk"
            if [[ ! -d "$java_home_path" ]]; then
                java_home_path="/usr/lib/jvm/default"
            fi
        fi
        
        if [[ -n "$java_home_path" && -d "$java_home_path" ]]; then
            export JAVA_HOME="$java_home_path"
            log_success "JAVA_HOME set to: $JAVA_HOME"
        fi
    fi
}

# Go utilities
setup_go_environment() {
    if ! cmd_exists go; then
        log_warning "Go not found. Installing..."
        install_package "go"
    fi
    
    # Create Go workspace directories
    mkdir -p "${HOME}/go"/{bin,src,pkg}
    
    # Set up GOPATH and GOROOT if not set
    if [[ -z "$GOPATH" ]]; then
        export GOPATH="${HOME}/go"
    fi
    
    if [[ -z "$GOROOT" ]] && cmd_exists go; then
        export GOROOT="$(go env GOROOT)"
    fi
    
    log_success "Go environment configured"
}

# Development tools installation
install_go_tools() {
    log_info "Installing Go development tools..."
    
    local tools=(
        "golang.org/x/tools/gopls@latest"
        "github.com/go-delve/delve/cmd/dlv@latest"
        "golang.org/x/tools/cmd/goimports@latest"
        "github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
        "mvdan.cc/gofumpt@latest"
        "github.com/fatih/gomodifytags@latest"
        "github.com/josharian/impl@latest"
        "github.com/cweill/gotests/gotests@latest"
    )
    
    for tool in "${tools[@]}"; do
        log_step "Installing $(basename "$tool" | cut -d'@' -f1)..."
        go install "$tool"
    done
    
    log_success "Go tools installed successfully"
}

# Validation functions
validate_installation() {
    local tool="$1"
    local version_flag="${2:---version}"
    
    if cmd_exists "$tool"; then
        local version
        version=$("$tool" "$version_flag" 2>&1 | head -n1)
        log_success "$tool: $version"
        return 0
    else
        log_error "$tool: Not found"
        return 1
    fi
}

# Cross-platform path handling
get_config_path() {
    local app="$1"
    
    case "$app" in
        nvim)
            echo "${HOME}/.config/nvim"
            ;;
        tmux)
            echo "${HOME}/.tmux.conf"
            ;;
        zsh)
            echo "${HOME}/.zshrc"
            ;;
        *)
            echo "${HOME}/.config/$app"
            ;;
    esac
}

# Safety check for destructive operations
confirm_action() {
    local message="$1"
    local default="${2:-n}"
    
    if [[ "$default" == "y" ]]; then
        read -p "$message [Y/n]: " -n 1 -r
        echo
        [[ $REPLY =~ ^[Nn]$ ]] && return 1
    else
        read -p "$message [y/N]: " -n 1 -r
        echo
        [[ ! $REPLY =~ ^[Yy]$ ]] && return 1
    fi
    return 0
}

# Progress tracking
show_progress() {
    local current="$1"
    local total="$2"
    local message="$3"
    
    local percentage=$((current * 100 / total))
    log_info "[$current/$total] ($percentage%) $message"
}

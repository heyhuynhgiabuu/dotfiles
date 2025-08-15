#!/usr/bin/env sh

# Automation Installation Script for Serena Auto-Update
# Supports both macOS (launchd) and Linux (systemd)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${YELLOW}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

# Make main script executable
make_executable() {
    log_info "Making scripts executable..."
    chmod +x "$PROJECT_ROOT/scripts/serena-auto-update.sh"
    log_success "✓ Scripts made executable"
}

# Install for macOS using launchd
install_macos() {
    log_info "Installing automation for macOS using launchd..."
    
    local plist_file="$SCRIPT_DIR/com.dotfiles.serena-update.plist"
    local user_agents_dir="$HOME/Library/LaunchAgents"
    local installed_plist="$user_agents_dir/com.dotfiles.serena-update.plist"
    
    # Create LaunchAgents directory if it doesn't exist
    mkdir -p "$user_agents_dir"
    
    # Replace %HOME% placeholder with actual home directory
    sed "s|%HOME%|$HOME|g" "$plist_file" > "$installed_plist"
    
    # Load the plist
    if launchctl load "$installed_plist" 2>/dev/null; then
        log_success "✓ Serena auto-update scheduled for weekly execution (Mondays at 9 AM)"
    else
        # Unload first if already loaded, then load again
        launchctl unload "$installed_plist" 2>/dev/null || true
        if launchctl load "$installed_plist"; then
            log_success "✓ Serena auto-update scheduled for weekly execution (Mondays at 9 AM)"
        else
            log_error "✗ Failed to load launchd job"
            return 1
        fi
    fi
    
    # Show status
    if launchctl list | grep -q "com.dotfiles.serena-update"; then
        log_success "✓ Automation installed and active"
        echo "  Next run: Every Monday at 9:00 AM"
        echo "  Logs: $HOME/dotfiles/.serena/automation.log"
        echo "  Errors: $HOME/dotfiles/.serena/automation_error.log"
    else
        log_error "✗ Installation verification failed"
        return 1
    fi
}

# Install for Linux using systemd
install_linux() {
    log_info "Installing automation for Linux using systemd..."
    
    local user_systemd_dir="$HOME/.config/systemd/user"
    mkdir -p "$user_systemd_dir"
    
    # Copy service and timer files
    cp "$SCRIPT_DIR/serena-update.service" "$user_systemd_dir/"
    cp "$SCRIPT_DIR/serena-update.timer" "$user_systemd_dir/"
    
    # Replace %h placeholder with actual home directory in service file
    sed -i "s|%h|$HOME|g" "$user_systemd_dir/serena-update.service"
    
    # Reload systemd and enable/start timer
    systemctl --user daemon-reload
    
    if systemctl --user enable serena-update.timer && systemctl --user start serena-update.timer; then
        log_success "✓ Serena auto-update scheduled for weekly execution"
        
        # Show status
        echo ""
        systemctl --user status serena-update.timer --no-pager
        echo ""
        log_info "Next scheduled run:"
        systemctl --user list-timers serena-update.timer --no-pager
    else
        log_error "✗ Failed to enable systemd timer"
        return 1
    fi
}

# Main function
main() {
    echo "🔧 Installing Serena Auto-Update Automation..."
    echo ""
    
    make_executable
    
    # Detect platform and install accordingly
    if [[ "$OSTYPE" == "darwin"* ]]; then
        install_macos
        echo ""
        echo "📋 Management Commands:"
        echo "  Status:    launchctl list | grep serena-update"
        echo "  Stop:      launchctl unload ~/Library/LaunchAgents/com.dotfiles.serena-update.plist"
        echo "  Start:     launchctl load ~/Library/LaunchAgents/com.dotfiles.serena-update.plist"
        echo "  Run now:   $PROJECT_ROOT/scripts/serena-auto-update.sh"
        
    elif [[ -n "$(command -v systemctl)" ]]; then
        install_linux
        echo ""
        echo "📋 Management Commands:"
        echo "  Status:    systemctl --user status serena-update.timer"
        echo "  Stop:      systemctl --user stop serena-update.timer"
        echo "  Start:     systemctl --user start serena-update.timer"
        echo "  Logs:      journalctl --user -u serena-update.service"
        echo "  Run now:   $PROJECT_ROOT/scripts/serena-auto-update.sh"
        
    else
        log_error "Unsupported platform. Please install manually or use cron."
        echo ""
        echo "🔧 Manual cron installation:"
        echo "Add this line to your crontab (crontab -e):"
        echo "0 9 * * 1 $PROJECT_ROOT/scripts/serena-auto-update.sh"
        return 1
    fi
    
    echo ""
    log_success "🎉 Serena auto-update automation installed successfully!"
    echo ""
    echo "💡 To run immediately: $PROJECT_ROOT/scripts/serena-auto-update.sh"
}

main "$@"
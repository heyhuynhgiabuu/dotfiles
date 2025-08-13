# Serena Auto-Update Automation
# This directory contains automation scripts for periodic Serena updates

## Files:
- `serena-auto-update.sh` - Main update script
- `serena-update.timer` - Systemd timer (Linux)
- `serena-update.service` - Systemd service (Linux)  
- `com.dotfiles.serena-update.plist` - Launchd plist (macOS)
- `install-automation.sh` - Installation helper

## Usage:

### Manual Run:
```bash
./scripts/serena/serena-auto-update.sh
```

### Install Weekly Automation:
```bash
./scripts/automation/install-automation.sh
```

### Check Status:
```bash
# Linux (systemd)
systemctl --user status serena-update.timer

# macOS (launchd)  
launchctl list | grep serena-update
```

This system automatically:
1. Checks for Serena updates weekly
2. Downloads and analyzes changelog
3. Backs up existing configuration 
4. Updates metadata and configuration
5. Verifies installation integrity
6. Generates detailed reports
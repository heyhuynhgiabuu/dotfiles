# Augment Configuration

This directory manages the configuration for AugmentCode, a tool that provides context-aware chat and workspace understanding within Neovim. The setup is synchronized across environments using GNU Stow.

## Key Files
- `.augmentignore`: Global ignore patterns for all workspaces.
- `settings.conf`: Main settings for AugmentCode's behavior.
- `keymaps.conf`: Keyboard shortcut definitions.
- `workspace_folders.conf`: Default directories to be included in workspaces.

## Setup
The configuration is managed via symlinks created by GNU Stow. The setup script `scripts/setup-augment-config.sh` handles the Stow process.

## Integration
This configuration is designed to work alongside other AI tools:
- **OpenCode:** For terminal-based, long-form conversations.
- **GitHub Copilot:** For real-time code completions.
- **AugmentCode:** For in-editor, context-aware chat.

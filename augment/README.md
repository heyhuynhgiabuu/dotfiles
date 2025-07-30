# AugmentCode Configuration

This directory contains global AugmentCode configuration that's synchronized across all development environments using GNU Stow.

## 📁 Directory Structure

```
augment/
├── .augmentignore                     # Global ignore patterns
├── .config/augment/                   # Configuration directory
│   ├── settings.conf                  # Global AugmentCode settings
│   ├── keymaps.conf                   # Keyboard shortcuts configuration
│   ├── workspace_folders.conf         # Default workspace directories
│   └── dotfiles-workspace.conf        # Dotfiles-specific workspace config
└── .local/share/vim-augment/          # Data and cache directory (empty)
```

## 🔗 Stow Integration

This configuration uses GNU Stow to create symlinks:

- `~/.config/augment/` → `~/dotfiles/augment/.config/augment/`
- `~/.local/share/vim-augment/` → `~/dotfiles/augment/.local/share/vim-augment/`
- `~/.augmentignore` → `~/dotfiles/augment/.augmentignore`

## 🚀 Setup

### Initial Setup
```bash
cd ~/dotfiles
./scripts/setup-augment-config.sh
```

### Manual Setup
```bash
cd ~/dotfiles
stow augment
```

### Remove Configuration
```bash
cd ~/dotfiles
stow -D augment
```

## ⚙️ Configuration Files

### `.augmentignore`
Global ignore patterns applied to all AugmentCode workspaces:
- Build outputs (`build/`, `dist/`, `target/`)
- Dependencies (`node_modules/`, `vendor/`)
- Environment files (`.env`, `secrets.json`)
- IDE files (`.vscode/`, `.idea/`)
- Logs and temporary files

### `settings.conf`
Global AugmentCode behavior settings:
- Completion delays and triggers
- Chat history and rendering options
- Workspace indexing preferences
- Security and privacy settings
- Language-specific configurations

### `keymaps.conf`
Consistent keyboard shortcuts across all projects:
- `<leader>a*` prefix for all AugmentCode commands
- Chat, completion, and management shortcuts
- Visual mode mappings for code explanations

### `workspace_folders.conf`
Default workspace directories automatically included:
- Common development folders (`~/projects`, `~/Developer/`)
- Language-specific directories (`~/go/src`, `~/python`)
- Configuration directories (`~/dotfiles`, `~/.config`)

## 🎯 Usage

### In Neovim
All configurations are automatically loaded. Key mappings:

**Chat & AI Assistance:**
- `<leader>ac` - Send chat message
- `<leader>an` - New chat conversation  
- `<leader>at` - Toggle chat panel

**Status & Management:**
- `<leader>as` - Show AugmentCode status
- `<leader>ai` - Sign in
- `<leader>al` - Show logs
- `<leader>aw` - Show workspace folders

**Completions:**
- `<Tab>` - Accept suggestion (default)
- `<Ctrl-l>` - Accept suggestion (alternative)
- `<Ctrl-CR>` - Accept with newline fallback

### Workspace Configuration
The Neovim plugin automatically configures workspaces with:
1. Current working directory
2. Common development directories (if they exist)
3. Project-specific overrides (`.augmentconfig` file)

### Project-Specific Overrides
Create a `.augmentconfig` file in any project root to override global settings:

```lua
-- Project-specific AugmentCode configuration
vim.g.augment_workspace_folders = {
  vim.fn.getcwd(),
  "/path/to/related/project",
  "/path/to/shared/library"
}

-- Project-specific ignore patterns
vim.g.augment_ignore_patterns = {
  "*.tmp",
  "custom-build/"
}
```

## 🔄 Updating Configuration

Since configurations are symlinked, changes are immediate:

1. Edit files in `~/dotfiles/augment/`
2. Changes are automatically reflected in `~/.config/augment/`
3. Restart Neovim to apply configuration changes

## 🧪 Testing

Verify AugmentCode is working:

```bash
nvim test.go
:Augment status
:Augment log
```

Expected output:
- Authentication status
- Workspace folders being indexed
- No error messages in logs

## 🔧 Troubleshooting

### Common Issues

1. **Symlinks not created**
   ```bash
   cd ~/dotfiles && stow -D augment && stow augment
   ```

2. **Configuration not loading**
   - Check symlinks exist: `ls -la ~/.config/augment`
   - Restart Neovim completely
   - Run `:Augment log` for error details

3. **Workspace indexing slow**
   - Add patterns to `.augmentignore`
   - Check `:Augment status` for progress
   - Exclude large directories in workspace config

4. **Keymaps conflicting**
   - Check for conflicts with other plugins
   - Customize mappings in `keymaps.conf`
   - Use `<leader>aw` to verify workspace configuration

### Debug Commands
```vim
:Augment status        " Overall status
:Augment log          " Detailed logs  
:checkhealth          " Neovim health check
:Lazy health          " Plugin health check
```

## 🔒 Security Notes

- Authentication tokens are stored in `~/.local/share/vim-augment/secrets.json`
- This file is **not** included in dotfiles (excluded by gitignore)
- Global `.augmentignore` excludes sensitive files by default
- Review workspace folders to ensure no sensitive data is indexed

## 📚 Documentation

- [AugmentCode Vim Documentation](https://docs.augmentcode.com/vim/)
- [Workspace Configuration](https://docs.augmentcode.com/vim/setup-augment/workspace-context-vim)
- [Keyboard Shortcuts](https://docs.augmentcode.com/vim/setup-augment/vim-keyboard-shortcuts)
- [Workspace Indexing](https://docs.augmentcode.com/vim/setup-augment/workspace-indexing)

## 🤝 Integration with Existing Workflow

This AugmentCode configuration integrates seamlessly with your existing dotfiles:

- **OpenCode** (terminal) - Long-form discussions, session management
- **GitHub Copilot** (Neovim) - Real-time completions  
- **AugmentCode** (Neovim) - Context-aware chat and workspace understanding

Each tool serves a different purpose in the AI-assisted development workflow.

---

*Part of the cross-platform dotfiles repository. Maintained with stow for consistent configuration across macOS and Linux.*

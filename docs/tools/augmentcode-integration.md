# AugmentCode AI Integration

This dotfiles repository includes AugmentCode AI integration for enhanced Neovim development experience. AugmentCode provides AI-augmented development with deep codebase understanding, context-aware completions, and intelligent chat directly within your editor.

## Features

- **Context-aware AI completions** - Deep understanding of your entire codebase
- **Multi-turn chat conversations** - Ask questions and get context-specific help
- **Workspace indexing** - Syncs your project for better AI suggestions
- **Code analysis** - Explain, review, and improve code with AI assistance
- **Cross-platform support** - Works on both macOS and Linux

## Quick Setup

### 1. Prerequisites
- **Node.js 22.0.0+** (upgraded to v22.14.0 ✅)
- **Neovim 0.10.0+** (you have v0.11.0 ✅)
- **AugmentCode account** (free trial at [augmentcode.com](https://augmentcode.com))

### 2. Automated Setup
Run the setup script to check requirements:

```bash
cd ~/dotfiles
./scripts/setup-augmentcode.sh
```

This script will:
- ✅ Check Node.js and Neovim versions
- 📝 Provide installation instructions
- 🧪 Verify setup requirements

### 3. Manual Setup

1. **Upgrade Node.js** (if needed):
   ```bash
   # macOS with Homebrew
   brew install node
   
   # Or download from https://nodejs.org/
   ```

2. **Open Neovim** in your dotfiles directory:
   ```bash
   cd ~/dotfiles
   nvim
   ```

3. **Install plugins**:
   ```vim
   :Lazy sync
   ```

4. **Sign in to AugmentCode**:
   ```vim
   :Augment signin
   ```

5. **Test the installation**:
   ```vim
   :Augment status
   ```

## Keyboard Shortcuts

All AugmentCode commands use the `<leader>a` prefix:

### Completion
- `<Tab>` - Accept completion suggestion (default)
- `<Ctrl+l>` - Accept suggestion (alternative)
- `<Ctrl+CR>` - Accept suggestion or insert newline

### Chat and Analysis
- `<leader>ac` - Send chat message (add your message after command)
- `<leader>an` - Start new chat conversation
- `<leader>at` - Toggle chat panel visibility

### Status and Management
- `<leader>as` - Show AugmentCode status
- `<leader>al` - Show plugin log
- `<leader>ae` - Enable completions
- `<leader>ad` - Disable completions

### Authentication
- `<leader>ai` - Sign in to AugmentCode
- `<leader>ao` - Sign out of AugmentCode

## Configuration

The AugmentCode plugin is configured in `nvim/.config/nvim/lua/custom/plugins.lua` with:

- **Workspace Folders**: Automatically set to current working directory
- **Custom Keymaps**: Non-conflicting shortcuts using `<leader>a` prefix
- **Lazy Loading**: Only loads when needed for optimal performance
- **Tab Completion**: Uses default Tab behavior for accepting suggestions

## Workspace Context

AugmentCode works best when it understands your project structure:

### Automatic Configuration
- **Workspace folder**: Automatically set to your current directory
- **Context engine**: Indexes your codebase for better suggestions
- **Sync progress**: Check with `:Augment status`

### Ignoring Files
Create a `.augmentignore` file in your project root to exclude files:
```
node_modules/
.git/
*.log
tmp/
```

### Workspace Commands
```vim
:Augment status    " Check sync progress and workspace info
:Augment log       " View detailed plugin logs
```

## Dual AI Workflow

This setup creates a powerful dual AI development environment:

### OpenCode (Terminal)
- **Long-form discussions** and architecture planning
- **Multi-session management** with persistent context
- **Cross-platform dotfiles management**
- **Complex problem-solving** and research

### AugmentCode (Editor)
- **Real-time completions** with deep codebase context
- **Multi-turn chat** with project understanding
- **Workspace indexing** for intelligent suggestions
- **Context-aware code analysis**

## File Structure

```
nvim/.config/nvim/lua/custom/plugins.lua  # Plugin configuration
scripts/setup-augmentcode.sh              # Setup automation
docs/augmentcode-integration.md           # This documentation
```

## Cross-Platform Compatibility

### macOS
- ✅ Native support
- Install Node.js via Homebrew: `brew install node`
- Install Neovim via Homebrew: `brew install neovim`

### Linux
- ✅ Full compatibility
- Install Node.js via package manager or NodeSource
- Install Neovim via package manager or AppImage

## Troubleshooting

### Common Issues

1. **"Could not find sign in state" Authentication Error**
   - **Cause**: Authentication state not properly maintained between browser and Neovim
   - **Root Issue**: URL cannot be clicked in Neovim - must be manually copied
   - **Solution**: 
     ```bash
     # Follow these EXACT steps:
     
     # 1. Start fresh authentication
     cd ~/dotfiles
     nvim test.go
     :Augment signin
     
     # 2. MANUALLY copy the URL from Neovim's message area
     # ⚠️  You CANNOT click it or use 'gx' - must select and copy text
     
     # 3. Paste URL in browser, complete authentication
     
     # 4. Copy ENTIRE JSON response from browser:
     # {"code":"xyz123","state":"abc456","tenant_url":"https://i0.api.augmentcode.com/"}
     
     # 5. Return to SAME terminal, paste complete JSON
     
     # 6. Verify: :Augment status
     ```
   - **Important**: Copy the complete JSON, not just the code value

2. **"Node.js version too old"**
   - AugmentCode requires Node.js 22.0.0+
   - Upgrade: `brew install node` (macOS) or download from nodejs.org
   - Verify: `node --version`

3. **"Not signed in"**
   - Run `:Augment signin` in Neovim
   - Sign up at [augmentcode.com](https://augmentcode.com) if needed
   - Check status: `:Augment status`

4. **"No completions appearing"**
   - Check `:Augment status` shows "Signed in"
   - Ensure workspace is synced
   - Try enabling: `:Augment enable`

5. **":Augment command not found"**
   - Run `:Lazy sync` to install the plugin
   - Restart Neovim after installation

6. **"Workspace syncing slowly"**
   - Large codebases take time to index initially
   - Check progress: `:Augment status`
   - Add `.augmentignore` to exclude large directories

### Debug Information

Check detailed status and logs:
```vim
:Augment status   " Current status and workspace info
:Augment log      " Detailed plugin logs
```

## Integration with Existing Workflow

AugmentCode integrates seamlessly with your existing setup:

- **Copilot Compatibility**: Works alongside GitHub Copilot
- **LSP Integration**: Complements existing language servers  
- **Lazy Loading**: Only loads when needed for optimal performance
- **Custom Keymaps**: Non-conflicting shortcuts using `<leader>a`

## Cost Considerations

- **Free Trial**: Available at [augmentcode.com](https://augmentcode.com)
- **Context Engine**: Deep codebase understanding included
- **Workspace Indexing**: Real-time project synchronization
- **Independent**: Uses AugmentCode API (not GitHub Copilot allocation)

This provides a sophisticated AI coding assistant that complements your existing OpenCode + GitHub Copilot Education setup.

## Usage Examples

### Chat with Context
```vim
" Select code in visual mode, then:
:Augment chat How can I optimize this function?

" Or directly from normal mode:
:Augment chat Explain the auth middleware pattern
```

### Completion Workflow
1. Start typing code
2. See context-aware suggestions appear
3. Press `<Tab>` to accept, or keep typing to refine
4. Use `<Ctrl+l>` as alternative acceptance key

### Workspace Management
```vim
:Augment status    " Check workspace sync progress
:Augment log       " Debug any issues
```

## Next Steps

1. **Upgrade Node.js**: `brew install node` (if needed)
2. **Run setup script**: `./scripts/setup-augmentcode.sh`
3. **Open Neovim**: `nvim` and run `:Lazy sync`
4. **Sign in**: `:Augment signin`
5. **Test features**: Try completions and `<leader>a` commands
6. **Enjoy**: Enhanced AI-assisted development!

## Advanced Configuration

### Custom Completion Key
If you prefer a different key than Tab:
```lua
-- In your plugin config
vim.g.augment_disable_tab_mapping = true

-- Then add custom mapping
vim.keymap.set("i", "<C-Space>", function()
  return vim.fn['augment#Accept']()
end, { expr = true })
```

### Workspace Folders
For multiple projects:
```lua
vim.g.augment_workspace_folders = {
  "~/projects/main-app",
  "~/projects/shared-lib"
}
```

---

*This integration maintains the clean, cross-platform nature of your dotfiles while adding powerful AI capabilities with deep codebase understanding directly in your editor.*
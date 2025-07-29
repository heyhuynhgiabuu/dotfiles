# Clean Dual-AI Development Setup

This dotfiles configuration provides a clean, conflict-free dual-AI development environment optimized for productivity.

## Architecture Overview

### **External AI (Planning & Agents)**
- **OpenCode.ai** with GitHub Copilot provider
- **Purpose**: Planning, code review, complex problem-solving, agent-based tasks
- **Access**: Web interface, command line, integrated workflows
- **Cost**: Utilizes your existing GitHub Copilot Education plan

### **Internal AI (Coding Assistance)**
- **AugmentCode** (`augment.vim` plugin)
- **Purpose**: Real-time completions, inline suggestions, coding chat
- **Access**: Integrated directly into Neovim
- **Features**: Tab completion, chat interface, context-aware suggestions

## Why This Dual Setup?

1. **Separation of Concerns**: External planning vs. internal coding assistance
2. **No Plugin Conflicts**: Clean single-AI setup in Neovim eliminates conflicts
3. **Cost Optimization**: Leverages existing Copilot subscription through OpenCode
4. **Best of Both**: Strategic AI for planning + tactical AI for coding

## Neovim Configuration

### **AugmentCode Keybindings**
```
Insert Mode (Completion Acceptance):
  Ctrl-L   - Accept suggestion (primary, safe)
  Ctrl-J   - Accept suggestion (alternative)  
  Ctrl-Y   - Accept suggestion (fallback)
  
Note: Tab key reserved for nvim-cmp to prevent conflicts

Normal Mode:
  <leader>ac  - Start chat
  <leader>an  - New chat conversation
  <leader>at  - Toggle chat panel
  <leader>as  - Show status
  <leader>ai  - Sign in
  <leader>ao  - Sign out
  <leader>ae  - Enable completions
  <leader>ad  - Disable completions
  
Workspace Management:
  <leader>aw  - Show workspace folders
  <leader>aW  - Add current directory to workspace
  <leader>aF  - Add custom folder to workspace
```

### **Clean Configuration Features**
- **No Conflicts**: Removed all GitHub Copilot nvim plugins
- **Single AI**: AugmentCode is the only AI assistant in Neovim
- **Tab Safety**: Tab key reserved for nvim-cmp to prevent E565 conflicts
- **Global Config**: Settings managed via `~/.config/augment/` (symlinked)
- **Workspace Context**: Automatic loading of workspace folders for enhanced context
- **Dynamic Management**: Add/remove workspace folders on-the-fly

## Usage Workflow

### **Typical Development Session**
1. **Planning Phase**: Use OpenCode for architecture, research, problem breakdown
2. **Coding Phase**: Use AugmentCode in Neovim for real-time assistance
3. **Review Phase**: Use OpenCode agents for code review and optimization
4. **Documentation**: Use OpenCode for comprehensive documentation

### **When to Use What**
- **OpenCode**: Complex problems, research, architecture, code review
- **AugmentCode**: Day-to-day coding, completions, quick questions

## Configuration Files

### **Core Files**
- `nvim/.config/nvim/lua/custom/plugins.lua` - Clean single-AI Neovim config
- `augment/.config/augment/` - AugmentCode global settings
- `opencode/` - OpenCode global configuration

### **Removed Files** (moved to `deprecated/`)
- `scripts/setup-copilot.sh` - No longer needed
- `tmux/copilot-integration.conf` - Copilot-specific tmux config

## Testing Your Setup

### **Test AugmentCode**
```bash
# Test clean environment
nvim --clean -u test-augment-clean.lua

# In Neovim:
# 1. Press <space>test to check configuration
# 2. Try Tab in insert mode for completions
# 3. Use <leader>ac for chat
```

### **Test OpenCode**
```bash
# Verify OpenCode authentication
opencode auth status

# Test GitHub Copilot provider
opencode chat "Help me plan a Go microservice"
```

## Benefits of This Setup

✅ **No Plugin Conflicts**: Clean single-AI environment  
✅ **Cost Efficient**: Reuses existing Copilot subscription  
✅ **Workflow Optimized**: Right tool for each task  
✅ **Cross-Platform**: Works on macOS and Linux  
✅ **Maintainable**: Simple, clean configuration  

## Troubleshooting

### **AugmentCode Issues**
- Check `:Augment status` for authentication
- Verify `~/.config/augment/` configuration
- Ensure Node.js is available

### **OpenCode Issues**
- Verify GitHub authentication: `gh auth status`
- Check Copilot access: `opencode auth status`
- Review OpenCode configuration: `~/.config/opencode/`

## Migration Notes

If upgrading from the old dual-plugin setup:
1. ✅ Removed `github/copilot.vim` plugin
2. ✅ Removed `CopilotC-Nvim/CopilotChat.nvim` plugin  
3. ✅ Cleaned up duplicate AugmentCode configurations
4. ✅ Enabled Tab key for AugmentCode (no more conflicts)
5. ✅ Moved old Copilot files to `deprecated/` folder

Your development workflow is now cleaner, faster, and conflict-free! 🚀
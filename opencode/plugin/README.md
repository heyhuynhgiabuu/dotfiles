# OpenCode Plugins - Official Pattern

**Following the [official OpenCode documentation](https://opencode.ai/docs/plugins/) exactly.**

## 🎯 Official Plugin Structure

✅ **Correct Setup:**
```bash
~/.config/opencode/plugin/     # ← OpenCode loads from here (via symlink)
├── unified.js                 # All features combined - RECOMMENDED
├── notification.js            # Session completion notifications
├── env-protection.js          # Security file blocking
└── README.md                  # This file
```

## 📁 Main Plugin: `unified.js`

### **Reasoning Optimization**
Automatically tunes reasoning parameters based on agent characteristics:

**High Precision Agents** (focused, minimal reasoning):
- `reviewer` - Code quality analysis
- `security` - Security auditing

**Structured Reasoning Agents** (medium reasoning, concise output):
- `devops` - Infrastructure & deployment
- `language` - Code patterns & optimization  
- `orchestrator` - Multi-agent coordination
- `specialist` - Domain expertise

**Research Agents** (comprehensive reasoning):
- `general` - Multi-step tasks
- `researcher` - Information synthesis

### **Cross-Platform Notifications**
- **macOS**: `say` + `osascript` + system sounds
- **Linux**: `notify-send` + `canberra-gtk-play`
- **Auto-summary**: Extracts "Summary:" lines from responses

### **Security Protection**
Blocks reading of sensitive files:
- `.env` files
- Files containing "secret", "private"
- Custom security patterns

### **VectorCode Integration**
Custom commands for codebase analysis:
```bash
vc-query "search terms"    # Search codebase context
vc-index                   # Index current directory
```

## 🚀 Usage

**Automatic features** (no commands needed):
- Reasoning optimization per agent
- Session completion notifications with summaries
- Sensitive file protection

**Manual commands**:
- VectorCode integration (requires `npm i -g vectorcode`)

## ✅ KISS Principles Applied

1. **Single responsibility** - One plugin file with clear sections
2. **No external dependencies** - Uses built-in OpenCode APIs only
3. **Official patterns** - Follows documented JavaScript examples exactly
4. **Cross-platform** - Works on macOS and Linux
5. **Defensive coding** - Graceful error handling
6. **Agent-aware** - Maps to actual agents in `opencode/agent/`

## 🔍 Verification

```bash
# Check plugin detection
ls ~/.config/opencode/plugin/    # Should show: unified.js, notification.js, env-protection.js

# Verify symlink works  
readlink ~/.config/opencode      # Should show: /Users/killerkidbo/dotfiles/opencode

# Test syntax
node -c ~/.config/opencode/plugin/unified.js  # Should pass
```

## 📚 References

- [Official Plugin Docs](https://opencode.ai/docs/plugins/)
- [Agent Definitions](../agent/) - Local subagent configurations
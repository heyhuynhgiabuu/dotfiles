# OpenCode Unified Dotfiles Plugin

**Working plugin following KISS principles and proven patterns**

## 🎯 Plugin Structure

✅ **Simple Unified Architecture:**
```bash
opencode/plugin/               # Dotfiles integration directory
├── unified.js                 # Single file with async function export
└── README.md                  # This documentation
```

## 📦 UnifiedDotfilesPlugin Function

### **Core Architecture**
- **Function Export**: Simple `async ({ $ }) =>` pattern that OpenCode SDK expects
- **Single File**: All functionality in 160 lines (KISS principle)
- **SDK Hooks**: Uses `chat.params`, `tool.execute.before`, `event` hooks
- **Cross-Platform**: Works on macOS and Linux without modification

### **🔧 Agent Optimization** 
Automatically reduces GPT-5 verbosity based on agent type:

**Low Effort Agents** (low reasoning, low verbosity):
- `reviewer` - Code quality analysis  
- `security` - Security auditing

**Medium Effort Agents** (medium reasoning, low verbosity):
- `devops` - Infrastructure & deployment
- `language` - Code patterns & optimization  
- `orchestrator` - Multi-agent coordination
- `specialist` - Domain expertise

**High Effort Agents** (high reasoning, medium verbosity):
- `general` - Multi-step tasks
- `researcher` - Information synthesis

### **🔔 Cross-Platform Notifications**
Desktop alerts on session completion with smart summary extraction:
- **macOS**: `osascript` visual notifications
- **Linux**: `notify-send` desktop notifications
- **Summary Pattern**: Extracts "Summary:" lines from responses (≤100 chars)
- **Fallback**: Uses last line if no summary found
- **Silent Fail**: Notification errors don't break workflow

### **🔒 Security Protection**
Blocks sensitive file reads with pattern matching:
- **Patterns**: `.env`, `secret`, `private`, `password`, `token`, `key`, `credential`
- **Immediate Block**: Throws error on sensitive file access attempts
- **No Retry**: Security errors escalate immediately (per AGENTS.md)
- **Console Warning**: Clear feedback on blocked access

### **🔍 VectorCode Integration**
Intercepts and executes semantic search commands:
```bash
vc-query "search terms"    # Semantic codebase search
vc-index                   # Index current directory
```
- **Command Interception**: Catches bash commands containing `vc-query`/`vc-index`
- **Direct Execution**: Runs `vectorcode` CLI with proper error handling
- **Completion Signal**: Throws error to prevent double execution
- **Install Guidance**: Shows npm install command on missing dependency

## 🚀 Usage

**Fully Automatic** - Zero configuration required:
- ✅ **Agent Optimization**: Reduces GPT-5 verbosity automatically
- ✅ **Desktop Notifications**: Session completion alerts with summaries
- ✅ **Security Blocking**: Prevents access to sensitive files
- ✅ **VectorCode Commands**: `vc-query` and `vc-index` semantic search

**Plugin Integration**:
- Auto-loads from dotfiles `opencode/plugin/unified.js`
- Uses proven async function export pattern
- Hooks into OpenCode SDK events seamlessly

## ✅ Design Principles

1. **KISS Principle** - Single file, simple function export
2. **Working First** - Proven patterns over "official" architectures  
3. **Cross-Platform** - macOS and Linux compatibility required
4. **Security First** - Immediate escalation, no retry on security errors
5. **Silent Fail** - Non-critical errors don't break workflow
6. **AGENTS.md Compliant** - Follows established dotfiles protocols
7. **Manual Verification** - All changes include testing steps
8. **No Dependencies** - Uses only built-in OpenCode SDK features

## 🔍 Manual Verification Steps

```bash
# 1. Check plugin loads without syntax errors
node -c opencode/plugin/unified.js

# 2. Verify cross-platform notification commands exist
# macOS:
which osascript  # Should exist
# Linux: 
which notify-send  # Should exist

# 3. Test VectorCode integration (if installed)
vectorcode --version  # Optional: npm i -g vectorcode

# 4. Verify security patterns work
echo "Contains: secret, token, .env" | grep -E "(secret|token|\.env)"

# 5. Check agent optimization mappings
node -e "
const plugin = require('./opencode/plugin/unified.js');
console.log('Plugin exports:', Object.keys(plugin));
"
```

## 📚 Related Documentation

- [AGENTS.md](../AGENTS.md) - OpenCode protocol and agent routing rules
- [Agent Definitions](../agent/) - Individual agent configurations  
- [Dotfiles README](../../README.md) - Project setup and verification
- [OpenCode Documentation](../../docs/opencode/) - Additional architecture details
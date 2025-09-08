# OpenCode Unified Dotfiles Plugin

**Working plugin following KISS principles and proven patterns**

## 🎯 Plugin Structure

✅ **Simple Unified Architecture:**

```bash
opencode/plugin/               # Dotfiles integration directory
├── unified.js                 # Single file with async function export
└── README.md                  # This documentation
```

# OpenCode Universal Dotfiles Plugin

**Working plugin following KISS principles and proven patterns**

## 🎯 Plugin Structure

✅ **Simple Universal Architecture:**

```bash
opencode/plugin/               # Dotfiles integration directory
├── universal.js               # Universal context engineering plugin
├── notification.js            # Simple notification plugin
└── README.md                  # This documentation
```

## 📦 UniversalContextEngineering Plugin

### **Core Architecture**

- **Function Export**: Uses OpenCode SDK v0.6.5 `async ({ project, client, $, directory, worktree }) =>` pattern
- **Single File**: All functionality in 691 lines with advanced tech stack detection
- **SDK Hooks**: Uses `tool.execute.before`, `tool.execute.after`, and `event` hooks
- **Cross-Platform**: Works on macOS and Linux without modification

### **🔧 Tech Stack Detection**

Automatically detects and provides context for:

**Java Ecosystem:**

- Spring Boot, Maven/Gradle projects
- Servlet and Jakarta EE applications
- Standard Java source structure

**Go Ecosystem:**

- Gin, Fiber, Echo frameworks
- Go modules and standard library
- cmd/, pkg/, internal/ structure

**JavaScript/TypeScript:**

- React, Next.js, Vue, Svelte
- Express.js backend services
- Modern build systems (Webpack, Vite)

**Infrastructure:**

- Docker, Kubernetes, Docker Compose
- GitHub Actions, Terraform, Ansible
- Configuration files (YAML, JSON, TOML)

### **🔔 Cross-Platform Notifications**

Desktop alerts on session completion with smart summary extraction:

- **macOS**: `osascript` visual notifications
- **Linux**: `notify-send` desktop notifications
- **Summary Pattern**: Extracts "Summary:" lines from responses (≤100 chars)
- **Fallback**: Uses last line if no summary found
- **Silent Fail**: Notification errors don't break workflow

### **🔒 Security Protection**

Blocks sensitive file reads with comprehensive pattern matching:

- **Patterns**: `.env`, `secret`, `private`, `password`, `token`, `key`, `credential`
- **Java Security**: `application-prod.yml`, `prod.properties`, `.keystore`
- **SSH Keys**: `.pem`, `.p12`, `id_rsa`, `id_ed25519`, `.ssh/`
- **Immediate Block**: Throws error on sensitive file access attempts
- **No Retry**: Security errors escalate immediately (per AGENTS.md)
- **Console Warning**: Clear feedback on blocked access

## 📦 NotificationPlugin

### **Simple Notification System**

- **Function Export**: Uses OpenCode SDK v0.6.5 pattern
- **Toast Notifications**: Uses `client.tui.showToast()` API
- **Sound Alerts**: Cross-platform system sounds
- **Event Handling**: Proper throttling and deduplication
- **Summary Extraction**: Finds "Summary:" lines in responses

## 🚀 Usage

**Fully Automatic** - Zero configuration required:

- ✅ **Tech Stack Detection**: Identifies Java, Go, JS/TS, infrastructure projects
- ✅ **Context Enhancement**: Provides expert guidance based on detected frameworks
- ✅ **Desktop Notifications**: Session completion alerts with summaries
- ✅ **Security Blocking**: Prevents access to sensitive files
- ✅ **Toast Messages**: Framework-specific tips and guidance

**Plugin Integration**:

- Auto-loads from dotfiles `opencode/plugin/universal.js`
- Uses OpenCode SDK v0.6.5 async function export pattern
- Hooks into OpenCode SDK events seamlessly

## ✅ Design Principles

1. **KISS Principle** - Focused functionality, clear responsibilities
2. **Working First** - Proven patterns over experimental architectures
3. **Cross-Platform** - macOS and Linux compatibility required
4. **Security First** - Immediate escalation, no retry on security errors
5. **Silent Fail** - Non-critical errors don't break workflow
6. **AGENTS.md Compliant** - Follows established dotfiles protocols
7. **Manual Verification** - All changes include testing steps
8. **SDK Compatible** - Uses OpenCode SDK v0.6.5 standards

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
# 1. Check plugin syntax (both should pass without errors)
node -c opencode/plugin/universal.js
node -c opencode/plugin/notification.js

# 2. Verify cross-platform notification commands exist
# macOS:
which osascript  # Should exist
# Linux:
which notify-send  # Should exist

# 3. Test security patterns work
echo "Contains: secret, token, .env" | grep -E "(secret|token|\.env)"

# 4. Verify plugins export correct functions
node -e "
const universal = require('./opencode/plugin/universal.js');
const notification = require('./opencode/plugin/notification.js');
console.log('Universal exports:', Object.keys(universal));
console.log('Notification exports:', Object.keys(notification));
"
```

## 📚 Related Documentation

- [AGENTS.md](../AGENTS.md) - OpenCode protocol and agent routing rules
- [Agent Definitions](../agent/) - Individual agent configurations
- [Dotfiles README](../../README.md) - Project setup and verification
- [OpenCode Documentation](../../docs/opencode/) - Additional architecture details

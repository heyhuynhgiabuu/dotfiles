# OpenCode GPT-4.1 Optimization Guide

## What Changed

✅ **Default model** changed to `github-copilot/gpt-4.1` (free on Education)
✅ **New beast mode** with Beast Mode v3 optimizations
✅ **Enhanced agents** moved to free GPT-4.1 models where appropriate
✅ **Optimized prompts** for autonomous operation and reduced verbosity

## New Beast Mode Features

### 🚀 Autonomous Operation
- Never stops until problems are completely solved
- Iterates through solutions automatically
- No more incomplete tasks or partial implementations

### 🔍 Enhanced Research
- **Mandatory research** for all third-party packages
- **Recursive link following** from documentation
- **Google search integration** for current information
- **Verification protocols** for installation and configuration

### 📋 Smart Todo Management
```markdown
## 📋 Implementation Plan
- [ ] 🔍 Research current API documentation
- [x] ✅ Install dependencies with latest syntax
- [ ] 🛠️ Implement feature with error handling
```

### 🛡️ Environment Safety
- **Automatic .env creation** when API keys detected
- **No auto-commits** without explicit permission
- **Proactive security** best practices

### 💬 Reduced Verbosity
- **Concise communication** while maintaining completeness
- **Progress-focused updates** instead of explanations
- **Action-oriented responses** with clear next steps

## Usage Recommendations

### Primary Workflow (90% of work)
```bash
# For complex autonomous tasks
opencode --mode beast "Build a REST API with authentication"

# For interactive development
opencode --mode daily "Help me debug this function"

# For planning and analysis
opencode --mode plan "Design architecture for user management"
```

### Premium Usage (10% of work)
```bash
# Only for critical complex tasks
opencode --mode enhanced "Optimize performance of entire system"

# For important code reviews
opencode --mode review "Review this PR for production deployment"

# For security audits
opencode --mode security "Audit this authentication system"
```

## Cost Efficiency Tips

1. **Start with beast mode** - fully autonomous, no premium cost
2. **Batch related tasks** - handle multiple items in one session
3. **Use research effectively** - comprehensive information gathering
4. **Let it complete** - autonomous operation means fewer interruptions

## Key Improvements Over Stock GPT-4.1

- **10x better research** with mandatory webfetch and current info
- **Autonomous completion** instead of asking for permission
- **Smart file operations** avoiding redundant reads
- **Visual todo tracking** with emoji status indicators
- **Environment management** with proactive .env handling
- **Enhanced error handling** with systematic debugging

Your setup is now optimized to get maximum value from GitHub Copilot Education's free GPT-4.1 access! 🎉

---

# OpenCode Cross-Platform Dotfiles System - Usage Guide

## Configuration Architecture

### **Optimized Symlink-Based Setup**
- **Global OpenCode Config**: `dotfiles/opencode/` → symlinked to `~/.config/opencode/`
- **File path resolution**: `{file:AGENTS.md}` loads from `~/.config/opencode/AGENTS.md`
- **Project-Specific Rules**: Each repository has its own `AGENTS.md` for additional context
- **Cross-Platform Support**: All configurations tested on macOS and Linux

### **Simplified File Path Understanding**
When OpenCode loads `{file:AGENTS.md}`:
- **Global config directory**: `~/.config/opencode/AGENTS.md`
- **Via symlink**: `dotfiles/opencode/AGENTS.md`
- **Project context**: `./AGENTS.md` (automatically loaded when present)

### **Optimized Directory Structure**
```
dotfiles/
├── opencode/           # Symlinked to ~/.config/opencode/
│   ├── opencode.json   # Optimized global config
│   ├── AGENTS.md       # Enhanced global development rules
│   ├── prompts/        # Specialized prompt system
│   └── agent/          # Focused agent configurations
├── AGENTS.md           # Dotfiles-specific project rules
├── nvim/              # Cross-platform Neovim configs
├── tmux/              # Cross-platform tmux configs
└── zsh/               # Cross-platform zsh configs
```

## Available Modes (Optimized)

### **Cost-Optimized Primary Modes**
- **`beast`** - NEW: GPT-4.1 with Beast Mode v3 optimizations (0 premium requests, autonomous)
- **`daily`** - Primary development mode using GPT-4.1 (0 premium requests on Copilot Education)
- **`plan`** - Analysis and planning using GPT-4.1 (0 premium requests, research-enabled)
- **`debug`** - Troubleshooting with bash access using GPT-4.1 (0 premium requests)
- **`docs`** - Documentation writing using GPT-4.1 (0 premium requests)

### **Premium Modes (1x Request Per Session)**
- **`enhanced`** - Autonomous cross-platform dotfiles expertise using Claude Sonnet 4
- **`build`** - Advanced development mode using Claude Sonnet 4
- **`review`** - Code review using Claude Sonnet 4 (read-only with research)
- **`security`** - Security analysis using Claude Sonnet 4 (read-only with research)

### **Key Optimizations Applied**
1. **Autonomous operation patterns**: TodoWrite/TodoRead enabled for complex tasks
2. **Research capabilities**: WebFetch enabled across all modes for current information
3. **Cost efficiency**: Primary development uses GPT-4.1 (Copilot Education = 0 premium requests)
4. **Tool access simplified**: Only disabled tools specified (OpenCode best practice)

## Agent Configuration (Optimized)

### **Specialized Agents**
- **`security-audit`** - Quick backend security scans (Claude Sonnet 4, read-only)
- **`devops-deployer`** - Docker and deployment assistance (Claude Sonnet 4, bash-enabled)
- **`api-reviewer`** - Backend API code review (Claude Sonnet 4, read-only)
- **`docs-writer`** - Essential documentation creation (GPT-4.1, write-enabled)
- **`backend-troubleshooter`** - Debug backend issues (GPT-4.1, read-only)
- **`simple-researcher`** - Find solutions when obvious searches fail (Claude Sonnet 4, read-only)

### **Agent Optimization Changes**
1. **Tool access streamlined**: Only disabled tools specified
2. **Model consistency**: Security/review tasks use Claude Sonnet 4, docs/troubleshooting use GPT-4.1
3. **Appropriate permissions**: Each agent has minimal required tool access

## Practical Usage Examples

### **Cost-Optimized Daily Development**
```bash
cd ~/dotfiles
opencode --mode daily "Update tmux configuration for cross-platform compatibility"
```
- **Model**: GPT-4.1 (0 premium requests on Copilot Education)
- **Capabilities**: Full file operations, bash, research, autonomous task tracking
- **Context**: Global rules + dotfiles project guidelines

### **Complex Autonomous Tasks**
```bash
cd ~/dotfiles
opencode --mode enhanced "Set up comprehensive cross-platform development environment"
```
- **Model**: Claude Sonnet 4 (1 premium request per session)
- **Capabilities**: Full autonomous operation with TodoWrite/TodoRead
- **Context**: Comprehensive dotfiles expertise with research capabilities

### **Analysis and Planning**
```bash
cd ~/my-project
opencode --mode plan "Analyze this codebase for cross-platform compatibility"
```
- **Model**: GPT-4.1 (0 premium requests)
- **Capabilities**: Read-only with research and task tracking
- **Context**: Global rules + project-specific guidelines (if `AGENTS.md` exists)

## Context Loading Optimization

### **Simplified Global Instructions**
- **Primary**: `{file:AGENTS.md}` (enhanced global development rules)
- **Autonomous**: Enhanced mode uses specialized dotfiles prompt
- **Research-enabled**: All modes can fetch current documentation

### **Automatic Project Context**
- **Auto-detection**: OpenCode automatically loads `./AGENTS.md` from working directory
- **Dual-context**: Global rules + project-specific guidelines work together
- **No path confusion**: Simplified file references eliminate complexity

## Best Practices for Optimized Setup

### **Mode Selection Strategy**
1. **`beast` mode**: Complex autonomous development tasks (free on Copilot Education)
2. **`daily` mode**: 90% of interactive development work (free on Copilot Education)
3. **`plan` mode**: Analysis and exploration (free)
4. **`enhanced` mode**: Complex cross-platform tasks requiring deep expertise
5. **Agents**: Specialized tasks with specific tool requirements

### **Cost Management**
- **Maximize GPT-4.1 usage**: Leverage Copilot Education for zero premium requests
- **Strategic Claude usage**: Use enhanced/build modes for complex autonomous tasks
- **Session continuity**: Complete related tasks in same session to minimize premium requests

### **Research and Validation**
- **WebFetch enabled**: All modes can research current best practices
- **TodoWrite/TodoRead**: Complex tasks tracked systematically
- **Cross-platform testing**: Validate changes work on both macOS and Linux

This optimized setup provides maximum capability while minimizing costs, leveraging OpenCode's best practices for tool access, file resolution, and autonomous operation patterns.
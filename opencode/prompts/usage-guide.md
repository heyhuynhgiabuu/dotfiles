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
1. **`daily` mode**: 90% of development work (free on Copilot Education)
2. **`plan` mode**: Analysis and exploration (free)
3. **`enhanced` mode**: Complex cross-platform tasks requiring deep expertise
4. **Agents**: Specialized tasks with specific tool requirements

### **Cost Management**
- **Maximize GPT-4.1 usage**: Leverage Copilot Education for zero premium requests
- **Strategic Claude usage**: Use enhanced/build modes for complex autonomous tasks
- **Session continuity**: Complete related tasks in same session to minimize premium requests

### **Research and Validation**
- **WebFetch enabled**: All modes can research current best practices
- **TodoWrite/TodoRead**: Complex tasks tracked systematically
- **Cross-platform testing**: Validate changes work on both macOS and Linux

This optimized setup provides maximum capability while minimizing costs, leveraging OpenCode's best practices for tool access, file resolution, and autonomous operation patterns.
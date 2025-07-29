# OpenCode Optimized Configuration Setup

This document outlines the optimized OpenCode configuration following best practices from the official documentation for cost efficiency, autonomous operation, and cross-platform development.

## Architecture Overview

### **Symlink-Based Global Configuration**
The OpenCode configuration uses a symlink strategy that provides both global consistency and project-specific flexibility:

```
dotfiles/opencode/ → ~/.config/opencode/
├── opencode.json       # Optimized global configuration
├── AGENTS.md          # Enhanced global development rules  
├── prompts/           # Specialized autonomous prompts
└── agent/             # Focused task-specific agents
```

### **Key Optimizations Applied**

#### **1. Cost-Optimized Mode Strategy**
- **Primary development**: `daily` mode using GPT-4.1 (0 premium requests on Copilot Education)
- **Complex autonomous tasks**: `enhanced` mode using Claude Sonnet 4 (1 premium request per session)
- **Analysis and planning**: `plan` mode using GPT-4.1 (0 premium requests, research-enabled)

#### **2. OpenCode Best Practices Integration**
- **Tool access simplification**: Only disabled tools specified (not exhaustive true/false lists)
- **Autonomous operation patterns**: TodoWrite/TodoRead enabled for complex multi-step tasks
- **Research capabilities**: WebFetch enabled across all modes for current documentation
- **File path optimization**: Simplified references using OpenCode's native resolution

#### **3. Agent Configuration Optimization**
- **Model consistency**: Security/review tasks use Claude Sonnet 4, docs/troubleshooting use GPT-4.1
- **Minimal tool access**: Each agent has only necessary permissions
- **Focused responsibilities**: Clear task boundaries prevent overlap

## Configuration Details

### **Optimized Modes**

#### **Cost-Efficient Primary Modes** (GPT-4.1 - 0 Premium Requests)
```json
"daily": {
  "description": "Daily development mode with full access using GPT-4.1 (Copilot Education).",
  "model": "github-copilot/gpt-4.1",
  "temperature": 0.3,
  "tools": {
    "webfetch": true,
    "todowrite": true,
    "todoread": true
  }
}
```

#### **Autonomous Premium Mode** (Claude Sonnet 4 - 1 Premium Request)
```json
"enhanced": {
  "description": "Enhanced dotfiles mode with comprehensive expertise and autonomous operation",
  "model": "github-copilot/claude-sonnet-4",
  "temperature": 0.3,
  "prompt": "{file:prompts/global-development-prompt.md}",
  "tools": {
    "webfetch": true,
    "todowrite": true,
    "todoread": true
  }
}
```

### **Specialized Agents**

#### **Security-Focused Agents**
```json
"security-audit": {
  "description": "Quick security scan for backend code. Finds common vulns and compliance issues.",
  "model": "github-copilot/claude-sonnet-4",
  "prompt": "{file:agent/security-audit.md}",
  "tools": {
    "write": false,
    "edit": false,
    "bash": false,
    "webfetch": false,
    "todowrite": false,
    "todoread": false
  }
}
```

## Usage Patterns

### **Daily Development Workflow**
```bash
# Most development work (free on Copilot Education)
cd ~/dotfiles
opencode --mode daily "Update cross-platform zsh configuration"

# Complex autonomous tasks requiring deep expertise
opencode --mode enhanced "Set up comprehensive development environment"

# Analysis and planning (free, research-enabled)
opencode --mode plan "Analyze current tmux setup for optimization opportunities"
```

### **Agent-Driven Tasks**
```bash
# Security review using specialized agent
opencode "Review this backend code for security issues" 
# → Automatically uses security-audit agent

# DevOps assistance 
opencode "Help optimize this Dockerfile for security and size"
# → Automatically uses devops-deployer agent
```

## Best Practices Implementation

### **1. Research-First Methodology**
All modes now include `webfetch: true` to ensure:
- Current documentation verification
- Latest best practices integration
- Up-to-date configuration recommendations

### **2. Autonomous Operation Patterns** 
Complex modes include TodoWrite/TodoRead for:
- Multi-step task tracking
- Systematic progress management
- Completion verification

### **3. Cross-Platform Excellence**
- All configurations tested on macOS and Linux
- Platform-specific handling where necessary
- Consistent user experience across systems

### **4. Cost Optimization Strategy**
- **90% of work**: Use `daily` mode (GPT-4.1, 0 premium requests)
- **10% complex tasks**: Use `enhanced` mode (Claude Sonnet 4, 1 premium request)
- **Session continuity**: Complete related tasks in same session

## Migration from Previous Setup

### **Key Changes Made**
1. **Simplified tool access**: Removed exhaustive true/false tool listings
2. **Enhanced research capabilities**: Added webfetch to all modes
3. **Autonomous operation**: Added TodoWrite/TodoRead for complex tasks
4. **Cost optimization**: Prioritized GPT-4.1 for primary development
5. **Agent tool streamlining**: Focused permissions for each agent

### **Breaking Changes**
- **Enhanced mode prompt**: Now uses specialized autonomous prompt
- **Agent tool access**: Simplified to only specify disabled tools
- **Mode capabilities**: Research and task tracking now standard

### **Compatibility Notes**
- All existing workflows continue to function
- Performance improvements from simplified configuration
- Better cost efficiency with optimized model selection

## Validation and Testing

### **Configuration Verification**
```bash
# Test basic functionality
opencode --mode daily "Show current configuration status"

# Test research capabilities  
opencode --mode plan "Research current best practices for tmux configuration"

# Test autonomous operation
opencode --mode enhanced "Set up cross-platform development environment from scratch"
```

### **Cross-Platform Testing**
- macOS: Darwin-specific configurations handled appropriately
- Linux: Distribution-agnostic configuration patterns
- Shared: Common cross-platform patterns and utilities

This optimized setup leverages OpenCode's best practices while maintaining the educational, cross-platform focus that makes the dotfiles repository effective for learning and development.
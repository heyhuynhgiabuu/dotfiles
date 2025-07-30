# 🏠 Cross-Platform Development Dotfiles

Modern, efficient dotfiles for cross-platform development environments. Optimized for **macOS** and **Linux** with a focus on simplicity, functionality, and developer productivity.

## 🎯 Quick Start

```bash
# Clone repository
git clone https://github.com/heyhuynhgiabuu/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run setup (idempotent)
./scripts/install.sh
```

## 🛠️ Features

### 🎨 Enhanced Debug Environment
- **IntelliJ-like debugging experience** for Java and Go
- **5-panel sidebar layout** with organized debug information
- **Full-width console** for maximum output visibility
- **F-key hotkeys** matching IDE standards

#### Enhanced Debug Layout:
```
[Variables/Scopes  ] [                    ] [NvimTree]
[Call Stack       ] [    Code Editor     ] [        ]
[Breakpoints      ] [                    ] [        ]
[Watches          ] [                    ] [        ]
[Console+Controls ] [                    ] [        ]
[-------- REPL (Logs & Output) ----------] [        ]
```

#### Console vs REPL:
- **🎮 Console (Sidebar)**: Debug controls (play/pause/step buttons) + interface
- **📋 REPL (Bottom)**: Full-width logs, output, and interactive debugging

#### Debug Hotkeys:
- **F9**: Toggle Breakpoint
- **F5**: Start/Continue Debug
- **F10**: Step Over
- **F11**: Step Into
- **F4**: Toggle Debug UI
- **F12**: Quick Debug (Java/Go)

### 🔧 Tools & Technologies
- **Editor**: Neovim/NvChad with LSP integration
- **Terminal**: WezTerm + Tmux sessions
- **Shell**: Zsh with advanced completions
- **Languages**: Go, Java, JavaScript/TypeScript
- **Debug**: DAP with enhanced UI layout
- **Window Manager**: AeroSpace (macOS)

### 📁 Structure
```
├── nvim/          # Neovim configuration (Lua)
├── tmux/          # Tmux configuration and layouts
├── zsh/           # Zsh configuration and aliases
├── wezterm/       # Terminal configuration
├── scripts/       # Installation and utility scripts
├── opencode/      # OpenCode AI configuration
└── docs/          # Documentation and guides
```

## 🐛 Enhanced Debugging

### Quick Test
```bash
# Test the FINAL CORRECT layout
./scripts/verify-final-correct-layout.sh

# Open test file
nvim /tmp/debug-final-test/test.go
```

### Debug Features
- **5-Panel Sidebar**: Variables, Stack, Breakpoints, Watches, Console+Controls
- **Console vs REPL**: Console (controls) in sidebar, REPL (logs) at bottom
- **Control Integration**: Debug controls perfectly placed in sidebar Console
- **Auto-Open/Close**: UI management tied to debug sessions
- **Enhanced Help**: `<Leader>d?` for full guide, `<Leader>dL` for layout info

### Key Improvements
1. **Console in sidebar** - Debug controls (play/pause/step) perfectly integrated
2. **REPL at bottom** - Full-width logs and output for maximum visibility
3. **Controls integration** - Sidebar Console works perfectly with debug buttons
4. **Logical organization** - Controls where you interact, logs where you read
5. **Maximum efficiency** - Best use of screen real estate for debugging

## 🚀 Development Workflows

### Java Development
```bash
# Start Java layout
./scripts/tmux-java-layout.sh

# Debug with F12 or <Leader>dj
# Set breakpoints with F9
```

### Go Development  
```bash
# Start Go layout
./scripts/tmux-go-layout.sh

# Debug with F12 or <Leader>dg
# Set breakpoints with F9
```

## 🤝 Contributing

### Development Guidelines
1. **Test thoroughly** - Verify changes on both macOS and Linux
2. **Follow KISS principle** - Keep configurations simple and maintainable
3. **Update documentation** - Reflect changes in relevant docs
4. **Maintain cross-platform compatibility** - Ensure configs work everywhere
5. **Test F-key hotkeys** - Verify debugging and development workflows
6. **Preserve existing functionality** - Don't break working configurations

### Agent Guidelines
- **Clean commits** - No "Generated with opencode" messages in this repo
- **Respect structure** - Follow existing directory organization
- **Match conventions** - Use Lua for Neovim, shell for scripts
- **Self-contained configs** - New configurations shouldn't require external dependencies

## 📄 License

Personal dotfiles collection - use at your own discretion.

**Note**: This repository follows the KISS (Keep It Simple, Stupid) principle for maintainable, cross-platform development environments.
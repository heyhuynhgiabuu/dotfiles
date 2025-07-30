# IntelliJ IDEA-like nvim-jdtls Setup Guide

This guide explains how to configure nvim-jdtls to provide an IntelliJ IDEA-like Java development experience in Neovim.

## 🎯 Overview

Our configuration provides:
- **IntelliJ-style keymaps** for navigation and refactoring
- **Advanced code completion** with smart suggestions
- **Google Java Style** formatting (IntelliJ-compatible)
- **Code generation templates** similar to IntelliJ Live Templates
- **Intelligent import management** with automatic organization
- **Comprehensive refactoring** capabilities
- **Advanced debugging** integration with nvim-dap

## 🔧 Key Features Implemented

### 1. IntelliJ IDEA-Style Keymaps

#### Navigation (IntelliJ-compatible)
- **Ctrl+B**: Go to Declaration (same as IntelliJ)
- **Ctrl+Alt+B**: Go to Implementation 
- **Ctrl+H**: Go to Type Definition
- **Alt+F7**: Show Usages
- **gd**: Go to Definition (Vim-style)
- **gr**: Go to References (Vim-style)

#### Refactoring (IntelliJ hotkeys)
- **Ctrl+Alt+V**: Extract Variable
- **Ctrl+Alt+C**: Extract Constant  
- **Ctrl+Alt+M**: Extract Method
- **Ctrl+Alt+O**: Organize Imports
- **Ctrl+Alt+L**: Format Code
- **Shift+F6**: Rename Symbol

#### Code Generation (IntelliJ-style)
- **Alt+Insert**: Generate Code (getters, setters, constructors)
- **Alt+Enter**: Quick Fix/Intention Actions

### 2. Smart Code Completion

```lua
-- IntelliJ-like completion settings
completion = {
  enabled = true,
  maxResults = 50,
  guessMethodArguments = true,  -- Smart argument completion
  postfix = { enabled = true }, -- .var, .if, .for postfix completion
  
  favoriteStaticMembers = {
    -- Testing frameworks (like IntelliJ Live Templates)
    "org.junit.jupiter.api.Assertions.*",
    "org.mockito.Mockito.*",
    -- Java utilities
    "java.util.Objects.requireNonNull",
    "java.util.Collections.*",
    -- And more...
  }
}
```

### 3. Google Java Style Formatting

- **2-space indentation** (Google style)
- **100-character line limit**
- **Automatic brace forcing** for all control statements
- **Comment wrapping** enabled
- **IntelliJ-compatible XML configuration** loaded

### 4. Advanced Code Generation

```lua
codeGeneration = {
  generateComments = true,    -- Generate JavaDoc
  useBlocks = true,          -- Always use braces
  
  toString = {
    template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
    codeStyle = "STRING_FORMAT",
  },
  
  hashCodeEquals = {
    useInstanceof = true,      -- Modern instanceof checks
    useJava7Objects = true,    -- Use Objects.equals()/hashCode()
  }
}
```

### 5. Intelligent Import Management

```lua
sources = {
  organizeImports = {
    starThreshold = 5,        -- Use * imports after 5 classes
    staticStarThreshold = 3,  -- Use static * after 3 imports
  }
}

completion = {
  importOrder = {
    "java", "javax", "jakarta", "org", "com",
    "static java", "static javax", "static org", "static com"
  }
}
```

### 6. Code Cleanup on Save (IntelliJ-style)

```lua
cleanup = {
  actionsOnSave = {
    "addOverride",           -- Add @Override annotations
    "addDeprecated",         -- Add @Deprecated annotations  
    "qualifyMembers",        -- Qualify with 'this.'
    "addFinalModifier",      -- Add final where possible
    "instanceofPatternMatch", -- Modern pattern matching
    "lambdaExpression",      -- Convert to lambda expressions
  }
}
```

## 🚀 Function Key Layout

The configuration maintains IntelliJ-like function key behavior:

### Java Run/Test Operations (F5-F8)
- **F5**: Run Java Application
- **F6**: Debug Java Application  
- **F7**: Run Test Class
- **F8**: Run Nearest Test Method

### DAP Debug Controls (F9-F12)
- **F9**: Toggle Breakpoint
- **F10**: Step Over
- **F11**: Step Into
- **F12**: Step Out

### Java Debug Test Operations (Leader-based)
- **<leader>jdt**: Debug Test Class
- **<leader>jdn**: Debug Nearest Test Method

## 📋 Complete Keymap Reference

### Core LSP Operations
| Keymap | Function | IntelliJ Equivalent |
|--------|----------|-------------------|
| `gd` | Go to Definition | Ctrl+B |
| `gD` | Go to Declaration | Ctrl+B |
| `gi` | Go to Implementation | Ctrl+Alt+B |
| `gr` | Go to References | Alt+F7 |
| `K` | Show Hover Info | Ctrl+Q |
| `<C-k>` | Signature Help | Ctrl+P |

### IntelliJ-Style Shortcuts
| Keymap | Function | Description |
|--------|----------|-------------|
| `<C-A-o>` | Organize Imports | Ctrl+Alt+O |
| `<C-A-v>` | Extract Variable | Ctrl+Alt+V |
| `<C-A-c>` | Extract Constant | Ctrl+Alt+C |
| `<C-A-m>` | Extract Method | Ctrl+Alt+M |
| `<C-A-l>` | Format Code | Ctrl+Alt+L |
| `<S-F6>` | Rename Symbol | Shift+F6 |
| `<A-Insert>` | Generate Code | Alt+Insert |
| `<A-Enter>` | Quick Fix | Alt+Enter |

### Additional JDTLS Commands
| Keymap | Function |
|--------|----------|
| `<leader>jw` | Compile Workspace |
| `<leader>jr` | Compile Incremental |
| `<leader>js` | Open JShell |
| `<leader>jb` | Show Bytecode |

## 🛠️ Advanced Configuration Features

### 1. Multi-JDK Support
Configure multiple Java runtimes (like IntelliJ Project Structure):

```lua
configuration = {
  runtimes = {
    {
      name = "JavaSE-17",
      path = "/opt/homebrew/opt/openjdk@17",
      default = true,
    },
    {
      name = "JavaSE-21", 
      path = "/opt/homebrew/opt/openjdk@21",
    }
  }
}
```

### 2. Inlay Hints (Parameter Names)
Shows parameter names for method calls (like IntelliJ):

```lua
inlayHints = {
  parameterNames = {
    enabled = "literals",  -- Show for literals only
    exclusions = { "java.lang.String" }  -- Exclude common types
  }
}
```

### 3. Code Lens Integration
- **Implementation count** above interfaces/abstract methods
- **Reference count** above methods/fields
- **Test indicators** for test methods

### 4. Template System
Pre-configured file and type comment templates:

```lua
templates = {
  fileHeader = {
    "/**",
    " * ${type_name}",
    " *", 
    " * @author ${user}",
    " * @date ${date}",
    " */"
  }
}
```

## 🔍 Testing and Validation

### Basic Functionality Test
1. Open a Java file: `nvim HelloJava.java`
2. Wait for "Java LSP attached" message
3. Test completion with `Ctrl+Space`
4. Test navigation with `gd` on a method call
5. Test refactoring with `<C-A-v>` on a variable

### Debug Integration Test
1. Set a breakpoint with `F9`
2. Run debug with `F6`
3. Step through code with `F10`, `F11`
4. Test variable inspection

## 📁 Files Created/Modified

1. **`nvim/.config/nvim/ftplugin/java.lua`** - Enhanced with IntelliJ-like configuration
2. **`nvim/.config/nvim/lang-servers/intellij-java-google-style.xml`** - Google Style formatter configuration
3. **`docs/nvim-jdtls-intellij-setup.md`** - This documentation file

## 🎨 Customization Options

### Adjust Formatting Style
Modify the XML formatter configuration or change the profile:

```lua
format = {
  settings = {
    url = vim.fn.stdpath("config") .. "/lang-servers/your-custom-style.xml",
    profile = "YourStyle",
  }
}
```

### Customize Keymaps
Add your own IntelliJ-style shortcuts:

```lua
-- Example: Add Ctrl+Shift+F for global search
vim.keymap.set("n", "<C-S-f>", "<cmd>Telescope live_grep<cr>", 
  { desc = "Global Search (Ctrl+Shift+F)" })
```

### Extend Code Generation
Add more static members to favorites or customize templates:

```lua
favoriteStaticMembers = {
  "your.custom.framework.*",
  -- Add your commonly used static imports
}
```

## 🚨 Troubleshooting

### Common Issues

1. **"Java LSP not starting"**
   - Check Java installation: `java --version`
   - Verify jdtls installation via Mason: `:MasonInstall jdtls`

2. **"Formatting not working"**
   - Ensure XML file exists: `~/.config/nvim/lang-servers/intellij-java-google-style.xml`
   - Check file permissions

3. **"Keymaps not working"**
   - Verify no conflicts with other plugins
   - Check `:map <C-A-v>` to see current mapping

4. **"Completion too slow"**
   - Reduce `maxResults` from 50 to 20
   - Check project size and memory settings

### Debug Commands
- `:JdtShowLogs` - View language server logs
- `:LspInfo` - Check LSP client status
- `:lua print(vim.inspect(vim.lsp.get_active_clients()))` - Debug LSP clients

## 🌟 Benefits Over Standard Setup

1. **Familiar Keymaps** - IntelliJ users feel at home
2. **Faster Development** - Smart completion and refactoring
3. **Consistent Formatting** - Google Style across team
4. **Advanced Features** - Code generation, cleanup, templates
5. **Better Integration** - Seamless debugging with nvim-dap
6. **Cross-Platform** - Works on macOS and Linux

This configuration transforms Neovim into a powerful Java IDE that rivals IntelliJ IDEA while maintaining Vim's efficiency and customizability.

---

**Last Updated**: January 30, 2025  
**Compatibility**: Neovim 0.10+, nvim-jdtls, eclipse.jdt.ls 1.9+
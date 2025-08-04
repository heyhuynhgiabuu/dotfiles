# Which-Key Integration & Java Profiles for nvim-jdtls

## 🎯 Overview

This document covers the advanced **which-key integration** and **custom profile system** for nvim-jdtls. You now have:

- **📋 6 specialized Java profiles** for different project types
- **🔧 Complete which-key integration** with organized keymaps
- **🤖 Auto-detection** of project types and profile suggestions
- **⚡ Quick profile switching** without configuration changes

## 🔧 Which-Key Integration

### Primary Java Menu (`<leader>j`)

Once you open a Java file, press `<leader>j` to see the complete Java development menu:

```
☕ Java
├── 🧭 Navigation (jg)
├── 🔄 Refactoring (jx)  
├── 💡 Code Actions (jc)
├── 🔨 Build (jb)
├── ▶️ Run (jr)
├── 🧪 Testing (jt)
├── 🐛 Debug (jd)
├── 🔍 Diagnostics (jq)
├── ❓ Help (jh)
└── ⚙️ Settings/Profiles (js)
```

### Detailed Keymap Reference

#### 🧭 Navigation (`<leader>jg`)
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>jgd` | Go to Definition | Jump to symbol definition |
| `<leader>jgD` | Go to Declaration | Jump to symbol declaration |
| `<leader>jgi` | Go to Implementation | Show implementations |
| `<leader>jgr` | Go to References | Show all references |
| `<leader>jgt` | Go to Type Definition | Jump to type definition |

#### 🔄 Refactoring (`<leader>jx`)
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>jxv` | Extract Variable | Extract to local variable |
| `<leader>jxc` | Extract Constant | Extract to constant |
| `<leader>jxm` | Extract Method | Extract to method (visual mode) |
| `<leader>jxr` | Rename Symbol | Rename across project |

#### 💡 Code Actions (`<leader>jc`)
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>jca` | Show Code Actions | Available quick fixes |
| `<leader>jco` | Organize Imports | Auto-organize imports |
| `<leader>jcf` | Format Code | Format current buffer |

#### 🔨 Build (`<leader>jb`)
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>jbw` | Compile Workspace | Full workspace compile |
| `<leader>jbi` | Compile Incremental | Incremental compile |
| `<leader>jbc` | Clean Compile | Clean and full compile |

#### ▶️ Run (`<leader>jr`)
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>jra` | Run Application | Same as F5 |
| `<leader>jrd` | Debug Application | Same as F6 |
| `<leader>jrs` | Open JShell | Interactive Java shell |
| `<leader>jrb` | Show Bytecode | Display bytecode |

#### 🧪 Testing (`<leader>jt`)
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>jtc` | Run Test Class | Same as F7 |
| `<leader>jtm` | Run Test Method | Same as F8 |
| `<leader>jtd` | Debug Test Class | Debug entire test class |
| `<leader>jtn` | Debug Test Method | Debug nearest test method |

#### ⚙️ Profiles (`<leader>js`)
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>jsl` | List Profiles | Show all available profiles |
| `<leader>jss` | Select Profile | Interactive profile selector |
| `<leader>jsc` | Current Profile | Show current active profile |
| `<leader>jsa` | Auto-detect Profile | Suggest profile for project |
| `<leader>jsd` | Switch to Default | Quick switch to default |
| `<leader>jsp` | Switch to Spring Boot | Quick switch to Spring |
| `<leader>jse` | Switch to Enterprise | Quick switch to enterprise |
| `<leader>jst` | Switch to Testing | Quick switch to testing |

## 📋 Java Profiles System

### Available Profiles

#### 1. ☕ **Default Java** (`default`)
- **Use Case**: General Java development, learning, small projects
- **Features**: Basic Java completion, standard import organization
- **Settings**: Conservative settings, 50 completion results

#### 2. 🍃 **Spring Boot** (`spring`)
- **Use Case**: Spring Boot microservices, web applications
- **Features**: Spring-specific imports, framework completions
- **Settings**: 100 completion results, Spring static imports
- **Auto-detection**: Detects `spring-boot` in `pom.xml` or `build.gradle`

#### 3. 🤖 **Android** (`android`)
- **Use Case**: Android application development
- **Features**: Android SDK imports, UI component completions
- **Settings**: Android-specific import order, 75 completion results
- **Auto-detection**: Detects `AndroidManifest.xml` or Android project structure

#### 4. 🏢 **Enterprise** (`enterprise`)
- **Use Case**: Large enterprise applications, JEE, complex projects
- **Features**: Enterprise framework support, extensive completions
- **Settings**: 150 completion results, enterprise static imports
- **Auto-detection**: Detects JEE patterns, `webapp` directory

#### 5. 🧪 **Testing Focus** (`testing`)
- **Use Case**: Test-driven development, testing frameworks
- **Features**: JUnit, Mockito, AssertJ, Testcontainers support
- **Settings**: Testing-focused imports and completions
- **Auto-detection**: High test-to-source code ratio

#### 6. ⚡ **Performance** (`performance`)
- **Use Case**: High-performance applications, optimization
- **Features**: Concurrent utilities, streaming, benchmarking
- **Settings**: Reduced completion results (30), performance-focused imports

### Profile Management Commands

#### `:JavaProfile [profile_name]`
```vim
:JavaProfile                   " Show current profile and options
:JavaProfile spring           " Switch to Spring Boot profile
:JavaProfile testing          " Switch to Testing profile
```

#### `:JavaProfileDetect`
```vim
:JavaProfileDetect            " Auto-detect and suggest profile
```

#### `:JavaProfileInfo [profile_name]`
```vim
:JavaProfileInfo              " Show current profile details
:JavaProfileInfo enterprise   " Show enterprise profile info
```

### Setting Custom Profile via vim variable
```vim
" Set in your init.lua or before opening Java files
vim.g.java_profile = "spring"
```

### Profile Auto-Detection

The system automatically detects your project type:

1. **Spring Boot**: Looks for `spring-boot` dependencies
2. **Android**: Checks for `AndroidManifest.xml` or Android structure
3. **Enterprise**: Detects JEE patterns, web applications
4. **Testing**: Analyzes test-to-source ratio
5. **Default**: Fallback for general Java projects

## 🚀 Usage Examples

### Basic Workflow with Which-Key

1. **Open Java file**: `nvim MyClass.java`
2. **Access Java menu**: `<leader>j` → See all options
3. **Navigate code**: `<leader>jg` → Navigation submenu
4. **Refactor code**: `<leader>jx` → Refactoring options
5. **Run tests**: `<leader>jt` → Testing submenu

### Profile Switching Workflow

1. **Check current profile**: `<leader>jsc` or `:JavaProfile`
2. **Auto-detect suggestion**: `<leader>jsa` or `:JavaProfileDetect`  
3. **Select new profile**: `<leader>jss` (interactive) or `:JavaProfile spring`
4. **Restart Neovim** to apply changes

### Spring Boot Development Example

```bash
# Open Spring Boot project
cd my-spring-app
nvim src/main/java/Application.java

# In Neovim:
<leader>jsa    # Auto-detect suggests Spring profile
<leader>jsp    # Quick switch to Spring profile
# Restart Neovim
<leader>jcf    # Format with Spring-specific settings
<leader>jtc    # Run Spring tests
```

### Enterprise Development Example

```bash
# Open enterprise project  
cd enterprise-app
nvim src/main/java/service/UserService.java

# In Neovim:
:JavaProfile enterprise    # Switch to enterprise profile
# Restart Neovim
<leader>jco               # Organize imports (enterprise order)
<leader>jxv               # Extract variable with enterprise settings
```

## 🎨 Customization

### Adding Custom Profiles

Edit `nvim/.config/nvim/lua/custom/java-profiles.lua`:

```lua
-- Add new profile
M.profiles.custom = {
  name = "🔧 Custom",
  description = "My custom Java setup",
  settings = {
    java = {
      completion = {
        maxResults = 75,
        favoriteStaticMembers = {
          "com.mycompany.utils.*",
          -- Add your custom imports
        },
      },
    },
  },
  on_apply = function()
    vim.notify("🔧 Applied: Custom Profile", vim.log.levels.INFO)
    -- Custom setup logic
  end,
}
```

### Modifying Which-Key Groups

Edit the which-key configuration in `java.lua`:

```lua
-- Add custom which-key group
{ "<leader>jm", group = "🔧 My Tools", buffer = bufnr },
{ "<leader>jmt", function() 
  -- Your custom function
end, desc = "My Custom Tool", buffer = bufnr },
```

## 🔍 Troubleshooting

### Profile Not Applied
- **Issue**: Changes not visible after profile switch
- **Solution**: Restart Neovim (profiles apply at startup)

### Which-Key Not Showing
- **Issue**: `<leader>j` doesn't show Java menu
- **Solution**: Ensure which-key is loaded and Java file is open

### Auto-Detection Wrong
- **Issue**: Wrong profile suggested
- **Solution**: Manually set via `:JavaProfile <correct_profile>`

### Profile Settings Not Working
- **Issue**: Completion or imports not following profile
- **Solution**: Check `:JavaProfileInfo` and verify JDTLS restart

## 📊 Profile Comparison

| Feature | Default | Spring | Android | Enterprise | Testing | Performance |
|---------|---------|---------|---------|------------|---------|-------------|
| Completion Results | 50 | 100 | 75 | 150 | 100 | 30 |
| Static Imports | Basic | Spring-focused | Android-focused | Enterprise | Test-focused | Performance |
| Import Star Threshold | 5 | 3 | 5 | 8 | 5 | 10 |
| Auto-detected by | Fallback | spring-boot deps | Android structure | JEE patterns | Test ratio | Manual |
| Best for | Learning | Web services | Mobile apps | Large systems | TDD | Optimization |

## 🎯 Benefits

### 1. **Productivity Boost**
- **Which-key menus** eliminate the need to memorize keymaps
- **Profile-specific settings** optimize completion for your project type
- **Quick access** to all Java development functions

### 2. **Project-Specific Optimization**
- **Tailored completions** for Spring, Android, Enterprise, etc.
- **Relevant static imports** for your framework
- **Optimal settings** for different development styles

### 3. **Consistent Workflow**
- **Unified interface** across different project types
- **Predictable keymaps** following IntelliJ conventions
- **Seamless switching** between project types

### 4. **IntelliJ-like Experience**
- **Familiar shortcuts** (`Ctrl+Alt+V`, etc.) work alongside which-key
- **Professional IDE features** in Neovim
- **Rich context menus** for discovery

Your nvim-jdtls setup now provides a **professional, IDE-like Java development experience** with the flexibility of custom profiles and the discoverability of which-key integration! 🚀

---

**Created**: January 30, 2025  
**Compatibility**: Neovim 0.10+, nvim-jdtls, which-key.nvim  
**Files**: `java.lua`, `java-profiles.lua`
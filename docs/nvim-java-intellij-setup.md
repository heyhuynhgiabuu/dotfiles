# IntelliJ-like Java Development with nvim-java

Complete IntelliJ IDEA alternative setup using nvim-java for professional Java development in Neovim.

## Features Overview

### 🎯 **IntelliJ-like Features**
- ✅ **Spring Boot Tools** - Full Spring Boot development support
- ✅ **Advanced Debugging** - Visual debugger with breakpoints, watches, call stack
- ✅ **Test Runner** - JUnit integration with test reports
- ✅ **Code Refactoring** - Extract variable, method, constant, field
- ✅ **Build Integration** - Maven/Gradle support with auto-detection
- ✅ **Auto-completion** - Intelligent code completion with imports
- ✅ **Project Management** - Multiple run configurations and profiles

### 🔧 **Automatic Setup**
- **Zero Configuration** - Just install and start coding
- **Auto JDK Installation** - Automatically installs Java 17 LTS
- **Mason Integration** - Automatic LSP server and tool management
- **Dependency Resolution** - Handles JDTLS, debug adapters, test runners

## Keybindings (IntelliJ-style)

### **Build & Run** 
```
<leader>jr  - Run Main Class              (like Ctrl+Shift+F10)
<leader>js  - Stop Running Application    (like Ctrl+F2)
<leader>jl  - Toggle Logs                 (like Alt+4)
<leader>jb  - Build Workspace            (like Ctrl+F9)
<leader>jc  - Clean Workspace            (like Build → Clean)

F10         - Quick Run Main             (like Shift+F10)
```

### **Testing** 
```
<leader>jtc - Run Test Class             (like Ctrl+Shift+F10)
<leader>jtm - Run Test Method            (like Ctrl+Shift+F10)
<leader>jtd - Debug Test Class           (like Ctrl+Shift+F9)
<leader>jtM - Debug Test Method          (like Ctrl+Shift+F9)
<leader>jtr - View Test Report           (like Alt+4)

F9          - Quick Run Tests            (like Ctrl+Shift+F10)
Shift+F9    - Quick Debug Tests          (like Ctrl+Shift+F9)
```

### **Refactoring** 
```
<leader>jxv - Extract Variable           (like Ctrl+Alt+V)
<leader>jxV - Extract Variable (All)     (like Ctrl+Alt+V)
<leader>jxc - Extract Constant           (like Ctrl+Alt+C)
<leader>jxm - Extract Method             (like Ctrl+Alt+M)
<leader>jxf - Extract Field              (like Ctrl+Alt+F)
```

### **Debugging** 
```
<leader>jd  - Configure DAP              (like Run → Edit Configurations)
<leader>db  - Toggle Breakpoint          (like Ctrl+F8)
<leader>dB  - Conditional Breakpoint     (like Ctrl+Shift+F8)
<leader>dr  - Open Debug REPL            (like Alt+8)
<leader>du  - Toggle Debug UI            (like Alt+5)

F5          - Continue/Start Debug       (like F9)
F6          - Step Over                  (like F8)
F7          - Step Into                  (like F7)
F8          - Step Out                   (like Shift+F8)
Shift+F10   - Debug Main Class          (like Shift+F9)
```

### **Project Management** 
```
<leader>jp  - Open Run Profiles          (like Run → Edit Configurations)
<leader>jk  - Change JDK Runtime         (like File → Project Structure)
```

## Project Structure Support

### **Supported Build Systems**
- **Maven** - `pom.xml` detection and integration
- **Gradle** - `build.gradle`, `build.gradle.kts` support
- **Multi-module** - Handles complex project structures

### **Framework Support**
- **Spring Boot** - Auto-configuration and tools
- **JUnit** - Test discovery and execution
- **Lombok** - Annotation processing support

## Configuration Details

### **Automatic Features**
```lua
-- Auto-installed components:
jdtls = 'v1.43.0'           -- Java Language Server
java_test = '0.40.1'        -- Test runner integration  
java_debug_adapter = '0.58.1' -- Debugging support
spring_boot_tools = '1.55.1'  -- Spring Boot integration
lombok = 'nightly'          -- Lombok support
jdk = '17.0.2'             -- Java Development Kit
```

### **Enhanced LSP Settings**
- **Smart Imports** - Auto-organize imports on save
- **Parameter Hints** - Inline parameter name hints
- **Code Lens** - Reference counts and quick actions
- **Signature Help** - Method signature assistance
- **Source Download** - Maven/Gradle source attachment

## Development Workflow

### **Typical Session**
1. **Open Java Project** - nvim-java auto-detects build system
2. **Code with Intelligence** - Full LSP completion and diagnostics
3. **Run/Test** - Use F9/F10 for quick execution
4. **Debug** - Set breakpoints with `<leader>db`, debug with F5-F8
5. **Refactor** - Extract methods/variables with `<leader>jx*`

### **Spring Boot Development**
```bash
# Open Spring Boot project
cd my-spring-app
nvim src/main/java/Application.java

# In Neovim:
<leader>jr    # Run Spring Boot application
<leader>jtc   # Run integration tests
<leader>jl    # View application logs
```

### **Test-Driven Development**
```bash
# Write test first
<leader>jtm   # Run current test method
# Implement feature
<leader>jtc   # Run full test class
<leader>jtr   # View test report
```

## Migration from IntelliJ

### **Feature Mapping**
| IntelliJ Feature | nvim-java Equivalent |
|------------------|----------------------|
| Run Configuration | `<leader>jp` |
| Debug Mode | F5-F8, `<leader>du` |
| Test Runner | `<leader>jt*` |
| Refactor Menu | `<leader>jx*` |
| Project Tool Window | `:NvimTreeToggle` |
| Terminal | `<leader>tv` |
| Build Project | `<leader>jb` |

### **Advantages over IntelliJ**
- **Lightweight** - No heavy IDE overhead
- **Customizable** - Full Neovim ecosystem access
- **Fast Startup** - Instant project loading
- **Integrated Terminal** - Native tmux/terminal workflow
- **Git Integration** - Built-in fugitive.vim support

## Troubleshooting

### **Common Issues**
1. **JDK Not Found** - nvim-java auto-installs Java 17
2. **Project Not Detected** - Ensure `pom.xml` or `build.gradle` exists
3. **LSP Not Starting** - Check `:LspInfo` and restart Neovim
4. **Tests Not Running** - Verify JUnit dependencies in build file

### **Debug Commands**
```
:JavaSettingsChangeRuntime  # Switch JDK versions
:JavaBuildCleanWorkspace    # Clean and rebuild
:LspRestart                 # Restart language server
:Mason                      # Check installed tools
```

## Performance Optimizations

- **Lazy Loading** - Java features load only for `.java` files
- **Efficient LSP** - Shared JDTLS instance across projects
- **Smart Indexing** - Incremental workspace analysis
- **Memory Management** - Configurable JVM heap settings

Your Neovim setup now provides a complete IntelliJ IDEA alternative for Java development! 🚀

## Next Steps

1. **Open a Java project** and test the configuration
2. **Try debugging** with breakpoints and stepping
3. **Run tests** to verify JUnit integration
4. **Use refactoring tools** to experience IntelliJ-like features
5. **Create run profiles** for different execution scenarios
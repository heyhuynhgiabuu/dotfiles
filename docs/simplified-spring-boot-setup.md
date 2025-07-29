# Simplified Spring Boot Java Setup

## Overview

A streamlined Java development environment focused on Spring Boot development with integrated Spring application profile management.

## 🍃 Profile System

### Available Profiles

**Default Profile (🍃 Spring Boot)**
- Spring Boot development with standard configurations
- Optimized for microservices and web applications
- 100 completion results, Spring-focused static imports
- Auto-detects and scans Spring application profiles

**Enhanced Profile (🍃 Spring Boot Pro)**
- Advanced Spring Boot with enterprise features
- Microservices focus with security, data, and testing
- 150 completion results, comprehensive static imports
- Maven source downloads, advanced code generation

## 🎯 Auto-Detection

The system automatically detects Spring Boot projects by scanning:
- `pom.xml` for Spring Boot dependencies
- `build.gradle` / `build.gradle.kts` for Spring Boot plugins
- Defaults to Spring Boot profile for all Java projects

## 🍃 Spring Application Profile Integration

### Profile Scanning
- Automatically scans for Spring application profiles
- Detects `application-{profile}.yml/yaml/properties` files
- Fallback to common profiles: `dev`, `local`, `test`

### Profile Management
- Set active profiles via environment: `SPRING_PROFILES_ACTIVE`
- Interactive profile selection via `:SpringProfiles`
- Quick profile switching in which-key menus

### Common Profiles for Your Projects
- `lcl` - Local development
- `prd` - Production 
- `hunterio` - Hunter.io integration
- `lcl,hunterio` - Local with Hunter.io (typical development setup)

## 🔧 Key Features

### Which-Key Integration

**Java Development (`<leader>j`)**
- `<leader>js` - Settings/Profiles
- `<leader>jsp` - Spring Profiles management
- `<leader>jr` - Run commands
- `<leader>jrS` - Spring Boot specific runs

**Spring Profile Management (`<leader>jsp`)**
- `<leader>jsps` - Select Spring profiles interactively
- `<leader>jspc` - Show current Spring profiles
- `<leader>jspr` - Scan for available Spring profiles
- `<leader>jspd` - Set to dev profile
- `<leader>jspl` - Set to lcl profile
- `<leader>jspp` - Set to prd profile
- `<leader>jsph` - Set to lcl,hunterio profile

**Spring Boot Runs (`<leader>jrS`)**
- `<leader>jrSr` - Run with current profiles
- `<leader>jrSd` - Run with dev profile
- `<leader>jrSl` - Run with lcl profile
- `<leader>jrSp` - Run with prd profile
- `<leader>jrSh` - Run with lcl,hunterio profile
- `<leader>jrSs` - Run with selected profiles

### User Commands

**`:JavaProfile [profile]`**
- List available profiles (no args)
- Switch to specific profile

**`:SpringRun [profiles]`**
- Run Spring Boot app with current profiles (no args)
- Run with specific profiles (e.g., `:SpringRun lcl,hunterio`)

**`:SpringProfiles [profiles]`**
- Show current and available Spring profiles (no args)
- Set active Spring profiles (e.g., `:SpringProfiles lcl,hunterio`)

### Function Keys

**Java-specific (F5-F8)**
- `F5` - Run Java Application
- `F6` - Debug Java Application  
- `F7` - Run Test Class
- `F8` - Run Nearest Test Method

**Debug Controls (F9-F12)**
- `F9` - Toggle Breakpoint
- `F10` - Step Over
- `F11` - Step Into
- `F12` - Step Out

## 🚀 Usage Examples

### Setting Up Local Development
```vim
:SpringProfiles lcl,hunterio
:SpringRun
```

### Quick Profile Switching
```vim
<leader>jsph  " Set to lcl,hunterio
<leader>jrSh  " Run with lcl,hunterio
```

### Profile Detection
```vim
:JavaProfileDetect  " Auto-detect suitable profile
:JavaProfile        " List all profiles
```

## 🔄 Migration from Previous System

### Removed Profiles
- Android - Focus on Spring Boot only
- Enterprise - Merged into Spring Boot Pro
- Testing - Integrated into Spring Boot profiles
- Performance - Not needed for typical Spring development

### Retained Features
- IntelliJ-like keymaps and configurations
- Which-key integration
- Profile auto-detection
- Code generation and formatting

### New Features
- Spring application profile integration
- Spring Boot run commands with profile selection
- Simplified profile management
- Environment-based profile activation

## 🎯 Benefits

1. **Focused Development** - Only Spring Boot profiles, no distractions
2. **Profile Integration** - nvim-jdtls profiles work with Spring application profiles
3. **Quick Switching** - Easy profile changes for different environments
4. **Project-Aware** - Automatically detects and suggests appropriate profiles
5. **Streamlined Workflow** - Common development tasks accessible via which-key

This setup provides a complete Spring Boot development environment with seamless integration between Neovim Java profiles and Spring application profiles.
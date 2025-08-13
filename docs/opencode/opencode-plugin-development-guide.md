# OpenCode Plugin Development Guide

## 🚀 Quick Start

This guide helps you extend OpenCode with custom plugins using the standardized plugin system.

### Prerequisites

- Node.js ≥18.0.0
- TypeScript knowledge
- Basic understanding of OpenCode

### Plugin System Overview

The OpenCode plugin system allows you to:
- Add custom commands and tools
- Integrate external CLIs and services
- Extend OpenCode functionality
- Share plugins with the community

## 📁 Plugin Structure

### Standardized Directory Layout

```
opencode/plugin/plugins/
├── README.md                    # This file
├── your-plugin-name/
│   ├── dist/                   # Compiled output (auto-generated)
│   │   ├── index.js           # Main plugin file
│   │   ├── index.d.ts         # TypeScript declarations
│   │   └── index.js.map       # Source maps
│   ├── src/                   # Source files
│   │   └── index.ts           # Main plugin source
│   ├── node_modules/          # Dependencies (auto-generated)
│   ├── package.json           # NPM configuration
│   ├── plugin.json            # OpenCode plugin metadata
│   ├── tsconfig.json          # TypeScript configuration
│   ├── types.d.ts             # Plugin-specific types
│   ├── README.md              # Plugin documentation
│   └── TESTING_CHECKLIST.md   # Manual testing procedures
```

## 🛠️ Creating Your First Plugin

### Step 1: Setup Plugin Directory

```bash
# Navigate to plugins directory
cd opencode/plugin/plugins

# Create your plugin directory
mkdir my-awesome-plugin
cd my-awesome-plugin
```

### Step 2: Initialize Package Configuration

Create `package.json`:

```json
{
  "name": "my-awesome-plugin",
  "version": "1.0.0",
  "description": "My awesome OpenCode plugin",
  "main": "dist/index.js",
  "type": "module",
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "clean": "rm -rf dist",
    "test": "echo \"Run manual tests as described in TESTING_CHECKLIST.md\""
  },
  "keywords": ["opencode", "plugin"],
  "author": "Your Name",
  "license": "MIT",
  "peerDependencies": {
    "@opencode-ai/plugin": "*"
  },
  "devDependencies": {
    "typescript": "^5.0.0",
    "@types/node": "^20.0.0"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
```

### Step 3: Create Plugin Configuration

Create `plugin.json`:

```json
{
  "name": "my-awesome-plugin",
  "version": "1.0.0",
  "description": "My awesome OpenCode plugin that does amazing things",
  "author": "Your Name",
  "main": "dist/index.js",
  "type": "module",
  "keywords": ["opencode", "plugin", "awesome"],
  "repository": "https://github.com/yourusername/my-awesome-plugin",
  "license": "MIT"
}
```

### Step 4: Setup TypeScript Configuration

Create `tsconfig.json`:

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "node",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "removeComments": false,
    "noEmitOnError": true
  },
  "include": ["src/**/*", "types.d.ts"],
  "exclude": ["node_modules", "dist"]
}
```

### Step 5: Define Plugin Types

Create `types.d.ts`:

```typescript
// Plugin-specific type definitions
export interface MyPluginOptions {
  option1?: string;
  option2?: number;
  option3?: boolean;
}

export interface MyPluginResult {
  success: boolean;
  data?: any;
  error?: string;
  command: string;
}
```

### Step 6: Implement Plugin Logic

Create `src/index.ts`:

```typescript
import type { Plugin } from "@opencode-ai/plugin";
import type { MyPluginOptions, MyPluginResult } from "../types.d.ts";

// Helper function for your plugin logic
async function myPluginFunction($: any, options: MyPluginOptions): Promise<MyPluginResult> {
  try {
    // Your plugin logic here
    const result = await $`echo "Hello from my plugin!"`.quiet();
    
    return {
      success: true,
      data: {
        message: result.stdout.trim(),
        options,
        timestamp: new Date().toISOString()
      },
      command: 'myPluginFunction'
    };
  } catch (error) {
    return {
      success: false,
      error: `Plugin error: ${error instanceof Error ? error.message : String(error)}`,
      command: 'myPluginFunction'
    };
  }
}

// Main plugin function
const plugin: Plugin = async ({ app, client, $ }) => {
  return {
    // Handle tool execution
    "tool.execute.after": async ({ tool, sessionID, callID }, output) => {
      // Only handle our plugin commands
      if (tool !== 'myAwesomeCommand') {
        return;
      }

      try {
        const args = output.args || {};
        const result = await myPluginFunction($, args);

        // Update output with our result
        output.title = result.success ? `✅ ${tool}` : `❌ ${tool}`;
        output.output = JSON.stringify(result, null, 2);
        output.metadata = {
          success: result.success,
          command: result.command,
          timestamp: new Date().toISOString()
        };

      } catch (error) {
        output.title = `❌ ${tool} (Error)`;
        output.output = JSON.stringify({
          success: false,
          error: `Plugin execution error: ${error instanceof Error ? error.message : String(error)}`,
          command: tool
        }, null, 2);
      }
    },

    // Handle events (optional)
    event: async ({ event }) => {
      if (event.type === "session.start") {
        console.log(`[${plugin.name}] Plugin loaded successfully`);
      }
    }
  };
};

export default plugin;
```

### Step 7: Install Dependencies and Build

```bash
# Install dependencies
npm install

# Build the plugin
npm run build

# Verify build output
ls dist/  # Should show index.js, index.d.ts, index.js.map
```

## 🧪 Testing Your Plugin

### Create Testing Checklist

Create `TESTING_CHECKLIST.md`:

```markdown
# My Awesome Plugin - Testing Checklist

## ✅ Pre-Testing Setup
- [ ] Node.js >=18.0.0 installed
- [ ] Plugin compiles successfully: `npm run build`
- [ ] All required files present

## 🚀 Functionality Tests
- [ ] Plugin loads in OpenCode: `/plugins`
- [ ] Plugin commands appear in help: `/help`
- [ ] Basic command works: `/myAwesomeCommand`
- [ ] Error handling works: `/myAwesomeCommand` with invalid input

## 🔧 Cross-Platform Tests
- [ ] Works on macOS
- [ ] Works on Linux
- [ ] Paths are platform-agnostic

## ❌ Error Scenarios
- [ ] Graceful error handling
- [ ] Meaningful error messages
- [ ] No OpenCode crashes

## 📊 Final Verification
- [ ] All tests pass
- [ ] Documentation accurate
- [ ] Ready for production use
```

### Automated Verification

Use the provided verification script:

```bash
# From dotfiles root
./scripts/verify/verify-opencode-plugin.sh
```

## 🎯 Advanced Plugin Development

### Integrating External CLIs

Example pattern for CLI integration:

```typescript
async function executeExternalCommand($: any, command: string[]): Promise<MyPluginResult> {
  try {
    // Check if CLI is available
    const versionCheck = await $`my-cli --version`.quiet().nothrow();
    if (versionCheck.exitcode !== 0) {
      return {
        success: false,
        error: "my-cli not found. Please install: npm install -g my-cli",
        command: command.join(' ')
      };
    }

    // Execute the command
    const result = await $`my-cli ${command}`.quiet().nothrow();
    
    if (result.exitcode !== 0) {
      return {
        success: false,
        error: `Command failed: ${result.stderr || 'Unknown error'}`,
        command: command.join(' ')
      };
    }

    // Parse output if JSON
    let data: any = result.stdout;
    try {
      data = JSON.parse(result.stdout);
    } catch {
      data = result.stdout.trim();
    }

    return {
      success: true,
      data,
      command: command.join(' ')
    };
  } catch (error) {
    return {
      success: false,
      error: `Execution error: ${error instanceof Error ? error.message : String(error)}`,
      command: command.join(' ')
    };
  }
}
```

### Error Handling Best Practices

1. **Always catch errors** - Never let exceptions crash OpenCode
2. **Meaningful messages** - Help users understand what went wrong
3. **Graceful degradation** - Plugin should fail safely
4. **Resource cleanup** - Clean up any temporary resources

### Cross-Platform Considerations

```typescript
// ✅ Good: Platform-agnostic
const result = await $`node --version`;

// ❌ Bad: Platform-specific
const result = await $`ls -la`;  // Use 'dir' on Windows

// ✅ Good: Check platform
const platform = process.platform;
const listCommand = platform === 'win32' ? 'dir' : 'ls -la';
const result = await $`${listCommand}`;
```

## 📚 Reference Examples

### VectorCode Plugin

See `opencode-vectorcode-plugin/` for a complete reference implementation:

- **Complex CLI integration** with VectorCode
- **Multiple commands** (getContext, query, index)
- **Advanced error handling** and validation
- **JSON response formatting**
- **Comprehensive testing checklist**

### Key Learning Points from VectorCode Plugin

1. **CLI Availability Check**: Always verify external tools are installed
2. **Command Validation**: Validate input parameters before execution  
3. **Structured Responses**: Use consistent JSON response format
4. **Error Recovery**: Handle both plugin errors and CLI errors
5. **Documentation**: Comprehensive README and testing procedures

## 🚨 Common Pitfalls

### 1. Missing Error Handling
```typescript
// ❌ Bad: No error handling
const result = await $`some-command`;
return { success: true, data: result.stdout };

// ✅ Good: Proper error handling
try {
  const result = await $`some-command`.nothrow();
  if (result.exitcode !== 0) {
    return { success: false, error: result.stderr };
  }
  return { success: true, data: result.stdout };
} catch (error) {
  return { success: false, error: error.message };
}
```

### 2. Platform-Specific Commands
```typescript
// ❌ Bad: Unix-only
await $`grep pattern file.txt`;

// ✅ Good: Cross-platform alternative
const content = await fs.readFile('file.txt', 'utf8');
const matches = content.split('\n').filter(line => line.includes(pattern));
```

### 3. Missing Validation
```typescript
// ❌ Bad: No input validation
async function myCommand($: any, options: any) {
  return await $`command ${options.file}`;
}

// ✅ Good: Input validation
async function myCommand($: any, options: any) {
  if (!options.file) {
    return { success: false, error: "File parameter required" };
  }
  // Continue with command...
}
```

## 🔧 Development Workflow

### 1. Development Loop
```bash
# Start development
cd opencode/plugin/plugins/my-plugin
npm run dev  # Watch mode for TypeScript compilation

# In another terminal, test changes
opencode  # Start OpenCode and test plugin
```

### 2. Testing Loop
```bash
# Build and verify
npm run build
./scripts/verify/verify-opencode-plugin.sh

# Manual testing in OpenCode
# Follow TESTING_CHECKLIST.md
```

### 3. Release Preparation
```bash
# Final build
npm run clean
npm run build

# Final verification
./scripts/verify/verify-opencode-plugin.sh

# Test on both platforms (if available)
# Update documentation
# Create release notes
```

## 🌟 Best Practices Summary

### Code Quality
- ✅ Use TypeScript for type safety
- ✅ Include comprehensive error handling
- ✅ Follow consistent code patterns
- ✅ Add meaningful comments for complex logic

### Testing
- ✅ Create detailed testing checklists
- ✅ Test all functionality and edge cases  
- ✅ Verify cross-platform compatibility
- ✅ Test error scenarios

### Documentation
- ✅ Write clear README with examples
- ✅ Document all commands and options
- ✅ Include troubleshooting guide
- ✅ Provide manual testing procedures

### Maintenance
- ✅ Use semantic versioning
- ✅ Keep dependencies up to date
- ✅ Monitor for issues and user feedback
- ✅ Regular compatibility testing

## 🎉 Plugin Distribution

### Sharing Your Plugin

1. **Create GitHub Repository**
2. **Write Comprehensive Documentation**
3. **Include Examples and Screenshots**
4. **Provide Installation Instructions**
5. **Add License and Contributing Guidelines**

### Plugin Naming Conventions

- Use descriptive names: `opencode-vectorcode-plugin`
- Follow pattern: `opencode-[service]-plugin`
- Keep names short but clear
- Use lowercase with hyphens

## 🆘 Troubleshooting

### Plugin Not Loading
1. Check `plugin.json` syntax
2. Verify `dist/index.js` exists
3. Check TypeScript compilation errors
4. Review OpenCode logs

### Commands Not Working
1. Verify plugin registration in code
2. Check command names in tool execution handler
3. Test with `/plugins` and `/help` commands
4. Review plugin-specific logs

### Build Issues
1. Check TypeScript configuration
2. Verify all dependencies installed
3. Check for syntax errors
4. Review import/export statements

### Cross-Platform Issues
1. Test on target platforms
2. Use platform-agnostic commands
3. Check file path separators
4. Verify environment variables

## 📞 Getting Help

- **OpenCode Documentation**: [docs.opencode.ai](https://docs.opencode.ai)
- **Plugin Examples**: Check existing plugins in this directory
- **TypeScript Help**: [typescriptlang.org](https://www.typescriptlang.org)
- **Community**: OpenCode Discord/GitHub Discussions

---

**Happy Plugin Development! 🚀**
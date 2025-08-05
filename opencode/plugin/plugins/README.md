# OpenCode Plugin System

## 📂 Standardized Plugin Structure

This directory contains individual OpenCode plugins that extend functionality.

### Current Plugins

- **opencode-vectorcode-plugin**: VectorCode CLI integration for context querying and indexing

### Plugin Structure Standard

Each plugin should follow this structure:

```
plugins/
└── your-plugin-name/
    ├── dist/           # Compiled JavaScript (required)
    │   ├── index.js    # Main plugin file
    │   └── index.d.ts  # TypeScript declarations
    ├── src/            # Source TypeScript files
    │   └── index.ts    # Main source file
    ├── package.json    # Plugin dependencies and metadata
    ├── plugin.json     # OpenCode plugin configuration
    ├── tsconfig.json   # TypeScript compilation config
    ├── README.md       # Plugin documentation
    ├── TESTING_CHECKLIST.md  # Manual testing procedures
    └── types.d.ts      # Plugin-specific types
```

### Adding New Plugins

1. **Create Plugin Directory**
   ```bash
   mkdir -p opencode/plugin/plugins/your-plugin-name
   cd opencode/plugin/plugins/your-plugin-name
   ```

2. **Setup Package Configuration**
   ```json
   {
     "name": "your-plugin-name",
     "version": "1.0.0",
     "main": "dist/index.js",
     "type": "module",
     "scripts": {
       "build": "tsc",
       "dev": "tsc --watch"
     },
     "peerDependencies": {
       "@opencode-ai/plugin": "*"
     }
   }
   ```

3. **Create Plugin Configuration** (`plugin.json`)
   ```json
   {
     "name": "your-plugin-name",
     "version": "1.0.0",
     "description": "Your plugin description",
     "author": "Your Name",
     "main": "dist/index.js",
     "type": "module"
   }
   ```

4. **Build Plugin**
   ```bash
   npm install
   npm run build
   ```

5. **Test Plugin**
   - Follow TESTING_CHECKLIST.md
   - Verify `/plugins` command shows your plugin
   - Test functionality manually

### Plugin Development Guidelines

#### Cross-Platform Requirements
- All plugins MUST work on macOS and Linux
- Use platform-agnostic paths and commands
- Test on both platforms before release

#### Code Standards
- TypeScript preferred for type safety
- Include comprehensive error handling
- Provide meaningful error messages
- Follow existing code patterns

#### Documentation Standards
- Include detailed README.md
- Provide TESTING_CHECKLIST.md for manual verification
- Document all commands and options
- Include troubleshooting section

#### Testing Requirements
- Manual testing checklist required
- Test all functionality and edge cases
- Verify error handling scenarios
- Cross-platform testing essential

### Plugin Loading

OpenCode automatically discovers plugins in this directory structure:
- Scans `plugins/*/plugin.json` for configurations
- Loads compiled JavaScript from `dist/index.js`
- Registers plugin commands and hooks

### Troubleshooting

#### Plugin Not Loading
1. Check `plugin.json` syntax and required fields
2. Verify `dist/index.js` exists and is valid
3. Check for TypeScript compilation errors
4. Review OpenCode logs for specific errors

#### Plugin Commands Not Working
1. Verify plugin is listed in `/plugins` command
2. Check command registration in plugin code
3. Test with `/help` command to see available commands
4. Review plugin-specific documentation

### Examples

See `opencode-vectorcode-plugin/` for a complete reference implementation demonstrating:
- Complex CLI integration
- Error handling patterns
- JSON response formatting
- Cross-platform compatibility
- Comprehensive testing procedures

## 🔧 Development Workflow

1. **Clone Template**: Copy structure from existing plugin
2. **Implement Features**: Follow TypeScript patterns
3. **Build & Test**: Use provided testing checklist
4. **Document**: Update README and testing procedures
5. **Verify**: Cross-platform testing required

## 📚 Resources

- [OpenCode Plugin API Documentation](https://docs.opencode.ai/plugins)
- [TypeScript Configuration Guide](https://www.typescriptlang.org/tsconfig)
- [Plugin Testing Best Practices](./opencode-vectorcode-plugin/TESTING_CHECKLIST.md)
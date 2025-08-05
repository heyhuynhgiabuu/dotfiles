# OpenCode VectorCode Plugin

A comprehensive TypeScript plugin for OpenCode that integrates with VectorCode CLI to provide intelligent code context retrieval, querying, and indexing capabilities.

## 🚀 Features

- **Get Context**: Retrieve current project context and available collections
- **Query Code**: Search through indexed code with semantic similarity
- **Index Files**: Add new files to the VectorCode database
- **Error Handling**: Robust error handling with clear feedback
- **Cross-Platform**: Works on macOS and Linux
- **TypeScript**: Full type safety and IntelliSense support

## 📋 Prerequisites

### Required Dependencies

1. **VectorCode CLI** (v0.7.0+)
   ```bash
   # Install via pip
   pip install vectorcode
   
   # Or install from source
   git clone https://github.com/GiovanniKaaijk/vectorcode
   cd vectorcode
   pip install -e .
   ```

2. **Node.js** (v18.0.0+)
   ```bash
   # Check version
   node --version
   ```

3. **OpenCode** (with plugin support)
   ```bash
   # Verify OpenCode installation
   opencode --version
   ```

### Verify VectorCode Installation

```bash
# Check if VectorCode is properly installed
vectorcode --version

# Initialize a project (if not already done)
vectorcode init

# Test basic functionality
vectorcode ls
```

## 🛠️ Installation

### Method 1: Manual Installation

1. **Clone or copy the plugin**:
   ```bash
   git clone <this-repo> opencode-vectorcode-plugin
   cd opencode-vectorcode-plugin
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Build the plugin**:
   ```bash
   npm run build
   ```

4. **Link to OpenCode**:
   ```bash
   # Copy to OpenCode plugins directory
   cp -r . ~/.opencode/plugins/opencode-vectorcode-plugin
   
   # Or create a symbolic link
   ln -s $(pwd) ~/.opencode/plugins/opencode-vectorcode-plugin
   ```

### Method 2: Development Mode

1. **Install in development mode**:
   ```bash
   npm install
   npm run dev  # Watch mode for development
   ```

2. **Test compilation**:
   ```bash
   npm run build
   ls dist/  # Should contain index.js and index.d.ts
   ```

## 📖 Usage

### Command 1: Get VectorCode Context

Retrieves the current project context including available collections and prompts.

**OpenCode Command**:
```
/getVectorCodeContext
```

**Parameters** (optional):
- `projectRoot`: Specific project root path (defaults to current directory)

**Example Response**:
```json
{
  "success": true,
  "data": {
    "projectRoot": "/path/to/project",
    "prompts": "System prompts for code context...",
    "collections": ["collection1", "collection2"],
    "timestamp": "2025-01-05T10:00:00.000Z"
  },
  "command": "getVectorCodeContext"
}
```

### Command 2: Query VectorCode

Search through indexed code using semantic similarity.

**OpenCode Command**:
```
/queryVectorCode
```

**Parameters**:
- `query` (required): Search query string
- `number` (optional): Number of results (default: 10)
- `include` (optional): What to include in results ["path", "document", "chunk"]
- `exclude` (optional): Files to exclude from results
- `projectRoot` (optional): Project root path

**Example Usage**:
```json
{
  "query": "authentication middleware",
  "number": 5,
  "include": ["path", "document"],
  "exclude": ["test", "spec"]
}
```

**Example Response**:
```json
{
  "success": true,
  "data": {
    "query": "authentication middleware",
    "results": [
      {
        "path": "src/middleware/auth.ts",
        "document": "Authentication middleware implementation...",
        "similarity": 0.95
      }
    ],
    "options": {
      "number": 5,
      "include": ["path", "document"],
      "exclude": ["test", "spec"]
    },
    "projectRoot": "/path/to/project",
    "timestamp": "2025-01-05T10:00:00.000Z"
  },
  "command": "queryVectorCode"
}
```

### Command 3: Index VectorCode

Add files to the VectorCode database for searching.

**OpenCode Command**:
```
/indexVectorCode
```

**Parameters**:
- `filePaths` (required): Array of file paths to index
- `recursive` (optional): Recursively index directories (default: false)
- `includeHidden` (optional): Include hidden files (default: false)
- `force` (optional): Force indexing against gitignore (default: false)
- `projectRoot` (optional): Project root path

**Example Usage**:
```json
{
  "filePaths": ["src/", "docs/"],
  "recursive": true,
  "includeHidden": false,
  "force": false
}
```

**Example Response**:
```json
{
  "success": true,
  "data": {
    "indexedPaths": ["src/", "docs/"],
    "options": {
      "recursive": true,
      "includeHidden": false,
      "force": false
    },
    "projectRoot": "/path/to/project",
    "result": "Successfully indexed 42 files",
    "timestamp": "2025-01-05T10:00:00.000Z"
  },
  "command": "indexVectorCode"
}
```

## 🧪 Manual Testing

### Test Checklist

- [ ] **Plugin Compilation**
  ```bash
  npm run build
  # Should compile without errors
  ```

- [ ] **VectorCode CLI Availability**
  ```bash
  vectorcode --version
  # Should return version number
  ```

- [ ] **Basic Context Retrieval**
  ```
  /getVectorCodeContext
  # Should return project context
  ```

- [ ] **Query Functionality**
  ```
  /queryVectorCode {"query": "function", "number": 3}
  # Should return search results
  ```

- [ ] **Indexing Capability**
  ```
  /indexVectorCode {"filePaths": ["README.md"]}
  # Should index the file successfully
  ```

- [ ] **Error Handling**
  ```
  /queryVectorCode {"query": ""}
  # Should return error for empty query
  ```

### Manual Verification Steps

#### Step 1: Environment Setup
```bash
# 1. Verify all prerequisites
node --version          # Should be >=18.0.0
vectorcode --version    # Should be >=0.7.0
opencode --version      # Should be installed

# 2. Check plugin build
cd opencode-vectorcode-plugin
npm run build
ls dist/                # Should contain index.js, index.d.ts
```

#### Step 2: Plugin Integration Test
```bash
# 1. Copy plugin to OpenCode (adjust path as needed)
mkdir -p ~/.opencode/plugins
cp -r . ~/.opencode/plugins/opencode-vectorcode-plugin

# 2. Restart OpenCode to load the plugin
# 3. Test in OpenCode chat interface
```

#### Step 3: Functional Testing
```bash
# In OpenCode chat:

# Test 1: Get context
/getVectorCodeContext

# Test 2: Query with simple term
/queryVectorCode {"query": "function"}

# Test 3: Index a specific file
/indexVectorCode {"filePaths": ["package.json"]}

# Test 4: Query with options
/queryVectorCode {"query": "typescript", "number": 5, "include": ["path", "document"]}

# Test 5: Error handling
/queryVectorCode {"query": ""}
/indexVectorCode {"filePaths": []}
```

#### Step 4: Output Validation
- [ ] All successful commands return `"success": true`
- [ ] Error cases return `"success": false` with meaningful error messages
- [ ] JSON responses are properly formatted
- [ ] Timestamps are included in all responses
- [ ] Project root is correctly detected

## 🛠️ Development

### Project Structure
```
opencode-vectorcode-plugin/
├── src/
│   └── index.ts          # Main plugin implementation
├── dist/                 # Compiled output (generated)
├── package.json          # Dependencies and scripts
├── tsconfig.json         # TypeScript configuration
├── plugin.json           # OpenCode plugin metadata
├── types.d.ts           # Type definitions
└── README.md            # Documentation
```

### Development Commands
```bash
# Install dependencies
npm install

# Development mode (watch)
npm run dev

# Build for production
npm run build

# Clean build artifacts
npm run clean

# Run tests (manual only)
npm test
```

### Code Structure

The plugin follows OpenCode's hook-based architecture:

- **`tool.execute.after`**: Main hook for handling commands
- **Error Handling**: Comprehensive error catching and user-friendly messages
- **Type Safety**: Full TypeScript support with custom type definitions
- **CLI Integration**: Safe execution of VectorCode CLI with proper error handling

## ⚠️ Troubleshooting

### Common Issues

#### 1. "VectorCode CLI not found"
```bash
# Solution: Install VectorCode CLI
pip install vectorcode

# Verify installation
which vectorcode
vectorcode --version
```

#### 2. "Plugin not loading in OpenCode"
```bash
# Solutions:
# 1. Check plugin directory placement
ls ~/.opencode/plugins/opencode-vectorcode-plugin/

# 2. Verify plugin.json exists
cat ~/.opencode/plugins/opencode-vectorcode-plugin/plugin.json

# 3. Check compilation
cd ~/.opencode/plugins/opencode-vectorcode-plugin/
npm run build
```

#### 3. "Command execution fails"
```bash
# Solution: Check VectorCode project initialization
cd /path/to/your/project
vectorcode init
vectorcode ls
```

#### 4. "Permission denied errors"
```bash
# Solution: Check file permissions
chmod +x ~/.opencode/plugins/opencode-vectorcode-plugin/dist/index.js
```

### Debug Mode

Enable verbose logging by setting environment variable:
```bash
export OPENCODE_DEBUG=true
```

## 🔧 Customization

### Adding New Commands

1. **Add command definition** in `plugin.json`
2. **Implement handler** in `src/index.ts` tool.execute.after hook
3. **Add type definitions** in `types.d.ts`
4. **Update documentation** in README.md

### Modifying VectorCode CLI Options

Edit the command building logic in `src/index.ts`:

```typescript
// Example: Add new CLI option
const command = [
  'query',
  '--project_root', root,
  '--your-new-option', 'value',
  // ...
];
```

## 📝 Notes

### Important Considerations

1. **Cross-Platform Compatibility**: Plugin uses POSIX-compliant commands and paths
2. **Error Handling**: All CLI interactions are wrapped with try-catch blocks
3. **Security**: No shell injection vulnerabilities - uses parameterized commands
4. **Performance**: Commands use `--pipe` flag for structured output parsing
5. **Logging**: Includes timestamps and command tracking for debugging

### Future Enhancements

- [ ] Add caching for frequently accessed results
- [ ] Implement batch operations for multiple queries
- [ ] Add configuration file support
- [ ] Include progress reporting for large indexing operations
- [ ] Add integration with OpenCode's project management features

## 📄 License

MIT License - see LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly using the manual testing checklist
5. Submit a pull request

## 📞 Support

If you encounter issues:

1. Check the troubleshooting section
2. Verify all prerequisites are installed
3. Run the manual testing checklist
4. Enable debug mode for detailed logging
5. Open an issue with full error details and environment information
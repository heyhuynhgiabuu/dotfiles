# OpenCode LSP Configuration Optimization Patterns

## Valid LSP Configuration Properties
Based on official OpenCode documentation (https://opencode.ai/docs/lsp/):
- `disabled`: boolean - Set to true to disable the LSP server
- `command`: string[] - The command to start the LSP server
- `extensions`: string[] - File extensions this LSP server should handle
- `env`: object - Environment variables to set when starting server
- `initialization`: object - Initialization options to send to the LSP server

## Optimization Rules Applied

### 1. Remove Redundant Environment Variables
- **TypeScript `NODE_ENV`**: Removed because it's a standard Node.js environment variable that should be globally available
- **Rationale**: Global environment variables don't need to be duplicated in LSP configs

### 2. Keep Language-Specific Environment Variables
- **Go `GOPROXY` and `GOSUMDB`**: Kept because these are Go-specific proxy settings not globally configured
- **Rationale**: Language-specific settings that aren't globally available should remain in LSP config

### 3. Minimal Configuration Approach
- Empty objects `{}` for servers that work with defaults (like TypeScript)
- Only specify properties when needed to override defaults

## Example Clean Configuration
```json
{
  "lsp": {
    "typescript": {},
    "gopls": {
      "env": {
        "GOPROXY": "https://proxy.golang.org,direct",
        "GOSUMDB": "sum.golang.org"
      }
    },
    "ruby-lsp": {
      "disabled": true
    }
  }
}
```

## Validation Steps
1. Check JSON syntax validity
2. Verify against OpenCode schema
3. Test with OpenCode CLI configuration validation
4. Confirm environment variables are globally available where expected

## Root Cause Fixed
- **Issue**: LSP configuration contained redundant environment variables that were already globally available
- **Fix**: Removed unnecessary `NODE_ENV` for TypeScript while keeping Go-specific proxy settings
- **Benefit**: Cleaner, more maintainable configuration following DRY principles
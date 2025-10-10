# OpenCode Fix Tool

Batch code maintenance tool for common fixes across multiple files.

## Overview

The Fix Tool provides automated batch operations for common code maintenance tasks:

- **Import Organization**: Remove unused imports, sort alphabetically, group external/internal
- **Code Formatting**: Apply Prettier/ESLint formatting rules
- **Lint Fixes**: Auto-fix ESLint, TypeScript, and Python linting issues
- **Unused Code Removal**: Remove unused variables, functions, and imports
- **Deprecated API Migration**: Update deprecated APIs to modern alternatives

## Usage

```bash
# Basic usage - dry run by default
opencode fix --type imports
opencode fix --type formatting --files "src/**/*.ts"
opencode fix --type lint --no-dry-run

# Apply fixes with backup
opencode fix --type unused --no-dry-run --backup

# Multiple file patterns
opencode fix --type imports --files "src/**/*.ts" "lib/**/*.js"
```

## Fix Types

### `imports`

- Removes unused imports
- Sorts imports alphabetically
- Groups external vs internal imports
- Supports: JavaScript, TypeScript, JSX, TSX

### `formatting`

- Applies Prettier formatting (preferred)
- Falls back to ESLint --fix for formatting rules
- Supports: JavaScript, TypeScript, Python, Rust

### `lint`

- Applies ESLint auto-fixes
- Handles TypeScript compiler errors (limited)
- Applies Python auto-fixes (autopep8, black)
- Only processes auto-fixable issues

### `unused`

- Removes unused variables and functions
- Removes unused imports (overlaps with imports type)
- Uses static analysis for detection
- Conservative approach to avoid false positives

### `deprecated`

- Updates deprecated API usage
- Supports common patterns:
  - `new Buffer()` → `Buffer.from()`
  - `React.PropTypes` → `PropTypes` (requires manual import)
  - `fs.exists()` → `fs.access()`
  - jQuery patterns → vanilla JS
  - Python 2 → Python 3 patterns

## Safety Features

- **Dry Run Default**: Preview changes before applying
- **File Validation**: Checks file size, binary detection, permissions
- **Performance Limits**: Max 100 files, 30s timeout, 1000 changes
- **Backup Option**: Create `.bak` files before changes
- **Error Recovery**: Individual file failures don't stop batch operation
- **Conservative Detection**: Avoids false positives in unused code detection

## Examples

### Import Organization

```typescript
// Before
import { z } from "zod";
import { unused } from "module";
import { a } from "axios";
import { internal } from "./utils";

// After
import { a } from "axios";
import { z } from "zod";
import { internal } from "./utils";
```

### Deprecated API Updates

```javascript
// Before
const buffer = new Buffer('data');
$(document).ready(function() { ... });

// After
const buffer = Buffer.from('data');
document.addEventListener('DOMContentLoaded', function() { ... });
```

### Unused Code Removal

```typescript
// Before
const unused = "value";
const used = "other";
console.log(used);

// After
const used = "other";
console.log(used);
```

## Performance

- **File Limits**: 100 files max per operation
- **Time Limits**: 30 second timeout
- **Change Limits**: 1000 changes max per operation
- **Memory Efficient**: Processes files individually
- **Tool Integration**: Uses existing tools (Prettier, ESLint, etc.)

## Error Handling

- **Graceful Degradation**: Tool failures don't crash operation
- **Individual File Errors**: Logged but don't stop batch processing
- **Tool Detection**: Automatically detects available tools
- **Fallback Strategies**: Multiple approaches for each fix type

## Integration

Uses OpenCode's built-in tools internally:

- `grep`: Pattern matching and search
- `read`: File content access
- `edit`: Safe file modifications
- `bash`: External tool execution
- `glob`: File pattern matching

## Architecture

```
FixEngine (orchestrator)
├── ImportsFixer
├── FormattingFixer
├── LintFixer
├── UnusedFixer
└── DeprecatedFixer
```

Each fixer implements:

- `detect(files)`: Find issues
- `apply(issues, options)`: Apply fixes

## Workflow Efficiency

**Before Fix Tool:**

```bash
# Manual process (10-20 minutes)
eslint --fix src/**/*.ts
prettier --write src/**/*.ts
# Manual unused import removal
# Manual deprecated API updates
```

**With Fix Tool:**

```bash
# Automated process (30 seconds)
opencode fix --type imports --no-dry-run
opencode fix --type formatting --no-dry-run
opencode fix --type lint --no-dry-run
```

**Efficiency Gain**: 10-20x faster for common maintenance tasks

## Testing

The Fix Tool includes comprehensive test coverage:

### Unit Tests

```bash
cd opencode/tool/fix
node test-runner.js
```

Tests individual fixer components with mocked dependencies.

### Integration Tests

```bash
cd opencode/tool/fix
node integration-test.cjs
```

Tests complete workflows with real files and edge cases.

### Performance Tests

```bash
cd opencode/tool/fix
node performance-test.cjs
```

Benchmarks performance with large codebases and concurrent operations.

## Development

### Adding New Fix Types

1. Create new fixer class implementing `Fixer` interface:

```typescript
export class NewFixer implements Fixer {
  async detect(files: string[]): Promise<FixableIssue[]> {
    // Detection logic
  }

  async apply(
    issues: FixableIssue[],
    options: FixOptions,
  ): Promise<FixChange[]> {
    // Fix application logic
  }
}
```

2. Add to `FixEngine.getFixerForType()` method
3. Update tool schema and documentation
4. Add comprehensive tests

### Architecture Principles

- **Modular Design**: Each fixer is independent
- **Safety First**: Dry-run default, validation, error handling
- **Performance**: Efficient file processing, memory management
- **Tool Integration**: Leverage existing formatters and linters
- **Cross-platform**: Works on macOS, Linux, Windows

## Troubleshooting

### Common Issues

**Tool not found errors:**

- Install required tools: `npm install -g prettier eslint`
- Check PATH configuration
- Use fallback options when available

**Permission denied:**

- Check file permissions
- Run with appropriate user privileges
- Verify write access to target directories

**Large file timeouts:**

- Use `--files` to process specific files
- Break large operations into smaller batches
- Increase timeout limits if needed

**False positive unused detection:**

- Review changes in dry-run mode
- Use conservative detection settings
- Manual review for complex cases

### Debug Mode

Enable verbose logging:

```bash
DEBUG=fix opencode fix --type imports
```

### Performance Tuning

For large codebases:

- Process files in batches
- Use specific file patterns
- Enable concurrent processing
- Monitor memory usage

## Contributing

1. Follow existing code patterns
2. Add comprehensive tests
3. Update documentation
4. Ensure cross-platform compatibility
5. Performance test with large files

## License

Part of OpenCode project - see main project license.

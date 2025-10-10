# Quick Fix Applier Tool Specification

## Problem Statement

OpenCode has excellent individual file operations (`edit`, `multiedit`) but no intelligent batch fixing for common maintenance tasks.

**Current workflow is inefficient:**

1. `grep "import.*from"` → find import issues
2. `read file.ts` → analyze each file
3. `edit file.ts` → fix each file manually
4. Repeat for 10-50 files

**Result**: 30-60 minutes for tasks that should take 2-3 minutes.

## Solution

Single `fix` tool that applies common fixes across multiple files using existing OpenCode tools internally.

## Core Requirements

### Input Parameters

```typescript
interface FixParams {
  type: "imports" | "formatting" | "lint" | "unused" | "deprecated";
  files?: string[]; // Optional: specific files (default: auto-detect)
  dryRun?: boolean; // Optional: preview only (default: true)
  backup?: boolean; // Optional: create .bak files (default: false)
}
```

### Output Format

```typescript
interface FixResult {
  title: string; // "Import fixes applied to 12 files"
  metadata: {
    type: string; // Fix type applied
    filesProcessed: number; // Total files checked
    filesChanged: number; // Files actually modified
    changesApplied: number; // Total number of changes
    duration: number; // Execution time in ms
    dryRun: boolean; // Whether changes were applied
  };
  output: {
    summary: string; // Human-readable summary
    changes: FixChange[]; // Detailed change list
    errors: FixError[]; // Any errors encountered
  };
}

interface FixChange {
  file: string; // File path
  description: string; // What was changed
  lineNumber?: number; // Line number if applicable
  before?: string; // Original content
  after?: string; // New content
}
```

## Performance Constraints

### Hard Limits

- **Max files**: 100 files per operation
- **Max file size**: 10MB per file (skip larger files)
- **Execution timeout**: 30 seconds
- **Max changes**: 1000 changes per operation

### Default Excludes

```
node_modules/
.git/
dist/
build/
target/
*.min.js
*.bundle.js
*.map
```

## Fix Types Implementation

### 1. Import Fixes (`imports`)

**Purpose**: Organize, remove unused, sort imports

**Detection Strategy**:

```typescript
// Use existing grep tool
await grep({ pattern: "^import.*from", include: "*.{ts,tsx,js,jsx}" });
```

**Fix Operations**:

- Remove unused imports
- Sort imports alphabetically
- Group imports (external → internal → relative)
- Remove duplicate imports
- Fix import paths (relative vs absolute)

**Safety**: Only modify import statements, never touch code logic

### 2. Formatting Fixes (`formatting`)

**Purpose**: Apply consistent code style

**Detection Strategy**:

```typescript
// Use existing glob tool to find files
await glob({ pattern: "**/*.{ts,tsx,js,jsx,py,rs}" });
```

**Fix Operations**:

```typescript
// Use existing bash tool
await bash({ command: "prettier --write " + filePaths.join(" ") });
await bash({ command: "eslint --fix " + filePaths.join(" ") });
```

**Supported Formatters**:

- Prettier (JS/TS/CSS/HTML)
- ESLint --fix (JS/TS)
- Black (Python)
- rustfmt (Rust)

### 3. Lint Fixes (`lint`)

**Purpose**: Fix common linting issues automatically

**Detection Strategy**:

```typescript
// Use existing bash tool to run linter
await bash({ command: "eslint --format json " + filePaths.join(" ") });
```

**Fix Operations**:

- Missing semicolons
- Quote consistency
- Spacing issues
- Unused variables (safe removals only)
- Prefer const/let over var

**Safety**: Only apply auto-fixable rules, skip complex logic changes

### 4. Unused Code Removal (`unused`)

**Purpose**: Remove unused variables, functions, imports

**Detection Strategy**:

```typescript
// Use existing grep tool for declarations and usage
await grep({
  pattern: "^(const|let|var|function|class)\\s+(\\w+)",
  include: "*.{ts,js}",
});
await grep({ pattern: "\\b" + identifier + "\\b", include: "*.{ts,js}" });
```

**Fix Operations**:

- Remove unused imports
- Remove unused variables (if no side effects)
- Remove unused functions (if not exported)
- Remove unused type definitions

**Safety**: Conservative approach, skip if uncertain about usage

### 5. Deprecated API Updates (`deprecated`)

**Purpose**: Update deprecated API usage to modern equivalents

**Detection Strategy**:

```typescript
// Use existing grep tool for known deprecated patterns
await grep({ pattern: "deprecated_api_pattern", include: "*.{ts,js}" });
```

**Fix Operations**:

- React class components → functional components
- jQuery → vanilla JS
- Old Node.js APIs → modern equivalents
- Deprecated library methods

**Safety**: Only apply well-known, safe transformations

## Implementation Architecture

### Tool Integration

```typescript
import { Tool } from "./tool";
import { GrepTool } from "./grep";
import { ReadTool } from "./read";
import { EditTool } from "./edit";
import { BashTool } from "./bash";
import { GlobTool } from "./glob";

export const FixTool = Tool.define("fix", {
  description: "Apply common fixes across multiple files with batch operations",
  parameters: z.object({
    type: z.enum(["imports", "formatting", "lint", "unused", "deprecated"]),
    files: z.array(z.string()).optional(),
    dryRun: z.boolean().optional().default(true),
    backup: z.boolean().optional().default(false),
  }),

  async execute(params, ctx) {
    // Validate parameters
    if (!params.type) throw new Error("Fix type is required");

    // Get file list
    const files = await getTargetFiles(params.files, params.type);

    // Apply fixes based on type
    const fixer = getFixerForType(params.type);
    const result = await fixer.apply(files, params, ctx);

    return formatResult(result, params.type);
  },
});
```

### Modular Fix Architecture

```typescript
interface Fixer {
  detect(files: string[]): Promise<FixableIssue[]>;
  apply(issues: FixableIssue[], dryRun: boolean): Promise<FixResult[]>;
  validate(result: FixResult): Promise<boolean>;
}

class ImportsFixer implements Fixer {
  async detect(files: string[]) {
    // Use existing grep tool to find import issues
    const matches = await GrepTool.execute({
      pattern: "^import.*from",
      include: "*.{ts,tsx,js,jsx}",
    });
    return parseImportIssues(matches);
  }

  async apply(issues: FixableIssue[], dryRun: boolean) {
    // Use existing edit tool for changes
    const changes = [];
    for (const issue of issues) {
      if (!dryRun) {
        await EditTool.execute({
          filePath: issue.file,
          oldString: issue.before,
          newString: issue.after,
        });
      }
      changes.push(createChangeRecord(issue));
    }
    return changes;
  }
}
```

## Error Handling

### Failure Modes

- **File permission denied**: Skip file, continue with others
- **Syntax errors**: Skip file, report error
- **Tool not found**: Graceful fallback or clear error message
- **Timeout exceeded**: Return partial results with timeout warning
- **Invalid patterns**: Validate before processing

### Error Response Format

```typescript
interface FixError {
  type:
    | "permission"
    | "syntax"
    | "timeout"
    | "tool_missing"
    | "invalid_pattern";
  file?: string;
  message: string;
  suggestion?: string;
}
```

## Safety Measures

### Pre-flight Checks

1. **Syntax validation**: Skip files with syntax errors
2. **Git status check**: Warn about uncommitted changes
3. **File size limits**: Skip files > 10MB
4. **Binary file detection**: Skip binary files automatically

### Backup Strategy

```typescript
if (params.backup) {
  await bash({ command: `cp "${filePath}" "${filePath}.bak"` });
}
```

### Rollback Capability

```typescript
// Store original content for rollback
const originalContent = await read({ filePath });
// Apply changes...
// If validation fails, restore original
if (!isValid) {
  await write({ filePath, content: originalContent });
}
```

## Testing Strategy

### Unit Tests

- Each fixer module independently
- Mock OpenCode tool calls
- Test error conditions
- Validate output format

### Integration Tests

- Real file operations
- Cross-platform compatibility
- Performance under load
- Tool interaction patterns

### Safety Tests

- Backup/restore functionality
- Rollback on errors
- Dry-run accuracy
- Permission handling

## Usage Examples

### Import Organization

```bash
# Preview import fixes
fix --type imports --dryRun

# Apply import fixes to specific files
fix --type imports --files "src/**/*.ts" --backup

# Apply to all TypeScript files
fix --type imports
```

### Code Formatting

```bash
# Format all JavaScript files
fix --type formatting --files "**/*.js"

# Format with backup
fix --type formatting --backup
```

### Lint Fixes

```bash
# Fix all auto-fixable lint issues
fix --type lint

# Preview lint fixes only
fix --type lint --dryRun
```

## Success Criteria

1. **Performance**: 90% of operations complete under 10 seconds
2. **Safety**: Zero data loss with backup option enabled
3. **Accuracy**: 95% of fixes applied correctly without manual intervention
4. **Reliability**: Graceful handling of all error conditions
5. **Integration**: Seamless operation with existing OpenCode tools

## Non-Requirements

- **Complex refactoring**: No logic restructuring
- **Custom rules**: No user-defined fix patterns
- **IDE integration**: Command-line tool only
- **Real-time fixing**: Batch operations only
- **Multi-language AST**: Simple regex/text-based fixes only

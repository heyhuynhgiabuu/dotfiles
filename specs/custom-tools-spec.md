# OpenCode Custom Tools Specification

## Overview

Essential custom tools to fill genuine gaps in OpenCode's built-in capabilities, focusing on batch operations and higher-level abstractions.

## Analysis: OpenCode Built-in Coverage

**Existing Tools (Comprehensive):**

- File operations: `read`, `write`, `edit`, `multiedit`
- Search: `grep` (with ripgrep), `glob` (pattern matching)
- Execution: `bash`, `task` (agent delegation)
- LSP: `lsp-hover`, `lsp-diagnostics`
- Management: `todo`, `patch`, `webfetch`

**Identified Gaps:**

1. Batch fix operations across multiple files
2. Large file summarization for context management
3. Dependency analysis and management
4. Template/boilerplate generation

## Tool 1: Project Analyzer ✅ IMPLEMENTED

**Status**: Already implemented in `opencode/tool/analyze.ts`
**Value**: Comprehensive project analysis with security, performance, architecture insights
**Action**: Keep as-is, working well with analyze-enhancer plugin

## Tool 2: Quick Fix Applier

**File**: `opencode/tool/fix.ts`
**Name**: `fix`
**Priority**: HIGH - Addresses genuine gap in batch operations

### Purpose

Apply common fixes across multiple files with batch operations. OpenCode has `edit`/`multiedit` but no intelligent batch fixing.

### Gap Analysis

- **Current**: Manual `grep` → `read` → `edit` for each file
- **Needed**: Single command for common fix patterns across project
- **Value**: 10-20x faster for common maintenance tasks

### Arguments

```typescript
import { z } from "zod";

const fixArgsSchema = z.object({
  type: z.enum(["imports", "formatting", "lint", "unused", "deprecated"], {
    description: "Fix type to apply",
  }),
  files: z
    .array(z.string())
    .optional()
    .describe("Specific files (default: auto-detect)"),
  dryRun: z
    .boolean()
    .optional()
    .default(false)
    .describe("Preview changes without applying"),
  backup: z
    .boolean()
    .optional()
    .default(false)
    .describe("Create backup before changes"),
});

type FixArgs = z.infer<typeof fixArgsSchema>;
```

### Implementation Strategy

1. **Detection**: Use existing `grep` tool to find fixable patterns
2. **Validation**: Use existing `read` tool to verify context
3. **Application**: Use existing `edit`/`multiedit` tools for changes
4. **Verification**: Use existing `bash` tool for linters/formatters

### Fix Types

- **imports**: Organize, remove unused, add missing imports
- **formatting**: Apply consistent code style (prettier, eslint --fix)
- **lint**: Fix common linting issues automatically
- **unused**: Remove unused variables/imports/functions
- **deprecated**: Update deprecated API usage patterns

### OpenCode Integration

```typescript
// Uses existing tools internally
await grep({ pattern: "import.*from", include: "*.ts" });
await read({ filePath: matchedFile });
await edit({
  filePath: matchedFile,
  oldString: oldImport,
  newString: newImport,
});
await bash({ command: "eslint --fix " + filePath });
```

## Tool 3: Context Compressor

**File**: `opencode/tool/compress.ts`
**Name**: `compress`
**Priority**: MEDIUM-HIGH - Addresses token limit issues

### Purpose

Compress large files for context while preserving essential information. OpenCode's `read` tool hits token limits on large files.

### Gap Analysis

- **Current**: `read` tool returns full file content, often too large
- **Problem**: Token limits prevent analyzing large files (>2000 lines)
- **Needed**: Intelligent summarization preserving key information
- **Value**: Enable analysis of large codebases within token constraints

### Arguments

```typescript
import { z } from "zod";

const compressArgsSchema = z.object({
  file: z.string().describe("File path to compress"),
  strategy: z
    .enum(["functions", "classes", "exports", "smart"])
    .optional()
    .default("smart")
    .describe("Compression strategy"),
  maxLines: z
    .number()
    .int()
    .positive()
    .optional()
    .default(100)
    .describe("Maximum output lines"),
});

type CompressArgs = z.infer<typeof compressArgsSchema>;
```

### Implementation Strategy

1. **Content Analysis**: Use existing `read` tool to get full content
2. **Structure Extraction**: Parse for functions, classes, exports using regex/AST
3. **Importance Scoring**: Rank by exports, usage patterns, complexity
4. **Smart Compression**: Keep signatures, remove implementation details

### Compression Strategies

- **functions**: Extract function signatures, JSDoc, remove bodies
- **classes**: Extract class definitions, public methods, remove private implementation
- **exports**: Focus on exported interfaces, types, public APIs
- **smart**: Adaptive based on file extension and content patterns

### OpenCode Integration

```typescript
// Uses existing read tool
const content = await read({ filePath: file });
// Process and compress content
// Return compressed version following OpenCode output format
```

## Tool 4: Dependency Manager

**File**: `opencode/tool/deps.ts`
**Name**: `deps`
**Priority**: MEDIUM - Security and maintenance value

### Purpose

Analyze and manage project dependencies across different package managers.

### Gap Analysis

- **Current**: Manual `read package.json` → external tools for vulnerability checking
- **Needed**: Integrated dependency analysis, security scanning, update suggestions
- **Value**: Automated security and maintenance insights

### Arguments

```typescript
import { z } from "zod";

const depsArgsSchema = z.object({
  action: z
    .enum(["analyze", "outdated", "vulnerabilities", "update"])
    .describe("Action to perform"),
  packageManager: z
    .enum(["npm", "yarn", "pnpm", "pip", "cargo", "auto"])
    .optional()
    .default("auto")
    .describe("Package manager (auto-detect by default)"),
  severity: z
    .enum(["low", "moderate", "high", "critical"])
    .optional()
    .default("moderate")
    .describe("Minimum severity for vulnerabilities"),
});

type DepsArgs = z.infer<typeof depsArgsSchema>;
```

### Implementation Strategy

1. **Detection**: Use `glob` to find package files (package.json, requirements.txt, Cargo.toml)
2. **Analysis**: Use `bash` to run package manager commands (npm audit, pip check)
3. **Parsing**: Use `read` to parse dependency files and command outputs
4. **Reporting**: Structured output with actionable recommendations

## Implementation Guidelines

### OpenCode Integration Principles

1. **Leverage Existing Tools**: All custom tools use existing OpenCode built-ins internally
2. **Follow Tool Patterns**: Use `Tool.define()` with proper `{title, metadata, output}` format
3. **Zod Validation**: ALL tool arguments MUST use Zod schemas for type safety and runtime validation
4. **Respect Permissions**: Work within agent permission constraints
5. **Error Handling**: Graceful fallbacks, clear error messages, partial results with Zod error formatting

### Architecture

```typescript
import { Tool } from "@opencode-ai/sdk";
import { z } from "zod";

// Define Zod schema for arguments
const fixArgsSchema = z.object({
  type: z.enum(["imports", "formatting", "lint", "unused", "deprecated"]),
  files: z.array(z.string()).optional(),
  dryRun: z.boolean().optional().default(false),
  backup: z.boolean().optional().default(false),
});

// Custom tools are higher-level orchestrators
export const FixTool = Tool.define({
  name: "fix",
  description: "Apply common fixes across multiple files",
  args: fixArgsSchema,

  async execute(args) {
    // Zod validation happens automatically before execute()
    const { type, files, dryRun, backup } = args;

    try {
      // Use existing tools internally
      const matches = await GrepTool.execute({ pattern: "import.*" });
      const content = await ReadTool.execute({ filePath: matches[0].file });

      if (dryRun) {
        return { preview: true, changes: [...] };
      }

      const result = await EditTool.execute({
        filePath: matches[0].file,
        oldString,
        newString
      });

      return {
        title: `Fixed ${type} in ${matches.length} files`,
        metadata: { filesModified: matches.length, type },
        output: formatOutput(result),
      };
    } catch (error) {
      // Zod validation errors are caught before execute()
      // Handle tool execution errors here
      throw new Error(`Fix failed: ${error.message}`);
    }
  },
});
```

### Zod Validation Best Practices

```typescript
import { z } from "zod";

// 1. Use descriptive error messages
const schema = z.object({
  prompt: z
    .string()
    .min(10, "Prompt must be at least 10 characters")
    .max(1000, "Prompt too long (max 1000 characters)"),
});

// 2. Use refinements for complex validation
const imageKeysSchema = z
  .array(z.string())
  .min(1, "At least 1 image required")
  .max(3, "Maximum 3 images allowed")
  .refine(
    (keys) => keys.every((k) => k.startsWith("uploads/")),
    "Invalid image key format",
  );

// 3. Use transforms for data normalization
const aspectRatioSchema = z
  .enum(["1:1", "16:9", "9:16", "4:3", "3:4"])
  .default("1:1")
  .transform((val) => val.toLowerCase());

// 4. Handle validation errors gracefully
function handleValidationError(error: z.ZodError) {
  return {
    error: "Validation failed",
    details: error.errors.map((e) => ({
      field: e.path.join("."),
      message: e.message,
    })),
  };
}
```

### Performance

- Batch operations using existing `multiedit` tool
- Leverage existing caching in built-in tools
- Respect existing timeout and resource limits
- Zod validation adds <1ms overhead (negligible)

## Implementation Priority

1. **Quick Fix Applier** - Immediate impact, addresses common pain points
2. **Context Compressor** - Solves token limit issues for large files
3. **Dependency Manager** - Security and maintenance value

## Usage Examples

```bash
# Fix import issues across TypeScript files
fix --type imports --files "src/**/*.ts" --dryRun

# Compress large config file for analysis
compress webpack.config.js --strategy smart --maxLines 50

# Check for vulnerable dependencies
deps --action vulnerabilities --severity high
```

## Benefits

1. **Efficiency**: Reduce 5-10 step workflows to single commands
2. **Intelligence**: Higher-level abstractions over existing primitives
3. **Integration**: Built on existing OpenCode tool ecosystem
4. **Scalability**: Handle large codebases within existing constraints
5. **Maintenance**: Automated fixes and security insights

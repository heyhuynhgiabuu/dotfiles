# OpenCode Custom Tools Specification

## Overview

Essential custom tools to enhance OpenCode's built-in capabilities with higher-level abstractions and batch operations.

## Tool 1: Project Analyzer

**File**: `.opencode/tool/analyze.ts`
**Name**: `analyze`

### Purpose

Deep project structure analysis combining glob + grep + read for comprehensive overview.

### Arguments

```typescript
{
  depth: tool.schema.number().optional().describe("Analysis depth (1-3, default: 2)"),
  focus: tool.schema.enum(["structure", "dependencies", "patterns", "all"]).optional().describe("Analysis focus area"),
  exclude: tool.schema.array(tool.schema.string()).optional().describe("Patterns to exclude")
}
```

### Implementation Strategy

1. **Structure Analysis**: Use glob to map directory tree
2. **Dependency Analysis**: Parse package.json, imports, requires
3. **Pattern Analysis**: Use grep to identify common patterns
4. **Context Extraction**: Use read for key files (README, config)

### Output Format

```typescript
{
  structure: { directories: string[], files: number, depth: number },
  dependencies: { external: string[], internal: string[] },
  patterns: { frameworks: string[], languages: string[] },
  keyFiles: { path: string, purpose: string }[]
}
```

## Tool 2: Smart Code Search

**File**: `.opencode/tool/search.ts`
**Name**: `search`

### Purpose

Enhanced code search with context extraction and intelligent filtering.

### Arguments

```typescript
{
  pattern: tool.schema.string().describe("Search pattern (regex supported)"),
  context: tool.schema.number().optional().describe("Lines of context around matches (default: 3)"),
  fileTypes: tool.schema.array(tool.schema.string()).optional().describe("File extensions to search"),
  exclude: tool.schema.array(tool.schema.string()).optional().describe("Paths to exclude")
}
```

### Implementation Strategy

1. **Smart Filtering**: Use glob for file type filtering
2. **Pattern Matching**: Use grep with context lines
3. **Result Enhancement**: Use read to extract function/class context
4. **Relevance Ranking**: Score matches by context relevance

### Output Format

```typescript
{
  matches: {
    file: string,
    line: number,
    content: string,
    context: { before: string[], after: string[] },
    scope: string // function/class name if applicable
  }[],
  summary: { totalMatches: number, filesSearched: number }
}
```

## Tool 3: Quick Fix Applier

**File**: `.opencode/tool/fix.ts`
**Name**: `fix`

### Purpose

Apply common fixes across multiple files with batch operations.

### Arguments

```typescript
{
  type: tool.schema.enum(["imports", "formatting", "lint", "unused", "deprecated"]).describe("Fix type to apply"),
  files: tool.schema.array(tool.schema.string()).optional().describe("Specific files (default: auto-detect)"),
  dryRun: tool.schema.boolean().optional().describe("Preview changes without applying"),
  backup: tool.schema.boolean().optional().describe("Create backup before changes")
}
```

### Implementation Strategy

1. **Detection**: Use grep to find fixable patterns
2. **Validation**: Use read to verify context before changes
3. **Application**: Use edit for targeted fixes
4. **Verification**: Use bash to run formatters/linters

### Fix Types

- **imports**: Organize, remove unused, add missing
- **formatting**: Apply consistent code style
- **lint**: Fix common linting issues
- **unused**: Remove unused variables/imports
- **deprecated**: Update deprecated API usage

### Output Format

```typescript
{
  changes: {
    file: string,
    type: string,
    description: string,
    applied: boolean
  }[],
  summary: { filesChanged: number, errorsFixed: number }
}
```

## Tool 4: Context Compressor

**File**: `.opencode/tool/compress.ts`
**Name**: `compress`

### Purpose

Compress large files for context while preserving essential information.

### Arguments

```typescript
{
  file: tool.schema.string().describe("File path to compress"),
  strategy: tool.schema.enum(["functions", "classes", "exports", "smart"]).optional().describe("Compression strategy"),
  maxLines: tool.schema.number().optional().describe("Maximum output lines (default: 100)")
}
```

### Implementation Strategy

1. **Content Analysis**: Use read to get full file content
2. **Structure Extraction**: Parse for functions, classes, exports
3. **Importance Scoring**: Rank elements by usage/complexity
4. **Smart Compression**: Keep signatures, remove implementation details

### Compression Strategies

- **functions**: Extract function signatures and docstrings
- **classes**: Extract class definitions and public methods
- **exports**: Focus on exported interfaces and types
- **smart**: Adaptive based on file type and content

### Output Format

```typescript
{
  original: { lines: number, size: number },
  compressed: { lines: number, compressionRatio: number },
  content: string,
  preserved: string[] // List of preserved elements
}
```

## Implementation Guidelines

### Error Handling

- Graceful fallbacks for missing files/permissions
- Clear error messages with suggested fixes
- Partial results when possible

### Performance

- Batch operations where possible
- Cache results for repeated operations
- Limit resource usage with configurable timeouts

### Integration

- Work seamlessly with existing built-in tools
- Follow OpenCode's tool orchestration patterns
- Support agent routing and permissions

### Testing

- Unit tests for each tool function
- Integration tests with real project structures
- Performance benchmarks for large codebases

## Usage Examples

```bash
# Analyze project structure
@build analyze the project structure

# Search for authentication patterns
@build search for "auth" patterns with context

# Fix import issues across the project
@build fix import issues in TypeScript files

# Compress large config file for context
@build compress webpack.config.js for analysis
```

## Benefits

1. **Efficiency**: Reduce multi-step operations to single commands
2. **Intelligence**: Context-aware analysis and fixes
3. **Consistency**: Standardized approaches to common tasks
4. **Scalability**: Handle large codebases effectively
5. **Integration**: Seamless workflow with existing tools

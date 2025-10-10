# Context Compressor Tool Specification

## Overview

The Context Compressor is a critical tool for managing OpenCode's token limits when analyzing large files. It intelligently compresses file contents while preserving essential structural and semantic information for code analysis.

## Problem Statement

### Current Limitations

- OpenCode's `read` tool returns full file content, often exceeding token limits (>2000 lines)
- Large codebases become unanalyzable due to context window constraints
- Manual file chunking is time-consuming and loses structural context
- No intelligent summarization preserving key programming constructs

### Impact

- Cannot analyze large configuration files, generated code, or monolithic modules
- Reduced effectiveness on enterprise codebases
- Manual workarounds break development flow
- Context loss leads to incomplete analysis

## Solution: Context Compressor Tool

### Core Functionality

Intelligent file compression that preserves:

- Function and class signatures
- Export/import declarations
- Type definitions and interfaces
- Documentation comments
- Structural relationships
- Critical business logic markers

### Tool Definition

**Name**: `compress`
**Location**: `opencode/tool/compress.ts`
**Priority**: HIGH - Addresses fundamental context management gap

### Arguments Schema

```typescript
{
  file: tool.schema.string().describe("File path to compress"),
  strategy: tool.schema.enum([
    "functions",
    "classes",
    "exports",
    "smart",
    "structure"
  ]).optional().describe("Compression strategy (default: smart)"),
  maxLines: tool.schema.number().optional().describe("Maximum output lines (default: 100)"),
  preserveComments: tool.schema.boolean().optional().describe("Keep documentation comments (default: true)"),
  focus: tool.schema.string().optional().describe("Specific construct to focus on (function name, class, etc.)")
}
```

## Compression Strategies

### 1. Functions Strategy

- Extract function signatures with parameter types
- Preserve JSDoc/docstrings
- Keep first 2-3 lines of function bodies for context
- Remove implementation details
- Maintain import/export declarations

```typescript
// Original
function calculateTotal(items: Item[], tax: number): number {
  // Calculate subtotal
  const subtotal = items.reduce((sum, item) => {
    return sum + item.price * item.quantity;
  }, 0);

  // Apply tax
  const taxAmount = subtotal * tax;
  return subtotal + taxAmount;
}

// Compressed
function calculateTotal(items: Item[], tax: number): number {
  // Calculate subtotal and apply tax
  // ... implementation details removed
}
```

### 2. Classes Strategy

- Preserve class declarations and inheritance
- Keep public method signatures
- Remove private implementation
- Maintain constructor signatures
- Preserve property declarations

### 3. Exports Strategy

- Focus on module interface (exports/imports)
- Keep type definitions and interfaces
- Preserve public API signatures
- Remove internal implementation
- Maintain dependency structure

### 4. Smart Strategy (Default)

- Adaptive based on file extension and content analysis
- Automatic pattern recognition for different file types
- Context-aware importance scoring
- Balanced compression preserving most critical information

### 5. Structure Strategy

- Focus on architectural overview
- Class hierarchies and module relationships
- Interface definitions
- Minimal implementation details
- Dependency mapping

## Implementation Architecture

### Phase 1: Content Analysis

```typescript
const content = await ReadTool.execute({ filePath: file });
const fileType = detectFileType(file);
const patterns = getCompressionPatterns(fileType);
```

### Phase 2: Parsing and Extraction

```typescript
const ast = parseContent(content, fileType);
const constructs = extractConstructs(ast, strategy);
const scored = scoreImportance(constructs);
```

### Phase 3: Intelligent Compression

```typescript
const compressed = applyCompression(scored, maxLines);
const formatted = formatOutput(compressed, preserveComments);
```

### Phase 4: Output Generation

```typescript
return {
  title: `Compressed: ${file}`,
  metadata: {
    originalLines: content.split("\n").length,
    compressedLines: formatted.split("\n").length,
    compressionRatio: calculateRatio(content, formatted),
    strategy: strategy,
    constructs: extractedCount,
  },
  output: formatted,
};
```

## Language Support

### TypeScript/JavaScript

- Function declarations and arrow functions
- Class definitions and methods
- Interface and type declarations
- Import/export statements
- JSDoc comments

### Python

- Function and class definitions
- Docstrings and type hints
- Import statements
- Decorators and magic methods

### Go

- Function and method signatures
- Struct and interface definitions
- Package declarations
- Documentation comments

### Java

- Class and interface definitions
- Method signatures with annotations
- Package and import declarations
- Javadoc comments

### Rust

- Function and struct definitions
- Trait implementations
- Module declarations
- Documentation comments

## Integration with OpenCode Ecosystem

### Using Existing Tools

```typescript
// Leverages existing OpenCode tools
const content = await ReadTool.execute({ filePath });
const fileInfo = await BashTool.execute({ command: `file "${filePath}"` });
const dependencies = await GrepTool.execute({
  pattern: "import|require|use",
  files: [filePath],
});
```

### Error Handling

- Graceful fallback to line-based compression
- Partial results when parsing fails
- Clear error messages with suggestions
- Respect existing OpenCode error patterns

### Performance Considerations

- Maximum 30-second processing time
- Streaming for very large files
- Caching of parsed AST structures
- Memory-efficient compression algorithms

## Usage Examples

### Basic Compression

```bash
# Compress a large configuration file
compress webpack.config.js

# Focus on functions only
compress utils.ts --strategy functions --maxLines 50
```

### Advanced Usage

```bash
# Smart compression with comment preservation
compress src/api/users.ts --strategy smart --preserveComments true

# Focus on specific construct
compress models/User.ts --focus "UserModel" --maxLines 25
```

### Integration Patterns

```bash
# Analyze compressed file structure
compress large-module.js --strategy structure | analyze --mode architecture

# Check compressed exports
compress api.ts --strategy exports | grep "export"
```

## Output Format

### Metadata Structure

```json
{
  "title": "Compressed: src/utils/helpers.ts",
  "metadata": {
    "originalLines": 847,
    "compressedLines": 89,
    "compressionRatio": "10.5%",
    "strategy": "smart",
    "constructs": {
      "functions": 23,
      "classes": 4,
      "interfaces": 7,
      "exports": 15
    },
    "preservedElements": [
      "function signatures",
      "class declarations",
      "type definitions",
      "documentation"
    ]
  }
}
```

### Content Structure

```typescript
// === COMPRESSED: src/utils/helpers.ts ===
// Original: 847 lines -> Compressed: 89 lines (10.5%)
// Strategy: smart | Constructs: 49 total

// === IMPORTS ===
import { Config } from "./types";
import { Logger } from "./logger";

// === INTERFACES ===
interface HelperOptions {
  debug: boolean;
  timeout: number;
}

// === FUNCTIONS ===
export function formatDate(date: Date, format: string): string {
  // Formats date according to specified format string
  // ... implementation compressed
}

export class DataProcessor {
  constructor(options: HelperOptions) {
    /* ... */
  }

  process(data: unknown[]): ProcessedData[] {
    // Processes array of data with validation and transformation
    // ... implementation compressed
  }
}

// === EXPORTS ===
export { HelperOptions, DataProcessor };
export type { ProcessedData };
```

## Testing Strategy

### Unit Tests

- Compression accuracy for different file types
- Strategy selection logic
- Error handling edge cases
- Performance benchmarks

### Integration Tests

- OpenCode tool chain integration
- Real-world large file processing
- Cross-platform compatibility
- Memory usage validation

### Validation Metrics

- Information preservation score
- Compression ratio efficiency
- Processing time benchmarks
- Context usefulness rating

## Success Criteria

### Functional Requirements

- ✅ Compress files >2000 lines to <100 lines while preserving structure
- ✅ Support major programming languages (JS/TS, Python, Go, Java, Rust)
- ✅ Multiple compression strategies for different use cases
- ✅ Integration with existing OpenCode tool ecosystem

### Performance Requirements

- ✅ Process files up to 10MB within 30 seconds
- ✅ Memory usage under 256MB for compression operations
- ✅ 80%+ compression ratio with 90%+ information preservation

### Quality Requirements

- ✅ Graceful fallback for unsupported file types
- ✅ Clear error messages and partial results
- ✅ Consistent output format following OpenCode patterns

## Implementation Timeline

### Phase 1: Core Infrastructure (Week 1)

- Basic file parsing and AST generation
- JavaScript/TypeScript compression strategies
- OpenCode tool integration framework

### Phase 2: Strategy Implementation (Week 2)

- All compression strategies (functions, classes, exports, smart, structure)
- Multi-language support expansion
- Performance optimization

### Phase 3: Integration & Testing (Week 3)

- OpenCode ecosystem integration
- Comprehensive testing suite
- Documentation and examples

### Phase 4: Production Readiness (Week 4)

- Error handling refinement
- Performance benchmarking
- User feedback integration

## Risk Mitigation

### Technical Risks

- **AST Parsing Failures**: Fallback to regex-based extraction
- **Memory Constraints**: Streaming processing for large files
- **Language Support**: Graceful degradation to line-based compression

### Integration Risks

- **OpenCode Compatibility**: Extensive testing with existing tool chain
- **Performance Impact**: Caching and optimization strategies
- **User Experience**: Clear documentation and examples

## Future Enhancements

### Advanced Features

- Machine learning-based importance scoring
- Custom compression rules per project
- Integration with IDE/LSP for semantic analysis
- Collaborative compression strategies

### Ecosystem Integration

- Plugin system for custom compression strategies
- Integration with code analysis tools
- Export to documentation generators
- API for external tool integration

## Conclusion

The Context Compressor addresses a fundamental limitation in OpenCode's ability to analyze large files. By providing intelligent compression that preserves essential structural and semantic information, it enables comprehensive analysis of enterprise codebases while respecting token limitations.

This tool represents a critical infrastructure component that unlocks OpenCode's full potential for large-scale software engineering tasks.

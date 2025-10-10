# Quick Fix Applier Implementation Guide

## Technical Architecture

### Core Components

```typescript
// Main tool entry point
export const FixTool = Tool.define("fix", {
  description: "Apply common fixes across multiple files with batch operations",
  parameters: FixParams,
  execute: async (params, ctx) => await FixEngine.execute(params, ctx),
});

// Fix engine orchestrator
class FixEngine {
  static async execute(params: FixParams, ctx: Context): Promise<FixResult>;
}

// Individual fix implementations
interface Fixer {
  detect(files: string[]): Promise<FixableIssue[]>;
  apply(issues: FixableIssue[], options: FixOptions): Promise<FixChange[]>;
  validate(changes: FixChange[]): Promise<ValidationResult>;
}
```

### OpenCode Tool Integration

```typescript
import { GrepTool } from "./grep";
import { ReadTool } from "./read";
import { EditTool } from "./edit";
import { BashTool } from "./bash";
import { GlobTool } from "./glob";

class FixEngine {
  constructor(
    private grep = GrepTool,
    private read = ReadTool,
    private edit = EditTool,
    private bash = BashTool,
    private glob = GlobTool,
  ) {}

  async execute(params: FixParams, ctx: Context) {
    // Get target files
    const files = await this.getTargetFiles(params.files, params.type);

    // Get appropriate fixer
    const fixer = this.getFixerForType(params.type);

    // Detect issues
    const issues = await fixer.detect(files);

    // Apply fixes
    const changes = await fixer.apply(issues, {
      dryRun: params.dryRun,
      backup: params.backup,
    });

    // Format result
    return this.formatResult(changes, params.type, ctx);
  }
}
```

## Fix Type Implementations

### 1. Import Fixer

```typescript
class ImportsFixer implements Fixer {
  async detect(files: string[]): Promise<FixableIssue[]> {
    const issues: FixableIssue[] = [];

    for (const file of files) {
      // Use OpenCode grep tool to find imports
      const importMatches = await this.grep.execute({
        pattern: "^import.*from",
        path: file,
      });

      if (importMatches.metadata.matches === 0) continue;

      // Use OpenCode read tool to get full content
      const content = await this.read.execute({ filePath: file });

      // Analyze imports
      const imports = this.parseImports(content.output);
      const importIssues = this.analyzeImports(imports, file);

      issues.push(...importIssues);
    }

    return issues;
  }

  async apply(
    issues: FixableIssue[],
    options: FixOptions,
  ): Promise<FixChange[]> {
    const changes: FixChange[] = [];

    // Group issues by file for batch processing
    const issuesByFile = this.groupByFile(issues);

    for (const [file, fileIssues] of issuesByFile) {
      const fileChanges = await this.applyImportFixes(
        file,
        fileIssues,
        options,
      );
      changes.push(...fileChanges);
    }

    return changes;
  }

  private async applyImportFixes(
    file: string,
    issues: FixableIssue[],
    options: FixOptions,
  ): Promise<FixChange[]> {
    const changes: FixChange[] = [];

    // Read current content
    const content = await this.read.execute({ filePath: file });
    const lines = content.output.split("\n");

    // Process imports
    const { newImports, removedImports } = this.processImports(lines, issues);

    if (!options.dryRun) {
      // Create backup if requested
      if (options.backup) {
        await this.bash.execute({
          command: `cp "${file}" "${file}.bak"`,
          description: "Create backup file",
        });
      }

      // Apply changes using OpenCode edit tool
      const newContent = this.reconstructFile(lines, newImports);
      await this.edit.execute({
        filePath: file,
        oldString: content.output,
        newString: newContent,
      });
    }

    // Record changes
    changes.push({
      file,
      description: `Organized ${newImports.length} imports, removed ${removedImports.length} unused`,
      before: this.formatImports(this.extractImports(lines)),
      after: this.formatImports(newImports),
    });

    return changes;
  }

  private parseImports(content: string): ImportStatement[] {
    const importRegex =
      /^import\s+(?:(?:\{[^}]*\}|\*\s+as\s+\w+|\w+)(?:\s*,\s*(?:\{[^}]*\}|\*\s+as\s+\w+|\w+))*\s+from\s+)?['"]([^'"]+)['"];?$/gm;
    const imports: ImportStatement[] = [];
    let match;

    while ((match = importRegex.exec(content)) !== null) {
      imports.push({
        raw: match[0],
        source: match[1],
        lineNumber: content.substring(0, match.index).split("\n").length,
      });
    }

    return imports;
  }

  private analyzeImports(
    imports: ImportStatement[],
    file: string,
  ): FixableIssue[] {
    const issues: FixableIssue[] = [];

    // Check for unused imports
    for (const imp of imports) {
      if (this.isUnusedImport(imp, file)) {
        issues.push({
          type: "unused-import",
          file,
          lineNumber: imp.lineNumber,
          description: `Unused import: ${imp.source}`,
          fix: { action: "remove", target: imp.raw },
        });
      }
    }

    // Check for unsorted imports
    if (!this.areImportsSorted(imports)) {
      issues.push({
        type: "unsorted-imports",
        file,
        description: "Imports are not sorted",
        fix: { action: "sort", target: "all-imports" },
      });
    }

    return issues;
  }
}
```

### 2. Formatting Fixer

```typescript
class FormattingFixer implements Fixer {
  async detect(files: string[]): Promise<FixableIssue[]> {
    const issues: FixableIssue[] = [];

    // Use OpenCode bash tool to check formatting
    const prettierCheck = await this.bash.execute({
      command: `prettier --check ${files.join(" ")}`,
      description: "Check formatting with Prettier",
    });

    if (prettierCheck.metadata.exitCode !== 0) {
      // Parse prettier output to identify files needing formatting
      const needsFormatting = this.parsePrettierOutput(prettierCheck.output);

      for (const file of needsFormatting) {
        issues.push({
          type: "formatting",
          file,
          description: "File needs formatting",
          fix: { action: "format", tool: "prettier" },
        });
      }
    }

    return issues;
  }

  async apply(
    issues: FixableIssue[],
    options: FixOptions,
  ): Promise<FixChange[]> {
    const changes: FixChange[] = [];
    const filesToFormat = issues.map((issue) => issue.file);

    if (filesToFormat.length === 0) return changes;

    if (!options.dryRun) {
      // Create backups if requested
      if (options.backup) {
        for (const file of filesToFormat) {
          await this.bash.execute({
            command: `cp "${file}" "${file}.bak"`,
            description: "Create backup file",
          });
        }
      }

      // Apply formatting using OpenCode bash tool
      await this.bash.execute({
        command: `prettier --write ${filesToFormat.join(" ")}`,
        description: "Format files with Prettier",
      });

      // Also run ESLint --fix if available
      try {
        await this.bash.execute({
          command: `eslint --fix ${filesToFormat.join(" ")}`,
          description: "Fix ESLint issues",
        });
      } catch (error) {
        // ESLint not available or failed, continue
      }
    }

    // Record changes
    for (const file of filesToFormat) {
      changes.push({
        file,
        description: "Applied code formatting",
        lineNumber: undefined,
        before: undefined,
        after: undefined,
      });
    }

    return changes;
  }
}
```

### 3. Lint Fixer

```typescript
class LintFixer implements Fixer {
  async detect(files: string[]): Promise<FixableIssue[]> {
    const issues: FixableIssue[] = [];

    try {
      // Use OpenCode bash tool to run ESLint
      const eslintResult = await this.bash.execute({
        command: `eslint --format json ${files.join(" ")}`,
        description: "Run ESLint to detect issues",
      });

      const eslintOutput = JSON.parse(eslintResult.output);

      for (const fileResult of eslintOutput) {
        for (const message of fileResult.messages) {
          if (message.fix) {
            // Only auto-fixable issues
            issues.push({
              type: "lint",
              file: fileResult.filePath,
              lineNumber: message.line,
              description: message.message,
              fix: {
                action: "eslint-fix",
                ruleId: message.ruleId,
                fixable: true,
              },
            });
          }
        }
      }
    } catch (error) {
      // ESLint not available or failed
      console.warn("ESLint not available for lint fixing");
    }

    return issues;
  }

  async apply(
    issues: FixableIssue[],
    options: FixOptions,
  ): Promise<FixChange[]> {
    const changes: FixChange[] = [];
    const filesToFix = [...new Set(issues.map((issue) => issue.file))];

    if (filesToFix.length === 0) return changes;

    if (!options.dryRun) {
      // Create backups if requested
      if (options.backup) {
        for (const file of filesToFix) {
          await this.bash.execute({
            command: `cp "${file}" "${file}.bak"`,
            description: "Create backup file",
          });
        }
      }

      // Apply ESLint fixes using OpenCode bash tool
      await this.bash.execute({
        command: `eslint --fix ${filesToFix.join(" ")}`,
        description: "Apply ESLint auto-fixes",
      });
    }

    // Record changes
    const fixesByFile = this.groupFixesByFile(issues);
    for (const [file, fileIssues] of fixesByFile) {
      changes.push({
        file,
        description: `Fixed ${fileIssues.length} lint issues`,
        lineNumber: undefined,
        before: undefined,
        after: undefined,
      });
    }

    return changes;
  }
}
```

## Error Handling Implementation

### Graceful Degradation

```typescript
class FixEngine {
  async execute(params: FixParams, ctx: Context): Promise<FixResult> {
    const errors: FixError[] = [];
    const changes: FixChange[] = [];

    try {
      // Get target files with error handling
      const files = await this.getTargetFiles(params.files, params.type).catch(
        (error) => {
          errors.push({
            type: "file_discovery",
            message: `Failed to discover files: ${error.message}`,
            suggestion: "Check file patterns and permissions",
          });
          return [];
        },
      );

      if (files.length === 0) {
        return this.createEmptyResult(params.type, errors);
      }

      // Apply fixes with individual error handling
      for (const file of files) {
        try {
          const fileChanges = await this.applyFixesToFile(file, params);
          changes.push(...fileChanges);
        } catch (error) {
          errors.push({
            type: "file_processing",
            file,
            message: error.message,
            suggestion: "Check file permissions and syntax",
          });
        }
      }
    } catch (error) {
      errors.push({
        type: "general",
        message: `Fix operation failed: ${error.message}`,
        suggestion: "Check tool configuration and permissions",
      });
    }

    return this.formatResult(changes, errors, params.type);
  }

  private async applyFixesToFile(
    file: string,
    params: FixParams,
  ): Promise<FixChange[]> {
    // Pre-flight checks
    await this.validateFile(file);

    // Get fixer and apply
    const fixer = this.getFixerForType(params.type);
    const issues = await fixer.detect([file]);
    return await fixer.apply(issues, {
      dryRun: params.dryRun,
      backup: params.backup,
    });
  }

  private async validateFile(file: string): Promise<void> {
    // Check file exists and is readable
    const content = await this.read.execute({ filePath: file });

    // Check file size
    if (content.output.length > 10 * 1024 * 1024) {
      // 10MB
      throw new Error(`File too large: ${file}`);
    }

    // Check if binary file
    if (this.isBinaryFile(content.output)) {
      throw new Error(`Binary file not supported: ${file}`);
    }

    // Basic syntax check for supported languages
    if (file.endsWith(".js") || file.endsWith(".ts")) {
      try {
        // Simple syntax validation
        new Function(content.output);
      } catch (error) {
        throw new Error(`Syntax error in ${file}: ${error.message}`);
      }
    }
  }
}
```

### Performance Monitoring

```typescript
class PerformanceMonitor {
  private startTime: number;
  private fileCount: number = 0;
  private changeCount: number = 0;

  start() {
    this.startTime = Date.now();
  }

  recordFile() {
    this.fileCount++;

    // Check limits
    if (this.fileCount > 100) {
      throw new Error("File limit exceeded (max 100 files)");
    }

    if (Date.now() - this.startTime > 30000) {
      throw new Error("Timeout exceeded (max 30 seconds)");
    }
  }

  recordChange() {
    this.changeCount++;

    if (this.changeCount > 1000) {
      throw new Error("Change limit exceeded (max 1000 changes)");
    }
  }

  getMetrics() {
    return {
      duration: Date.now() - this.startTime,
      filesProcessed: this.fileCount,
      changesApplied: this.changeCount,
    };
  }
}
```

## Testing Strategy

### Unit Tests

```typescript
describe("ImportsFixer", () => {
  let fixer: ImportsFixer;
  let mockGrep: jest.MockedFunction<typeof GrepTool.execute>;
  let mockRead: jest.MockedFunction<typeof ReadTool.execute>;
  let mockEdit: jest.MockedFunction<typeof EditTool.execute>;

  beforeEach(() => {
    fixer = new ImportsFixer(mockGrep, mockRead, mockEdit);
  });

  test("detects unused imports", async () => {
    mockGrep.mockResolvedValue({
      title: "import search",
      metadata: { matches: 2 },
      output:
        'file.ts:1:import { unused } from "lib"\nfile.ts:2:import { used } from "lib2"',
    });

    mockRead.mockResolvedValue({
      title: "file.ts",
      metadata: {},
      output:
        'import { unused } from "lib"\nimport { used } from "lib2"\nconsole.log(used)',
    });

    const issues = await fixer.detect(["file.ts"]);

    expect(issues).toHaveLength(1);
    expect(issues[0].type).toBe("unused-import");
    expect(issues[0].description).toContain("unused");
  });

  test("applies import fixes in dry-run mode", async () => {
    const issues = [
      {
        type: "unused-import",
        file: "file.ts",
        lineNumber: 1,
        description: "Unused import",
        fix: { action: "remove", target: 'import { unused } from "lib"' },
      },
    ];

    const changes = await fixer.apply(issues, { dryRun: true, backup: false });

    expect(changes).toHaveLength(1);
    expect(changes[0].file).toBe("file.ts");
    expect(mockEdit).not.toHaveBeenCalled(); // Dry run, no actual changes
  });
});
```

### Integration Tests

```typescript
describe("FixTool Integration", () => {
  test("fixes imports in real TypeScript files", async () => {
    // Create test files
    const testFile = "/tmp/test.ts";
    await fs.writeFile(
      testFile,
      `
      import { unused } from 'lib1'
      import { used } from 'lib2'
      
      console.log(used)
    `,
    );

    // Run fix tool
    const result = await FixTool.execute({
      type: "imports",
      files: [testFile],
      dryRun: false,
      backup: true,
    });

    // Verify results
    expect(result.metadata.filesChanged).toBe(1);
    expect(result.metadata.changesApplied).toBe(1);

    // Verify backup was created
    expect(await fs.exists(testFile + ".bak")).toBe(true);

    // Verify fix was applied
    const fixedContent = await fs.readFile(testFile, "utf8");
    expect(fixedContent).not.toContain("unused");
    expect(fixedContent).toContain("used");

    // Cleanup
    await fs.unlink(testFile);
    await fs.unlink(testFile + ".bak");
  });
});
```

## Deployment Checklist

### Pre-deployment Validation

- [ ] All unit tests pass
- [ ] Integration tests pass on sample projects
- [ ] Performance tests within limits (100 files, 30 seconds)
- [ ] Error handling covers all failure modes
- [ ] Backup/restore functionality works
- [ ] Dry-run mode accurate
- [ ] Cross-platform compatibility (macOS, Linux)
- [ ] OpenCode tool integration verified
- [ ] Memory usage within bounds
- [ ] No data loss in any test scenario

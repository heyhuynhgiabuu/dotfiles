import { Fixer, FixableIssue, FixOptions, FixChange } from "./types";

export class UnusedFixer implements Fixer {
  constructor(
    private grep: any,
    private read: any,
    private edit: any,
  ) {}

  async detect(files: string[]): Promise<FixableIssue[]> {
    const issues: FixableIssue[] = [];

    for (const file of files) {
      try {
        // Read file content
        const content = await this.read.execute({ filePath: file });
        const fileContent = content.output;

        // Detect unused variables, functions, and imports
        const unusedItems = await this.findUnusedItems(file, fileContent);

        for (const item of unusedItems) {
          issues.push({
            type: "unused",
            file,
            lineNumber: item.lineNumber,
            description: `Unused ${item.type}: ${item.name}`,
            fix: {
              action: "remove",
              target: item.declaration,
              fixable: item.safeToRemove,
            },
          });
        }
      } catch (error) {
        // Skip files that can't be processed
        continue;
      }
    }

    return issues;
  }

  async apply(
    issues: FixableIssue[],
    options: FixOptions,
  ): Promise<FixChange[]> {
    const changes: FixChange[] = [];

    // Group issues by file
    const issuesByFile = this.groupByFile(issues);

    for (const [file, fileIssues] of issuesByFile) {
      try {
        const fileChanges = await this.applyUnusedFixes(
          file,
          fileIssues,
          options,
        );
        changes.push(...fileChanges);
      } catch (error) {
        // Skip files that can't be fixed
        continue;
      }
    }

    return changes;
  }

  private async findUnusedItems(
    file: string,
    content: string,
  ): Promise<UnusedItem[]> {
    const unusedItems: UnusedItem[] = [];
    const lines = content.split("\n");

    // Find variable declarations
    const variables = this.findVariableDeclarations(lines);
    for (const variable of variables) {
      if (!this.isVariableUsed(variable, content)) {
        unusedItems.push({
          type: "variable",
          name: variable.name,
          lineNumber: variable.lineNumber,
          declaration: variable.declaration,
          safeToRemove: this.isSafeToRemoveVariable(variable, content),
        });
      }
    }

    // Find function declarations
    const functions = this.findFunctionDeclarations(lines);
    for (const func of functions) {
      if (
        !this.isFunctionUsed(func, content) &&
        !this.isExported(func, content)
      ) {
        unusedItems.push({
          type: "function",
          name: func.name,
          lineNumber: func.lineNumber,
          declaration: func.declaration,
          safeToRemove: true, // Functions are generally safe to remove if unused
        });
      }
    }

    // Find unused imports (already handled by ImportsFixer, but include for completeness)
    const imports = this.findImportDeclarations(lines);
    for (const imp of imports) {
      if (!this.isImportUsed(imp, content)) {
        unusedItems.push({
          type: "import",
          name: imp.name,
          lineNumber: imp.lineNumber,
          declaration: imp.declaration,
          safeToRemove: true,
        });
      }
    }

    return unusedItems;
  }

  private findVariableDeclarations(lines: string[]): VariableDeclaration[] {
    const variables: VariableDeclaration[] = [];

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i].trim();

      // Match variable declarations
      const patterns = [
        /^(const|let|var)\s+(\w+)\s*[=:]/, // const x = ..., let x = ..., var x = ...
        /^(const|let|var)\s+\{([^}]+)\}\s*=/, // const { x, y } = ...
        /^(const|let|var)\s+\[([^\]]+)\]\s*=/, // const [x, y] = ...
      ];

      for (const pattern of patterns) {
        const match = line.match(pattern);
        if (match) {
          const names = this.extractVariableNames(match[2]);

          for (const name of names) {
            variables.push({
              name,
              lineNumber: i + 1,
              declaration: line,
              type: match[1] as "const" | "let" | "var",
            });
          }
          break;
        }
      }
    }

    return variables;
  }

  private findFunctionDeclarations(lines: string[]): FunctionDeclaration[] {
    const functions: FunctionDeclaration[] = [];

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i].trim();

      // Match function declarations
      const patterns = [
        /^(export\s+)?(async\s+)?function\s+(\w+)/, // function name() {}
        /^(export\s+)?const\s+(\w+)\s*=\s*(async\s+)?\(/, // const name = () => {}
        /^(export\s+)?const\s+(\w+)\s*=\s*(async\s+)?function/, // const name = function() {}
      ];

      for (const pattern of patterns) {
        const match = line.match(pattern);
        if (match) {
          const name = match[3] || match[2]; // Different capture groups for different patterns
          if (name) {
            functions.push({
              name,
              lineNumber: i + 1,
              declaration: line,
              isExported: !!match[1],
              isAsync: !!(match[2] || match[3]),
            });
          }
          break;
        }
      }
    }

    return functions;
  }

  private findImportDeclarations(lines: string[]): ImportDeclaration[] {
    const imports: ImportDeclaration[] = [];

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i].trim();

      // Match import declarations
      const importMatch = line.match(
        /^import\s+(.+)\s+from\s+['"]([^'"]+)['"]/,
      );
      if (importMatch) {
        const importClause = importMatch[1];
        const names = this.extractImportNames(importClause);

        for (const name of names) {
          imports.push({
            name,
            lineNumber: i + 1,
            declaration: line,
            source: importMatch[2],
          });
        }
      }
    }

    return imports;
  }

  private extractVariableNames(nameClause: string): string[] {
    // Handle destructuring: { a, b: c, d } -> [a, c, d]
    if (nameClause.includes(",")) {
      return nameClause
        .split(",")
        .map((part) => {
          const trimmed = part.trim();
          // Handle renaming: b: c -> c
          const colonIndex = trimmed.indexOf(":");
          return colonIndex > -1
            ? trimmed.substring(colonIndex + 1).trim()
            : trimmed;
        })
        .filter((name) => name && /^\w+$/.test(name));
    }

    return [nameClause.trim()];
  }

  private extractImportNames(importClause: string): string[] {
    const names: string[] = [];

    // Default import: React
    if (!importClause.includes("{") && !importClause.includes("*")) {
      names.push(importClause.trim());
    }

    // Named imports: { useState, useEffect }
    const namedMatch = importClause.match(/\{([^}]+)\}/);
    if (namedMatch) {
      const namedImports = namedMatch[1].split(",").map((s) => {
        const trimmed = s.trim();
        // Handle aliasing: useState as state -> state
        const asIndex = trimmed.indexOf(" as ");
        return asIndex > -1 ? trimmed.substring(asIndex + 4).trim() : trimmed;
      });
      names.push(...namedImports);
    }

    // Namespace import: * as React
    const namespaceMatch = importClause.match(/\*\s+as\s+(\w+)/);
    if (namespaceMatch) {
      names.push(namespaceMatch[1]);
    }

    return names.filter((name) => name && /^\w+$/.test(name));
  }

  private isVariableUsed(
    variable: VariableDeclaration,
    content: string,
  ): boolean {
    // Simple usage check - look for variable name as word boundary
    const usageRegex = new RegExp(`\\b${variable.name}\\b`, "g");
    const matches = content.match(usageRegex) || [];

    // If found more than once (declaration + usage), it's used
    return matches.length > 1;
  }

  private isFunctionUsed(func: FunctionDeclaration, content: string): boolean {
    // Check for function calls
    const callRegex = new RegExp(`\\b${func.name}\\s*\\(`, "g");
    const matches = content.match(callRegex) || [];

    return matches.length > 0;
  }

  private isImportUsed(imp: ImportDeclaration, content: string): boolean {
    const usageRegex = new RegExp(`\\b${imp.name}\\b`, "g");
    const matches = content.match(usageRegex) || [];

    // If found more than once (import + usage), it's used
    return matches.length > 1;
  }

  private isExported(func: FunctionDeclaration, content: string): boolean {
    // Check if function is exported
    if (func.isExported) return true;

    // Check for export statements
    const exportRegex = new RegExp(`export\\s+.*\\b${func.name}\\b`);
    return exportRegex.test(content);
  }

  private isSafeToRemoveVariable(
    variable: VariableDeclaration,
    content: string,
  ): boolean {
    // Conservative approach - only remove if:
    // 1. It's a const/let (not var, which has function scope)
    // 2. It doesn't have side effects in its initialization

    if (variable.type === "var") return false;

    // Check for side effects in declaration
    const sideEffectPatterns = [
      /\.\w+\s*\(/, // Method calls: obj.method()
      /new\s+\w+/, // Constructor calls: new Class()
      /require\s*\(/, // Require calls: require()
      /import\s*\(/, // Dynamic imports: import()
    ];

    for (const pattern of sideEffectPatterns) {
      if (pattern.test(variable.declaration)) {
        return false;
      }
    }

    return true;
  }

  private groupByFile(issues: FixableIssue[]): Map<string, FixableIssue[]> {
    const grouped = new Map<string, FixableIssue[]>();

    for (const issue of issues) {
      if (!grouped.has(issue.file)) {
        grouped.set(issue.file, []);
      }
      grouped.get(issue.file)!.push(issue);
    }

    return grouped;
  }

  private async applyUnusedFixes(
    file: string,
    issues: FixableIssue[],
    options: FixOptions,
  ): Promise<FixChange[]> {
    const changes: FixChange[] = [];

    // Only process safe-to-remove items
    const safeIssues = issues.filter((issue) => issue.fix.fixable);

    if (safeIssues.length === 0) return changes;

    if (!options.dryRun) {
      // Create backup if requested
      if (options.backup) {
        try {
          // Note: In real implementation, this would use the bash tool
          // await this.bash.execute({ command: `cp "${file}" "${file}.bak"` })
        } catch (error) {
          // Skip backup if failed
        }
      }

      // Read current content
      const content = await this.read.execute({ filePath: file });
      let modifiedContent = content.output;

      // Remove unused items (in reverse line order to maintain line numbers)
      const sortedIssues = safeIssues.sort(
        (a, b) => (b.lineNumber || 0) - (a.lineNumber || 0),
      );

      for (const issue of sortedIssues) {
        if (issue.lineNumber) {
          const lines = modifiedContent.split("\n");
          lines.splice(issue.lineNumber - 1, 1); // Remove the line
          modifiedContent = lines.join("\n");
        }
      }

      // Apply changes
      await this.edit.execute({
        filePath: file,
        oldString: content.output,
        newString: modifiedContent,
      });
    }

    // Record changes
    const removedCount = safeIssues.length;
    changes.push({
      file,
      description: `Removed ${removedCount} unused items`,
      before: `${removedCount} unused declarations`,
      after: "Cleaned up unused code",
    });

    return changes;
  }
}

interface UnusedItem {
  type: "variable" | "function" | "import";
  name: string;
  lineNumber: number;
  declaration: string;
  safeToRemove: boolean;
}

interface VariableDeclaration {
  name: string;
  lineNumber: number;
  declaration: string;
  type: "const" | "let" | "var";
}

interface FunctionDeclaration {
  name: string;
  lineNumber: number;
  declaration: string;
  isExported: boolean;
  isAsync: boolean;
}

interface ImportDeclaration {
  name: string;
  lineNumber: number;
  declaration: string;
  source: string;
}

import { Fixer, FixableIssue, FixOptions, FixChange } from "./types";

interface ImportStatement {
  raw: string;
  source: string;
  imports: string;
  lineNumber: number;
  isDefault: boolean;
  isNamespace: boolean;
  isSideEffect: boolean;
}

export class ImportsFixer implements Fixer {
  constructor(
    private grep: any,
    private read: any,
    private edit: any,
    private bash: any,
  ) {}

  async detect(files: string[]): Promise<FixableIssue[]> {
    const issues: FixableIssue[] = [];

    for (const file of files) {
      try {
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
        const importIssues = await this.analyzeImports(
          imports,
          file,
          content.output,
        );

        issues.push(...importIssues);
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

    // Group issues by file for batch processing
    const issuesByFile = this.groupByFile(issues);

    for (const [file, fileIssues] of issuesByFile) {
      try {
        const fileChanges = await this.applyImportFixes(
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

  private parseImports(content: string): ImportStatement[] {
    const lines = content.split("\n");
    const imports: ImportStatement[] = [];

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i].trim();

      // Match various import patterns
      const importPatterns = [
        /^import\s+(.+)\s+from\s+['"]([^'"]+)['"];?$/, // import { x } from 'module'
        /^import\s+['"]([^'"]+)['"];?$/, // import 'module'
        /^import\s+(\w+)\s+from\s+['"]([^'"]+)['"];?$/, // import React from 'react'
        /^import\s+\*\s+as\s+(\w+)\s+from\s+['"]([^'"]+)['"];?$/, // import * as x from 'module'
      ];

      for (const pattern of importPatterns) {
        const match = line.match(pattern);
        if (match) {
          imports.push({
            raw: line,
            source: match[2] || match[1], // Handle side-effect imports
            imports: match[1] || "",
            lineNumber: i + 1,
            isDefault: !line.includes("{") && !line.includes("*"),
            isNamespace: line.includes("* as"),
            isSideEffect: !match[2], // Side-effect import has no 'from'
          });
          break;
        }
      }
    }

    return imports;
  }

  private async analyzeImports(
    imports: ImportStatement[],
    file: string,
    content: string,
  ): Promise<FixableIssue[]> {
    const issues: FixableIssue[] = [];

    // Check for unused imports
    for (const imp of imports) {
      if (imp.isSideEffect) continue; // Skip side-effect imports

      const isUsed = await this.isImportUsed(imp, content);
      if (!isUsed) {
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

    // Check for ungrouped imports (external vs internal)
    if (!this.areImportsGrouped(imports)) {
      issues.push({
        type: "ungrouped-imports",
        file,
        description: "Imports are not grouped (external vs internal)",
        fix: { action: "group", target: "all-imports" },
      });
    }

    return issues;
  }

  private async isImportUsed(
    imp: ImportStatement,
    content: string,
  ): Promise<boolean> {
    if (imp.isSideEffect) return true; // Side-effect imports are always "used"

    // Extract imported identifiers
    const identifiers = this.extractImportedIdentifiers(imp);

    // Check if any identifier is used in the content
    for (const identifier of identifiers) {
      // Simple usage check - look for identifier as word boundary
      const usageRegex = new RegExp(`\\b${identifier}\\b`, "g");
      const matches = content.match(usageRegex) || [];

      // If found more than once (import + usage), it's used
      if (matches.length > 1) {
        return true;
      }
    }

    return false;
  }

  private extractImportedIdentifiers(imp: ImportStatement): string[] {
    const identifiers: string[] = [];

    if (imp.isNamespace) {
      // import * as React from 'react' -> ['React']
      const match = imp.imports.match(/\*\s+as\s+(\w+)/);
      if (match) identifiers.push(match[1]);
    } else if (imp.isDefault) {
      // import React from 'react' -> ['React']
      const match = imp.imports.match(/^\s*(\w+)/);
      if (match) identifiers.push(match[1]);
    } else {
      // import { useState, useEffect } from 'react' -> ['useState', 'useEffect']
      const match = imp.imports.match(/\{([^}]+)\}/);
      if (match) {
        const namedImports = match[1]
          .split(",")
          .map((s) => s.trim().split(" as ")[0].trim());
        identifiers.push(...namedImports);
      }
    }

    return identifiers;
  }

  private areImportsSorted(imports: ImportStatement[]): boolean {
    const sources = imports.map((imp) => imp.source).filter(Boolean);
    const sortedSources = [...sources].sort();
    return JSON.stringify(sources) === JSON.stringify(sortedSources);
  }

  private areImportsGrouped(imports: ImportStatement[]): boolean {
    let foundInternal = false;

    for (const imp of imports) {
      const isExternal = this.isExternalImport(imp.source);

      if (!isExternal) {
        foundInternal = true;
      } else if (foundInternal) {
        // Found external import after internal - not grouped
        return false;
      }
    }

    return true;
  }

  private isExternalImport(source: string): boolean {
    // External imports don't start with '.', '/', or '@/' (common internal alias)
    return (
      !source.startsWith(".") &&
      !source.startsWith("/") &&
      !source.startsWith("@/")
    );
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

  private async applyImportFixes(
    file: string,
    issues: FixableIssue[],
    options: FixOptions,
  ): Promise<FixChange[]> {
    const changes: FixChange[] = [];

    // Read current content
    const content = await this.read.execute({ filePath: file });
    const lines = content.output.split("\n");

    // Parse current imports
    const imports = this.parseImports(content.output);

    // Apply fixes
    const { newImports, removedCount } = this.processImports(imports, issues);

    if (!options.dryRun) {
      // Create backup if requested
      if (options.backup) {
        await this.bash.execute({
          command: `cp "${file}" "${file}.bak"`,
          description: "Create backup file",
        });
      }

      // Apply changes using OpenCode edit tool
      const newContent = this.reconstructFile(lines, imports, newImports);
      await this.edit.execute({
        filePath: file,
        oldString: content.output,
        newString: newContent,
      });
    }

    // Record changes
    const changeDescription = this.createChangeDescription(
      issues,
      removedCount,
    );
    changes.push({
      file,
      description: changeDescription,
      before: this.formatImports(imports),
      after: this.formatImports(newImports),
    });

    return changes;
  }

  private processImports(
    imports: ImportStatement[],
    issues: FixableIssue[],
  ): { newImports: ImportStatement[]; removedCount: number } {
    let processedImports = [...imports];
    let removedCount = 0;

    // Remove unused imports
    const unusedIssues = issues.filter((i) => i.type === "unused-import");
    for (const issue of unusedIssues) {
      processedImports = processedImports.filter(
        (imp) => imp.lineNumber !== issue.lineNumber,
      );
      removedCount++;
    }

    // Sort and group imports
    const shouldSort = issues.some((i) => i.type === "unsorted-imports");
    const shouldGroup = issues.some((i) => i.type === "ungrouped-imports");

    if (shouldSort || shouldGroup) {
      processedImports = this.sortAndGroupImports(processedImports);
    }

    return { newImports: processedImports, removedCount };
  }

  private sortAndGroupImports(imports: ImportStatement[]): ImportStatement[] {
    // Separate external and internal imports
    const external = imports.filter((imp) => this.isExternalImport(imp.source));
    const internal = imports.filter(
      (imp) => !this.isExternalImport(imp.source),
    );

    // Sort each group
    external.sort((a, b) => a.source.localeCompare(b.source));
    internal.sort((a, b) => a.source.localeCompare(b.source));

    // Combine: external first, then internal
    return [...external, ...internal];
  }

  private reconstructFile(
    originalLines: string[],
    originalImports: ImportStatement[],
    newImports: ImportStatement[],
  ): string {
    const lines = [...originalLines];

    // Find import section boundaries
    const importLines = originalImports.map((imp) => imp.lineNumber - 1); // Convert to 0-based
    const firstImportLine = Math.min(...importLines);
    const lastImportLine = Math.max(...importLines);

    // Remove old import lines
    for (let i = lastImportLine; i >= firstImportLine; i--) {
      lines.splice(i, 1);
    }

    // Insert new imports
    const newImportLines = newImports.map((imp) => imp.raw);
    lines.splice(firstImportLine, 0, ...newImportLines);

    return lines.join("\n");
  }

  private createChangeDescription(
    issues: FixableIssue[],
    removedCount: number,
  ): string {
    const descriptions: string[] = [];

    if (removedCount > 0) {
      descriptions.push(`Removed ${removedCount} unused imports`);
    }

    if (issues.some((i) => i.type === "unsorted-imports")) {
      descriptions.push("Sorted imports alphabetically");
    }

    if (issues.some((i) => i.type === "ungrouped-imports")) {
      descriptions.push("Grouped external and internal imports");
    }

    return descriptions.join(", ") || "Organized imports";
  }

  private formatImports(imports: ImportStatement[]): string {
    return imports.map((imp) => imp.raw).join("\n");
  }
}

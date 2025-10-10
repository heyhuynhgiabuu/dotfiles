import { Fixer, FixableIssue, FixOptions, FixChange } from "./types";

export class LintFixer implements Fixer {
  constructor(private bash: any) {}

  async detect(files: string[]): Promise<FixableIssue[]> {
    const issues: FixableIssue[] = [];

    try {
      // Use OpenCode bash tool to run ESLint
      const eslintResult = await this.bash.execute({
        command: `eslint --format json ${files.join(" ")}`,
        description: "Run ESLint to detect issues",
      });

      const eslintOutput = JSON.parse(eslintResult.output || "[]");

      for (const fileResult of eslintOutput) {
        for (const message of fileResult.messages || []) {
          if (message.fix) {
            // Only auto-fixable issues
            issues.push({
              type: "lint",
              file: fileResult.filePath,
              lineNumber: message.line,
              description: `${message.ruleId}: ${message.message}`,
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
      // ESLint not available or failed - try other linters

      // Try TypeScript compiler for TS files
      const tsFiles = files.filter(
        (f) => f.endsWith(".ts") || f.endsWith(".tsx"),
      );
      if (tsFiles.length > 0) {
        try {
          const tscResult = await this.bash.execute({
            command: `tsc --noEmit --pretty false ${tsFiles.join(" ")}`,
            description: "Check TypeScript files",
          });

          if (tscResult.metadata && tscResult.metadata.exitCode !== 0) {
            // Parse TypeScript errors for auto-fixable issues
            const tsIssues = this.parseTypeScriptErrors(
              tscResult.output,
              tsFiles,
            );
            issues.push(...tsIssues);
          }
        } catch (tscError) {
          // TypeScript not available
        }
      }

      // Try Python linters for Python files
      const pyFiles = files.filter((f) => f.endsWith(".py"));
      if (pyFiles.length > 0) {
        try {
          const flake8Result = await this.bash.execute({
            command: `flake8 --format=json ${pyFiles.join(" ")}`,
            description: "Check Python files with flake8",
          });

          const flake8Issues = this.parseFlake8Output(
            flake8Result.output,
            pyFiles,
          );
          issues.push(...flake8Issues);
        } catch (flake8Error) {
          // flake8 not available
        }
      }
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
          try {
            await this.bash.execute({
              command: `cp "${file}" "${file}.bak"`,
              description: "Create backup file",
            });
          } catch (error) {
            // Skip backup if failed
          }
        }
      }

      // Apply ESLint fixes
      const eslintFiles = filesToFix.filter((f) =>
        issues.some((i) => i.file === f && i.fix.action === "eslint-fix"),
      );

      if (eslintFiles.length > 0) {
        try {
          await this.bash.execute({
            command: `eslint --fix ${eslintFiles.join(" ")}`,
            description: "Apply ESLint auto-fixes",
          });

          for (const file of eslintFiles) {
            const fileIssues = issues.filter(
              (i) => i.file === file && i.fix.action === "eslint-fix",
            );
            changes.push({
              file,
              description: `Fixed ${fileIssues.length} ESLint issues`,
            });
          }
        } catch (error) {
          // ESLint fix failed
        }
      }

      // Apply other language-specific fixes
      await this.applyLanguageSpecificFixes(issues, changes, options);
    } else {
      // Dry run - just record what would be changed
      const fixesByFile = this.groupFixesByFile(issues);
      for (const [file, fileIssues] of fixesByFile) {
        changes.push({
          file,
          description: `Would fix ${fileIssues.length} lint issues`,
        });
      }
    }

    return changes;
  }

  private parseTypeScriptErrors(
    output: string,
    files: string[],
  ): FixableIssue[] {
    const issues: FixableIssue[] = [];
    const lines = output.split("\n");

    for (const line of lines) {
      // Parse TypeScript error format: file(line,col): error TS####: message
      const match = line.match(
        /^(.+)\((\d+),\d+\):\s+error\s+TS(\d+):\s+(.+)$/,
      );

      if (match && files.some((f) => match[1].includes(f))) {
        const [, file, lineNum, errorCode, message] = match;

        // Only include auto-fixable TypeScript errors
        if (this.isAutoFixableTypeScriptError(errorCode)) {
          issues.push({
            type: "lint",
            file: files.find((f) => match[1].includes(f)) || file,
            lineNumber: parseInt(lineNum),
            description: `TS${errorCode}: ${message}`,
            fix: {
              action: "typescript-fix",
              ruleId: `TS${errorCode}`,
              fixable: true,
            },
          });
        }
      }
    }

    return issues;
  }

  private parseFlake8Output(output: string, files: string[]): FixableIssue[] {
    const issues: FixableIssue[] = [];

    try {
      const flake8Results = JSON.parse(output);

      for (const result of flake8Results) {
        if (files.includes(result.filename)) {
          // Only include auto-fixable flake8 errors
          if (this.isAutoFixableFlake8Error(result.code)) {
            issues.push({
              type: "lint",
              file: result.filename,
              lineNumber: result.line_number,
              description: `${result.code}: ${result.text}`,
              fix: {
                action: "python-fix",
                ruleId: result.code,
                fixable: true,
              },
            });
          }
        }
      }
    } catch (error) {
      // Failed to parse flake8 JSON output
    }

    return issues;
  }

  private isAutoFixableTypeScriptError(errorCode: string): boolean {
    // Common auto-fixable TypeScript errors
    const autoFixableCodes = [
      "2304", // Cannot find name (import missing)
      "2307", // Cannot find module (import path)
      "2322", // Type assignment (simple cases)
      "2339", // Property does not exist (typos)
    ];

    return autoFixableCodes.includes(errorCode);
  }

  private isAutoFixableFlake8Error(code: string): boolean {
    // Common auto-fixable flake8 errors
    const autoFixableCodes = [
      "E302", // Expected 2 blank lines
      "E303", // Too many blank lines
      "E501", // Line too long (can be wrapped)
      "W291", // Trailing whitespace
      "W292", // No newline at end of file
      "W293", // Blank line contains whitespace
    ];

    return autoFixableCodes.includes(code);
  }

  private async applyLanguageSpecificFixes(
    issues: FixableIssue[],
    changes: FixChange[],
    options: FixOptions,
  ): Promise<void> {
    // Apply Python fixes with autopep8 or black
    const pythonFiles = [
      ...new Set(
        issues.filter((i) => i.fix.action === "python-fix").map((i) => i.file),
      ),
    ];

    if (pythonFiles.length > 0) {
      try {
        // Try autopep8 first
        await this.bash.execute({
          command: `autopep8 --in-place ${pythonFiles.join(" ")}`,
          description: "Apply Python auto-fixes with autopep8",
        });

        for (const file of pythonFiles) {
          const fileIssues = issues.filter(
            (i) => i.file === file && i.fix.action === "python-fix",
          );
          changes.push({
            file,
            description: `Fixed ${fileIssues.length} Python issues`,
          });
        }
      } catch (error) {
        try {
          // Try black as fallback
          await this.bash.execute({
            command: `black ${pythonFiles.join(" ")}`,
            description: "Format Python files with black",
          });

          for (const file of pythonFiles) {
            changes.push({
              file,
              description: "Applied black formatting",
            });
          }
        } catch (blackError) {
          // Neither autopep8 nor black available
        }
      }
    }

    // Apply TypeScript fixes (limited auto-fixes)
    const tsFiles = [
      ...new Set(
        issues
          .filter((i) => i.fix.action === "typescript-fix")
          .map((i) => i.file),
      ),
    ];

    if (tsFiles.length > 0) {
      // TypeScript auto-fixes are limited, mostly just report what would be fixed
      for (const file of tsFiles) {
        const fileIssues = issues.filter(
          (i) => i.file === file && i.fix.action === "typescript-fix",
        );
        changes.push({
          file,
          description: `${fileIssues.length} TypeScript issues require manual fixes`,
        });
      }
    }
  }

  private groupFixesByFile(
    issues: FixableIssue[],
  ): Map<string, FixableIssue[]> {
    const grouped = new Map<string, FixableIssue[]>();

    for (const issue of issues) {
      if (!grouped.has(issue.file)) {
        grouped.set(issue.file, []);
      }
      grouped.get(issue.file)!.push(issue);
    }

    return grouped;
  }
}

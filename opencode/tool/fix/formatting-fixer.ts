import { Fixer, FixableIssue, FixOptions, FixChange } from "./types";

export class FormattingFixer implements Fixer {
  constructor(private bash: any) {}

  async detect(files: string[]): Promise<FixableIssue[]> {
    const issues: FixableIssue[] = [];

    // Check if prettier is available and files need formatting
    try {
      const prettierCheck = await this.bash.execute({
        command: `prettier --check ${files.join(" ")}`,
        description: "Check formatting with Prettier",
      });

      if (prettierCheck.metadata && prettierCheck.metadata.exitCode !== 0) {
        // Parse prettier output to identify files needing formatting
        const needsFormatting = this.parsePrettierOutput(
          prettierCheck.output,
          files,
        );

        for (const file of needsFormatting) {
          issues.push({
            type: "formatting",
            file,
            description: "File needs formatting",
            fix: { action: "format", target: "prettier" },
          });
        }
      }
    } catch (error) {
      // Prettier not available, try ESLint
      try {
        const eslintCheck = await this.bash.execute({
          command: `eslint --format json ${files.join(" ")}`,
          description: "Check formatting with ESLint",
        });

        const eslintResults = JSON.parse(eslintCheck.output || "[]");

        for (const result of eslintResults) {
          const formattingMessages =
            result.messages?.filter(
              (msg: any) =>
                msg.ruleId &&
                (msg.ruleId.includes("indent") ||
                  msg.ruleId.includes("quotes") ||
                  msg.ruleId.includes("semi") ||
                  msg.ruleId.includes("spacing")),
            ) || [];

          if (formattingMessages.length > 0) {
            issues.push({
              type: "formatting",
              file: result.filePath,
              description: `${formattingMessages.length} formatting issues`,
              fix: { action: "format", target: "eslint" },
            });
          }
        }
      } catch (eslintError) {
        // Neither prettier nor eslint available
        // Skip formatting detection
      }
    }

    return issues;
  }

  async apply(
    issues: FixableIssue[],
    options: FixOptions,
  ): Promise<FixChange[]> {
    const changes: FixChange[] = [];
    const filesToFormat = [...new Set(issues.map((issue) => issue.file))];

    if (filesToFormat.length === 0) return changes;

    if (!options.dryRun) {
      // Create backups if requested
      if (options.backup) {
        for (const file of filesToFormat) {
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

      // Try prettier first
      const prettierFiles = issues
        .filter((i) => i.fix.target === "prettier")
        .map((i) => i.file);
      if (prettierFiles.length > 0) {
        try {
          await this.bash.execute({
            command: `prettier --write ${prettierFiles.join(" ")}`,
            description: "Format files with Prettier",
          });

          for (const file of prettierFiles) {
            changes.push({
              file,
              description: "Applied Prettier formatting",
            });
          }
        } catch (error) {
          // Prettier failed, record error but continue
        }
      }

      // Try ESLint --fix for remaining files
      const eslintFiles = issues
        .filter((i) => i.fix.target === "eslint")
        .map((i) => i.file);
      if (eslintFiles.length > 0) {
        try {
          await this.bash.execute({
            command: `eslint --fix ${eslintFiles.join(" ")}`,
            description: "Fix formatting with ESLint",
          });

          for (const file of eslintFiles) {
            changes.push({
              file,
              description: "Applied ESLint formatting fixes",
            });
          }
        } catch (error) {
          // ESLint failed, record error but continue
        }
      }
    } else {
      // Dry run - just record what would be changed
      for (const file of filesToFormat) {
        const issue = issues.find((i) => i.file === file);
        changes.push({
          file,
          description: `Would apply ${issue?.fix.target} formatting`,
        });
      }
    }

    return changes;
  }

  private parsePrettierOutput(output: string, files: string[]): string[] {
    const needsFormatting: string[] = [];

    // Prettier outputs filenames that need formatting
    const lines = output.split("\n");

    for (const line of lines) {
      const trimmed = line.trim();

      // Check if line contains a file path from our list
      for (const file of files) {
        if (
          trimmed.includes(file) ||
          trimmed.endsWith(file.split("/").pop() || "")
        ) {
          needsFormatting.push(file);
          break;
        }
      }
    }

    return [...new Set(needsFormatting)];
  }
}

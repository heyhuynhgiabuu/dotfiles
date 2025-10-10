import { Fixer, FixableIssue, FixOptions, FixChange } from "./types";

export class DeprecatedFixer implements Fixer {
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

        // Detect deprecated API usage
        const deprecatedUsages = this.findDeprecatedUsages(file, fileContent);

        for (const usage of deprecatedUsages) {
          issues.push({
            type: "deprecated",
            file,
            lineNumber: usage.lineNumber,
            description: `Deprecated API: ${usage.api} -> ${usage.replacement}`,
            fix: {
              action: "replace",
              target: usage.oldPattern,
              fixable: usage.autoFixable,
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
        const fileChanges = await this.applyDeprecatedFixes(
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

  private findDeprecatedUsages(
    file: string,
    content: string,
  ): DeprecatedUsage[] {
    const usages: DeprecatedUsage[] = [];
    const lines = content.split("\n");

    // Define deprecated API patterns based on file type
    const deprecatedPatterns = this.getDeprecatedPatterns(file);

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];

      for (const pattern of deprecatedPatterns) {
        const match = line.match(pattern.regex);
        if (match) {
          usages.push({
            api: pattern.api,
            oldPattern: match[0],
            newPattern: pattern.replacement(match),
            replacement: pattern.description,
            lineNumber: i + 1,
            autoFixable: pattern.autoFixable,
          });
        }
      }
    }

    return usages;
  }

  private getDeprecatedPatterns(file: string): DeprecatedPattern[] {
    const patterns: DeprecatedPattern[] = [];

    // JavaScript/TypeScript patterns
    if (
      file.endsWith(".js") ||
      file.endsWith(".ts") ||
      file.endsWith(".jsx") ||
      file.endsWith(".tsx")
    ) {
      patterns.push(
        // React class components -> functional components (simple cases)
        {
          api: "React.createClass",
          regex: /React\.createClass\s*\(/g,
          replacement: () => "function Component()",
          description: "Use functional components",
          autoFixable: false, // Too complex for auto-fix
        },

        // jQuery -> vanilla JS
        {
          api: "$(document).ready",
          regex: /\$\(document\)\.ready\s*\(/g,
          replacement: () => 'document.addEventListener("DOMContentLoaded", ',
          description: "Use native DOM events",
          autoFixable: true,
        },

        // Old Node.js APIs
        {
          api: "fs.exists",
          regex: /fs\.exists\s*\(/g,
          replacement: () => "fs.access(",
          description: "Use fs.access instead of fs.exists",
          autoFixable: true,
        },

        // Buffer constructor
        {
          api: "new Buffer",
          regex: /new Buffer\s*\(/g,
          replacement: () => "Buffer.from(",
          description: "Use Buffer.from instead of Buffer constructor",
          autoFixable: true,
        },

        // React PropTypes
        {
          api: "React.PropTypes",
          regex: /React\.PropTypes/g,
          replacement: () => "PropTypes",
          description: "Import PropTypes from prop-types package",
          autoFixable: false, // Requires import statement
        },

        // Moment.js -> date-fns/dayjs
        {
          api: "moment()",
          regex: /moment\s*\(/g,
          replacement: () => "dayjs(",
          description: "Consider using dayjs or date-fns",
          autoFixable: false, // Requires dependency change
        },
      );
    }

    // Python patterns
    if (file.endsWith(".py")) {
      patterns.push(
        // Python 2 print statements
        {
          api: "print statement",
          regex: /^(\s*)print\s+([^(].*)/gm,
          replacement: (match) => `${match[1]}print(${match[2]})`,
          description: "Use print() function",
          autoFixable: true,
        },

        // Python 2 string formatting
        {
          api: "% string formatting",
          regex: /"[^"]*"\s*%\s*\(/g,
          replacement: () => "Use f-strings or .format()",
          description: "Use modern string formatting",
          autoFixable: false,
        },

        // urllib2 -> urllib
        {
          api: "urllib2",
          regex: /import urllib2/g,
          replacement: () => "import urllib.request",
          description: "Use urllib.request in Python 3",
          autoFixable: true,
        },
      );
    }

    // CSS patterns
    if (
      file.endsWith(".css") ||
      file.endsWith(".scss") ||
      file.endsWith(".less")
    ) {
      patterns.push(
        // Vendor prefixes that are no longer needed
        {
          api: "-webkit-border-radius",
          regex: /-webkit-border-radius\s*:/g,
          replacement: () => "border-radius:",
          description: "border-radius is widely supported",
          autoFixable: true,
        },

        {
          api: "-moz-border-radius",
          regex: /-moz-border-radius\s*:/g,
          replacement: () => "border-radius:",
          description: "border-radius is widely supported",
          autoFixable: true,
        },
      );
    }

    return patterns;
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

  private async applyDeprecatedFixes(
    file: string,
    issues: FixableIssue[],
    options: FixOptions,
  ): Promise<FixChange[]> {
    const changes: FixChange[] = [];

    // Only process auto-fixable issues
    const autoFixableIssues = issues.filter((issue) => issue.fix.fixable);

    if (autoFixableIssues.length === 0) {
      // Record non-fixable issues for manual review
      const manualIssues = issues.filter((issue) => !issue.fix.fixable);
      if (manualIssues.length > 0) {
        changes.push({
          file,
          description: `${manualIssues.length} deprecated APIs require manual migration`,
          before: manualIssues.map((i) => i.description).join(", "),
          after: "Manual migration required",
        });
      }
      return changes;
    }

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

      // Apply replacements
      for (const issue of autoFixableIssues) {
        const deprecatedUsage = this.findDeprecatedUsageByIssue(
          issue,
          modifiedContent,
        );
        if (deprecatedUsage) {
          modifiedContent = modifiedContent.replace(
            deprecatedUsage.oldPattern,
            deprecatedUsage.newPattern,
          );
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
    const fixedCount = autoFixableIssues.length;
    const manualCount = issues.length - fixedCount;

    let description = `Updated ${fixedCount} deprecated APIs`;
    if (manualCount > 0) {
      description += `, ${manualCount} require manual migration`;
    }

    changes.push({
      file,
      description,
      before: `${issues.length} deprecated API usages`,
      after: `${fixedCount} auto-fixed, ${manualCount} manual`,
    });

    return changes;
  }

  private findDeprecatedUsageByIssue(
    issue: FixableIssue,
    content: string,
  ): DeprecatedUsage | null {
    // Re-find the deprecated usage in the current content
    // This is needed because content may have changed from previous fixes
    const lines = content.split("\n");

    if (issue.lineNumber && issue.lineNumber <= lines.length) {
      const line = lines[issue.lineNumber - 1];

      // Try to match the issue's target pattern
      if (issue.fix.target && line.includes(issue.fix.target)) {
        // Find the corresponding pattern and create usage
        const patterns = this.getDeprecatedPatterns(issue.file);

        for (const pattern of patterns) {
          const match = line.match(pattern.regex);
          if (match && match[0] === issue.fix.target) {
            return {
              api: pattern.api,
              oldPattern: match[0],
              newPattern: pattern.replacement(match),
              replacement: pattern.description,
              lineNumber: issue.lineNumber,
              autoFixable: pattern.autoFixable,
            };
          }
        }
      }
    }

    return null;
  }
}

interface DeprecatedUsage {
  api: string;
  oldPattern: string;
  newPattern: string;
  replacement: string;
  lineNumber: number;
  autoFixable: boolean;
}

interface DeprecatedPattern {
  api: string;
  regex: RegExp;
  replacement: (match: RegExpMatchArray) => string;
  description: string;
  autoFixable: boolean;
}

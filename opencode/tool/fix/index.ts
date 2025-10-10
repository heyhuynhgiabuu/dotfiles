// Refactored fix tool - main entry point
import z from "zod/v4";
import { Tool } from "../tool";
import { GrepTool } from "../grep";
import { ReadTool } from "../read";
import { EditTool } from "../edit";
import { BashTool } from "../bash";
import { GlobTool } from "../glob";
import { Instance } from "../../project/instance";
import path from "path";

import DESCRIPTION from "../fix.txt";
import { FixParams, FixChange, FixError, Fixer } from "./types";
import { PerformanceMonitor } from "./performance";
import { UnusedFixer } from "./unused-fixer";
import { DeprecatedFixer } from "./deprecated-fixer";
import { ImportsFixer } from "./imports-fixer";
import { FormattingFixer } from "./formatting-fixer";
import { LintFixer } from "./lint-fixer";

// Core fix engine orchestrator
class FixEngine {
  private monitor = new PerformanceMonitor();

  constructor(
    private grep = GrepTool,
    private read = ReadTool,
    private edit = EditTool,
    private bash = BashTool,
    private glob = GlobTool,
  ) {}

  async execute(params: FixParams, ctx: any) {
    const errors: FixError[] = [];
    const changes: FixChange[] = [];

    this.monitor.start();

    try {
      // Get target files with error handling
      const files = await this.getTargetFiles(params.files, params.type).catch(
        (error) => {
          errors.push({
            type: "invalid_pattern",
            message: `Failed to discover files: ${error.message}`,
            suggestion: "Check file patterns and permissions",
          });
          return [];
        },
      );

      if (files.length === 0) {
        return this.createEmptyResult(params.type, errors);
      }

      // Get appropriate fixer
      const fixer = this.getFixerForType(params.type);

      // Detect issues
      const issues = await fixer.detect(files);

      if (issues.length === 0) {
        return this.createNoIssuesResult(params.type, files.length);
      }

      // Apply fixes with individual error handling
      for (const file of [...new Set(issues.map((i) => i.file))]) {
        try {
          this.monitor.recordFile();

          const fileIssues = issues.filter((i) => i.file === file);
          const fileChanges = await this.applyFixesToFile(
            file,
            fileIssues,
            params,
            fixer,
          );

          changes.push(...fileChanges);

          for (const change of fileChanges) {
            this.monitor.recordChange();
          }
        } catch (error) {
          errors.push({
            type: "permission",
            file,
            message: error.message,
            suggestion: "Check file permissions and syntax",
          });
        }
      }
    } catch (error) {
      errors.push({
        type: "timeout",
        message: `Fix operation failed: ${error.message}`,
        suggestion: "Try processing fewer files or use more specific patterns",
      });
    }

    return this.formatResult(changes, errors, params.type);
  }

  private async getTargetFiles(
    files?: string[],
    fixType?: string,
  ): Promise<string[]> {
    if (files && files.length > 0) {
      // Use provided file patterns
      const allFiles: string[] = [];

      for (const pattern of files) {
        if (pattern.includes("*") || pattern.includes("?")) {
          // Use glob for patterns
          const globResult = await this.glob.execute({ pattern });
          if (globResult.metadata.files) {
            allFiles.push(...globResult.metadata.files);
          }
        } else {
          // Direct file path
          allFiles.push(
            path.isAbsolute(pattern)
              ? pattern
              : path.join(Instance.directory, pattern),
          );
        }
      }

      return [...new Set(allFiles)];
    }

    // Auto-detect based on fix type
    return this.getDefaultFilesForType(fixType);
  }

  private async getDefaultFilesForType(fixType?: string): Promise<string[]> {
    const patterns: Record<string, string> = {
      imports: "**/*.{ts,tsx,js,jsx}",
      formatting: "**/*.{ts,tsx,js,jsx,py,rs}",
      lint: "**/*.{ts,tsx,js,jsx}",
      unused: "**/*.{ts,tsx,js,jsx}",
      deprecated: "**/*.{ts,tsx,js,jsx}",
    };

    const pattern = patterns[fixType || "imports"];
    const globResult = await this.glob.execute({ pattern });

    return globResult.metadata.files || [];
  }

  private getFixerForType(type: string): Fixer {
    switch (type) {
      case "imports":
        return new ImportsFixer(this.grep, this.read, this.edit, this.bash);
      case "formatting":
        return new FormattingFixer(this.bash);
      case "lint":
        return new LintFixer(this.bash);
      case "unused":
        return new UnusedFixer(this.grep, this.read, this.edit);
      case "deprecated":
        return new DeprecatedFixer(this.grep, this.read, this.edit);
      default:
        throw new Error(`Unknown fix type: ${type}`);
    }
  }

  private async applyFixesToFile(
    file: string,
    issues: any[],
    params: FixParams,
    fixer: Fixer,
  ): Promise<FixChange[]> {
    // Pre-flight checks
    await this.validateFile(file);

    // Apply fixes
    return await fixer.apply(issues, {
      dryRun: params.dryRun ?? true,
      backup: params.backup ?? false,
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
  }

  private isBinaryFile(content: string): boolean {
    // Simple binary detection - check for null bytes
    return content.includes("\0");
  }

  private createEmptyResult(type: string, errors: FixError[]) {
    return {
      title: `No files found for ${type} fixes`,
      metadata: {
        type,
        filesProcessed: 0,
        filesChanged: 0,
        changesApplied: 0,
        duration: this.monitor.getMetrics().duration,
        dryRun: true,
      },
      output: {
        summary: `No files found matching patterns for ${type} fixes`,
        changes: [],
        errors,
      },
    };
  }

  private createNoIssuesResult(type: string, fileCount: number) {
    return {
      title: `No ${type} issues found`,
      metadata: {
        type,
        filesProcessed: fileCount,
        filesChanged: 0,
        changesApplied: 0,
        duration: this.monitor.getMetrics().duration,
        dryRun: true,
      },
      output: {
        summary: `Analyzed ${fileCount} files, no ${type} issues found`,
        changes: [],
        errors: [],
      },
    };
  }

  private formatResult(changes: FixChange[], errors: FixError[], type: string) {
    const metrics = this.monitor.getMetrics();
    const filesChanged = new Set(changes.map((c) => c.file)).size;

    return {
      title: `${type.charAt(0).toUpperCase() + type.slice(1)} fixes ${changes.length > 0 ? "applied" : "completed"}`,
      metadata: {
        type,
        filesProcessed: metrics.filesProcessed,
        filesChanged,
        changesApplied: changes.length,
        duration: metrics.duration,
        dryRun: changes.length > 0 ? false : true,
        errors: errors.length,
      },
      output: {
        summary: this.createSummary(changes, errors, type, metrics),
        changes,
        errors,
      },
    };
  }

  private createSummary(
    changes: FixChange[],
    errors: FixError[],
    type: string,
    metrics: any,
  ): string {
    const filesChanged = new Set(changes.map((c) => c.file)).size;

    if (changes.length === 0 && errors.length === 0) {
      return `No ${type} issues found in ${metrics.filesProcessed} files`;
    }

    if (changes.length === 0 && errors.length > 0) {
      return `${type} fixes failed: ${errors.length} errors encountered`;
    }

    let summary = `Applied ${changes.length} ${type} fixes to ${filesChanged} files`;

    if (errors.length > 0) {
      summary += ` (${errors.length} errors)`;
    }

    summary += ` in ${metrics.duration}ms`;

    return summary;
  }
}

// Main tool definition
export const FixTool = Tool.define("fix", {
  description: DESCRIPTION,
  parameters: z.object({
    type: z
      .enum(["imports", "formatting", "lint", "unused", "deprecated"])
      .describe("Fix type to apply"),
    files: z
      .array(z.string())
      .optional()
      .describe("Specific files (default: auto-detect)"),
    dryRun: z
      .boolean()
      .optional()
      .default(true)
      .describe("Preview changes without applying"),
    backup: z
      .boolean()
      .optional()
      .default(false)
      .describe("Create backup before changes"),
  }),

  async execute(params: FixParams, ctx: any) {
    const engine = new FixEngine();
    return await engine.execute(params, ctx);
  },
});

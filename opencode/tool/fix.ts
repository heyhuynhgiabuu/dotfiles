// @ts-nocheck
import { tool } from "@opencode-ai/plugin";

export default tool({
  description: `Apply common fixes across multiple files with batch operations.

This tool provides intelligent batch fixing for common maintenance tasks:

- imports: Organize, remove unused, sort imports
- formatting: Apply consistent code style (prettier, eslint --fix)
- lint: Fix common linting issues automatically
- unused: Remove unused variables/imports/functions
- deprecated: Update deprecated API usage patterns

Features:
- Dry-run mode by default for safety
- Backup option for risky operations
- Performance limits (100 files, 30s timeout)
- Cross-platform compatibility
- Integration with existing formatters and linters

Examples:
  fix --type imports --dryRun
  fix --type formatting --files "src/**/*.ts" --backup
  fix --type lint`,

  args: {
    type: tool.schema
      .enum(["imports", "formatting", "lint", "unused", "deprecated"])
      .describe("Fix type to apply"),
    files: tool.schema
      .array(tool.schema.string())
      .optional()
      .describe("Specific files (default: auto-detect)"),
    dryRun: tool.schema
      .boolean()
      .optional()
      .describe("Preview changes without applying (default: true)"),
    backup: tool.schema
      .boolean()
      .optional()
      .describe("Create backup before changes (default: false)"),
  },

  async execute(args: any, context: any) {
    const { type, files, dryRun = true, backup = false } = args;
    const startTime = Date.now();

    try {
      // Basic validation
      if (!type) {
        return {
          title: "Fix operation failed",
          output:
            "Error: Fix type is required. Use one of: imports, formatting, lint, unused, deprecated",
        };
      }

      // Import and use the fix engine from our plugin implementation
      const { FixEngine } = await import("./fix/plugin-engine.js");
      const engine = new FixEngine();

      const result = await engine.execute(
        {
          type,
          files,
          dryRun,
          backup,
        },
        context,
      );

      return result;
    } catch (error) {
      return {
        title: "Fix operation failed",
        metadata: {
          type,
          filesProcessed: 0,
          filesChanged: 0,
          changesApplied: 0,
          duration: Date.now() - startTime,
          dryRun: true,
          errors: 1,
        },
        output: {
          summary: `Fix operation failed: ${error.message}`,
          changes: [],
          errors: [
            {
              type: "tool_error",
              message: error.message,
              suggestion: "Check tool availability and file permissions",
            },
          ],
        },
      };
    }
  },
});

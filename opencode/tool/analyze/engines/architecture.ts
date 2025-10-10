// @ts-nocheck
import { BaseEngine } from "./base";
import {
  AnalysisConfig,
  ArchitectureAnalysis,
  ArchitecturalPattern,
  ArchitecturalViolation,
  ArchitecturalSuggestion,
} from "../types";

export class ArchitectureEngine extends BaseEngine {
  async analyze(config: AnalysisConfig): Promise<ArchitectureAnalysis> {
    const cacheKey = `architecture:${this.getCacheKey(config)}`;

    if (config.useCache) {
      const cached = await this.cache.get<ArchitectureAnalysis>(cacheKey);
      if (cached) return cached;
    }

    try {
      const patterns: ArchitecturalPattern[] = [];
      const violations: ArchitecturalViolation[] = [];
      const suggestions: ArchitecturalSuggestion[] = [];

      const findCmd = `find . -type f \\( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" \\) -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null`;
      const filesOutput = await this.executeCommand(findCmd);
      const sourceFiles = filesOutput.split("\n").filter((f) => f.trim());

      // Detect architectural patterns
      const hasComponents = sourceFiles.some((f: any) =>
        f.includes("component"),
      );
      const hasServices = sourceFiles.some((f: any) => f.includes("service"));
      const hasUtils = sourceFiles.some((f: any) => f.includes("util"));
      const hasControllers = sourceFiles.some((f: any) =>
        f.includes("controller"),
      );
      const hasModels = sourceFiles.some((f: any) => f.includes("model"));
      const hasViews = sourceFiles.some((f: any) => f.includes("view"));

      if (hasComponents) {
        patterns.push({
          name: "Component Architecture",
          type: "architectural-pattern",
          confidence: 0.8,
          files: sourceFiles.filter((f: any) => f.includes("component")),
          description: "Component-based architecture detected",
        });
      }

      if (hasServices) {
        patterns.push({
          name: "Service Layer",
          type: "architectural-pattern",
          confidence: 0.7,
          files: sourceFiles.filter((f: any) => f.includes("service")),
          description: "Service layer pattern detected",
        });
      }

      if (hasControllers && hasModels && hasViews) {
        patterns.push({
          name: "MVC Pattern",
          type: "architectural-pattern",
          confidence: 0.9,
          files: sourceFiles.filter(
            (f: any) =>
              f.includes("controller") ||
              f.includes("model") ||
              f.includes("view"),
          ),
          description: "Model-View-Controller pattern detected",
        });
      }

      // Check for violations
      const largeFiles = await this.findLargeFiles(sourceFiles);
      for (const file of largeFiles) {
        violations.push({
          rule: "File size limit",
          severity: "warning",
          file: file.path,
          description: `File is too large (${file.lines} lines)`,
          suggestion: "Consider breaking into smaller modules",
        });
      }

      // Generate suggestions
      if (!hasUtils && sourceFiles.length > 10) {
        suggestions.push({
          category: "structure",
          priority: "medium",
          title: "Add utility layer",
          description: "Consider adding a utilities layer for shared functions",
          benefits: ["Code reusability", "Better organization"],
          effort: "low",
        });
      }

      if (!hasServices && sourceFiles.length > 20) {
        suggestions.push({
          category: "patterns",
          priority: "high",
          title: "Implement service layer",
          description: "Add service layer to separate business logic",
          benefits: ["Better separation of concerns", "Improved testability"],
          effort: "medium",
        });
      }

      if (patterns.length === 0) {
        suggestions.push({
          category: "structure",
          priority: "high",
          title: "Define architectural pattern",
          description: "Project lacks clear architectural patterns",
          benefits: ["Better code organization", "Improved maintainability"],
          effort: "high",
        });
      }

      const result: ArchitectureAnalysis = {
        patterns,
        violations,
        suggestions,
      };

      await this.cache.set(cacheKey, result, 600);
      return result;
    } catch (error) {
      this.client.app
        .log({
          body: {
            service: "analyze-tool",
            level: "warn",
            message: `Architecture analysis failed: ${error.message}`,
          },
        })
        .catch(() => {});
      return { patterns: [], violations: [], suggestions: [] };
    }
  }

  private async findLargeFiles(
    files: string[],
  ): Promise<{ path: string; lines: number }[]> {
    const largeFiles: { path: string; lines: number }[] = [];

    for (const file of files.slice(0, 20)) {
      try {
        const content = await this.executeCommand(`cat "${file}"`);

        if (content) {
          const lines = content.split("\n").length;
          if (lines > 300) {
            largeFiles.push({ path: file, lines });
          }
        }
      } catch (error) {
        this.client.app
          .log({
            body: {
              service: "analyze-tool",
              level: "warn",
              message: `Failed to analyze ${file}: ${error.message}`,
            },
          })
          .catch(() => {});
      }
    }

    return largeFiles;
  }
}

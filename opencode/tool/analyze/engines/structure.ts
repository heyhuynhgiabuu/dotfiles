// @ts-nocheck
import { BaseEngine } from "./base";
import {
  AnalysisConfig,
  StructureAnalysis,
  DirectoryInfo,
  KeyFile,
  DetectedPattern,
  ProjectSize,
} from "../types";

export class StructureEngine extends BaseEngine {
  async analyze(config: AnalysisConfig): Promise<StructureAnalysis> {
    const cacheKey = `structure:${this.getCacheKey(config)}`;

    if (config.useCache) {
      const cached = await this.cache.get<StructureAnalysis>(cacheKey);
      if (cached) return cached;
    }

    try {
      const excludePatterns = [
        "node_modules",
        ".git",
        "dist",
        "build",
        "*.log",
        ...config.exclude,
      ];

      // Use glob pattern to find all files
      const scope = config.scope.length > 0 ? config.scope : ["**/*"];
      const pattern = scope.join(",");

      // Build exclude args for find command
      const excludeArgs = excludePatterns
        .map((p) => `-path "*/${p}" -prune -o`)
        .join(" ");

      // Use find command to get all files
      const findCmd = `find . ${excludeArgs} -type f -print | sed 's|^\\./||'`;
      const filesOutput = await this.executeCommand(findCmd);

      const allFiles = filesOutput
        .split("\n")
        .filter((f) => f.trim() && !f.includes("Permission denied"))
        .filter((f) => !excludePatterns.some((p) => f.includes(p)));

      // Get line counts for files
      const lineCountCmd = `find . ${excludeArgs} -type f -print0 | xargs -0 wc -l 2>/dev/null | tail -1`;
      const lineCountOutput = await this.executeCommand(lineCountCmd);
      const totalLines = parseInt(lineCountOutput.trim().split(/\s+/)[0]) || 0;

      const directories = this.buildDirectoryTree(allFiles);
      const keyFiles = this.identifyKeyFiles(allFiles);
      const patterns = this.detectPatterns(allFiles);
      const size = await this.calculateProjectSize(allFiles, totalLines);

      const result: StructureAnalysis = {
        directories,
        keyFiles,
        patterns,
        size,
      };

      await this.cache.set(cacheKey, result, 300);
      return result;
    } catch (error) {
      this.client.app
        .log({
          body: {
            service: "analyze-tool",
            level: "warn",
            message: `Structure analysis failed: ${error.message}`,
          },
        })
        .catch(() => {});
      return {
        directories: [],
        keyFiles: [],
        patterns: [],
        size: { files: 0, lines: 0, bytes: 0, directories: 0 },
      };
    }
  }

  private buildDirectoryTree(files: string[]): DirectoryInfo[] {
    const dirMap = new Map<string, number>();

    files.forEach((file) => {
      const parts = file.split("/");
      for (let i = 0; i < parts.length - 1; i++) {
        const dirPath = parts.slice(0, i + 1).join("/");
        dirMap.set(dirPath, (dirMap.get(dirPath) || 0) + 1);
      }
    });

    return Array.from(dirMap.entries()).map(([path, fileCount]) => ({
      path,
      type: this.inferDirectoryType(path),
      fileCount,
      purpose: this.inferDirectoryPurpose(path),
      importance: fileCount > 10 ? "high" : fileCount > 5 ? "medium" : "low",
    }));
  }

  private identifyKeyFiles(files: string[]): KeyFile[] {
    const keyPatterns = [
      {
        pattern: /package\.json$/,
        type: "package",
        importance: "critical" as const,
      },
      {
        pattern: /README\.md$/i,
        type: "documentation",
        importance: "high" as const,
      },
      { pattern: /\.env/, type: "environment", importance: "high" as const },
      { pattern: /docker/i, type: "deployment", importance: "medium" as const },
      { pattern: /test|spec/i, type: "test", importance: "medium" as const },
    ];

    return files
      .map((file) => {
        const match = keyPatterns.find((p) => p.pattern.test(file));
        return match
          ? {
              path: file,
              type: match.type,
              importance: match.importance,
              purpose: this.inferFilePurpose(file, match.type),
              size: 0,
            }
          : null;
      })
      .filter(Boolean) as KeyFile[];
  }

  private detectPatterns(files: string[]): DetectedPattern[] {
    const patterns: DetectedPattern[] = [];

    const hasReact = files.some(
      (f) => f.includes(".jsx") || f.includes(".tsx"),
    );
    const hasVue = files.some((f) => f.includes(".vue"));
    const hasNode = files.some((f) => f.includes("package.json"));

    if (hasReact) {
      patterns.push({
        name: "React",
        description: "React framework detected",
        files: files.filter((f) => f.includes(".jsx") || f.includes(".tsx")),
        confidence: 0.9,
        category: "framework",
      });
    }

    if (hasVue) {
      patterns.push({
        name: "Vue.js",
        description: "Vue.js framework detected",
        files: files.filter((f) => f.includes(".vue")),
        confidence: 0.9,
        category: "framework",
      });
    }

    if (hasNode) {
      patterns.push({
        name: "Node.js",
        description: "Node.js project detected",
        files: files.filter((f) => f.includes("package.json")),
        confidence: 0.8,
        category: "framework",
      });
    }

    return patterns;
  }

  private async calculateProjectSize(
    files: string[],
    totalLines: number,
  ): Promise<ProjectSize> {
    const directories = new Set<string>();

    files.forEach((file) => {
      const parts = file.split("/");
      for (let i = 0; i < parts.length - 1; i++) {
        directories.add(parts.slice(0, i + 1).join("/"));
      }
    });

    // Get total size in bytes
    let totalBytes = 0;
    try {
      const sizeCmd = `du -sb . 2>/dev/null | cut -f1`;
      const sizeOutput = await this.executeCommand(sizeCmd);
      totalBytes = parseInt(sizeOutput.trim()) || 0;
    } catch (error) {
      this.client.app
        .log({
          body: {
            service: "analyze-tool",
            level: "warn",
            message: `Failed to calculate total size: ${error.message}`,
          },
        })
        .catch(() => {});
    }

    return {
      files: files.length,
      lines: totalLines,
      bytes: totalBytes,
      directories: directories.size,
    };
  }

  private inferDirectoryType(path: string): string {
    if (path.includes("src")) return "source";
    if (path.includes("test")) return "test";
    if (path.includes("config")) return "config";
    if (path.includes("docs")) return "docs";
    if (path.includes("assets")) return "assets";
    if (path.includes("build") || path.includes("dist")) return "build";
    return "unknown";
  }

  private inferDirectoryPurpose(path: string): string {
    const type = this.inferDirectoryType(path);
    const purposes = {
      source: "Contains source code",
      test: "Contains test files",
      config: "Contains configuration files",
      docs: "Contains documentation",
      assets: "Contains static assets",
      build: "Contains build artifacts",
      unknown: "Purpose unclear",
    };
    return purposes[type] || "Purpose unclear";
  }

  private inferFilePurpose(file: string, type: string): string {
    const purposes = {
      package: "Package configuration and dependencies",
      documentation: "Project documentation",
      environment: "Environment variables",
      deployment: "Deployment configuration",
      test: "Test files",
      source: "Source code",
      asset: "Static assets",
    };
    return purposes[type] || "File purpose unclear";
  }
}

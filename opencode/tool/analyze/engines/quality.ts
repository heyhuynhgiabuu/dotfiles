// @ts-nocheck
import { BaseEngine } from "./base";
import {
  AnalysisConfig,
  QualityAnalysis,
  TechDebtItem,
  CodeSmell,
} from "../types";

export class QualityEngine extends BaseEngine {
  async analyze(config: AnalysisConfig): Promise<QualityAnalysis> {
    const cacheKey = `quality:${this.getCacheKey(config)}`;

    if (config.useCache) {
      const cached = await this.cache.get<QualityAnalysis>(cacheKey);
      if (cached) return cached;
    }

    try {
      const findCmd = `find . -type f \\( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.py" -o -name "*.java" -o -name "*.go" -o -name "*.rs" \\) -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null`;
      const filesOutput = await this.executeCommand(findCmd);
      const sourceFiles = filesOutput.split("\n").filter((f) => f.trim());

      const techDebt: TechDebtItem[] = [];
      const codeSmells: CodeSmell[] = [];
      let totalComplexity = 0;
      let fileCount = 0;

      for (const file of sourceFiles.slice(0, 20)) {
        try {
          const content = await this.executeCommand(`cat "${file}"`);

          if (content) {
            const lines = content.split("\n");

            lines.forEach((line: any, index: any) => {
              if (line.includes("TODO") || line.includes("FIXME")) {
                techDebt.push({
                  file,
                  line: index + 1,
                  type: "code-smell",
                  severity: "minor",
                  description: line.trim(),
                });
              }

              if (line.length > 120) {
                codeSmells.push({
                  type: "long-line",
                  file,
                  line: index + 1,
                  description: "Line exceeds 120 characters",
                  suggestion: "Break into multiple lines",
                });
              }
            });

            const complexity = this.calculateComplexity(content.content);
            totalComplexity += complexity;
            fileCount++;
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

      const avgComplexity = fileCount > 0 ? totalComplexity / fileCount : 0;
      const maintainabilityScore = Math.max(0, 100 - avgComplexity * 2);
      const grade =
        maintainabilityScore >= 80
          ? "A"
          : maintainabilityScore >= 60
            ? "B"
            : maintainabilityScore >= 40
              ? "C"
              : maintainabilityScore >= 20
                ? "D"
                : "F";

      const result: QualityAnalysis = {
        maintainability: { score: maintainabilityScore, grade },
        complexity: {
          cyclomatic: avgComplexity,
          cognitive: avgComplexity * 1.2,
        },
        techDebt,
        codeSmells,
      };

      await this.cache.set(cacheKey, result, 600);
      return result;
    } catch (error) {
      this.client.app
        .log({
          body: {
            service: "analyze-tool",
            level: "warn",
            message: `Quality analysis failed: ${error.message}`,
          },
        })
        .catch(() => {});
      return {
        maintainability: { score: 0, grade: "F" },
        complexity: { cyclomatic: 0, cognitive: 0 },
        techDebt: [],
        codeSmells: [],
      };
    }
  }

  private calculateComplexity(content: string): number {
    const complexityKeywords = [
      "if",
      "else",
      "for",
      "while",
      "switch",
      "case",
      "catch",
      "try",
    ];
    let complexity = 1;

    complexityKeywords.forEach((keyword) => {
      const regex = new RegExp(`\\b${keyword}\\b`, "g");
      const matches = content.match(regex);
      if (matches) {
        complexity += matches.length;
      }
    });

    return complexity;
  }
}

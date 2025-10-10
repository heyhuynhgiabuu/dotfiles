// @ts-nocheck
import { StructureEngine } from "./structure";
import { DependencyEngine } from "./dependency";
import { SecurityEngine } from "./security";
import { QualityEngine } from "./quality";
import { PerformanceEngine } from "./performance";
import { ArchitectureEngine } from "./architecture";
import { BaseEngine } from "./base";
import { AnalysisConfig, AnalysisResult, Recommendation } from "../types";
import { CacheManager } from "../cache/manager";

export class AnalysisEngine {
  private engines: Map<string, BaseEngine>;

  constructor(
    private client: any,
    private cache: CacheManager,
  ) {
    this.engines = new Map([
      ["structure", new StructureEngine(client, cache)],
      ["dependency", new DependencyEngine(client, cache)],
      ["security", new SecurityEngine(client, cache)],
      ["quality", new QualityEngine(client, cache)],
      ["performance", new PerformanceEngine(client, cache)],
      ["architecture", new ArchitectureEngine(client, cache)],
    ]);
  }

  async analyze(config: AnalysisConfig): Promise<AnalysisResult> {
    const startTime = Date.now();
    const results: AnalysisResult = {
      metadata: {
        mode: config.mode,
        timestamp: new Date().toISOString(),
        duration: 0,
        scope: config.scope,
        exclude: config.exclude,
      },
    };

    const engineOrder = this.getEngineOrder(config.mode);

    for (const engineName of engineOrder) {
      const engine = this.engines.get(engineName);
      if (!engine) continue;

      try {
        const engineResult = await engine.analyze(config);
        results[engineName] = engineResult;
      } catch (error) {
        this.client.app
          .log({
            body: {
              service: "analyze-tool",
              level: "warn",
              message: `Engine ${engineName} failed: ${error.message}`,
            },
          })
          .catch(() => {});
        results[engineName] = { error: error.message };
      }
    }

    results.recommendations = this.generateRecommendations(results);
    results.metadata.duration = Date.now() - startTime;
    return results;
  }

  private getEngineOrder(mode: string): string[] {
    const orders = {
      quick: ["structure", "dependency"],
      deep: ["structure", "dependency", "quality", "architecture"],
      security: ["structure", "dependency", "security"],
      performance: ["structure", "dependency", "performance"],
      architecture: ["structure", "dependency", "quality", "architecture"],
    };
    return orders[mode] || orders.quick;
  }

  private generateRecommendations(results: AnalysisResult): Recommendation[] {
    const recommendations: Recommendation[] = [];

    if (results.security?.issues && results.security.issues.length > 0) {
      recommendations.push({
        id: "security-issues",
        category: "security",
        priority: "high",
        title: "Address security issues",
        description: `Found ${results.security.issues.length} security issues`,
        effort: "medium",
        impact: "high",
        relatedFiles: results.security.issues.map((i) => i.file),
      });
    }

    if (
      results.performance?.bottlenecks &&
      results.performance.bottlenecks.length > 0
    ) {
      recommendations.push({
        id: "performance-bottlenecks",
        category: "performance",
        priority: "medium",
        title: "Optimize performance bottlenecks",
        description: `Found ${results.performance.bottlenecks.length} performance issues`,
        effort: "medium",
        impact: "medium",
        relatedFiles: results.performance.bottlenecks.map((b) => b.location),
      });
    }

    if (results.quality?.techDebt && results.quality.techDebt.length > 5) {
      recommendations.push({
        id: "tech-debt",
        category: "maintainability",
        priority: "low",
        title: "Address technical debt",
        description: `Found ${results.quality.techDebt.length} technical debt items`,
        effort: "high",
        impact: "medium",
        relatedFiles: results.quality.techDebt.map((t) => t.file),
      });
    }

    if (
      results.architecture?.violations &&
      results.architecture.violations.length > 0
    ) {
      recommendations.push({
        id: "architecture-violations",
        category: "architecture",
        priority: "high",
        title: "Fix architectural violations",
        description: `Found ${results.architecture.violations.length} architectural violations`,
        effort: "high",
        impact: "high",
        relatedFiles: results.architecture.violations.map((v) => v.file),
      });
    }

    return recommendations;
  }
}

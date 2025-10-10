// @ts-nocheck
import { tool } from "@opencode-ai/plugin";
import { createOpencodeClient } from "@opencode-ai/sdk";
import { AnalysisEngine } from "./analyze/engines/index";
import { CacheManager } from "./analyze/cache/manager";
import { AnalysisConfig, AnalysisResult } from "./analyze/types";

function formatOutput(result: AnalysisResult, format: string) {
  if (format === "agent") {
    return createAgentOutput(result);
  }

  if (format === "summary") {
    return createSummaryOutput(result);
  }

  // For detailed format, structure the output for TUI block display
  return createDetailedOutput(result);
}

function createDetailedOutput(result: AnalysisResult) {
  // Structure the output to display nicely as TUI blocks
  return {
    // Main analysis header block
    "📊 Analysis Overview": {
      Mode: result.metadata.mode.toUpperCase(),
      Duration: `${result.metadata.duration}ms`,
      Timestamp: new Date(result.metadata.timestamp).toLocaleString(),
    },

    // Project structure block
    "📁 Project Structure": {
      Files: result.structure?.size?.files || 0,
      Directories: result.structure?.size?.directories || 0,
      "Lines of Code": result.structure?.size?.lines || 0,
      "Key Files": result.structure?.keyFiles?.length || 0,
      Patterns:
        result.structure?.patterns?.map((p) => p.name).join(", ") ||
        "None detected",
    },

    // Dependencies block
    "📦 Dependencies": {
      External: result.dependency?.external?.length || 0,
      Internal: result.dependency?.internal?.length || 0,
      Vulnerabilities: result.dependency?.vulnerabilities?.length || 0,
      "Package Managers":
        [
          ...new Set(
            result.dependency?.external?.map((d) =>
              d.location?.split("/").pop(),
            ) || [],
          ),
        ].join(", ") || "None",
    },

    // Code quality block (if available)
    ...(result.quality && {
      "🎯 Code Quality": {
        "Maintainability Grade": result.quality.maintainability?.grade || "N/A",
        "Maintainability Score": result.quality.maintainability?.score || 0,
        "Technical Debt": result.quality.techDebt?.length || 0,
        "Code Smells": result.quality.codeSmells?.length || 0,
      },
    }),

    // Security block (if available)
    ...(result.security && {
      "🔒 Security": {
        Issues: result.security.issues?.length || 0,
        Secrets: result.security.secrets?.length || 0,
        "Compliance Checks": result.security.compliance?.length || 0,
        Critical:
          result.security.issues?.filter((i) => i.severity === "critical")
            .length || 0,
      },
    }),

    // Performance block (if available)
    ...(result.performance && {
      "⚡ Performance": {
        Bottlenecks: result.performance.bottlenecks?.length || 0,
        Recommendations: result.performance.recommendations?.length || 0,
      },
    }),

    // Architecture block (if available)
    ...(result.architecture && {
      "🏗️ Architecture": {
        Violations: result.architecture.violations?.length || 0,
        Patterns:
          result.architecture.patterns?.map((p) => p.name).join(", ") || "None",
        Suggestions: result.architecture.suggestions?.length || 0,
      },
    }),

    // Recommendations summary
    ...(result.recommendations?.length > 0 && {
      "💡 Recommendations": {
        Total: result.recommendations.length,
        High: result.recommendations.filter((r) => r.priority === "high")
          .length,
        Medium: result.recommendations.filter((r) => r.priority === "medium")
          .length,
        Low: result.recommendations.filter((r) => r.priority === "low").length,
      },
    }),

    // Include raw results for programmatic access
    _raw: result,
  };
}

function createAgentOutput(result: AnalysisResult) {
  let recommendedAgent = "general";
  let reasoning = "General analysis completed";
  let confidence = 0.8;

  if (result.security?.issues?.length > 0) {
    recommendedAgent = "security";
    reasoning = "Security issues detected";
    confidence = 0.9;
  } else if (result.performance?.bottlenecks?.length > 0) {
    recommendedAgent = "devops";
    reasoning = "Performance bottlenecks identified";
    confidence = 0.8;
  } else if (result.architecture?.violations?.length > 0) {
    recommendedAgent = "reviewer";
    reasoning = "Architecture violations found";
    confidence = 0.8;
  } else if (result.quality?.techDebt?.length > 0) {
    recommendedAgent = "language";
    reasoning = "Code quality or architecture issues detected";
    confidence = 0.8;
  }

  return {
    routing: {
      recommendedAgent,
      confidence,
      reasoning,
      alternatives: ["general", "specialist"],
    },
    context: {
      projectType: "unknown",
      technologies: [],
      complexity: "low",
      riskLevel: "low",
      keyAreas: [],
    },
    priorities: [
      {
        agent: recommendedAgent,
        tasks: [],
        urgency: "soon",
        dependencies: [],
      },
    ],
    capabilities: [
      {
        capability: "code-analysis",
        importance: "required",
        agents: ["language", "security"],
      },
    ],
  };
}

function createSummaryOutput(result: AnalysisResult) {
  return {
    overview: {
      mode: result.metadata.mode,
      duration: `${result.metadata.duration}ms`,
      filesAnalyzed: result.structure?.size?.files || 0,
      directoriesFound: result.structure?.size?.directories || 0,
    },
    keyInsights: [],
    criticalIssues: [],
    recommendations: result.recommendations || [],
  };
}

export default tool({
  description:
    "Comprehensive project analysis with multi-dimensional insights displayed as TUI blocks",
  args: {
    mode: tool.schema
      .enum(["quick", "deep", "security", "performance", "architecture"])
      .optional()
      .describe("Analysis mode (default: quick)"),
    scope: tool.schema
      .array(tool.schema.string())
      .optional()
      .describe("Specific paths to analyze"),
    exclude: tool.schema
      .array(tool.schema.string())
      .optional()
      .describe("Patterns to exclude"),
    cache: tool.schema
      .boolean()
      .optional()
      .describe("Use cached results (default: true)"),
    format: tool.schema
      .enum(["detailed", "summary", "agent"])
      .optional()
      .describe("Output format (default: detailed)"),
    autoRoute: tool.schema
      .boolean()
      .optional()
      .describe("Auto-route to recommended agent"),
  },

  async execute(args: any, context: any) {
    const client = createOpencodeClient({
      baseUrl: context.baseUrl || "http://localhost:4096",
    });

    const cache = new CacheManager(context.sessionID);
    const engine = new AnalysisEngine(client, cache);

    const config: AnalysisConfig = {
      mode: args.mode || "quick",
      scope: args.scope || [],
      exclude: args.exclude || ["node_modules", ".git", "dist", "build"],
      useCache: args.cache !== false,
      format: args.format || "detailed",
    };

    const startTime = Date.now();

    try {
      // Log analysis start
      await client.app
        .log({
          body: {
            service: "analyze-tool",
            level: "info",
            message: `🔍 Starting ${config.mode} analysis...`,
          },
        })
        .catch(() => {});

      // Initialize metadata
      if (context.metadata) {
        context.metadata({
          metadata: {
            status: "analyzing",
            mode: config.mode,
            progress: 0,
          },
        });
      }

      // Run analysis
      const result = await engine.analyze(config);

      // Update metadata with results
      if (context.metadata) {
        context.metadata({
          metadata: {
            status: "completed",
            mode: config.mode,
            duration: result.metadata.duration,
            files: result.structure?.size?.files || 0,
            directories: result.structure?.size?.directories || 0,
            lines: result.structure?.size?.lines || 0,
          },
        });
      }

      // Log analysis completion
      await client.app
        .log({
          body: {
            service: "analyze-tool",
            level: "info",
            message: `✅ Analysis completed in ${result.metadata.duration}ms`,
          },
        })
        .catch(() => {});

      // Format output based on requested format
      const output = formatOutput(result, config.format);

      // Auto-route to appropriate agent if requested
      if (config.format === "agent" || args.autoRoute) {
        const routing = createAgentOutput(result);

        await client.app
          .log({
            body: {
              service: "analyze-tool",
              level: "info",
              message: `🤖 Recommended: ${routing.routing.recommendedAgent} - ${routing.routing.reasoning}`,
            },
          })
          .catch(() => {});

        return {
          title: `Analysis Complete - ${routing.routing.recommendedAgent} recommended`,
          metadata: {
            ...result.metadata,
            routing: routing.routing,
          },
          output: routing,
          _raw: result,
        };
      }

      // Escalate critical security issues
      if (result.security?.issues?.some((i) => i.severity === "critical")) {
        await client.app
          .log({
            body: {
              service: "analyze-tool",
              level: "warn",
              message:
                "🚨 CRITICAL SECURITY ISSUES DETECTED - IMMEDIATE ACTION REQUIRED",
            },
          })
          .catch(() => {});
      }

      // Return structured output following OpenCode tool pattern
      return {
        title: `${config.mode.toUpperCase()} Analysis Complete`,
        metadata: {
          ...result.metadata,
          files: result.structure?.size?.files || 0,
          directories: result.structure?.size?.directories || 0,
          lines: result.structure?.size?.lines || 0,
          dependencies: result.dependency?.external?.length || 0,
          techDebt: result.quality?.techDebt?.length || 0,
          securityIssues: result.security?.issues?.length || 0,
          architectureViolations: result.architecture?.violations?.length || 0,
        },
        output: output,
        _raw: result,
      };
    } catch (error) {
      // Update metadata with error
      if (context.metadata) {
        context.metadata({
          metadata: {
            status: "error",
            error: error.message,
            mode: config.mode,
            duration: Date.now() - startTime,
          },
        });
      }

      // Log analysis error
      await client.app
        .log({
          body: {
            service: "analyze-tool",
            level: "error",
            message: `❌ Analysis failed: ${error.message}`,
          },
        })
        .catch(() => {});

      return {
        title: "Analysis Failed",
        metadata: {
          error: error.message,
          mode: config.mode,
          duration: Date.now() - startTime,
        },
        output: {
          "❌ Analysis Failed": {
            Error: error.message,
            Mode: config.mode,
            Duration: `${Date.now() - startTime}ms`,
          },
          _error: {
            message: error.message,
            stack: error.stack,
          },
        },
      };
    }
  },
});

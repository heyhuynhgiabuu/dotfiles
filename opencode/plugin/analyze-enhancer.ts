/**
 * Analyze Tool Enhancer Plugin - Fixed Version
 * Enhances the analyze tool with proper metadata extraction and logging
 */

import type { Plugin } from "@opencode-ai/plugin";

export const AnalyzeEnhancerPlugin: Plugin = async ({
  project,
  client,
  directory,
}) => {
  // Log plugin initialization
  client.app
    .log({
      body: {
        service: "analyze-enhancer",
        level: "info",
        message: `🔧 Analyze Enhancer Plugin loaded for: ${project?.id || directory}`,
      },
    })
    .catch(() => {});

  return {
    "tool.execute.after": async (input, output) => {
      if (input.tool === "analyze") {
        try {
          // The analyze tool output structure - need to extract the actual result
          let analyzeResult: any;

          // Simplified approach: assume the output is the analyze result
          if (typeof output === "object" && output !== null) {
            // If it has the expected structure, use it directly
            if (output.title && output.metadata) {
              analyzeResult = output;
            } else {
              // Try to find the analyze result in common nested structures
              analyzeResult =
                (output as any).result || // result property
                (output as any).data || // data property
                (output as any).response || // response property
                output; // fallback to output itself
            }
          } else if (typeof output === "string") {
            try {
              const parsed = JSON.parse(output);
              // If parsed result has the expected structure, use it
              if (parsed.title && parsed.metadata) {
                analyzeResult = parsed;
              } else {
                analyzeResult = { output: parsed };
              }
            } catch {
              // If it's not JSON, create a simple structure
              analyzeResult = { output: output };
            }
          } else {
            // For any other type, wrap it
            analyzeResult = { output: output };
          }

          // Debug: Log what we found and the raw output structure
          client.app
            .log({
              body: {
                service: "analyze-enhancer",
                level: "debug",
                message: `🔍 Debug: Raw output type: ${typeof output}, keys: ${Object.keys(output || {}).join(", ")}`,
              },
            })
            .catch(() => {});

          client.app
            .log({
              body: {
                service: "analyze-enhancer",
                level: "debug",
                message: `🔍 Debug: Found result structure - title: ${!!analyzeResult?.title}, metadata: ${!!analyzeResult?.metadata}, output: ${!!analyzeResult?.output}`,
              },
            })
            .catch(() => {});

          // Extract metadata from the structured analyze result, with fallback to _raw
          const metadata =
            analyzeResult?.metadata || analyzeResult?.output?._raw?.metadata;
          const rawResult =
            analyzeResult?.output?._raw || analyzeResult?._raw || analyzeResult;

          // Log successful completion
          client.app
            .log({
              body: {
                service: "analyze-enhancer",
                level: "info",
                message: `✅ Analyze tool COMPLETED successfully`,
              },
            })
            .catch(() => {});

          // Log analysis completion with performance metrics
          if (
            metadata &&
            metadata.mode &&
            typeof metadata.duration === "number"
          ) {
            client.app
              .log({
                body: {
                  service: "analyze-enhancer",
                  level: "info",
                  message: `📊 Analysis completed: ${metadata.mode} mode in ${metadata.duration}ms`,
                },
              })
              .catch(() => {});
          } else {
            client.app
              .log({
                body: {
                  service: "analyze-enhancer",
                  level: "info",
                  message: `📊 Analysis completed (metadata extraction attempted)`,
                },
              })
              .catch(() => {});
          }

          // Extract metrics with fallbacks from formatted output, raw result, and metadata
          const metrics = {
            files: 0,
            directories: 0,
            lines: 0,
            dependencies: 0,
            techDebt: 0,
            securityIssues: 0,
            architectureViolations: 0,
          };

          // Try to extract from formatted output first (most reliable)
          const formattedOutput = analyzeResult.output;
          if (formattedOutput && typeof formattedOutput === "object") {
            const formattedStructure = formattedOutput["📁 Project Structure"];
            if (formattedStructure) {
              metrics.files = formattedStructure.Files || 0;
              metrics.directories = formattedStructure.Directories || 0;
              metrics.lines = formattedStructure["Lines of Code"] || 0;
            }

            const formattedDeps = formattedOutput["📦 Dependencies"];
            if (formattedDeps) {
              metrics.dependencies = formattedDeps.External || 0;
            }
          }

          // Fallback to raw result
          if (metrics.files === 0)
            metrics.files = rawResult?.structure?.size?.files ?? 0;
          if (metrics.directories === 0)
            metrics.directories = rawResult?.structure?.size?.directories ?? 0;
          if (metrics.lines === 0)
            metrics.lines = rawResult?.structure?.size?.lines ?? 0;
          if (metrics.dependencies === 0)
            metrics.dependencies = rawResult?.dependency?.external?.length ?? 0;
          if (metrics.techDebt === 0)
            metrics.techDebt = rawResult?.quality?.techDebt?.length ?? 0;
          if (metrics.securityIssues === 0)
            metrics.securityIssues = rawResult?.security?.issues?.length ?? 0;
          if (metrics.architectureViolations === 0)
            metrics.architectureViolations =
              rawResult?.architecture?.violations?.length ?? 0;

          // Final fallback to metadata
          if (metrics.files === 0) metrics.files = metadata?.files ?? 0;
          if (metrics.directories === 0)
            metrics.directories = metadata?.directories ?? 0;
          if (metrics.lines === 0) metrics.lines = metadata?.lines ?? 0;
          if (metrics.dependencies === 0)
            metrics.dependencies = metadata?.dependencies ?? 0;
          if (metrics.techDebt === 0)
            metrics.techDebt = metadata?.techDebt ?? 0;
          if (metrics.securityIssues === 0)
            metrics.securityIssues = metadata?.securityIssues ?? 0;
          if (metrics.architectureViolations === 0)
            metrics.architectureViolations =
              metadata?.architectureViolations ?? 0;

          client.app
            .log({
              body: {
                service: "analyze-enhancer",
                level: "info",
                message: `📈 Project Metrics: ${metrics.files} files, ${metrics.directories} dirs, ${metrics.lines} lines, ${metrics.dependencies} deps, ${metrics.techDebt} tech debt, ${metrics.securityIssues} security issues, ${metrics.architectureViolations} arch violations`,
              },
            })
            .catch(() => {});

          // Log detailed analysis results from raw data if available
          if (rawResult) {
            // Log structure analysis details
            if (rawResult.structure?.size) {
              const structSize = rawResult.structure.size;
              client.app
                .log({
                  body: {
                    service: "analyze-enhancer",
                    level: "info",
                    message: `🏗️ Structure Analysis: ${structSize.files} files, ${structSize.directories} directories, ${structSize.lines} lines of code, ${structSize.bytes} bytes`,
                  },
                })
                .catch(() => {});
            }

            // Log dependency analysis details
            if (rawResult.dependency) {
              const deps = rawResult.dependency;
              client.app
                .log({
                  body: {
                    service: "analyze-enhancer",
                    level: "info",
                    message: `📦 Dependencies: ${deps.external?.length || 0} external, ${deps.internal?.length || 0} internal, ${deps.vulnerabilities?.length || 0} vulnerabilities`,
                  },
                })
                .catch(() => {});
            }

            // Log quality analysis details
            if (rawResult.quality) {
              const quality = rawResult.quality;
              client.app
                .log({
                  body: {
                    service: "analyze-enhancer",
                    level: "info",
                    message: `🎯 Code Quality: ${quality.maintainability?.grade || "N/A"} grade (${quality.maintainability?.score || 0} score), ${quality.techDebt?.length || 0} tech debt items, ${quality.codeSmells?.length || 0} code smells`,
                  },
                })
                .catch(() => {});
            }

            // Log security analysis details
            if (rawResult.security) {
              const security = rawResult.security;
              const criticalIssues =
                security.issues?.filter((i: any) => i.severity === "critical")
                  ?.length || 0;
              client.app
                .log({
                  body: {
                    service: "analyze-enhancer",
                    level: "info",
                    message: `🔒 Security: ${security.issues?.length || 0} total issues (${criticalIssues} critical), ${security.secrets?.length || 0} secrets detected, ${security.compliance?.length || 0} compliance checks`,
                  },
                })
                .catch(() => {});
            }

            // Log performance analysis details
            if (rawResult.performance) {
              const perf = rawResult.performance;
              client.app
                .log({
                  body: {
                    service: "analyze-enhancer",
                    level: "info",
                    message: `⚡ Performance: ${perf.bottlenecks?.length || 0} bottlenecks, ${perf.recommendations?.length || 0} optimization recommendations`,
                  },
                })
                .catch(() => {});
            }

            // Log architecture analysis details
            if (rawResult.architecture) {
              const arch = rawResult.architecture;
              client.app
                .log({
                  body: {
                    service: "analyze-enhancer",
                    level: "info",
                    message: `🏗️ Architecture: ${arch.patterns?.length || 0} patterns detected, ${arch.violations?.length || 0} violations, ${arch.suggestions?.length || 0} suggestions`,
                  },
                })
                .catch(() => {});
            }

            // Log recommendations
            if (
              rawResult.recommendations &&
              rawResult.recommendations.length > 0
            ) {
              const highPriority =
                rawResult.recommendations.filter(
                  (r: any) => r.priority === "high",
                )?.length || 0;
              const mediumPriority =
                rawResult.recommendations.filter(
                  (r: any) => r.priority === "medium",
                )?.length || 0;
              const lowPriority =
                rawResult.recommendations.filter(
                  (r: any) => r.priority === "low",
                )?.length || 0;

              client.app
                .log({
                  body: {
                    service: "analyze-enhancer",
                    level: "info",
                    message: `💡 Recommendations: ${rawResult.recommendations.length} total (${highPriority} high, ${mediumPriority} medium, ${lowPriority} low priority)`,
                  },
                })
                .catch(() => {});
            }
          }

          // Check for routing recommendations
          const routing = metadata?.routing;
          if (routing?.recommendedAgent) {
            client.tui
              .showToast({
                body: {
                  message: `🤖 Recommended: ${routing.recommendedAgent} (${Math.round(routing.confidence * 100)}% confidence)`,
                  variant: "info",
                },
              })
              .catch(() => {});

            client.app
              .log({
                body: {
                  service: "analyze-enhancer",
                  level: "info",
                  message: `🎯 Agent recommendation: ${routing.recommendedAgent} - ${routing.reasoning} (confidence: ${routing.confidence})`,
                },
              })
              .catch(() => {});
          }

          // Log comprehensive summary with full metadata
          client.app
            .log({
              body: {
                service: "analyze-enhancer",
                level: "info",
                message: `📈 FULL METADATA EXTRACTED: ${JSON.stringify(
                  {
                    // Basic metadata
                    title: analyzeResult?.title,
                    mode: metadata?.mode,
                    duration: metadata?.duration,
                    timestamp: metadata?.timestamp,
                    scope: metadata?.scope,
                    exclude: metadata?.exclude,
                    version: metadata?.version,

                    // Project metrics
                    files: metrics.files,
                    directories: metrics.directories,
                    lines: metrics.lines,
                    dependencies: metrics.dependencies,
                    techDebt: metrics.techDebt,
                    securityIssues: metrics.securityIssues,
                    architectureViolations: metrics.architectureViolations,

                    // Raw analysis data availability
                    hasRawData: !!rawResult,
                    hasStructure: !!rawResult?.structure,
                    hasDependencies: !!rawResult?.dependencies,
                    hasQuality: !!rawResult?.quality,
                    hasSecurity: !!rawResult?.security,
                    hasPerformance: !!rawResult?.performance,
                    hasArchitecture: !!rawResult?.architecture,
                    hasRecommendations: !!(
                      rawResult?.recommendations?.length > 0
                    ),

                    // Routing info
                    hasRouting: !!routing,
                    recommendedAgent: routing?.recommendedAgent,
                    routingConfidence: routing?.confidence,

                    // Complete metadata object
                    fullMetadata: metadata,

                    // Output structure info
                    outputType: typeof analyzeResult?.output,
                    hasOutput: !!analyzeResult?.output,
                  },
                  null,
                  2,
                )}`,
              },
            })
            .catch(() => {});
        } catch (error) {
          // Log parsing error
          client.app
            .log({
              body: {
                service: "analyze-enhancer",
                level: "error",
                message: `❌ Failed to parse analyze output: ${(error as Error).message}`,
              },
            })
            .catch(() => {});
        }
      }
    },

    event: async ({ event }) => {
      try {
        // Listen for session idle events
        if (event.type === "session.idle") {
          client.app
            .log({
              body: {
                service: "analyze-enhancer",
                level: "info",
                message:
                  "💤 Session idle - analysis tools ready for next operation",
              },
            })
            .catch(() => {});
        }

        // Listen for file changes that might trigger re-analysis
        if (event.type === "file.edited") {
          client.app
            .log({
              body: {
                service: "analyze-enhancer",
                level: "info",
                message: `📝 File edited: ${event.properties.file} - consider re-running analysis`,
              },
            })
            .catch(() => {});
        }
      } catch (error) {
        client.app
          .log({
            body: {
              service: "analyze-enhancer",
              level: "error",
              message: `❌ Event handling failed: ${(error as Error).message}`,
            },
          })
          .catch(() => {});
      }
    },
  };
};

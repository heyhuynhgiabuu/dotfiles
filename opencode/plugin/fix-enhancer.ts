/**
 * Fix Tool Enhancer Plugin
 * Enhances the fix tool with proper metadata extraction and logging
 */

import type { Plugin } from "@opencode-ai/plugin";

export const FixEnhancerPlugin: Plugin = async ({
  project,
  client,
  directory,
}) => {
  // Log plugin initialization
  client.app
    .log({
      body: {
        service: "fix-enhancer",
        level: "info",
        message: `🔧 Fix Enhancer Plugin loaded for: ${project?.id || directory}`,
      },
    })
    .catch(() => {});

  return {
    "tool.execute.before": async (input) => {
      if (input.tool === "fix") {
        try {
          // Simple startup log - we'll get the actual parameters from the output
          client.app
            .log({
              body: {
                service: "fix-enhancer",
                level: "info",
                message: `🚀 Fix tool STARTING...`,
              },
            })
            .catch(() => {});
        } catch (error) {
          client.app
            .log({
              body: {
                service: "fix-enhancer",
                level: "error",
                message: `❌ Failed to log fix tool start: ${(error as Error).message}`,
              },
            })
            .catch(() => {});
        }
      }
    },

    "tool.execute.after": async (input, output) => {
      if (input.tool === "fix") {
        try {
          // Extract fix result from output
          let fixResult: any;

          // Handle different output structures
          if (typeof output === "object" && output !== null) {
            // If it has the expected structure, use it directly
            if (output.title && output.metadata) {
              fixResult = output;
            } else {
              // Try to find the fix result in common nested structures
              fixResult =
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
                fixResult = parsed;
              } else {
                fixResult = { output: parsed };
              }
            } catch {
              // If it's not JSON, create a simple structure
              fixResult = { output: output };
            }
          } else {
            // For any other type, wrap it
            fixResult = { output: output };
          }

          // Debug: Log what we found and the raw output structure
          client.app
            .log({
              body: {
                service: "fix-enhancer",
                level: "info",
                message: `🔍 Debug: Raw output type: ${typeof output}, keys: ${Object.keys(output || {}).join(", ")}`,
              },
            })
            .catch(() => {});

          client.app
            .log({
              body: {
                service: "fix-enhancer",
                level: "info",
                message: `🔍 Debug: Found result structure - title: ${!!fixResult?.title}, metadata: ${!!fixResult?.metadata}, output: ${!!fixResult?.output}`,
              },
            })
            .catch(() => {});

          client.app
            .log({
              body: {
                service: "fix-enhancer",
                level: "info",
                message: `🔍 Debug: fixResult.title="${fixResult?.title}", fixResult.metadata.type="${fixResult?.metadata?.type}"`,
              },
            })
            .catch(() => {});

          // Extract metadata from the fix result - handle nested structure
          let metadata = fixResult?.metadata || {};
          let outputData = fixResult?.output || {};

          // If the main result doesn't have metadata, check if it's the raw tool output
          if (!metadata.type && fixResult?.title && fixResult?.metadata) {
            // Direct tool output structure
            metadata = fixResult.metadata;
            outputData = fixResult.output || {};
          }

          // Now that we have the output, log the actual parameters that were used
          if (metadata.type) {
            client.app
              .log({
                body: {
                  service: "fix-enhancer",
                  level: "info",
                  message: `🎯 Fix tool EXECUTED: type=${metadata.type}, files=${metadata.filesProcessed || 0} processed, dryRun=${metadata.dryRun ?? true}, backup=${metadata.backup ?? false}`,
                },
              })
              .catch(() => {});
          }

          // Log successful completion
          client.app
            .log({
              body: {
                service: "fix-enhancer",
                level: "info",
                message: `✅ Fix tool COMPLETED successfully`,
              },
            })
            .catch(() => {});

          // Log fix completion with performance metrics
          if (
            metadata &&
            metadata.type &&
            typeof metadata.duration === "number"
          ) {
            client.app
              .log({
                body: {
                  service: "fix-enhancer",
                  level: "info",
                  message: `🔧 Fix completed: ${metadata.type} fixes in ${metadata.duration}ms`,
                },
              })
              .catch(() => {});
          } else {
            client.app
              .log({
                body: {
                  service: "fix-enhancer",
                  level: "info",
                  message: `🔧 Fix completed (metadata extraction attempted)`,
                },
              })
              .catch(() => {});
          }

          // Extract fix metrics directly from metadata (most reliable source)
          const metrics = {
            type: metadata.type || "unknown",
            filesProcessed: metadata.filesProcessed || 0,
            filesChanged: metadata.filesChanged || 0,
            changesApplied: metadata.changesApplied || 0,
            duration: metadata.duration || 0,
            dryRun: metadata.dryRun ?? true,
            backup: metadata.backup ?? false,
            errors: metadata.errors || 0,
          };

          // Log fix metrics
          client.app
            .log({
              body: {
                service: "fix-enhancer",
                level: "info",
                message: `📊 Fix Metrics: ${metrics.type} - ${metrics.filesProcessed} files processed, ${metrics.filesChanged} files changed, ${metrics.changesApplied} changes applied, ${metrics.errors} errors`,
              },
            })
            .catch(() => {});

          // Log performance metrics
          client.app
            .log({
              body: {
                service: "fix-enhancer",
                level: "info",
                message: `⚡ Performance: ${metrics.duration}ms duration, ${metrics.dryRun ? "DRY RUN" : "APPLIED"}, backup: ${metrics.backup}`,
              },
            })
            .catch(() => {});

          // Log detailed fix results if available
          if (outputData) {
            // Log summary
            if (outputData.summary) {
              client.app
                .log({
                  body: {
                    service: "fix-enhancer",
                    level: "info",
                    message: `📝 Summary: ${outputData.summary}`,
                  },
                })
                .catch(() => {});
            }

            // Log changes applied
            if (outputData.changes && Array.isArray(outputData.changes)) {
              const changesByType = outputData.changes.reduce(
                (acc: any, change: any) => {
                  const file = change.file || "unknown";
                  if (!acc[file]) acc[file] = [];
                  acc[file].push(change.description || "No description");
                  return acc;
                },
                {},
              );

              Object.entries(changesByType).forEach(([file, descriptions]) => {
                client.app
                  .log({
                    body: {
                      service: "fix-enhancer",
                      level: "info",
                      message: `📄 ${file}: ${(descriptions as string[]).join(", ")}`,
                    },
                  })
                  .catch(() => {});
              });
            }

            // Log errors if any
            if (
              outputData.errors &&
              Array.isArray(outputData.errors) &&
              outputData.errors.length > 0
            ) {
              outputData.errors.forEach((error: any) => {
                client.app
                  .log({
                    body: {
                      service: "fix-enhancer",
                      level: "warn",
                      message: `⚠️ ${error.type || "Error"}: ${error.message || "Unknown error"} ${error.file ? `in ${error.file}` : ""} ${error.suggestion ? `- ${error.suggestion}` : ""}`,
                    },
                  })
                  .catch(() => {});
              });
            }

            // Log success message if no errors
            if (!outputData.errors || outputData.errors.length === 0) {
              client.app
                .log({
                  body: {
                    service: "fix-enhancer",
                    level: "info",
                    message: `🎉 Fix operation completed successfully with no errors!`,
                  },
                })
                .catch(() => {});
            }
          }

          // Show user-friendly toast notification
          if (metrics.changesApplied > 0 && !metrics.dryRun) {
            client.tui
              .showToast({
                body: {
                  message: `🔧 Applied ${metrics.changesApplied} ${metrics.type} fixes to ${metrics.filesChanged} files`,
                  variant: "success",
                },
              })
              .catch(() => {});
          } else if (metrics.dryRun && metrics.changesApplied > 0) {
            client.tui
              .showToast({
                body: {
                  message: `👀 Preview: Would apply ${metrics.changesApplied} ${metrics.type} fixes to ${metrics.filesChanged} files`,
                  variant: "info",
                },
              })
              .catch(() => {});
          } else if (
            metrics.filesProcessed > 0 &&
            metrics.changesApplied === 0
          ) {
            client.tui
              .showToast({
                body: {
                  message: `✨ No ${metrics.type} issues found in ${metrics.filesProcessed} files`,
                  variant: "success",
                },
              })
              .catch(() => {});
          }

          // Log comprehensive summary with full metadata
          client.app
            .log({
              body: {
                service: "fix-enhancer",
                level: "info",
                message: `📈 FULL FIX METADATA: ${JSON.stringify(
                  {
                    // Basic metadata
                    title: fixResult?.title || "",
                    type: metadata.type || "unknown",
                    duration: metadata.duration || 0,
                    timestamp: new Date().toISOString(),

                    // Fix metrics
                    filesProcessed: metadata.filesProcessed || 0,
                    filesChanged: metadata.filesChanged || 0,
                    changesApplied: metadata.changesApplied || 0,
                    errors: metadata.errors || 0,
                    dryRun: metadata.dryRun ?? true,
                    backup: metadata.backup ?? false,

                    // Input parameters (extracted from metadata)
                    inputFiles: metadata?.files || "auto-detect",

                    // Output structure info
                    hasOutput: !!outputData,
                    hasChanges: !!(outputData.changes?.length > 0),
                    hasErrors: !!(outputData.errors?.length > 0),
                    hasSummary: !!outputData.summary,

                    // Complete data for debugging
                    fullMetadata: metadata,
                    fullOutput: fixResult,
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
                service: "fix-enhancer",
                level: "error",
                message: `❌ Failed to parse fix output: ${(error as Error).message}`,
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
                service: "fix-enhancer",
                level: "info",
                message: "💤 Session idle - fix tools ready for next operation",
              },
            })
            .catch(() => {});
        }

        // Listen for file changes that might trigger re-fixing
        if (event.type === "file.edited") {
          client.app
            .log({
              body: {
                service: "fix-enhancer",
                level: "info",
                message: `📝 File edited: ${event.properties.file} - consider re-running fix`,
              },
            })
            .catch(() => {});
        }
      } catch (error) {
        client.app
          .log({
            body: {
              service: "fix-enhancer",
              level: "error",
              message: `❌ Event handling failed: ${(error as Error).message}`,
            },
          })
          .catch(() => {});
      }
    },
  };
};

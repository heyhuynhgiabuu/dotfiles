import type { Plugin } from "@opencode-ai/plugin";
import type { VectorCodeQueryResult, VectorCodeQueryOptions, VectorCodeIndexOptions } from "../types.d.ts";

/**
 * VectorCode CLI Integration Plugin for OpenCode
 * 
 * This plugin provides seamless integration with VectorCode CLI for:
 * - Querying indexed code context
 * - Indexing new files
 * - Getting project context
 */

// Utility function to execute VectorCode CLI commands safely
async function executeVectorCodeCommand($: any, command: string[]): Promise<VectorCodeQueryResult> {
  try {
    // Check if vectorcode CLI is available
    const versionCheck = await $`vectorcode version`.quiet().nothrow();
    if (versionCheck.exitcode !== 0) {
      return {
        success: false,
        error: "VectorCode CLI not found. Please install VectorCode CLI first: https://github.com/GiovanniKaaijk/vectorcode",
        command: command.join(' ')
      };
    }

    // Execute the command with structured output
    const result = await $`vectorcode ${command} --pipe --no_stderr`.quiet().nothrow();
    
    if (result.exitcode !== 0) {
      return {
        success: false,
        error: `VectorCode command failed: ${result.stderr || 'Unknown error'}`,
        command: command.join(' ')
      };
    }

    // Parse JSON output if available
    let data: any = result.stdout;
    try {
      data = JSON.parse(result.stdout);
    } catch {
      // If not JSON, return as string
      data = result.stdout.trim();
    }

    return {
      success: true,
      data,
      command: command.join(' ')
    };
  } catch (error) {
    return {
      success: false,
      error: `Execution error: ${error instanceof Error ? error.message : String(error)}`,
      command: command.join(' ')
    };
  }
}

// Get current working directory for project root detection
async function getCurrentProjectRoot($: any): Promise<string> {
  try {
    const result = await $`pwd`.quiet();
    return result.stdout.trim();
  } catch {
    return process.cwd();
  }
}

// Command: Get VectorCode Context
async function getVectorCodeContext($: any, projectRoot?: string): Promise<VectorCodeQueryResult> {
  const root = projectRoot || await getCurrentProjectRoot($);
  
  // Get project prompts and collections info
  const promptsResult = await executeVectorCodeCommand($, [
    'prompts', 'query', '--project_root', root
  ]);
  
  if (!promptsResult.success) {
    return promptsResult;
  }

  const collectionsResult = await executeVectorCodeCommand($, [
    'ls', '--project_root', root
  ]);

  return {
    success: true,
    data: {
      projectRoot: root,
      prompts: promptsResult.data,
      collections: collectionsResult.success ? collectionsResult.data : [],
      timestamp: new Date().toISOString()
    },
    command: 'getVectorCodeContext'
  };
}

// Command: Query VectorCode
async function queryVectorCode($: any, options: VectorCodeQueryOptions): Promise<VectorCodeQueryResult> {
  const { query, number = 10, include = ['path', 'document'], exclude = [], projectRoot } = options;
  const root = projectRoot || await getCurrentProjectRoot($);

  if (!query.trim()) {
    return {
      success: false,
      error: "Query cannot be empty",
      command: 'queryVectorCode'
    };
  }

  const command = [
    'query',
    '--project_root', root,
    '--number', number.toString(),
    '--include', ...include
  ];

  if (exclude.length > 0) {
    command.push('--exclude', ...exclude);
  }

  command.push(query);

  const result = await executeVectorCodeCommand($, command);
  
  if (result.success) {
    result.data = {
      query,
      results: result.data,
      options: { number, include, exclude },
      projectRoot: root,
      timestamp: new Date().toISOString()
    };
  }

  return result;
}

// Command: Index VectorCode
async function indexVectorCode($: any, options: VectorCodeIndexOptions): Promise<VectorCodeQueryResult> {
  const { filePaths, recursive = false, includeHidden = false, force = false, projectRoot } = options;
  const root = projectRoot || await getCurrentProjectRoot($);

  if (!filePaths || filePaths.length === 0) {
    return {
      success: false,
      error: "File paths cannot be empty",
      command: 'indexVectorCode'
    };
  }

  const command = [
    'vectorise',
    '--project_root', root
  ];

  if (recursive) command.push('--recursive');
  if (includeHidden) command.push('--include-hidden');
  if (force) command.push('--force');

  command.push(...filePaths);

  const result = await executeVectorCodeCommand($, command);
  
  if (result.success) {
    result.data = {
      indexedPaths: filePaths,
      options: { recursive, includeHidden, force },
      projectRoot: root,
      result: result.data,
      timestamp: new Date().toISOString()
    };
  }

  return result;
}

// Main plugin function
const plugin: Plugin = async ({ app, client, $ }) => {
  // Store arguments from 'before' hook to use in 'after' hook
  const toolArgs = new Map<string, any>();

  return {
    // Handle tool execution for our custom commands - capture arguments
    "tool.execute.before": async ({ tool, sessionID, callID }, output) => {
      if (tool.startsWith('vectorcode.') || 
          tool === 'getVectorCodeContext' || 
          tool === 'queryVectorCode' || 
          tool === 'indexVectorCode') {
        // Store arguments for use in after hook
        const key = `${sessionID}-${callID}`;
        toolArgs.set(key, output.args);
        console.log(`[VectorCode Plugin] Executing ${tool} for session ${sessionID}`);
      }
    },

    "tool.execute.after": async ({ tool, sessionID, callID }, output) => {
      // Skip if not our command
      if (!(tool.startsWith('vectorcode.') || 
            tool === 'getVectorCodeContext' || 
            tool === 'queryVectorCode' || 
            tool === 'indexVectorCode')) {
        return;
      }

      let result: VectorCodeQueryResult;
      const key = `${sessionID}-${callID}`;
      const args = toolArgs.get(key) || {};

      try {
        switch (tool) {
          case 'vectorcode.getContext':
          case 'getVectorCodeContext':
            result = await getVectorCodeContext($, args?.projectRoot);
            break;

          case 'vectorcode.query':
          case 'queryVectorCode':
            if (!args?.query) {
              result = {
                success: false,
                error: "Query parameter is required",
                command: tool
              };
            } else {
              result = await queryVectorCode($, args);
            }
            break;

          case 'vectorcode.index':
          case 'indexVectorCode':
            if (!args?.filePaths) {
              result = {
                success: false,
                error: "filePaths parameter is required",
                command: tool
              };
            } else {
              result = await indexVectorCode($, args);
            }
            break;

          default:
            // Not our command, skip
            return;
        }

        // Update output with our result
        output.title = result.success ? `✅ ${tool}` : `❌ ${tool}`;
        output.output = JSON.stringify(result, null, 2);
        output.metadata = {
          success: result.success,
          command: result.command,
          timestamp: new Date().toISOString()
        };

      } catch (error) {
        output.title = `❌ ${tool} (Error)`;
        output.output = JSON.stringify({
          success: false,
          error: `Plugin execution error: ${error instanceof Error ? error.message : String(error)}`,
          command: tool
        }, null, 2);
        output.metadata = {
          success: false,
          error: true,
          timestamp: new Date().toISOString()
        };
      } finally {
        // Clean up stored arguments
        toolArgs.delete(key);
      }
    },

    // Handle events (optional)
    event: async ({ event }) => {
      if (event.type === "session.start") {
        console.log("[VectorCode Plugin] Session started - VectorCode integration ready");
      }
    }
  };
};

export default plugin;
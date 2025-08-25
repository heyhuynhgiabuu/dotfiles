/**
 * Security Protection Plugin - Following Official OpenCode Example
 * Prevents opencode from reading sensitive files
 */
export const EnvProtection = async ({ client, $ }) => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool === "read" && output.args.filePath) {
        const filePath = output.args.filePath.toLowerCase();
        
        // Block sensitive files (following official example pattern)
        if (filePath.includes(".env") || 
            filePath.includes("secret") || 
            filePath.includes("private") ||
            filePath.includes("password") ||
            filePath.includes("token")) {
          
          console.warn(`🔒 Security: Blocked read of ${output.args.filePath}`);
          throw new Error("Blocked: Attempted to read sensitive file");
        }
      }
    }
  };
};
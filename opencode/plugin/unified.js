/**
 * OpenCode Unified Dotfiles Plugin - v0.6.x Compatible
 * 
 * FEATURES:
 * - Security: Blocks reads of .env/secrets/keys/tokens/credentials files
 * - Notifications: Cross-platform desktop alerts on session completion
 * 
 * ARCHITECTURE:
 * - v0.6.x plugin API: project, client, $, directory, worktree
 * - Uses official plugin hooks: tool.execute.before, event
 * - Cross-platform compatible (macOS osascript, Linux notify-send)
 * - KISS principle: Essential functionality only
 * 
 * BREAKING CHANGES v0.6.x:
 * - Plugin now receives { project, client, $, directory, worktree }
 * - "app" concept removed, replaced with "project"
 * - Storage events removed (event tracking still works)
 */

export const UnifiedDotfilesPlugin = async ({ project, client: _client, $, directory }) => {
  let lastMessage = { text: null };

  // Log plugin initialization with correct project info
  console.log(`🚀 Unified Plugin loaded for project: ${project?.name || directory || 'unknown'}`);
  
  // Sensitive file patterns
  const BLOCKED_PATTERNS = [
    '.env', 'secret', 'private', 'password', 'token', 'key', 'credential'
  ];

  const isSensitiveFile = (filePath) => {
    if (!filePath) return false;
    const path = filePath.toLowerCase();
    return BLOCKED_PATTERNS.some(pattern => path.includes(pattern));
  };

  // Extract summary from text
  const extractSummary = (text) => {
    if (!text) return null;
    const lines = text.split(/\r?\n/).filter(l => l.trim());
    if (!lines.length) return null;

    // Look for summary pattern
    for (let i = Math.max(0, lines.length - 3); i < lines.length; i++) {
      const match = lines[i].match(/^(?:[*\-]\s*)?(?:summary|Summary):\s*(.+)$/i);
      if (match && match[1].trim().length > 2) {
        return match[1].trim().slice(0, 100);
      }
    }
    return lines[lines.length - 1].slice(0, 80);
  };

  // Send notification
  const sendNotification = async (summary) => {
    try {
      if (process.platform === "darwin") {
        await $`osascript -e 'display notification "${summary}" with title "opencode"'`;
      } else {
        await $`notify-send 'opencode' '${summary.replace(/'/g, "'\\''")}'`;
      }
    } catch (err) {
      // Silent fail
    }
  };

  return {
    // Security
    "tool.execute.before": async (input, output) => {
      if (input.tool === "read" && isSensitiveFile(output.args.filePath)) {
        console.warn(`🔒 Security: Blocked read of ${output.args.filePath}`);
        throw new Error("Blocked: Attempted to read sensitive file");
      }
    },

    // Notifications
    event: async ({ event }) => {
      // Track messages
      if (event.type === "message.part.updated" && event.properties.part.type === "text") {
        lastMessage.text = event.properties.part.text;
      }

      // Send notification on completion
      if (event.type === "session.idle") {
        const summary = extractSummary(lastMessage.text) || "Session completed";
        await sendNotification(summary);
      }
    },
  };
};
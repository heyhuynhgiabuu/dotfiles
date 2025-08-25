/**
 * Simple Notification Plugin - Following Official OpenCode Example
 * Cross-platform session completion notifications
 */
export const NotificationPlugin = async ({ client, $ }) => {
  let lastMessage = { text: null };

  return {
    event: async ({ event }) => {
      // Track message for summary
      if (event.type === "message.part.updated" && event.properties.part.type === "text") {
        lastMessage.text = event.properties.part.text;
      }

      // Send notification on session completion (following official example)
      if (event.type === "session.idle") {
        const summary = extractSummary(lastMessage.text) ?? "Session completed!";
        
        try {
          if (process.platform === "darwin") {
            // macOS notifications
            await $`say "Hey man, done!"`;
            await $`osascript -e 'display notification ${JSON.stringify(summary)} with title "opencode"'`;
            await $`afplay /System/Library/Sounds/Glass.aiff`;
          } else {
            // Linux notifications  
            await $`canberra-gtk-play --id=message`;
            await $`notify-send 'opencode' '${summary.replace(/'/g, "'\\''")}'`;
          }
        } catch (err) {
          // Ignore notification errors silently
        }
      }
    },
  };
};

function extractSummary(text) {
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

  // Fallback to last non-empty line
  return lines[lines.length - 1].slice(0, 80);
}
/**
 * OpenCode Notification Plugin
 * Sends notifications on session completion with summary detection
 */

export const NotificationPlugin = async ({ project, client, $, directory }) => {
  await client.app.log({
    body: {
      service: "notification-plugin",
      level: "info",
      message: `🔔 Notification Plugin loaded for: ${project?.name || directory}`,
    },
  });

  // EXACT summary extraction - no fancy logic
  const extractSummary = (text) => {
    if (!text) return "Session completed";

    const lines = text.split(/\r?\n/);

    // Get the very last non-empty line
    for (let i = lines.length - 1; i >= 0; i--) {
      const line = lines[i].trim();
      if (line.length === 0) continue;

      // ONLY match if the line starts EXACTLY with "Summary:"
      if (line.startsWith("Summary: ")) {
        const summary = line.substring(9).trim(); // Remove "Summary: "
        return summary || "Session completed";
      }

      // If we hit a non-empty line that's not a summary, stop looking
      break;
    }

    return "Session completed";
  };

  const sendNotification = async (summary) => {
    try {
      // Validate summary
      if (!summary || summary.trim().length < 3) {
        summary = "Session completed";
      }

      // Simple truncation at word boundary
      if (summary.length > 80) {
        summary = summary.substring(0, 77) + "...";
      }

      await client.app.log({
        body: {
          service: "notification-plugin",
          level: "debug",
          message: `📤 Sending notification: "${summary}"`,
        },
      });

      // Use the official pattern from docs
      if (process.platform === "darwin") {
        await $`osascript -e 'display notification "${summary}" with title "opencode"'`;
      } else {
        await $`notify-send 'opencode' '${summary.replace(/'/g, "'\\''")}'`;
      }
    } catch (error) {
      await client.app.log({
        body: {
          service: "notification-plugin",
          level: "error",
          message: `❌ Notification failed: ${error.message}`,
        },
      });
    }
  };

  // Store last message for summary extraction
  let lastMessage = null;

  return {
    event: async ({ event }) => {
      // Capture message updates
      if (
        event.type === "message.part.updated" &&
        event.properties?.part?.type === "text"
      ) {
        lastMessage = event.properties.part.text;
        return;
      }

      // Send notification on session idle
      if (event.type === "session.idle") {
        await client.app.log({
          body: {
            service: "notification-plugin",
            level: "debug",
            message: `📄 Raw message text: "${lastMessage?.substring(0, 200) || "empty"}"`,
          },
        });

        // Show last few lines for debugging
        const lines = lastMessage?.split(/\r?\n/) || [];
        const lastLines = lines.slice(-3).filter((l) => l.trim());
        await client.app.log({
          body: {
            service: "notification-plugin",
            level: "debug",
            message: `📝 Last lines: ${lastLines.map((l) => `"${l.substring(0, 50)}"`).join(" | ")}`,
          },
        });

        const summary = extractSummary(lastMessage);

        await client.app.log({
          body: {
            service: "notification-plugin",
            level: "info",
            message: `🎯 Session completed: ${summary}`,
          },
        });

        await sendNotification(summary);
      }
    },
  };
};

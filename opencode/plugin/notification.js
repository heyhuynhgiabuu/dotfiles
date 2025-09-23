/**
 * OpenCode Notification Plugin - v0.10.4 Compatible
 * Fixed for current OpenCode API
 */

export const NotificationPlugin = async ({ project, client, $, directory }) => {
  // Log plugin initialization (non-blocking - don't await during init)
  client.app
    .log({
      body: {
        service: "notification-plugin",
        level: "info",
        message: `🔔 Notification Plugin loaded for: ${project?.name || directory}`,
      },
    })
    .catch(() => {}); // Non-blocking with error handling

  const extractSummary = (text) => {
    if (!text) return null;
    const lines = text.split(/\r?\n/);
    for (let i = lines.length - 1; i >= 0; i--) {
      const line = lines[i].trim();
      if (line.length === 0) continue;
      if (line.startsWith("Summary: ")) {
        return line.substring(9).trim().slice(0, 100) || null;
      }
      break;
    }
    return null;
  };

  const notify = async (summary) => {
    if (!summary || summary.length < 3) return;

    try {
      // Use OpenCode toast notification (proper SDK way)
      client.tui
        .showToast({
          body: { message: summary, variant: "success" },
        })
        .catch(() => {});

      // Also use native notification as backup
      if (process.platform === "darwin") {
        $`osascript -e 'display notification "${summary}" with title "OpenCode"'`.catch(
          () => {},
        );
        // Play sound asynchronously to avoid blocking
        $`afplay /System/Library/Sounds/Glass.aiff`.catch(() => {});
      } else {
        // Linux notification
        $`notify-send "OpenCode" "${summary}"`.catch(() => {});
        $`paplay /usr/share/sounds/alsa/Front_Right.wav`.catch(() => {});
      }

      // Log success (non-blocking)
      client.app
        .log({
          body: {
            service: "notification-plugin",
            level: "info",
            message: `✅ Notification sent: ${summary.slice(0, 50)}...`,
          },
        })
        .catch(() => {});
    } catch (error) {
      // Log error (non-blocking)
      client.app
        .log({
          body: {
            service: "notification-plugin",
            level: "warn",
            message: `⚠️ Notification failed: ${error.message}`,
          },
        })
        .catch(() => {});
    }
  };

  // Event throttling + deduplication
  let lastMessage = { text: null, time: 0 };
  let processedEvents = new Set();

  return {
    event: async ({ event }) => {
      try {
        const now = Date.now();

        if (
          event.type === "message.part.updated" &&
          event.properties?.part?.type === "text"
        ) {
          // Throttle updates to every 5 seconds
          if (now - lastMessage.time > 5000) {
            lastMessage = { text: event.properties.part.text, time: now };
          }
          return;
        }

        if (event.type === "session.idle") {
          const eventId = `${event.type}-${now}`;
          if (processedEvents.has(eventId)) return;
          processedEvents.add(eventId);

          const summary =
            extractSummary(lastMessage.text) || "Session completed";
          await notify(summary);

          // Cleanup processed events to prevent memory leak
          if (processedEvents.size > 10) {
            processedEvents.clear();
          }
        }
      } catch (error) {
        // Log event handling errors (non-blocking)
        client.app
          .log({
            body: {
              service: "notification-plugin",
              level: "error",
              message: `❌ Event handling failed: ${error.message}`,
            },
          })
          .catch(() => {});
      }
    },
  };
};

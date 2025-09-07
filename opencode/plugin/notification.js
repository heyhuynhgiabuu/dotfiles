/**
 * OpenCode Notification Plugin - v0.6.5 SDK Enhanced
 * Uses new toast API + proper event handling
 */

export const NotificationPlugin = async ({ client, $ }) => {
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
      // Toast + sound
      await client.tui.showToast({
        body: { message: summary, variant: "success" },
      });

      // Just play sound
      if (process.platform === "darwin") {
        await $`afplay /System/Library/Sounds/Glass.aiff`;
      } else {
        await $`paplay /usr/share/sounds/alsa/Front_Right.wav 2>/dev/null || true`;
      }
    } catch {}
  };

  // Event throttling + deduplication
  let lastMessage = { text: null, time: 0 };
  let processedEvents = new Set();

  return {
    event: async ({ event }) => {
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

        const summary = extractSummary(lastMessage.text) || "Session completed";
        await notify(summary);

        // Cleanup processed events to prevent memory leak
        if (processedEvents.size > 10) {
          processedEvents.clear();
        }
      }
    },
  };
};

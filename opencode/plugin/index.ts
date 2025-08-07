import type { Plugin, Event } from "@opencode-ai/plugin";
import vectorcodePlugin from "./plugins/vectorcode/dist/index.js";

const plugin: Plugin = async (ctx) => {
  let lastMessage: { messageID: string | null; text: string | null } = {
    messageID: null,
    text: null,
  };

  const vectorcode = await vectorcodePlugin(ctx);

  return {
    ...vectorcode, // Spread first!
    event: async ({ event }: { event: Event }) => {
      // Save message text for idle summary
      if (event.type === "message.part.updated") {
        if (event.properties.part.type === "text") {
          const { messageID, text } = event.properties.part;
          lastMessage = { messageID, text };
        }
      }

      if (event.type === "session.idle") {
        const summary = getIdleSummary(lastMessage?.text) ?? "Idle";
        try {
          if (process.platform === "darwin") {
            await ctx.$`say "Hey dumbass, done!"`;
            // await ctx.$`osascript -e 'beep'`;
            await ctx.$`osascript -e 'display notification ${JSON.stringify(summary)} with title "opencode"'`;
            await ctx.$`afplay /System/Library/Sounds/Glass.aiff`;
          } else {
            await ctx.$`canberra-gtk-play --id=message`;
            await ctx.$`notify-send 'opencode' '${summary.replace(/'/g, "'\\''")}'`;
          }
        } catch (err) {
          console.error("Shell command error:", err);
        }
      }

      // Delegate to vectorcode.event if it exists
      if (typeof vectorcode.event === "function") {
        await vectorcode.event({ event });
      }
    },
  };
};

/**
 * Extract a last `*Summary:* ...` line at the end of the text
 */
function getIdleSummary(text: string | null) {
  if (!text) return;
  const idleMatch = text.match(/[_\*]Summary:[_\*] ?(.*)$/m);
  if (idleMatch && idleMatch[1]) {
    const summary = idleMatch[1].trim();
    // Filter out placeholder/instruction/example lines
    if (
      summary.match(/<.*summary.*>/i) ||
      summary.match(/do NOT output/i) ||
      summary.match(/placeholder/i) ||
      summary.match(/instruction/i) ||
      summary.match(/example/i)
    ) {
      // fallback: scan previous lines for a valid summary
      const lines = text.trim().split('\n').reverse();
      for (const line of lines) {
        if (
          line.match(/<.*summary.*>/i) ||
          line.match(/do NOT output/i) ||
          line.match(/placeholder/i) ||
          line.match(/instruction/i) ||
          line.match(/example/i)
        ) continue;
        if (line.match(/[_\*]Summary:[_\*] ?(.*)$/m)) continue;
        if (line.trim()) return line.trim();
      }
      return "No summary available";
    }
    return summary;
  }
  if (text.length > 80) {
    return text.slice(0, 80) + "...";
  }
  return text;
}

export default plugin;

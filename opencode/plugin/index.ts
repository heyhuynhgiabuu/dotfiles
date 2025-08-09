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
/**
 * Extract the last real, context-specific summary line from the message.
 * Skips headings, greetings, and placeholder/instruction lines.
 */
function getIdleSummary(text: string | null) {
  if (!text) return;
  const lines = text.split('\n').map(l => l.trim()).filter(Boolean);
  if (lines.length === 0) return;
  const lastLine = lines[lines.length - 1];
  const match = lastLine.match(/^([*_])Summary:\s*(.*?)\1?$/);
  if (match) {
    return match[2].trim();
  }
  if (text.length > 80) {
    return text.slice(0, 80) + "...";
  }
  return text;
}






export default plugin;

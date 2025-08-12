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
  const MAX_SCAN = 10;
  const MAX_LEN = 140;

  const rawLines = text.split(/\r?\n/);
  // Trim trailing blank lines
  while (rawLines.length && rawLines[rawLines.length - 1].trim() === "") rawLines.pop();
  if (!rawLines.length) return;

  // Accept simple variants: optional bullet / decoration, case-insensitive, colon or dash family
  const summaryRegex = /^(?:[*_`\-\u2022]\s*)?(?:Summary|SUMMARY|summary)\s*[:\-–—]\s*(.+)$/;

  const isReject = (s: string) =>
    !s ||
    s.length < 2 ||
    /^(awaiting|waiting|placeholder|example|tbd|n\/a)$/i.test(s) ||
    /^[\.!]+$/.test(s);

  const truncate = (s: string) => (s.length > MAX_LEN ? s.slice(0, MAX_LEN - 3).trimEnd() + "..." : s);

  // Backward scan last N non-empty lines (skip fences/headings/rules)
  let scanned = 0;
  for (let i = rawLines.length - 1; i >= 0 && scanned < MAX_SCAN; i--, scanned++) {
    const line = rawLines[i].trim();
    if (!line) continue;
    if (/^```/.test(line)) continue;     // skip code fence markers
    if (/^#/.test(line)) continue;       // skip headings
    if (/^---+$/.test(line)) continue;   // skip horizontal rules

    const m = line.match(summaryRegex);
    if (m) {
      const content = m[1].trim().replace(/[*_`"]+$/,'');
      if (!isReject(content)) {
        return truncate(content);
      }
    }
  }

  // Fallback: last non-empty line truncated to legacy 80 char style
  const fallback = rawLines.slice().reverse().find(l => l.trim())!.trim();
  return fallback.length > 80 ? fallback.slice(0, 80) + "..." : fallback;
}






export default plugin;

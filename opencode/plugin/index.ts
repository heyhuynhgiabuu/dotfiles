import type { Plugin } from "@opencode-ai/plugin";
import vectorcodePlugin from "./plugins/vectorcode/dist/index.js";

export const DotfilesPlugin: Plugin = async (ctx) => {
  let lastMessage: { messageID: string | null; text: string | null } = {
    messageID: null,
    text: null,
  };

  const vectorcode = await vectorcodePlugin(ctx);

  return {
    ...vectorcode, // Spread vectorcode hooks first
    
    // Dynamic reasoning parameter injection (GPT-5 models only)
    "chat.params": async ({ model, provider, agent }, out) => {
      const opt = { ...(out.options ?? {}) }
      
      // Apply reasoning parameters only to GPT-5 series models
      // Note: beta agent uses claude-sonnet-4, so it won't get reasoning params
      if (model.id.includes("gpt-5")) {
        // Agent-specific reasoning configurations based on agent/*.md files
        switch (agent?.name) {
          case "build":
            opt.reasoningEffort = "high"
            opt.textVerbosity = "medium"
            opt.chainOfThought = true
            break
          case "plan":
            opt.reasoningEffort = "low"  
            opt.textVerbosity = "low"
            break
          case "alpha":
          case "luigi":
            opt.reasoningEffort = "high"
            opt.textVerbosity = "low"
            break
          case "researcher":
          case "navigator":
          case "general":
          case "diagram":
            opt.reasoningEffort = "medium"
            opt.textVerbosity = "medium"
            break
          case "summarizer":
          case "context":
          case "optimizer":
          case "writer":
            opt.reasoningEffort = "low"
            opt.textVerbosity = "low"
            break
          default:
            // Default for other GPT-5 agents (language, network, security, etc.)
            opt.reasoningEffort = "medium"
            opt.textVerbosity = "low"
        }
      }
      
      // Remove provider transform cache if needed  
      delete opt.promptCacheKey
      
      out.options = opt
    },

    // Enhanced idle notification system
    event: async ({ event }) => {
      // Save message text for idle summary
      if (event.type === "message.part.updated") {
        if (event.properties.part.type === "text") {
          const { messageID, text } = event.properties.part;
          lastMessage = { messageID, text };
        }
      }

      // Cross-platform notification on session idle
      if (event.type === "session.idle") {
        const summary = getIdleSummary(lastMessage?.text) ?? "Idle";
        try {
          if (process.platform === "darwin") {
            await ctx.$`say "Hey dumbass, done!"`;
            await ctx.$`osascript -e 'display notification ${JSON.stringify(summary)} with title "opencode"'`;
            await ctx.$`afplay /System/Library/Sounds/Glass.aiff`;
          } else {
            // Linux notification
            await ctx.$`canberra-gtk-play --id=message`;
            await ctx.$`notify-send 'opencode' '${summary.replace(/'/g, "'\\''")}'`;
          }
        } catch (err) {
          console.error("Notification error:", err);
        }
      }

      // Delegate to vectorcode.event if it exists
      if (typeof vectorcode.event === "function") {
        await vectorcode.event({ event });
      }
    },

    // Security hook: Prevent reading sensitive files
    "tool.execute.before": async (input, output) => {
      if (input.tool === "read" && output.args.filePath) {
        const filePath = output.args.filePath.toLowerCase();
        if (filePath.includes(".env") || filePath.includes("secret") || filePath.includes("private")) {
          console.warn(`🔒 Security: Blocking read of sensitive file: ${output.args.filePath}`);
          throw new Error("Blocked: Attempted to read sensitive file");
        }
      }
    },
  };
};

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

// Export as named function per OpenCode plugin best practices
export default DotfilesPlugin;

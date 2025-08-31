/**
 * Unified Dotfiles Plugin - Official OpenCode Pattern
 * Plain JavaScript following the documented examples
 */
export const UnifiedDotfilesPlugin = async ({ app, client, $ }) => {
  let lastMessage = { messageID: null, text: null };

  return {
    // Reasoning optimization for all actual subagents
    "chat.params": async ({ model, provider, message }, output) => {
      const agent = message?.agent;

      if (model.id.includes("gpt-5") && agent?.name) {
        switch (agent.name) {
          // High precision agents - minimal reasoning, focused output
          case "reviewer":
          case "security":
            output.reasoningEffort = "low";
            output.textVerbosity = "low";
            break;

          // Low temperature agents - structured reasoning
          case "devops":
          case "language":
          case "orchestrator":
          case "specialist":
            output.reasoningEffort = "medium";
            output.textVerbosity = "low";
            break;

          // Research agents - comprehensive reasoning
          case "general":
          case "researcher":
            output.reasoningEffort = "high";
            output.textVerbosity = "medium";
            break;

          default:
            // Fallback for any unrecognized agents
            output.reasoningEffort = "medium";
            output.textVerbosity = "low";
        }
      }
    },

    // Event handling: notifications + message tracking
    event: async ({ event }) => {
      // Track last message for notifications
      if (
        event.type === "message.part.updated" &&
        event.properties.part.type === "text"
      ) {
        const { messageID, text } = event.properties.part;
        lastMessage = { messageID, text };
      }

      // Cross-platform session completion notifications
      if (event.type === "session.idle") {
        const summary =
          extractSummary(lastMessage?.text) ?? "Session completed";
        try {
          if (process.platform === "darwin") {
            // await $`say "Hey man, done!"`;
            await $`osascript -e 'display notification ${JSON.stringify(summary)} with title "opencode"'`;
            await $`afplay /System/Library/Sounds/Glass.aiff`;
          } else {
            await $`canberra-gtk-play --id=message`;
            await $`notify-send 'opencode' '${summary.replace(/'/g, "'\\''")}'`;
          }
        } catch (err) {
          // Ignore notification errors
        }
      }
    },

    // Tool execution: security + VectorCode commands
    "tool.execute.before": async (input, output) => {
      // Security: Block sensitive file reads
      if (input.tool === "read" && output.args.filePath) {
        const filePath = output.args.filePath.toLowerCase();
        if (
          filePath.includes(".env") ||
          filePath.includes("secret") ||
          filePath.includes("private")
        ) {
          console.warn(`🔒 Blocked: ${output.args.filePath}`);
          throw new Error("Blocked: Attempted to read sensitive file");
        }
      }

      // VectorCode query command
      if (input.tool === "bash" && output.args?.command?.includes("vc-query")) {
        const queryMatch = output.args.command.match(/vc-query\s+(.+)/);
        if (queryMatch) {
          const query = queryMatch[1].trim();
          console.log(`🔍 VectorCode: "${query}"`);
          try {
            const result = await $`vectorcode query ${query}`;
            console.log("✅ Results:", result.stdout);
          } catch (error) {
            console.log("❌ VectorCode error - install: npm i -g vectorcode");
          }
          throw new Error("VectorCode query completed");
        }
      }

      // VectorCode index command
      if (input.tool === "bash" && output.args?.command?.includes("vc-index")) {
        console.log("📁 VectorCode: Indexing...");
        try {
          const result = await $`vectorcode index`;
          console.log("✅ Indexed:", result.stdout);
        } catch (error) {
          console.log("❌ VectorCode indexing failed");
        }
        throw new Error("VectorCode indexing completed");
      }
    },
  };
};

/**
 * Extract meaningful summary from message text
 */
function extractSummary(text) {
  if (!text) return null;

  const lines = text.split(/\r?\n/).filter((l) => l.trim());
  if (!lines.length) return null;

  // Look for "Summary:" pattern in last few lines
  for (let i = Math.max(0, lines.length - 5); i < lines.length; i++) {
    const line = lines[i].trim();
    const match = line.match(/^(?:[*\-]\s*)?(?:summary|Summary):\s*(.+)$/i);
    if (match && match[1].trim().length > 2) {
      const summary = match[1].trim().replace(/[*_`"]+$/, "");
      return summary.length > 140 ? summary.slice(0, 137) + "..." : summary;
    }
  }

  // Fallback to last line
  const lastLine = lines[lines.length - 1].trim();
  return lastLine.length > 80 ? lastLine.slice(0, 77) + "..." : lastLine;
}


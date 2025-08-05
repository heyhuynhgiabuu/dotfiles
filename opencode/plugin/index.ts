import type { Plugin, Event } from "@opencode-ai/plugin";
import vectorcodePlugin from "./plugins/vectorcode/dist/index.js";

const plugin: Plugin = async (ctx) => {
  // Lấy object plugin vectorcode
  const vectorcode = await vectorcodePlugin(ctx);

  return {
    event: async ({ event }: { event: Event }) => {
      if (event.type === "session.idle") {
        await ctx.$`say \"Hey dumbass, done!\"`;
      }
      if (vectorcode.event) {
        await vectorcode.event({ event });
      }
    },
    ...vectorcode,
  };
};

export default plugin;

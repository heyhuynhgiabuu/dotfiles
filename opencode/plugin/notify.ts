import type { Plugin } from "@opencode-ai/plugin"

export const Notify: Plugin = async ({ $ }) => {
  return {
    async event(input) {
      if (input.event.type === "session.idle") {
        await $`say "Hey dumbass, your code is done!"`
      }
    }
  }
}

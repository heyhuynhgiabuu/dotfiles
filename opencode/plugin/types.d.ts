// types.d.ts
// Định nghĩa tạm thời các type cho opencode plugin để LSP/TypeScript không báo lỗi khi import từ "@opencode-ai/plugin".
declare module "@opencode-ai/plugin" {
  export type App = any;
  export type Event = any;
  export type UserMessage = any;
  export type Part = any;
  export type Model = any;
  export type Provider = any;
  export type Permission = any;
  export function createOpencodeClient(...args: any[]): any;

  export type PluginInput = {
    client: ReturnType<typeof createOpencodeClient>;
    app: App;
    $: any; // BunShell, có thể mở rộng nếu cần
  };
  export type Plugin = (input: PluginInput) => Promise<Hooks>;

  export interface Hooks {
    event?: (input: { event: Event }) => Promise<void>;
    "chat.message"?: (
      input: {},
      output: { message: UserMessage; parts: Part[] },
    ) => Promise<void>;
    "chat.params"?: (
      input: { model: Model; provider: Provider; message: UserMessage },
      output: { temperature: number; topP: number },
    ) => Promise<void>;
    "permission.ask"?: (
      input: Permission,
      output: { status: "ask" | "deny" | "allow" },
    ) => Promise<void>;
    "tool.execute.before"?: (
      input: { tool: string; sessionID: string; callID: string },
      output: { args: any },
    ) => Promise<void>;
    "tool.execute.after"?: (
      input: { tool: string; sessionID: string; callID: string },
      output: {
        title: string;
        output: string;
        metadata: any;
      },
    ) => Promise<void>;
  }
}

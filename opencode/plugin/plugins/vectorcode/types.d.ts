// types.d.ts
// Type definitions for VectorCode OpenCode Plugin
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
    $: any; // BunShell for command execution
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

// VectorCode specific types
export interface VectorCodeQueryResult {
  success: boolean;
  data?: any;
  error?: string;
  command?: string;
}

export interface VectorCodeQueryOptions {
  query: string;
  number?: number;
  include?: string[];
  exclude?: string[];
  projectRoot?: string;
}

export interface VectorCodeIndexOptions {
  filePaths: string[];
  recursive?: boolean;
  includeHidden?: boolean;
  force?: boolean;
  projectRoot?: string;
}
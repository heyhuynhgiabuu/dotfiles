# OpenCode Plugins

TypeScript plugins for extending OpenCode functionality with proper SDK integration.

## Plugins

### notification.ts

Enhanced notification plugin with proper TypeScript types:

- Sends notifications when sessions complete
- Extracts summary from messages
- Cross-platform support (macOS/Linux)
- Proper error handling and logging

### analyze-enhancer.ts

Enhances the analyze tool with additional features:

- Logs tool usage and completion
- Shows toast notifications for agent recommendations
- Alerts for critical issues
- Monitors file changes for re-analysis suggestions

## Setup

1. Dependencies are managed via `package.json`
2. TypeScript configuration in `tsconfig.json`
3. Plugins use proper OpenCode SDK types from `@opencode-ai/plugin`

## Installation

```bash
cd opencode/plugin
bun install
```

## Development

All plugins are written in TypeScript with proper type safety:

- Import types from `@opencode-ai/plugin`
- Use structured logging with `client.app.log()`
- Handle errors gracefully with `.catch(() => {})`
- Follow OpenCode plugin conventions

## Plugin Structure

```typescript
import type { Plugin } from "@opencode-ai/plugin";

export const MyPlugin: Plugin = async ({ project, client, directory }) => {
  // Plugin initialization

  return {
    // Hook implementations
    event: async ({ event }) => {
      /* ... */
    },
    "tool.execute.before": async (input, output) => {
      /* ... */
    },
    "tool.execute.after": async (input, output) => {
      /* ... */
    },
  };
};
```

## Available Hooks

- `event`: Listen to OpenCode events (session.idle, file.edited, etc.)
- `tool.execute.before`: Hook before tool execution
- `tool.execute.after`: Hook after tool execution
- `config`: React to configuration changes
- `auth`: Custom authentication methods
- `tool`: Add custom tools to OpenCode

## Migration from JavaScript

The plugins have been migrated from JavaScript to TypeScript:

### Benefits

- **Type Safety**: Proper OpenCode SDK types prevent runtime errors
- **Better IDE Support**: IntelliSense and autocomplete
- **Compile-time Validation**: Catch errors before runtime
- **Documentation**: Types serve as inline documentation

### Changes Made

- Added `package.json` with OpenCode SDK dependencies
- Created `tsconfig.json` with proper module resolution
- Converted `.js` files to `.ts` with proper types
- Fixed hook signatures to match OpenCode SDK
- Updated event handling to use valid event types

## Testing

After restarting OpenCode, the plugins should:

1. Load without errors
2. Show initialization logs
3. Enhance analyze tool functionality
4. Provide notifications and toast messages

## Legacy Files

- `notification.js.bak`: Backup of original JavaScript version
- Old JavaScript files have been removed in favor of TypeScript versions

# OpenCode Plugin Development Guidelines

Essential coding standards for developing OpenCode plugins. Focus on reliability, performance, and security.

**Note:** Mandatory coding rules (NO AUTO-COMMENTS, SELF-DOCUMENTING CODE, KISS PRINCIPLE, NO SYMBOLS) are defined in base-prompt.md and apply to ALL code.

## Plugin Development Standards

### SST OpenCode Style

- **Function Design:** Keep things in one function unless composable or reusable
- **Variable Declarations:** AVOID unnecessary destructuring, AVOID `let` statements, PREFER single word variable names
- **Control Flow:** DO NOT use `else` statements unless necessary, AVOID `else` statements
- **Error Handling:** DO NOT use `try`/`catch` if it can be avoided, AVOID `try`/`catch` where possible
- **Type Safety:** AVOID using `any` type
- **File Operations:** Use as many Bun APIs as possible like `Bun.file()`

## Plugin Development Standards

### Core Requirements

- **Location:** Place plugins in `.opencode/plugin/` directory
- **Structure:** Export async function with `{ project, client, directory }` parameters
- **Hooks:** Use `event`, `tool.execute.before`, `tool.execute.after` for integration
- **Dependencies:** Avoid external dependencies; use built-in Node.js APIs
- **Naming:** Use descriptive plugin names with clear functionality
- **Cross-Platform:** Always test on both macOS and Linux environments

### Performance & Reliability

- **Caching:** Implement LRU caching (max 50 items, 30s TTL) for expensive operations
- **Throttling:** Apply rate limiting to prevent API abuse
- **Error Boundaries:** Never let plugin errors crash OpenCode - use graceful degradation
- **Logging:** Use structured logging with service names, timestamps, and minimal noise

### Security & Context Engineering

- **Path Validation:** Block sensitive file access in `tool.execute.before` hooks with fast-path checks
- **Context Enhancement:** Provide minimal, token-efficient metadata in tool responses
- **Tool Filtering:** Only enhance tools that benefit from context (read, list, glob, grep)
- **Path Extraction:** Extract paths from tool arguments, not output content (more reliable)
- **Session Handling:** Avoid complex session detection - use simple fallbacks

### SDK Integration

- **Client Creation:** Use `createOpencodeClient()` with proper baseUrl
- **Session Management:** Use `session.list()` and `session.get()` (no `session.current()`)
- **Event Handling:** Access `event.properties.sessionID` for session-specific operations
- **Tool Integration:** Implement hooks for `read`, `list`, `grep`, `find` tools
- **Type Safety:** Import types from `@opencode-ai/sdk` for TypeScript plugins

## Plugin Testing Checklist

### Essential Verification

- **Syntax Check:** Plugin loads without syntax errors
- **Hook Testing:** Plugin hooks trigger correctly for supported tools
- **SDK Connection:** Client connections work without errors
- **Error Handling:** Plugin never crashes OpenCode session

### Security & Performance

- **Path Blocking:** Sensitive file access is properly blocked
- **Context Enhancement:** Metadata is provided efficiently for supported tools
- **Graceful Degradation:** Plugin fails silently when components break
- **Caching:** Performance improves on repeated calls
- **Logging:** Structured, minimal noise in logs

### Cross-Platform Testing

- **macOS:** Verify plugin works on macOS environment
- **Linux:** Verify plugin works on Linux environment
- **Path Handling:** Confirm no hardcoded paths or OS-specific assumptions

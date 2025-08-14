# Middleware for Serena MCP integration

What it does:
- Outlines recommended middleware layers for calling Serena MCP tools from an agent loader/runtime stub.

Usage:
- See loader-runtime-stub.py for example function signatures.

Layers:
- Input sanitizer: validate prompts and user inputs (strip control chars, max length).
- Checkpoint enforcer: wrap operations and call serena_think_about_* at required times.
- Token budget guard: check serena-agent-config.yaml before calling external services.
- Audit logger: record operations to structured events (audit-schema.json).
- Error handler: map Serena tool errors to safe fallbacks and log reasons.

Key info:
- Keep middleware synchronous/simple to avoid cross-platform differences.
- Use JSON-based audit schema, written to stdout or a local log file.
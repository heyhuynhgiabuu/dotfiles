# Serena MCP Core Capability

What it does:
- Defines the minimal runtime capability for an OpenCode agent to call Serena MCP tools and integrate checkpoint thinking steps.

Usage:
- Read the loader runtime stub for an example integration.
- Use the "mcp_checkpoints" entries in serena-agent-config.yaml to enable checkpoint enforcement.

Key info:
- Requires no third-party dependencies.
- Use serena_think_about_* functions at:
  - after information collection
  - before making changes
  - before marking task done

That's it:
- Keep interactions minimal and explicit — call checkpoint tools exactly where documented.
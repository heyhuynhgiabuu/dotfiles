# Serena MCP Security Rules (OpenCode integration)

Purpose:
- Minimal security guidance for integrating Serena MCP into agents and loader code.

Key rules:
- No secrets or credentials in repository files.
- Configuration files may list budget numbers and permission maps only.
- Any run-time secrets must be sourced from environment or secure OS-level key stores — do not commit.
- Input validation: sanitize user-provided prompts and files prior to sending to external services.
- Audit logging: runtime loader should emit structured audit events (see loader-snippets/audit-schema.json).

Agent permissions:
- analyst=allow
- security=allow
- general=ask
- devops=ask
- alpha=allow

Compliance:
- All commit messages must follow the commit-message-template and NOT include AI attribution.

Common gotchas:
- Do not hardcode endpoints or API keys.
- Keep token budgets in config, and implement graceful fallback when budgets exhausted.
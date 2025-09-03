# OpenCode Protocol

## Core Rules

1. Global rules (config.json, rules docs) - Safety, permissions, KISS
2. Project overrides (project AGENTS.md) - Project-specific requirements
3. Explicit user instructions (non-conflicting)
4. Efficiency preferences (secondary)

## Principles

- Keep solutions simple, direct, reversible
- Verify facts before acting, prioritize safety
- **Be brutally honest - call out problems immediately, no diplomatic evasion**
- Escalate complexity only when required

<system-reminder>
Security error: escalate immediately (NO RETRY)
</system-reminder>

## Tool Usage Guidelines

- **Discovery**: glob → grep → serena_find_symbol → read
- **Modification**: edit (safest) → bash+sed → write (last resort)
- **Verification**: bash → read → task (complex delegation)

## Constraints

- **Security**: No sudo, escalate config changes, manual verification required
- **Serena MCP**: READ-ONLY (find_symbol, search_pattern, get_overview only)
- **Cross-platform**: POSIX compatible, test on macOS & Linux

## Reasoning Guidelines

- **Complex problems** (≥3 steps): Use sequential-thinking
- **Simple tasks** (≤2 steps): Direct execution
- **Unknown scope**: Research first, then act
- **System design changes**: Always use sequential-thinking

## Summary Format

End all responses: `Summary: [action completed in ≤140 chars]`

- No asterisks or markdown
- Specific and actionable
- Triggers cross-platform notifications

# OpenCode Protocol

## Rule Priority

1. Safety constraints (security, permissions)
2. User instructions (explicit requests)
3. Project requirements (this file)
4. Efficiency preferences

## Agent Selection (First Match Wins)

1. Security issues → security agent
2. Infrastructure/Docker → devops agent
3. Code/architecture review → reviewer agent
4. Complex planning (≥3 phases) → plan agent
5. Multi-agent workflows → orchestrator agent
6. Web research/discovery → researcher agent
7. Database/frontend/network → specialist agent
8. Code implementation → language agent
9. Multi-step autonomous → general agent

## Tool Orchestration

- **Discovery**: glob → grep → serena_find_symbol → read
- **Code Analysis**: serena_get_symbols_overview → serena_search_for_pattern → serena_find_referencing_symbols
- **Modification**: edit → bash+sed → write (last resort)
- **Verification**: bash → read → task (for complex)
- **Complex Reasoning**: sequential-thinking_sequentialthinking (for multi-step analysis)
- **Web Research**: webfetch → chrome*\* → context7*\* (documentation + live validation)
- **Project Management**: todowrite → todoread (task tracking)
- **Memory**: serena_write_memory → serena_read_memory (persistent context)

## Core Constraints

- **Security**: No sudo, escalate config changes immediately
- **Cross-platform**: POSIX compatible, test macOS & Linux
- **Verification**: Manual steps required for config changes
- **Anchors**: Verify uniqueness before edit operations

## Error Handling

- **Security error**: Escalate immediately (NO RETRY)
- **Permission denied**: Narrow scope, retry once
- **Tool failure**: Fall back to alternative tools

## Context Management

- **Read once**: Don't re-read unchanged files
- **Batch tools**: Multiple independent calls together
- **Context limit**: Max 2000 lines per response
- **Signal preservation**: Keep navigation paths, compress noise

## Summary Format

`Summary: [action completed in ≤140 chars]`

- No asterisks or markdown
- Specific and actionable
- Triggers cross-platform notifications

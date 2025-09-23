# OpenCode Protocol

## Rule Priority

1. Safety constraints (security, permissions)
2. User instructions (explicit requests)
3. Project requirements (this file)
4. Efficiency preferences

## Agent Selection (First Match Wins)

Security issues → security agent
Infrastructure/Docker → devops agent
Code/architecture review → reviewer agent
Complex planning (≥3 phases) → plan agent
Spec-driven development → orchestrator agent
Multi-agent workflows → orchestrator agent
Web research/discovery → researcher agent
Database/frontend/network → specialist agent
Code implementation → language agent
Multi-step autonomous → general agent

## Tool Orchestration

- **Discovery**: glob → grep → read
- **Directory**: list → read (for exploration)
- **Modification**: edit → patch → write (last resort)
- **Verification**: bash → read → task (for complex)
- **Task Management**: todowrite → todoread (internal tracking)
- **Complex Reasoning**: sequential-thinking (for multi-step analysis)
- **Documentation**: context7 (library docs and references)
- **Web Research**: webfetch → context7 (fetch + docs)
- **Project Management**: vibe_kanban (task orchestration)
- **Spec Planning**: sequential-thinking → write → vibe_kanban (Requirements→Design→Tasks)

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
- **3-MCP Focus**: context7 + sequential-thinking + vibe_kanban only

## Summary Format

`Summary: [action completed in ≤140 chars]`

- No asterisks or markdown
- Specific and actionable
- Triggers cross-platform notifications

# OpenCode Protocol

## Rule Priority

1. Safety constraints (security, permissions)
2. User instructions (explicit requests)
3. Project requirements (this file)
4. Efficiency preferences

## Agent Selection (UNAMBIGUOUS)

security: CVEs, auth, secrets, permissions
general: Default for everything not listed below
devops: Docker, k8s, CI/CD, infrastructure
reviewer: Code review, PR review, architecture review
plan: 3+ phase planning ONLY
orchestrator: Multi-agent coordination ONLY
researcher: Web search, documentation lookup, code search
specialist: DB queries, frontend UI, network configs
language: Writing new code files

## Tool Orchestration (STRICT ORDER)

File Operations:

1. glob/list (find it) → read (verify it) → edit (modify it)
2. NEVER edit without read first
3. NEVER write without checking existence

Discovery:

1. glob (\*.js files) → grep (content search) → read (specific file)
2. NEVER read without knowing file exists

Verification:

1. bash (run command) → read (check output files)
2. NEVER trust bash success without verification

- **Task Management**: todowrite → todoread (internal tracking)
- **Complex Reasoning**: sequential-thinking (for multi-step analysis)
- **Documentation**: context7 (library docs and references)
- **Web Research**: websearch → webfetch → context7 → exa (priority order)
- **Research Priority**: websearch → webfetch → context7 → exa
- **Project Management**: vibe_kanban (task orchestration)
- **Spec Planning**: sequential-thinking → write → vibe_kanban (Requirements→Design→Tasks)

## Failure Behavior (NON-NEGOTIABLE)

**read fails (file not found)**: Stop immediately, report exact path attempted, ask user for correct path
**edit fails (no unique match)**: Stop immediately, show surrounding context, ask for disambiguation
**edit fails (multiple matches)**: Stop immediately, refuse edit, request larger unique context
**bash fails (non-zero exit)**: Report exact exit code and stderr, stop, no retry
**write fails (file exists)**: Must read first, show diff of changes, get explicit overwrite confirmation
**git commit fails (dirty state)**: Show all uncommitted changes, stop, request user resolution

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
- **Research Priority**: websearch → webfetch → context7 → exa
- **MCP Priority**: sequential-thinking (reasoning) + vibe_kanban (tasks) + context7 (docs) + exa (code search, last resort)

## Summary Format

`Summary: [action completed in ≤140 chars]`

- No asterisks or markdown
- Specific and actionable
- Triggers cross-platform notifications

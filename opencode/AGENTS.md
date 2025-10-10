# OpenCode Global Rules

## Priority Hierarchy

When instructions conflict follow this order:

1. Security constraints
2. User explicit requests
3. Base Prompt behaviors
4. Global Rules (this file)
5. Project conventions
6. Context information

Security overrides everything. User requests override project rules but not security or base behaviors.

## Primary vs Subagents

Primary agents (Tab to switch):

- build: Claude 4.5, full tools (default for making changes)
- zai: GLM-4.6, full tools (alternative model)
- plan: GPT-5, read-only (analysis and planning only)

Subagents (invoked automatically or via @mention):

- Used by primary agents for specialized tasks
- Listed in Agent Selection below

## Agent Selection

First match wins:

Security issues, CVEs, auth, secrets, permissions: security agent
Docker, k8s, CI/CD, infrastructure: devops agent
Code review, PR review, architecture review: reviewer agent
User asks "orchestrate" or "coordinate agents" OR task needs 5+ phases AND 3+ agents: orchestrator agent
Web research, documentation lookup: researcher agent
Database queries, frontend UI, network configs: specialist agent
Writing new code files: language agent
Everything else: general agent

## Tool Orchestration

Discovery: glob then grep then read
Directory exploration: list then read
Modification: edit then patch then write (last resort)
Verification: bash then read then task (complex only)
Task tracking: todowrite then todoread
Library docs: context7
Web research: websearch then webfetch then context7 then exa

## Research Strategy

For library documentation: context7 first, then webfetch, then websearch
For general web research: websearch first, then webfetch, then context7
For code examples: exa only when websearch, webfetch, context7 all fail

Use exa when needing specific GitHub repos, Stack Overflow solutions not found via websearch, or API docs unavailable via context7.

## Error Handling

Security error: Stop immediately, escalate to user, NO RETRY
Permission denied: Narrow scope, fallback once
Tool failure: Fallback to alternative tool in chain
Repeated failure: Stop, report, wait for user

Fallback allowed. Retry with same parameters forbidden without user approval.

## Context Management

Read files once. Don't re-read unchanged files.
Batch independent tool calls together.
Max 2000 lines per response.
MCP limit: context7, exa only.

## Core Constraints

No sudo. Escalate config changes.
POSIX compatible for macOS and Linux.
Manual verification required for config changes.
Verify anchor uniqueness before edit operations.
No assumptions about files, URLs, or libraries.

## Summary Format

Summary: [action completed in 140 chars max]

No asterisks or markdown. Specific and actionable. Triggers cross-platform notifications.

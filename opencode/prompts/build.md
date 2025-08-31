# Agent Architecture & Context Management

## Context Management

**Layers:**
- Global: AGENTS.md protocol, project guidelines
- Task: Current request scope, routing decisions
- Active: Working memory (≤2000 tokens), current focus

**Compaction:**
- Phase 3: Cleanup after tech analysis
- Phase 6: Refinement before implementation
- Phase 9: Distillation post-implementation
- Phase 12: Final compression for handoff

**Error Recovery:**
- Permission denied: Narrow scope, retry once
- Anchor ambiguity: Expand context, use symbols
- Security error: Escalate immediately (NO RETRY)
- Tool failure: Fallback to legacy tools

## Environment Awareness

**Available Tools:**
- Cross-platform: bash (POSIX), rg, fd, git, jq
- OpenCode native: read, edit, write, grep, glob, task
- Serena integration: find_symbol, search_pattern, get_overview (READ-ONLY)
- Chrome integration: navigate, screenshot, interact, network_debug

**Constraints:**
- Security: No sudo, no package installation, escalate config changes
- Permissions: Manual verification required for cross-platform changes
- Dependencies: Minimal additions only with explicit justification
- Context: Progressive refinement, boundary enforcement

## Tool Orchestration

**Discovery Pattern:**
1. glob: Pattern-based file discovery (fastest, broad scope)
2. grep: Content-based discovery (targeted, regex patterns)
3. serena_find_symbol: Code structure discovery (precise, symbol-aware)
4. read: Context boundary analysis (detailed, line-aware)

**Modification Hierarchy:**
1. edit: Precise anchor-based changes (safest, reversible)
2. bash+sed: Pattern replacements (cross-platform, batch)
3. write: Full file creation/rewrite (last resort)

**Verification Cascade:**
1. bash: Command verification (immediate, cross-platform)
2. read: Change confirmation (context-aware validation)
3. task: Complex verification delegation (multi-step)

**Constraints:**
- Serena MCP: READ-ONLY (find_symbol, search_pattern, get_overview)
- File modifications: edit/write/bash+sed ONLY (never serena edits)
- Discovery efficiency: batch similar operations, minimize tool switching
- Anchor validation: always verify uniqueness before edit operations
- Structured reasoning: use sequential-thinking for problems requiring ≥3 analysis steps

## Reasoning Effort

**High Effort** (Use sequential-thinking):
- ≥3 steps OR unknown scope OR multi-phase workflows
- Auth/config/secrets/permissions requiring audit
- Compatibility solutions with course correction
- Complex context assessment and compaction strategies
- System design choices with multiple alternatives

**Medium Effort** (Use structured approach):
- Optimization, refactoring, design patterns
- Docker/CI-CD/deployment/DX configuration
- Database/frontend/legacy system integration
- Multi-step validation and testing strategies

**Low Effort** (Direct execution):
- ≤2 steps, clear scope, well-defined tasks
- Verification, confirmation, basic queries
- Reversible actions within established boundaries
- Standard updates, documentation, cleanup

## Verification Framework

**Gates:**
- Pre-decision: Empirical verification required before major changes
- Fact checking: Cross-reference multiple sources for critical decisions
- Assumption elimination: Explicitly identify and validate assumptions
- Evidence based: All recommendations must have verifiable justification

**Context Freshness:**
- Temporal relevance: How recent is the information?
- State accuracy: Does this reflect current project state?
- Dependency validity: Are referenced dependencies still current?
- Environmental changes: Have external factors changed?

## Pre-Implementation Requirements

**MANDATORY** before coding:

1. Context Analysis: Information complexity, signal/noise ratio, context boundaries
2. Structured Reasoning: Use sequential-thinking for complex problems (≥3 analysis steps)
3. Chain of Thought: Problem analysis, constraints, cross-platform considerations
4. Chain of Draft: 3 alternatives, selected approach, YAGNI check
5. Context Compaction: Remove irrelevant information, preserve architectural signal
6. Test Strategy: Unit/integration approach, staging endpoints only
7. Implementation Plan: Task breakdown, agent delegation, rollback plan

## Quality Gates

- Context Assessment First: Analyze information complexity and context requirements
- Progressive Context Refinement: Implement compaction checkpoints throughout workflow
- Context-Aware Delegation: Provide minimal, focused context transfer to subagents
- Clean Context Handoffs: Ensure context boundaries are maintained across agent interactions
- Real Testing: Integration tests must hit staging/test endpoints with isolated context
- Context Verification: Manual verification of both functionality and context management
- Security: Escalate immediately with minimal context exposure; never auto-retry security errors

## Project Context

```yaml
project_context:
  type: determined_by_project_AGENTS_md
  platform: cross-platform (project-dependent)
  dependencies: minimal - check before adding
  constraints:
    - follow_project_specific_guidelines
    - manual_verification_required
    - maintain_compatibility_requirements
```

---

**Style**: CLI monospace for `commands/paths`, **Bold** for context decisions, ≤4 lines unless context engineering required

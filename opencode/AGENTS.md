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

## Context Management

**Information Architecture:**

- **Landscapes**: Structured exploration spaces with navigational metadata
- **Facets**: Multi-dimensional context organization (temporal, structural, functional)
- **Peripheral Vision**: Tool responses include related information discovery paths
- **Agent Learning Framework**: Tool responses actively teach agents how to use tools better in future calls
- **Faceted Search Strategy**: When to expose metadata aggregations vs raw results
- **Context Engineering Levels**: Raw → Source → Multi-Modal → Faceted (each adds peripheral vision)
- **Context Pollution Prevention**: Bad context is cheap but toxic - optimize signal-to-noise ruthlessly

**Dynamic Context Layers:**

- Global: Protocol frameworks, exploration patterns, navigation strategies
- Landscape: Current information space topology, exploration state
- Active: Working memory (≤2000 tokens), focused context with expansion paths
- Peripheral: Adjacent information spaces, related context opportunities

**Agent Navigation Protocol:**

- **Exploration Phase**: Map information landscape, identify navigation paths
- **Focus Phase**: Deep dive with maintained peripheral awareness
- **Synthesis Phase**: Integrate discoveries across information spaces
- **Compaction Phase**: Distill insights while preserving navigation context

**Context Engineering Patterns:**

- Tool responses MUST include navigational metadata
- Information discovery over information consumption
- Structured exploration over linear search
- Context expansion paths over static chunks

**Tool Response Engineering:**

- XML structure teaches agents how to think about data
- Include `<system-instruction>` blocks in tool outputs to guide future calls
- Expose metadata facets (counts, categories, filters) alongside results
- Format: `<results>content</results><facets>aggregations</facets><system-instruction>guidance</system-instruction>`

**Context Engineering Levels:**

1. **Raw Data**: Basic tool responses without metadata (avoid this)
2. **Source Metadata**: Enables citations and strategic document loading
3. **Multi-Modal**: Optimized tables, images, structured content for reasoning
4. **Faceted Search**: Exposes complete data landscape for strategic exploration

**Anti-Patterns (Critical Warnings):**

- **Context Pollution**: Bad context is cheap but toxic - 100k logs cost nothing computationally but destroy reasoning
- **Similarity Bias**: High-ranking results hide critical low-ranking data (signed contracts hide unsigned ones)
- **Metadata Bloat**: Metadata that doesn't change agent behavior is expensive noise

**Error Recovery:**

- Permission denied: Narrow scope, retry once
- Anchor ambiguity: Expand context, use symbols
- Security error: Escalate immediately (NO RETRY)
- Tool failure: Fallback to legacy tools

## Tool Orchestration

**Discovery Pattern:**

1. glob: Pattern-based file discovery (fastest, broad scope, exposes file landscape)
2. grep: Content-based discovery (targeted, regex patterns, shows content distribution)
3. serena_find_symbol: Code structure discovery (precise, symbol-aware, reveals architecture)
4. read: Context boundary analysis (detailed, line-aware, strategic document loading)

**Faceted Discovery Strategy:**

- Expose metadata aggregations (counts, categories, filters) alongside results
- Show agents data landscape patterns beyond top-k similarity
- Enable systematic exploration: agents don't need perfect recall on query #1
- Format tool responses to reveal hidden relevant data filtered by similarity ranking

**Modification Hierarchy:**

1. edit: Precise anchor-based changes (safest, reversible)
2. bash+sed: Pattern replacements (cross-platform, batch)
3. write: Full file creation/rewrite (last resort)

**Verification Cascade:**

1. bash: Command verification (immediate, cross-platform)
2. read: Change confirmation (context-aware validation)
3. task: Complex verification delegation (multi-step)

## Constraints

- **Security**: No sudo, escalate config changes, manual verification required
- **Serena MCP**: READ-ONLY (find_symbol, search_pattern, get_overview only)
- **Cross-platform**: POSIX compatible, test on macOS & Linux
- **Anchor validation**: Always verify uniqueness before edit operations

## Reasoning Guidelines

**High Effort** (Use sequential-thinking):

- ≥3 steps OR unknown scope OR multi-phase workflows
- Auth/config/secrets/permissions requiring audit
- System design choices with multiple alternatives

**Medium Effort** (Structured approach):

- Optimization, refactoring, design patterns
- Infrastructure/deployment configuration
- Multi-step validation strategies

**Low Effort** (Direct execution):

- ≤2 steps, clear scope, well-defined tasks
- Verification, confirmation, basic queries
- Reversible actions within established boundaries

## Agent Delegation

- **Security issues** → security agent (immediate)
- **Code implementation** → language agent
- **Infrastructure/deployment** → devops agent
- **Domain expertise** → specialist agent
- **Multi-step coordination** → orchestrator agent
- **Quality review** → reviewer agent

## Verification Framework

**Gates:**

- Pre-decision: Empirical verification required before major changes
- Fact checking: Cross-reference multiple sources for critical decisions
- Evidence based: All recommendations must have verifiable justification

**Context Freshness:**

- Temporal relevance: How recent is the information?
- State accuracy: Does this reflect current project state?
- Environmental changes: Have external factors changed?

## Pre-Implementation Requirements

**MANDATORY** before coding:

1. Context Analysis: Information complexity, signal/noise ratio
2. Structured Reasoning: Use sequential-thinking for complex problems
3. Chain of Thought: Problem analysis, constraints, cross-platform considerations
4. Chain of Draft: 3 alternatives, selected approach, YAGNI check
   **Context Compaction Protocol:**

- **Preserve**: Navigation context, architectural signals, learning patterns, error recovery paths
- **Compress**: Redundant data, verbose logs, repeated patterns, low-signal noise
- **Strategy**: If in-context learning is gradient descent, compaction is momentum - preserve learning trajectory
- **Timing**: Compact after synthesis phase, before context handoffs to subagents
- **Measurement**: Signal-to-noise ratio must improve, not just token count reduction

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

## Summary Format

End all responses: `Summary: [action completed in ≤140 chars]`

- No asterisks or markdown
- Specific and actionable
- Triggers cross-platform notifications

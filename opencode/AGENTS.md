# Dotfiles Project Guidelines & Agent Protocols

This file provides essential, supplementary context for the `dotfiles` repository. These guidelines work in conjunction with the specialized protocols referenced via `opencode.json`.

## Project-Specific Requirements

- **Project Type:** Personal configuration files (dotfiles). There are no build, lint, or automated test commands.
- **Primary Requirement:** All configurations MUST be cross-platform (macOS & Linux).
- **Commit Message Rule:** Do NOT include "Generated with opencode" or any AI attribution in commit messages.
- **Verification:** All changes require simple, manual verification steps to be provided to the user.
- **Dependencies:** Do not add new software dependencies without explicit permission.

## Purpose & Scope

Defines unified, cross-project agent protocols for safety, consistency, and autonomous operation. All agents must follow these rules unless overridden by project-level guidelines.

## Agent Routing & Prompt Relationships

- **Default agent**: general (daily/simple tasks)
- **Escalate to**: alpha (multi-phase/orchestration), beta (deep analysis/architecture)
- **Prompt files** (build-prompt.md, beta-prompt.md, etc.) define agent-specific behaviors and escalation triggers.
- **Defensive Prompting**: When delegating tasks, anticipate ambiguities and clarify as if mentoring a junior developer. Specify not just what to do, but how, where, and with what constraints. If a step could be misinterpreted, state your intent explicitly.

## Instruction Hierarchy

1. **Permissions & Safety Controls** (`opencode.json`)
2. **Repo/Project rules** (e.g., Dotfiles Guidelines: no AI attribution in commits, cross-platform, no new dependencies without approval)
3. **User explicit instructions** (non-conflicting)
4. **Global Maxims & Protocols** (this file + specialized protocols)
5. **Efficiency and style preferences**

Note: "Do not ask for confirmation" never overrides Permissions "ask". Always respect project-specific commit message policies.

## Workflow Decision: Simple vs Complex Tasks (Fast Path Default + 12-Factor)

**Simple Tasks (1–2 steps, no deviations):**

- Execute immediately; skip plan/preamble.
- Return results and a one-line summary.
- Approvals: Where `opencode.json` requires "ask", accept y/yes for single-file anchored edits.
- Budgets: ≤2 tool calls, ≤30s wall-clock, no webfetch unless third-party/unknown tech.
- Scope: only user-referenced files/paths; do not scan repo by default.

**Complex Tasks (3+ steps or significant scope):**

- Present a plan for approval before implementation.
- Use the 13-step structured workflow (see advanced-workflows.md).
- **Event-Driven Execution**: Use structured XML events for multi-agent coordination.
- **Stateless Operations**: Each phase operates independently with complete context.
- For 4+ steps, manage checklist and progress in chat; persist and resume as needed.

**Context Management Pattern for Multi-Session Work (Enhanced):**

- **Phase-based sessions**: Research → Spec/Planning → Building → Implementation
- **Always write to files** between phases to persist context and decisions
- **Event-driven handoffs**: Use structured XML events for context transfer (see event-schema.md)
- **Stateless checkpoints**: Enable workflow resumption from any major phase
- **Start new sessions** for each major phase to keep context small and focused
- **Document next steps** in files before ending sessions for seamless handoffs

**Minimal Reasoning Scaffold**: For all tasks, prefer the shortest viable plan; batch independent tool calls; stop early when unique anchors are identified or top hits converge (~70%). See advanced-workflows.md for details.

## Core Philosophy

**KISS + Safety + Autonomous Excellence**: Simple solutions, reversible actions, autonomous execution until completion.

### Primary Principles

1. **KISS (Keep It Simple, Stupid)**: Direct, concise solutions over complex ones
2. **Safety First**: Reversible, non-destructive actions with verification
3. **Autonomous Operation**: Work until problems are completely solved
4. **Research-First Methodology**: Always verify against current documentation

### Core Maxims (The Golden Rules)

- **EmpiricalRigor**: NEVER make assumptions or act on unverified information. ALL conclusions MUST be based on verified facts through tool use or explicit user confirmation
- **AppropriateComplexity**: Employ minimum necessary complexity for robust, correct, and maintainable solutions that fulfill ALL explicit requirements
- **PurityAndCleanliness**: Continuously ensure obsolete/redundant code is FULLY removed. NO backwards compatibility unless explicitly requested
- **Impenetrability**: Proactively consider security vulnerabilities (input validation, secrets, secure API use, etc.)
- **Resilience**: Proactively implement necessary error handling and boundary checks
- **Consistency**: Reuse existing project patterns, libraries, and architectural choices

Reference: These maxims apply throughout all workflow steps and quality standards. Avoid repeating them in other sections—refer to this list as needed.

## Stateless Reducer Patterns (12-Factor Compliance)

**Stateless Agent Operations**: Each agent phase operates as a pure function with explicit inputs and outputs:

```
Agent_Output = AgentReducer(Structured_Input, Agent_Capabilities, Quality_Gates)
```

**Reducer Pattern Requirements:**

1. **No Hidden State**: All required context provided in structured XML events (see event-schema.md)
2. **Deterministic Operations**: Same input produces same output (idempotent where possible)
3. **Complete Context**: Agent can operate independently without external dependencies
4. **Explicit Outputs**: Structured results enable next phase to operate autonomously
5. **Error Boundaries**: Clear failure modes with recovery strategies

**Context Engineering Principles:**

- **Input Validation**: Validate complete context before agent execution
- **State Compression**: Minimize context to essential information between phases
- **Output Specification**: Define exact format expected from each agent
- **Handoff Integrity**: Preserve critical decisions and constraints across boundaries

**Implementation Pattern:**

```xml
<agent_input>
  <context>complete_mission_context</context>
  <constraints>all_applicable_limitations</constraints>
  <previous_outputs>structured_results_from_prior_phases</previous_outputs>
  <quality_gates>validation_requirements</quality_gates>
</agent_input>

<!-- Agent operates independently -->

<agent_output>
  <deliverables>structured_results</deliverables>
  <decisions_made>critical_choices_with_rationale</decisions_made>
  <next_phase_inputs>context_for_next_agent</next_phase_inputs>
  <quality_validation>gate_status_and_results</quality_validation>
</agent_output>
```

**Resumability Design**: Every agent output includes sufficient context for workflow restart at any point.

## Tooling & Scope Discipline

- **Preferred CLI tools**: `rg` (ripgrep), `fd`, `bat`, `sd`, `jq`, `delta`, `fzf`.
- All agents/scripts MUST use these tools for search, preview, batch replace, JSON, and diffs.
- For code/content edits and searches, use OpenCode native tools: Read/Edit/Write/Grep/Glob.
- Do not enumerate/grep entire repositories unless explicitly requested or required.
- Operate only on files/paths explicitly referenced by the user.
- Do not prescribe installation or add dependencies unless permitted by the project's `AGENTS.md`.

## Chrome MCP Auto-Start Protocol

**Before using any Chrome MCP tools, automatically ensure Chrome is running:**

```bash
# Auto-start Chrome if not running (cross-platform)
if ! pgrep -f "Google Chrome\|google-chrome\|chromium" >/dev/null 2>&1; then
  case "$(uname -s)" in
    Darwin)
      open -a "Google Chrome"
      ;;
    Linux)
      if command -v google-chrome >/dev/null 2>&1; then
        nohup google-chrome >/dev/null 2>&1 &
      elif command -v chromium >/dev/null 2>&1; then
        nohup chromium >/dev/null 2>&1 &
      fi
      ;;
  esac
  sleep 3  # Wait for Chrome to initialize
fi
```

**Automatic Integration Rules:**

- **ANY agent using Chrome MCP tools** must first run the auto-start check
- **Use user's regular Chrome browser** (not isolated profiles)
- **Preserve all logins and extensions** (especially MCP Chrome Bridge)
- **Cross-platform compatible** (macOS & Linux)
- **Idempotent** - safe to run multiple times
- **Silent operation** - minimal output unless Chrome launch fails

**Implementation:** All agents with Chrome MCP capabilities should call this auto-start logic before their first Chrome tool use.

## OpenCode Permissions & Safety Controls

Always check for project-level overrides in `AGENTS.md` before applying these rules.

- **Explicit Approval for Sensitive Actions**: All file edits and bash commands should require explicit user approval unless globally allowed in `opencode.json`.
- **Permission-Driven Automation**: The platform automatically enforces the `permission` settings in `opencode.json`; rely on the allow/ask/deny result rather than manually opening the file during routine actions.
- **Manual Config Inspection**: Only read `opencode/opencode.json` when (a) the user explicitly requests a permissions review/change, or (b) diagnosing an unexpected permission denial outcome.
- **Token-Efficient Permission Checks**: Do not include explicit permission-check steps in user-visible plans. Treat permission checks as implicit background logic and cache results per session.

## External Protocol References

This file references specialized protocols loaded via `opencode.json` instructions:

- **orchestration.md**: Multi-agent coordination, BMAD protocols, luigi planning
- **context-management.md**: Token budgeting, parallelization criteria, compression strategies
- **advanced-workflows.md**: 13-step workflow, checklist protocols, failure recovery
- **quality-tooling.md**: Quality standards, tooling hierarchy, anchor robustness

These protocols are loaded on-demand based on task complexity and requirements.

## New Protocols for Enhanced Intelligence

To make agents smarter and more adaptable, incorporate the following protocols:

### Advanced Reasoning Protocol
- Generate 2-3 hypotheses for complex queries to explore multiple angles.
- Validate each hypothesis using available tools (e.g., webfetch, grep, or Serena 'think' tools).
- Synthesize findings into actionable insights with evidence and confidence scores.
- Apply this for tasks requiring deep analysis or decision-making.

### Technical XML Handling Protocol
- Focus on structural validation and error handling for XML-based tool calls.
- Implement automated recovery for malformed XML to ensure reliability.
- Ensure compatibility with tool call standards and best practices.
- Prioritize technical integrity without enforcing specific tag formats.

### Feedback Loop Protocol
- Encourage agents to self-improve based on user interactions and past performance.
- Log successes/failures and adjust behaviors dynamically (e.g., via memory storage).
- Use this to refine responses over time and enhance user satisfaction.

## Enhanced Guidelines for Smarter Agent Behavior

- **Context Adaptability**: Agents should adjust response style, depth, and tools based on session history, user preferences, or task complexity.
- **Error Handling and Recovery**: Implement proactive escalation, automated retries, and clear failure modes for robust operations.
- **Performance Optimization**: Prioritize efficient tool usage, token management, and cross-platform compatibility to reduce latency and improve speed.
- **Security and Safety**: Reinforce with protocols for secure operations, dependency management, and vulnerability prevention.

## Serena MCP Integration

A supported Serena MCP integration package is provided in `opencode/serena-integration/`:

- **Purpose**: Examples, config and templates to integrate Serena MCP into OpenCode agents
- **Key files**: serena-agent-config.yaml (token budgets, permissions), loader-snippets/ (runtime examples), templates/ (commit & user prompt templates), verification_steps.md
- **Policy**: Commit messages must follow opencode/serena-integration/templates/commit-message-template.txt (no AI attribution)
- **Checkpoints**: Follow the three Serena MCP checkpoints (think_about_collected_information, think_about_task_adherence, think_about_whether_you_are_done) when integrating

---

> **Note**: This streamlined AGENTS.md focuses on project-specific rules and essential protocols. Complex orchestration, context management, and advanced workflow protocols are externalized to specialized files loaded via `opencode.json` instructions for optimal token efficiency.


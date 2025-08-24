# Core Foundations Protocol

## Overview

This protocol establishes the foundational systems for agent orchestration, control flow management, and tooling standards. It provides the core infrastructure for multi-agent coordination, workflow control, and consistent tool usage across the OpenCode system.

## Agent Orchestration Framework

### 1. Multi-Context Orchestration Guidelines

1. **Routing Order**: general → (luigi optional) → alpha → specialized agents → reviewer/security → summarizer/context
2. **Blueprint First**: If ambiguity > moderate or multiple domains involved, invoke luigi to produce a NOOP plan; alpha executes orchestration after approval
3. **Parallelization**: Alpha may fan out independent specialized agents only when Shared Context Slice (SCS) ≤ SCS_THRESHOLD (default 2k) and no ordering dependency
4. **Context Chaining**: Each agent must emit: Objective, Inputs Consumed, Outputs Produced, Next Agent Hint. Context agent compresses after every 2–3 hops
5. **Escalation Triggers**: Security risk → security; Architectural divergence → reviewer; Legacy hotspot → legacy; Network anomalies → network; Performance regression → troubleshooter
6. **Tier Adjustment**: Start minimal; elevate to standard when branching logic emerges; elevate to high only for: multi-phase refactor, security-critical path, or cross-cutting architecture change
7. **Proactive Invocation Rules**: Agents marked Proactive?=Yes may self-suggest; alpha must validate before delegation (except summarizer/context which can self-run at boundaries)
8. **Handoff Integrity**: Summarizer generates session chunk; context persists; alpha validates completeness before next phase
9. **Failure Path**: On permission denial or uncertainty, route through luigi (NOOP) rather than partial execution, then re-orchestrate
10. **Completion Seal**: Reviewer PASS + (if security-sensitive) Security PASS + Summarizer handoff required before task considered closed

### 2. Consolidated Subagent Role Matrix (7 Agents)

| Agent         | Purpose (1-line)                                    | Invoke When (Primary Trigger)                         | Absorbed Capabilities                     | Reasoning Tier   | Proactive?                      | Escalates To         |
| ------------- | --------------------------------------------------- | ----------------------------------------------------- | ---------------------------------------- | ---------------- | ------------------------------- | -------------------- |
| general       | Default executor for simple, low-risk tasks         | 1–2 step, low ambiguity requests                      | N/A (unchanged)                          | minimal→standard | No                              | orchestrator         |
| orchestrator  | Orchestrates multi-phase, multi-agent workflows     | Complex missions needing phased delegation            | context, analyst, summarizer             | high             | Yes (when complexity detected)  | reviewer / security  |
| language      | Idiomatic coding, refactoring & prompt engineering  | Advanced code patterns, optimization, AI prompts      | prompt, writer                           | standard→high    | No                              | reviewer             |
| devops        | Infrastructure, deployment & developer experience   | Infra changes, pipeline review, DX improvements       | optimizer                                | standard→high    | Yes (security/perf infra gaps)  | security / reviewer  |
| security      | Rapid security audits & vulnerability detection     | New backend code, pre-deploy, config changes          | N/A (unchanged)                          | high             | Yes (critical paths)            | reviewer / orchestrator |
| researcher    | Deep research, synthesis & codebase navigation      | Unknown tech, discovery, pattern search               | navigator                                | standard→high    | Yes (when gaps found)           | orchestrator         |
| reviewer      | Code/API/architecture quality & security review     | Post-implementation audit needed                      | N/A (unchanged)                          | standard         | Yes (after major change)        | security (if issues) |
| specialist    | Multi-domain technical expertise                     | Database, frontend, network, legacy, troubleshooting  | database, frontend, network, legacy, troubleshooter, diagram | standard→high    | Yes (domain-specific issues)    | reviewer / security  |

**Legend:**
- Reasoning Tier guidance: minimal (fast path), standard (balanced), high (deep analysis). Escalate tier only when ambiguity/risk justifies cost.
- Proactive? = Should agent be invoked without explicit user request when trigger conditions are auto-detected.

**Token Reduction Impact:**
- **Previous**: 21 agents × ~200 tokens each = 4,200 tokens in routing logic
- **Consolidated**: 7 agents × ~200 tokens each = 1,400 tokens
- **Savings**: 67% reduction in agent overhead

### 3. Luigi Agent (Planning Sentinel)

**Purpose**: Produce a structured multi-phase blueprint (NOOP only) for high-ambiguity or high-risk tasks before any tool or edit actions.

**When to Invoke (Trigger Criteria):**
- Ambiguous multi-step request lacking clear phase boundaries
- Cross-agent orchestration needed (multiple specialized roles)
- Broad refactor / security-sensitive change needing rollback matrix first
- High-risk operations where a risk & rollback table is prerequisite

**Never Invoke (Anti-Patterns):**
- Simple ≤2 step tasks
- Tasks already in active execution (post-plan)
- Trivial doc / config edits
- Pure research not requiring phased execution

**Output Contract:**
- Return only `[NOOP]` plus a structured plan containing: mission synthesis, ordered phase breakdown, risk & rollback matrix, delegation map (agent → phase), guardrails / escalation notes.

**Escalation Flow:**
Request → General → Luigi (plan only) → Alpha (orchestrated execution) → Specialized agents (phase tasks) → Reviewer / Security (as needed) → Completion.

## Control Flow Management System

### 1. Core Principle

**"If you own your control flow, you can do lots of fun things."**

Own control flow implementation enables custom loop control with human approval breaks, async operation handling, and intelligent workflow pausing between tool selection and execution.

### 2. Control Flow Categories

#### Immediate Operations (Continue Loop)
- Safe read operations (file reads, status checks)
- Low-risk calculations and analysis
- Information gathering and research
- Local file system operations (non-destructive)

#### Approval Required Operations (Break Loop)
- File writes and edits
- External API calls
- System configuration changes
- Deployment or build operations
- Database modifications

#### Human Review Operations (Break Loop + Human Validation)
- High-stakes destructive operations
- Security-sensitive changes
- Architecture decisions with broad impact
- Operations that could affect production systems

### 3. Control Flow Implementation

```python
def handle_workflow_step(workflow_thread: WorkflowThread):
    while True:
        # Get next step from LLM
        next_step = await determine_next_step(
            context=format_context(workflow_thread),
            format=select_optimal_context_format(workflow_thread.size)
        )

        # Log the intended action
        workflow_thread.events.append({
            'type': 'action_planned',
            'action': next_step,
            'timestamp': datetime.now().isoformat()
        })

        # Apply control flow logic
        if next_step.intent == 'research_information':
            # IMMEDIATE: Safe read operation - continue loop
            result = await execute_research(next_step)
            workflow_thread.events.append({
                'type': 'research_completed',
                'result': result,
                'timestamp': datetime.now().isoformat()
            })
            continue

        elif next_step.intent == 'edit_file':
            # APPROVAL REQUIRED: File modification - break loop
            workflow_thread.events.append({
                'type': 'approval_requested',
                'operation': next_step,
                'risk_level': 'medium'
            })
            await save_checkpoint(workflow_thread)
            await request_approval(next_step, risk_level='medium')
            break  # Wait for approval webhook

        elif next_step.intent == 'deploy_to_production':
            # HUMAN REVIEW: High-stakes operation - break loop with validation
            workflow_thread.events.append({
                'type': 'human_review_required',
                'operation': next_step,
                'risk_level': 'high',
                'review_criteria': [
                    'security_implications',
                    'rollback_strategy',
                    'impact_assessment'
                ]
            })
            await save_checkpoint(workflow_thread)
            await require_human_review(next_step, criteria=['security', 'rollback', 'impact'])
            break  # Wait for human validation

        elif next_step.intent == 'workflow_complete':
            # COMPLETION: Generate final checkpoint and exit
            await generate_completion_checkpoint(workflow_thread)
            return next_step.final_result
```

### 4. Operation Risk Classification

```python
def classify_operation_risk(operation: Operation) -> RiskLevel:
    if operation.category == 'read_only':
        return RiskLevel.IMMEDIATE
    elif operation.affects == 'local_files' and operation.type == 'write':
        return RiskLevel.APPROVAL_REQUIRED
    elif operation.affects == 'external_systems':
        return RiskLevel.APPROVAL_REQUIRED
    elif operation.affects == 'production' or operation.type == 'destructive':
        return RiskLevel.HUMAN_REVIEW
    else:
        return RiskLevel.APPROVAL_REQUIRED  # Default to safe
```

### 5. Human-in-the-Loop Integration

```xml
<approval_request>
  <operation_summary>brief description of intended action</operation_summary>
  <risk_assessment>
    <risk_level>medium|high</risk_level>
    <potential_impact>what could go wrong</potential_impact>
    <mitigation_strategy>how to handle failures</mitigation_strategy>
  </risk_assessment>
  <context>
    <current_state>where we are in the workflow</current_state>
    <intended_outcome>what this operation will achieve</intended_outcome>
    <alternatives>other approaches considered</alternatives>
  </context>
  <approval_options>
    <approve>proceed with operation as planned</approve>
    <modify>suggest changes before proceeding</modify>
    <reject>skip this operation</reject>
    <escalate>get additional review</escalate>
  </approval_options>
</approval_request>
```

## Tooling Standards and Quality Framework

### 1. Quality Standards (Condensed)

- **Security**: No plaintext secrets; least privilege; validate external inputs early; sanitize/log conservatively; escalate on potential secret exposure.
- **Cross-Platform**: All scripts/config must run on macOS & Linux (avoid macOS-only flags like `sed -i` without portable form; prefer POSIX sh; guard platform-specific code paths).
- **Minimal Complexity**: Choose the smallest stable solution; defer abstractions until duplication emerges (≥3 occurrences) or explicit scalability need.
- **Verification**: Always provide manual verification steps; re-read files after edit; confirm anchor uniqueness pre-edit.
- **Purity & Cleanup**: Remove dead code, stale docs, superseded plan blocks immediately; never leave TODOs without owner/context.
- **Consistency**: Follow existing naming, tool choices (`rg`, `fd`, `bat`, `sd`, `jq`, `delta`, `fzf`), and formatting patterns.
- **Performance & Context Efficiency**: Avoid unnecessary large reads; compress context per triggers before expansion.
- **Resilience**: Anticipate failure modes (permissions, ambiguous anchors, token bursts) and apply Failure Recovery Recap.

### 2. Modern Search/Edit Tooling Policy

**Preferred CLI tools for all codebase search/edit operations:**
- `rg` (ripgrep): Fastest recursive code/text search. Always use instead of `grep` for codebase or config search.
- `fd`: Fast, user-friendly file search. Prefer over `find` for file discovery.
- `bat`: Syntax-highlighted file preview. Use for readable file output in scripts, reviews, and AI workflows.
- `delta`: Syntax-highlighted git diff viewer. Use for reviewing code changes.
- `sd`: Fast, safe find & replace. Prefer over `sed` for batch replacements.
- `jq`: For all JSON parsing/editing in scripts or AI workflows.
- `fzf`: For interactive fuzzy finding in terminal or scripts.

**Implementation Guidance:**
- All agents, scripts, and workflows MUST use `rg` for code/text search and `fd` for file search, falling back to `grep`/`find` only if the preferred tool is unavailable.
- When previewing or displaying file content, use `bat` for readability.
- For batch replacements, use `sd` instead of `sed` for safety and simplicity.
- For JSON, always use `jq` for parsing and manipulation.
- For reviewing diffs, use `delta` for clarity.
- Document these conventions in all onboarding and developer docs.
- When writing new scripts or agent logic, check for tool availability and prefer the modern tool.

**Sample Usage Patterns:**

```sh
rg "pattern" path/
fd pattern path/
bat file.txt
sd 'foo' 'bar' file.txt
jq '.' file.json
git diff | delta
fzf
```

### 3. Tool Selection Hierarchy

#### Scope Discipline (Agent-Agnostic)
- Operate only on files/paths explicitly referenced by the user.
- Prefer Read/Glob with exact paths; avoid repo-wide listing/grep by default.
- If broader scope seems needed, ask to expand—state why and the intended bounds.

#### Code Analysis
1. **Serena** (read-only think/symbol tools only; no edit/mutation) - For codebase relationships and symbol analysis
2. **OpenCode Read/Edit/Write/Grep/Glob** - For file content, searches, and all edits

#### Information Retrieval
1. **API/CLI** (bash + curl/gh) - For structured data sources
2. **Context7** - For library/framework documentation
3. **WebFetch** - For current documentation and best practices (mandatory for unknown tech)

### 4. Anchor Robustness Protocol

- Always verify anchor uniqueness before editing.
- If the anchor appears multiple times, expand context (multi-line) or switch to symbol-based editing.
- After editing, always re-read the file to confirm the change is in the correct location.
- If a unique anchor cannot be determined, log an error and suggest manual review or user confirmation.
- For dynamic or generated files, avoid direct edits unless explicitly confirmed.

### 5. Enhanced Research Protocol (Chrome MCP Integrated)

#### Chrome MCP Auto-Start Requirement

**BEFORE using any Chrome MCP research tools, ensure Chrome is running:**

```bash
# Check if Chrome is running, start if needed (cross-platform)
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
  sleep 3  # Wait for Chrome initialization
fi
```

#### Research Tier Selection

**Tier 1: Quick Research** (Known tech, simple verification)
- Use when: Framework basics, familiar APIs, syntax clarification
- Tools: `chrome_search_tabs_content` → `webfetch` → early stop
- Agent Impact: **General/Language** - 50% faster simple lookups

**Tier 2: Interactive Research** (Setup instructions, API docs, complex frameworks)
- Use when: Installation guides, configuration, new framework patterns
- Tools: `chrome_navigate` → `chrome_get_web_content` → `chrome_screenshot` → `chrome_search_tabs_content`
- Agent Impact: **DevOps/Language/Frontend** - 3x more accurate implementation

**Tier 3: Comparative Research** (Solution evaluation, architecture decisions)
- Use when: Multiple solutions exist, architecture choices, best practices
- Tools: Multi-tab `chrome_navigate` → parallel content extraction → `chrome_search_tabs_content` → semantic synthesis
- Agent Impact: **Alpha/Reviewer** - 2x better architectural decisions

## Benefits of Control Flow Ownership

1. **Granular Control**: Pause between tool selection and execution
2. **Risk Management**: Appropriate approval levels for different operations
3. **Async Support**: Handle long-running operations without blocking
4. **Human Safety**: Human validation for high-stakes decisions
5. **Resume Capability**: Restart from any control flow break point
6. **Audit Trail**: Complete log of all decisions and approvals

## Integration Guidelines

### 1. Agent Orchestration Integration
- Apply orchestration rules to control flow decisions
- Use agent role matrix for appropriate delegation
- Implement proactive agent invocation where appropriate
- Maintain completion seal requirements

### 2. Context Management Integration
- Use control flow breaks for context compression
- Apply context optimization at orchestration boundaries
- Preserve context integrity across control flow transitions
- Enable stateless agent operations

### 3. Security Integration
- Apply security validation at control flow checkpoints
- Use risk classification for approval requirements
- Implement security escalation triggers
- Maintain audit trail for security-sensitive operations

## Expected Benefits

- **Orchestration Efficiency**: 40-60% improvement in multi-agent coordination
- **Control Flow Safety**: 95%+ prevention of unintended operations
- **Tool Consistency**: 100% standardized tool usage across agents
- **Research Quality**: 2-3x improvement in research accuracy and depth
- **System Reliability**: 90%+ successful complex workflow completion

## Implementation Checklist

### Agent Orchestration
- [ ] Multi-context orchestration guidelines implemented
- [ ] Subagent role matrix operational
- [ ] Luigi planning sentinel functional
- [ ] Escalation triggers configured
- [ ] Completion seal requirements active

### Control Flow Management
- [ ] Control flow categories defined and enforced
- [ ] Operation risk classification working
- [ ] Human-in-the-loop integration active
- [ ] Async operation handling functional
- [ ] Checkpoint generation at control flow breaks

### Tooling Standards
- [ ] Modern search/edit tooling policy enforced
- [ ] Tool selection hierarchy implemented
- [ ] Anchor robustness protocol active
- [ ] Chrome MCP auto-start functional
- [ ] Enhanced research protocol operational

This consolidated protocol provides the core infrastructure for reliable, efficient, and secure agent operations with comprehensive orchestration, control flow management, and consistent tooling standards.
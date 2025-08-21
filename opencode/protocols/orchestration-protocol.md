# Agent Orchestration Protocols

## Multi-Context Orchestration Guidelines

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

## Subagent Role Matrix

| Agent           | Purpose (1-line)                                 | Invoke When (Primary Trigger)                         | Avoid / Not For                              | Reasoning Tier   | Proactive?                      | Escalates To         |
| --------------- | ------------------------------------------------ | ----------------------------------------------------- | -------------------------------------------- | ---------------- | ------------------------------- | -------------------- |
| general         | Default executor for simple, low-risk tasks      | 1–2 step, low ambiguity requests                      | Deep analysis, multi-phase orchestration     | minimal→standard | No                              | alpha                |
| alpha           | Orchestrates multi-phase, multi-agent workflows  | Complex missions needing phased delegation            | Direct feature implementation of atomic task | high             | Yes (when complexity detected)  | reviewer / security  |
| luigi           | NOOP planning sentinel & safe pause              | High ambiguity; need blueprint before action          | Actual execution, trivial edits              | minimal          | No                              | alpha                |
| analyst         | Analyze context mgmt, caching, billing           | Need insight into token/billing/caching behavior      | Direct code edits or orchestration           | standard→high    | Yes (periodic audits)           | optimizer / alpha    |
| context         | Maintain & distribute long-running session state | Project/session >10k tokens or multi-agent continuity | Feature implementation, security audit       | standard         | Yes (size/complexity threshold) | alpha                |
| database-expert | SQL, schema, migrations, DB tuning               | Schema design, query perf, migration planning         | General app logic, frontend UI               | standard→high    | No (on-demand)                  | reviewer             |
| devops          | Docker, IaC, deployment, pipeline optimization   | Infra changes, container/pipeline review              | Pure business logic or minor code tweaks     | standard→high    | Yes (security/perf infra gaps)  | security / reviewer  |
| frontend-uiux   | UI components, UX flows, accessibility           | Building/auditing frontend or UX design               | Backend-only tasks, DB tuning                | standard         | No                              | reviewer             |
| language        | Idiomatic multi-language coding & refactors      | Need advanced code patterns or optimization           | Pure orchestration, UX design                | standard→high    | No                              | reviewer             |
| legacy          | Incremental modernization & migration            | Refactoring outdated frameworks / tech debt           | Greenfield feature w/ modern stack           | high             | Yes (legacy hotspots)           | security / reviewer  |
| navigator       | Locate files, patterns, architecture mapping     | Need codebase discovery / pattern search              | Writing new features directly                | minimal→standard | No                              | alpha                |
| network         | Connectivity, DNS, SSL/TLS, traffic analysis     | Network issues, perf/bottleneck, load balancing       | Pure application logic                       | standard→high    | Yes (network anomalies)         | security             |
| optimizer       | Developer experience & workflow improvements     | Friction, slow onboarding, repetitive toil            | Product feature implementation               | standard         | Yes (detecting DX friction)     | reviewer             |
| prompt          | Optimize LLM/system prompts                      | Creating/improving AI prompts/pipelines               | General coding, infra changes                | standard→high    | No                              | reviewer             |
| researcher      | Deep web/code research & synthesis               | Unknown tech, ambiguous domain questions              | Simple known tasks                           | standard→high    | Yes (when gaps found)           | alpha                |
| reviewer        | Code/API/architecture quality & security review  | Post-implementation audit needed                      | Planning or execution of changes             | standard         | Yes (after major change)        | security (if issues) |
| security        | Rapid security audits & vuln detection           | New backend code, pre-deploy, config changes          | Non-security cosmetic review                 | high             | Yes (critical paths)            | reviewer / alpha     |
| summarizer      | Concise actionable session/project summaries     | Need continuity or handoff clarity                    | Deep technical refactor                      | minimal→standard | Yes (handoffs)                  | context              |
| troubleshooter  | Debugging, performance, incident response        | Failures, outages, perf regressions                   | Planned feature dev                          | standard→high    | Yes (incident triggers)         | reviewer / optimizer |
| diagram         | Visual content analysis & automated diagram gen  | Content needs visual representation, architecture docs | Simple text responses, non-visual tasks     | standard→high    | Yes (architectural doc gaps)    | reviewer             |
| writer          | Essential dev-focused documentation              | After new feature/refactor needing docs               | Brainstorming architecture plans             | minimal→standard | Yes (post-change)               | reviewer             |

**Legend:**
- Reasoning Tier guidance: minimal (fast path), standard (balanced), high (deep analysis). Escalate tier only when ambiguity/risk justifies cost.
- Proactive? = Should agent be invoked without explicit user request when trigger conditions are auto-detected.

## Luigi Agent (Planning Sentinel)

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

**Example Invocation (conceptual):**
`/plan "Refactor legacy auth module across services: add MFA with rollback strategy"`

**Related Agents**: Alpha, Legacy, Security, Reviewer

## Context Rot Integration

This protocol incorporates Context Rot research findings for optimal information structure. For detailed implementation guidance, see `context-rot-protocol.md`.

### Key Integration Points
- **Critical Information Placement**: Position most important information in the first 25% of context
- **Information Organization**: Use clear boundaries and semantic clustering
- **Structure Optimization**: Maintain optimal block sizes and information density
- **Dynamic Management**: Adapt structure based on context length and performance feedback

### Reference Implementation
See `context-rot-protocol.md` for complete information structure guidelines and optimization strategies.
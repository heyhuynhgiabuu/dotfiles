# Orchestration Advanced Protocol

**LOAD TRIGGER**: Multi-agent coordination required, complex missions needing phased delegation, or luigi planning needed.

## Multi-Context Orchestration Guidelines

1. **Routing Order**: general → (luigi optional) → orchestrator → specialized agents → reviewer/security
2. **Blueprint First**: If ambiguity > moderate or multiple domains involved, invoke luigi for NOOP plan
3. **Parallelization**: Fan out independent specialized agents only when SCS ≤ 2000 tokens and no ordering dependency
4. **Context Chaining**: Each agent must emit: Objective, Inputs Consumed, Outputs Produced, Next Agent Hint
5. **Escalation Triggers**: Security risk → security; Architectural divergence → reviewer; Domain expertise → specialist
6. **Tier Adjustment**: Start minimal; elevate to standard when branching logic emerges; high only for multi-phase refactor, security-critical path, or cross-cutting architecture change
7. **Proactive Invocation**: Agents marked Proactive=Yes may self-suggest; orchestrator validates before delegation
8. **Handoff Integrity**: Validate completeness before next phase
9. **Failure Path**: On permission denial or uncertainty, route through luigi (NOOP) rather than partial execution
10. **Completion Seal**: Reviewer PASS + (if security-sensitive) Security PASS required before task closed

## 7-Agent Routing Matrix

| Agent | Purpose | Invoke When | Reasoning Tier | Proactive? | Escalates To |
|-------|---------|-------------|----------------|------------|--------------|
| general | Default executor for simple tasks | 1–2 step, low ambiguity | minimal→standard | No | orchestrator |
| orchestrator | Multi-phase, multi-agent workflows | Complex missions needing phased delegation | high | Yes (complexity detected) | reviewer/security |
| language | Coding, refactoring, prompt engineering | Advanced code patterns, optimization, AI prompts | standard→high | No | reviewer |
| specialist | Multi-domain technical expertise | Database, frontend, network, legacy, troubleshooting | standard→high | Yes (domain-specific issues) | reviewer/security |
| researcher | Deep research, codebase navigation | Unknown tech, discovery, pattern search | standard→high | Yes (gaps found) | orchestrator |
| devops | Infrastructure, deployment, DX | Infra changes, pipeline review, DX improvements | standard→high | Yes (security/perf gaps) | security/reviewer |
| security | Security audits & vulnerability detection | New backend code, pre-deploy, config changes | high | Yes (critical paths) | reviewer/orchestrator |
| reviewer | Code/API/architecture quality review | Post-implementation audit needed | standard | Yes (after major change) | security (if issues) |

## Luigi Agent (Planning Sentinel)

**Purpose**: Produce structured multi-phase blueprint (NOOP only) for high-ambiguity or high-risk tasks.

**When to Invoke:**
- Ambiguous multi-step request lacking clear phase boundaries
- Cross-agent orchestration needed (multiple specialized roles)
- Broad refactor/security-sensitive change needing rollback matrix first
- High-risk operations requiring risk & rollback table

**Output Contract:**
Return only `[NOOP]` plus structured plan: mission synthesis, ordered phase breakdown, risk & rollback matrix, delegation map (agent → phase), guardrails/escalation notes.

**Escalation Flow:**
Request → General → Luigi (plan only) → Orchestrator (execution) → Specialized agents → Reviewer/Security → Completion

## Event-Driven Agent Communication

```xml
<agent_handoff>
  <meta>
    <source_agent>current_agent</source_agent>
    <target_agent>next_agent</target_agent>
    <handoff_reason>why_delegating</handoff_reason>
  </meta>
  <context>
    <objective>what_needs_to_be_accomplished</objective>
    <inputs_consumed>what_current_agent_processed</inputs_consumed>
    <outputs_produced>what_current_agent_delivered</outputs_produced>
    <next_agent_hint>specific_guidance_for_next_agent</next_agent_hint>
  </context>
  <state>
    <progress_so_far>completed_work_summary</progress_so_far>
    <remaining_work>what_still_needs_doing</remaining_work>
    <constraints>limitations_and_requirements</constraints>
    <escalation_conditions>when_to_escalate_and_to_whom</escalation_conditions>
  </state>
</agent_handoff>
```

## Control Flow Management

### Operation Categories
- **Immediate Operations**: Safe reads, analysis, research (continue loop)
- **Approval Required**: File edits, external APIs, system changes (break loop)
- **Human Review**: High-stakes destructive operations, security-sensitive changes (break loop + validation)

### Risk Classification
- **Low Risk**: Read-only operations → Immediate execution
- **Medium Risk**: Local file modifications → Approval required
- **High Risk**: Production/security impact → Human review required

### Human-in-the-Loop Integration
```xml
<approval_request>
  <operation_summary>brief description of intended action</operation_summary>
  <risk_assessment>
    <risk_level>medium|high</risk_level>
    <potential_impact>what could go wrong</potential_impact>
    <mitigation_strategy>how to handle failures</mitigation_strategy>
  </risk_assessment>
  <approval_options>
    <approve>proceed with operation as planned</approve>
    <modify>suggest changes before proceeding</modify>
    <reject>skip this operation</reject>
    <escalate>get additional review</escalate>
  </approval_options>
</approval_request>
```

## Benefits of Control Flow Ownership
1. **Granular Control**: Pause between tool selection and execution
2. **Risk Management**: Appropriate approval levels for different operations
3. **Async Support**: Handle long-running operations without blocking
4. **Human Safety**: Human validation for high-stakes decisions
5. **Resume Capability**: Restart from any control flow break point
6. **Audit Trail**: Complete log of all decisions and approvals

This protocol provides comprehensive multi-agent orchestration with intelligent routing, control flow management, and human-in-the-loop safety for complex coordinated workflows.
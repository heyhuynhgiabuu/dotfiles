# Advanced Workflow Protocols (12-Factor Enhanced)

## Pause/Resume Checkpoint Architecture (Factor 6)

**Checkpoint Generation Strategy**: Enable workflow resumption from any major phase boundary using structured state persistence.

### Checkpoint Types

**1. Phase Boundary Checkpoints** (Mandatory)
Generated after each major workflow phase (stages 1, 2, 3):

```xml
<workflow_checkpoint>
  <checkpoint_id>workflow_[id]_stage_[n]_complete</checkpoint_id>
  <timestamp>ISO_8601_format</timestamp>
  <workflow_state>
    <stage_completed>mission_planning|implementation|verification</stage_completed>
    <next_stage>implementation|verification|complete</next_stage>
    <progress_percentage>33|67|100</progress_percentage>
  </workflow_state>
  <context_snapshot>
    <mission>original_user_request_and_objective</mission>
    <decomposition>phase_breakdown_with_dependencies</decomposition>
    <critical_decisions>
      <decision id="architecture">chosen_approach_with_rationale</decision>
      <decision id="technology">selected_tools_and_libraries</decision>
    </critical_decisions>
    <implementation_artifacts>
      <artifact>file_created_or_modified</artifact>
      <artifact>configuration_change</artifact>
    </implementation_artifacts>
    <quality_status>
      <verification_results>security_cross_platform_code_review</verification_results>
      <remaining_tasks>items_still_pending</remaining_tasks>
    </quality_status>
  </context_snapshot>
  <resume_instructions>
    <next_step>specific_action_to_take</next_step>
    <required_context>information_needed_for_continuation</required_context>
    <validation_required>context_integrity_check</validation_required>
  </resume_instructions>
</workflow_checkpoint>
```

**2. User Approval Checkpoints** (As Needed)
Generated when user decision impacts workflow direction:

```xml
<approval_checkpoint>
  <checkpoint_id>workflow_[id]_approval_[decision_point]</checkpoint_id>
  <decision_required>
    <decision_type>architecture_choice|technology_selection|approach_validation</decision_type>
    <options>
      <option id="1" pros="benefits" cons="limitations">approach_description</option>
      <option id="2" pros="benefits" cons="limitations">alternative_approach</option>
    </options>
    <recommendation>preferred_option_with_rationale</recommendation>
  </decision_required>
  <context_for_decision>
    <analysis_complete>research_and_impact_assessment</analysis_complete>
    <trade_offs>detailed_comparison_of_approaches</trade_offs>
    <implications>long_term_consequences_of_choice</implications>
  </context_for_decision>
  <workflow_continuation>
    <on_approval>continue_with_implementation</on_approval>
    <on_rejection>return_to_planning_with_feedback</on_rejection>
    <on_modification>adjust_approach_based_on_input</on_modification>
  </workflow_continuation>
</approval_checkpoint>
```

**3. Error Recovery Checkpoints** (Automatic)
Generated when workflow encounters blocking issues:

```xml
<error_checkpoint>
  <checkpoint_id>workflow_[id]_error_[error_type]</checkpoint_id>
  <error_context>
    <error_type>permission_denied|dependency_missing|context_overflow|anchor_ambiguity</error_type>
    <error_location>specific_step_or_phase_where_error_occurred</error_location>
    <attempted_resolution>what_was_tried_to_resolve</attempted_resolution>
    <partial_completion>work_completed_before_error</partial_completion>
  </error_context>
  <recovery_strategy>
    <immediate_options>
      <option priority="high">retry_with_adjusted_parameters</option>
      <option priority="medium">escalate_to_specialized_agent</option>
      <option priority="low">request_user_intervention</option>
    </immediate_options>
    <rollback_required>true|false</rollback_required>
    <context_integrity>preserved|needs_reconstruction</context_integrity>
  </recovery_strategy>
  <resume_plan>
    <recovery_steps>specific_actions_to_resolve_error</recovery_steps>
    <validation_steps>how_to_verify_resolution</validation_steps>
    <continuation_point>where_to_resume_workflow</continuation_point>
  </resume_plan>
</error_checkpoint>
```

### Checkpoint Persistence Strategy

**Memory Storage**: Store checkpoints using the serena memory system for cross-session persistence:

```
serena_write_memory(
  memory_name="workflow_[id]_checkpoint_[timestamp]",
  content=structured_checkpoint_xml
)
```

**Context Compression**: Minimize checkpoint size while preserving critical information:
- Compress verbose reasoning into bullet outcomes
- Abstract repeated patterns into references
- Maintain complete context for autonomous resumption
- Preserve all critical decisions and constraints

### Resume Validation Protocol

**Before resuming any workflow from checkpoint:**

1. **Context Integrity Check**: Validate that all referenced files, decisions, and constraints are still valid
2. **Environment Verification**: Confirm that dependencies, permissions, and platform requirements remain unchanged
3. **Progress Validation**: Verify that completed steps are still in expected state
4. **Agent Capability Check**: Ensure required agents and tools are available for continuation

**Resume Workflow**:
```xml
<resume_validation>
  <checkpoint_validity>
    <context_current>true|false</context_current>
    <dependencies_available>true|false</dependencies_available>
    <progress_intact>true|false</progress_intact>
    <agent_capabilities>verified|needs_update</agent_capabilities>
  </checkpoint_validity>
  <resume_action>
    <validation_passed>continue_from_checkpoint</validation_passed>
    <validation_failed>reconstruct_context_and_retry</validation_failed>
    <partial_validity>selective_replay_from_last_valid_point</partial_validity>
  </resume_action>
</resume_validation>
```

## Control Flow Ownership (Factor 8) 

**Core Principle**: "If you own your control flow, you can do lots of fun things."

Own control flow implementation enables custom loop control with human approval breaks, async operation handling, and intelligent workflow pausing between tool selection and execution.

### Control Flow Categories

**Immediate Operations** (Continue Loop):
- Safe read operations (file reads, status checks)
- Low-risk calculations and analysis
- Information gathering and research
- Local file system operations (non-destructive)

**Approval Required Operations** (Break Loop):
- File writes and edits
- External API calls
- System configuration changes
- Deployment or build operations
- Database modifications

**Human Review Operations** (Break Loop + Human Validation):
- High-stakes destructive operations
- Security-sensitive changes
- Architecture decisions with broad impact
- Operations that could affect production systems

### Control Flow Implementation

**Core Loop Structure**:
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
            
        elif next_step.intent == 'request_clarification':
            # ASYNC: Human input needed - break loop
            workflow_thread.events.append({
                'type': 'clarification_requested',
                'question': next_step.question
            })
            await save_checkpoint(workflow_thread)
            await request_user_input(next_step.question)
            break  # Wait for user response
            
        elif next_step.intent == 'workflow_complete':
            # COMPLETION: Generate final checkpoint and exit
            await generate_completion_checkpoint(workflow_thread)
            return next_step.final_result
```

### Operation Risk Classification

**Risk Assessment Matrix**:
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

**Custom Control Flow Examples**:

1. **Development Workflow**:
```python
# Research (immediate) → Planning (immediate) → Implementation (approval) → Testing (approval) → Deployment (human review)
```

2. **Security Audit**:
```python
# Code Analysis (immediate) → Vulnerability Detection (immediate) → Fix Recommendations (approval) → Apply Fixes (human review)
```

3. **Architecture Decision**:
```python
# Requirements Analysis (immediate) → Option Research (immediate) → Impact Assessment (immediate) → Decision Recommendation (human review)
```

### Async Operation Handling

**Long-Running Operations**:
```python
async def handle_long_running_operation(workflow_thread: WorkflowThread, operation: Operation):
    # Start operation
    workflow_thread.events.append({
        'type': 'long_operation_started',
        'operation_id': operation.id,
        'estimated_duration': operation.estimated_time
    })
    
    # Save checkpoint before starting
    await save_checkpoint(workflow_thread)
    
    # Initiate operation (CI/CD, training, external API, etc.)
    task_id = await start_async_operation(operation)
    
    # Break loop - will resume via webhook when complete
    await register_completion_webhook(task_id, workflow_thread.id)
    return 'PAUSED_FOR_ASYNC_OPERATION'
```

**Resume After Async Operation**:
```python
async def handle_async_completion(webhook_data: WebhookData):
    workflow_thread = await load_workflow(webhook_data.workflow_id)
    
    # Add completion event
    workflow_thread.events.append({
        'type': 'async_operation_completed',
        'operation_id': webhook_data.operation_id,
        'result': webhook_data.result,
        'success': webhook_data.success
    })
    
    # Resume workflow from checkpoint
    await resume_workflow(workflow_thread)
```

### Human-in-the-Loop Integration

**Approval Request Format**:
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

### Benefits of Control Flow Ownership

1. **Granular Control**: Pause between tool selection and execution
2. **Risk Management**: Appropriate approval levels for different operations
3. **Async Support**: Handle long-running operations without blocking
4. **Human Safety**: Human validation for high-stakes decisions
5. **Resume Capability**: Restart from any control flow break point
6. **Audit Trail**: Complete log of all decisions and approvals

**Integration with Checkpoints**: Every control flow break generates an automatic checkpoint, enabling seamless resumption when operations complete or approvals are granted.

## The 13-Step Structured Workflow

Use for complex tasks requiring comprehensive analysis and implementation.

### Stage 1: Mission & Planning (##1-7)

## 1. Mission Understanding

- Analyze user request beyond surface level
- Identify fundamental problem and ultimate goal
- Synthesize core intent, rationale, and critical nuances
- Internal Question: "What outcome do they truly want?"

## 2. Mission Decomposition

- Use EmpiricalRigor to decompose into granular, SMART phases and tasks
- Create sequential dependency-ordered breakdown
- Format: `### Phase {num}: {name}` → `#### {phase}.{task}: {description}`

Example:

```markdown
### Phase 1: Setup Environment

#### 1.1: Install dependencies

#### 1.2: Configure .env file

### Phase 2: Implement Feature

#### 2.1: Write function to parse input

#### 2.2: Add error handling
```

## 3. Pre-existing Tech Analysis

- Proactively search workspace files for relevant existing elements
- Identify reusable patterns, libraries, architectural choices
- Apply Consistency maxim to avoid duplication

## 4. Research & Verification

- THE PROBLEM CANNOT BE SOLVED WITHOUT EXTENSIVE INTERNET RESEARCH
- Your knowledge is out of date - verify everything with current documentation
- Use webfetch to research libraries, frameworks, dependencies
- Recursively gather information by fetching additional links until complete understanding
- Apply EmpiricalRigor - never proceed on assumptions

## 5. Tech to Introduce

- State final choices for NEW technology/dependencies to add
- Link to requirements identified in Mission and Decomposition
- Justify each addition based on research

## 6. Pre-Implementation Synthesis

- High-level executive summary of solution approach
- Mental practice-run referencing elements from ##1-5
- "In order to fulfill X, I will do Y using Z"

## 7. Impact Analysis

- Evaluate code signature changes, performance implications, security risks
- Conduct adversarial self-critique (Red Team analysis)
- Theorize mitigations for identified risks
- Apply Impenetrability and Resilience maxims

## 7.1. Stage 1 Checkpoint Generation

**MANDATORY**: Generate phase boundary checkpoint after completing mission planning:

```xml
<workflow_checkpoint>
  <checkpoint_id>workflow_[timestamp]_stage_1_complete</checkpoint_id>
  <workflow_state>
    <stage_completed>mission_planning</stage_completed>
    <next_stage>implementation</next_stage>
    <progress_percentage>33</progress_percentage>
  </workflow_state>
  <context_snapshot>
    <mission>synthesized_objective_from_step_1</mission>
    <decomposition>phase_breakdown_from_step_2</decomposition>
    <tech_analysis>existing_patterns_from_step_3</tech_analysis>
    <research_results>verified_information_from_step_4</research_results>
    <technology_decisions>new_tech_selections_from_step_5</technology_decisions>
    <approach_summary>synthesis_from_step_6</approach_summary>
    <impact_assessment>risks_and_mitigations_from_step_7</impact_assessment>
  </context_snapshot>
  <resume_instructions>
    <next_step>begin_implementation_trajectory_step_8</next_step>
    <required_context>complete_planning_context_above</required_context>
    <validation_required>verify_tech_decisions_still_valid</validation_required>
  </resume_instructions>
</workflow_checkpoint>
```

Store checkpoint: `serena_write_memory("workflow_[id]_stage_1_checkpoint", checkpoint_xml)`

### Stage 2: Implementation (##8-10)

## 8. Implementation Trajectory

- Decompose plan into highly detailed, practically-oriented implementation workload
- Use DecompositionProtocol for granular task breakdown
- Register EVERY task for progress tracking

## 9. Implementation

- Execute each task with surgical precision
- Use sub-headings: `## 9.{phase}.{task}: {description}`
- Apply AppropriateComplexity - robust but not over-engineered
- Continuously employ tools for emergent ambiguities
- Format phases as `## 9.{phase_number}: {phase_name}`

## 10. Cleanup Actions

- Apply PurityAndCleanliness - remove ALL obsolete artifacts
- Ensure code signature changes propagate to callers
- State "N/A" if no cleanup required

## 10.1. Stage 2 Checkpoint Generation

**MANDATORY**: Generate phase boundary checkpoint after completing implementation:

```xml
<workflow_checkpoint>
  <checkpoint_id>workflow_[timestamp]_stage_2_complete</checkpoint_id>
  <workflow_state>
    <stage_completed>implementation</stage_completed>
    <next_stage>verification</next_stage>
    <progress_percentage>67</progress_percentage>
  </workflow_state>
  <context_snapshot>
    <implementation_workload>detailed_tasks_from_step_8</implementation_workload>
    <implementation_results>completed_work_from_step_9</implementation_results>
    <cleanup_actions>artifacts_removed_from_step_10</cleanup_actions>
    <files_modified>list_of_changed_files_with_purposes</files_modified>
    <configuration_changes>system_or_environment_modifications</configuration_changes>
  </context_snapshot>
  <resume_instructions>
    <next_step>begin_formal_verification_step_11</next_step>
    <required_context>implementation_artifacts_and_decisions</required_context>
    <validation_required>verify_implementation_integrity</validation_required>
  </resume_instructions>
</workflow_checkpoint>
```

Store checkpoint: `serena_write_memory("workflow_[id]_stage_2_checkpoint", checkpoint_xml)`

### Stage 3: Verification & Completion (##11-13)

## 11. Formal Verification

```markdown
---
**VERIFICATION CHECKLIST**
* Self-reflection: Results from Serena 'think' tools (collected_information, task_adherence, whether_you_are_done) are logged and reviewed.
* Anchor verified: All edits made at correct, intended locations?
* Workload complete: {ENTIRE workload from ##2 and ##8 fully implemented?}
* Impact handled: {All impacts from ##7 properly mitigated?}
* Quality assured: {Code adheres to ALL maxims and standards?}
* Cleanup performed: {PurityAndCleanliness enforced?}
* Tests passing: {All existing tests still pass?}

Final Outcome:
- Status: {PASS/PARTIAL/FAIL - ALL checks must PASS}
- Verdict: {Concise summary or remaining issues}
---
```

## 12. Suggestions

- Ideas/features correctly excluded per AppropriateComplexity
- Alternative approaches identified during implementation
- Future enhancement opportunities
- State "N/A" if no suggestions

## 13. Summary

- Brief restatement of mission accomplishment
- Key elements cleaned up for future reference
- Notable resolutions or patterns established

## 13.1. Final Checkpoint Generation

**MANDATORY**: Generate final checkpoint after workflow completion:

```xml
<workflow_checkpoint>
  <checkpoint_id>workflow_[timestamp]_complete</checkpoint_id>
  <workflow_state>
    <stage_completed>verification_and_completion</stage_completed>
    <next_stage>complete</next_stage>
    <progress_percentage>100</progress_percentage>
  </workflow_state>
  <context_snapshot>
    <verification_results>formal_verification_outcomes_from_step_11</verification_results>
    <suggestions>recommendations_from_step_12</suggestions>
    <final_summary>mission_accomplishment_from_step_13</final_summary>
    <deliverables>
      <deliverable>final_implementation_with_location</deliverable>
      <deliverable>documentation_updates</deliverable>
      <deliverable>configuration_changes</deliverable>
    </deliverables>
    <quality_assurance>
      <cross_platform_validated>true|false</cross_platform_validated>
      <security_reviewed>true|false</security_reviewed>
      <tests_passing>true|false</tests_passing>
    </quality_assurance>
  </context_snapshot>
  <workflow_completion>
    <status>complete</status>
    <success_criteria_met>all|partial|failed</success_criteria_met>
    <follow_up_required>none|minor_fixes|major_revisions</follow_up_required>
  </workflow_completion>
</workflow_checkpoint>
```

Store final checkpoint: `serena_write_memory("workflow_[id]_final_completion", checkpoint_xml)`

---

## Checklist & Summarization Protocol (Unified)

Consolidates and replaces prior deprecated execution, autonomy, checklist, communication, preamble, and plan hygiene sections plus duplicate minimal reasoning scaffold blocks.

### 1. Applicability

- Simple tasks (≤2 steps): Execute directly; skip checklist & scaffold.
- Complex tasks (≥3 steps) or multi-phase scope: Use this protocol end‑to‑end.

### 2. Minimal Reasoning Scaffold (Pre-Tool Preamble)

Provide exactly once before first tool batch (or when materially changed):

1. One-sentence goal restatement.
2. 3–5 bullet actionable micro-plan (only current phase; no speculative later phases).
3. State intended batching (what tools, why) and expected stop condition (unique anchor, diff presence, etc.).
4. Omit if task is simple fast-path.
   Update ONLY when plan changes; otherwise do not repost unchanged plan.

### 3. Checklist Construction

- Format: fenced markdown code block; each line: `- [ ] Step N: Imperative, concise outcome`.
- Use phases optionally: `### Phase X` headings inside the fenced block (keep terse).
- Steps must be SMART enough to verify; avoid vague verbs ("handle", "update") without objects.
- Maintain ordering by dependency; append new steps instead of rewriting history when scope legitimately expands.

### 4. Progress Lifecycle

- After completing a step (or coherent batch) mark `[x]` and show ONLY the updated checklist (fenced) plus a micro handoff summary (see §6).
- Do NOT reprint unchanged checklist.
- Never pause for confirmation after approval unless permissions or ambiguity force clarification.

### 5. Tool Batching & Early Stop

- Batch independent reads/searches together; serialize only when later steps depend on earlier outputs.
- Stop search when: (a) unique anchor confirmed OR (b) top ~70% hits converge OR (c) additional results are redundant.
- Retry a failing batch at most once with adjusted parameters (anchor expansion, alternative pattern). Then escalate (clarify, fallback, or luigi plan) if still blocked.

### 6. Handoff & Summarization Cadence

Every state change (batch completion, phase end) emit 3–7 bullets:

- Objective segment addressed
- Actions executed (concise verbs)
- Key results / diffs / anchors validated
- Risks or deviations encountered & mitigations
- Next planned action (single decisive step) OR decision fork
  Include a final line summary per Idle Notification Protocol (see §10) when awaiting user input.

### 7. Early-Stop & Restart Criteria

If: looping corrections, anchor ambiguity persists, or progress stalls for 2 consecutive batches → perform one consolidated restart: restate refined goal, prune obsolete steps, reissue scaffold. Prefer clean restart over incremental thrashing.

### 8. Integrity & Safety Hooks

- Anchor uniqueness: validate before edit (delegate details to Anchor Robustness Protocol; do not restate here).
- Scope discipline: only referenced files/paths unless explicit user expansion.
- Permissions: honor `opencode.json`; do not expose internal permission logic in user-facing plan.
- No hidden state: all decisions visible in handoff bullets.

### 9. Autonomy Rules

- After initial checklist approval proceed through all steps; only pause for: permission denial, unexpected destructive diff, or unresolved ambiguity impacting correctness/safety.
- Combine low-impact cosmetic edits into nearest functional step; avoid noise commits.

### 10. Final Summaries (Idle Notification Integration)

- Last line of any response needing user input must follow: `*Summary: <≤10 words>*` (or underscore variant) and be context-specific.
- Do not echo examples; produce real state.

## Idle Notification Protocol

Defines mandatory final summary line format when awaiting user input.

**Rules:**

1. Position: MUST be the last non-empty line of the response.
2. Prefix: Either `*Summary:` or `_Summary:` (asterisk or underscore style permitted; tools must accept both).
3. Content: ≤10 words, concrete & state-specific (no placeholders like "Awaiting input" alone).
4. Scope: Reflects the most recent completed action + the immediate next expected action or waiting condition.
5. Uniqueness: Avoid repeating the identical summary consecutively unless state truly unchanged.
6. Prohibited: Filler words, examples from docs, or generic phrases (e.g., "Task done" without context).
7. Multi-request Responses: If no user input required, omit the summary line entirely.
8. Error State: If blocked, include concise cause (e.g., "Need permission for edit").

**Examples (valid):**
_Summary: Edited AGENTS.md added idle protocol_
_Summary: Waiting user to approve doc changes_

**Example (invalid):**
_Summary: Awaiting input_

## Failure Recovery Recap (Playbook)

1. **Stall Detection**: Two consecutive batches without checklist advancement → restart minimal scaffold (retain objective).
2. **Anchor Integrity**: Halt edits until a unique anchor or symbol path is confirmed; expand multi-line context up to 2 times.
3. **Permission Denial**: Narrow file/command scope; retry once; if still denied, surface required permission change (no repeated attempts).
4. **Ambiguous Matches**: Broaden search (symbol/grep) ≤2 iterations; if still non-unique escalate (luigi plan or user clarification).
5. **Token Burst Control**: If projected AWS growth >15%, perform compression (dedupe → collapse → prune) before new large reads.
6. **Plan Divergence**: Prune obsolete steps; micro-summarize retained decisions (≤50 tokens) before proceeding.
7. **Security Flag**: Potential secret/injection/misconfig → pause; invoke security agent before continuation.
8. **Recurrent Failure**: Same step fails twice after adjustments → luigi blueprint then alpha orchestrates.
9. **Post-Recovery Log**: Record one-line cause + mitigation to prevent silent repetition.
10. **Retry Budget**: Limit reattempt of same failing action to one adjusted retry; on second failure escalate (clarify, luigi plan, or specialized agent) instead of looping.

## State Management for Complex Tasks

- For tasks requiring 4+ steps, the checklist and progress MUST be managed directly in the conversation (chat).
- Workflow: Post a markdown checklist in the chat → Execute each step → Mark each step as complete in the chat → Repeat until all steps are done
- Autonomous Execution: Once the checklist is posted and approved in the chat, the agent must autonomously execute the entire plan without stopping for further approval after each step.
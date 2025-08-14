# Advanced Workflow Protocols

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
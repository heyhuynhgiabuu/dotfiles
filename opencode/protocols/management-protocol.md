# Context Management & Token Budget Policy (12-Factor Enhanced)

## Purpose
Standardize when to parallelize, summarize, compress, or escalate based on live context/token utilization using 12-factor agent principles for structured context engineering and stateless operations.

**Context Rot Integration**: This protocol now incorporates Context Rot research findings to optimize LLM performance by managing context length, relevance, and information structure according to proven principles.

## 12-Factor Context Engineering Principles

### Factor 3: Context Engineering (Official Implementation)

**Core Principle**: "You don't necessarily need to use standard message-based formats for conveying context to an LLM."

All agent communications use custom context formats optimized for token efficiency and LLM understanding. Instead of standard message-based format, agents should pack context into optimized structures.

#### Custom Context Format Options

**Option 1: Single Message XML Context** (For 500-2000 tokens)
```xml
<!-- Pack all context into single user message -->
<workflow_context>
  <current_objective>what_needs_to_be_accomplished</current_objective>
  
  <events_history>
    <action type="research_completed">
      analyzed framework options, chose Next.js for React app
    </action>
    <action type="implementation_started">
      created component structure in src/components/
    </action>
    <action type="error_encountered">
      build failed: missing dependency @types/react
    </action>
  </events_history>
  
  <current_state>
    <phase>implementation</phase>
    <progress>70% complete</progress>
    <blocking_issues>dependency missing, tests failing</blocking_issues>
  </current_state>
  
  <decisions_made>
    <decision id="framework">Next.js selected over Vite</decision>
    <decision id="styling">TailwindCSS for component styling</decision>
  </decisions_made>
  
  <constraints>
    <constraint>cross-platform (macOS/Linux)</constraint>
    <constraint>no new dependencies without approval</constraint>
    <constraint>maintain existing API compatibility</constraint>
  </constraints>
  
  <next_step_context>
    what's the next step to resolve dependencies and continue implementation?
  </next_step_context>
</workflow_context>
```

**Option 2: Compressed Token-Optimized Format** (For >2000 tokens)
```yaml
# Ultra-compressed context for large workflows
MISSION: implement React dashboard with user auth
PHASE: implementation (step 5/8)
DONE: research✓ architecture✓ components✓ auth-setup✓
CURRENT: fixing build errors in auth module
BLOCKS: missing @types/react, JWT validation failing
DECISIONS: Next.js|TailwindCSS|JWT-auth|PostgreSQL
CONSTRAINTS: cross-platform|no-new-deps|API-compat
NEXT: resolve dependencies then test authentication flow
```

**Option 3: Event Stream Format** (For inter-agent communication)
```xml
<agent_context>
  <meta>
    <event_id>unique_identifier</event_id>
    <timestamp>ISO_8601_format</timestamp>
    <source_agent>agent_name</source_agent>
    <target_agent>agent_name</target_agent>
    <workflow_id>workflow_identifier</workflow_id>
  </meta>
  <state>
    <compressed_context>
      <mission>objective_statement</mission>
      <phase>current_phase_number</phase>
      <critical_decisions>key_decisions_made</critical_decisions>
      <constraints>security_cross_platform_etc</constraints>
    </compressed_context>
    <inputs>explicit_inputs_for_target_agent</inputs>
    <expected_outputs>structured_output_format</expected_outputs>
  </state>
  <context_metrics>
    <scs_size>current_shared_context_tokens</scs_size>
    <aws_size>active_working_set_tokens</aws_size>
    <compression_events>count_since_start</compression_events>
  </context_metrics>
</agent_context>
```

#### Dynamic Context Format Selection

**Format Selection Algorithm**:
```python
def select_context_format(context_size: int, agent_type: str, operation_type: str) -> ContextFormat:
    if context_size < 500:
        return CompressedYAMLFormat()  # Ultra-efficient
    elif context_size < 2000:
        return SingleMessageXMLFormat()  # Structured but readable  
    elif operation_type == "inter_agent":
        return EventStreamFormat()  # Stateless handoff
    else:
        return TokenOptimizedFormat()  # Maximum compression
```

**Context Format Benefits**:
1. **Information Density**: 40-60% token reduction vs standard message format
2. **LLM Attention**: Custom structure improves model focus on key information
3. **Error Recovery**: Structured format enables better error context inclusion
4. **Safety**: Control what information gets passed to LLM
5. **Flexibility**: Adapt format based on workflow needs

### Factor 5: State Unification
- **Stateless Agents**: Each agent operates independently with complete context in events
- **Explicit State**: No hidden dependencies between agents
- **Event-Driven State**: All state transitions recorded in structured events
- **Resumable Workflows**: Complete context available for restart at any checkpoint

## Key Concepts (Enhanced)

- **Shared Context Slice (SCS)**: Minimal token subset all concurrently active agents MUST share (objective, current phase plan, open risks, active anchors). Now optimized with custom context formats.
- **SCS_THRESHOLD (default: 2000 tokens)**: Upper bound for safe parallel fan‑out. Adjustable only via Change Control (below).
- **Active Working Set (AWS)**: Full token span currently kept in the conversation window (SCS + supplemental details).
- **Context Debt**: Accumulated low-signal residue (obsolete plans, duplicated reasoning, stale diffs) inflating AWS without raising decision quality.
- **Compression Event**: Intentional summarization or pruning action producing a strictly smaller AWS while preserving SCS fidelity. Now generates structured XML events.
- **Summarization Tier**: (Micro) ≤50 tokens; (Phase) 51–300; (Macro) 301–800; choose smallest tier satisfying downstream needs.
- **Token Burst**: Predicted AWS growth >15% within the next planned batch (e.g., large file reads, multi-agent deltas).
- **Delta Payload**: Net new tokens introduced by the last batch (post-compression).
- **Event Stream**: Sequence of structured XML events representing workflow state transitions.
- **Context Checkpoint**: Persisted workflow state enabling pause/resume from any point.
- **Stateless Handoff**: Complete context transfer via structured events (no hidden state).
- **Context Format Efficiency**: Token reduction ratio achieved through custom formatting (target: >40% vs standard messages).
- **Attention Optimization**: Context structure designed to maximize LLM focus on critical information.

## Context Rot Optimization Principles

Based on Context Rot research findings, implement these principles to maximize LLM performance:

### 1. Relevance-Based Filtering
- **Remove Irrelevant Information**: Filter out content that doesn't directly contribute to the current task
- **Prioritize Critical Context**: Place essential information early in the context
- **Eliminate Redundancy**: Remove duplicate or overlapping information
- **Contextual Relevance Scoring**: Score information by relevance to current objective

### 2. Information Structure Optimization
- **Early Critical Placement**: Position most important information at the beginning
- **Logical Flow Disruption**: Break up long, structured text blocks that may confuse LLMs
- **Clear Information Boundaries**: Use explicit separators between different types of information
- **Semantic Similarity Management**: Avoid clustering similar but non-relevant information

### 3. Length-Aware Processing
- **Progressive Context Building**: Add information incrementally rather than in large blocks
- **Length Thresholds**: Monitor context length and trigger compression at optimal points
- **Performance-Based Limits**: Adjust context size based on observed performance degradation
- **Task Complexity Matching**: Scale context length according to task complexity

### 4. Dynamic Context Management
- **Real-time Performance Monitoring**: Track LLM performance as context grows
- **Adaptive Compression**: Automatically compress when performance degradation is detected
- **Context Quality Metrics**: Measure context effectiveness and optimize accordingly
- **Feedback Loop Integration**: Use performance data to improve future context construction

## Context Format Implementation Strategy

### When to Use Each Format

**Micro Context (CompressedYAMLFormat)** - Use when context <500 tokens:
```yaml
GOAL: fix authentication bug
STATUS: debugging JWT validation  
ERROR: token signature verification failed
NEXT: check secret key configuration
```

**Standard Context (SingleMessageXMLFormat)** - Use when context 500-2000 tokens:
```xml
<task_context>
  <objective>implement user authentication system</objective>
  <current_phase>testing and debugging</current_phase>
  <completed_steps>
    <step>JWT library integration</step>
    <step>user registration endpoint</step>
    <step>login endpoint implementation</step>
  </completed_steps>
  <current_issue>
    JWT token validation failing in production environment
    Error: "JsonWebTokenError: invalid signature"
  </current_issue>
  <debugging_context>
    - Development works fine with same code
    - Production uses different environment variables
    - JWT_SECRET appears to be correctly set
  </debugging_context>
  <next_actions>
    1. Verify JWT_SECRET in production matches development
    2. Check token generation vs validation key consistency
    3. Test with manual token creation
  </next_actions>
</task_context>
```

**Event Stream (EventStreamFormat)** - Use for inter-agent communication:
```xml
<agent_handoff>
  <source>language_agent</source>
  <target>security_agent</target>
  <context_type>authentication_review</context_type>
  <deliverables>
    <code_artifact>src/auth/jwt-handler.js</code_artifact>
    <test_results>15 tests passing, 3 failing on signature validation</test_results>
    <environment_config>JWT_SECRET, TOKEN_EXPIRY settings</environment_config>
  </deliverables>
  <security_review_needed>
    <concern>JWT secret key security in production</concern>
    <concern>token expiration handling</concern>
    <concern>refresh token implementation</concern>
  </security_review_needed>
  <success_criteria>
    - All security vulnerabilities identified and fixed
    - Production authentication working correctly
    - Security best practices validated
  </success_criteria>
</agent_handoff>
```

**Compressed Context (TokenOptimizedFormat)** - Use when context >2000 tokens:
```yaml
# Maximum compression for large workflows
MISSION: full-stack React app with auth|dashboard|admin
PROGRESS: auth✓ dashboard✓ admin-UI✓ testing→
STACK: Next.js|TypeScript|TailwindCSS|PostgreSQL|JWT
PHASES: [1]research✓ [2]arch✓ [3]implement✓ [4]test→ [5]deploy
CURRENT: integration testing phase 4 of 5
BLOCKS: CORS issues in production, DB connection pool limits
FIXES_TRIED: cors middleware✓ connection strings✓ env vars✓
DECISIONS: |auth:JWT+refresh| |db:PostgreSQL+Prisma| |deploy:Vercel|
CONSTRAINTS: |cross-platform| |no-new-major-deps| |API-backward-compat|
NEXT: resolve CORS for production deployment, optimize DB connections
CONTEXT: 3 weeks dev, 2 blockers remaining, target production next week
```

## Parallelization Criteria (Event-Driven)
Applies before launching independent specialized agents:

1. SCS size ≤ SCS_THRESHOLD (2000 default).
2. Predicted aggregate Delta Payload for parallel branch set ≤ 40% of remaining threshold.
3. No unresolved ordering dependencies (data or decision).
4. No pending high-risk escalation (security, legacy, network) requiring serialized review.
5. Compression backlog < 2 events (i.e., no more than one deferred compression trigger outstanding).
6. **Event Schema Ready**: Structured XML events defined for all parallel agent communications.
7. **Stateless Validation**: Each parallel agent has complete context in its initial event.

## Event-Driven Context Validation

Before parallel agent launch, validate:
```xml
<validation_checklist>
  <context_completeness>
    <mission_clarity>clear_objective_statement</mission_clarity>
    <input_specification>explicit_inputs_defined</input_specification>
    <output_format>structured_expectations</output_format>
    <constraints>security_cross_platform_dependencies</constraints>
  </context_completeness>
  <stateless_verification>
    <no_hidden_state>true</no_hidden_state>
    <resumable_from_event>true</resumable_from_event>
    <complete_context>true</complete_context>
  </stateless_verification>
</validation_checklist>
```

## Measurement & Instrumentation (Event-Tracked)

- Track (a) SCS size, (b) AWS size, (c) Delta Payload per batch, (d) Compression Events count, (e) Event Stream integrity.
- After each batch: recompute SCS by extracting: active mission, current phase checklist slice, open risks, unresolved decisions, anchors.
- **Event Metrics**: Track event count, payload sizes, handoff efficiency, context compression ratios.
- Predict Token Burst = sum(estimated sizes of planned file reads + agent prompts) – budget remaining.
- Abort fan‑out if predicted SCS post‑merge > 90% of threshold.
- **Context Health Score**: Ratio of useful context to total AWS (target: >80%).

## Context Event Generation

For every significant workflow transition, generate structured events:

```xml
<context_transition>
  <event_type>phase_boundary|compression|escalation|checkpoint</event_type>
  <before_state>
    <scs_size>tokens</scs_size>
    <aws_size>tokens</aws_size>
    <context_debt_ratio>percentage</context_debt_ratio>
  </before_state>
  <action_taken>specific_compression_or_transition</action_taken>
  <after_state>
    <scs_size>tokens</scs_size>
    <aws_size>tokens</aws_size>
    <compression_ratio>percentage_reduction</compression_ratio>
  </after_state>
  <next_agent>target_agent_if_handoff</next_agent>
</context_transition>
```

## Summarization & Compression Triggers (Event-Enhanced)
Fire smallest satisfying tier; multiple may coalesce into a single event:

1. Post‑Phase Boundary (always) → Generate `phase_complete` event with compressed state.
2. SCS > 70% of SCS_THRESHOLD → Micro or Phase summary (whichever yields ≥12% SCS reduction).
3. AWS contains ≥25% Context Debt (heuristic: duplicated plan versions, superseded reasoning) → compress.
4. Pre‑Burst (predicted >15% growth) → proactive compression before expansion.
5. After 3 consecutive batches without compression AND AWS growth >10%.
6. Macro summary mandatory if AWS > 8k tokens (guardrail).
7. Emergency: If SCS projected > threshold, immediate targeted pruning of stale anchors then summarize.
8. **Event Stream Overflow**: >50 events in stream → compress to checkpoints.
9. **Stateless Validation Failure**: Agent cannot resume from event → force context rebuild.

## Structured Compression Strategy

Replace verbose context with structured summaries:

```xml
<compressed_workflow_state>
  <mission>core_objective</mission>
  <phases_completed>
    <phase id="1" agent="beta">architecture_analysis_done</phase>
    <phase id="2" agent="language">implementation_in_progress</phase>
  </phases_completed>
  <critical_decisions>
    <decision id="auth_strategy">oauth2_with_jwt</decision>
    <decision id="db_choice">postgresql_selected</decision>
  </critical_decisions>
  <active_constraints>
    <constraint>cross_platform_macos_linux</constraint>
    <constraint>no_new_dependencies_without_approval</constraint>
  </active_constraints>
  <next_phase>
    <agent>security</agent>
    <task>vulnerability_audit</task>
    <required_inputs>implementation_code,architecture_decisions</required_inputs>
  </next_phase>
</compressed_workflow_state>
```

## Reduction Strategies
Ordered preference:

1. Deduplicate unchanged plan / checklist blocks (keep latest only).
2. Collapse verbose reasoning paragraphs into bullet outcome lines.
3. Abstract repeated file path references into a short anchor index.
4. Externalize long historical rationale (already resolved) into memory then remove from active window.
5. Prune stale tasks superseded by updated decomposition (log in summary).
6. Replace large code excerpts with hash + line span + diff-only anchors (retain security-sensitive snippets verbatim).

## Escalation & Safeguards

- Escalate to context agent if: (a) SCS >80% threshold twice within 4 batches, or (b) required future phase estimated to add ≥50% SCS.
- Escalate to alpha if parallelization repeatedly denied (≥3 times) due to Context Debt >30%.
- Escalate to user ONLY when compression would drop semantically necessary unresolved details (edge case).
- Fallback Compression (when urgent) applies in sequence: remove duplicate plans → collapse reasoning → trim unchanged code blocks → macro summarize earliest resolved phases.

## SCS_THRESHOLD Change Control

- Default 2000; proposals must cite 7‑day median SCS utilization, max SCS Δ, and parallelization denial rate.
- Raise when median SCS >75% AND denial rate >30%.
- Lower when median SCS <40% AND >2 macro summaries/week are no‑ops.
- Adjustment process: propose → pilot on ≥3 complex tasks → record metrics → adopt or revert.

## Memory Use & Criteria

Use contextual memory only when all apply:
1. **Durable Value**: Benefit expected beyond current task (multi-session workflow, recurring policy, architectural decision).
2. **Reusability**: Pattern/procedure applicable to ≥2 future scenarios.
3. **Compression Benefit**: Storing externally reduces Active Working Set or prevents repetition.

**Avoid storing**: transient diffs, single-use reasoning, ephemeral numeric metrics, or speculative ideas without decision.

**Memory Insertion Guidelines**: Summarize to minimal actionable bullet form; omit verbose rationale; include date + purpose tag.

## Hierarchical Context Bridge (Event-Driven)

At each phase boundary emit the smallest summary tier preserving the Shared Context Slice (objective, active checklist slice, open risks, anchors) using structured XML events; escalate to Macro only when AWS > 8000 tokens or compression triggers (context debt ≥25% or predicted burst >15%) fire; always prune context debt before expansion.

**Context as API Principle**: Treat context (SCS + AWS deltas) as a formal interface with structured XML schemas: define required inputs, emit structured outputs, and avoid leaking internal intermediate reasoning beyond what downstream agents need.

**Event-Driven Handoffs**: Every agent transition requires:
1. Source agent emits `phase_complete` event with structured outputs
2. Context compression applied if thresholds exceeded  
3. Target agent receives `phase_start` event with complete context
4. Validation checkpoint ensures stateless resumability

## Pause/Resume Architecture (Factor 6)

**Checkpoint Generation**: After each major phase:
```xml
<workflow_checkpoint>
  <checkpoint_id>workflow_[id]_phase_[n]_complete</checkpoint_id>
  <timestamp>ISO_8601</timestamp>
  <resumable_state>
    <compressed_workflow_state>...</compressed_workflow_state>
    <event_stream_summary>key_decisions_and_outputs</event_stream_summary>
    <next_actions>
      <action agent="security" priority="high">vulnerability_audit</action>
    </next_actions>
  </resumable_state>
  <context_metrics>
    <scs_size>tokens</scs_size>
    <compression_ratio>percentage</compression_ratio>
    <events_processed>count</events_processed>
  </context_metrics>
</workflow_checkpoint>
```

**Resume Protocol**: Workflow can restart from any checkpoint with complete context restoration and validation of event stream integrity.

## Context Rot-Aware Compression Triggers

Enhanced compression triggers that incorporate Context Rot research findings:

### Performance-Based Triggers
1. **Context Length Degradation**: When context length exceeds 1000 tokens, trigger relevance-based compression
2. **Performance Drop Detection**: If LLM response quality decreases (based on confidence scores), trigger compression
3. **Semantic Similarity Threshold**: When similar but non-relevant information clusters exceed 30% of context
4. **Information Density Drop**: When useful information density falls below 70%

### Relevance-Based Triggers
1. **Irrelevant Content Ratio**: When >40% of context is not directly relevant to current task
2. **Redundancy Detection**: When duplicate information exceeds 25% of context
3. **Stale Information**: When >30% of context references outdated decisions or completed phases
4. **Distractor Content**: When similar but incorrect information is present that could confuse the LLM

### Structure Optimization Triggers
1. **Long Block Detection**: When any single information block exceeds 200 tokens
2. **Poor Information Flow**: When critical information is buried in the middle or end of context
3. **Missing Clear Boundaries**: When different types of information are not clearly separated
4. **Suboptimal Ordering**: When information is not ordered by importance/relevance

### Adaptive Thresholds
- **Short Tasks (<500 tokens)**: Compress when irrelevant content >20%
- **Medium Tasks (500-2000 tokens)**: Compress when irrelevant content >30%
- **Long Tasks (>2000 tokens)**: Compress when irrelevant content >40%
- **Complex Tasks**: More aggressive compression with relevance scoring

## Glossary (Enhanced)

**SCS (Shared Context Slice)**: Minimal token subset all concurrently active agents must share (objective, current phase plan, open risks, active anchors). Now transmitted via structured XML events.

**AWS (Active Working Set)**: Full token span currently kept in the conversation window (SCS + supplemental details).

**Context Debt**: Accumulated low-signal residue (obsolete plans, duplicated reasoning, stale diffs) inflating AWS without raising decision quality.

**Token Burst**: Predicted AWS growth >15% within the next planned batch (e.g., large file reads, multi-agent deltas).

**Delta Payload**: Net new tokens introduced by the last batch (post-compression).

**Event Stream**: Chronological sequence of structured XML events representing all workflow state transitions.

**Context Checkpoint**: Serialized workflow state enabling pause/resume from any major phase boundary.

**Stateless Handoff**: Agent-to-agent context transfer using complete, structured events with no hidden dependencies.

**Context Event**: Structured XML representation of workflow state, agent assignments, and expected outputs.

**Event Schema**: Defined XML structure ensuring consistent context format across all agent communications.

**Context Health Score**: Ratio of actionable context to total AWS tokens (target: >80% useful content).

**Compression Ratio**: Percentage reduction in context size after compression events (target: >30% when needed).

## Context Quality Metrics

Metrics to measure and optimize context effectiveness based on Context Rot principles:

### Relevance Metrics
- **Relevance Score**: Percentage of context directly relevant to current task (target: >80%)
- **Critical Information Placement**: Position of most important information (target: top 25% of context)
- **Redundancy Ratio**: Percentage of duplicate or overlapping information (target: <15%)
- **Staleness Ratio**: Percentage of outdated or superseded information (target: <10%)

### Structure Metrics
- **Information Density**: Ratio of useful tokens to total tokens (target: >75%)
- **Block Size Distribution**: Average size of information blocks (target: <150 tokens per block)
- **Boundary Clarity**: Number of clear information separators (target: adequate for content types)
- **Flow Disruption Score**: Measure of how well logical flow is broken up (target: optimized for LLM processing)

### Performance Metrics
- **Response Quality Score**: LLM output quality as context length increases
- **Processing Time**: Time taken to generate response vs context length
- **Error Rate**: Frequency of hallucinations or incorrect responses
- **Consistency Score**: Response consistency across similar queries with different context lengths

### Optimization Targets
- **Context Efficiency**: Maximize useful information per token
- **Performance Stability**: Minimize performance degradation as context grows
- **Information Accessibility**: Ensure critical information is easily accessible
- **Processing Optimization**: Structure content for optimal LLM attention patterns
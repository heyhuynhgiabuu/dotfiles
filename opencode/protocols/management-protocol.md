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

## Context Management Integration

This protocol integrates with the Context Rot Protocol (`context-rot-protocol.md`) for advanced context optimization and management. Key integration points include:

### Context Format Selection
- Use Context Rot protocol format selection algorithms
- Apply context quality metrics for optimization decisions
- Implement compression triggers based on Context Rot research

### Performance Monitoring
- Monitor context efficiency using Context Rot metrics
- Track compression ratios and quality improvements
- Implement adaptive context management strategies

### Integration Reference
For detailed Context Rot implementation, see `context-rot-protocol.md` which provides:
- Complete context optimization strategies
- Format selection algorithms
- Quality metrics and monitoring
- Compression and performance optimization techniques

### Context Management Best Practices
- Apply Context Rot principles for optimal performance
- Use structured XML events for context handoffs
- Monitor context health and quality metrics
- Implement adaptive compression based on performance feedback
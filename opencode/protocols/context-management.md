# Context Management & Token Budget Policy

## Purpose
Standardize when to parallelize, summarize, compress, or escalate based on live context/token utilization without duplicating existing summarization protocols.

## Key Concepts

- **Shared Context Slice (SCS)**: Minimal token subset all concurrently active agents MUST share (objective, current phase plan, open risks, active anchors). Excludes historical chatter already summarized.
- **SCS_THRESHOLD (default: 2000 tokens)**: Upper bound for safe parallel fan‑out. Adjustable only via Change Control (below).
- **Active Working Set (AWS)**: Full token span currently kept in the conversation window (SCS + supplemental details).
- **Context Debt**: Accumulated low-signal residue (obsolete plans, duplicated reasoning, stale diffs) inflating AWS without raising decision quality.
- **Compression Event**: Intentional summarization or pruning action producing a strictly smaller AWS while preserving SCS fidelity.
- **Summarization Tier**: (Micro) ≤50 tokens; (Phase) 51–300; (Macro) 301–800; choose smallest tier satisfying downstream needs.
- **Token Burst**: Predicted AWS growth >15% within the next planned batch (e.g., large file reads, multi-agent deltas).
- **Delta Payload**: Net new tokens introduced by the last batch (post-compression).

## Parallelization Criteria
Applies before launching independent specialized agents:

1. SCS size ≤ SCS_THRESHOLD (2000 default).
2. Predicted aggregate Delta Payload for parallel branch set ≤ 40% of remaining threshold.
3. No unresolved ordering dependencies (data or decision).
4. No pending high-risk escalation (security, legacy, network) requiring serialized review.
5. Compression backlog < 2 events (i.e., no more than one deferred compression trigger outstanding).

## Measurement & Instrumentation

- Track (a) SCS size, (b) AWS size, (c) Delta Payload per batch, (d) Compression Events count.
- After each batch: recompute SCS by extracting: active mission, current phase checklist slice, open risks, unresolved decisions, anchors.
- Predict Token Burst = sum(estimated sizes of planned file reads + agent prompts) – budget remaining.
- Abort fan‑out if predicted SCS post‑merge > 90% of threshold.

## Summarization & Compression Triggers
Fire smallest satisfying tier; multiple may coalesce into a single event:

1. Post‑Phase Boundary (always).
2. SCS > 70% of SCS_THRESHOLD → Micro or Phase summary (whichever yields ≥12% SCS reduction).
3. AWS contains ≥25% Context Debt (heuristic: duplicated plan versions, superseded reasoning) → compress.
4. Pre‑Burst (predicted >15% growth) → proactive compression before expansion.
5. After 3 consecutive batches without compression AND AWS growth >10%.
6. Macro summary mandatory if AWS > 8k tokens (guardrail).
7. Emergency: If SCS projected > threshold, immediate targeted pruning of stale anchors then summarize.

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

## Hierarchical Context Bridge

At each phase boundary emit the smallest summary tier preserving the Shared Context Slice (objective, active checklist slice, open risks, anchors); escalate to Macro only when AWS > 8000 tokens or compression triggers (context debt ≥25% or predicted burst >15%) fire; always prune context debt before expansion.

**Context as API Principle**: Treat context (SCS + AWS deltas) as a formal interface: define required inputs, emit structured outputs, and avoid leaking internal intermediate reasoning beyond what downstream agents need.

## Glossary

**SCS (Shared Context Slice)**: Minimal token subset all concurrently active agents must share (objective, current phase plan, open risks, active anchors).

**AWS (Active Working Set)**: Full token span currently kept in the conversation window (SCS + supplemental details).

**Context Debt**: Accumulated low-signal residue (obsolete plans, duplicated reasoning, stale diffs) inflating AWS without raising decision quality.

**Token Burst**: Predicted AWS growth >15% within the next planned batch (e.g., large file reads, multi-agent deltas).

**Delta Payload**: Net new tokens introduced by the last batch (post-compression).
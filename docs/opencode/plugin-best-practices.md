# OpenCode Plugin Best Practices: Brutal Edition

Single focus. One plugin. No distraction.

## Core Principles (Only What We Enforce)

1. Solve a real, high-frequency pain
2. Ship smallest functional slice fast
3. Instrument before claiming success
4. Delete if metrics miss thresholds twice
5. Zero mock evaluations
6. Minimize tokens: return only decision-grade data
7. Security guardrails first (path block, no secrets)

## Past Failure (Kept As Warning)

refactor-engine (deleted): claimed success without real work. Lesson: never publish mock metrics.

debug-trace (deleted): handled 2/5 error cases. Lesson: narrow pattern matching = shallow value.

Both prove: partial cleverness without measurable impact is waste. No resurrection.

---

## Chosen Single Focus Plugin

Name: test-forge
Mission: Eradicate silent test gaps fast.

### Problem (Brutal Statement)

We ship code with unknown untested functions. Regression risk is invisible. Manual discovery is slow. Agents cannot prioritize stabilization without a gap map.

### MVP Scope (Nothing Else)

Tools:

- test_discover_gaps: list functions/methods without matching test file or spec block
- test_generate_unit: produce minimal runnable test skeleton for one target (imports, describe/it, placeholder assertion)
- test_coverage_summary: parse coverage snippet input and surface top N untested high-change functions

Out of scope (ban now): integration tests, mocking frameworks, snapshot generation, flaky test detection, auto-fix code.

### Hard Evaluation Contract

Dataset: ≥40 functions across JS/TS utilities (mix pure + side-effect). Ground truth: which have tests.
Metrics (must hit all):

- Gap detection precision ≥85%
- Gap detection recall ≥90%
- Generated test compile/run success ≥90%
- Useless skeleton rate (no meaningful assertion after 1 agent refinement) ≤15%
- Coverage delta after generating tests: +20% lines (or reach ≥70% total) on sample module set
- Average generation latency ≤2s per test on warm cache
  Kill conditions: any metric below target twice consecutively OR useless skeleton rate >20% once.

### Implementation Phases (Strict Order)

1. Static scan: gather candidate source files (filter node_modules, dist, .\* hidden, secrets, keys)
2. Symbol extract: naive regex + fallback parse for function names/exports
3. Test presence check: map src/foo/bar.test.(js|ts) or **tests** pattern
4. Gap list return: sorted by (recent edit heuristic if git present) + size
5. Skeleton generation: parameter introspection (best-effort), insert TODO for complex deps
6. Coverage summarizer: ingest provided coverage JSON/text, rank top untested by missed lines
7. Metrics logging: structured line per tool invocation
8. LRU cache (50 items, 30s TTL) for symbol + test existence map

### Security / Path Guard

Block if path matches: /keys/, /secrets/, /token/, .git/, node_modules/, _.pem, _.key, \*.env
Return explicit denial reason. Never partially leak.

### Logging Spec

Structured single-line JSON: {"service":"test-forge","tool":"<name>","event":"<stage>","duration_ms":N,"items":M}
No stack traces unless fatal internal error.

### Response Shapes

- test_discover_gaps: {version: "1", gaps: [{path, name, line}], total, truncated: bool}
- test_generate_unit: {version: "1", path_suggested, content}
- test_coverage_summary: {version: "1", hotspots: [{path, missed, lines}], total_files, analyzed}

### Token Discipline

Never return full source unless function length ≤40 lines. Else return signature + first 5 and last 5 lines.

### Next Immediate Actions (Enforce Sequence)

1. Create plugin file opencode/plugin/test-forge.js skeleton with: registry, LRU cache, path guard, placeholder tool handlers, metrics emitter.
2. Add evaluation harness directory (fixtures + expected). (Not building now.)
3. Run initial dry scan on repo (no generation) to baseline gap count.

No other plugin work starts until Phase 1–3 complete with real outputs captured.

### Survival Rule

If by first full evaluation (all metrics measured) two metrics miss targets: delete plugin, retain harness, pick next idea.

Final: Only test-forge exists. Everything else is noise until it proves value.

# Context Gap Question Generator Template

Use this template when automation reveals uncertainty that blocks a confident review decision. Select or adapt questions; remove those not relevant.

## When to Invoke
- High-risk tag (security/large-change) without surrounding architectural context.
- Legacy hotspot flagged with minimal existing tests.
- Missing test delta on large addition.
- Diff touches config/auth/crypto paths with unclear enforcement boundaries.

## Template Blocks

### Architecture & Flow
1. Which upstream components call the modified functions/modules?
2. Are there downstream consumers relying on prior behavior (any breaking change risk)?
3. Is there a feature flag or rollout guard for this change?

### Security & Data Handling
4. Where is input validation occurring for new/modified entry points?
5. Are secrets or tokens introduced/handled here already rotated or masked in logs?
6. Does this change alter authZ/authN logic or trust boundaries?

### Performance & Scalability
7. Are new loops or queries expected to run in hot paths or large datasets?
8. Has any profiling or benchmark been executed (baseline numbers)?

### Testing & Coverage
9. What tests (unit/integration) assert the new behavior and edge cases?
10. Are there negative tests for failure/invalid input scenarios?
11. Is there a plan to add tests for uncovered branches flagged by automation?

### Legacy & Refactor Strategy
12. Are there plans to decompose large touched files (extraction phases)?
13. Do TODO/FIXME markers reflect actionable backlog items or stale notes?

### Deployment & Ops
14. Any migration steps, data backfills, or config toggles required on deploy?
15. Rollback strategy if regression or incident occurs?

### Clarification & Assumptions
16. Which assumptions (if any) should a reviewer NOT make about surrounding systems?
17. Are there domain constraints not obvious from the diff?

## Output Integration
- Place curated questions under "## Open Questions" in review output.
- Use writer agent to convert resolved answers into persistent docs if systemic.
- Summarizer agent can compress Q/A into session handoff.

## Minimal Example
```
Open Questions:
- Where is validation for new /api/invoice endpoint? (Blocks security assessment)
- Are there tests covering negative auth token scenarios? (Coverage gap)
- Is large 400+ line addition in invoice_service gated behind a flag? (Risk mitigation)
```

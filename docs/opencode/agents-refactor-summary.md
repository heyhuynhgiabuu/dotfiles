# AGENTS.md Refactor Summary (2025-08-13)

Purpose: Concise developer-facing overview of what changed between legacy AGENTS v1 (archived at `docs/archive/AGENTS-v1.md`) and the current streamlined `opencode/AGENTS.md`.

## Overview
The global agent operating protocol was refactored to eliminate duplication, tighten terminology, and formalize context / parallelization governance. Legacy sprawling sections were merged into a unified, enforceable core; a guardrail script prevents regression.

## Key Additions
- Subagent Role Matrix: Single authoritative matrix for roles, triggers, escalation paths.
- Multi-Context Orchestration Guidelines: Formal routing order + blueprint / handoff rules.
- Token & Context Budget Policy: Defines SCS, AWS, Context Debt, Token Burst, Delta Payload, compression & parallelization gates.
- Unified Checklist & Summarization Protocol: Replaces scattered execution / autonomy / todo / communication sections.
- Glossary: Central definitions (SCS, AWS, Context Debt, Token Burst, Delta Payload).
- Explicit Luigi (planning sentinel) usage contract and escalation flow.

## Consolidations / Merges
- Execution Rules, Autonomous Execution Rules, Todo List Management, Communication Guidelines, and duplicate Minimal Reasoning Scaffold blocks collapsed into the unified protocol.
- Redundant plan/preamble/answer style instructions compressed into semantic tags `<tool_preambles>` & `<answer_style>` (single occurrence each).
- Dynamic chunking & context engineering content partly integrated or referenced via Token & Context Budget Policy (removed standalone duplication).

## Removals (Now Superseded)
- Legacy heading variants now blocked: "Execution Rules", "Autonomous Execution Rules", "Todo List Management".
- Verbose, duplicated failure recovery / memory management narratives (essential concepts either implicit in unified protocol or retained in archive for reference).
- Multiple reiterations of reasoning scaffold & plan hygiene instructions.

## Guardrails & Enforcement
- `scripts/verify-doc-consistency.sh` blocks reintroduction of forbidden legacy headings in active AGENTS.md.
- Archived legacy spec preserved verbatim at `docs/archive/AGENTS-v1.md` (script comment clarifies archive is allowed).

## Backward Compatibility & Impact
- Operational semantics unchanged—only authoritative locations & naming. Existing automation referencing old headings should update to new unified protocol labels.
- No behavioral code changes required; adjustments are documentation and governance structure only.

## Migration Guidance
Replace references as follows:
- Old: "Execution Rules" / "Autonomous Execution Rules" / "Todo List Management" → New: "Checklist & Summarization Protocol (Unified)".
- Old ad-hoc agent selection heuristics → Use Subagent Role Matrix.
- Ad-hoc parallelization reasoning → Apply Token & Context Budget Policy (SCS thresholds & triggers).

## Retrieval / Discovery Tips
- For context management: search "Token & Context Budget Policy".
- For agent routing: search "Subagent Role Matrix".
- For execution cadence & summaries: search "Checklist & Summarization Protocol".

## Verification Steps
1. Open `opencode/AGENTS.md` and confirm single occurrences of `<tool_preambles>` and `<answer_style>`.
2. Run `bash scripts/verify-doc-consistency.sh` → expect "No forbidden legacy headings found.".
3. (Optional) Diff archive vs current: `diff -u docs/archive/AGENTS-v1.md opencode/AGENTS.md | less` to inspect reductions.
4. Confirm glossary terms (SCS, AWS, Context Debt, Token Burst, Delta Payload) exist only once.

## Reference
Archive: `docs/archive/AGENTS-v1.md` (retain for historical detail; do not modify).

---
Generated on 2025-08-13 based on commit series culminating at `8b6f249`.

# Quality Standards & Tooling Guide

## Quality Standards (Condensed)

- **Security**: No plaintext secrets; least privilege; validate external inputs early; sanitize/log conservatively; escalate on potential secret exposure.
- **Cross-Platform**: All scripts/config must run on macOS & Linux (avoid macOS-only flags like `sed -i` without portable form; prefer POSIX sh; guard platform-specific code paths).
- **Minimal Complexity**: Choose the smallest stable solution; defer abstractions until duplication emerges (≥3 occurrences) or explicit scalability need.
- **Verification**: Always provide manual verification steps; re-read files after edit; confirm anchor uniqueness pre-edit.
- **Purity & Cleanup**: Remove dead code, stale docs, superseded plan blocks immediately; never leave TODOs without owner/context.
- **Consistency**: Follow existing naming, tool choices (`rg`, `fd`, `bat`, `sd`, `jq`, `delta`, `fzf`), and formatting patterns.
- **Performance & Context Efficiency**: Avoid unnecessary large reads; compress context per triggers before expansion.
- **Resilience**: Anticipate failure modes (permissions, ambiguous anchors, token bursts) and apply Failure Recovery Recap.

## Modern Search/Edit Tooling Policy

**Preferred CLI tools for all codebase search/edit operations:**
- `rg` (ripgrep): Fastest recursive code/text search. Always use instead of `grep` for codebase or config search.
- `fd`: Fast, user-friendly file search. Prefer over `find` for file discovery.
- `bat`: Syntax-highlighted file preview. Use for readable file output in scripts, reviews, and AI workflows.
- `delta`: Syntax-highlighted git diff viewer. Use for reviewing code changes.
- `sd`: Fast, safe find & replace. Prefer over `sed` for batch replacements.
- `jq`: For all JSON parsing/editing in scripts or AI workflows.
- `fzf`: For interactive fuzzy finding in terminal or scripts.

**Implementation Guidance:**
- All agents, scripts, and workflows MUST use `rg` for code/text search and `fd` for file search, falling back to `grep`/`find` only if the preferred tool is unavailable.
- When previewing or displaying file content, use `bat` for readability.
- For batch replacements, use `sd` instead of `sed` for safety and simplicity.
- For JSON, always use `jq` for parsing and manipulation.
- For reviewing diffs, use `delta` for clarity.
- Document these conventions in all onboarding and developer docs.
- When writing new scripts or agent logic, check for tool availability and prefer the modern tool.

**Sample Usage Patterns:**

```sh
rg "pattern" path/
fd pattern path/
bat file.txt
sd 'foo' 'bar' file.txt
jq '.' file.json
git diff | delta
fzf
```

**Rationale**: These tools are cross-platform, fast, and provide a superior developer and AI experience. They are required for all new workflows and strongly recommended for legacy script modernization.

## Tool Selection Hierarchy

### Scope Discipline (Agent-Agnostic)

- Operate only on files/paths explicitly referenced by the user.
- Prefer Read/Glob with exact paths; avoid repo-wide listing/grep by default.
- If broader scope seems needed, ask to expand—state why and the intended bounds.

### Code Analysis

1. **Serena** (read-only think/symbol tools only; no edit/mutation) - For codebase relationships and symbol analysis
2. **OpenCode Read/Edit/Write/Grep/Glob** - For file content, searches, and all edits

### Information Retrieval

1. **API/CLI** (bash + curl/gh) - For structured data sources
2. **Context7** - For library/framework documentation
3. **WebFetch** - For current documentation and best practices (mandatory for unknown tech)

## Anchor Robustness Protocol

- Always verify anchor uniqueness before editing.
- If the anchor appears multiple times, expand context (multi-line) or switch to symbol-based editing.
- After editing, always re-read the file to confirm the change is in the correct location.
- If a unique anchor cannot be determined, log an error and suggest manual review or user confirmation.
- For dynamic or generated files, avoid direct edits unless explicitly confirmed.

## Serena MCP 'think' Tools Integration

- For every major workflow phase:
  - After data gathering, call `think_about_collected_information`.
  - Before code modification or verification, call `think_about_task_adherence`.
  - At the end, call `think_about_whether_you_are_done`.
- Log/report results as part of the verification checklist and final report.
- **Editing policy**: Serena MCP is strictly read-only. Do NOT use Serena editing/mutation tools (e.g., replace_regex, replace_symbol_body, insert_after_symbol, insert_before_symbol). For any code/content edits and searches, use OpenCode-native tools: Read/Edit/Write/Grep/Glob, and follow the Anchor Robustness Protocol and `opencode.json` permissions.

## Research Protocol

- **Mandatory webfetch** for third-party/unknown tech or ambiguous requirements.
- For trivial tasks with known local anchors, you may skip webfetch and proceed using early-stop criteria.
- **Early-stop criteria**: Unique anchors identified OR top hits converge (~70%) on one path.
- If signals conflict or scope is fuzzy, escalate once (research or clarification), then proceed.
- **Never proceed on assumptions**; always verify with current documentation.

## Reusable Playbooks

Maintain concise, reusable prompt templates ("playbooks") for repetitive workflows:
- Dependency upgrades
- Documentation updates  
- Test-writing
- PR preparation

Prefer adapting playbooks before writing ad-hoc prompts.
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

## Enhanced Research Protocol (Chrome MCP Integrated)

### Chrome MCP Auto-Start Requirement

**BEFORE using any Chrome MCP research tools, ensure Chrome is running:**

```bash
# Check if Chrome is running, start if needed (cross-platform)
if ! pgrep -f "Google Chrome\|google-chrome\|chromium" >/dev/null 2>&1; then
  case "$(uname -s)" in
    Darwin) 
      open -a "Google Chrome" 
      ;;
    Linux) 
      if command -v google-chrome >/dev/null 2>&1; then
        nohup google-chrome >/dev/null 2>&1 &
      elif command -v chromium >/dev/null 2>&1; then
        nohup chromium >/dev/null 2>&1 &
      fi
      ;;
  esac
  sleep 3  # Wait for Chrome initialization
fi
```

**Auto-Start Integration Rules:**
- **Automatic activation**: Run before first Chrome MCP tool use
- **Silent operation**: Minimal output, handle errors gracefully  
- **Regular browser**: Use user's normal Chrome (with Google login, extensions)
- **Cross-platform**: Works on macOS and Linux
- **Idempotent**: Safe to run multiple times

### Research Tier Selection

**Tier 1: Quick Research** (Known tech, simple verification)
- Use when: Framework basics, familiar APIs, syntax clarification
- Tools: `chrome_search_tabs_content` → `webfetch` → early stop
- Agent Impact: **General/Language** - 50% faster simple lookups

**Tier 2: Interactive Research** (Setup instructions, API docs, complex frameworks)
- Use when: Installation guides, configuration, new framework patterns
- Tools: `chrome_navigate` → `chrome_get_web_content` → `chrome_screenshot` → `chrome_search_tabs_content`
- Agent Impact: **DevOps/Language/Frontend** - 3x more accurate implementation

**Tier 3: Comparative Research** (Solution evaluation, architecture decisions)
- Use when: Multiple solutions exist, architecture choices, best practices
- Tools: Multi-tab `chrome_navigate` → parallel content extraction → `chrome_search_tabs_content` → semantic synthesis
- Agent Impact: **Alpha/Reviewer** - 2x better architectural decisions

### Chrome MCP Research Tools Priority

**Primary Research Tools** (Prefer over webfetch):
1. `chrome_search_tabs_content` - Semantic search existing browser knowledge
2. `chrome_navigate` - Access live documentation with JavaScript support
3. `chrome_get_web_content` - Extract structured content with better parsing
4. `chrome_screenshot` - Visual verification for UI/setup instructions
5. `chrome_network_capture_start/stop` - Monitor API requests/responses
6. `webfetch` - Fallback for simple static content only

### Research Decision Matrix

| Research Scenario | Recommended Tools | Agent Effectiveness Gain |
|-------------------|------------------|-------------------------|
| **Framework Documentation** | `navigate` + `content` + `screenshot` | Language: +200% pattern accuracy |
| **API Integration Guide** | `navigate` + `network_capture` + `content` | DevOps: +150% integration success |
| **Setup Instructions** | `navigate` + `screenshot` + `content` | All: +300% setup verification |
| **UI/Component Research** | `navigate` + `screenshot` + `search_tabs` | Frontend: +250% visual accuracy |
| **Architecture Comparison** | Multi-tab + `search_tabs` + `content` | Alpha/Reviewer: +200% decision quality |
| **Troubleshooting Guides** | `navigate` + `screenshot` + `network_capture` | Troubleshooter: +180% diagnosis speed |

### Enhanced Research Workflow

**Step 1: Knowledge Check**
```
chrome_search_tabs_content(query) → Check existing browser knowledge
If semantic_score > 0.8 → Use existing knowledge
Else → Proceed to interactive research
```

**Step 2: Interactive Investigation**
```
chrome_navigate(official_docs_url)
chrome_get_web_content() → Extract structured content
chrome_screenshot() → Capture visual elements (if UI-related)
chrome_search_tabs_content() → Correlate with existing knowledge
```

**Step 3: Verification & Synthesis**
```
If API/integration: chrome_network_capture() → Test live examples
If multiple sources: Repeat Step 2 across tabs → Semantic comparison
Synthesize findings with confidence scoring
```

### Agent-Specific Research Guidelines

**Language Agent**: 
- **Always** screenshot code examples with syntax highlighting
- Use `network_capture` for API integration patterns
- Semantic search for framework comparison

**DevOps Agent**:
- **Mandatory** screenshot verification for infrastructure setup
- Network monitoring for deployment API calls
- Visual confirmation of dashboard/UI states

**Frontend-UIUX Agent**:
- **Primary** tool: `screenshot` for all UI research
- Multi-tab component library comparison
- Visual pattern extraction and analysis

**Security Agent**:
- Network capture for security API examples
- Screenshot security configuration interfaces
- Content analysis of security documentation

**Alpha Agent**:
- Comparative research across multiple architectural solutions
- Semantic synthesis of complex multi-source research
- Visual decision matrices via screenshots

### Research Quality Standards

- **Visual Verification**: Screenshot key concepts for UI/setup instructions
- **Semantic Correlation**: Score > 0.7 across related sources
- **Live Validation**: Test APIs/endpoints when possible via network capture
- **Multi-Source Synthesis**: Minimum 2 authoritative sources for architecture decisions
- **Never proceed on assumptions**: Always verify with current, interactive documentation

## Reusable Playbooks

Maintain concise, reusable prompt templates ("playbooks") for repetitive workflows:

### Traditional Playbooks
- Dependency upgrades
- Documentation updates  
- Test-writing
- PR preparation

### Chrome MCP Enhanced Playbooks

**Framework Integration Playbook**:
```
1. chrome_search_tabs_content("framework_name patterns") → Check existing knowledge
2. chrome_navigate(official_docs + examples) → Multi-tab research
3. chrome_screenshot(key_patterns + setup_ui) → Visual documentation
4. chrome_network_capture() → Monitor API calls during examples
5. Synthesize implementation strategy with visual verification
```

**API Research Playbook**:
```
1. chrome_navigate(api_docs + interactive_explorer) 
2. chrome_get_web_content() → Extract endpoint details
3. chrome_network_capture_start() → Monitor live API calls
4. chrome_screenshot(request_response_examples) → Visual confirmation
5. chrome_search_tabs_content() → Correlate with existing integrations
```

**Setup Verification Playbook**:
```
1. chrome_navigate(installation_guide)
2. chrome_screenshot(each_step) → Visual step documentation
3. chrome_get_web_content() → Extract commands/configuration
4. chrome_search_tabs_content("common_issues") → Troubleshooting prep
5. Visual success criteria documentation
```

**Architecture Decision Playbook**:
```
1. chrome_navigate() × multiple_solutions → Parallel research
2. chrome_get_web_content() × all_tabs → Structured comparison
3. chrome_search_tabs_content("pros_cons_comparison") → Semantic analysis
4. chrome_screenshot(architecture_diagrams) → Visual comparison
5. Decision matrix with confidence scoring
```

Prefer adapting these Chrome MCP enhanced playbooks before writing ad-hoc research prompts.
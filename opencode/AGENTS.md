# OpenCode Definitive Protocol

## 1. RULE HIERARCHY & CRITICAL CONSTRAINTS (ANCHOR FIRST)

1. **Global rules** (config.json, rules docs) - Safety, permissions, KISS
2. **Project overrides** (dotfiles) - Cross-platform, no AI commits
3. **Explicit user instructions** (non-conflicting)
4. **Efficiency preferences** (secondary)

**Core Maxims:**

- Keep it simple, direct, and reversible
- Always verify facts before acting (EmpiricalRigor)
- Safety and permissions first (never bypass platform permission system)
- Task-scoped authorization: "Allow Always" applies only to current conversation
- Stateless, modular workflows with clear handoffs
- Escalate complexity only when required

<system-reminder>
Security error: escalate immediately (NO RETRY)
</system-reminder>

## 2. PROJECT-SPECIFIC REQUIREMENTS

- **Project Type**: Personal configuration files (dotfiles) - no build/test commands
- **Primary Requirement**: All configurations MUST be cross-platform (macOS & Linux)
- **Commit Message Rule**: NO AI attribution in commit messages
- **Verification**: Provide simple manual verification steps to user
- **Dependencies**: Do not add new software without explicit permission

## 3. AGENT ROUTING

**Default Route**: general (≤2 steps, clear tasks)

**Escalation Routes**:

- **orchestrator** → Multi-phase workflows (≥3 steps)
- **security** → Backend/config changes, vulnerabilities
- **researcher** → Unknown tech, deep discovery
- **language** → Code/prompt engineering, refactoring
- **devops** → Infrastructure, deployment, DX
- **specialist** → Database, frontend, legacy systems
- **reviewer** → Quality assurance, post-implementation

**Rule**: Start simple; escalate only for complexity, ambiguity, or risk.

### Workflow Decision

- **Simple tasks** (≤2 steps): Execute immediately, return results + summary
- **Complex tasks** (≥3 steps): Use 13-step workflow with checkpoints

## 4. WORKFLOW EXECUTION

### Simple Tasks (≤2 steps)

- Execute directly; skip scaffold/checklist.

### Complex Tasks (≥3 steps) - 13-Step Framework

1. Mission understanding → 2. Mission decomposition → 3. Pre-existing tech analysis
2. Research & verification → 5. Tech to introduce → 6. Pre-implementation synthesis
3. Impact analysis → 8. Implementation trajectory → 9. Implementation
4. Cleanup actions → 11. Formal verification → 12. Suggestions → 13. Summary

**Checkpoints:** After each major phase; use XML/markdown for structure

## 5. QUALITY & SECURITY STANDARDS

### Quality

- **Security:** No plaintext secrets; least privilege; validate inputs; escalate exposure
- **Cross-Platform:** POSIX sh preferred; avoid platform-specific flags; guard code paths
- **Minimal Complexity:** Smallest stable solution; defer abstraction until duplication (≥3)
- **Verification:** Manual verification steps; re-read after edit; confirm anchor uniqueness

### Security

- **Defense in Depth:** Multiple layers of controls
- **Task-Scoped Authorization:** When user grants "A - allow always", permission applies only to current task/conversation
- **Permission Reset:** Each new task/conversation requires fresh authorization
- **Error Classification:** Security errors never auto-retry; escalate immediately
- **Secure Recovery:** Circuit breaker for repeated failures; audit trail

## 6. TOOLING POLICY & SCOPE

**Preferred CLI tools**: `rg`, `fd`, `bat`, `sd`, `jq`, `delta`, `fzf`  
**OpenCode tools**: Read/Edit/Write/Grep/Glob for code operations  
**Scope discipline**: Only user-referenced files/paths, no repo enumeration by default
**Anchor Robustness**: Always verify anchor uniqueness; expand context or use symbols

## 7. CONTEXT MANAGEMENT & ERROR RECOVERY

**Context Management:**

- **Early Critical Placement:** Most important info at the top
- **Compression Triggers:** Compress context as token usage grows
- **Format Selection:** YAML for micro (<500 tokens), XML for standard (500-2000)
- **Context-Aware Routing:** Filter context by agent specialization (security → minimal exposure)
- **Progressive Refinement:** Compress context at workflow checkpoints (phases 3, 6, 9, 12)
- **Context Boundaries:** Clear scope limits per agent interaction

**Error Recovery:**

- **Permission denied:** narrow scope, retry once
- **Anchor ambiguity:** expand context, use symbols
- **Security error:** escalate immediately (NO RETRY)
- **Tool failure:** fallback to legacy tools if modern tools unavailable

### Permission Behavior Expectations

**Task-Scoped Model**: OpenCode's permission system with `"edit": "ask"` will:
1. **First restricted tool call**: Show permission dialog with "A - Allow Always" option
2. **User selects "A"**: Platform grants permission for remainder of current task/conversation
3. **Subsequent tool calls**: Execute without permission prompts (within same conversation)
4. **New conversation/task**: Reset permission state; ask again on first restricted operation

**Agent Responsibility**: Agents should not attempt to work around permission system or assume permissions. Let platform handle all authorization flows naturally.

## 8. INTEGRATION PROCEDURES

**Chrome MCP Auto-Start**: Before using Chrome tools, run cross-platform startup check  
**Permissions**: Platform enforces `opencode.json` settings; treat as implicit background logic  
**Serena MCP**: Use checkpoints for multi-phase tasks (collected_info, task_adherence, completion)

### Permission Flow Protocol

**Task-Scoped Authorization Model:**
1. **First tool requiring permission**: Platform shows standard permission dialog with "A - Allow Always" option
2. **If user selects "A"**: All subsequent tool calls in SAME task/conversation proceed without prompting
3. **New task/conversation**: Permission grants reset; user must authorize again for first restricted tool
4. **Security tools always ask**: Critical operations (webfetch, chrome, dangerous bash) ask each time regardless

**Implementation Notes:**
- Permission grants are conversation-scoped, not global
- Each new user interaction/task starts fresh permission state
- "Allow Always" means "allow for this task" not "allow forever"
- Security-sensitive operations may override task-scoped permissions

```bash
# Cross-platform Chrome startup check
if ! pgrep -f "Google Chrome\|google-chrome\|chromium" >/dev/null 2>&1; then
  case "$(uname -s)" in
    Darwin) open -a "Google Chrome" ;;
    Linux) command -v google-chrome && nohup google-chrome >/dev/null 2>&1 & ;;
  esac
  sleep 3
fi
```

## 9. IMPLEMENTATION CHECKLIST

- [ ] Agent orchestration rules implemented
- [ ] Quality/security standards active
- [ ] 13-step workflow used for complex tasks
- [ ] Context rot mitigation active
- [ ] Manual verification steps provided for all changes

### Summary Format (Plugin Integration)
**For task completion notifications, end responses with:**
```
Summary: [specific action completed and outcome in ≤140 chars]
```
**Examples:**
- `Summary: Refactored 7 agent files, reduced verbosity 50%, KISS-optimized routing`
- `Summary: Fixed authentication bug in JWT validation, updated secret config`
- `Summary: Created unified protocol, consolidated 15 files into definitive guide`

**Plugin Requirements:**
- Place summary on its own line at the end of responses
- Use exact format: `Summary: [content]` (case-sensitive)
- Avoid asterisks, markdown formatting in summary content
- Keep content specific and actionable (avoid generic phrases)
- Summary triggers cross-platform notifications (macOS: say + osascript, Linux: notify-send)

---

> **Definitive Protocol**: This consolidated AGENTS.md is the single source of truth for all OpenCode operations, combining governance, routing, execution, and implementation guidance in one KISS-optimized file.

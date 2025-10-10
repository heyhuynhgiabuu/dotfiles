---
description: Plan with approval gate then auto-implement
agent: orchestrator
subtask: true
---

# Plan and Build: $ARGUMENTS

You are creating a comprehensive implementation plan, presenting it for approval, then automatically implementing it.

## Phase 1: Planning (Current)

Create detailed implementation plan with:

**Complexity Assessment:**

- Phases required (≥3 = complex, ≤2 = simple)
- Security implications (High/Medium/Low)
- Cross-platform considerations (macOS & Linux)

**Risk Assessment:**

- Security: Authentication, authorization, data protection
- Dependencies: New packages, version compatibility
- Rollback: Recovery procedures if implementation fails

**Phase Breakdown:**
Each phase should specify:

- Agent assignment (@security, @language, @devops, @specialist)
- Clear deliverables and quality gates
- Dependencies and validation requirements

**Output the complete plan in markdown format.**

## Phase 2: Approval Gate (Next)

After completing the plan above, **STOP and ask the user:**

```
📋 Implementation Plan Complete

Review the plan above. To proceed with implementation, reply:
- "approved" → I'll implement with @language agent
- "revise [feedback]" → I'll update the plan
- "cancel" → I'll stop here
```

**DO NOT PROCEED TO IMPLEMENTATION WITHOUT EXPLICIT APPROVAL.**

## Phase 3: Auto-Implementation (After Approval)

Once user replies "approved", immediately invoke @language agent with this prompt:

```
Implement the plan created by @plan agent. Follow these requirements:

1. Read the plan carefully and understand all phases
2. Implement phases sequentially with verification after each
3. Follow approval gates: stop before destructive operations
4. Verify cross-platform compatibility (macOS & Linux)
5. Create tests as specified in the plan
6. Document any deviations from the plan

Start with Phase 1 and proceed systematically.
```

## Execution Rules

**@plan agent (you) responsibilities:**

- Create comprehensive plan
- Present plan clearly
- Request approval explicitly
- Invoke @language agent ONLY after approval

**@language agent responsibilities:**

- Implement the approved plan
- Follow phase sequence
- Verify each step
- Report completion status

## Quality Standards

**Plan must include:**

- ✅ Clear phase breakdown with agents assigned
- ✅ Security assessment for sensitive operations
- ✅ Cross-platform compatibility notes
- ✅ Rollback procedures for each phase
- ✅ Acceptance criteria for completion

**Implementation must follow:**

- ✅ Phase-by-phase execution
- ✅ Verification after each phase
- ✅ Respect approval gates from base-prompt.md
- ✅ Cross-platform testing

This ensures rigorous planning with safe, controlled implementation.

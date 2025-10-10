---
description: Quick plan and implement without approval (simple tasks only)
agent: plan
subtask: true
---

# Quick Build: $ARGUMENTS

You are rapidly planning and implementing a simple task without approval gates.

**USE THIS ONLY FOR SIMPLE TASKS (≤2 phases, low risk)**

## Rapid Planning

Create minimal plan with:

- Task breakdown (max 2 phases)
- Security check (must be LOW risk)
- Agent assignment

**If complexity assessment shows ≥3 phases or MEDIUM/HIGH security risk, STOP and recommend `/plan-and-build` instead.**

## Auto-Implementation

Immediately after plan, invoke @language agent with:

```
Implement this simple task: $ARGUMENTS

Follow these requirements:
1. Keep it simple (KISS principle)
2. Verify cross-platform (macOS & Linux)
3. Test basic functionality
4. No destructive operations without confirmation

Proceed with implementation.
```

## Safety Limits

**Automatic implementation is ONLY allowed for:**

- ✅ Single file changes
- ✅ Well-understood requirements
- ✅ LOW security risk
- ✅ No database changes
- ✅ No external API integrations
- ✅ Standard library usage only

**Require approval for:**

- ❌ Multi-file changes
- ❌ Security-sensitive operations
- ❌ Database modifications
- ❌ External integrations
- ❌ Performance-critical code

This command trades approval safety for speed on simple, low-risk tasks.

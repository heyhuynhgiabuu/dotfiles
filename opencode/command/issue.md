---
description: Analyze GitHub issue and create implementation plan
agent: build
---

## Analyze Issue $ARGUMENTS

**Issue details:** `!gh issue view $ARGUMENTS`
**Related files:** `!gh issue view $ARGUMENTS --json body | grep -o '\`[^`]*\`' | head -10 || echo "No file references found"`

**Analysis steps:**

1. **Issue breakdown:**
   - Problem description
   - Expected behavior
   - Current behavior
   - Steps to reproduce

2. **Implementation approach:**
   - Files that need changes
   - Testing strategy
   - Potential risks/edge cases

3. **Action plan:**
   - Create feature branch: `!git checkout -b issue-$ARGUMENTS`
   - Implementation steps (ordered)
   - Testing approach
   - Documentation updates needed

4. **Acceptance criteria:**
   - List concrete deliverables
   - Test cases to verify fix
   - Performance considerations

**Next:** Start implementing the planned solution step by step.
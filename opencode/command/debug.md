---
description: Autonomous debug analysis with approval gates
agent: build
---

## Debug Analysis for $ARGUMENTS

**Context**: @opencode/AGENTS.md
**Incident**: $ARGUMENTS

Autonomous debugging workflow:

1. **Gather context**: 
   - `!git log --oneline -10`
   - `!git status`
   - Relevant log files and error traces

2. **Root cause analysis**:
   - Analyze stack traces and error patterns
   - Identify likely failure points
   - Cross-reference with recent changes

3. **Solution recommendations**:
   - Propose specific fixes with reasoning
   - Include rollback plan if needed
   - Provide verification steps

4. **Human approval gate**: 
   - Present analysis and proposed fixes
   - Require explicit approval before any changes
   - Include manual verification checklist

**Safety**: All proposed fixes require human review and approval.
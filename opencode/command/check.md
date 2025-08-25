---
description: Quick code quality check and fix
agent: beta
---

## Code Quality Check for $ARGUMENTS

**Files to check:** $ARGUMENTS

Run comprehensive quality checks:

**Linting:** `!command -v npm > /dev/null && npm run lint 2>/dev/null || echo "No lint script found"`
**Type checking:** `!command -v tsc > /dev/null && npx tsc --noEmit 2>/dev/null || echo "No TypeScript configured"`
**Git status:** `!git status --porcelain`

**Analysis:**
1. Review files for common issues:
   - Unused imports/variables
   - Missing error handling
   - Code style violations
   - Performance concerns

2. **Fix automatically** where possible:
   - Format code
   - Remove unused imports
   - Fix simple linting errors

3. **Report findings:**
   - List issues requiring manual fix
   - Suggest improvements
   - Provide specific line references

**Action:** Apply automatic fixes first, then report remaining issues.
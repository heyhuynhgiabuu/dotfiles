---
description: Generate tests with human approval gate
agent: beta
---

## Generate Tests for $ARGUMENTS

**Context**: @opencode/AGENTS.md
**Target**: $ARGUMENTS

Create comprehensive test suite:

1. **Analyze target**: `!find . -name "*test*" -o -name "*spec*" | head -10`
2. **Review existing patterns**: Identify test frameworks and patterns
3. **Generate test cases**: 
   - Unit tests for core functions
   - Integration tests for workflows
   - Cross-platform compatibility tests
4. **Validation**: Ensure tests are runnable and meaningful

**Requirements**:
- Follow existing test patterns in codebase
- Include setup/teardown as needed
- Add verification steps for manual execution
- Cross-platform compatible (macOS & Linux)

**Human Approval Required**: All generated tests need review before integration.
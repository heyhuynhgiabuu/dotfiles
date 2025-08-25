---
description: Test-driven development workflow
agent: beta
---

## TDD Workflow for $ARGUMENTS

**Current tests:** `!find . -name "*test*" -o -name "*spec*" | head -10`
**Test runner:** `!command -v npm > /dev/null && npm run test --dry-run 2>/dev/null || echo "Checking test setup..."`

**TDD cycle for $ARGUMENTS:**

1. **RED - Write failing test:**
   - Create test file for $ARGUMENTS
   - Write minimal test that fails
   - Verify test failure: `!npm test -- --verbose`

2. **GREEN - Make test pass:**
   - Implement minimal code to pass test
   - Focus only on making test green
   - Run tests: `!npm test`

3. **REFACTOR - Improve code:**
   - Clean up implementation
   - Maintain passing tests
   - Consider edge cases

**Test structure:**
```javascript
describe('$ARGUMENTS', () => {
  it('should [expected behavior]', () => {
    // Arrange
    // Act  
    // Assert
  });
});
```

**Commit after each cycle:** RED → GREEN → REFACTOR
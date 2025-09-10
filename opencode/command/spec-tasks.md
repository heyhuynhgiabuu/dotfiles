---
description: Break down implementation plan into actionable tasks
agent: plan
---

# Spec-Driven Task Breakdown

You are proactively breaking down the implementation plan into specific, actionable tasks with clear dependencies and acceptance criteria.

## Current Workflow Status

Workflow status: !`bash "$(find . -name "spec-workflow.sh" -type f 2>/dev/null | head -1 || echo "./spec-driven-framework/scripts/spec-workflow.sh")" status`

Project detection: !`bash "$(find . -name "spec-workflow.sh" -type f 2>/dev/null | head -1 || echo "./spec-driven-framework/scripts/spec-workflow.sh")" detect`

## Proactive Task Generation

Based on the implementation plan, create detailed tasks that include:

1. **Setup Tasks**: Project structure, dependencies, environment setup
2. **Test-First Tasks**: TDD approach with failing tests before implementation
3. **Implementation Tasks**: Core functionality development
4. **Integration Tasks**: Component wiring, API connections, data flow
5. **Polish Tasks**: Testing, documentation, performance optimization

## Task Structure Requirements

Each task should include:

- **Task ID**: Unique identifier (T001, T002, etc.)
- **Title**: Clear, actionable description
- **Description**: Detailed implementation guidance
- **Acceptance Criteria**: Specific completion requirements
- **Dependencies**: Prerequisites and blockers
- **Estimated Effort**: Time complexity (XS, S, M, L, XL)
- **Priority**: Must-have vs nice-to-have

## Task Generation Execution

Execute task breakdown:

```bash
# Generate detailed implementation tasks
bash "$(find . -name "spec-workflow.sh" -type f 2>/dev/null | head -1 || echo "./spec-driven-framework/scripts/spec-workflow.sh")" tasks
```

## Task Quality Standards

Ensure tasks meet these criteria:

- ✅ **Testable**: Clear acceptance criteria for completion
- ✅ **Independent**: Minimal dependencies, parallel execution possible
- ✅ **Sized Appropriately**: No tasks larger than 4-6 hours
- ✅ **Well-Defined**: No ambiguity in requirements
- ✅ **Prioritized**: Critical path identified and prioritized

## Development Workflow Integration

Tasks should support:

- **TDD Workflow**: Tests written before implementation
- **Incremental Delivery**: Each task delivers working functionality
- **Continuous Integration**: Automated testing and validation
- **Code Review Ready**: Clean, well-documented code

## Next Steps Guidance

After task generation:

- Review tasks.md for completeness and clarity
- Start with highest priority tasks (setup and foundation)
- Use `/spec-status` to track progress
- Run `/spec-validate` to ensure implementation matches spec

## Progress Tracking

Implement task tracking with:

- ✅ Completion checkboxes
- 🔄 In-progress indicators
- ❌ Blocked task identification
- 📊 Progress visualization

This proactive task breakdown ensures systematic, measurable progress toward feature completion.

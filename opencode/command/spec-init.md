---
description: Initialize spec-driven development Workflow Phase
agent: orchestrator
---

# Spec-Driven Development Initialization

You are proactively initializing a spec-driven development workflow for the user's request. This ensures high-quality, systematic development with proper planning and testing.

## Current Context Analysis

Project detection: !`bash "$(find . -name "spec-workflow.sh" -type f 2>/dev/null | head -1 || echo "./spec-driven-framework/scripts/spec-workflow.sh")" detect`

## Proactive Workflow Setup

Based on the user's request "$ARGUMENTS", I should:

1. **Initialize Feature Branch**: Create a numbered feature branch (e.g., 001-user_authentication)
2. **Generate Specification**: Create a comprehensive spec.md file with user scenarios and requirements
3. **Setup Directory Structure**: Create organized folders for contracts, research, and implementation
4. **Project Context Integration**: Use detected project type, language, and framework information

## Implementation Steps

Execute the spec-driven workflow initialization:

```bash
# Initialize the workflow with the provided feature description
bash "$(find . -name "spec-workflow.sh" -type f 2>/dev/null | head -1 || echo "./spec-driven-framework/scripts/spec-workflow.sh")" init "$ARGUMENTS"
```

## Next Steps Guidance

After initialization, guide the user to:

- Review and refine the generated spec.md
- Run `/spec-plan` to generate implementation plan
- Use `/spec-tasks` to break down into actionable tasks

## Quality Assurance

Ensure the initialization includes:

- ✅ Proper branch naming convention
- ✅ Comprehensive specification template
- ✅ Project context detection
- ✅ Directory structure setup
- ✅ Integration with existing codebase patterns

This proactive approach ensures systematic development from day one, reducing technical debt and improving code quality.

---
description: Check current spec-driven workflow status
agent: general
---

# Spec-Driven Workflow Status Check

You are proactively monitoring the current state of the spec-driven development workflow to ensure systematic progress and identify any blockers.

## Current Workflow Status

Workflow status: !`bash "$(find . -name "spec-workflow.sh" -type f 2>/dev/null | head -1 || echo "./spec-driven-framework/scripts/spec-workflow.sh")" status`

## Comprehensive Status Analysis

Provide a detailed status report including:

1. **Branch Information**: Current feature branch and naming convention compliance
2. **File Status**: Presence and completeness of spec.md, plan.md, tasks.md
3. **Progress Tracking**: Task completion status and current phase
4. **Validation Results**: Prerequisites check and any issues
5. **Next Steps**: Recommended actions based on current state

## Status Categories

**Branch & Structure:**

- ✅ Feature branch properly named (XXX-feature_name format)
- ✅ Spec directory exists and is properly structured
- ✅ Required files (spec.md, plan.md, tasks.md) are present

**Content Quality:**

- ✅ Specification is complete with user scenarios and requirements
- ✅ Implementation plan includes technical architecture decisions
- ✅ Tasks are well-defined with clear acceptance criteria

**Progress Indicators:**

- 🔄 Current development phase
- 📊 Task completion percentage
- 🎯 Next milestone or deliverable

## Proactive Issue Detection

Identify and suggest solutions for:

- **Missing Prerequisites**: Files or setup requirements not met
- **Quality Issues**: Incomplete specifications or unclear requirements
- **Blockers**: Dependencies, technical challenges, or external factors
- **Timeline Concerns**: Delays or scope changes affecting delivery

## Recommendations Engine

Based on current status, provide:

- **Immediate Actions**: High-priority tasks to unblock progress
- **Quality Improvements**: Suggestions for better specifications or planning
- **Risk Mitigation**: Proactive steps to prevent future issues
- **Timeline Adjustments**: Realistic delivery estimates based on progress

## Integration Status

Verify integration with:

- **Version Control**: Proper branching and commit practices
- **Testing Framework**: Test coverage and TDD compliance
- **Code Quality**: Linting, formatting, and review processes
- **CI/CD Pipeline**: Automated validation and deployment readiness

## Next Steps Guidance

Provide clear next actions:

- Complete missing prerequisites
- Address any validation failures
- Move to next development phase
- Schedule reviews or checkpoints

This proactive status monitoring ensures the development process stays on track and maintains high quality standards.

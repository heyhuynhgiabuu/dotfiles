---
description: Validate implementation against specification
agent: reviewer
---

# Spec-Driven Implementation Validation

You are proactively validating that the current implementation meets all specification requirements and quality standards.

## Current Workflow Status

Workflow status: !`bash "$(find . -name "spec-workflow.sh" -type f 2>/dev/null | head -1 || echo "./spec-driven-framework/scripts/spec-workflow.sh")" status`

Prerequisites validation: !`bash "$(find . -name "spec-workflow.sh" -type f 2>/dev/null | head -1 || echo "./spec-driven-framework/scripts/spec-workflow.sh")" validate`

## Comprehensive Validation Framework

Validate implementation against multiple dimensions:

1. **Functional Requirements**: All specified features implemented correctly
2. **User Scenarios**: Acceptance criteria met for all user stories
3. **Technical Specifications**: Architecture, patterns, and design decisions
4. **Quality Standards**: Code quality, testing coverage, documentation
5. **Performance Criteria**: Response times, resource usage, scalability
6. **Security Requirements**: Authentication, authorization, data protection

## Validation Execution

Run comprehensive validation:

```bash
# Execute workflow validation
bash "$(find . -name "spec-workflow.sh" -type f 2>/dev/null | head -1 || echo "./spec-driven-framework/scripts/spec-workflow.sh")" validate
```

## Validation Categories

**Specification Compliance:**

- ✅ All functional requirements implemented
- ✅ User acceptance scenarios satisfied
- ✅ Business rules correctly enforced
- ✅ Edge cases and error conditions handled

**Technical Implementation:**

- ✅ Architecture patterns followed
- ✅ Design decisions documented and justified
- ✅ Code quality standards met
- ✅ Dependencies properly managed

**Testing & Quality:**

- ✅ Unit test coverage meets requirements
- ✅ Integration tests validate end-to-end flows
- ✅ Performance benchmarks achieved
- ✅ Security vulnerabilities addressed

**Documentation & Maintenance:**

- ✅ Code is well-documented
- ✅ API documentation complete
- ✅ Deployment and operations guides provided
- ✅ Maintenance procedures documented

## Issue Tracking & Resolution

For any validation failures:

- **Critical Issues**: Blockers that prevent deployment
- **Major Issues**: Significant functionality gaps
- **Minor Issues**: Quality improvements needed
- **Enhancement Opportunities**: Nice-to-have improvements

## Compliance Verification

Ensure alignment with:

- **Project Constitution**: Simplicity, testing, architecture principles
- **Industry Standards**: Best practices and security requirements
- **Regulatory Requirements**: Legal and compliance obligations
- **Performance SLAs**: Response time and throughput guarantees

## Validation Report Generation

Provide structured validation report:

- **Executive Summary**: Overall compliance status
- **Detailed Findings**: Specific issues and recommendations
- **Risk Assessment**: Impact of any failures
- **Remediation Plan**: Steps to address issues
- **Sign-off Criteria**: Requirements for approval

## Next Steps Based on Validation

- **Pass**: Proceed to deployment or next phase
- **Conditional Pass**: Address minor issues before proceeding
- **Fail**: Return to implementation with specific remediation steps
- **Review**: Schedule formal review meeting for critical issues

This proactive validation ensures high-quality deliverables that meet all requirements and maintain system integrity.

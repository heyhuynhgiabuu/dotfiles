---
description: Planning with spec-driven framework integration
agent: plan
---

# Planning with Spec-Driven Integration

You are combining OpenCode's production planning with the spec-driven framework for comprehensive, high-quality development planning.

## Current Context Analysis

Project detection: !`bash "$(find . -name "spec-workflow.sh" -type f 2>/dev/null | head -1 || echo "./spec-driven-framework/scripts/spec-workflow.sh")" detect`

Workflow status: !`bash "$(find . -name "spec-workflow.sh" -type f 2>/dev/null | head -1 || echo "./spec-driven-framework/scripts/spec-workflow.sh")" status`

## Dual Framework Integration

This command combines:

- **OpenCode Production Planning**: Pre-implementation artifacts and quality gates
- **Spec-Driven Framework**: Systematic specification, planning, and task breakdown

## Enhanced Planning Process

### Phase 1: OpenCode Production Requirements

**MANDATORY Pre-Implementation Artifacts:**

1. **Chain of Thought Analysis**
   - Task complexity assessment
   - Agent delegation requirements
   - Implementation scope estimation

2. **Chain of Draft (3 Alternatives)**
   - Alternative 1: Traditional development approach
   - Alternative 2: Spec-driven systematic approach
   - Alternative 3: Hybrid approach with selective artifacts
   - **Selected Approach:** [Justification based on complexity and requirements]

3. **YAGNI Check**
   - What we're explicitly NOT implementing
   - Future-proofing boundaries
   - Scope limitations and justifications

4. **Test Strategy**
   - Unit testing approach
   - Integration testing with staging endpoints only
   - End-to-end validation scenarios

### Phase 2: Spec-Driven Framework Integration

**Automatic Workflow Setup:**

```bash
# Initialize spec-driven workflow if not already done
bash "$(find . -name "spec-workflow.sh" -type f 2>/dev/null | head -1 || echo "./spec-driven-framework/scripts/spec-workflow.sh")" init "$ARGUMENTS"
```

**Enhanced Specification Generation:**

- User scenarios and acceptance criteria
- Technical requirements and constraints
- Quality standards and compliance needs
- Risk assessment and mitigation strategies

**Comprehensive Implementation Plan:**

- Technical architecture decisions
- Phase breakdown with clear deliverables
- Dependency analysis and management
- Performance and scalability considerations

## Risk Assessment Integration

**Security Implications:**

- Authentication and authorization requirements
- Data protection and privacy considerations
- Security testing integration
- Compliance requirements (GDPR, HIPAA, etc.)

**Cross-Platform Compatibility:**

- macOS and Linux support verification
- Dependency management across platforms
- Environment-specific configurations

**Dependency Requirements:**

- New packages and libraries needed
- Version compatibility constraints
- Migration and upgrade considerations

**Rollback Plan:**

- Database migration reversibility
- Configuration rollback procedures
- Feature flag implementation for gradual rollout

## Quality Gates and Validation

**Pre-Implementation Checklist:**

- [ ] Chain of Thought analysis completed
- [ ] Chain of Draft with 3 alternatives evaluated
- [ ] YAGNI principles applied and documented
- [ ] Test strategy defined with staging endpoints
- [ ] Risk assessment completed
- [ ] Human approval obtained for complex tasks

**Spec-Driven Validation:**

- [ ] Specification meets quality standards
- [ ] Implementation plan is comprehensive
- [ ] Tasks are well-defined and measurable
- [ ] Dependencies are identified and manageable

## Output Format Enhancement

```yaml
task: "$ARGUMENTS"
complexity: [simple|complex|enterprise]
framework: [traditional|spec-driven|hybrid]

# OpenCode Production Requirements
artifacts:
  cot: "[comprehensive analysis]"
  cod: "[3 alternatives + justification]"
  yagni: "[scoped limitations]"
  tests: "[staging-only test strategy]"

# Spec-Driven Framework Integration
spec_driven:
  initialized: [true|false]
  specification: "[quality assessment]"
  plan: "[architecture decisions]"
  tasks: "[breakdown status]"

risk_assessment:
  security: "[detailed implications]"
  compatibility: "[platform considerations]"
  dependencies: "[package requirements]"
  rollback: "[recovery procedures]"

status: [DRAFT|APPROVED|IMPLEMENTING|VERIFIED]
approval_required: [true|false]
approved_by: "[reviewer]"
```

## Integration with Existing Commands

**Complementary Commands:**

- `/spec-init` - Initialize spec-driven workflow
- `/spec-tasks` - Break down into actionable tasks
- `/spec-status` - Monitor progress
- `/spec-validate` - Validate implementation
- `/spec-review` - Review specification quality

**Enhanced Workflow:**

1. `/spec-plan-enhanced` (this command)
2. `/spec-init` (if not already initialized)
3. `/spec-plan` (detailed technical planning)
4. `/spec-tasks` (actionable breakdown)
5. `/spec-status` (ongoing monitoring)
6. `/spec-validate` (quality assurance)

## Human Approval Requirements

**Automatic Approval for Simple Tasks:**

- Single file changes
- Well-understood requirements
- Low risk modifications
- Standard library usage only

**Mandatory Human Review for:**

- Complex multi-step implementations
- Security-related changes
- Database schema modifications
- External API integrations
- Performance-critical components

## Audit Trail and Documentation

**Comprehensive Documentation:**

- All artifacts preserved in project repository
- Decision rationales clearly documented
- Alternative approaches evaluated and justified
- Risk assessments and mitigation plans
- Approval records and reviewer identification

**Integration with Project History:**

- Links to previous similar implementations
- Lessons learned from past projects
- Best practices and patterns applied
- Continuous improvement recommendations

This enhanced planning command provides the rigor of OpenCode's production requirements combined with the systematic approach of spec-driven development, ensuring high-quality, well-planned implementations with comprehensive validation and audit trails.

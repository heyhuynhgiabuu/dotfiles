---
description: Production planning command for enforcing pre-implementation artifacts
agent: build
---

# /opencode-plan - Production Planning Command

**Purpose**: Enforce production-ready planning before implementation

## Command Usage
```
/opencode-plan [task-description]
```

## Execution Flow

1. **Complexity Assessment**
   - Analyze task requirements
   - Determine agent delegation needs
   - Estimate implementation scope

2. **Pre-Implementation Artifacts** (MANDATORY)
   - Chain of Thought analysis
   - Chain of Draft with 3 alternatives
   - YAGNI check (what we're NOT implementing)
   - Test strategy with staging endpoints

3. **Risk Assessment**
   - Security implications
   - Cross-platform compatibility
   - Dependency requirements
   - Rollback plan

4. **Implementation Gate**
   - Human approval required
   - All artifacts completed
   - Verification plan documented

## Output Format
```yaml
task: "[task-description]"
complexity: [simple|complex]
artifacts:
  cot: "[analysis]"
  cod: "[3 alternatives + selected]"
  yagni: "[what we're not implementing]"
  tests: "[test strategy]"
risk_assessment:
  security: "[implications]"
  dependencies: "[new packages needed]"
  rollback: "[recovery plan]"
status: [DRAFT|APPROVED|IMPLEMENTING|VERIFIED]
```

## Integration Points
- Links to `opencode/workflow/planning-template.md`
- Enforces `AGENTS.md` quality standards
- Triggers human checkpoint for complex tasks
- Requires staging-only integration tests

## Security Requirements
- No production endpoints in test plans
- Secret scanning before artifact creation
- Audit trail for all approvals
- Mandatory human review for security-related changes
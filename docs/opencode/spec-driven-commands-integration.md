# Spec-Driven Development Commands Integration

This document describes the custom OpenCode commands that proactively integrate with the universal spec-driven development framework.

## Overview

The spec-driven commands provide a proactive, systematic approach to software development that ensures high quality, clear requirements, and measurable progress. These commands automatically detect project context and suggest appropriate workflows.

## Available Commands

### Core Spec-Driven Commands

#### `/spec-suggest` - Proactive Recommendation Engine

**Agent:** orchestrator
**Purpose:** Analyzes current context and recommends spec-driven approach when beneficial

**When to Use:**

- Before starting any new development task
- When evaluating development approaches
- For complex or high-risk features

**Features:**

- ✅ Project type detection and analysis
- ✅ Complexity assessment
- ✅ Quality requirement evaluation
- ✅ Team coordination needs assessment
- ✅ Proactive workflow recommendations

#### `/spec-init` - Workflow Initialization

**Agent:** orchestrator
**Purpose:** Initialize complete spec-driven workflow for new features

**What it does:**

- Creates numbered feature branch (e.g., 001-user_authentication)
- Generates comprehensive specification template
- Sets up organized directory structure
- Integrates with detected project context

**Usage:**

```
/spec-init user authentication system
```

#### `/spec-plan` - Implementation Planning

**Agent:** plan
**Purpose:** Generate detailed technical implementation plan

**Features:**

- ✅ Technical architecture design
- ✅ Phase breakdown with deliverables
- ✅ Dependency analysis
- ✅ Risk assessment and mitigation
- ✅ Testing strategy definition
- ✅ Performance considerations

#### `/spec-tasks` - Task Breakdown

**Agent:** plan
**Purpose:** Break implementation plan into actionable, testable tasks

**Task Structure:**

- **Task ID:** Unique identifier (T001, T002, etc.)
- **Acceptance Criteria:** Clear completion requirements
- **Dependencies:** Prerequisites and blockers
- **Effort Estimation:** XS, S, M, L, XL sizing
- **Priority:** Must-have vs nice-to-have

#### `/spec-status` - Progress Monitoring

**Agent:** general
**Purpose:** Comprehensive workflow status and progress tracking

**Status Categories:**

- ✅ Branch and structure validation
- ✅ File completeness verification
- ✅ Progress indicators and milestones
- ✅ Issue detection and recommendations
- ✅ Next steps guidance

#### `/spec-validate` - Implementation Validation

**Agent:** reviewer
**Purpose:** Validate implementation against specification requirements

**Validation Dimensions:**

- ✅ Functional requirements compliance
- ✅ User scenario satisfaction
- ✅ Technical specification adherence
- ✅ Quality standards verification
- ✅ Performance criteria validation
- ✅ Security requirements checking

#### `/spec-review` - Specification Quality Review

**Agent:** reviewer
**Purpose:** Review specification quality and provide improvement recommendations

**Review Criteria:**

- ✅ Completeness and clarity
- ✅ Testability and feasibility
- ✅ Consistency and scope
- ✅ Documentation quality
- ✅ Stakeholder alignment

### Enhanced Integration Commands

#### `/spec-plan-enhanced` - Enhanced Planning with OpenCode Integration

**Agent:** plan
**Purpose:** Combines OpenCode production planning with spec-driven framework

**Integration Features:**

- ✅ OpenCode Chain of Thought analysis
- ✅ Chain of Draft with 3 alternatives
- ✅ YAGNI principle application
- ✅ Spec-driven workflow initialization
- ✅ Comprehensive risk assessment
- ✅ Quality gate enforcement

#### `/spec-review-enhanced` - Enhanced Code Review with Validation

**Agent:** reviewer
**Purpose:** Comprehensive code review combining OpenCode standards with spec validation

**Enhanced Review Features:**

- ✅ Code quality and security assessment
- ✅ Specification compliance validation
- ✅ Performance and maintainability analysis
- ✅ Automated quality gate checking
- ✅ Integration with existing review workflows

#### `/spec-workflow` - Complete Workflow Management

**Agent:** orchestrator
**Purpose:** End-to-end workflow orchestration integrating all OpenCode and spec-driven commands

**Workflow Management:**

- ✅ Phase-based development lifecycle
- ✅ Command integration matrix
- ✅ Quality assurance automation
- ✅ Progress tracking and reporting
- ✅ Risk management integration

#### `/spec-tdd-enhanced` - Enhanced TDD with Task Integration

**Agent:** language
**Purpose:** Test-Driven Development enhanced with spec-driven task management

**TDD Enhancements:**

- ✅ Task-based development workflow
- ✅ Comprehensive test coverage planning
- ✅ Quality assurance integration
- ✅ Progress synchronization
- ✅ Spec compliance validation

#### `/spec-automate` - Automated Workflow Orchestration

**Agent:** orchestrator
**Purpose:** Intelligent automation of spec-driven workflows with OpenCode integration

**Automation Features:**

- ✅ Context-aware workflow detection
- ✅ Automated command sequencing
- ✅ Quality gate enforcement
- ✅ Progress monitoring and reporting
- ✅ Continuous learning and optimization

## Proactive Features

### Automatic Context Detection

All commands automatically detect:

- **Project Type:** Web app, API, library, CLI tool
- **Technology Stack:** Language, framework, testing tools
- **Current State:** Branch, files, progress status
- **Quality Requirements:** Based on project constitution

### Smart Recommendations

Commands proactively suggest:

- **When to use spec-driven approach**
- **Quality improvements needed**
- **Risk mitigation strategies**
- **Next development steps**
- **Integration opportunities**

### Quality Assurance Integration

Built-in quality gates ensure:

- **Constitution Compliance:** Simplicity, testing, architecture
- **Industry Standards:** Best practices and security
- **Regulatory Requirements:** Legal and compliance
- **Performance SLAs:** Response times and scalability

## Workflow Integration

### Complete Development Cycle

#### Full Spec-Driven Workflow (Complex Features)

1. **Planning Phase:**

   ```
   /spec-suggest → /spec-plan-enhanced → /spec-init → /spec-plan → /spec-tasks
   ```

2. **Implementation Phase:**

   ```
   /spec-status → /spec-tdd-enhanced → /spec-workflow
   ```

3. **Validation Phase:**
   ```
   /spec-review-enhanced → /spec-validate → /spec-review
   ```

#### Light Workflow (Simple Tasks)

1. **Quick Start:**

   ```
   /spec-suggest → /spec-plan-enhanced → /spec-init
   ```

2. **Implementation:**

   ```
   /spec-status → /tdd → /spec-tdd-enhanced
   ```

3. **Validation:**
   ```
   /spec-review-enhanced → /spec-validate
   ```

#### Automated Workflow (Recommended)

1. **Smart Orchestration:**

   ```
   /spec-automate [task-description]
   ```

   _(Automatically determines and executes optimal workflow)_

### Command Integration Matrix

| Phase          | OpenCode Command | Spec-Driven Command     | Enhanced Integration                         |
| -------------- | ---------------- | ----------------------- | -------------------------------------------- |
| Planning       | `/plan`          | `/spec-plan-enhanced`   | Production artifacts + spec framework        |
| Specification  | `/research`      | `/spec-init`            | Systematic spec creation + context detection |
| Implementation | `/tdd`           | `/spec-tdd-enhanced`    | TDD + task management + quality gates        |
| Review         | `/review`        | `/spec-review-enhanced` | Code review + spec compliance validation     |
| Validation     | `/verify`        | `/spec-validate`        | Quality verification + spec adherence        |
| Documentation  | `/docs`          | `/spec-review`          | Documentation + spec quality assessment      |
| Workflow       | `/setup`         | `/spec-workflow`        | Complete lifecycle orchestration             |
| Automation     | N/A              | `/spec-automate`        | Intelligent workflow automation              |

### Integration with Existing Workflows

**Git Workflow:**

- Automatic feature branch creation
- Commit message standards
- Pull request templates

**Testing Workflow:**

- TDD approach enforcement
- Test coverage requirements
- Integration testing setup

**Code Quality:**

- Linting and formatting
- Documentation standards
- Security scanning

## Command Dependencies

### Framework Scripts

All commands integrate with:

- `spec-workflow.sh` - Main workflow orchestration
- `detect-project.sh` - Project context analysis
- Template files (spec.md, plan.md, tasks.md)

### OpenCode Agents

Commands leverage specialized agents:

- **orchestrator:** Workflow coordination and planning
- **plan:** Technical planning and task breakdown
- **reviewer:** Quality assurance and validation
- **general:** Status monitoring and reporting

## Usage Examples

### New Feature Development

```
# Start with recommendation
/spec-suggest implement user authentication

# Initialize workflow
/spec-init user authentication system

# Generate implementation plan
/spec-plan

# Break down into tasks
/spec-tasks

# Monitor progress
/spec-status

# Validate completion
/spec-validate
```

### Complex Bug Fix

```
# Assess if spec-driven approach needed
/spec-suggest fix authentication bypass vulnerability

# Initialize security-focused workflow
/spec-init security authentication fix

# Plan security remediation
/spec-plan

# Track security testing tasks
/spec-tasks
```

### API Development

```
# Recommend API contract approach
/spec-suggest create user management API

# Initialize API specification
/spec-init user management API v1

# Design API contracts and schemas
/spec-plan

# Break down endpoint implementation
/spec-tasks
```

## Configuration

### Command Location

Commands are stored in: `opencode/command/`

**Core Spec-Driven Commands:**

- `spec-suggest.md` - Proactive recommendation engine
- `spec-init.md` - Workflow initialization
- `spec-plan.md` - Implementation planning
- `spec-tasks.md` - Task breakdown
- `spec-status.md` - Progress monitoring
- `spec-validate.md` - Implementation validation
- `spec-review.md` - Specification quality review

**Enhanced Integration Commands:**

- `spec-plan-enhanced.md` - Enhanced planning with OpenCode integration
- `spec-review-enhanced.md` - Enhanced code review with validation
- `spec-workflow.md` - Complete workflow management
- `spec-tdd-enhanced.md` - Enhanced TDD with task integration
- `spec-automate.md` - Automated workflow orchestration

### Framework Location

Framework components in: `opencode/spec-driven-framework/`

- `scripts/spec-workflow.sh` - Main workflow script
- `scripts/detect-project.sh` - Project detection
- `templates/` - Specification templates
- `prompts/` - Agent integration prompts

## Benefits

### Quality Improvements

- **Clear Requirements:** Unambiguous specifications
- **Systematic Development:** Structured workflow
- **Quality Gates:** Validation at each phase
- **Risk Mitigation:** Proactive issue identification

### Efficiency Gains

- **Faster Onboarding:** Clear project structure
- **Reduced Rework:** Early requirement validation
- **Better Planning:** Realistic estimates and timelines
- **Improved Communication:** Clear stakeholder expectations

### Compliance & Documentation

- **Audit Trail:** Complete development records
- **Regulatory Compliance:** Formal requirement tracking
- **Knowledge Transfer:** Comprehensive documentation
- **Maintenance Support:** Clear system understanding

## Troubleshooting

### Common Issues

**Command Not Found:**

- Verify command files exist in `opencode/command/`
- Check file permissions and naming
- Restart OpenCode session

**Script Execution Errors:**

- Ensure framework scripts are executable
- Check bash path and dependencies
- Verify project root detection

**Context Detection Issues:**

- Check project structure matches expected patterns
- Update detection script for custom project types
- Verify git repository setup

### Getting Help

**Status Commands:**

- `/spec-status` - Current workflow state
- `/help` - General OpenCode help
- Check framework README for detailed documentation

**Debug Information:**

- Run detection script manually
- Check workflow script output
- Review generated specification files

## Future Enhancements

### Planned Features

- **CI/CD Integration:** Automated validation pipelines
- **Team Collaboration:** Multi-user workflow support
- **Template Customization:** Project-specific templates
- **Metrics & Analytics:** Development productivity tracking
- **Integration APIs:** Third-party tool connections

### Customization Options

- **Project Templates:** Custom specification formats
- **Quality Gates:** Configurable validation rules
- **Agent Prompts:** Specialized agent configurations
- **Workflow Extensions:** Additional development phases

This integration provides a comprehensive, proactive approach to software development that ensures quality, efficiency, and systematic progress across all project types.

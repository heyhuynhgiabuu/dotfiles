# OpenCode Spec-Driven Development Framework

A universal framework for spec-driven development that integrates seamlessly with OpenCode agents across any project type and technology stack.

## Overview

This framework provides a standardized workflow for software development that ensures:

- ✅ **Consistency** across all projects and team members
- ✅ **Quality** through gated phases and validation checkpoints
- ✅ **Efficiency** with parallel task execution and automated tooling
- ✅ **Scalability** from small scripts to large distributed systems
- ✅ **Cross-platform** compatibility and deployment

## Core Principles

### 1. Constitution-First Governance

Every project follows constitutional principles:

- **Library-First**: Every feature as a standalone library
- **CLI Interface**: All libraries expose functionality via command-line
- **Test-First (TDD)**: Tests written before implementation, must fail first
- **Simplicity**: Start simple, justify complexity with business rationale

### 2. Phased Development Lifecycle

```
Spec → Plan → Tasks → Implementation → Validation
```

### 3. Auto-Detection & Adaptation

The framework automatically detects:

- **Project Type**: web-app, mobile-app, cli-tool, library, api-service
- **Technology Stack**: Language, framework, testing tools
- **Project Structure**: Directory layout and conventions
- **Dependencies**: Libraries and external services

## Quick Start

### 1. Copy Framework to Any Project

```bash
# Copy the framework to your project (any location)
cp -r /path/to/opencode/spec-driven-framework ./my-framework

# Make scripts executable
chmod +x my-framework/scripts/*.sh
```

### 2. Use OpenCode Commands (Recommended)

```bash
# Initialize a new feature
/spec-init user authentication system

# Generate implementation plan
/spec-plan

# Create executable tasks
/spec-tasks

# Monitor progress
/spec-status

# Validate completion
/spec-validate
```

### 3. Direct Script Usage (Alternative)

```bash
# Find the framework location dynamically
FRAMEWORK_DIR=$(find . -name "spec-workflow.sh" -type f 2>/dev/null | head -1 | xargs dirname)

# Initialize a new feature
"$FRAMEWORK_DIR/spec-workflow.sh" init "user authentication" "Add secure user login"

# Follow the workflow
"$FRAMEWORK_DIR/spec-workflow.sh" plan
"$FRAMEWORK_DIR/spec-workflow.sh" tasks
"$FRAMEWORK_DIR/spec-workflow.sh" validate
"$FRAMEWORK_DIR/spec-workflow.sh" status
```

## Project Type Support

### Web Applications (React/Vue + API)

```
frontend/          # React/Vue/Angular application
├── src/
├── tests/
└── package.json

backend/           # API server
├── src/
├── tests/
└── package.json

specs/001-feature/ # Feature specifications
├── spec.md
├── plan.md
├── tasks.md
└── contracts/
```

### API Services (FastAPI/Express/Spring)

```
src/               # Main application code
├── models/
├── routes/
├── services/
└── middleware/

tests/             # Comprehensive test suite
├── unit/
├── integration/
└── contract/

specs/            # Feature specifications
└── 001-feature/
```

### CLI Tools (Python/Go/Rust)

```
cmd/               # Command-line interfaces
├── tool/
└── commands/

pkg/               # Reusable libraries
├── library1/
└── library2/

internal/          # Private implementation
└── core/

specs/             # Feature specifications
```

### Mobile Apps (React Native/Flutter)

```
src/               # Cross-platform code
├── components/
├── screens/
└── services/

android/           # Android-specific
ios/               # iOS-specific

tests/             # Test suites
```

### Libraries/Packages

```
src/ or lib/       # Library code
examples/          # Usage examples
tests/             # Test suite
docs/              # Documentation

specs/             # Feature specifications
```

## OpenCode Integration

### Primary: OpenCode Commands (Recommended)

```bash
# Step-by-step workflow
/spec-init user authentication system        # Initialize specification
/spec-plan                                   # Generate implementation plan
/spec-tasks                                  # Break down into tasks
/spec-status                                 # Check progress
/spec-validate                               # Validate implementation
```

### Secondary: Direct Agent Usage

```bash
# Use OpenCode agents for specific tasks
@researcher "Create a comprehensive spec for user authentication feature"
@plan "Create implementation plan for user authentication"
@language "Generate development tasks for the authentication system"
@security "Add authentication and authorization logic"
@devops "Configure deployment and monitoring"
```

### Tertiary: Direct Script Execution

```bash
# Find framework location dynamically
FRAMEWORK_DIR=$(find . -name "spec-workflow.sh" -type f 2>/dev/null | head -1 | xargs dirname)

# Execute workflow steps
"$FRAMEWORK_DIR/spec-workflow.sh" init "user authentication" "Add secure user login"
"$FRAMEWORK_DIR/spec-workflow.sh" plan
"$FRAMEWORK_DIR/spec-workflow.sh" tasks
"$FRAMEWORK_DIR/spec-workflow.sh" validate
```

## Workflow Phases

### Phase 1: Specification (`/spec-init`)

**Goal**: Capture business requirements without technical details

**Commands**: `/spec-init`

**Deliverables**:

- `specs/###-feature/spec.md` - Business requirements
- User stories and acceptance criteria
- Functional and non-functional requirements
- Key entities and data relationships

**Validation**:

- ✅ No technical implementation details
- ✅ Requirements are testable and unambiguous
- ✅ Business stakeholders can understand and approve

### Phase 2: Planning (`/spec-plan`)

**Goal**: Create technical implementation strategy

**Commands**: `/spec-plan`

**Deliverables**:

- `specs/###-feature/plan.md` - Technical approach
- `specs/###-feature/research.md` - Technical unknowns resolved
- `specs/###-feature/data-model.md` - Entity definitions
- `specs/###-feature/contracts/` - API specifications
- `specs/###-feature/quickstart.md` - Validation scenarios

**Validation**:

- ✅ Constitution compliance verified
- ✅ Technical unknowns resolved
- ✅ Project structure defined
- ✅ Failing tests created (TDD)

### Phase 3: Task Generation (`/spec-tasks`)

**Goal**: Break implementation into executable units

**Commands**: `/spec-tasks`

**Deliverables**:

- `specs/###-feature/tasks.md` - Structured task list
- Task dependencies and parallel execution markers
- File paths and implementation details
- Quality gates and validation checkpoints

**Validation**:

- ✅ All tasks have clear deliverables
- ✅ Dependencies properly mapped
- ✅ Parallel execution opportunities identified
- ✅ TDD compliance (tests before implementation)

### Phase 4: Implementation

**Goal**: Execute tasks following TDD principles

**Commands**: Use standard `/tdd` command

**Process**:

1. **Setup**: Project structure and dependencies
2. **Tests First**: Write failing tests (TDD requirement)
3. **Core Implementation**: Business logic and features
4. **Integration**: Connect components and services
5. **Polish**: Testing, performance, documentation

**Validation**:

- ✅ All tests pass
- ✅ Code review completed
- ✅ Documentation updated
- ✅ Performance requirements met

### Phase 5: Validation (`/spec-validate`)

**Goal**: Ensure quality and production readiness

**Commands**: `/spec-validate` → `/spec-status`

**Checkpoints**:

- ✅ All acceptance criteria met
- ✅ Security audit passed
- ✅ Performance benchmarks achieved
- ✅ Documentation complete
- ✅ Deployment configuration verified

## Constitution Compliance

### Mandatory Principles

#### 1. Library-First Architecture

```
✅ DO: Every feature as standalone library
✅ DO: Clear CLI interface for each library
❌ DON'T: Direct application code without library abstraction
```

#### 2. Test-Driven Development (TDD)

```
✅ DO: Write tests before implementation
✅ DO: Tests must fail before coding begins
✅ DO: Red-Green-Refactor cycle
❌ DON'T: Implementation without failing tests
```

#### 3. Simplicity & Justification

```
✅ DO: Start with simplest solution
✅ DO: Justify complexity with business rationale
❌ DON'T: Over-engineer without proven need
```

#### 4. Cross-Platform Compatibility

```
✅ DO: Design for target platforms from start
✅ DO: Test on all supported platforms
❌ DON'T: Platform-specific assumptions
```

### Quality Gates

#### Pre-Implementation

- ✅ **Constitution Check**: All principles verified
- ✅ **Research Complete**: No [NEEDS CLARIFICATION] markers
- ✅ **Tests Ready**: Failing test suite prepared

#### Implementation

- ✅ **TDD Compliance**: Tests written before code
- ✅ **Code Review**: All changes reviewed
- ✅ **Integration**: Components properly connected

#### Release

- ✅ **All Tests Pass**: Unit, integration, contract tests
- ✅ **Performance**: Benchmarks met
- ✅ **Security**: Audit completed
- ✅ **Documentation**: User and API docs complete

## Tool Integration

### Version Control

```bash
# Feature branches follow naming convention
git checkout -b 001-user-authentication

# Commit follows TDD pattern
git add tests/
git commit -m "RED: Add failing tests for user authentication"
git add src/
git commit -m "GREEN: Implement user authentication"
git commit -m "REFACTOR: Clean up authentication code"
```

### CI/CD Integration

```yaml
# .github/workflows/spec-driven.yml
name: Spec-Driven Development
on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Framework
        run: |
          # Copy framework if not present
          if [ ! -f "spec-workflow.sh" ]; then
            cp -r /path/to/opencode/spec-driven-framework ./
            chmod +x spec-driven-framework/scripts/*.sh
          fi
      - name: Validate Constitution
        run: |
          # Dynamic path detection
          FRAMEWORK_DIR=$(find . -name "spec-workflow.sh" -type f | head -1 | xargs dirname)
          "$FRAMEWORK_DIR/spec-workflow.sh" validate
      - name: Run Tests
        run: npm test # or appropriate test command
```

### IDE Integration

```json
// .vscode/tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Initialize Feature (OpenCode)",
      "type": "shell",
      "command": "opencode",
      "args": ["/spec-init", "${input:featureName}", "${input:featureDesc}"],
      "group": "build"
    },
    {
      "label": "Initialize Feature (Direct)",
      "type": "shell",
      "command": "${workspaceFolder}/spec-driven-framework/scripts/spec-workflow.sh",
      "args": ["init", "${input:featureName}", "${input:featureDesc}"],
      "group": "build"
    }
  ],
  "inputs": [
    {
      "id": "featureName",
      "description": "Feature name (e.g., user-authentication)",
      "type": "promptString"
    },
    {
      "id": "featureDesc",
      "description": "Feature description",
      "type": "promptString"
    }
  ]
}
```

## Advanced Usage

### Custom Project Types

```bash
# Use OpenCode commands for custom projects
/spec-init custom feature "description"
/spec-plan
/spec-tasks

# Or direct script with dynamic path
FRAMEWORK_DIR=$(find . -name "spec-workflow.sh" -type f 2>/dev/null | head -1 | xargs dirname)
"$FRAMEWORK_DIR/scripts/detect-project.sh" > project-context.json

# Modify templates based on project context
# Add custom validation rules
# Integrate with specialized tooling
```

### Multi-Agent Coordination

```bash
# Use OpenCode agents for implementation
@orchestrator "Coordinate implementation of e-commerce checkout system"
@researcher "Research payment processing best practices"
@security "Audit payment security requirements"
@language "Implement payment processing logic"
@devops "Configure payment infrastructure"
```

### Parallel Development

```bash
# Use standard TDD for parallel task execution
/tdd

# Or execute independent tasks in parallel
@language "Implement user registration API" &
@language "Implement user login API" &
@language "Implement password reset API" &
wait
```

## Troubleshooting

### Common Issues

#### Framework Location Not Found

```bash
# Check if framework scripts exist
find . -name "spec-workflow.sh" -type f

# If not found, copy framework to project
cp -r /path/to/opencode/spec-driven-framework ./
chmod +x spec-driven-framework/scripts/*.sh
```

#### Constitution Violations

```bash
# Use OpenCode commands (recommended)
/spec-validate

# Or direct script with dynamic path
FRAMEWORK_DIR=$(find . -name "spec-workflow.sh" -type f 2>/dev/null | head -1 | xargs dirname)
"$FRAMEWORK_DIR/spec-workflow.sh" validate
```

#### Project Detection Issues

```bash
# Use OpenCode status command
/spec-status

# Or debug with direct script
FRAMEWORK_DIR=$(find . -name "spec-workflow.sh" -type f 2>/dev/null | head -1 | xargs dirname)
"$FRAMEWORK_DIR/spec-workflow.sh" detect
```

#### Task Dependencies

```bash
# Check with OpenCode status
/spec-status

# Validate task dependencies
find specs -name "tasks.md" -exec grep -l "blocks\|before\|after" {} \;
```

## Examples

### Web Application Feature

```bash
# Step-by-step workflow
/spec-init user dashboard "Create personalized dashboard for users"
/spec-plan                                   # Generate plan
/spec-tasks                                  # Break down tasks

# Implementation with standard commands
/tdd                                         # Test-driven development
/review                                      # Code review

# Final validation
/spec-validate                               # Validate against spec
```

### API Service Feature

```bash
# Initialize with planning
/spec-init payment processing "Add Stripe payment integration"
/spec-plan                                   # Generate secure plan
/spec-tasks                                  # Break down tasks

# Implement with standard commands
@security "Design secure payment flow"
@language "Implement payment processing with security"
@devops "Configure secure payment infrastructure"

# Final validation
/spec-validate                               # Validate implementation
```

### CLI Tool Feature

```bash
# Quick initialization
/spec-init data export "Add CSV/JSON export functionality"
/spec-plan                                   # Generate plan
/spec-tasks                                  # Break down tasks

# Implement with standard commands
@language "Implement export commands with multiple formats"
@language "Add export configuration options"

# Validate implementation
/spec-validate                               # Final validation
```

### Legacy Direct Script Usage (Not Recommended)

```bash
# Find framework location dynamically
FRAMEWORK_DIR=$(find . -name "spec-workflow.sh" -type f 2>/dev/null | head -1 | xargs dirname)

# Execute workflow (hardcoded path approach)
"$FRAMEWORK_DIR/spec-workflow.sh" init "feature name" "description"
"$FRAMEWORK_DIR/spec-workflow.sh" plan
"$FRAMEWORK_DIR/spec-workflow.sh" tasks
"$FRAMEWORK_DIR/spec-workflow.sh" validate
```

## Contributing

### Adding New Project Types

1. Update `scripts/detect-project.sh` with new detection logic
2. Add project type templates in `templates/`
3. Update prompts in `prompts/` for new project types
4. Add validation rules in workflow scripts

### Extending Constitution

1. Document new principles in constitution template
2. Update validation scripts
3. Add compliance checks to workflow
4. Update documentation

### Custom Integrations

1. Add new agent prompts for specialized workflows
2. Create custom validation scripts
3. Integrate with external tools and services
4. Add project-specific templates

## License

This framework is part of the OpenCode ecosystem and follows the same licensing terms.

## Support

- **OpenCode Commands**: Use `/spec-status` for current framework status
- **Documentation**: See OpenCode command help (`/help`) or individual script help
- **Issues**: Report framework issues in the OpenCode repository
- **Discussions**: Join OpenCode community discussions
- **Examples**: Check the `templates/` directory for project templates

---

**Framework Version**: 1.0.0
**OpenCode Integration**: Full compatibility with dynamic path detection
**Project Types**: Universal (web, mobile, CLI, API, library)
**Technology Stacks**: Auto-detected and supported
**Path Detection**: Dynamic location finding for any project structure

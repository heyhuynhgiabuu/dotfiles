# OpenCode Custom Commands Reference

Quick reference for all custom commands in this dotfiles repo.

## Auto-Implementation

### `/plan-and-build`

Plan complex task with approval gate then implement

- **Agent**: @plan → @language
- **Approval**: Required
- **Use for**: Complex tasks (≥3 phases)

### `/quick-build`

Fast plan and implement for simple tasks

- **Agent**: @plan → @language
- **Approval**: Not required
- **Use for**: Simple tasks (≤2 phases, low risk)

## Spec-Driven Framework

### `/spec-plan`

Planning with spec-driven framework integration

- **Agent**: @orchestrator
- **Generates**: Requirements + design + tasks

### `/spec-tasks`

Break down implementation plan into actionable tasks

- **Agent**: @orchestrator
- **Output**: Detailed task breakdown with dependencies

### `/spec-status`

Monitor spec-driven workflow progress

- **Agent**: general
- **Shows**: Current phase, completion status

### `/spec-validate`

Validate implementation against spec

- **Agent**: @reviewer
- **Checks**: Quality standards, acceptance criteria

### `/spec-init`

Initialize spec-driven workflow for feature

- **Agent**: @plan
- **Creates**: Project structure, initial specs

## Research & Analysis

### `/research`

Enhanced research with multimedia support

- **Agent**: @researcher
- **Supports**: YouTube videos, docs, code examples

### `/analyze-project`

Comprehensive project analysis

- **Agent**: general
- **Output**: Architecture, dependencies, complexity

## Development Workflow

### `/commit`

Create git commit with best practices

- **Agent**: general
- **Follows**: Conventional commit format

### `/pr`

Create pull request with description

- **Agent**: general
- **Generates**: PR title, body, labels

### `/issue`

Create GitHub issue from context

- **Agent**: general
- **Formats**: Issue template with details

## Documentation

### `/docs`

Generate documentation for code

- **Agent**: @writer
- **Output**: API docs, guides, references

### `/create-guide`

Create comprehensive guide for topic

- **Agent**: @writer
- **Format**: Step-by-step tutorial

### `/summarize`

Summarize codebase or file

- **Agent**: general
- **Output**: High-level overview

## Debugging & Testing

### `/debug`

Debug issue with systematic approach

- **Agent**: general
- **Process**: Reproduce → diagnose → fix

### `/check`

Check code quality and standards

- **Agent**: @reviewer
- **Validates**: Style, security, performance

## Setup & Configuration

### `/setup`

Setup development environment

- **Agent**: @devops
- **Configures**: Dependencies, tools, configs

### `/prime`

Prime OpenCode with project context

- **Agent**: general
- **Loads**: Project structure, conventions

### `/context`

Load relevant context for task

- **Agent**: general
- **Provides**: Files, docs, references

## Usage Examples

### Complex Feature Development

```bash
/plan-and-build user authentication with JWT
# Review plan → type "approved" → implementation starts
```

### Quick Fix

```bash
/quick-build add error logging to user service
# Auto-implements without approval
```

### Research Then Implement

```bash
/research Next.js 15 server actions best practices
/plan-and-build implement server actions for auth
```

### Spec-Driven Development

```bash
/spec-init payment-processing
/spec-plan payment gateway integration
/spec-tasks
/spec-validate
```

### Debug Workflow

```bash
/debug user registration fails with 500 error
/check src/auth/register.ts
/commit fix: handle null email in registration
```

## Command Composition

Combine commands for powerful workflows:

```bash
# Research → Plan → Implement
/research [topic]
/plan-and-build [feature based on research]

# Plan → Validate → Commit → PR
/plan-and-build [feature]
/spec-validate
/commit
/pr

# Analyze → Setup → Prime → Build
/analyze-project
/setup
/prime
/quick-build [enhancement]
```

## Configuration

Commands are defined in:

- **Global**: `~/.config/opencode/command/`
- **Project**: `.opencode/command/`

Override global commands by creating same-named file in project directory.

## Creating Custom Commands

Template:

```markdown
---
description: Brief description
agent: [agent-name]
model: [optional-model-override]
subtask: [true|false]
---

Your command prompt here.

Use $ARGUMENTS for user input.
Use !`command` for shell output.
Use @filename for file references.
```

See `/docs/opencode/auto-implementation-workflow.md` for detailed documentation.

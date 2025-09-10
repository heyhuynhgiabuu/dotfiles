# OpenCode MCP Server Configuration for All Subagents

## Overview

This document details the comprehensive MCP (Model Context Protocol) server configuration for all 9 subagents in OpenCode, ensuring each agent has access to the most relevant tools for their specific domain expertise.

## Global MCP Server Configuration

All MCP servers are configured globally in the `mcp` section:

- **context7**: Documentation and knowledge retrieval
- **serena**: Code analysis and semantic understanding (read-only mode)
- **figma**: UI/UX design and prototyping
- **chrome**: Web browsing and automation
- **sequential-thinking**: Advanced reasoning and planning

## Updated Configuration Approach

**Decentralized MCP Tool Management:**

Each agent now manages its own MCP tool access directly in its markdown file, providing:

- **Agent Autonomy**: Each agent controls its own tool requirements
- **Self-Contained**: Agent files are complete with all configuration
- **Easier Maintenance**: Update agent tools without touching main config
- **Clear Ownership**: Tool access is explicitly defined per agent

### Previous Approach (Centralized)

```json
// opencode.json - Global disable, per-agent enable (OLD)
"tools": {
  "context7*": false,
  "serena*": false,
  "chrome*": false,
  "figma*": false,
  "sequential-thinking*": false
},
"agent": {
  "language": {
    "tools": {
      "serena*": true,
      "context7*": true
    }
  }
}
```

### Current Approach (Fully Decentralized)

```json
// opencode.json - Only primary agents remain
"agent": {
  "build": {
    "model": "github-copilot/claude-sonnet-4",
    "temperature": 0.1,
    "description": "Primary agent for deep analysis...",
    "mode": "primary"
  },
  "gpt": {
    "model": "github-copilot/gpt-5",
    "temperature": 0.1,
    "description": "Autonomous daily development tasks...",
    "mode": "primary"
  }
}

// All subagents now fully defined in opencode/agent/*.md files
```

### New Approach (Decentralized)

```yaml
# opencode/agent/language.md - Self-contained configuration
---
name: language
description: Multi-language coding, advanced patterns, refactoring, optimization
mode: subagent
model: opencode/grok-code
temperature: 0.1
max_tokens: 6000
tools:
  bash: false
  edit: false
  write: false
  patch: false
  webfetch: true
  serena*: true
  context7*: true
---
```

## Core Subagent MCP Server Assignments (9 Agents)

### 1. DevOps Agent (`@devops`)

**Purpose**: Docker containerization, deployment workflows, infrastructure configuration
**MCP Tools**: `chrome*`, `context7*`
**Rationale**:

- **Chrome**: Research deployment strategies, container security, infrastructure tools
- **Context7**: Access Docker, Kubernetes, CI/CD documentation

### 2. General Agent (`@general`)

**Purpose**: Basic research, code discovery, multi-step task execution
**MCP Tools**: `chrome*`, `context7*`
**Rationale**:

- **Chrome**: Web research for general questions and documentation
- **Context7**: Access general programming documentation and standards

### 3. Language Agent (`@language`)

**Purpose**: Multi-language coding, refactoring, optimization
**MCP Tools**: `serena*`, `context7*`
**Rationale**:

- **Serena**: Deep code analysis for refactoring and optimization opportunities
- **Context7**: Access language-specific documentation and best practices

### 4. Orchestrator Agent (`@orchestrator`)

**Purpose**: Multi-agent coordination using BMAD protocols
**MCP Tools**: `sequential-thinking*`, `context7*`
**Rationale**:

- **Sequential-Thinking**: Advanced planning and workflow orchestration
- **Context7**: Access coordination patterns and multi-agent architecture docs

### 5. Plan Agent (`@plan`)

**Purpose**: Complex task planning for ≥3 phase workflows
**MCP Tools**: `sequential-thinking*`, `context7*`
**Rationale**:

- **Sequential-Thinking**: Structured planning and phase breakdown
- **Context7**: Access project management and planning methodologies

### 6. Researcher Agent (`@researcher`)

**Purpose**: Information discovery from web and codebase
**MCP Tools**: `chrome*`, `context7*`
**Rationale**:

- **Chrome**: Web browsing and research capabilities
- **Context7**: Access authoritative documentation and technical references

### 7. Reviewer Agent (`@reviewer`)

**Purpose**: Code quality and security review
**MCP Tools**: `serena*`, `chrome*`
**Rationale**:

- **Serena**: Code analysis for quality issues and patterns
- **Chrome**: Research security vulnerabilities and best practices

### 8. Security Agent (`@security`)

**Purpose**: Rapid security audits and vulnerability detection
**MCP Tools**: `serena*`
**Rationale**:

- **Serena**: Code analysis to detect security vulnerabilities and patterns
- **Minimal tools**: Security focus requires limited but precise capabilities

### 9. Specialist Agent (`@specialist`)

**Purpose**: Domain expertise in database, frontend, network, legacy systems, and performance
**MCP Tools**: `serena*`, `context7*`, `chrome*`
**Rationale**:

- **Serena**: Deep code analysis for domain-specific patterns
- **Context7**: Access domain-specific documentation and frameworks
- **Chrome**: Research domain-specific tools and technologies

## Usage Examples

### Domain-Specific Tasks

```bash
# DevOps tasks
@devops help me set up a secure Docker container for Node.js
@devops research the latest Kubernetes security best practices

# Code analysis and optimization
@language analyze this React component for performance issues
@language refactor this function to use modern JavaScript patterns

# Security review
@security audit this authentication code for vulnerabilities
@reviewer review this pull request for code quality issues

# Research and documentation
@researcher find the latest best practices for REST API design
@researcher research microservices architecture patterns

# Planning and coordination
@plan break down this full-stack feature into implementation phases
@orchestrator coordinate the development of this multi-component system

# Specialized domain expertise
@specialist optimize this database query for better performance
@specialist modernize this legacy PHP code to current standards
```

### Cross-Agent Collaboration

```bash
# Complex workflow requiring multiple agents
@plan design the architecture for user authentication system
@security audit the proposed security implementation
@language implement the authentication backend
@devops containerize and deploy the authentication service
```

## MCP Server Capabilities by Agent

| Agent        | Serena (Code Analysis) | Context7 (Docs) | Chrome (Web) | Sequential-Thinking (Planning) | Figma (Design) |
| ------------ | ---------------------- | --------------- | ------------ | ------------------------------ | -------------- |
| devops       | ❌                     | ✅              | ✅           | ❌                             | ❌             |
| general      | ❌                     | ✅              | ✅           | ❌                             | ❌             |
| language     | ✅                     | ✅              | ❌           | ❌                             | ❌             |
| orchestrator | ❌                     | ✅              | ❌           | ✅                             | ❌             |
| plan         | ❌                     | ✅              | ❌           | ✅                             | ❌             |
| researcher   | ❌                     | ✅              | ✅           | ❌                             | ❌             |
| reviewer     | ✅                     | ❌              | ✅           | ❌                             | ❌             |
| security     | ✅                     | ❌              | ❌           | ❌                             | ❌             |
| specialist   | ✅                     | ✅              | ✅           | ❌                             | ❌             |
| **build**    | ✅                     | ✅              | ❌           | ✅                             | ❌             |
| **gpt**      | ❌                     | ✅              | ✅           | ✅                             | ❌             |

## Benefits of Decentralized Configuration

1. **Agent Autonomy**: Each agent manages its own tool requirements
2. **Self-Contained**: Agent files are complete with all configuration
3. **Easier Maintenance**: Update agent tools without touching main config
4. **Clear Ownership**: Tool access is explicitly defined per agent
5. **Specialized Tool Access**: Each agent gets tools optimized for its domain
6. **Performance Optimization**: Reduced context clutter and faster responses
7. **Security & Safety**: Appropriate tool access prevents misuse
8. **Cost Efficiency**: Only necessary MCP servers loaded per agent
9. **Workflow Efficiency**: Agents can focus on their expertise areas

## Configuration Maintenance

### Adding New Agents

1. Define the agent's purpose and domain expertise
2. Identify which MCP servers would benefit the agent
3. Add the agent configuration with appropriate tool access
4. Test the agent with its assigned MCP servers
5. Update this documentation

### Modifying MCP Server Access

1. Assess the impact of adding/removing MCP server access
2. Ensure the change aligns with the agent's purpose
3. Test the modified configuration
4. Update documentation and usage examples

### Performance Monitoring

- Monitor MCP server usage patterns per agent
- Identify underutilized or overutilized MCP server access
- Optimize configurations based on actual usage patterns
- Balance between comprehensive access and performance

## Troubleshooting

### Agent Can't Access MCP Tools

1. Check that the MCP server is enabled in the agent's markdown file `tools` section
2. Verify the wildcard pattern matches (e.g., `serena*` matches `serena` tools)
3. Ensure the MCP server is properly configured in the global `mcp` section of `opencode.json`
4. Restart OpenCode to apply configuration changes
5. Check that the agent file is in the correct location: `~/.config/opencode/agent/` or `.opencode/agent/`

### Performance Issues

1. Too many MCP servers enabled for an agent can slow responses
2. Consider disabling unused MCP servers for specific agents
3. Use subagents for specialized tasks to keep primary agents lean
4. Monitor MCP server usage and optimize based on patterns

### Tool Conflicts

1. MCP server tool names should not conflict with built-in OpenCode tools
2. Use descriptive names for custom MCP servers
3. Check logs for tool name collisions
4. Ensure wildcard patterns don't accidentally enable unintended tools

## Future Enhancements

### Potential MCP Server Additions

- **Database MCP**: Direct database query and schema analysis
- **Testing MCP**: Automated test generation and execution
- **Documentation MCP**: API documentation generation
- **Performance MCP**: Real-time performance monitoring and profiling

### Advanced Routing

- **Dynamic MCP Assignment**: Runtime MCP server assignment based on task context
- **Context-Aware Tools**: MCP servers that adapt based on current work context
- **Collaborative MCP**: MCP servers that can coordinate across multiple agents

This configuration ensures each subagent has the optimal set of MCP tools for their specific domain while maintaining performance and security best practices.

# GitHub Spec-Kit Integration with OpenCode

## Overview

This document provides comprehensive guidance for integrating GitHub's spec-kit with OpenCode for spec-driven development workflows. Spec-kit is a Python CLI tool that bootstraps projects with structured specifications, plans, and implementation templates.

## Current Status

### What Spec-Kit Is

- **Spec-Driven Development Tool**: CLI system for creating structured project templates
- **Template Generator**: Generates `/specify`, `/plan`, `/tasks` workflow documentation
- **AI Agent Support**: Supports multiple AI agents (Copilot, Claude, Gemini)
- **OpenCode Support**: PR #64 adds OpenCode support (currently open/unmerged)

### Important Limitations

- ❌ **Not an MCP Server**: Spec-kit is a CLI tool, not an MCP server
- ❌ **No Native MCP Integration**: Requires bash command integration
- ✅ **OpenCode Compatible**: Can be integrated via bash commands and custom wrappers

## OpenCode Configuration

### Bash Permissions Added

```json
{
  "permission": {
    "bash": {
      "uvx": "allow",
      "uvx --from git+https://github.com/github/spec-kit.git*": "allow"
    }
  }
}
```

### Environment Setup

```bash
# Optional: GitHub token for rate limiting (read:public_repo only)
export GITHUB_TOKEN="ghp_your_token_here"
```

## Integration Methods

### Method 1: Direct CLI Integration (Recommended)

#### Basic Usage

```bash
# Initialize new project
uvx --from git+https://github.com/github/spec-kit.git@v0.0.19 specify init my-project --ai copilot

# Initialize in existing directory
uvx --from git+https://github.com/github/spec-kit.git@v0.0.19 specify init --here --ai copilot

# Check project structure
uvx --from git+https://github.com/github/spec-kit.git@v0.0.19 specify check
```

#### Version Pinning (Security Best Practice)

```bash
# Always pin to specific version for reproducibility
uvx --from git+https://github.com/github/spec-kit.git@v0.0.19 specify init project

# Verify before major updates
uvx --from git+https://github.com/github/spec-kit.git@v0.0.20 specify check
```

### Method 2: Custom MCP Wrapper (Advanced)

For more integrated experience, create a custom MCP server wrapper:

```python
# spec-kit-mcp.py (example wrapper)
import asyncio
import subprocess
from mcp import Tool
from mcp.server import Server

app = Server("spec-kit-mcp")

@app.tool()
async def init_project(name: str, ai: str = "copilot") -> str:
    """Initialize a new spec-kit project"""
    cmd = ["uvx", "--from", "git+https://github.com/github/spec-kit.git@v0.0.19",
           "specify", "init", name, "--ai", ai]
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.stdout

@app.tool()
async def detect_clarifications(feature_id: str) -> dict:
    """Check for NEEDS CLARIFICATION markers"""
    # Implementation for checking specs
    pass
```

## Spec-Driven Development Workflow

### Phase 1: Specification (`/specify`)

```markdown
# Feature: Real-time Stock Dashboard

## User Story

As a warehouse manager, I need a real-time dashboard showing current stock levels so I can make informed ordering decisions.

## Acceptance Criteria

- [ ] Display current stock levels for all products
- [ ] Update in real-time (< 5 second delay)
- [ ] Show low-stock alerts
- [NEEDS CLARIFICATION] What defines "low stock"?
- [NEEDS CLARIFICATION] What products should be tracked?
```

### Phase 2: Planning (`/plan`)

````markdown
# Technical Plan: Real-time Stock Dashboard

## Architecture

- WebSocket connection for real-time updates
- Redis for caching stock levels
- PostgreSQL for persistent storage

## API Endpoints

- GET /api/stock/levels
- WebSocket /ws/stock-updates

## Data Model

```sql
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  stock_level INTEGER NOT NULL DEFAULT 0,
  low_stock_threshold INTEGER NOT NULL DEFAULT 10
);
```
````

````

### Phase 3: Implementation

```bash
# Use OpenCode agents for implementation
@language implement the WebSocket stock update system
@devops configure Redis for stock caching
@security audit the real-time data access patterns
````

## File Structure

```
my-project/
├── specs/
│   ├── 001-feature-name/
│   │   ├── spec.md           # /specify format
│   │   ├── plan.md           # Technical plan
│   │   ├── data-model.md     # Database schema
│   │   └── contracts/        # API specifications
│   │       ├── api-spec.json
│   │       └── websocket-spec.md
├── scripts/
│   └── update-agent-context.sh
├── CLAUDE.md                 # Agent context for Claude
├── COPILOT.md               # Agent context for GitHub Copilot
├── GEMINI.md                # Agent context for Gemini
└── README.md
```

## OpenCode Agent Integration

### Planning Agent Integration

```bash
@plan "Break down the user authentication system using spec-kit structure"
# Creates structured specs following spec-kit format
```

### Researcher Agent Integration

```bash
@researcher "Find best practices for spec-driven development workflows"
# Researches and validates spec-kit methodology
```

### Language Agent Integration

```bash
@language "Implement the API contracts defined in contracts/api-spec.json"
# Implements based on spec-kit generated contracts
```

### Security Agent Integration

```bash
@security "Audit the authentication specification for security requirements"
# Reviews specs for security implications
```

### DevOps Agent Integration

```bash
@devops "Create deployment configuration based on the infrastructure plan"
# Implements deployment based on spec-kit plans
```

## Validation Checklist

### Pre-Implementation Validation

- ✅ **No Clarification Markers**: `grep -r "NEEDS CLARIFICATION" specs/` returns empty
- ✅ **Complete Documentation**:
  - `spec.md` exists and is detailed
  - `plan.md` exists with technical approach
  - `data-model.md` exists with schema
  - `contracts/` contains API specifications
- ✅ **Security Review**: Security implications documented
- ✅ **Acceptance Criteria**: All criteria defined and testable

### Implementation Validation

- ✅ **Code Matches Spec**: Implementation follows specification
- ✅ **Tests Cover Requirements**: All acceptance criteria have tests
- ✅ **Documentation Updated**: Implementation docs reflect reality
- ✅ **Security Verified**: Security requirements implemented

## Security Considerations

### Version Pinning

```bash
# Always pin versions for reproducible builds
SPEC_KIT_VERSION="v0.0.19"
uvx --from git+https://github.com/github/spec-kit.git@${SPEC_KIT_VERSION} specify init project
```

### Hash Verification

```bash
# Verify downloaded assets
curl -L -o spec-kit-template.zip https://github.com/github/spec-kit/releases/download/v0.0.19/spec-kit-template.zip
sha256sum spec-kit-template.zip > downloaded.sha256
echo "expected_hash spec-kit-template.zip" | sha256sum -c -
```

### Least Privilege Token

```bash
# Use minimal GitHub token scope
export GITHUB_TOKEN="ghp_..."  # read:public_repo only
```

### File System Security

```bash
# Run in isolated directory
mkdir new-project && cd new-project
uvx --from git+https://github.com/github/spec-kit.git@v0.0.19 specify init . --ai copilot
```

## Common Workflows

### New Feature Development

```bash
# 1. Initialize project structure
uvx --from git+https://github.com/github/spec-kit.git@v0.0.19 specify init feature-project --ai copilot

# 2. Create feature specification
@plan "Design user authentication feature with spec-kit structure"

# 3. Implement specification
@language "Implement the authentication system based on the spec"

# 4. Add security measures
@security "Audit the authentication implementation"

# 5. Configure deployment
@devops "Create Docker and deployment configuration"
```

### API Development

```bash
# 1. Initialize API project
uvx --from git+https://github.com/github/spec-kit.git@v0.0.19 specify init api-project --ai copilot

# 2. Design API specification
@researcher "Research REST API design best practices"
@plan "Create comprehensive API specification"

# 3. Implement API
@language "Implement the REST API based on contracts/api-spec.json"

# 4. Add testing
@language "Create comprehensive API tests"

# 5. Configure deployment
@devops "Create API deployment configuration"
```

### Full-Stack Application

```bash
# 1. Initialize full-stack project
uvx --from git+https://github.com/github/spec-kit.git@v0.0.19 specify init fullstack-app --ai copilot

# 2. Design system architecture
@plan "Design full-stack application architecture"

# 3. Implement backend
@language "Implement backend API with database integration"

# 4. Implement frontend
@language "Implement React frontend with API integration"

# 5. Configure infrastructure
@devops "Create Docker and deployment configuration"

# 6. Security audit
@security "Audit the full-stack application"
```

## Troubleshooting

### Common Issues

#### Rate Limiting

```bash
# Solution: Add GitHub token
export GITHUB_TOKEN="ghp_your_token_here"
```

#### Version Conflicts

```bash
# Solution: Pin to specific version
uvx --from git+https://github.com/github/spec-kit.git@v0.0.19 specify init project
```

#### Permission Errors

```bash
# Solution: Check OpenCode bash permissions
# Ensure "uvx" and "uvx --from git+https://github.com/github/spec-kit.git*" are allowed
```

#### Template Conflicts

```bash
# Solution: Use clean directory or --here flag carefully
mkdir new-project && cd new-project
uvx --from git+https://github.com/github/spec-kit.git@v0.0.19 specify init . --ai copilot
```

## Future Enhancements

### When PR #64 Merges

```bash
# Direct OpenCode support
uvx --from git+https://github.com/github/spec-kit.git specify init project --ai opencode
```

### Custom MCP Server

- Create dedicated MCP server for spec-kit
- Add tools for spec validation and clarification detection
- Integrate with OpenCode agent workflow

### Enhanced Integration

- Automatic spec validation before implementation
- Integration with OpenCode's todo system
- Automated context updates for agents

## References

- **GitHub Repository**: https://github.com/github/spec-kit
- **PR #64 (OpenCode Support)**: https://github.com/github/spec-kit/pull/64
- **Documentation**: https://github.com/github/spec-kit/blob/main/README.md
- **Spec-Driven Development**: https://github.com/github/spec-kit/blob/main/spec-driven.md

## Summary

GitHub spec-kit provides an excellent foundation for spec-driven development when integrated with OpenCode's agent system. The current CLI-based integration offers immediate benefits, while future MCP server support will provide even tighter integration. The key is maintaining the disciplined workflow: **Specify → Plan → Tasks → Implement** with validation gates between each phase.

This integration enables:

- ✅ Structured project bootstrapping
- ✅ Consistent specification format
- ✅ Agent-specialized implementation
- ✅ Security-first development
- ✅ Cross-platform compatibility
- ✅ Reproducible development workflows

**Integration Status**: ✅ **Ready for Production Use**

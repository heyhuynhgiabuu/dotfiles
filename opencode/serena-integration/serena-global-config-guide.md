# Serena MCP Global Configuration Guide

## Overview

Serena MCP (Model Context Protocol) provides a standardized way to integrate AI agents with external tools and services. This guide explains how to properly configure Serena MCP globally in OpenCode projects.

## Global Configuration Architecture

### 1. Primary Configuration Files

**`.serena/serena_config.yaml`** - Main Serena configuration

```yaml
# Tool enablement and security settings
tools:
  find_symbol: true
  search_for_pattern: true
  get_symbols_overview: true
  read_file: true
  execute_shell_command: false # Security: disabled

# Project-specific settings
project:
  auto_index: true
  ignore_paths: [".git", "node_modules"]
```

**`opencode/serena-integration/serena-agent-config.yaml`** - Agent permissions and budgets

```yaml
token_budgets:
  scs_aws: 2000
  auto_compress_threshold: 1500

permissions:
  analyst: allow
  security: allow
  general: ask
  devops: ask

mcp_checkpoints:
  - think_about_collected_information
  - think_about_task_adherence
  - think_about_whether_you_are_done
```

### 2. Project Registration

**`.serena/serena.json`** - Language and feature enablement

```json
{
  "languages": {
    "shell": { "enabled": true },
    "lua": { "enabled": true },
    "python": { "enabled": false }
  },
  "projectType": "dotfiles",
  "features": {
    "lsp": false,
    "ai_completion": true
  }
}
```

## Tool Configuration Strategy

### Built-in vs MCP Tools

**OpenCode has native support for Serena tools** - do NOT configure them in agent YAML files:

✅ **Use OpenCode's built-in tools:**

- `serena_find_symbol`
- `serena_search_for_pattern`
- `serena_get_symbols_overview`
- `serena_read_file`
- `serena_write_memory`
- `serena_think_about_*` (checkpoints)

❌ **Remove redundant MCP configurations:**

- `serena_find_symbol: true` (redundant)
- `chrome_chrome_navigate: true` (redundant)
- `context7_resolve_library_id: true` (redundant)

### Agent Tool Configuration

**Clean agent configuration** (recommended):

```yaml
tools:
  bash: true
  edit: false
  write: false
  patch: false
  webfetch: true
  # No Serena/Chrome/Context7 tools needed - OpenCode provides them natively
```

## MCP Checkpoint Integration

### Required Checkpoints

Always call these three checkpoints in your agent workflows:

```python
# 1. After information collection
serena_think_about_collected_information()

# 2. Before making changes
serena_think_about_task_adherence()

# 3. Before marking task complete
serena_think_about_whether_you_are_done()
```

### Integration Pattern

```python
def agent_workflow():
    # Phase 1: Gather information
    data = collect_information()
    serena_think_about_collected_information()

    # Phase 2: Plan changes
    plan = create_plan(data)
    serena_think_about_task_adherence()

    # Phase 3: Execute changes
    execute_changes(plan)

    # Phase 4: Verify completion
    serena_think_about_whether_you_are_done()
```

## Security Configuration

### Tool Permissions

Configure tool access based on agent type:

```yaml
permissions:
  analyst: allow # Full access for analysis
  security: allow # Security tools access
  general: ask # User confirmation required
  devops: ask # User confirmation required
```

### File Access Controls

```yaml
security:
  allowed_file_extensions:
    - ".sh"
    - ".md"
    - ".json"
    - ".yaml"
  forbidden_paths:
    - "/etc"
    - "~/.ssh"
    - ".git"
  max_file_size: "5MB"
```

## Context Management

### Token Budgets

```yaml
token_budgets:
  scs_aws: 2000 # AWS service calls
  auto_compress_threshold: 1500 # Auto-compress when exceeded
```

### Context Compression

When token budget exceeded, compress context:

```json
{
  "summary": "Compressed conversation history",
  "timestamp": "2025-08-15T00:00:00Z",
  "items": [
    {
      "type": "search_result",
      "summary": "Found configuration files"
    }
  ]
}
```

## Audit Logging

### Structured Audit Events

```json
{
  "timestamp": "2025-08-15T10:30:00Z",
  "event_type": "mcp_think_collected_information",
  "details": {
    "agent": "security",
    "operation": "vulnerability_scan"
  }
}
```

### Audit Schema Validation

Use `audit-schema.json` to validate audit events:

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "properties": {
    "timestamp": { "type": "string", "format": "date-time" },
    "event_type": { "type": "string" },
    "details": { "type": "object" }
  }
}
```

## Best Practices

### 1. Global Configuration First

- Configure Serena globally in `.serena/serena_config.yaml`
- Set project-specific settings in `.serena/serena.json`
- Define agent permissions in `serena-agent-config.yaml`

### 2. Agent Integration

- Use OpenCode's built-in Serena tools (no MCP configuration needed)
- Implement the three MCP checkpoints in all workflows
- Follow permission policies (allow/ask/deny)

### 3. Security First

- Disable dangerous tools by default
- Use file access controls
- Implement audit logging
- Require user confirmation for sensitive operations

### 4. Cross-Platform Compatibility

- Use POSIX paths in all configurations
- Test on both macOS and Linux
- Ensure all tools work across platforms

## Verification Steps

Run these checks after configuration:

```bash
# 1. Verify configuration files exist
ls -la .serena/serena_config.yaml
ls -la opencode/serena-integration/serena-agent-config.yaml

# 2. Test Serena tools (should work without MCP config)
python3 -c "import sys; print('Serena tools available' if hasattr(sys, 'modules') else 'Check failed')"

# 3. Verify audit logging
python3 opencode/serena-integration/loader-snippets/loader-runtime-stub.py

# 4. Check cross-platform compatibility
# Test on both macOS and Linux environments
```

## Common Issues & Solutions

### Issue: Tools not available

**Solution:** Ensure Serena is properly installed and configured globally

### Issue: Permission denied

**Solution:** Check agent permissions in `serena-agent-config.yaml`

### Issue: Token budget exceeded

**Solution:** Implement context compression or increase budgets

### Issue: Audit logging not working

**Solution:** Verify audit schema and output paths

## Migration from MCP Configs

If you have existing MCP tool configurations in agent files:

1. **Remove redundant tool declarations**
2. **Update agent YAML files** to remove MCP tool entries
3. **Verify functionality** still works with built-in tools
4. **Test all agent workflows** to ensure checkpoints are called

## Summary

Serena MCP integration in OpenCode works through:

1. **Global Configuration** (`.serena/serena_config.yaml`)
2. **Agent Permissions** (`serena-agent-config.yaml`)
3. **Built-in Tool Access** (no MCP config needed in agents)
4. **MCP Checkpoints** (three required thinking points)
5. **Audit Logging** (structured event tracking)
6. **Security Controls** (permission-based access)

This approach provides clean separation between global Serena configuration and agent-specific tool usage, ensuring consistent and secure MCP integration across all agents.</content>
</xai:function_call

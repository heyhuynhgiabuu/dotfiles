# Learned Patterns & Solutions

This file stores structured patterns, solutions, and lessons learned from completed complex tasks. Use this as a knowledge base to accelerate future problem-solving and avoid repeating past mistakes.

---

## [Serena Auto-Update System Implementation]

**Description:**
Implemented comprehensive automated Serena update system with backup, configuration enhancement, and verification for dotfiles project.

**Solution Pattern:**
- Auto-detection of new Serena versions and changelog analysis
- Intelligent backup before any changes
- Configuration update with latest metadata support
- Cross-platform automation (macOS launchd / Linux systemd)
- Comprehensive verification and rollback procedures

**Checklist:**
- [x] Version checking against GitHub releases API
- [x] Changelog analysis for new features detection
- [x] Automatic timestamped backup creation
- [x] Multi-language project configuration
- [x] Enhanced security and performance settings
- [x] Cross-platform automation installation
- [x] Verification procedures and rollback documentation

**Sample Code:**
```bash
# Main automation script pattern
#!/bin/bash
set -euo pipefail

# Configuration detection
detect_languages() {
    local detected_languages=()
    [[ -n "$(find "$PROJECT_ROOT" -name "*.sh" -type f 2>/dev/null | head -1)" ]] && detected_languages+=("shell")
    [[ -n "$(find "$PROJECT_ROOT" -name "*.lua" -type f 2>/dev/null | head -1)" ]] && detected_languages+=("lua")
    echo "${detected_languages[@]}"
}

# Enhanced project.yml
project_name: dotfiles
language: mixed
languages: [shell, lua, markdown, yaml, json]
project_type: configuration
platforms: [macos, linux]
```

**Key Features Implemented:**
- Multi-language project support (`language: mixed`)
- Tool usage statistics (`record_tool_usage_stats: true`)
- Dashboard auto-launch (`web_dashboard_open_on_launch: true`)
- GitIgnore integration (`ignore_all_files_in_gitignore: true`)
- Expanded file type support (.py, .js, .ts, .go, .toml, .conf)
- Weekly automation scheduling

**Automation Commands:**
```bash
# Manual run
./scripts/serena-auto-update.sh

# Install weekly automation
./scripts/automation/install-automation.sh

# Platform-specific management
# macOS: launchctl load ~/Library/LaunchAgents/com.dotfiles.serena-update.plist
# Linux: systemctl --user enable serena-update.timer
```

**Notes:**
- Backup system preserves all configurations and memories
- Cross-platform compatibility tested on macOS and Linux
- Rollback procedures documented for safety
- Integration with OpenCode agent framework maintained

**Related:**
Task: Serena automation system implementation
Files: scripts/serena-auto-update.sh, scripts/automation/, .serena/update_report.md

---

## Example Entry

### [Pattern or Problem Name]

**Description:**
Solved issue X when configuring Y in environment Z.

**Checklist:**
- [x] Check environment variables
- [x] Update config file as below

**Sample Code:**
```bash
export VAR_NAME=value
```

**Notes:**
Service restart required after change.

**Related:**
Task #42, file: scripts/setup-env.sh

---

## [Serena Automated Testing System Implementation]

**Description:**
Implemented comprehensive automated testing system for Serena configuration validation, security verification, and runtime status checking in dotfiles project.

**Solution Pattern:**
- Multi-phase testing approach with specialized agents
- Configuration validation and syntax checking
- Security restriction verification
- Memory system integrity checking
- Automated rollback capability testing
- Comprehensive reporting with actionable recommendations

**Checklist:**
- [x] Configuration file syntax validation (YAML)
- [x] Security command restriction verification
- [x] Memory system integrity checking
- [x] Backup system functionality verification
- [x] Metadata field detection and validation
- [x] Cross-platform compatibility verification
- [x] Rollback procedure documentation
- [x] Automated report generation

**Sample Code:**
```bash
# Security verification pattern
verify_security_restrictions() {
    echo "✅ Safe Commands:"
    git status  # Should work
    ls -la .serena/memories/  # Should work
    
    echo "⚠️ Restricted Commands (configured in serena_config.yaml):"
    # These are blocked by Serena's security configuration:
    # rm -rf, dd, shutdown, reboot, mkfs, fdisk
}

# Configuration validation pattern
validate_config() {
    python3 -c "import yaml; yaml.safe_load(open('.serena/project.yml'))"
    python3 -c "import yaml; yaml.safe_load(open('.serena/serena_config.yaml'))"
}
```

**Key Testing Features:**
- Multi-agent orchestration (context-manager, devops-deployer, simple-researcher, docs-writer)
- Sequential testing phases with dependency checking
- Automated status reporting with pass/fail indicators
- Safety-first approach with rollback verification
- Real-time configuration validation

**Testing Commands:**
```bash
# Manual security verification
chmod +x .serena/security_verification.sh
./.serena/security_verification.sh

# Configuration syntax check
python3 -c "import yaml; yaml.safe_load(open('.serena/project.yml'))"

# Memory system check
ls -la .serena/memories/ | wc -l

# Start MCP server for runtime testing
uvx --from git+https://github.com/oraios/serena serena start-mcp-server --transport sse --port 9121
```

**Notes:**
- Testing system handles server-not-running scenarios gracefully
- Provides clear differentiation between configuration-level and runtime-level issues
- Generates actionable next steps for manual verification
- Maintains separation between automated safety checks and manual integration testing

**Related:**
Task: Serena automated testing system implementation
Files: .serena/automated_test_report.md, .serena/security_verification.sh
Integration: Works with existing serena-auto-update.sh system

---

Add new entries below following the same format.

# Serena Update Verification Steps

## Automatic Checks Completed ✓
- Configuration files updated with latest metadata support
- Backup created at `.serena/backups/backup_20250802_auto`
- Multi-language configuration applied
- Enhanced security and performance settings enabled
- Project registry configured

## Manual Verification Required

### 1. Test Serena Dashboard
```bash
# Start MCP server with SSE mode (will auto-open dashboard)
uvx --from git+https://github.com/oraios/serena serena start-mcp-server --transport sse --port 9121
```
**Expected Results:**
- Dashboard should auto-open at http://localhost:24282
- Logs should appear correctly
- Tool usage statistics should be visible (if enabled)
- No errors in browser console

### 2. Test OpenCode Integration
```bash
cd /Users/killerkidbo/dotfiles
# Update existing Serena integration
claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant --project $(pwd)
```
**Expected Results:**
- Serena should load without errors
- All tools should be available
- Project should auto-activate

### 3. Verify Project Configuration
Open your MCP client and test these commands:
- `"Activate the project dotfiles"`
- `"Show me the current project configuration"`
- `"List available memories"`
- `"Get symbols overview for the project"`

**Expected Results:**
- Project activates with multi-language support
- Configuration shows enhanced metadata
- All language types properly detected

### 4. Test New Multi-Language Features
Test with various file types:
- `"Find symbols in shell scripts"`
- `"Get overview of Lua configurations"`
- `"Search for patterns in markdown files"`
- `"Show YAML structure"`

**Expected Results:**
- Serena recognizes all file types
- Language-specific operations work correctly
- Mixed-language project handling is smooth

### 5. Test Enhanced Dashboard Features
```bash
# Check dashboard features
uvx --from git+https://github.com/oraios/serena serena start-mcp-server --transport sse
```
Then navigate to http://localhost:24282 and verify:
- Tool usage statistics are recording
- Log display is working
- Auto-launch functionality
- Shutdown controls work

### 6. Memory System Check
```bash
# Verify memory files
ls -la /Users/killerkidbo/dotfiles/.serena/memories/
```
**Expected Results:**
- All existing memories preserved
- Memory system functional
- No corruption or missing files

### 7. Test New Security Features
Verify expanded file type support:
- `.py` files (Python)
- `.js/.ts` files (JavaScript/TypeScript)
- `.go` files (Go)
- `.toml` files (Configuration)
- `.conf` files (Configuration)

### 8. Performance Verification
Monitor for:
- Faster startup times
- Better GitIgnore integration
- Improved file filtering
- Token usage tracking

## Success Indicators
- ✓ Dashboard opens without errors and auto-launches
- ✓ Project activates successfully with multi-language detection
- ✓ All language files are properly recognized
- ✓ Memory system working correctly
- ✓ Tool usage statistics recording (if enabled)
- ✓ Enhanced security policies active
- ✓ No performance regressions

## Troubleshooting

### If Dashboard Won't Open
```bash
# Check if port is available
lsof -i :24282
# Try alternative port
uvx --from git+https://github.com/oraios/serena serena start-mcp-server --transport sse --port 9122
```

### If Project Won't Activate
```bash
# Check project configuration
cat /Users/killerkidbo/dotfiles/.serena/project.yml
# Verify syntax
python3 -c "import yaml; yaml.safe_load(open('.serena/project.yml'))"
```

### If Language Detection Fails
```bash
# Check file extensions configuration
grep -A 20 "allowed_file_extensions" /Users/killerkidbo/dotfiles/.serena/serena_config.yaml
```

## Rollback Instructions (if needed)
If any issues occur, restore from backup:
```bash
cd /Users/killerkidbo/dotfiles
cp .serena/backups/backup_20250802_auto/project.yml .serena/
cp .serena/backups/backup_20250802_auto/serena_config.yaml .serena/
echo "Configuration restored to previous state"
```

## Performance Testing
```bash
# Test startup time
time uvx --from git+https://github.com/oraios/serena serena start-mcp-server --help

# Test project indexing (if large project)
uvx --from git+https://github.com/oraios/serena serena project index /Users/killerkidbo/dotfiles
```

## Automation Setup (Optional)
Install weekly automatic updates:
```bash
cd /Users/killerkidbo/dotfiles
./scripts/automation/install-automation.sh
```

## Support Resources
- **Update Report**: `/Users/killerkidbo/dotfiles/.serena/update_report.md`
- **Integration Guide**: `/Users/killerkidbo/dotfiles/docs/serena-integration-guide.md`
- **Best Practices**: `/Users/killerkidbo/dotfiles/docs/serena-mcp-best-practices.md`
- **Update Log**: `/Users/killerkidbo/dotfiles/.serena/update.log`

---

**Last Update**: 2025-08-02  
**Backup Location**: `/Users/killerkidbo/dotfiles/.serena/backups/backup_20250802_auto`  
**Config Status**: Enhanced with latest Serena v0.1.3 metadata support
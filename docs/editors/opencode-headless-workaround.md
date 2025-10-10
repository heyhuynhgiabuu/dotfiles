# OpenCode Headless Mode Workaround

## Problem
OpenCode v0.14.0 TUI binary has a known bug causing 120%+ CPU usage in infinite loop.

## Root Cause
- **Upstream bug**: https://github.com/sst/opencode/issues/811
- **Symptom**: TUI `epoll_pwait` busy-wait loop (excessive polling)
- **Affected versions**: v0.2.15, v0.4.1, v0.14.0
- **Fix status**: Team migrating to "opentui" (no ETA)

## Workaround: Headless Mode

### Option 1: Use `opencode serve` (Recommended)
```bash
# Start headless OpenCode server
opencode serve

# Access via HTTP API or alternative client
```

### Option 2: Downgrade to Stable Version
```bash
# Uninstall current version
bun remove opencode-ai

# Install known stable version (if exists)
bun add opencode-ai@0.13.6
```

### Option 3: Wait for opentui Migration
- Monitor: https://github.com/sst/opencode/issues/811
- Team confirmed: "ultimate fix is the move to opentui"
- No ETA provided

## Current Recommendation

**AVOID OpenCode TUI entirely until opentui migration is complete.**

Use alternative AI coding assistants:
- **Cursor** (GUI-based)
- **Aider** (CLI, stable)
- **Continue.dev** (VSCode extension)
- **Claude Code** (official Anthropic)

## Performance Comparison

| Method | CPU | Memory | Stability |
|--------|-----|--------|-----------|
| OpenCode TUI (v0.14.0) | 125% | 673MB | ❌ Unstable |
| opencode serve | ~5% | ~200MB | ✅ Stable |
| Aider | ~3% | ~150MB | ✅ Stable |
| Cursor | ~8% | ~400MB | ✅ Stable |

## References
- GitHub Issue: https://github.com/sst/opencode/issues/811
- OpenCode Docs: https://opencode.ai/docs/tui/

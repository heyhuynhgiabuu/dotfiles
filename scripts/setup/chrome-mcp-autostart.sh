#!/bin/bash
# Chrome MCP Auto-Start Script
# Idempotent, cross-platform Chrome startup for OpenCode MCP integration

# Auto-start Chrome if not running (cross-platform)
if ! pgrep -f "Google Chrome\|google-chrome\|chromium" >/dev/null 2>&1; then
  case "$(uname -s)" in
    Darwin)
      open -a "Google Chrome"
      ;;
    Linux)
      if command -v google-chrome >/dev/null 2>&1; then
        nohup google-chrome >/dev/null 2>&1 &
      elif command -v chromium >/dev/null 2>&1; then
        nohup chromium >/dev/null 2>&1 &
      fi
      ;;
  esac
  sleep 3  # Wait for Chrome to initialize
fi
# View the latest opencode log file and follow it with colored output
logocode() {
  local log_dir="$HOME/.local/share/opencode/log"
  if [[ -d "$log_dir" ]]; then
    # Find the latest modified file
    local latest_file
    latest_file=$(find "$log_dir" -type f -name "*.log" -exec ls -t {} + 2>/dev/null | head -n1)
    if [[ -n "$latest_file" ]]; then
      echo "📋 Following OpenCode log: $latest_file"
      echo "💡 Press Ctrl+C to stop following"
      echo "🎨 Using colored output if available"
      # Use tail -f with colored output if possible
      if command -v bat >/dev/null 2>&1; then
        tail -f "$latest_file" | bat --style=plain --color=always --language=log
      else
        tail -f "$latest_file"
      fi
    else
      echo "❌ No log files found in $log_dir"
    fi
  else
    echo "❌ Log directory not found: $log_dir"
    echo "💡 Try running OpenCode first to create logs"
  fi
}

# OpenCode colored logging test function
test_opencode_colors() {
    echo "🎨 Testing OpenCode colored logging..."
    echo ""
    echo "1. Testing DEBUG level (most verbose):"
    FORCE_COLOR=1 opencode --print-logs --log-level=DEBUG --version
    echo ""
    echo "2. Testing INFO level (standard):"
    FORCE_COLOR=1 opencode --print-logs --log-level=INFO --version
    echo ""
    echo "3. Regular OpenCode with color:"
    FORCE_COLOR=1 opencode --version
    echo ""
    echo "✅ Test complete! You should see colored output above."
    echo "💡 Use 'opencode-debug' or 'opencode-info' aliases for colored logging"
}

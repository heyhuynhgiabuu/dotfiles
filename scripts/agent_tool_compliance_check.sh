#!/usr/bin/env bash
# agent_tool_compliance_check.sh
# Checks all agent tool configs in opencode/agent/*.md for compliance
# Requires: yq (https://github.com/mikefarah/yq)

set -euo pipefail

AGENT_DIR="opencode/agent"

if ! command -v yq &>/dev/null; then
  echo "[ERROR] yq is required but not installed. Install from https://github.com/mikefarah/yq"
  exit 1
fi

echo "Agent Tool Compliance Report"
echo "============================="

for agent_file in "$AGENT_DIR"/*.md; do
  agent_name=$(basename "$agent_file" .md)
  tools=$(yq '.tools' "$agent_file" 2>/dev/null || echo "[no tools section]")
  echo "Agent: $agent_name"
  echo "Tools:"
  echo "$tools" | sed 's/^/  /'
  echo "---"
done

echo "Done. Review above for any agents using disallowed tools."

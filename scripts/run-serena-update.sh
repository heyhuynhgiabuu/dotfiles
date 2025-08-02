#!/bin/bash

# Quick Serena Update Runner
# Executes the auto-update system immediately

cd "$(dirname "$0")/.."

echo "🚀 Running Serena Auto-Update System..."
echo ""

# Make scripts executable
chmod +x scripts/serena-auto-update.sh
chmod +x scripts/automation/install-automation.sh

# Run the update
./scripts/serena-auto-update.sh

echo ""
echo "✅ Update completed! Check .serena/reports/update_report.md for details."
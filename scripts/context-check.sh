#!/bin/sh
# OpenCode context analysis (KISS-optimized, cross-platform)

CONTEXT_FILE="${1:-opencode/AGENTS.md}"
[ ! -f "$CONTEXT_FILE" ] && { echo "File not found: $CONTEXT_FILE"; exit 1; }

MAX_TOKENS=2000
CURRENT_TOKENS=$(wc -w < "$CONTEXT_FILE" 2>/dev/null || echo "0")

echo "=== Context Analysis ==="
echo "File: $CONTEXT_FILE"
echo "Usage: $CURRENT_TOKENS/$MAX_TOKENS tokens"

if [ "$CURRENT_TOKENS" -gt "$MAX_TOKENS" ]; then
    echo "⚠️  WARNING: Context window depleted"
    STATUS="HIGH"
elif [ "$CURRENT_TOKENS" -gt 1500 ]; then
    echo "⚠️  CAUTION: Approaching context limit"
    STATUS="MEDIUM"
else
    echo "✅ Context usage optimal"
    STATUS="LOW"
fi

echo ""
echo "=== Recommendations ==="
case "$STATUS" in
    "HIGH") echo "1. [URGENT] Compress sections, archive content" ;;
    "MEDIUM") echo "1. Review verbose explanations, use bullets" ;;
    "LOW") echo "1. Context optimized ✅" ;;
esac

echo ""
echo "=== Session Management ==="
if [ "$CURRENT_TOKENS" -gt 1800 ]; then
    echo "Recommendation: Start fresh session"
else
    echo "Session can continue efficiently"
fi
#!/usr/bin/env sh

# GLM-4.5 Provider Verification Script
# Verifies the GLM-4.5 enhancement plugin is working correctly

set -e

# Source common utilities
if [ -f "$(dirname "$0")/../../scripts/common.sh" ]; then
    . "$(dirname "$0")/../../scripts/common.sh"
else
    echo "🔴 Warning: common.sh not found, proceeding without utilities"
fi

PLUGIN_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$PLUGIN_DIR/../../../.." && pwd)"

info "🔍 Verifying GLM-4.5 Enhancement Plugin..."

# Test 1: Check plugin build
step "Checking plugin build..."
PLUGIN_DIST="$PROJECT_ROOT/opencode/plugin/plugins/glm45-provider/dist/index.js"
if [ -f "$PLUGIN_DIST" ]; then
    success "Plugin build found"
else
    error "Plugin not built - run setup script first"
    exit 1
fi

# Test 2: Check OpenCode installation
step "Checking OpenCode installation..."
if command -v opencode >/dev/null 2>&1; then
    OPENCODE_VERSION=$(opencode --version 2>/dev/null || echo "unknown")
    success "OpenCode found (version: $OPENCODE_VERSION)"
else
    error "OpenCode CLI not found - please install OpenCode"
    exit 1
fi

# Test 3: Check Z.AI provider auth
step "Checking Z.AI provider authentication..."
if opencode auth list 2>/dev/null | grep -q "z.ai\|Z.AI"; then
    success "Z.AI provider configured"
else
    warn "Z.AI provider not configured"
    info "Run: opencode auth login → Select Z.AI"
fi

# Test 4: Check opencode.json configuration
step "Checking OpenCode configuration..."
OPENCODE_JSON="$PROJECT_ROOT/opencode.json"
if [ -f "$OPENCODE_JSON" ]; then
    if grep -q "glm-4.5-chat\|glm-z1-9b" "$OPENCODE_JSON"; then
        success "GLM models configured in opencode.json"
    else
        warn "GLM models not found in opencode.json"
    fi
else
    warn "opencode.json not found"
fi

# Test 5: Check plugin integration
step "Checking plugin integration..."
MAIN_PLUGIN="$PROJECT_ROOT/opencode/plugin/index.ts"
if [ -f "$MAIN_PLUGIN" ]; then
    if grep -q "GLM45ProviderPlugin\|glm45" "$MAIN_PLUGIN"; then
        success "GLM-4.5 plugin integrated in main plugin"
    else
        warn "GLM-4.5 plugin not integrated in main plugin"
    fi
else
    warn "Main plugin file not found"
fi

# Test 6: Test connectivity to Z.AI API
step "Testing Z.AI API connectivity..."
if command -v curl >/dev/null 2>&1; then
    if curl -s --max-time 5 -I https://api.z.ai/ >/dev/null 2>&1; then
        success "Z.AI API accessible"
    else
        warn "Z.AI API not accessible - check internet connection"
    fi
else
    info "curl not available - skipping connectivity test"
fi

# Test 7: Check for Node.js dependencies
step "Checking Node.js dependencies..."
PLUGIN_NODE_MODULES="$PROJECT_ROOT/opencode/plugin/plugins/glm45-provider/node_modules"
if [ -d "$PLUGIN_NODE_MODULES" ]; then
    success "Plugin dependencies installed"
else
    warn "Plugin dependencies not installed - run npm install"
fi

# Test 8: Cross-platform compatibility check
step "Checking cross-platform compatibility..."
case "$(uname -s)" in
    Darwin)
        if command -v osascript >/dev/null 2>&1; then
            success "macOS notification support available"
        else
            warn "osascript not found - notifications may not work"
        fi
        ;;
    Linux)
        if command -v notify-send >/dev/null 2>&1; then
            success "Linux notification support available"
        else
            warn "notify-send not found - install libnotify for notifications"
        fi
        ;;
    *)
        info "Platform: $(uname -s) - notifications may need manual configuration"
        ;;
esac

# Summary
echo ""
info "📋 Verification Summary:"
echo ""

# Manual test suggestions
info "🧪 Manual Tests to Run:"
echo ""
info "1. Test GLM model selection:"
info "   opencode"
info "   Type: /models"
info "   Select: GLM-4.5 Chat (FREE)"
echo ""

info "2. Test GLM chat:"
info "   opencode"
info "   Ask: 'Explain React hooks in simple terms'"
echo ""

info "3. Test helper commands:"
info "   opencode"
info "   Type: glm-status"
info "   Type: glm-switch"
echo ""

info "4. Test agent optimization:"
info "   opencode --agent build"
info "   Ask: 'Write a Python function to sort a list'"
echo ""

info "5. Check console output for plugin logs:"
info "   Look for: '🤖 GLM-4.5 Enhancement Plugin initialized!'"
echo ""

# Final status
if [ -f "$PLUGIN_DIST" ] && command -v opencode >/dev/null 2>&1; then
    success "✅ GLM-4.5 Enhancement Plugin verification passed!"
    info "Plugin is ready to use with OpenCode"
else
    warn "⚠️  Some issues found - check the warnings above"
    info "Run the setup script to fix missing components"
fi

echo ""
info "For troubleshooting, see:"
info "- Plugin README: $PROJECT_ROOT/opencode/plugin/plugins/glm45-provider/README.md"
info "- OpenCode docs: https://opencode.ai/docs/providers/"
info "- Z.AI docs: https://z.ai/docs"
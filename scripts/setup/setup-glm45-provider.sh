#!/usr/bin/env sh

# GLM-4.5 Provider Setup Script for OpenCode
# Sets up free GLM-4.5 access through Z.AI provider

set -e

# Source common utilities
if [ -f "$(dirname "$0")/../../scripts/common.sh" ]; then
    . "$(dirname "$0")/../../scripts/common.sh"
else
    echo "🔴 Warning: common.sh not found, proceeding without utilities"
fi

PLUGIN_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$PLUGIN_DIR/../../../.." && pwd)"
OPENCODE_JSON="$PROJECT_ROOT/opencode.json"

info "🤖 Setting up GLM-4.5 Enhancement Plugin..."

# Step 1: Build the plugin
step "Building GLM-4.5 plugin..."
cd "$PLUGIN_DIR/opencode/plugin/plugins/glm45-provider"
if [ -f package.json ]; then
    npm install
    npm run build
    success "Plugin built successfully"
else
    error "package.json not found in plugin directory"
    exit 1
fi

# Step 2: Check if Z.AI provider is configured
step "Checking Z.AI provider configuration..."
if command -v opencode >/dev/null 2>&1; then
    if opencode auth list 2>/dev/null | grep -q "z.ai\|Z.AI"; then
        success "Z.AI provider already configured"
    else
        warn "Z.AI provider not configured"
        info "Run: opencode auth login"
        info "Select: Z.AI"
        info "Get API key from: https://z.ai/manage-apikey/apikey-list"
    fi
else
    warn "OpenCode CLI not found - please install OpenCode first"
fi

# Step 3: Update opencode.json with GLM models
step "Updating OpenCode configuration..."
if [ -f "$OPENCODE_JSON" ]; then
    info "Backing up existing opencode.json..."
    cp "$OPENCODE_JSON" "$OPENCODE_JSON.bak"
    
    # Check if Z.AI provider section exists
    if grep -q '"z.ai"' "$OPENCODE_JSON" 2>/dev/null; then
        info "Z.AI provider section already exists"
    else
        info "Adding Z.AI provider configuration..."
        # Use jq if available, otherwise manual edit
        if command -v jq >/dev/null 2>&1; then
            jq '.provider["z.ai"] = {
                "models": {
                    "glm-4.5-chat": {
                        "name": "GLM-4.5 Chat (FREE)",
                        "description": "General purpose coding and analysis"
                    },
                    "glm-z1-9b": {
                        "name": "GLM-Z1-9B Reasoning (FREE)",
                        "description": "Advanced reasoning and mathematics" 
                    }
                }
            }' "$OPENCODE_JSON" > "$OPENCODE_JSON.tmp" && mv "$OPENCODE_JSON.tmp" "$OPENCODE_JSON"
            success "GLM models added to opencode.json"
        else
            warn "jq not available - please manually add GLM models to opencode.json"
            info "See README.md for configuration example"
        fi
    fi
else
    info "Creating new opencode.json with GLM configuration..."
    cat > "$OPENCODE_JSON" << 'EOF'
{
    "$schema": "https://opencode.ai/config.json",
    "provider": {
        "z.ai": {
            "models": {
                "glm-4.5-chat": {
                    "name": "GLM-4.5 Chat (FREE)",
                    "description": "General purpose coding and analysis"
                },
                "glm-z1-9b": {
                    "name": "GLM-Z1-9B Reasoning (FREE)",
                    "description": "Advanced reasoning and mathematics"
                }
            }
        }
    }
}
EOF
    success "Created opencode.json with GLM configuration"
fi

# Step 4: Verify plugin integration
step "Verifying plugin integration..."
MAIN_PLUGIN="$PROJECT_ROOT/opencode/plugin/index.ts"
if [ -f "$MAIN_PLUGIN" ]; then
    if grep -q "GLM45ProviderPlugin\|glm45" "$MAIN_PLUGIN"; then
        success "GLM-4.5 plugin already integrated"
    else
        warn "GLM-4.5 plugin not found in main plugin file"
        info "Plugin may need manual integration in $MAIN_PLUGIN"
    fi
else
    warn "Main plugin file not found: $MAIN_PLUGIN"
fi

# Summary
echo ""
info "🎉 GLM-4.5 Enhancement Plugin setup complete!"
echo ""
info "Next steps:"
info "1. Run: opencode auth login (if not done)"
info "2. Select: Z.AI"
info "3. Enter API key from: https://z.ai/manage-apikey/apikey-list"
info "4. Test: opencode → /models → Select GLM model"
echo ""
info "Helper commands:"
info "- glm-status    : Check provider health"
info "- glm-switch    : View model switching guide"
echo ""
success "Ready to use FREE GLM-4.5 models! 🚀"
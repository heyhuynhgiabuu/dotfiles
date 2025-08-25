#!/usr/bin/env sh

# Z.AI Authentication Setup Script for OpenCode
# Handles the Z.AI provider authentication issue

set -e

echo "🔧 Setting up Z.AI authentication for OpenCode..."

# Step 1: Check if Z.AI is already configured
if opencode auth list 2>/dev/null | grep -q "Z.AI\|z.ai"; then
    echo "✅ Z.AI provider already configured"
    echo "💡 Checking models availability..."
    
    # Test model access
    if opencode --help >/dev/null 2>&1; then
        echo "✅ OpenCode CLI working"
        echo "📋 Try running: opencode → type '/models' → look for GLM models"
    fi
    exit 0
fi

# Step 2: Update OpenCode if needed
echo "🔄 Checking OpenCode version..."
OPENCODE_VERSION=$(opencode --version 2>/dev/null || echo "unknown")
echo "📌 Current version: $OPENCODE_VERSION"

if [ "$OPENCODE_VERSION" != "unknown" ]; then
    echo "💡 If Z.AI provider is missing, try updating OpenCode:"
    echo "   npm update -g opencode"
fi

# Step 3: Manual Z.AI setup instructions
echo ""
echo "🎯 Manual Z.AI Setup Instructions:"
echo ""
echo "1. Get Z.AI API Key:"
echo "   • Visit: https://z.ai/manage-apikey/apikey-list"
echo "   • Create account and generate API key"
echo ""
echo "2. Add to OpenCode:"
echo "   • Run: opencode auth login"
echo "   • Type: 'Z.AI' in search"
echo "   • Select: Z.AI from the list"
echo "   • Enter: Your API key"
echo ""
echo "3. Test GLM Models:"
echo "   • Run: opencode"
echo "   • Type: /models"
echo "   • Look for: GLM-4.5 Chat (FREE)"
echo ""

# Step 4: Alternative - Direct auth file modification
echo "🔧 Alternative: Direct Configuration"
echo ""
echo "If the above doesn't work, you can manually add credentials:"

AUTH_FILE="$HOME/.local/share/opencode/auth.json"
if [ -f "$AUTH_FILE" ]; then
    echo "📝 Edit: $AUTH_FILE"
    echo "Add this section (replace YOUR_API_KEY):"
    echo ""
    cat << 'EOF'
{
  "z.ai": {
    "type": "api",
    "apiKey": "YOUR_Z_AI_API_KEY_HERE"
  }
}
EOF
else
    echo "📝 Create: $AUTH_FILE"
    echo "With this content (replace YOUR_API_KEY):"
    echo ""
    cat << 'EOF'
{
  "z.ai": {
    "type": "api", 
    "apiKey": "YOUR_Z_AI_API_KEY_HERE"
  }
}
EOF
fi

echo ""
echo "📚 Useful Resources:"
echo "• Z.AI API: https://z.ai/docs"
echo "• OpenCode Providers: https://opencode.ai/docs/providers/"
echo "• GLM-4.5 Info: Completely free models via Z.AI"
echo ""
echo "✨ Once setup, GLM-4.5 models should appear in /models command!"
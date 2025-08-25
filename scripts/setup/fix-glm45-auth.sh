#!/usr/bin/env sh

# GLM-4.5 Complete Setup and Fix Script
# Handles Z.AI authentication issues and provides multiple solutions

set -e

echo "🚀 GLM-4.5 Setup and Authentication Fix"
echo "======================================="

# Check current status
echo "📋 Current Status:"
echo "• OpenCode version: $(opencode --version 2>/dev/null || echo 'not found')"
echo "• Auth status: $(opencode auth list 2>/dev/null | grep -c 'credentials' || echo '0') providers configured"

# Test if Z.AI is available in provider list
echo ""
echo "🔍 Testing Z.AI Provider Availability..."

# Create a test script to check providers
cat > /tmp/test_providers.sh << 'EOF'
#!/usr/bin/env sh
timeout 5 sh -c '
    echo "" | opencode auth login 2>&1 | grep -i "z\.ai" && echo "✅ Z.AI provider found" || echo "❌ Z.AI provider not found"
' || echo "⚠️ Provider test timed out"
EOF

chmod +x /tmp/test_providers.sh
/tmp/test_providers.sh
rm -f /tmp/test_providers.sh

echo ""
echo "🎯 Step-by-Step Solutions:"
echo ""

echo "📝 SOLUTION 1: Manual Auth File Update (Most Reliable)"
echo "1. Get your Z.AI API key from: https://z.ai/manage-apikey/apikey-list"
echo "2. Edit your auth file: ~/.local/share/opencode/auth.json"
echo "3. Add this section (replace PLACEHOLDER with real key):"
echo ""
cat << 'EOF'
  "z.ai": {
    "type": "api",
    "key": "YOUR_REAL_Z_AI_API_KEY_HERE"
  }
EOF
echo ""

echo "📝 SOLUTION 2: OpenCode CLI Method"
echo "1. Run: opencode auth login"
echo "2. Type: Z.AI (search for it)"
echo "3. Select: Z.AI from dropdown"
echo "4. Enter: Your API key"
echo ""

echo "📝 SOLUTION 3: Update OpenCode"
echo "1. Run: npm update -g opencode"
echo "2. Then try Solution 1 or 2"
echo ""

echo "🧪 VERIFICATION STEPS:"
echo "After adding Z.AI credentials:"
echo "1. Run: opencode auth list"
echo "   Should show: Z.AI provider"
echo ""
echo "2. Run: opencode"
echo "   Type: /models"
echo "   Look for: GLM-4.5 Chat (FREE) and GLM-Z1-9B Reasoning (FREE)"
echo ""
echo "3. Test GLM model:"
echo "   Select GLM model from /models"
echo "   Ask: 'Hello GLM-4.5!'"
echo ""

echo "📋 Current OpenCode Configuration:"
OPENCODE_CONFIG="/Users/killerkidbo/dotfiles/opencode/opencode.json"
if [ -f "$OPENCODE_CONFIG" ]; then
    echo "✅ Z.AI provider configured in opencode.json"
    grep -A 10 '"z\.ai"' "$OPENCODE_CONFIG" || echo "❌ Z.AI config not found"
else
    echo "❌ OpenCode config not found at: $OPENCODE_CONFIG"
fi

echo ""
echo "🔧 Quick Fix Command:"
echo "To manually add Z.AI to auth file, run:"
echo ""
cat << 'EOF'
# Backup current auth
cp ~/.local/share/opencode/auth.json ~/.local/share/opencode/auth.json.backup

# Add Z.AI (replace YOURKEY with real API key)
python3 -c "
import json
with open('$HOME/.local/share/opencode/auth.json', 'r') as f:
    auth = json.load(f)
auth['z.ai'] = {'type': 'api', 'key': 'YOURKEY'}
with open('$HOME/.local/share/opencode/auth.json', 'w') as f:
    json.dump(auth, f, indent=2)
print('✅ Z.AI added to auth.json')
"
EOF

echo ""
echo "📚 Resources:"
echo "• Z.AI API Keys: https://z.ai/manage-apikey/apikey-list"
echo "• OpenCode Docs: https://opencode.ai/docs/providers/"
echo "• GLM-4.5 is FREE through Z.AI!"
echo ""
echo "🎉 After setup, you'll have free access to GLM-4.5 models!"
#!/bin/bash

echo "=== AugmentCode Authentication Step-by-Step Guide ==="
echo
echo "🔧 PREPARATION:"
echo "1. Close all Neovim instances"
echo "2. Open a fresh terminal"
echo "3. Ensure Node.js v22 is active: source ~/.nvm/nvm.sh && nvm use v22.14.0"
echo

echo "📱 AUTHENTICATION STEPS:"
echo
echo "STEP 1: Start authentication"
echo "  cd ~/dotfiles"
echo "  nvim test.go"
echo "  :Augment signin"
echo
echo "STEP 2: Manual URL handling"
echo "  ⚠️  The URL will appear in Neovim's message area"
echo "  ⚠️  You CANNOT click it or use 'gx' to open it"
echo "  ✅ MANUALLY select and copy the entire URL"
echo "  ✅ Paste it into your browser address bar"
echo
echo "STEP 3: Browser authentication"
echo "  - Complete sign-in in browser"
echo "  - Accept terms if prompted"
echo "  - Browser will show a JSON response"
echo
echo "STEP 4: Copy complete JSON response"
echo "  ⚠️  Do NOT copy just the 'code' value"
echo "  ✅ Copy the ENTIRE JSON object, example:"
echo '     {"code":"xyz123","state":"abc456","tenant_url":"https://i0.api.augmentcode.com/"}'
echo
echo "STEP 5: Return to terminal"
echo "  - Go back to the SAME terminal where Neovim is running"
echo "  - Paste the complete JSON when prompted"
echo "  - Press Enter"
echo
echo "STEP 6: Verify success"
echo "  :Augment status"
echo "  Should show: 'Signed in: true' or similar"
echo

echo "🚨 COMMON MISTAKES TO AVOID:"
echo "  ❌ Trying to click the URL in Neovim"
echo "  ❌ Using 'gx' command on the URL"
echo "  ❌ Copying only the 'code' part"
echo "  ❌ Switching to different terminal"
echo "  ❌ Taking too long (session timeout)"
echo

echo "✅ TROUBLESHOOTING:"
echo "  If still failing:"
echo "  1. :Augment log (show detailed errors)"
echo "  2. Try :Augment signout then :Augment signin"
echo "  3. Restart Neovim and try again"
echo "  4. Check Node.js version: node --version"
echo

echo "🎯 Ready to test? Follow the steps above exactly!"
echo
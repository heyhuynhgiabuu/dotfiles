#!/bin/bash

echo "=== AugmentCode Authentication Debug Script ==="
echo

# Load nvm and switch to Node.js v22
source ~/.nvm/nvm.sh
nvm use v22.14.0

echo "Environment Status:"
echo "  Node.js version: $(node --version)"
echo "  Neovim version: $(nvim --version | head -1)"
echo "  Current directory: $(pwd)"
echo

# Check AugmentCode plugin status
echo "Testing AugmentCode plugin status:"
nvim --headless +"lua print('✅ AugmentCode plugin loaded')" +qall 2>/dev/null
if [ $? -eq 0 ]; then
    echo "  ✅ Plugin loads successfully"
else
    echo "  ❌ Plugin failed to load"
fi

# Check if AugmentCode commands are available
echo
echo "Checking AugmentCode commands:"
nvim --headless +"Augment status" +qall 2>/dev/null
command_status=$?

if [ $command_status -eq 0 ]; then
    echo "  ✅ :Augment command is available"
else
    echo "  ❌ :Augment command not found"
fi

echo
echo "=== Authentication Troubleshooting Steps ==="
echo
echo "STEP 1: Clean authentication state"
echo "  - Close all Neovim instances"
echo "  - Clear any cached authentication"
echo "  - Open a fresh terminal session"
echo
echo "STEP 2: Proper sign-in process"
echo "  1. cd ~/dotfiles"
echo "  2. nvim test.go"
echo "  3. In Neovim: :Augment signin"
echo "  4. Complete sign-in in browser"
echo "  5. Copy the COMPLETE authentication response"
echo "  6. Paste in the SAME terminal where Neovim is running"
echo
echo "STEP 3: Expected authentication flow"
echo "  Browser should show: Complete authentication"
echo "  AugmentCode should provide JSON with:"
echo "    - code: API key"
echo "    - state: Session state"
echo "    - tenant_url: API endpoint"
echo
echo "STEP 4: Common authentication mistakes"
echo "  ❌ Pasting only part of the response"
echo "  ❌ Switching to different terminal window"
echo "  ❌ Browser showing different URL than expected"
echo "  ❌ Copying from wrong place in browser"
echo
echo "STEP 5: Verification"
echo "  After successful auth: :Augment status"
echo "  Should show: 'Signed in' status"
echo

echo "=== Manual Testing Instructions ==="
echo
echo "Ready to test? Follow these exact steps:"
echo
echo "1. Open NEW terminal window"
echo "2. cd ~/dotfiles"
echo "3. nvim test.go"
echo "4. In Neovim type: :Augment signin"
echo "5. Browser will open - complete authentication"
echo "6. Copy ENTIRE JSON response from browser"
echo "7. Return to SAME terminal with Neovim"
echo "8. Paste the authentication response"
echo "9. Check status: :Augment status"
echo
echo "If authentication still fails, run: :Augment log"
echo "This will show detailed error information."
echo
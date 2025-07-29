#!/bin/bash

echo "=== AugmentCode Deep Debug - JSON Parsing Error ==="
echo

# Load nvm and switch to Node.js v22
source ~/.nvm/nvm.sh
nvm use v22.14.0

echo "Environment Status:"
echo "  Node.js: $(node --version)"
echo "  Neovim: $(nvim --version | head -1)"
echo

echo "=== Checking AugmentCode Logs ==="
echo "Run this in Neovim to see detailed logs:"
echo "  :Augment log"
echo

echo "=== JSON Format Debugging ==="
echo "The JSON you copy should look EXACTLY like this:"
echo '{"code":"xxxxxxxx","state":"xxxxxxxx","tenant_url":"https://i0.api.augmentcode.com/"}'
echo
echo "Common JSON formatting issues:"
echo "  ❌ Extra whitespace or newlines"
echo "  ❌ Missing quotes around values"
echo "  ❌ Incomplete JSON (missing brackets)"
echo "  ❌ Special characters not properly escaped"
echo

echo "=== Testing Steps ==="
echo "1. Try authentication again:"
echo "   cd ~/dotfiles"
echo "   nvim test.go"
echo "   :Augment signin"
echo
echo "2. Before pasting JSON, check exact format in browser"
echo "3. Copy ONLY the JSON object (no extra text)"
echo "4. If it fails, immediately run: :Augment log"
echo

echo "=== Alternative Methods ==="
echo "Method 1: Clear cache and retry"
echo "  :Augment signout"
echo "  Close Neovim completely"
echo "  Restart Neovim"
echo "  :Augment signin"
echo
echo "Method 2: Check for plugin updates"
echo "  In Neovim: :Lazy sync"
echo "  Restart Neovim"
echo "  Try authentication again"
echo

echo "=== Debugging Questions ==="
echo "1. What does the exact JSON look like in your browser?"
echo "2. Are you copying from the page source or rendered page?"
echo "3. Does :Augment log show specific error details?"
echo "4. Are you using any browser extensions that might modify the JSON?"
echo
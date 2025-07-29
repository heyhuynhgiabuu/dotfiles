#!/bin/bash

echo "=== AugmentCode Environment Test ==="
echo

# Load nvm and switch to Node.js v22
source ~/.nvm/nvm.sh
nvm use v22.14.0

echo "Node.js version: $(node --version)"
echo "NPM version: $(npm --version)"
echo "Neovim version: $(nvim --version | head -1)"
echo

# Test if AugmentCode plugin loads
echo "Testing AugmentCode plugin loading..."
nvim --headless -c "
lua print('Testing AugmentCode plugin...')
lua local commands = vim.api.nvim_get_commands({})
lua for cmd, _ in pairs(commands) do if cmd:lower():find('augment') then print('✅ AugmentCode command found: ' .. cmd) end end
lua local handle = io.popen('node --version 2>&1')
lua local node_version = handle:read('*a'):gsub('\n', '')
lua handle:close()
lua print('Node.js accessible from Neovim: ' .. node_version)
qall
"

echo
echo "=== Manual Testing Instructions ==="
echo "1. Open Neovim: nvim test.go"
echo "2. Try sign-in: :Augment signin"
echo "3. If authentication fails, check the error message carefully"
echo "4. Look for any Node.js related errors"
echo
echo "Expected authentication flow:"
echo "- AugmentCode will provide a JSON response with auth details"
echo "- Copy the FULL response (may wrap multiple lines)"
echo "- Paste it in the terminal when prompted"
echo
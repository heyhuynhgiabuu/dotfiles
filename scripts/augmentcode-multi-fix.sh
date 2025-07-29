#!/bin/bash

echo "=== AugmentCode Authentication Fix - Multiple Solutions ==="
echo

# Load nvm and switch to Node.js v22
source ~/.nvm/nvm.sh
nvm use v22.14.0

echo "🔧 SOLUTION 1: Plugin Update & Clean Install"
echo "  Many authentication issues are fixed in newer versions"
echo "  
  Steps:
  1. nvim
  2. :Lazy sync (update all plugins)
  3. :qa (quit completely)
  4. Restart terminal
  5. cd ~/dotfiles && nvim test.go
  6. :Augment signin
"
echo

echo "🔧 SOLUTION 2: Clear Authentication Cache"
echo "  Remove any cached authentication data
  
  Steps:
  1. :Augment signout (if already signed in)
  2. Close Neovim completely
  3. Find and remove AugmentCode cache files:
     ~/.cache/augment* (if exists)
     ~/.local/share/augment* (if exists)
  4. Restart Neovim
  5. :Augment signin
"
echo

echo "🔧 SOLUTION 3: Terminal/Browser Compatibility"
echo "  Use different browser or terminal
  
  Steps:
  1. Try in a different browser (Chrome, Firefox, Safari)
  2. Try in Terminal.app instead of WezTerm
  3. Disable browser extensions temporarily
  4. Use incognito/private browsing mode
"
echo

echo "🔧 SOLUTION 4: Manual Account Creation"
echo "  Create account via website first
  
  Steps:
  1. Go to https://augmentcode.com
  2. Sign up for account manually
  3. Verify email if required
  4. THEN try :Augment signin in Neovim
"
echo

echo "🔧 SOLUTION 5: JSON Format Debugging"
echo "  Check exact JSON format from browser
  
  Expected format:
  {\"code\":\"your_api_key\",\"state\":\"session_state\",\"tenant_url\":\"https://i0.api.augmentcode.com/\"}
  
  Common issues:
  ❌ Browser adds extra text before/after JSON
  ❌ JSON is formatted with line breaks
  ❌ Copying from wrong part of page
  ❌ Unicode characters in JSON
"
echo

echo "🔧 SOLUTION 6: Alternative Installation Method"
echo "  Try manual installation instead of Lazy.nvim
  
  Steps:
  1. Remove current plugin from Lazy config
  2. :Lazy clean
  3. Manual install:
     git clone https://github.com/augmentcode/augment.vim.git \\
       ~/.config/nvim/pack/augment/start/augment.vim
  4. Restart Neovim
  5. :Augment signin
"
echo

echo "🔧 SOLUTION 7: Workspace Configuration Issue"
echo "  Fix workspace folder configuration
  
  Current config: vim.g.augment_workspace_folders = { vim.fn.getcwd() }
  
  Try static path instead:
  vim.g.augment_workspace_folders = { '/Users/killerkidbo/dotfiles' }
"
echo

echo "🎯 IMMEDIATE NEXT STEPS:"
echo "1. Try Solution 1 (Plugin Update) first"
echo "2. If that fails, try Solution 2 (Clear Cache)"
echo "3. For each attempt, check :Augment log for details"
echo "4. If JSON parsing still fails, try Solution 4 (Manual Account)"
echo

echo "📊 DEBUG COMMANDS:"
echo "  :Augment status  - Check current status"
echo "  :Augment log     - See detailed error logs"
echo "  :Lazy health     - Check plugin health"
echo "  :checkhealth     - General Neovim health"
echo
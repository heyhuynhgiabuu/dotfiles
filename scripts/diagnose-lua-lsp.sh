#!/bin/bash

echo "🔍 Comprehensive Lua LSP Diagnostic Test"
echo "========================================"

echo "1. Checking lua-language-server installation..."
if command -v lua-language-server &> /dev/null; then
    echo "✅ lua-language-server found at: $(which lua-language-server)"
    echo "   Testing server executable..."
    if lua-language-server --version &> /dev/null; then
        echo "✅ lua-language-server is executable"
    else
        echo "❌ lua-language-server is not executable or has issues"
    fi
else
    echo "❌ lua-language-server not found in PATH"
    echo "   Installing via Homebrew..."
    brew install lua-language-server
fi

echo
echo "2. Testing Neovim configuration..."
cd "$(dirname "$0")/.."
if nvim --headless -c "echo 'Neovim loads successfully'" -c "qa" 2>/dev/null; then
    echo "✅ Neovim configuration loads without errors"
else
    echo "❌ Neovim configuration has errors"
    echo "   Detailed error output:"
    nvim --headless -c "echo 'Testing...'" -c "qa"
fi

echo
echo "3. Testing LSP configuration..."
# Create a temporary test file
cat > /tmp/test_lua_lsp.lua << 'EOF'
-- Test file for Lua LSP
local function test()
    print("Hello, World!")
    vim.api.nvim_get_current_buf()
    -- This should trigger diagnostics
    local undefined = some_undefined_variable
end
EOF

echo "   Created test file: /tmp/test_lua_lsp.lua"
echo "   Testing LSP client connection..."

# Test LSP in a more detailed way
nvim --headless \
    -c "edit /tmp/test_lua_lsp.lua" \
    -c "sleep 3" \
    -c "lua print('=== LSP DIAGNOSTIC RESULTS ===')" \
    -c "lua print('Active LSP clients: ' .. #vim.lsp.get_clients())" \
    -c "lua for _, client in pairs(vim.lsp.get_clients()) do print('Client: ' .. client.name .. ' (ID: ' .. client.id .. ')') end" \
    -c "lua print('LSP buf clients for current buffer: ' .. #vim.lsp.get_clients({bufnr=0}))" \
    -c "lua print('=== END DIAGNOSTIC ===')" \
    -c "qa"

echo
echo "4. Testing Mason installation..."
nvim --headless \
    -c "lua local ok, mason = pcall(require, 'mason'); if ok then print('✅ Mason is available') else print('❌ Mason not found') end" \
    -c "lua local ok, registry = pcall(require, 'mason-registry'); if ok and registry.is_installed('lua-language-server') then print('✅ lua-language-server installed via Mason') else print('❌ lua-language-server not installed via Mason') end" \
    -c "qa"

echo
echo "5. Manual LSP test..."
echo "   You can now open Neovim with: nvim /tmp/test_lua_lsp.lua"
echo "   And run :LspInfo to see if lua_ls is attached"
echo "   Or run :checkhealth lsp for more detailed diagnostics"

# Cleanup
# rm -f /tmp/test_lua_lsp.lua

echo
echo "✅ Diagnostic complete! Check the output above for any issues."

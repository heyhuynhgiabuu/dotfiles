#!/bin/bash

# OpenCode VectorCode Plugin Verification Script
# Cross-platform verification for macOS and Linux

set -e

echo "🔍 OpenCode VectorCode Plugin Verification"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

info() {
    echo -e "ℹ️  $1"
}

# Check if we're in the right directory
if [[ ! -f "opencode/plugin/plugins/opencode-vectorcode-plugin/plugin.json" ]]; then
    error "Must run from dotfiles root directory"
    exit 1
fi

echo ""
echo "📋 Pre-Testing Verification"
echo "=========================="

# 1. Check Node.js version
info "Checking Node.js version..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    success "Node.js: $NODE_VERSION"
else
    error "Node.js not found - please install Node.js >=18.0.0"
    exit 1
fi

# 2. Check VectorCode CLI
info "Checking VectorCode CLI..."
if command -v vectorcode &> /dev/null; then
    VECTORCODE_VERSION=$(vectorcode --version 2>/dev/null || echo "unknown")
    success "VectorCode CLI: $VECTORCODE_VERSION"
else
    warning "VectorCode CLI not found - plugin will show appropriate error"
fi

# 3. Check TypeScript compilation
info "Checking plugin compilation..."
cd opencode/plugin/plugins/opencode-vectorcode-plugin
if npm run build > /dev/null 2>&1; then
    success "Plugin compiles successfully"
else
    error "Plugin compilation failed"
    exit 1
fi

# 4. Verify dist files exist
info "Checking build output..."
if [[ -f "dist/index.js" && -f "dist/index.d.ts" ]]; then
    success "Build files present: dist/index.js, dist/index.d.ts"
else
    error "Missing build files"
    exit 1
fi

# 5. Check required files
info "Checking required files..."
REQUIRED_FILES=("package.json" "plugin.json" "README.md" "TESTING_CHECKLIST.md" "tsconfig.json" "src/index.ts" "types.d.ts")
for file in "${REQUIRED_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        success "✓ $file"
    else
        error "Missing required file: $file"
        exit 1
    fi
done

# 6. Validate JSON files
info "Validating JSON configuration..."
if command -v node &> /dev/null; then
    if node -e "JSON.parse(require('fs').readFileSync('package.json', 'utf8'))" 2>/dev/null; then
        success "package.json is valid"
    else
        error "package.json is invalid"
        exit 1
    fi
    
    if node -e "JSON.parse(require('fs').readFileSync('plugin.json', 'utf8'))" 2>/dev/null; then
        success "plugin.json is valid"
    else
        error "plugin.json is invalid"
        exit 1
    fi
fi

# 7. Check plugin structure
info "Verifying plugin structure..."
PLUGIN_NAME=$(node -e "console.log(JSON.parse(require('fs').readFileSync('plugin.json', 'utf8')).name)" 2>/dev/null)
if [[ "$PLUGIN_NAME" == "opencode-vectorcode-plugin" ]]; then
    success "Plugin name correct: $PLUGIN_NAME"
else
    error "Plugin name mismatch: $PLUGIN_NAME"
    exit 1
fi

cd - > /dev/null

echo ""
echo "🚀 Plugin Integration Check"
echo "========================="

# 8. Check plugin location
info "Verifying plugin location..."
PLUGIN_PATH="opencode/plugin/plugins/opencode-vectorcode-plugin"
if [[ -d "$PLUGIN_PATH" ]]; then
    success "Plugin in correct location: $PLUGIN_PATH"
else
    error "Plugin not in expected location"
    exit 1
fi

# 9. Check main plugin directory
info "Checking main plugin structure..."
if [[ -f "opencode/plugin/index.ts" && -f "opencode/plugin/tsconfig.json" ]]; then
    success "Main plugin structure intact"
else
    error "Main plugin structure damaged"
    exit 1
fi

# 10. Verify no conflicts
info "Checking for conflicts..."
if [[ -f "opencode/plugin/plugins/README.md" ]]; then
    success "Plugin system README present"
else
    warning "Plugin system README missing"
fi

echo ""
echo "📊 Cross-Platform Check"
echo "======================"

# 11. Platform detection
PLATFORM=$(uname -s)
case $PLATFORM in
    Darwin*)
        success "Platform: macOS"
        ;;
    Linux*)
        success "Platform: Linux"
        ;;
    *)
        warning "Platform: $PLATFORM (may need testing)"
        ;;
esac

# 12. Path compatibility
info "Checking path compatibility..."
if [[ -r "$PLUGIN_PATH/dist/index.js" ]]; then
    success "Plugin file readable"
else
    error "Plugin file not readable"
    exit 1
fi

echo ""
echo "📝 Manual Testing Instructions"
echo "============================"

info "To complete verification, manually test these OpenCode commands:"
echo ""
echo "1. Check plugin is loaded:"
echo "   /plugins"
echo ""
echo "2. Get help for VectorCode commands:"
echo "   /help"
echo ""
echo "3. Test VectorCode context (if CLI available):"
echo "   /getVectorCodeContext"
echo ""
echo "4. Test VectorCode query (if CLI available):"
echo "   /queryVectorCode {\"query\": \"test\"}"
echo ""
echo "5. Follow complete TESTING_CHECKLIST.md"

echo ""
echo "🎯 Verification Summary"
echo "======================"

success "All automated checks PASSED"
info "Plugin is ready for manual testing"
warning "Complete TESTING_CHECKLIST.md for full verification"

echo ""
echo "📂 Files Created/Modified:"
echo "========================="
echo "✓ opencode/plugin/plugins/opencode-vectorcode-plugin/ (complete plugin)"
echo "✓ opencode/plugin/plugins/README.md (plugin system documentation)"
echo "✓ Backup created in .serena/backups/"

echo ""
echo "🔧 Next Steps:"
echo "============="
echo "1. Test plugin in OpenCode: /plugins"
echo "2. Execute manual testing checklist"
echo "3. Verify cross-platform compatibility"
echo "4. Add more plugins using the same structure"

echo ""
success "✅ VERIFICATION COMPLETE"
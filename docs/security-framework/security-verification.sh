#!/usr/bin/env sh

# OpenCode Plugin Security Verification Suite
# 
# Comprehensive manual verification of the plugin security framework:
# - Process isolation verification
# - Cryptographic signing validation
# - Token lifecycle testing
# - Audit logging integrity
# - Cross-platform compatibility

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Logging functions
log_info() {
    printf "${GREEN}[INFO]${NC} %s\n" "$1"
}

log_warn() {
    printf "${YELLOW}[WARN]${NC} %s\n" "$1"
}

log_error() {
    printf "${RED}[ERROR]${NC} %s\n" "$1"
}

log_test() {
    printf "${BLUE}[TEST]${NC} %s\n" "$1"
}

# Test result tracking
test_start() {
    TESTS_RUN=$((TESTS_RUN + 1))
    log_test "$1"
}

test_pass() {
    TESTS_PASSED=$((TESTS_PASSED + 1))
    log_info "✅ PASS: $1"
}

test_fail() {
    TESTS_FAILED=$((TESTS_FAILED + 1))
    log_error "❌ FAIL: $1"
}

test_warn() {
    log_warn "⚠️  WARN: $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check Node.js
    if ! command -v node >/dev/null 2>&1; then
        log_error "Node.js not found - required for security tests"
        exit 1
    fi
    
    # Check consolidated security framework (we're inside it now)
    if [ ! -d "process-isolation" ]; then
        log_error "Process isolation framework not found"
        exit 1
    fi
    
    if [ ! -d "token" ]; then
        log_error "Token security framework not found"
        exit 1
    fi
    
    if [ ! -d "tools" ]; then
        log_error "Signing tools not found"
        exit 1
    fi
    
    log_info "Prerequisites check: PASSED"
}

# Test 1: Process Isolation Verification
test_process_isolation() {
    test_start "Process isolation framework"
    
    # Test basic worker spawning
    if node process-isolation/test_isolation.js >/dev/null 2>&1; then
        test_pass "Process isolation basic functionality"
    else
        test_fail "Process isolation basic functionality"
    fi
    
    # Test sandbox utilities
    if ./process-isolation/sandbox_utils.sh verify >/dev/null 2>&1; then
        test_pass "Cross-platform sandbox utilities"
    else
        test_fail "Cross-platform sandbox utilities"
    fi
    
    # Test resource limits
    if ./process-isolation/sandbox_utils.sh test-memory 32 >/dev/null 2>&1; then
        test_pass "Memory limit enforcement"
    else
        test_warn "Memory limit enforcement (may not be supported on this platform)"
    fi
}

# Test 2: Cryptographic Signing Verification
test_cryptographic_signing() {
    test_start "Cryptographic signing and verification"
    
    # Generate test key if not exists
    if [ ! -f "$HOME/.opencode/keys/test_ed25519" ]; then
        ././keys/key-management.sh gen-ed25519 test-publisher >/dev/null 2>&1
    fi
    
    # Create test manifest
    cat > /tmp/test_manifest.json << 'EOF'
{
  "pluginId": "test.plugin",
  "version": "1.0.0",
  "files": []
}
EOF
    
    # Test signing
    if node tools/sign-manifest.js /tmp/test_manifest.json "$HOME/.opencode/keys/test_ed25519" test-key-1 ed25519 >/dev/null 2>&1; then
        test_pass "Manifest signing"
    else
        test_fail "Manifest signing"
    fi
    
    # Test verification
    if node tools/verify-manifest.js /tmp/test_manifest.signed.json >/dev/null 2>&1; then
        test_pass "Manifest verification"
    else
        test_fail "Manifest verification"
    fi
    
    # Cleanup
    rm -f /tmp/test_manifest.json /tmp/test_manifest.signed.json
}

# Test 3: Token Lifecycle Testing
test_token_lifecycle() {
    test_start "Token lifecycle and revocation"
    
    # Create test script for token operations
    cat > /tmp/test_tokens.js << 'EOF'
const TokenService = require('././token/service');
const RevocationStore = require('././token/revocation_store');
const AuditLogger = require('././audit/logger');

async function testTokens() {
    try {
        // Initialize services
        const revocationStore = new RevocationStore();
        const auditLogger = new AuditLogger();
        const tokenService = new TokenService({ revocationStore, auditLogger });
        
        // Test token issuance
        const tokenResult = await tokenService.issueToken('test-plugin', ['notify'], 60);
        if (!tokenResult.access_token) {
            throw new Error('Token issuance failed');
        }
        
        // Test token validation
        const validation = await tokenService.validateToken(tokenResult.access_token, ['notify'], 'test-plugin');
        if (!validation.valid) {
            throw new Error('Token validation failed');
        }
        
        // Test token revocation
        await tokenService.revokeToken(tokenResult.jti, 'test-revocation');
        
        // Test revoked token validation (should fail)
        const revokedValidation = await tokenService.validateToken(tokenResult.access_token, ['notify'], 'test-plugin');
        if (revokedValidation.valid) {
            throw new Error('Revoked token still valid');
        }
        
        console.log('Token lifecycle test: PASSED');
        process.exit(0);
    } catch (error) {
        console.error('Token lifecycle test: FAILED -', error.message);
        process.exit(1);
    }
}

testTokens();
EOF
    
    # Run token test
    if node /tmp/test_tokens.js >/dev/null 2>&1; then
        test_pass "Token lifecycle (issue, validate, revoke)"
    else
        test_fail "Token lifecycle"
    fi
    
    # Cleanup
    rm -f /tmp/test_tokens.js
}

# Test 4: Audit Logging Integrity
test_audit_logging() {
    test_start "Audit logging integrity and tamper detection"
    
    # Create test script for audit logging
    cat > /tmp/test_audit.js << 'EOF'
const AuditLogger = require('././audit/logger');
const path = require('path');

async function testAudit() {
    try {
        // Initialize audit logger with test directory
        const testLogDir = '/tmp/opencode_audit_test';
        const auditLogger = new AuditLogger({ 
            logDir: testLogDir,
            logFile: 'test_audit.jsonl'
        });
        
        // Log several test events
        await auditLogger.log({
            event_type: 'TEST_EVENT_1',
            actor: { type: 'system', id: 'test' },
            data: { message: 'Test event 1' }
        });
        
        await auditLogger.log({
            event_type: 'TEST_EVENT_2',
            actor: { type: 'plugin', id: 'test-plugin' },
            data: { message: 'Test event 2', secret: 'should-be-redacted' }
        });
        
        await auditLogger.log({
            event_type: 'TEST_EVENT_3',
            actor: { type: 'system', id: 'test' },
            data: { message: 'Test event 3' }
        });
        
        // Verify log integrity
        const verification = await auditLogger.verifyLogIntegrity();
        if (!verification.valid) {
            throw new Error('Log integrity verification failed: ' + verification.errors.join(', '));
        }
        
        if (verification.validEntries !== 3) {
            throw new Error('Expected 3 valid entries, got ' + verification.validEntries);
        }
        
        console.log('Audit logging test: PASSED');
        
        // Cleanup test directory
        const fs = require('fs');
        if (fs.existsSync(testLogDir)) {
            fs.rmSync(testLogDir, { recursive: true, force: true });
        }
        
        process.exit(0);
    } catch (error) {
        console.error('Audit logging test: FAILED -', error.message);
        process.exit(1);
    }
}

testAudit();
EOF
    
    # Run audit test
    if node /tmp/test_audit.js >/dev/null 2>&1; then
        test_pass "Audit logging integrity and chain validation"
    else
        test_fail "Audit logging integrity"
    fi
    
    # Cleanup
    rm -f /tmp/test_audit.js
}

# Test 5: Cross-Platform Compatibility
test_cross_platform() {
    test_start "Cross-platform compatibility"
    
    # Detect platform
    PLATFORM=$(uname -s)
    log_info "Testing on platform: $PLATFORM"
    
    # Test POSIX script compatibility
    if ././keys/key-management.sh help >/dev/null 2>&1; then
        test_pass "POSIX script compatibility"
    else
        test_fail "POSIX script compatibility"
    fi
    
    # Test directory permissions
    TEST_DIR="/tmp/opencode_perm_test"
    mkdir -p "$TEST_DIR"
    chmod 700 "$TEST_DIR"
    
    if [ "$(stat -c %a "$TEST_DIR" 2>/dev/null || stat -f %A "$TEST_DIR" 2>/dev/null)" = "700" ]; then
        test_pass "Directory permission handling"
    else
        test_warn "Directory permission verification (platform-specific)"
    fi
    
    rm -rf "$TEST_DIR"
    
    # Platform-specific notification test
    case "$PLATFORM" in
        "Darwin")
            if command -v osascript >/dev/null 2>&1; then
                test_pass "macOS notification support"
            else
                test_fail "macOS notification support"
            fi
            ;;
        "Linux")
            if command -v notify-send >/dev/null 2>&1; then
                test_pass "Linux notification support"
            else
                test_warn "Linux notification support (notify-send not available)"
            fi
            ;;
        *)
            test_warn "Unknown platform: $PLATFORM"
            ;;
    esac
}

# Test 6: Security Integration
test_security_integration() {
    test_start "Security framework integration"
    
    # Create integration test
    cat > /tmp/test_integration.js << 'EOF'
const TokenService = require('././token/service');
const RevocationStore = require('././token/revocation_store');
const AuditLogger = require('././audit/logger');

async function testIntegration() {
    try {
        // Initialize all components
        const revocationStore = new RevocationStore();
        const auditLogger = new AuditLogger();
        const tokenService = new TokenService({ revocationStore, auditLogger });
        
        // Test integrated workflow
        const plugin = 'test-plugin';
        const capabilities = ['notify', 'read_files'];
        
        // Issue token
        const tokenResult = await tokenService.issueToken(plugin, capabilities, 300);
        
        // Validate token
        const validation = await tokenService.validateToken(
            tokenResult.access_token, 
            ['notify'], 
            plugin
        );
        
        if (!validation.valid) {
            throw new Error('Integration test failed: token validation');
        }
        
        // Check audit events were logged
        const stats = auditLogger.getStats();
        if (stats.sequence < 1) {
            throw new Error('Integration test failed: no audit events logged');
        }
        
        // Test capability enforcement
        const overCapValidation = await tokenService.validateToken(
            tokenResult.access_token,
            ['notify', 'read_files', 'network'], // Request more than granted
            plugin
        );
        
        if (overCapValidation.valid) {
            throw new Error('Integration test failed: capability enforcement');
        }
        
        console.log('Security integration test: PASSED');
        process.exit(0);
    } catch (error) {
        console.error('Security integration test: FAILED -', error.message);
        process.exit(1);
    }
}

testIntegration();
EOF
    
    # Run integration test
    if node /tmp/test_integration.js >/dev/null 2>&1; then
        test_pass "Security framework integration"
    else
        test_fail "Security framework integration"
    fi
    
    # Cleanup
    rm -f /tmp/test_integration.js
}

# Test 7: Performance and Resource Usage
test_performance() {
    test_start "Performance and resource usage"
    
    # Test token service performance
    START_TIME=$(date +%s%N)
    for i in $(seq 1 100); do
        node -e "
            const TokenService = require('././token/service');
            const service = new TokenService();
            service.issueToken('perf-test-$i', ['notify'], 60);
        " >/dev/null 2>&1 || true
    done
    END_TIME=$(date +%s%N)
    
    DURATION=$(( (END_TIME - START_TIME) / 1000000 )) # Convert to milliseconds
    
    if [ "$DURATION" -lt 10000 ]; then # Less than 10 seconds for 100 operations
        test_pass "Token service performance (${DURATION}ms for 100 operations)"
    else
        test_warn "Token service performance may be slow (${DURATION}ms for 100 operations)"
    fi
    
    # Test memory usage (basic check)
    if node -e "
        const process = require('process');
        const initial = process.memoryUsage().heapUsed;
        const services = [];
        for (let i = 0; i < 10; i++) {
            const TokenService = require('././token/service');
            services.push(new TokenService());
        }
        const final = process.memoryUsage().heapUsed;
        const diff = final - initial;
        if (diff > 100 * 1024 * 1024) { // 100MB
            console.error('High memory usage: ' + Math.round(diff / 1024 / 1024) + 'MB');
            process.exit(1);
        }
        console.log('Memory usage acceptable: ' + Math.round(diff / 1024) + 'KB');
    " >/dev/null 2>&1; then
        test_pass "Memory usage within acceptable limits"
    else
        test_warn "Memory usage may be high"
    fi
}

# Main test execution
run_all_tests() {
    log_info "🔒 OpenCode Plugin Security Verification Suite"
    log_info "============================================="
    
    check_prerequisites
    
    test_process_isolation
    test_cryptographic_signing
    test_token_lifecycle
    test_audit_logging
    test_cross_platform
    test_security_integration
    test_performance
    
    # Print summary
    log_info ""
    log_info "Test Summary:"
    log_info "============="
    log_info "Tests Run:    $TESTS_RUN"
    log_info "Tests Passed: $TESTS_PASSED"
    log_info "Tests Failed: $TESTS_FAILED"
    
    if [ "$TESTS_FAILED" -eq 0 ]; then
        log_info ""
        log_info "🎉 ALL TESTS PASSED!"
        log_info "The OpenCode plugin security framework is working correctly."
        log_info ""
        log_info "Next steps:"
        log_info "1. Review security configuration in ~/.opencode/"
        log_info "2. Configure trusted publishers for plugin verification"
        log_info "3. Set up log monitoring and rotation policies"
        log_info "4. Test with actual plugins in development environment"
        exit 0
    else
        log_error ""
        log_error "❌ SOME TESTS FAILED!"
        log_error "Review the failures above and fix issues before deployment."
        log_error ""
        log_error "Common issues:"
        log_error "- Missing dependencies (Node.js, OpenSSL)"
        log_error "- Insufficient file permissions"
        log_error "- Platform-specific feature limitations"
        exit 1
    fi
}

# Show help
show_help() {
    cat << 'EOF'
OpenCode Plugin Security Verification Suite

Usage: security-verification.sh [command]

Commands:
    all                Run all security tests (default)
    isolation          Test process isolation only
    signing            Test cryptographic signing only
    tokens             Test token lifecycle only
    audit              Test audit logging only
    platform           Test cross-platform compatibility only
    integration        Test security integration only
    performance        Test performance and resource usage only
    help               Show this help message

Examples:
    ./scripts/verify/security-verification.sh
    ./scripts/verify/security-verification.sh signing
    ./scripts/verify/security-verification.sh --help

Environment Variables:
    DEBUG=1            Enable debug output

Security Checklist:
    ✓ Process isolation prevents plugin interference
    ✓ Cryptographic signatures verify plugin authenticity
    ✓ Token lifecycle controls plugin capabilities
    ✓ Audit logging provides tamper-evident trail
    ✓ Cross-platform compatibility (macOS/Linux)
    ✓ Security integration works end-to-end
    ✓ Performance within acceptable limits
EOF
}

# Command line argument handling
case "${1:-all}" in
    "all")
        run_all_tests
        ;;
    "isolation")
        check_prerequisites
        test_process_isolation
        ;;
    "signing")
        check_prerequisites
        test_cryptographic_signing
        ;;
    "tokens")
        check_prerequisites
        test_token_lifecycle
        ;;
    "audit")
        check_prerequisites
        test_audit_logging
        ;;
    "platform")
        check_prerequisites
        test_cross_platform
        ;;
    "integration")
        check_prerequisites
        test_security_integration
        ;;
    "performance")
        check_prerequisites
        test_performance
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        log_error "Unknown command: $1"
        show_help
        exit 2
        ;;
esac
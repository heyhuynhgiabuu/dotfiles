# OpenCode Security Framework

## Overview

**Enterprise-grade security framework** for OpenCode plugins, fully consolidated into a single, maintainable location. This framework provides comprehensive security controls while preserving existing plugin functionality.

## 📁 Framework Structure

```
opencode/security-framework/
├── 📄 README.md                    # This comprehensive guide
├── 🔒 secure-loader.js             # Main security wrapper
├── 🧪 test-secure-plugin.js        # Integration test suite
├── 🔍 security-verification.sh     # Comprehensive security tests
├── 📁 audit/                       # Audit logging system
│   └── logger.js                   # Tamper-evident logging
├── 📁 token/                       # Token lifecycle management
│   ├── service.js                  # JWT-style capability tokens
│   ├── keys.js                     # Cryptographic key management
│   └── revocation_store.js         # Token revocation
├── 📁 tools/                       # Signing and verification
│   ├── sign-manifest.js            # Plugin manifest signing
│   └── verify-manifest.js          # Signature verification
├── 📁 keys/                        # Key management utilities
│   └── key-management.sh           # Ed25519/RSA key generation
└── 📁 process-isolation/           # Process sandboxing
    ├── worker_host.js              # Plugin process manager
    ├── worker_child.js             # Isolated plugin runtime
    ├── sandbox_utils.sh            # Resource limits
    ├── test_isolation.js           # Test suite
    └── README.md                   # Process isolation docs
```

## 🚀 Quick Start

### Test the Framework
```bash
cd /Users/killerkidbo/dotfiles
node opencode/security-framework/test-secure-plugin.js
```

### Basic Usage
```javascript
// Import from consolidated location
import { SecurePluginLoader, loadUnifiedPlugin } from './opencode/security-framework/secure-loader.js';

// Quick usage - basic security
const plugin = await loadUnifiedPlugin({
  isolated: false,         // No process isolation
  verifySignatures: false, // Skip signature verification
  auditLog: false         // Disable audit logging
});

// Full security
const loader = new SecurePluginLoader({
  isolated: true,         // Enable process isolation
  verifySignatures: true, // Verify plugin signatures
  auditLog: true          // Full audit logging
});
```

## 🛡️ Security Features

### Core Security Components
1. **🔐 Process Isolation** - Sandboxed plugin execution with resource limits
2. **✍️ Cryptographic Signing** - Ed25519/RSA plugin authentication  
3. **🎫 Token Access Control** - JWT-style capability enforcement
4. **📊 Audit Logging** - Tamper-evident operation tracking
5. **🚫 File Access Control** - Block sensitive files (.env, secrets)

### Security Architecture
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│ OpenCode Client │───▶│ Secure Loader    │───▶│ Unified Plugin  │
└─────────────────┘    │ - Token Auth     │    │ - GPT-5 Config  │
                       │ - Audit Log      │    │ - Notifications │
                       │ - Capability     │    │ - VectorCode    │
                       │ - Process Isolation│    │ - File Security │
                       └──────────────────┘    └─────────────────┘
                                │                       │
                                ▼                       ▼
                       ┌──────────────────┐    ┌─────────────────┐
                       │ Security Layer   │    │ Original Logic  │
                       │ - File blocking  │    │ - Event handling│ 
                       │ - Token validation│    │ - Tool intercept│
                       │ - HMAC logging   │    │ - Notifications │
                       └──────────────────┘    └─────────────────┘
```

## 📋 Verification & Testing

### Comprehensive Testing
```bash
# Main integration test
node opencode/security-framework/test-secure-plugin.js

# Comprehensive security verification
cd opencode/security-framework && ./security-verification.sh

# Individual component tests
./security-verification.sh platform  # Cross-platform compatibility
./security-verification.sh signing   # Cryptographic signing
./security-verification.sh tokens    # Token lifecycle

# Process isolation test
node process-isolation/test_isolation.js

# Key management test
./keys/key-management.sh gen-ed25519 test-consolidated
```

### Expected Results
```
🎉 Security Integration Test Completed Successfully!
📋 Test Results:
   ✅ Plugin loading with security framework
   ✅ Capability enforcement active
   ✅ Audit logging functional
   ✅ Security controls working
   ✅ Existing functionality preserved
```

## 🔧 Production Deployment

### Recommended: Basic Security (Immediate Use)
```javascript
const loader = new SecurePluginLoader({
  isolated: false,         // In-process execution
  verifySignatures: false, // File-based trust
  auditLog: true          // Local audit logging
});
```
**Benefits**: Immediate deployment, file access security, audit trails  
**Trade-offs**: No process isolation, no cryptographic verification

### Enhanced: Process Isolation
```javascript
const loader = new SecurePluginLoader({
  isolated: true,          // Sandboxed execution
  verifySignatures: false, // File-based trust
  auditLog: true          // Local audit logging
});
```
**Benefits**: Process separation, resource limits, better isolation  
**Trade-offs**: Performance overhead, complexity

### Enterprise: Full Security
```javascript
const loader = new SecurePluginLoader({
  isolated: true,         // Sandboxed execution
  verifySignatures: true, // Cryptographic verification
  auditLog: true         // Full audit logging
});
```
**Benefits**: Maximum security, plugin authenticity, comprehensive auditing  
**Trade-offs**: Requires key management, signing workflow

## 🔄 Migration History

### Before (Scattered Files)
```
❌ security/audit/logger.js
❌ security/token/{service.js, keys.js, revocation_store.js}  
❌ tools/{sign-manifest.js, verify-manifest.js}
❌ scripts/keys/key-management.sh
❌ scripts/process_isolation/{worker_*.js, sandbox_utils.sh}
```

### After (Consolidated)
```
✅ opencode/security-framework/
   ├── All 14 components in organized subdirectories
   ├── Self-contained with relative imports
   ├── Easy maintenance and deployment
   └── Comprehensive testing suite included
```

## 🏗️ Integration Benefits

### ✅ **Single Location Maintenance**
- All security components in one directory
- Easy to backup, version, and deploy
- No scattered files across multiple directories

### ✅ **Self-Contained Framework**
- All dependencies use relative paths within framework
- No external references to scattered directories
- Framework can be moved or copied as a complete unit

### ✅ **Zero Breaking Changes**
- Existing `unified.js` plugin works unchanged
- Optional security - use features only when needed
- Cross-platform compatibility (macOS and Linux)

## 🔍 Manual Verification Steps

### 1. Verify File Access Security
```bash
# Test should block sensitive file access
node -e "
const plugin = require('./opencode/plugin/unified.js');
const instance = await plugin.UnifiedDotfilesPlugin({});
try {
  await instance['tool.execute.before'](
    {tool: 'read'}, 
    {args: {filePath: '.env'}}
  );
  console.log('❌ FAIL: Should block .env access');
} catch(e) {
  console.log('✅ PASS: Blocked sensitive file:', e.message);
}
"
```

### 2. Verify Cross-Platform Compatibility
```bash
# macOS test
uname -s  # Should show: Darwin
node opencode/security-framework/test-secure-plugin.js

# Linux test (if available)
uname -s  # Should show: Linux  
node opencode/security-framework/test-secure-plugin.js
```

### 3. Verify Audit Logging
```bash
# Check audit logs are created
ls -la ~/.opencode/logs/
# Should show: audit.jsonl, .audit_hmac_key

# View recent audit events
tail -5 ~/.opencode/logs/audit.jsonl
# Should show JSON log entries with HMAC signatures
```

### 4. Test Key Management
```bash
# Generate test keys
./keys/key-management.sh gen-ed25519 test-integration

# Verify key files created
ls -la ~/.opencode/keys/test-integration*
# Should show: private key (600), public key, metadata
```

## 🚨 Troubleshooting

### Common Issues
- **Key Management**: Ed25519 PEM conversion requires manual steps
- **Token Dependencies**: TokenService requires proper audit logger configuration
- **Cross-Platform**: macOS uses `osascript`, Linux uses `notify-send` for notifications

### Solutions
- Use RSA keys or update key management for proper Ed25519 PEM output
- Initialize TokenService with proper audit logger or use simplified validation
- Platform-specific notification handlers are built-in

## 📊 Security Benefits Achieved

1. **File Access Control** - Blocks access to `.env`, `secret`, `private` files
2. **Process Isolation** - Optional sandboxing for dangerous operations
3. **Audit Trails** - Tamper-evident logging of all plugin operations
4. **Capability Enforcement** - Token-based permission system
5. **Plugin Authenticity** - Cryptographic signature verification
6. **Cross-Platform Security** - POSIX-compliant security controls

## 🔧 Integration with OpenCode Workflow

### Current State
- ✅ `opencode/plugin/unified.js` continues to work unchanged
- ✅ Security framework ready for integration
- ✅ Cross-platform compatibility maintained
- ✅ No new software dependencies required

### Next Steps for Full Integration
1. **Update OpenCode plugin loader** - Integrate `SecurePluginLoader` with main OpenCode system
2. **Configure capability policies** - Define specific permissions for plugin operations  
3. **Set up production keys** - Generate and distribute official signing keys
4. **Enable audit monitoring** - Configure log analysis and alerting

The OpenCode security framework provides **enterprise-grade plugin security** with **simplified maintenance** as a single, consolidated module while preserving all existing OpenCode functionality.
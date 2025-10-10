# OpenCode Plugin Process Isolation Framework

**Security-first plugin sandboxing using Node.js child processes with privilege dropping and resource limits.**

## 🔒 Security Architecture

### Process Isolation Model
- **One process per plugin** - Complete memory and execution isolation
- **Privilege dropping** - Worker processes run with minimal privileges  
- **Resource limits** - Memory, CPU, file descriptor constraints
- **Secure IPC** - JSON-RPC message passing with validation
- **Filesystem sandboxing** - Working directory restrictions and whitelists

### Threat Model Coverage
- ✅ **Code injection** - Isolated processes prevent cross-plugin contamination
- ✅ **Privilege escalation** - Worker processes drop privileges on startup
- ✅ **Resource exhaustion** - ulimit enforcement prevents DoS attacks
- ✅ **Data exfiltration** - IPC validation and network controls limit data flows
- ✅ **Filesystem attacks** - Path traversal blocked by directory sandboxing

## 📁 Components

```bash
scripts/process_isolation/
├── worker_host.js          # Main process - spawns and manages plugin workers
├── worker_child.js         # Worker process runtime - loads and executes plugins
├── policies.js             # Security policies and capability definitions
├── sandbox_utils.sh        # POSIX helper scripts for resource limits
├── test_isolation.js       # Test suite for isolation verification
└── README.md              # This documentation
```

## 🚀 Usage

### Basic Plugin Execution
```javascript
const PluginHost = require('./worker_host');

const host = new PluginHost({
  maxWorkers: 5,
  workerTimeout: 30000,
  resourceLimits: {
    memory: 128,      // MB
    cpuTime: 10,      // seconds
    fileDescriptors: 50
  }
});

// Load and execute plugin in isolated process
const result = await host.executePlugin('notification', 'sendAlert', {
  message: 'Build completed',
  level: 'info'
});
```

### Security Configuration
```javascript
// Plugin-specific security policies
const policies = {
  'notification': {
    capabilities: ['notify'],
    network: false,
    filesystem: { whitelist: ['/tmp/notifications'] },
    resources: { memory: 64, cpuTime: 5 }
  },
  'env-protection': {
    capabilities: ['read_env'],
    network: false,
    filesystem: { readonly: true },
    resources: { memory: 32, cpuTime: 2 }
  }
};
```

## 🔧 Installation & Setup

### Prerequisites
- Node.js v16+ (built-in child_process support)
- POSIX-compliant shell (macOS/Linux)
- No additional dependencies required

### Setup Commands
```bash
# Make scripts executable
chmod +x scripts/process_isolation/*.sh

# Verify cross-platform compatibility
./scripts/process_isolation/sandbox_utils.sh verify

# Run isolation test suite
node scripts/process_isolation/test_isolation.js
```

## ✅ Security Verification

### Manual Verification Checklist

1. **Process Isolation Verification**
   ```bash
   # Start plugin host and verify separate processes
   node scripts/process_isolation/test_isolation.js
   ps aux | grep "worker_child" # Should show isolated worker processes
   ```

2. **Resource Limit Testing**
   ```bash
   # Test memory limits
   ./scripts/process_isolation/test_limits.sh memory
   
   # Test CPU limits  
   ./scripts/process_isolation/test_limits.sh cpu
   ```

3. **IPC Security Testing**
   ```bash
   # Test message validation
   node -e "require('./test_isolation').testIPCValidation()"
   
   # Test privilege dropping
   ./scripts/process_isolation/test_privileges.sh
   ```

4. **Cross-Platform Verification**
   ```bash
   # macOS verification
   uname -s | grep Darwin && ./sandbox_utils.sh verify
   
   # Linux verification  
   uname -s | grep Linux && ./sandbox_utils.sh verify
   ```

### Expected Security Behaviors

✅ **Plugin crashes don't affect host process**  
✅ **Memory exhaustion kills worker, not host**  
✅ **CPU limits terminate runaway plugins**  
✅ **File access restricted to whitelist**  
✅ **Network access controlled by capability**  
✅ **IPC messages validated and size-limited**

## 🛡️ Security Limitations & Mitigations

### Platform Limitations
- **chroot requires root** - Using working directory restrictions instead
- **Full network isolation** - Requires system-level firewall rules
- **Complete filesystem isolation** - Limited by Node.js capabilities

### Compensating Controls
- **Capability-based API restrictions** - Worker throws on unauthorized operations
- **Resource monitoring** - Host monitors worker resource usage
- **Graceful degradation** - System remains functional if isolation features unavailable
- **Comprehensive logging** - All security events logged for audit

## 🔍 Troubleshooting

### Common Issues

**Worker processes not starting**
```bash
# Check permissions
ls -la scripts/process_isolation/worker_child.js
chmod +x scripts/process_isolation/worker_child.js
```

**Resource limits not enforced**
```bash
# Verify ulimit support
ulimit -a
./sandbox_utils.sh test-limits
```

**IPC communication failures**
```bash
# Test message passing
node -e "require('./test_isolation').testBasicIPC()"
```

### Security Audit Commands
```bash
# Verify no shared memory segments
ipcs -m | grep -v "key"

# Check process tree isolation
pstree -p $(pgrep node)

# Monitor resource usage
top -p $(pgrep -f worker_child)
```

## 📋 Compliance Notes

- **SOC2**: Process isolation and resource controls meet security requirements
- **PCI**: Data isolation prevents cross-plugin contamination
- **GDPR**: Process boundaries limit data access scope
- **OWASP**: Addresses insecure design through defense-in-depth

## 🔗 Integration

### OpenCode Plugin Integration
```javascript
// Update opencode/plugin/loader.js to use process isolation
const PluginHost = require('../scripts/process_isolation/worker_host');

const secureLoader = {
  async loadPlugin(manifestPath) {
    return host.executePlugin(pluginId, 'initialize', { manifestPath });
  }
};
```

### Manual Verification Steps (Per Repo Guidelines)
1. **Load isolation framework without errors**
2. **Verify cross-platform compatibility (macOS/Linux)**  
3. **Test resource limit enforcement**
4. **Confirm privilege dropping works**
5. **Validate IPC security controls**
6. **Check process cleanup on termination**

---

**Next Steps**: Run verification tests and integrate with existing OpenCode plugin system.
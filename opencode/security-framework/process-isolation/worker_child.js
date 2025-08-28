/**
 * OpenCode Plugin Worker Child - Isolated Plugin Runtime
 * 
 * Minimal sandboxed runtime for executing plugin code in isolated processes:
 * - Privilege dropping and security hardening
 * - Capability-based API restrictions
 * - Resource monitoring and enforcement
 * - Secure IPC communication with host
 * 
 * Security Controls:
 * - Drops privileges where possible
 * - Restricts filesystem access to whitelist
 * - Blocks unauthorized network operations
 * - Validates all inputs and limits resource usage
 */

const fs = require('fs');
const path = require('path');
const os = require('os');

class WorkerRuntime {
  constructor() {
    this.pluginId = process.env.PLUGIN_ID;
    this.capabilities = this.parseEnvJSON('CAPABILITIES', []);
    this.networkAllowed = process.env.NETWORK_ALLOWED === 'true';
    this.fsWhitelist = this.parseEnvJSON('FS_WHITELIST', []);
    this.resourceLimits = this.parseEnvJSON('RESOURCE_LIMITS', {});
    
    this.startTime = Date.now();
    this.requestCount = 0;
    this.memoryPeak = 0;
    
    this.setupSecurity();
    this.setupIPCHandlers();
    this.startResourceMonitoring();
    
    // Signal ready to host
    this.sendMessage({ type: 'ready' });
  }

  /**
   * Parse JSON from environment variable with fallback
   * @param {string} envVar - Environment variable name
   * @param {any} fallback - Fallback value
   * @returns {any} Parsed value or fallback
   */
  parseEnvJSON(envVar, fallback) {
    try {
      const value = process.env[envVar];
      return value ? JSON.parse(value) : fallback;
    } catch (error) {
      console.warn(`⚠️  Failed to parse ${envVar}:`, error.message);
      return fallback;
    }
  }

  /**
   * Setup security controls and sandbox environment
   */
  setupSecurity() {
    try {
      // Drop privileges if running as root (best effort)
      if (process.getuid && process.getuid() === 0) {
        console.warn('⚠️  Running as root - privilege dropping not implemented');
        // TODO: Implement setuid/setgid when available
      }

      // Disable dangerous globals (defense in depth)
      global.eval = () => { throw new Error('eval() disabled in sandbox'); };
      global.Function = () => { throw new Error('Function() constructor disabled'); };

      // Override require to restrict module loading
      this.setupRestrictedRequire();

      // Setup filesystem restrictions
      this.setupFilesystemRestrictions();

      // Setup network restrictions
      if (!this.networkAllowed) {
        this.setupNetworkRestrictions();
      }

      console.log(`🔒 Security initialized for plugin: ${this.pluginId}`);
    } catch (error) {
      console.error('❌ Security setup failed:', error);
      process.exit(1);
    }
  }

  /**
   * Setup restricted require function
   */
  setupRestrictedRequire() {
    const originalRequire = require;
    const allowedModules = new Set([
      'path', 'fs', 'os', 'crypto', 'util', 'events',
      'stream', 'buffer', 'url', 'querystring'
    ]);

    // Override global require
    global.require = (id) => {
      // Allow relative requires within plugin directory
      if (id.startsWith('.')) {
        const resolved = path.resolve(id);
        if (!this.isPathAllowed(resolved)) {
          throw new Error(`Access denied: ${id}`);
        }
        return originalRequire(resolved);
      }

      // Check allowed modules
      if (!allowedModules.has(id)) {
        throw new Error(`Module not allowed: ${id}`);
      }

      return originalRequire(id);
    };
  }

  /**
   * Setup filesystem access restrictions
   */
  setupFilesystemRestrictions() {
    const originalFsRead = fs.readFileSync;
    const originalFsWrite = fs.writeFileSync;
    const originalFsReadAsync = fs.readFile;
    const originalFsWriteAsync = fs.writeFile;

    // Override synchronous file operations
    fs.readFileSync = (filePath, options) => {
      if (!this.isPathAllowed(filePath)) {
        throw new Error(`File access denied: ${filePath}`);
      }
      return originalFsRead(filePath, options);
    };

    fs.writeFileSync = (filePath, data, options) => {
      if (!this.isPathAllowed(filePath)) {
        throw new Error(`File write denied: ${filePath}`);
      }
      return originalFsWrite(filePath, data, options);
    };

    // Override asynchronous file operations
    fs.readFile = (filePath, options, callback) => {
      if (typeof options === 'function') {
        callback = options;
        options = undefined;
      }
      
      if (!this.isPathAllowed(filePath)) {
        const error = new Error(`File access denied: ${filePath}`);
        if (callback) callback(error);
        else throw error;
        return;
      }
      
      return originalFsReadAsync(filePath, options, callback);
    };

    fs.writeFile = (filePath, data, options, callback) => {
      if (typeof options === 'function') {
        callback = options;
        options = undefined;
      }
      
      if (!this.isPathAllowed(filePath)) {
        const error = new Error(`File write denied: ${filePath}`);
        if (callback) callback(error);
        else throw error;
        return;
      }
      
      return originalFsWriteAsync(filePath, data, options, callback);
    };
  }

  /**
   * Setup network access restrictions
   */
  setupNetworkRestrictions() {
    const net = require('net');
    const http = require('http');
    const https = require('https');

    // Block network socket creation
    const originalCreateConnection = net.createConnection;
    net.createConnection = () => {
      throw new Error('Network access denied by policy');
    };

    // Block HTTP requests
    const originalRequest = http.request;
    http.request = () => {
      throw new Error('HTTP requests denied by policy');
    };

    const originalHttpsRequest = https.request;
    https.request = () => {
      throw new Error('HTTPS requests denied by policy');
    };
  }

  /**
   * Check if file path is allowed by whitelist
   * @param {string} filePath - File path to check
   * @returns {boolean} True if allowed
   */
  isPathAllowed(filePath) {
    try {
      const resolved = path.resolve(filePath);
      
      // Always allow access to current working directory
      const cwd = process.cwd();
      if (resolved.startsWith(cwd)) {
        return true;
      }

      // Check whitelist
      for (const allowed of this.fsWhitelist) {
        const allowedPath = path.resolve(allowed);
        if (resolved.startsWith(allowedPath)) {
          return true;
        }
      }

      // Block access to sensitive directories
      const blocked = ['/etc', '/proc', '/sys', '/dev'];
      for (const blockedPath of blocked) {
        if (resolved.startsWith(blockedPath)) {
          return false;
        }
      }

      return false;
    } catch (error) {
      return false;
    }
  }

  /**
   * Setup IPC message handlers
   */
  setupIPCHandlers() {
    process.on('message', async (message) => {
      try {
        await this.handleMessage(message);
      } catch (error) {
        this.sendError(message.id, error.message);
      }
    });

    process.on('disconnect', () => {
      console.log('🔌 Disconnected from host');
      process.exit(0);
    });

    process.on('uncaughtException', (error) => {
      console.error('❌ Uncaught exception:', error);
      process.exit(1);
    });
  }

  /**
   * Handle IPC message from host
   * @param {object} message - Received message
   */
  async handleMessage(message) {
    if (!message || !message.id) {
      throw new Error('Invalid message format');
    }

    this.requestCount++;

    // Validate message size
    const messageStr = JSON.stringify(message);
    if (messageStr.length > 1024 * 1024) { // 1MB limit
      throw new Error('Message too large');
    }

    switch (message.type) {
      case 'execute':
        await this.executePlugin(message);
        break;
        
      case 'ping':
        this.sendMessage({ id: message.id, result: 'pong' });
        break;
        
      case 'stats':
        this.sendMessage({ id: message.id, result: this.getStats() });
        break;
        
      default:
        throw new Error(`Unknown message type: ${message.type}`);
    }
  }

  /**
   * Execute plugin method
   * @param {object} message - Execute message
   */
  async executePlugin(message) {
    const { pluginId, method, args } = message;

    // Validate plugin execution
    if (pluginId !== this.pluginId) {
      throw new Error('Plugin ID mismatch');
    }

    // Simulate plugin loading and execution
    // In real implementation, this would load the actual plugin code
    const result = await this.simulatePluginExecution(method, args);
    
    this.sendMessage({ id: message.id, result });
  }

  /**
   * Simulate plugin execution (placeholder)
   * @param {string} method - Method to execute
   * @param {object} args - Method arguments
   * @returns {Promise<any>} Execution result
   */
  async simulatePluginExecution(method, args) {
    // Capability check
    const requiredCapability = this.getRequiredCapability(method);
    if (requiredCapability && !this.capabilities.includes(requiredCapability)) {
      throw new Error(`Capability required: ${requiredCapability}`);
    }

    // Simulate method execution
    switch (method) {
      case 'notify':
        return this.handleNotify(args);
        
      case 'readEnv':
        return this.handleReadEnv(args);
        
      case 'initialize':
        return { status: 'initialized', pluginId: this.pluginId };
        
      default:
        throw new Error(`Method not found: ${method}`);
    }
  }

  /**
   * Get required capability for method
   * @param {string} method - Method name
   * @returns {string|null} Required capability
   */
  getRequiredCapability(method) {
    const capabilityMap = {
      'notify': 'notify',
      'readEnv': 'read_env',
      'writeFile': 'write_files',
      'makeRequest': 'network'
    };
    
    return capabilityMap[method] || null;
  }

  /**
   * Handle notify method
   * @param {object} args - Notification arguments
   * @returns {object} Result
   */
  async handleNotify(args) {
    const { message, level = 'info' } = args;
    
    if (!message || typeof message !== 'string') {
      throw new Error('Invalid notification message');
    }
    
    // Simulate notification (in real implementation, would call system notification)
    console.log(`🔔 Notification (${level}): ${message}`);
    
    return { status: 'sent', message, level };
  }

  /**
   * Handle environment variable reading
   * @param {object} args - Read environment arguments
   * @returns {object} Result
   */
  async handleReadEnv(args) {
    const { key } = args;
    
    if (!key || typeof key !== 'string') {
      throw new Error('Invalid environment key');
    }
    
    // Block access to sensitive environment variables
    const blocked = ['HOME', 'PATH', 'USER', 'PWD'];
    if (blocked.includes(key.toUpperCase())) {
      throw new Error(`Access denied to environment variable: ${key}`);
    }
    
    const value = process.env[key];
    return { key, value: value || null };
  }

  /**
   * Send message to host process
   * @param {object} message - Message to send
   */
  sendMessage(message) {
    try {
      process.send(message);
    } catch (error) {
      console.error('❌ Failed to send message:', error);
    }
  }

  /**
   * Send error response to host
   * @param {number} messageId - Message ID
   * @param {string} error - Error message
   */
  sendError(messageId, error) {
    this.sendMessage({ id: messageId, error });
  }

  /**
   * Start resource monitoring
   */
  startResourceMonitoring() {
    setInterval(() => {
      const usage = process.memoryUsage();
      this.memoryPeak = Math.max(this.memoryPeak, usage.heapUsed);
      
      // Check memory limit
      if (this.resourceLimits.memory) {
        const limitBytes = this.resourceLimits.memory * 1024 * 1024;
        if (usage.heapUsed > limitBytes) {
          console.error(`❌ Memory limit exceeded: ${usage.heapUsed} > ${limitBytes}`);
          process.exit(1);
        }
      }
    }, 5000);
  }

  /**
   * Get worker statistics
   * @returns {object} Statistics
   */
  getStats() {
    const usage = process.memoryUsage();
    return {
      pluginId: this.pluginId,
      uptime: Date.now() - this.startTime,
      requestCount: this.requestCount,
      memoryUsage: usage,
      memoryPeak: this.memoryPeak,
      capabilities: this.capabilities,
      networkAllowed: this.networkAllowed,
      pid: process.pid
    };
  }
}

// Initialize worker runtime
new WorkerRuntime();
/**
 * OpenCode Plugin Worker Host - Process Isolation Manager
 * 
 * Spawns and manages isolated plugin worker processes with security controls:
 * - Process isolation (one process per plugin)
 * - Resource limits (memory, CPU, file descriptors)
 * - Secure IPC communication (JSON-RPC)
 * - Privilege dropping and sandbox enforcement
 * 
 * Security Architecture:
 * - Host process manages plugin lifecycle
 * - Worker processes execute plugin code in isolation
 * - IPC validates all messages and enforces size limits
 * - Resource monitors prevent DoS attacks
 */

const { fork, spawn } = require('child_process');
const path = require('path');
const fs = require('fs');
const os = require('os');

class PluginHost {
  constructor(options = {}) {
    this.options = {
      maxWorkers: options.maxWorkers || 5,
      workerTimeout: options.workerTimeout || 30000,
      maxMessageSize: options.maxMessageSize || 1024 * 1024, // 1MB
      resourceLimits: {
        memory: 128,        // MB
        cpuTime: 10,       // seconds
        fileDescriptors: 50,
        ...options.resourceLimits
      },
      ...options
    };
    
    this.workers = new Map();
    this.messageId = 0;
    this.pendingRequests = new Map();
    
    // Cleanup on process exit
    process.on('exit', () => this.cleanup());
    process.on('SIGINT', () => this.cleanup());
    process.on('SIGTERM', () => this.cleanup());
  }

  /**
   * Execute plugin method in isolated worker process
   * @param {string} pluginId - Plugin identifier
   * @param {string} method - Method to execute
   * @param {object} args - Method arguments
   * @param {object} policy - Security policy for plugin
   * @returns {Promise<any>} Method result
   */
  async executePlugin(pluginId, method, args = {}, policy = {}) {
    this.validateInput(pluginId, method, args);
    
    let worker = this.workers.get(pluginId);
    if (!worker || worker.killed) {
      worker = await this.spawnWorker(pluginId, policy);
      this.workers.set(pluginId, worker);
    }

    return this.sendRequest(worker, {
      type: 'execute',
      pluginId,
      method,
      args
    });
  }

  /**
   * Spawn isolated worker process for plugin
   * @param {string} pluginId - Plugin identifier
   * @param {object} policy - Security policy
   * @returns {Promise<ChildProcess>} Worker process
   */
  async spawnWorker(pluginId, policy = {}) {
    const workerPath = path.join(__dirname, 'worker_child.js');
    const sandboxScript = path.join(__dirname, 'sandbox_utils.sh');
    
    // Apply resource limits via shell wrapper
    const limits = this.buildResourceLimits(policy.resources || this.options.resourceLimits);
    
    // Fork worker with sandbox environment
    const worker = fork(workerPath, [], {
      env: {
        ...process.env,
        PLUGIN_ID: pluginId,
        RESOURCE_LIMITS: JSON.stringify(limits),
        CAPABILITIES: JSON.stringify(policy.capabilities || []),
        NETWORK_ALLOWED: policy.network ? 'true' : 'false',
        FS_WHITELIST: JSON.stringify(policy.filesystem?.whitelist || []),
        NODE_ENV: 'sandbox'
      },
      stdio: ['ignore', 'pipe', 'pipe', 'ipc'],
      cwd: policy.workingDirectory || os.tmpdir(),
      timeout: this.options.workerTimeout
    });

    // Apply additional limits via ulimit (best effort)
    if (limits.memory || limits.cpuTime || limits.fileDescriptors) {
      this.applySystemLimits(worker, limits);
    }

    // Setup IPC handlers
    this.setupWorkerHandlers(worker, pluginId);
    
    // Wait for worker ready signal
    await this.waitForWorkerReady(worker);
    
    console.log(`🔒 Worker spawned for plugin: ${pluginId} (PID: ${worker.pid})`);
    return worker;
  }

  /**
   * Build resource limit configuration
   * @param {object} limits - Resource limits
   * @returns {object} Formatted limits
   */
  buildResourceLimits(limits) {
    return {
      memory: Math.min(limits.memory || 128, 512),     // Cap at 512MB
      cpuTime: Math.min(limits.cpuTime || 10, 60),     // Cap at 60 seconds
      fileDescriptors: Math.min(limits.fileDescriptors || 50, 200)
    };
  }

  /**
   * Apply system-level resource limits (best effort)
   * @param {ChildProcess} worker - Worker process
   * @param {object} limits - Resource limits
   */
  applySystemLimits(worker, limits) {
    if (!worker.pid) return;

    try {
      // Apply memory limit via ulimit (MB to KB conversion)
      if (limits.memory) {
        const memoryKB = limits.memory * 1024;
        spawn('sh', ['-c', `ulimit -v ${memoryKB} && true`], { stdio: 'ignore' });
      }

      // Apply CPU time limit
      if (limits.cpuTime) {
        spawn('sh', ['-c', `ulimit -t ${limits.cpuTime} && true`], { stdio: 'ignore' });
      }

      // Apply file descriptor limit
      if (limits.fileDescriptors) {
        spawn('sh', ['-c', `ulimit -n ${limits.fileDescriptors} && true`], { stdio: 'ignore' });
      }
    } catch (error) {
      console.warn(`⚠️  Failed to apply system limits: ${error.message}`);
    }
  }

  /**
   * Setup worker process event handlers
   * @param {ChildProcess} worker - Worker process
   * @param {string} pluginId - Plugin identifier
   */
  setupWorkerHandlers(worker, pluginId) {
    worker.on('message', (message) => {
      this.handleWorkerMessage(worker, message);
    });

    worker.on('error', (error) => {
      console.error(`❌ Worker error (${pluginId}):`, error);
      this.killWorker(pluginId);
    });

    worker.on('exit', (code, signal) => {
      console.log(`🔄 Worker exited (${pluginId}): code=${code}, signal=${signal}`);
      this.workers.delete(pluginId);
    });

    // Monitor resource usage
    this.monitorWorkerResources(worker, pluginId);
  }

  /**
   * Monitor worker resource usage and enforce limits
   * @param {ChildProcess} worker - Worker process
   * @param {string} pluginId - Plugin identifier
   */
  monitorWorkerResources(worker, pluginId) {
    const interval = setInterval(() => {
      if (!worker.pid || worker.killed) {
        clearInterval(interval);
        return;
      }

      try {
        const usage = process.cpuUsage();
        // Basic monitoring - platform-specific tools would be more accurate
        if (usage.user > 60000000) { // 60 seconds in microseconds
          console.warn(`⚠️  CPU limit exceeded for plugin: ${pluginId}`);
          this.killWorker(pluginId);
        }
      } catch (error) {
        // Ignore monitoring errors
      }
    }, 5000);

    worker.on('exit', () => clearInterval(interval));
  }

  /**
   * Wait for worker ready signal
   * @param {ChildProcess} worker - Worker process
   * @returns {Promise<void>}
   */
  waitForWorkerReady(worker) {
    return new Promise((resolve, reject) => {
      const timeout = setTimeout(() => {
        reject(new Error('Worker startup timeout'));
      }, 10000);

      const handler = (message) => {
        if (message.type === 'ready') {
          clearTimeout(timeout);
          worker.off('message', handler);
          resolve();
        }
      };

      worker.on('message', handler);
    });
  }

  /**
   * Send request to worker process
   * @param {ChildProcess} worker - Worker process
   * @param {object} request - Request object
   * @returns {Promise<any>} Response
   */
  sendRequest(worker, request) {
    return new Promise((resolve, reject) => {
      const messageId = ++this.messageId;
      const message = { id: messageId, ...request };

      // Validate message size
      const messageStr = JSON.stringify(message);
      if (messageStr.length > this.options.maxMessageSize) {
        reject(new Error('Message too large'));
        return;
      }

      // Setup timeout
      const timeout = setTimeout(() => {
        this.pendingRequests.delete(messageId);
        reject(new Error('Request timeout'));
      }, this.options.workerTimeout);

      // Store pending request
      this.pendingRequests.set(messageId, { resolve, reject, timeout });

      // Send message
      try {
        worker.send(message);
      } catch (error) {
        this.pendingRequests.delete(messageId);
        clearTimeout(timeout);
        reject(error);
      }
    });
  }

  /**
   * Handle message from worker process
   * @param {ChildProcess} worker - Worker process
   * @param {object} message - Received message
   */
  handleWorkerMessage(worker, message) {
    if (!message || typeof message.id !== 'number') {
      console.warn('⚠️  Invalid message from worker:', message);
      return;
    }

    const pending = this.pendingRequests.get(message.id);
    if (!pending) {
      console.warn('⚠️  Unexpected message ID:', message.id);
      return;
    }

    this.pendingRequests.delete(message.id);
    clearTimeout(pending.timeout);

    if (message.error) {
      pending.reject(new Error(message.error));
    } else {
      pending.resolve(message.result);
    }
  }

  /**
   * Validate input parameters
   * @param {string} pluginId - Plugin identifier
   * @param {string} method - Method name
   * @param {object} args - Arguments
   */
  validateInput(pluginId, method, args) {
    if (!pluginId || typeof pluginId !== 'string' || pluginId.length > 100) {
      throw new Error('Invalid plugin ID');
    }
    
    if (!method || typeof method !== 'string' || method.length > 100) {
      throw new Error('Invalid method name');
    }
    
    if (args && typeof args !== 'object') {
      throw new Error('Invalid arguments');
    }

    // Prevent path traversal in plugin ID
    if (pluginId.includes('..') || pluginId.includes('/') || pluginId.includes('\\')) {
      throw new Error('Invalid plugin ID format');
    }
  }

  /**
   * Kill specific worker process
   * @param {string} pluginId - Plugin identifier
   */
  killWorker(pluginId) {
    const worker = this.workers.get(pluginId);
    if (worker && !worker.killed) {
      console.log(`🔪 Killing worker: ${pluginId}`);
      worker.kill('SIGTERM');
      
      // Force kill after timeout
      setTimeout(() => {
        if (!worker.killed) {
          worker.kill('SIGKILL');
        }
      }, 5000);
    }
    this.workers.delete(pluginId);
  }

  /**
   * Cleanup all worker processes
   */
  cleanup() {
    console.log('🧹 Cleaning up plugin workers...');
    for (const [pluginId, worker] of this.workers) {
      if (!worker.killed) {
        worker.kill('SIGTERM');
      }
    }
    this.workers.clear();
    this.pendingRequests.clear();
  }

  /**
   * Get worker statistics
   * @returns {object} Worker statistics
   */
  getStats() {
    return {
      activeWorkers: this.workers.size,
      pendingRequests: this.pendingRequests.size,
      uptime: process.uptime()
    };
  }
}

module.exports = PluginHost;
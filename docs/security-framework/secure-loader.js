/**
 * Secure Plugin Loader for OpenCode
 * 
 * Integrates security framework with existing plugins:
 * - Process isolation for plugin execution
 * - Cryptographic signature verification
 * - Capability-based access control
 * - Audit logging for all operations
 * 
 * Usage: Import and wrap existing plugins with security layer
 */

import { readFileSync, existsSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import { spawn } from 'child_process';

const __dirname = dirname(fileURLToPath(import.meta.url));

// Import security components (CommonJS) - now from local directories
import { createRequire } from 'module';
const require = createRequire(import.meta.url);

const TokenService = require(join(__dirname, 'token/service.js'));
const AuditLogger = require(join(__dirname, 'audit/logger.js'));

/**
 * Secure Plugin Loader
 * Wraps existing plugins with security framework
 */
export class SecurePluginLoader {
  constructor(options = {}) {
    this.isolated = options.isolated ?? true;
    this.verifySignatures = options.verifySignatures ?? true;
    this.auditLog = options.auditLog ?? true;
    
    // Initialize security components
    this.tokenService = new TokenService();
    this.auditLogger = this.auditLog ? new AuditLogger() : null;
    
    // Capability mappings for OpenCode operations
    this.capabilities = {
      'chat.params': ['model:read', 'agent:configure'],
      'event': ['session:monitor', 'notification:send'], 
      'tool.execute.before': ['tool:intercept', 'file:read', 'command:execute']
    };
  }

  /**
   * Load and secure existing plugin
   */
  async loadPlugin(pluginPath, publisherId = 'opencode-official') {
    this.auditLogger?.log({
      event_type: 'plugin_load_start',
      pluginPath,
      publisherId,
      timestamp: new Date().toISOString()
    });

    try {
      // 1. Verify plugin signature if enabled
      if (this.verifySignatures) {
        await this.verifyPluginSignature(pluginPath, publisherId);
      }

      // 2. Load plugin module
      const plugin = await import(pluginPath);
      const pluginExport = plugin.UnifiedDotfilesPlugin || plugin.default;
      
      if (!pluginExport) {
        throw new Error(`Invalid plugin: no export found in ${pluginPath}`);
      }

      // 3. Wrap with security layer
      const securePlugin = await this.wrapWithSecurity(pluginExport, publisherId);
      
      this.auditLogger?.log({
        event_type: 'plugin_load_success',
        pluginPath,
        publisherId,
        timestamp: new Date().toISOString()
      });
      return securePlugin;

    } catch (error) {
      this.auditLogger?.log({
        event_type: 'plugin_load_failed',
        pluginPath,
        publisherId,
        error: error.message,
        timestamp: new Date().toISOString()
      });
      throw error;
    }
  }

  /**
   * Verify plugin cryptographic signature
   */
  async verifyPluginSignature(pluginPath, publisherId) {
    const verifyScript = join(__dirname, 'tools/verify-manifest.js');
    const manifestPath = `${pluginPath}.manifest.json`;
    
    if (!existsSync(manifestPath)) {
      throw new Error(`Plugin manifest not found: ${manifestPath}`);
    }

    return new Promise((resolve, reject) => {
      const verify = spawn('node', [verifyScript, manifestPath, publisherId], {
        stdio: 'pipe'
      });

      let output = '';
      verify.stdout.on('data', (data) => output += data);
      verify.stderr.on('data', (data) => output += data);

      verify.on('close', (code) => {
        if (code === 0) {
          resolve();
        } else {
          reject(new Error(`Signature verification failed: ${output}`));
        }
      });
    });
  }

  /**
   * Wrap plugin with security framework
   */
  async wrapWithSecurity(originalPlugin, publisherId) {
    const self = this;
    
    return async function securePluginWrapper(context) {
      // Generate capability token for this plugin session
      const capabilities = Object.values(self.capabilities).flat();
      const token = await self.tokenService.issueToken(publisherId, capabilities);
      
      // Get original plugin instance
      const pluginInstance = await originalPlugin(context);
      
      // Wrap each plugin method with security checks
      const secureInstance = {};
      
      for (const [method, handler] of Object.entries(pluginInstance)) {
        secureInstance[method] = await self.wrapMethod(method, handler, token, publisherId);
      }
      
      return secureInstance;
    };
  }

  /**
   * Wrap individual plugin method with security
   */
  async wrapMethod(methodName, originalHandler, token, publisherId) {
    const self = this;
    
    return async function secureMethodWrapper(...args) {
      const startTime = Date.now();
      
      try {
        // 1. Validate token and capabilities
        const requiredCaps = self.capabilities[methodName] || [];
        if (!await self.tokenService.validateToken(token, requiredCaps)) {
          throw new Error(`Insufficient capabilities for ${methodName}`);
        }

        // 2. Log method invocation
        self.auditLogger?.log({
          event_type: 'method_invoke',
          method: methodName,
          publisherId,
          args: self.sanitizeArgs(args),
          timestamp: new Date().toISOString()
        });

        // 3. Execute in isolation if enabled
        let result;
        if (self.isolated && self.shouldIsolate(methodName)) {
          result = await self.executeInIsolation(originalHandler, args, token);
        } else {
          result = await originalHandler.apply(this, args);
        }

        // 4. Log successful completion
        self.auditLogger?.log({
          event_type: 'method_success',
          method: methodName,
          publisherId,
          duration: Date.now() - startTime,
          timestamp: new Date().toISOString()
        });

        return result;

      } catch (error) {
        // Log security violations
        self.auditLogger?.log({
          event_type: 'method_failed',
          method: methodName,
          publisherId,
          error: error.message,
          duration: Date.now() - startTime,
          timestamp: new Date().toISOString()
        });
        throw error;
      }
    };
  }

  /**
   * Execute method in isolated process
   */
  async executeInIsolation(handler, args, token) {
    const workerScript = join(__dirname, 'process-isolation/worker_host.js');
    
    return new Promise((resolve, reject) => {
      const worker = spawn('node', [workerScript], {
        stdio: ['pipe', 'pipe', 'pipe']
      });

      const request = {
        handler: handler.toString(),
        args: this.sanitizeArgs(args),
        token
      };

      worker.stdin.write(JSON.stringify(request));
      worker.stdin.end();

      let output = '';
      worker.stdout.on('data', (data) => output += data);
      
      worker.on('close', (code) => {
        if (code === 0) {
          try {
            resolve(JSON.parse(output));
          } catch (err) {
            reject(new Error(`Invalid worker response: ${output}`));
          }
        } else {
          reject(new Error(`Worker process failed with code ${code}`));
        }
      });

      // Timeout after 30 seconds
      setTimeout(() => {
        worker.kill();
        reject(new Error('Plugin execution timeout'));
      }, 30000);
    });
  }

  /**
   * Determine if method should run in isolation
   */
  shouldIsolate(methodName) {
    // Isolate potentially dangerous operations
    const isolatedMethods = ['tool.execute.before', 'tool.execute.after'];
    return isolatedMethods.includes(methodName);
  }

  /**
   * Sanitize arguments for logging and IPC
   */
  sanitizeArgs(args) {
    return args.map(arg => {
      if (typeof arg === 'object' && arg !== null) {
        // Remove sensitive data from objects
        const sanitized = { ...arg };
        for (const key of Object.keys(sanitized)) {
          if (key.toLowerCase().includes('secret') || 
              key.toLowerCase().includes('token') ||
              key.toLowerCase().includes('password')) {
            sanitized[key] = '[REDACTED]';
          }
        }
        return sanitized;
      }
      return typeof arg === 'string' && arg.length > 1000 ? 
        arg.substring(0, 1000) + '...[TRUNCATED]' : arg;
    });
  }
}

/**
 * Convenience function to load the existing unified plugin with security
 */
export async function loadUnifiedPlugin(options = {}) {
  const loader = new SecurePluginLoader(options);
  const unifiedPath = join(__dirname, '../plugin/unified.js');
  
  return await loader.loadPlugin(unifiedPath, 'opencode-official');
}

/**
 * Create plugin manifest for existing plugin
 */
export function createManifest(pluginPath, metadata = {}) {
  const manifest = {
    name: metadata.name || 'UnifiedDotfilesPlugin',
    version: metadata.version || '1.0.0',
    publisher: metadata.publisher || 'opencode-official',
    description: metadata.description || 'Official OpenCode dotfiles plugin',
    capabilities: [
      'model:read',
      'agent:configure', 
      'session:monitor',
      'notification:send',
      'tool:intercept',
      'file:read',
      'command:execute'
    ],
    files: [pluginPath],
    createdAt: new Date().toISOString()
  };

  return JSON.stringify(manifest, null, 2);
}
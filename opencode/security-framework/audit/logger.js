const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

/**
 * OpenCode Plugin Audit Logger
 * 
 * Tamper-evident append-only audit logging with cryptographic integrity:
 * - Chained hash verification for tamper detection
 * - Structured JSON Lines format for machine processing
 * - HMAC signatures for entry authenticity
 * - Cross-platform log rotation and retention
 * - PII/secret redaction for compliance
 */

class AuditLogger {
  constructor(options = {}) {
    this.logDir = options.logDir || 
      path.join(process.env.HOME || process.cwd(), '.opencode', 'logs');
    this.logFile = options.logFile || 'audit.jsonl';
    this.maxFileSize = options.maxFileSize || 50 * 1024 * 1024; // 50MB
    this.maxAge = options.maxAge || 90 * 24 * 60 * 60 * 1000; // 90 days
    this.retentionDays = options.retentionDays || 365;
    
    // HMAC key for entry signing (in production, use KMS or secure storage)
    this.hmacKey = options.hmacKey || this.getOrCreateHmacKey();
    
    this.currentLogPath = path.join(this.logDir, this.logFile);
    this.sequence = 0;
    this.lastHash = null;
    
    this.ensureLogDirectory();
    this.initializeLogFile();
  }

  /**
   * Log an audit event
   * @param {object} event - Event to log
   * @returns {Promise<void>}
   */
  async log(event) {
    try {
      // Validate event structure
      this.validateEvent(event);
      
      // Create audit entry
      const entry = await this.createAuditEntry(event);
      
      // Check if rotation is needed
      await this.checkRotation();
      
      // Append to log file
      await this.appendEntry(entry);
      
      // Update state for next entry
      this.sequence++;
      this.lastHash = entry.entry_hash;
      
    } catch (error) {
      // Log errors to stderr to avoid infinite loops
      console.error('Audit logging failed:', error.message);
      throw error;
    }
  }

  /**
   * Create structured audit entry with integrity protection
   * @param {object} event - Raw event data
   * @returns {object} Complete audit entry
   */
  async createAuditEntry(event) {
    const timestamp = new Date().toISOString();
    const id = this.sequence + 1;
    
    // Get previous hash for chaining
    if (this.lastHash === null) {
      this.lastHash = await this.getLastEntryHash();
    }
    const prevHash = this.lastHash || '0';
    
    // Redact sensitive information
    const sanitizedData = this.redactSensitiveData(event.data || {});
    
    // Create base entry
    const baseEntry = {
      id,
      timestamp,
      prev_hash: prevHash,
      event_type: event.event_type,
      actor: event.actor || { type: 'system', id: 'unknown' },
      data: sanitizedData,
      level: event.level || 'info',
      source: 'opencode-plugin-system'
    };
    
    // Compute entry hash for integrity
    const entryHash = this.computeEntryHash(baseEntry);
    baseEntry.entry_hash = entryHash;
    
    // Sign entry with HMAC
    const signature = this.signEntry(baseEntry);
    baseEntry.signature = signature;
    
    return baseEntry;
  }

  /**
   * Append entry to current log file
   * @param {object} entry - Audit entry to append
   */
  async appendEntry(entry) {
    try {
      const entryLine = JSON.stringify(entry) + '\n';
      
      // Atomic append operation
      fs.appendFileSync(this.currentLogPath, entryLine, { mode: 0o600 });
    } catch (error) {
      throw new Error(`Failed to append audit entry: ${error.message}`);
    }
  }

  /**
   * Check if log rotation is needed and perform if necessary
   */
  async checkRotation() {
    try {
      if (!fs.existsSync(this.currentLogPath)) {
        return;
      }
      
      const stats = fs.statSync(this.currentLogPath);
      const shouldRotate = stats.size >= this.maxFileSize || 
                          (Date.now() - stats.mtime.getTime()) >= this.maxAge;
      
      if (shouldRotate) {
        await this.rotateLog();
      }
    } catch (error) {
      console.error('Log rotation check failed:', error.message);
    }
  }

  /**
   * Rotate current log file to archive
   */
  async rotateLog() {
    try {
      const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
      const archiveDir = path.join(this.logDir, 'archive');
      
      // Ensure archive directory exists
      if (!fs.existsSync(archiveDir)) {
        fs.mkdirSync(archiveDir, { recursive: true, mode: 0o700 });
      }
      
      // Create archive filename
      const archiveName = `audit-${timestamp}.jsonl`;
      const archivePath = path.join(archiveDir, archiveName);
      
      // Move current log to archive
      if (fs.existsSync(this.currentLogPath)) {
        fs.renameSync(this.currentLogPath, archivePath);
        console.log(`📦 Log rotated to: ${archivePath}`);
        
        // Create and sign checkpoint for integrity verification
        await this.createCheckpoint(archivePath);
      }
      
      // Reset sequence and hash for new log
      this.sequence = 0;
      this.lastHash = null;
      
      // Cleanup old archives
      await this.cleanupOldArchives();
      
    } catch (error) {
      console.error('Log rotation failed:', error.message);
    }
  }

  /**
   * Create signed checkpoint for archived log
   * @param {string} archivePath - Path to archived log file
   */
  async createCheckpoint(archivePath) {
    try {
      // Compute hash of entire archived log
      const logContent = fs.readFileSync(archivePath);
      const logHash = crypto.createHash('sha256').update(logContent).digest('hex');
      
      // Count entries in archive
      const entryCount = logContent.toString().split('\n').filter(line => line.trim()).length;
      
      // Create checkpoint record
      const checkpoint = {
        type: 'audit-checkpoint',
        timestamp: new Date().toISOString(),
        archive_file: path.basename(archivePath),
        archive_hash: logHash,
        entry_count: entryCount,
        final_sequence: this.sequence,
        integrity_method: 'sha256-chain-hmac'
      };
      
      // Sign checkpoint
      const checkpointHash = crypto.createHash('sha256')
        .update(JSON.stringify(checkpoint))
        .digest('hex');
      const checkpointSignature = crypto.createHmac('sha256', this.hmacKey)
        .update(checkpointHash)
        .digest('hex');
      
      checkpoint.checkpoint_hash = checkpointHash;
      checkpoint.signature = checkpointSignature;
      
      // Save checkpoint file
      const checkpointPath = archivePath.replace('.jsonl', '.checkpoint.json');
      fs.writeFileSync(checkpointPath, JSON.stringify(checkpoint, null, 2), { mode: 0o600 });
      
      console.log(`🔒 Checkpoint created: ${checkpointPath}`);
    } catch (error) {
      console.error('Checkpoint creation failed:', error.message);
    }
  }

  /**
   * Cleanup old archive files beyond retention period
   */
  async cleanupOldArchives() {
    try {
      const archiveDir = path.join(this.logDir, 'archive');
      if (!fs.existsSync(archiveDir)) {
        return;
      }
      
      const files = fs.readdirSync(archiveDir);
      const cutoffTime = Date.now() - (this.retentionDays * 24 * 60 * 60 * 1000);
      let deletedCount = 0;
      
      for (const file of files) {
        try {
          const filePath = path.join(archiveDir, file);
          const stats = fs.statSync(filePath);
          
          if (stats.mtime.getTime() < cutoffTime) {
            fs.unlinkSync(filePath);
            deletedCount++;
            console.log(`🗑️  Deleted old archive: ${file}`);
          }
        } catch (error) {
          console.warn(`Failed to cleanup ${file}:`, error.message);
        }
      }
      
      if (deletedCount > 0) {
        console.log(`🧹 Cleaned up ${deletedCount} old archive files`);
      }
    } catch (error) {
      console.error('Archive cleanup failed:', error.message);
    }
  }

  /**
   * Verify log integrity by checking hash chain
   * @param {string} logPath - Path to log file to verify
   * @returns {object} Verification result
   */
  async verifyLogIntegrity(logPath = null) {
    const targetPath = logPath || this.currentLogPath;
    
    try {
      if (!fs.existsSync(targetPath)) {
        return { valid: false, error: 'Log file not found' };
      }
      
      const content = fs.readFileSync(targetPath, 'utf8');
      const lines = content.split('\n').filter(line => line.trim());
      
      let expectedPrevHash = '0';
      let validEntries = 0;
      const errors = [];
      
      for (let i = 0; i < lines.length; i++) {
        try {
          const entry = JSON.parse(lines[i]);
          
          // Check sequence
          if (entry.id !== i + 1) {
            errors.push(`Sequence error at line ${i + 1}: expected ${i + 1}, got ${entry.id}`);
          }
          
          // Check hash chain
          if (entry.prev_hash !== expectedPrevHash) {
            errors.push(`Hash chain broken at line ${i + 1}: expected prev_hash ${expectedPrevHash}, got ${entry.prev_hash}`);
          }
          
          // Verify entry hash
          const computedHash = this.computeEntryHash({
            id: entry.id,
            timestamp: entry.timestamp,
            prev_hash: entry.prev_hash,
            event_type: entry.event_type,
            actor: entry.actor,
            data: entry.data,
            level: entry.level,
            source: entry.source
          });
          
          if (entry.entry_hash !== computedHash) {
            errors.push(`Entry hash mismatch at line ${i + 1}`);
          }
          
          // Verify signature
          const computedSignature = this.signEntry({
            ...entry,
            signature: undefined
          });
          
          if (entry.signature !== computedSignature) {
            errors.push(`Signature verification failed at line ${i + 1}`);
          }
          
          expectedPrevHash = entry.entry_hash;
          validEntries++;
          
        } catch (parseError) {
          errors.push(`Parse error at line ${i + 1}: ${parseError.message}`);
        }
      }
      
      return {
        valid: errors.length === 0,
        totalEntries: lines.length,
        validEntries,
        errors
      };
      
    } catch (error) {
      return { valid: false, error: error.message };
    }
  }

  /**
   * Compute hash for audit entry (excluding signature)
   * @param {object} entry - Entry to hash
   * @returns {string} SHA-256 hash
   */
  computeEntryHash(entry) {
    const hashableEntry = {
      id: entry.id,
      timestamp: entry.timestamp,
      prev_hash: entry.prev_hash,
      event_type: entry.event_type,
      actor: entry.actor,
      data: entry.data,
      level: entry.level || 'info',
      source: entry.source || 'opencode-plugin-system'
    };
    
    const canonical = JSON.stringify(hashableEntry, Object.keys(hashableEntry).sort());
    return crypto.createHash('sha256').update(canonical).digest('hex');
  }

  /**
   * Sign audit entry with HMAC
   * @param {object} entry - Entry to sign
   * @returns {string} HMAC signature
   */
  signEntry(entry) {
    const entryWithoutSignature = { ...entry };
    delete entryWithoutSignature.signature;
    
    const canonical = JSON.stringify(entryWithoutSignature, Object.keys(entryWithoutSignature).sort());
    return crypto.createHmac('sha256', this.hmacKey).update(canonical).digest('hex');
  }

  /**
   * Redact sensitive information from event data
   * @param {object} data - Event data
   * @returns {object} Sanitized data
   */
  redactSensitiveData(data) {
    const sensitiveKeys = new Set([
      'token', 'password', 'secret', 'key', 'private_key', 'api_key',
      'auth', 'authorization', 'credential', 'session', 'cookie'
    ]);
    
    const redacted = {};
    
    for (const [key, value] of Object.entries(data)) {
      const lowerKey = key.toLowerCase();
      const isSensitive = sensitiveKeys.has(lowerKey) || 
                         lowerKey.includes('password') || 
                         lowerKey.includes('secret') ||
                         lowerKey.includes('token');
      
      if (isSensitive && typeof value === 'string') {
        // Keep first and last few characters for debugging
        if (value.length > 8) {
          redacted[key] = `${value.substring(0, 4)}***${value.substring(value.length - 4)}`;
        } else {
          redacted[key] = '***';
        }
      } else {
        redacted[key] = value;
      }
    }
    
    return redacted;
  }

  /**
   * Validate event structure
   * @param {object} event - Event to validate
   */
  validateEvent(event) {
    if (!event || typeof event !== 'object') {
      throw new Error('Event must be an object');
    }
    
    if (!event.event_type || typeof event.event_type !== 'string') {
      throw new Error('Event must have a valid event_type');
    }
    
    if (event.actor && (!event.actor.type || !event.actor.id)) {
      throw new Error('Actor must have type and id fields');
    }
  }

  /**
   * Get last entry hash from current log file
   * @returns {string|null} Last entry hash or null if no entries
   */
  async getLastEntryHash() {
    try {
      if (!fs.existsSync(this.currentLogPath)) {
        return null;
      }
      
      const content = fs.readFileSync(this.currentLogPath, 'utf8');
      const lines = content.trim().split('\n').filter(line => line.trim());
      
      if (lines.length === 0) {
        return null;
      }
      
      const lastLine = lines[lines.length - 1];
      const lastEntry = JSON.parse(lastLine);
      this.sequence = lastEntry.id;
      
      return lastEntry.entry_hash;
    } catch (error) {
      console.warn('Failed to get last entry hash:', error.message);
      return null;
    }
  }

  /**
   * Get or create HMAC key for signing
   * @returns {string} HMAC key
   */
  getOrCreateHmacKey() {
    const keyPath = path.join(this.logDir, '.audit_hmac_key');
    
    try {
      if (fs.existsSync(keyPath)) {
        return fs.readFileSync(keyPath, 'utf8').trim();
      }
      
      // Generate new key
      const key = crypto.randomBytes(32).toString('hex');
      fs.writeFileSync(keyPath, key, { mode: 0o600 });
      console.log('🔑 Generated new audit HMAC key');
      
      return key;
    } catch (error) {
      console.warn('Failed to manage HMAC key:', error.message);
      // Fallback to deterministic key (not ideal for production)
      return crypto.createHash('sha256').update('opencode-audit-fallback').digest('hex');
    }
  }

  /**
   * Ensure log directory exists with proper permissions
   */
  ensureLogDirectory() {
    if (!fs.existsSync(this.logDir)) {
      fs.mkdirSync(this.logDir, { recursive: true, mode: 0o700 });
      console.log(`📁 Created audit log directory: ${this.logDir}`);
    }
  }

  /**
   * Initialize log file if it doesn't exist
   */
  initializeLogFile() {
    if (!fs.existsSync(this.currentLogPath)) {
      // Create empty log file with proper permissions
      fs.writeFileSync(this.currentLogPath, '', { mode: 0o600 });
      console.log(`📄 Initialized audit log: ${this.currentLogPath}`);
    }
  }

  /**
   * Get audit logger statistics
   * @returns {object} Logger statistics
   */
  getStats() {
    try {
      const stats = {
        currentLogPath: this.currentLogPath,
        sequence: this.sequence,
        lastHash: this.lastHash,
        maxFileSize: this.maxFileSize,
        retentionDays: this.retentionDays
      };
      
      if (fs.existsSync(this.currentLogPath)) {
        const fileStats = fs.statSync(this.currentLogPath);
        stats.currentFileSize = fileStats.size;
        stats.lastModified = fileStats.mtime.toISOString();
      }
      
      // Count archive files
      const archiveDir = path.join(this.logDir, 'archive');
      if (fs.existsSync(archiveDir)) {
        const archiveFiles = fs.readdirSync(archiveDir).filter(f => f.endsWith('.jsonl'));
        stats.archivedFiles = archiveFiles.length;
      } else {
        stats.archivedFiles = 0;
      }
      
      return stats;
    } catch (error) {
      return { error: error.message };
    }
  }
}

module.exports = AuditLogger;
const fs = require('fs');
const path = require('path');

/**
 * OpenCode Plugin Token Revocation Store
 * 
 * Fast token revocation checking using file-based storage:
 * - Store revoked token JTIs with expiration times
 * - Efficient lookup and cleanup of expired entries
 * - Cross-platform file-based implementation
 * - Fallback option when Redis/database unavailable
 */

class RevocationStore {
  constructor(options = {}) {
    this.storeDir = options.storeDir || 
      path.join(process.env.HOME || process.cwd(), '.opencode', 'revocation');
    this.cleanupInterval = options.cleanupInterval || 60000; // 1 minute
    
    this.ensureStoreDirectory();
    this.startCleanupTimer();
  }

  /**
   * Revoke a token by storing its JTI with expiration
   * @param {string} jti - Token identifier to revoke
   * @param {number} expiresAt - Expiration timestamp (milliseconds)
   */
  async revoke(jti, expiresAt) {
    try {
      this.validateJti(jti);
      
      const revocationEntry = {
        jti,
        revokedAt: Date.now(),
        expiresAt,
        reason: 'manual_revocation'
      };
      
      const filePath = this.getRevocationPath(jti);
      fs.writeFileSync(filePath, JSON.stringify(revocationEntry));
      
      console.log(`🚫 Token revoked: ${jti} (expires: ${new Date(expiresAt).toISOString()})`);
    } catch (error) {
      throw new Error(`Failed to revoke token: ${error.message}`);
    }
  }

  /**
   * Check if a token is revoked
   * @param {string} jti - Token identifier to check
   * @returns {Promise<boolean>} True if token is revoked
   */
  async isRevoked(jti) {
    try {
      this.validateJti(jti);
      
      const filePath = this.getRevocationPath(jti);
      
      if (!fs.existsSync(filePath)) {
        return false;
      }
      
      // Read revocation entry
      const content = fs.readFileSync(filePath, 'utf8');
      const entry = JSON.parse(content);
      
      // Check if revocation has expired
      if (Date.now() > entry.expiresAt) {
        // Cleanup expired entry
        this.removeRevocationEntry(jti);
        return false;
      }
      
      return true;
    } catch (error) {
      console.error(`Error checking revocation for ${jti}:`, error.message);
      // Fail open - if we can't check revocation, allow the token
      return false;
    }
  }

  /**
   * Remove revocation entry (for cleanup)
   * @param {string} jti - Token identifier
   */
  removeRevocationEntry(jti) {
    try {
      const filePath = this.getRevocationPath(jti);
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
        console.log(`🧹 Removed expired revocation: ${jti}`);
      }
    } catch (error) {
      console.warn(`Failed to remove revocation entry ${jti}:`, error.message);
    }
  }

  /**
   * Cleanup all expired revocation entries
   */
  async cleanupExpired() {
    try {
      if (!fs.existsSync(this.storeDir)) {
        return;
      }
      
      const files = fs.readdirSync(this.storeDir);
      let cleanedCount = 0;
      
      for (const file of files) {
        if (!file.endsWith('.json')) {
          continue;
        }
        
        try {
          const filePath = path.join(this.storeDir, file);
          const content = fs.readFileSync(filePath, 'utf8');
          const entry = JSON.parse(content);
          
          // Check if entry has expired
          if (Date.now() > entry.expiresAt) {
            fs.unlinkSync(filePath);
            cleanedCount++;
          }
        } catch (error) {
          // If we can't parse the file, remove it
          const filePath = path.join(this.storeDir, file);
          try {
            fs.unlinkSync(filePath);
            cleanedCount++;
          } catch (unlinkError) {
            console.warn(`Failed to cleanup invalid revocation file ${file}:`, unlinkError.message);
          }
        }
      }
      
      if (cleanedCount > 0) {
        console.log(`🧹 Cleaned up ${cleanedCount} expired revocation entries`);
      }
    } catch (error) {
      console.error('Failed to cleanup expired revocations:', error.message);
    }
  }

  /**
   * Get all currently revoked tokens (for debugging/monitoring)
   * @returns {Promise<array>} Array of revocation entries
   */
  async getAllRevoked() {
    try {
      if (!fs.existsSync(this.storeDir)) {
        return [];
      }
      
      const files = fs.readdirSync(this.storeDir);
      const revocations = [];
      
      for (const file of files) {
        if (!file.endsWith('.json')) {
          continue;
        }
        
        try {
          const filePath = path.join(this.storeDir, file);
          const content = fs.readFileSync(filePath, 'utf8');
          const entry = JSON.parse(content);
          
          // Only include non-expired entries
          if (Date.now() <= entry.expiresAt) {
            revocations.push(entry);
          }
        } catch (error) {
          console.warn(`Failed to read revocation file ${file}:`, error.message);
        }
      }
      
      return revocations.sort((a, b) => b.revokedAt - a.revokedAt);
    } catch (error) {
      console.error('Failed to get revoked tokens:', error.message);
      return [];
    }
  }

  /**
   * Get revocation statistics
   * @returns {object} Revocation store statistics
   */
  getStats() {
    try {
      if (!fs.existsSync(this.storeDir)) {
        return { totalRevoked: 0, storeSize: 0 };
      }
      
      const files = fs.readdirSync(this.storeDir).filter(f => f.endsWith('.json'));
      const storeSize = files.reduce((size, file) => {
        try {
          const stats = fs.statSync(path.join(this.storeDir, file));
          return size + stats.size;
        } catch (error) {
          return size;
        }
      }, 0);
      
      return {
        totalRevoked: files.length,
        storeSize,
        storePath: this.storeDir
      };
    } catch (error) {
      return { totalRevoked: 0, storeSize: 0, error: error.message };
    }
  }

  /**
   * Ensure revocation store directory exists
   */
  ensureStoreDirectory() {
    if (!fs.existsSync(this.storeDir)) {
      fs.mkdirSync(this.storeDir, { recursive: true, mode: 0o700 });
      console.log(`📁 Created revocation store: ${this.storeDir}`);
    }
  }

  /**
   * Get file path for revocation entry
   * @param {string} jti - Token identifier
   * @returns {string} File path
   */
  getRevocationPath(jti) {
    // Use JTI as filename (sanitized for filesystem)
    const sanitizedJti = jti.replace(/[^a-zA-Z0-9\-_]/g, '');
    return path.join(this.storeDir, `${sanitizedJti}.json`);
  }

  /**
   * Validate JTI format
   * @param {string} jti - Token identifier
   */
  validateJti(jti) {
    if (!jti || typeof jti !== 'string' || jti.length === 0) {
      throw new Error('Invalid JTI: must be a non-empty string');
    }
    
    if (jti.length > 255) {
      throw new Error('Invalid JTI: too long');
    }
    
    // Check for path traversal attempts
    if (jti.includes('..') || jti.includes('/') || jti.includes('\\')) {
      throw new Error('Invalid JTI: contains invalid characters');
    }
  }

  /**
   * Start periodic cleanup timer
   */
  startCleanupTimer() {
    this.cleanupTimer = setInterval(async () => {
      try {
        await this.cleanupExpired();
      } catch (error) {
        console.error('Periodic cleanup failed:', error.message);
      }
    }, this.cleanupInterval);
    
    // Don't keep process alive just for cleanup
    if (this.cleanupTimer.unref) {
      this.cleanupTimer.unref();
    }
  }

  /**
   * Stop cleanup timer (for graceful shutdown)
   */
  stopCleanupTimer() {
    if (this.cleanupTimer) {
      clearInterval(this.cleanupTimer);
      this.cleanupTimer = null;
    }
  }

  /**
   * Clear all revocation entries (for testing)
   */
  async clearAll() {
    try {
      if (!fs.existsSync(this.storeDir)) {
        return;
      }
      
      const files = fs.readdirSync(this.storeDir);
      for (const file of files) {
        if (file.endsWith('.json')) {
          fs.unlinkSync(path.join(this.storeDir, file));
        }
      }
      
      console.log('🧹 Cleared all revocation entries');
    } catch (error) {
      throw new Error(`Failed to clear revocations: ${error.message}`);
    }
  }
}

module.exports = RevocationStore;
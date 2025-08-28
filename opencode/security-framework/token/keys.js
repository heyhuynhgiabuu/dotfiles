const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

/**
 * OpenCode Plugin Token Keys Management
 * 
 * Secure Ed25519 key management for token signing:
 * - Environment variable or file-based key loading
 * - Secure key generation and storage
 * - Key rotation and fingerprinting
 * - Cross-platform secure storage recommendations
 */

class KeyManager {
  constructor(options = {}) {
    this.keyDir = options.keyDir || 
      path.join(process.env.HOME || process.cwd(), '.opencode', 'keys');
    this.keyId = options.keyId || 'default';
    
    this.privateKeyPath = path.join(this.keyDir, 'token_ed25519.pem');
    this.publicKeyPath = path.join(this.keyDir, 'token_ed25519_pub.pem');
    
    this.loadKeys();
  }

  /**
   * Load or generate cryptographic keys
   */
  loadKeys() {
    try {
      // Try environment variable first (for production/containers)
      if (process.env.OPENCODE_TOKEN_PRIVATE_KEY) {
        console.log('🔑 Loading token signing key from environment');
        this.privateKey = Buffer.from(process.env.OPENCODE_TOKEN_PRIVATE_KEY, 'base64').toString();
        this.keyId = process.env.OPENCODE_TOKEN_KEY_ID || 'env-key';
        
        // Extract public key from private key
        const privateKeyObj = crypto.createPrivateKey(this.privateKey);
        this.publicKey = privateKeyObj.export({ type: 'spki', format: 'pem' });
        return;
      }
      
      // Try loading from secure file storage
      if (this.keysExist()) {
        console.log(`🔑 Loading token signing keys from: ${this.keyDir}`);
        this.privateKey = fs.readFileSync(this.privateKeyPath, 'utf8');
        this.publicKey = fs.readFileSync(this.publicKeyPath, 'utf8');
        
        // Validate key pair
        this.validateKeyPair();
        return;
      }
      
      // Generate new key pair
      console.log('🔑 Generating new Ed25519 key pair for token signing');
      this.generateKeyPair();
      
    } catch (error) {
      throw new Error(`Failed to load token signing keys: ${error.message}`);
    }
  }

  /**
   * Check if key files exist
   * @returns {boolean} True if both keys exist
   */
  keysExist() {
    return fs.existsSync(this.privateKeyPath) && fs.existsSync(this.publicKeyPath);
  }

  /**
   * Generate new Ed25519 key pair
   */
  generateKeyPair() {
    try {
      // Ensure key directory exists with secure permissions
      this.ensureKeyDirectory();
      
      // Generate Ed25519 key pair
      const { publicKey, privateKey } = crypto.generateKeyPairSync('ed25519');
      
      // Export keys in PEM format
      this.privateKey = privateKey.export({ type: 'pkcs8', format: 'pem' });
      this.publicKey = publicKey.export({ type: 'spki', format: 'pem' });
      
      // Save keys with secure permissions
      fs.writeFileSync(this.privateKeyPath, this.privateKey, { mode: 0o600 });
      fs.writeFileSync(this.publicKeyPath, this.publicKey, { mode: 0o644 });
      
      // Generate key metadata
      this.saveKeyMetadata();
      
      console.log(`✅ New key pair generated: ${this.keyId}`);
      console.log(`   Private key: ${this.privateKeyPath} (mode 600)`);
      console.log(`   Public key:  ${this.publicKeyPath}`);
      console.log(`   Fingerprint: ${this.getPublicKeyFingerprint()}`);
      
      this.warnSecureStorage();
      
    } catch (error) {
      throw new Error(`Failed to generate key pair: ${error.message}`);
    }
  }

  /**
   * Ensure key directory exists with secure permissions
   */
  ensureKeyDirectory() {
    if (!fs.existsSync(this.keyDir)) {
      fs.mkdirSync(this.keyDir, { recursive: true, mode: 0o700 });
      console.log(`📁 Created secure key directory: ${this.keyDir}`);
    }
    
    // Verify directory permissions
    try {
      const stats = fs.statSync(this.keyDir);
      const mode = stats.mode & parseInt('777', 8);
      if (mode !== parseInt('700', 8)) {
        console.warn(`⚠️  Key directory permissions: ${mode.toString(8)} (should be 700)`);
      }
    } catch (error) {
      // Ignore permission checks on non-Unix systems
    }
  }

  /**
   * Validate that private and public keys are a matching pair
   */
  validateKeyPair() {
    try {
      // Create key objects
      const privateKeyObj = crypto.createPrivateKey(this.privateKey);
      const publicKeyObj = crypto.createPublicKey(this.publicKey);
      
      // Test signing and verification
      const testMessage = 'test-message-for-key-validation';
      const signature = crypto.sign(null, Buffer.from(testMessage), privateKeyObj);
      const isValid = crypto.verify(null, Buffer.from(testMessage), publicKeyObj, signature);
      
      if (!isValid) {
        throw new Error('Key pair validation failed - private and public keys do not match');
      }
      
      console.log('✅ Key pair validation successful');
    } catch (error) {
      throw new Error(`Key pair validation failed: ${error.message}`);
    }
  }

  /**
   * Get public key fingerprint for identification
   * @returns {string} Base64 encoded SHA-256 fingerprint
   */
  getPublicKeyFingerprint() {
    try {
      const publicKeyObj = crypto.createPublicKey(this.publicKey);
      const publicKeyDER = publicKeyObj.export({ format: 'der', type: 'spki' });
      
      return crypto.createHash('sha256')
        .update(publicKeyDER)
        .digest('base64');
    } catch (error) {
      throw new Error(`Failed to compute key fingerprint: ${error.message}`);
    }
  }

  /**
   * Save key metadata for tracking and rotation
   */
  saveKeyMetadata() {
    const metadata = {
      keyId: this.keyId,
      algorithm: 'ed25519',
      fingerprint: this.getPublicKeyFingerprint(),
      createdAt: new Date().toISOString(),
      privateKeyPath: this.privateKeyPath,
      publicKeyPath: this.publicKeyPath,
      usage: 'token-signing'
    };
    
    const metadataPath = path.join(this.keyDir, 'token_key.meta');
    fs.writeFileSync(metadataPath, JSON.stringify(metadata, null, 2));
    
    console.log(`📄 Key metadata saved: ${metadataPath}`);
  }

  /**
   * Rotate to new key pair (keep old for verification grace period)
   * @param {string} newKeyId - New key identifier
   * @returns {object} New key information
   */
  rotateKey(newKeyId) {
    console.log(`🔄 Rotating token signing key: ${this.keyId} → ${newKeyId}`);
    
    try {
      // Archive current keys
      const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
      const archiveDir = path.join(this.keyDir, 'archive');
      
      if (!fs.existsSync(archiveDir)) {
        fs.mkdirSync(archiveDir, { mode: 0o700 });
      }
      
      const archivePrivate = path.join(archiveDir, `token_${this.keyId}_${timestamp}.pem`);
      const archivePublic = path.join(archiveDir, `token_${this.keyId}_${timestamp}_pub.pem`);
      
      // Copy current keys to archive
      fs.copyFileSync(this.privateKeyPath, archivePrivate);
      fs.copyFileSync(this.publicKeyPath, archivePublic);
      fs.chmodSync(archivePrivate, 0o600);
      
      console.log(`📦 Archived old keys to: ${archiveDir}`);
      
      // Generate new key pair
      const oldKeyId = this.keyId;
      this.keyId = newKeyId;
      this.generateKeyPair();
      
      // Create rotation record
      const rotationRecord = {
        type: 'key-rotation',
        timestamp: new Date().toISOString(),
        oldKeyId,
        newKeyId,
        oldKeyFingerprint: crypto.createHash('sha256')
          .update(fs.readFileSync(archivePublic))
          .digest('base64'),
        newKeyFingerprint: this.getPublicKeyFingerprint(),
        archivedKeys: {
          private: archivePrivate,
          public: archivePublic
        }
      };
      
      const rotationPath = path.join(this.keyDir, `rotation_${timestamp}.json`);
      fs.writeFileSync(rotationPath, JSON.stringify(rotationRecord, null, 2));
      
      console.log('✅ Key rotation completed successfully');
      console.log(`📄 Rotation record: ${rotationPath}`);
      
      return rotationRecord;
      
    } catch (error) {
      throw new Error(`Key rotation failed: ${error.message}`);
    }
  }

  /**
   * Sign data with private key
   * @param {Buffer|string} data - Data to sign
   * @returns {Buffer} Signature
   */
  sign(data) {
    try {
      const privateKeyObj = crypto.createPrivateKey(this.privateKey);
      return crypto.sign(null, Buffer.from(data), privateKeyObj);
    } catch (error) {
      throw new Error(`Signing failed: ${error.message}`);
    }
  }

  /**
   * Verify signature with public key
   * @param {Buffer|string} data - Original data
   * @param {Buffer} signature - Signature to verify
   * @returns {boolean} True if signature is valid
   */
  verify(data, signature) {
    try {
      const publicKeyObj = crypto.createPublicKey(this.publicKey);
      return crypto.verify(null, Buffer.from(data), publicKeyObj, signature);
    } catch (error) {
      console.error('Verification error:', error.message);
      return false;
    }
  }

  /**
   * Export public key for distribution
   * @returns {object} Public key information
   */
  exportPublicKey() {
    return {
      keyId: this.keyId,
      algorithm: 'ed25519',
      publicKeyPem: this.publicKey,
      fingerprint: this.getPublicKeyFingerprint(),
      usage: 'token-verification'
    };
  }

  /**
   * Get key information for status/debugging
   * @returns {object} Key status information
   */
  getKeyInfo() {
    return {
      keyId: this.keyId,
      algorithm: 'ed25519',
      fingerprint: this.getPublicKeyFingerprint(),
      keyPath: this.privateKeyPath,
      hasPrivateKey: !!this.privateKey,
      hasPublicKey: !!this.publicKey,
      keySource: process.env.OPENCODE_TOKEN_PRIVATE_KEY ? 'environment' : 'file'
    };
  }

  /**
   * Warn about secure storage recommendations
   */
  warnSecureStorage() {
    console.log('\n🔒 SECURITY RECOMMENDATIONS:');
    console.log('  Store private keys securely:');
    console.log('    macOS: Import to Keychain (security import)');
    console.log('    Linux: Use ssh-agent or encrypted file storage');
    console.log('    Production: Use environment variables or KMS');
    console.log('  Never commit private keys to version control');
    console.log('  Rotate keys regularly and on suspected compromise');
    console.log('  Monitor key usage in audit logs\n');
  }
}

// Create singleton instance for the application
const keyManager = new KeyManager();

module.exports = keyManager;
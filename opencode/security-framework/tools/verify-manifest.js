/**
 * OpenCode Plugin Manifest Verification Tool
 * 
 * Cryptographic verification of signed plugin manifests:
 * - Signature validation using public keys
 * - File integrity verification (SHA-256)
 * - Publisher trust verification via key pinning
 * - Revocation list checking
 * 
 * Security Features:
 * - Constant-time signature comparison
 * - Public key fingerprint verification
 * - Tamper detection for plugin files
 * - Comprehensive audit logging
 */

const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

class ManifestVerifier {
  constructor(options = {}) {
    this.trustedPublishersPath = options.trustedPublishersPath || 
      path.join(process.env.HOME || process.cwd(), '.opencode/configs/trusted_publishers.json');
    this.revocationListPath = options.revocationListPath || 
      path.join(process.env.HOME || process.cwd(), '.opencode/configs/revocation-list.json');
    this.auditLogPath = options.auditLogPath || 
      path.join(process.env.HOME || process.cwd(), '.opencode/logs/plugin-verification.log');
    
    this.trustedPublishers = this.loadTrustedPublishers();
    this.revocationList = this.loadRevocationList();
  }

  /**
   * Verify a signed manifest
   * @param {string} manifestPath - Path to signed manifest file
   * @param {string} pluginBasePath - Base path for plugin files
   * @returns {Promise<object>} Verification result
   */
  async verifyManifest(manifestPath, pluginBasePath = null) {
    const startTime = Date.now();
    console.log(`🔍 Verifying manifest: ${manifestPath}`);
    
    try {
      // Load signed manifest
      const manifest = this.loadSignedManifest(manifestPath);
      
      // Set base path for file verification
      const basePath = pluginBasePath || path.dirname(manifestPath);
      
      // Perform verification steps
      const results = {
        manifestPath,
        pluginId: manifest.pluginId,
        version: manifest.version,
        signatureValid: false,
        publisherTrusted: false,
        filesIntact: false,
        keyRevoked: false,
        errors: [],
        warnings: []
      };
      
      // Step 1: Verify cryptographic signature
      results.signatureValid = this.verifySignature(manifest);
      if (!results.signatureValid) {
        results.errors.push('Invalid cryptographic signature');
      }
      
      // Step 2: Check publisher trust
      const trustResult = this.verifyPublisherTrust(manifest.signer);
      results.publisherTrusted = trustResult.trusted;
      if (!trustResult.trusted) {
        results.errors.push(trustResult.reason);
      }
      
      // Step 3: Check key revocation
      results.keyRevoked = this.isKeyRevoked(manifest.signer.keyId);
      if (results.keyRevoked) {
        results.errors.push('Signing key has been revoked');
      }
      
      // Step 4: Verify file integrity
      const integrityResult = await this.verifyFileIntegrity(manifest, basePath);
      results.filesIntact = integrityResult.intact;
      if (!integrityResult.intact) {
        results.errors.push(`File integrity check failed: ${integrityResult.errors.join(', ')}`);
      }
      
      // Overall verification result
      const isValid = results.signatureValid && 
                     results.publisherTrusted && 
                     results.filesIntact && 
                     !results.keyRevoked;
      
      results.valid = isValid;
      results.verificationTime = Date.now() - startTime;
      
      // Log verification result
      this.auditLog(results);
      
      // Print results
      this.printVerificationResults(results);
      
      return results;
      
    } catch (error) {
      const errorResult = {
        manifestPath,
        valid: false,
        errors: [error.message],
        verificationTime: Date.now() - startTime
      };
      
      this.auditLog(errorResult);
      console.error(`❌ Verification failed: ${error.message}`);
      return errorResult;
    }
  }

  /**
   * Load and parse signed manifest
   * @param {string} manifestPath - Path to manifest file
   * @returns {object} Parsed manifest
   */
  loadSignedManifest(manifestPath) {
    if (!fs.existsSync(manifestPath)) {
      throw new Error(`Manifest file not found: ${manifestPath}`);
    }
    
    try {
      const content = fs.readFileSync(manifestPath, 'utf8');
      const manifest = JSON.parse(content);
      
      // Validate required fields for verification
      const required = ['pluginId', 'version', 'signature', 'signer'];
      for (const field of required) {
        if (!manifest[field]) {
          throw new Error(`Missing required field: ${field}`);
        }
      }
      
      // Validate signer structure
      const signerRequired = ['keyId', 'algorithm', 'publicKeyPem'];
      for (const field of signerRequired) {
        if (!manifest.signer[field]) {
          throw new Error(`Missing signer field: ${field}`);
        }
      }
      
      return manifest;
    } catch (error) {
      if (error instanceof SyntaxError) {
        throw new Error(`Invalid JSON in manifest: ${error.message}`);
      }
      throw error;
    }
  }

  /**
   * Verify cryptographic signature
   * @param {object} manifest - Signed manifest
   * @returns {boolean} Signature validity
   */
  verifySignature(manifest) {
    try {
      const { signature, signer } = manifest;
      
      // Recreate canonical manifest for verification
      const manifestForVerification = { ...manifest };
      delete manifestForVerification.signature;
      const canonical = JSON.stringify(manifestForVerification, this.sortKeys);
      
      // Load public key
      const publicKey = crypto.createPublicKey({
        key: signer.publicKeyPem,
        format: 'pem'
      });
      
      // Verify signature based on algorithm
      const signatureBuffer = Buffer.from(signature, 'base64');
      let isValid;
      
      if (signer.algorithm === 'ed25519') {
        isValid = crypto.verify(null, Buffer.from(canonical, 'utf8'), publicKey, signatureBuffer);
      } else if (signer.algorithm === 'rsa') {
        isValid = crypto.verify('sha256', Buffer.from(canonical, 'utf8'), {
          key: publicKey,
          padding: crypto.constants.RSA_PKCS1_PSS_PADDING,
          saltLength: crypto.constants.RSA_PSS_SALTLEN_DIGEST
        }, signatureBuffer);
      } else {
        console.warn(`⚠️  Unsupported signature algorithm: ${signer.algorithm}`);
        return false;
      }
      
      return isValid;
    } catch (error) {
      console.error('Signature verification error:', error.message);
      return false;
    }
  }

  /**
   * Verify publisher trust via key pinning
   * @param {object} signer - Signer information
   * @returns {object} Trust verification result
   */
  verifyPublisherTrust(signer) {
    try {
      // Compute public key fingerprint
      const publicKey = crypto.createPublicKey({
        key: signer.publicKeyPem,
        format: 'pem'
      });
      
      const publicKeyDER = publicKey.export({ format: 'der', type: 'spki' });
      const fingerprint = crypto.createHash('sha256').update(publicKeyDER).digest('base64');
      
      // Check against trusted publishers
      for (const publisher of this.trustedPublishers) {
        if (publisher.keyId === signer.keyId) {
          // Constant-time fingerprint comparison
          if (this.constantTimeCompare(publisher.fingerprint, fingerprint)) {
            return { trusted: true, publisher };
          } else {
            return { trusted: false, reason: 'Public key fingerprint mismatch' };
          }
        }
      }
      
      return { trusted: false, reason: 'Publisher not in trusted list' };
    } catch (error) {
      return { trusted: false, reason: `Trust verification error: ${error.message}` };
    }
  }

  /**
   * Check if signing key is revoked
   * @param {string} keyId - Key identifier
   * @returns {boolean} True if key is revoked
   */
  isKeyRevoked(keyId) {
    try {
      for (const revocation of this.revocationList) {
        if (revocation.keyId === keyId) {
          console.warn(`⚠️  Key revoked: ${keyId} (${revocation.reason})`);
          return true;
        }
      }
      return false;
    } catch (error) {
      console.warn(`⚠️  Error checking revocation: ${error.message}`);
      return false; // Fail open for revocation check errors
    }
  }

  /**
   * Verify integrity of plugin files
   * @param {object} manifest - Manifest with file hashes
   * @param {string} basePath - Base directory for files
   * @returns {Promise<object>} Integrity verification result
   */
  async verifyFileIntegrity(manifest, basePath) {
    const result = { intact: true, errors: [] };
    
    if (!manifest.files || manifest.files.length === 0) {
      result.errors.push('No files listed in manifest');
      result.intact = false;
      return result;
    }
    
    for (const fileEntry of manifest.files) {
      try {
        const filePath = path.join(basePath, fileEntry.path);
        
        if (!fs.existsSync(filePath)) {
          result.errors.push(`File not found: ${fileEntry.path}`);
          result.intact = false;
          continue;
        }
        
        // Compute current file hash
        const content = fs.readFileSync(filePath);
        const hash = crypto.createHash('sha256');
        hash.update(content);
        const currentHash = hash.digest('hex');
        
        // Compare with manifest hash using constant-time comparison
        if (!this.constantTimeCompare(fileEntry.sha256, currentHash)) {
          result.errors.push(`Hash mismatch: ${fileEntry.path}`);
          result.intact = false;
        }
      } catch (error) {
        result.errors.push(`Error verifying ${fileEntry.path}: ${error.message}`);
        result.intact = false;
      }
    }
    
    return result;
  }

  /**
   * Load trusted publishers configuration
   * @returns {array} List of trusted publishers
   */
  loadTrustedPublishers() {
    try {
      if (!fs.existsSync(this.trustedPublishersPath)) {
        console.warn(`⚠️  Trusted publishers file not found: ${this.trustedPublishersPath}`);
        return [];
      }
      
      const content = fs.readFileSync(this.trustedPublishersPath, 'utf8');
      const publishers = JSON.parse(content);
      
      console.log(`📋 Loaded ${publishers.length} trusted publishers`);
      return publishers;
    } catch (error) {
      console.warn(`⚠️  Error loading trusted publishers: ${error.message}`);
      return [];
    }
  }

  /**
   * Load revocation list
   * @returns {array} List of revoked keys
   */
  loadRevocationList() {
    try {
      if (!fs.existsSync(this.revocationListPath)) {
        console.warn(`⚠️  Revocation list not found: ${this.revocationListPath}`);
        return [];
      }
      
      const content = fs.readFileSync(this.revocationListPath, 'utf8');
      const revocations = JSON.parse(content);
      
      console.log(`🚫 Loaded ${revocations.length} key revocations`);
      return revocations;
    } catch (error) {
      console.warn(`⚠️  Error loading revocation list: ${error.message}`);
      return [];
    }
  }

  /**
   * Constant-time string comparison to prevent timing attacks
   * @param {string} a - First string
   * @param {string} b - Second string
   * @returns {boolean} True if strings are equal
   */
  constantTimeCompare(a, b) {
    if (a.length !== b.length) {
      return false;
    }
    
    let result = 0;
    for (let i = 0; i < a.length; i++) {
      result |= a.charCodeAt(i) ^ b.charCodeAt(i);
    }
    
    return result === 0;
  }

  /**
   * Sort object keys for canonical JSON
   * @param {string} key - Object key
   * @param {any} value - Object value
   * @returns {any} Processed value
   */
  sortKeys(key, value) {
    if (value && typeof value === 'object' && !Array.isArray(value)) {
      const sorted = {};
      for (const k of Object.keys(value).sort()) {
        sorted[k] = value[k];
      }
      return sorted;
    }
    return value;
  }

  /**
   * Log verification result to audit log
   * @param {object} result - Verification result
   */
  auditLog(result) {
    try {
      // Ensure log directory exists
      const logDir = path.dirname(this.auditLogPath);
      if (!fs.existsSync(logDir)) {
        fs.mkdirSync(logDir, { recursive: true });
      }
      
      const logEntry = {
        timestamp: new Date().toISOString(),
        event: 'manifest-verification',
        pluginId: result.pluginId || 'unknown',
        version: result.version || 'unknown',
        valid: result.valid,
        signatureValid: result.signatureValid,
        publisherTrusted: result.publisherTrusted,
        filesIntact: result.filesIntact,
        keyRevoked: result.keyRevoked,
        verificationTime: result.verificationTime,
        errors: result.errors || [],
        warnings: result.warnings || []
      };
      
      // Append to audit log (JSON Lines format)
      const logLine = JSON.stringify(logEntry) + '\n';
      fs.appendFileSync(this.auditLogPath, logLine);
    } catch (error) {
      console.warn(`⚠️  Failed to write audit log: ${error.message}`);
    }
  }

  /**
   * Print verification results to console
   * @param {object} results - Verification results
   */
  printVerificationResults(results) {
    console.log('\n📊 Verification Results:');
    console.log('=' .repeat(50));
    
    const status = results.valid ? '✅ VALID' : '❌ INVALID';
    console.log(`Overall Status: ${status}`);
    console.log(`Plugin ID: ${results.pluginId}`);
    console.log(`Version: ${results.version}`);
    console.log(`Verification Time: ${results.verificationTime}ms`);
    
    console.log('\nChecks:');
    console.log(`  Signature Valid: ${results.signatureValid ? '✅' : '❌'}`);
    console.log(`  Publisher Trusted: ${results.publisherTrusted ? '✅' : '❌'}`);
    console.log(`  Files Intact: ${results.filesIntact ? '✅' : '❌'}`);
    console.log(`  Key Not Revoked: ${!results.keyRevoked ? '✅' : '❌'}`);
    
    if (results.errors.length > 0) {
      console.log('\n❌ Errors:');
      results.errors.forEach(error => console.log(`  - ${error}`));
    }
    
    if (results.warnings.length > 0) {
      console.log('\n⚠️  Warnings:');
      results.warnings.forEach(warning => console.log(`  - ${warning}`));
    }
    
    console.log('=' .repeat(50));
  }
}

// CLI interface
async function main() {
  const args = process.argv.slice(2);
  
  if (args.length < 1 || args.includes('--help')) {
    console.log(`
OpenCode Plugin Manifest Verifier

Usage: node verify-manifest.js <signed-manifest.json> [plugin-base-path]

Arguments:
  signed-manifest.json  Path to signed manifest file
  plugin-base-path     Base directory for plugin files (default: manifest directory)

Options:
  --help               Show this help message

Examples:
  node verify-manifest.js plugin/manifest.signed.json
  node verify-manifest.js plugin/manifest.signed.json ./plugin-files/

Configuration Files:
  ~/.opencode/configs/trusted_publishers.json  - Trusted publisher keys
  ~/.opencode/configs/revocation-list.json     - Revoked key list
  ~/.opencode/logs/plugin-verification.log     - Audit log

Exit Codes:
  0    Verification successful
  1    Verification failed
  2    Invalid arguments or configuration error
`);
    process.exit(args.includes('--help') ? 0 : 2);
  }
  
  const [manifestPath, pluginBasePath] = args;
  
  try {
    const verifier = new ManifestVerifier();
    const result = await verifier.verifyManifest(manifestPath, pluginBasePath);
    
    if (result.valid) {
      console.log('\n🎉 Manifest verification PASSED!');
      process.exit(0);
    } else {
      console.log('\n💥 Manifest verification FAILED!');
      process.exit(1);
    }
  } catch (error) {
    console.error('❌ Verification error:', error.message);
    process.exit(2);
  }
}

// Run CLI if executed directly
if (require.main === module) {
  main().catch(error => {
    console.error('Unexpected error:', error);
    process.exit(2);
  });
}

module.exports = ManifestVerifier;
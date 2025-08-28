/**
 * OpenCode Plugin Manifest Signing Tool
 * 
 * Cryptographic signing of plugin manifests using Node.js crypto module:
 * - Ed25519 and RSA signature support
 * - Canonical JSON serialization for consistent signatures
 * - File integrity hashing (SHA-256)
 * - PEM key format support
 * 
 * Security Features:
 * - Deterministic manifest canonicalization
 * - Multiple signature algorithms
 * - File integrity verification
 * - Secure private key handling
 */

const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

class ManifestSigner {
  constructor() {
    this.supportedAlgorithms = new Set(['ed25519', 'rsa']);
  }

  /**
   * Sign a plugin manifest
   * @param {string} manifestPath - Path to manifest.json
   * @param {string} privateKeyPath - Path to private key file
   * @param {string} keyId - Publisher key identifier
   * @param {string} algorithm - Signature algorithm (ed25519, rsa)
   * @returns {Promise<object>} Signed manifest
   */
  async signManifest(manifestPath, privateKeyPath, keyId, algorithm = 'ed25519') {
    console.log(`🔏 Signing manifest: ${manifestPath}`);
    
    // Validate inputs
    this.validateInputs(manifestPath, privateKeyPath, keyId, algorithm);
    
    // Load manifest
    const manifest = this.loadManifest(manifestPath);
    
    // Add file integrity hashes
    await this.addFileHashes(manifest, path.dirname(manifestPath));
    
    // Load private key
    const privateKey = this.loadPrivateKey(privateKeyPath, algorithm);
    
    // Load corresponding public key
    const publicKeyPath = this.getPublicKeyPath(privateKeyPath);
    const publicKeyPem = fs.readFileSync(publicKeyPath, 'utf8');
    
    // Add signer information
    manifest.signer = {
      keyId,
      algorithm,
      publicKeyPem: publicKeyPem.trim()
    };
    
    // Add timestamp
    manifest.signedAt = new Date().toISOString();
    
    // Create canonical representation for signing
    const canonicalManifest = this.canonicalizeManifest(manifest);
    
    // Generate signature
    const signature = this.createSignature(canonicalManifest, privateKey, algorithm);
    manifest.signature = signature;
    
    // Save signed manifest
    const signedPath = manifestPath.replace('.json', '.signed.json');
    fs.writeFileSync(signedPath, JSON.stringify(manifest, null, 2));
    
    console.log(`✅ Manifest signed successfully: ${signedPath}`);
    console.log(`   Algorithm: ${algorithm}`);
    console.log(`   Key ID: ${keyId}`);
    console.log(`   Files: ${manifest.files?.length || 0} files hashed`);
    
    return manifest;
  }

  /**
   * Validate signing inputs
   * @param {string} manifestPath - Manifest file path
   * @param {string} privateKeyPath - Private key file path
   * @param {string} keyId - Key identifier
   * @param {string} algorithm - Signature algorithm
   */
  validateInputs(manifestPath, privateKeyPath, keyId, algorithm) {
    if (!fs.existsSync(manifestPath)) {
      throw new Error(`Manifest file not found: ${manifestPath}`);
    }
    
    if (!fs.existsSync(privateKeyPath)) {
      throw new Error(`Private key file not found: ${privateKeyPath}`);
    }
    
    if (!keyId || typeof keyId !== 'string' || keyId.length === 0) {
      throw new Error('Valid key ID is required');
    }
    
    if (!this.supportedAlgorithms.has(algorithm)) {
      throw new Error(`Unsupported algorithm: ${algorithm}. Supported: ${Array.from(this.supportedAlgorithms).join(', ')}`);
    }
    
    // Check private key permissions (Unix systems)
    try {
      const stats = fs.statSync(privateKeyPath);
      const mode = stats.mode & parseInt('777', 8);
      if (mode !== parseInt('600', 8)) {
        console.warn(`⚠️  Private key permissions: ${mode.toString(8)} (should be 600)`);
      }
    } catch (error) {
      // Ignore permission check errors on non-Unix systems
    }
  }

  /**
   * Load and validate manifest file
   * @param {string} manifestPath - Path to manifest.json
   * @returns {object} Parsed manifest
   */
  loadManifest(manifestPath) {
    try {
      const content = fs.readFileSync(manifestPath, 'utf8');
      const manifest = JSON.parse(content);
      
      // Validate required fields
      const required = ['pluginId', 'version'];
      for (const field of required) {
        if (!manifest[field]) {
          throw new Error(`Missing required field: ${field}`);
        }
      }
      
      // Validate plugin ID format
      if (!/^[a-z0-9.-]+$/.test(manifest.pluginId)) {
        throw new Error('Invalid plugin ID format (use lowercase, numbers, dots, hyphens)');
      }
      
      // Validate version format (semantic versioning)
      if (!/^\d+\.\d+\.\d+/.test(manifest.version)) {
        throw new Error('Invalid version format (use semantic versioning: x.y.z)');
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
   * Add SHA-256 hashes for all plugin files
   * @param {object} manifest - Manifest object
   * @param {string} basePath - Base directory for relative file paths
   */
  async addFileHashes(manifest, basePath) {
    if (!manifest.files) {
      manifest.files = [];
    }
    
    // If no files specified, auto-detect common plugin files
    if (manifest.files.length === 0) {
      const commonFiles = ['index.js', 'plugin.js', 'main.js'];
      for (const file of commonFiles) {
        const filePath = path.join(basePath, file);
        if (fs.existsSync(filePath)) {
          manifest.files.push({ path: file });
        }
      }
    }
    
    // Compute hashes for all files
    for (const fileEntry of manifest.files) {
      const filePath = path.join(basePath, fileEntry.path);
      
      if (!fs.existsSync(filePath)) {
        throw new Error(`Plugin file not found: ${fileEntry.path}`);
      }
      
      const content = fs.readFileSync(filePath);
      const hash = crypto.createHash('sha256');
      hash.update(content);
      fileEntry.sha256 = hash.digest('hex');
      
      console.log(`   📁 ${fileEntry.path}: ${fileEntry.sha256.substring(0, 16)}...`);
    }
    
    console.log(`🔍 Computed hashes for ${manifest.files.length} files`);
  }

  /**
   * Load private key with algorithm-specific handling
   * @param {string} privateKeyPath - Path to private key
   * @param {string} algorithm - Key algorithm
   * @returns {object} Private key object
   */
  loadPrivateKey(privateKeyPath, algorithm) {
    try {
      const keyData = fs.readFileSync(privateKeyPath, 'utf8');
      
      // Create key object with algorithm validation
      const privateKey = crypto.createPrivateKey({
        key: keyData,
        format: 'pem'
      });
      
      // Validate algorithm matches key type
      const keyType = privateKey.asymmetricKeyType;
      if (algorithm === 'ed25519' && keyType !== 'ed25519') {
        throw new Error(`Key type mismatch: expected ed25519, got ${keyType}`);
      }
      if (algorithm === 'rsa' && keyType !== 'rsa') {
        throw new Error(`Key type mismatch: expected rsa, got ${keyType}`);
      }
      
      return privateKey;
    } catch (error) {
      throw new Error(`Failed to load private key: ${error.message}`);
    }
  }

  /**
   * Get corresponding public key path
   * @param {string} privateKeyPath - Private key path
   * @returns {string} Public key path
   */
  getPublicKeyPath(privateKeyPath) {
    // Try common public key naming conventions
    const candidates = [
      privateKeyPath + '.pub.pem',
      privateKeyPath + '.pub',
      privateKeyPath.replace(/\.pem$/, '.pub.pem'),
      privateKeyPath.replace(/$/, '.pub.pem')
    ];
    
    for (const candidate of candidates) {
      if (fs.existsSync(candidate)) {
        return candidate;
      }
    }
    
    throw new Error(`Public key not found for private key: ${privateKeyPath}`);
  }

  /**
   * Canonicalize manifest for consistent signing
   * @param {object} manifest - Manifest object
   * @returns {string} Canonical JSON string
   */
  canonicalizeManifest(manifest) {
    // Create copy without signature field
    const manifestForSigning = { ...manifest };
    delete manifestForSigning.signature;
    
    // Canonical JSON: sorted keys, no whitespace, UTF-8
    const canonical = JSON.stringify(manifestForSigning, this.sortKeys);
    
    console.log(`📋 Canonical manifest: ${canonical.length} bytes`);
    return canonical;
  }

  /**
   * Sort object keys recursively for canonical JSON
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
   * Create cryptographic signature
   * @param {string} data - Data to sign
   * @param {object} privateKey - Private key object
   * @param {string} algorithm - Signature algorithm
   * @returns {string} Base64-encoded signature
   */
  createSignature(data, privateKey, algorithm) {
    try {
      let signature;
      
      if (algorithm === 'ed25519') {
        // Ed25519 signature
        signature = crypto.sign(null, Buffer.from(data, 'utf8'), privateKey);
      } else if (algorithm === 'rsa') {
        // RSA-PSS signature with SHA-256
        signature = crypto.sign('sha256', Buffer.from(data, 'utf8'), {
          key: privateKey,
          padding: crypto.constants.RSA_PKCS1_PSS_PADDING,
          saltLength: crypto.constants.RSA_PSS_SALTLEN_DIGEST
        });
      } else {
        throw new Error(`Unsupported signature algorithm: ${algorithm}`);
      }
      
      const signatureBase64 = signature.toString('base64');
      console.log(`🔐 Signature created: ${signatureBase64.substring(0, 32)}... (${signature.length} bytes)`);
      
      return signatureBase64;
    } catch (error) {
      throw new Error(`Signature creation failed: ${error.message}`);
    }
  }

  /**
   * Verify manifest signature (for testing)
   * @param {object} signedManifest - Signed manifest object
   * @returns {boolean} Signature validity
   */
  verifySignature(signedManifest) {
    try {
      const { signature, signer } = signedManifest;
      
      if (!signature || !signer) {
        return false;
      }
      
      // Recreate canonical form
      const manifestForVerification = { ...signedManifest };
      delete manifestForVerification.signature;
      const canonical = JSON.stringify(manifestForVerification, this.sortKeys);
      
      // Load public key
      const publicKey = crypto.createPublicKey({
        key: signer.publicKeyPem,
        format: 'pem'
      });
      
      // Verify signature
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
        return false;
      }
      
      return isValid;
    } catch (error) {
      console.error('Signature verification error:', error.message);
      return false;
    }
  }
}

// CLI interface
async function main() {
  const args = process.argv.slice(2);
  
  if (args.length < 4 || args.includes('--help')) {
    console.log(`
OpenCode Plugin Manifest Signer

Usage: node sign-manifest.js <manifest.json> <private-key> <key-id> <algorithm>

Arguments:
  manifest.json    Path to plugin manifest file
  private-key      Path to private key file (PEM format)
  key-id          Publisher key identifier
  algorithm       Signature algorithm (ed25519, rsa)

Examples:
  node sign-manifest.js plugin/manifest.json ~/.opencode/keys/publisher_ed25519 publisher-v1 ed25519
  node sign-manifest.js plugin/manifest.json ~/.opencode/keys/publisher_rsa4096 publisher-v2 rsa

Security Notes:
  - Private key files should have 600 permissions
  - Never commit private keys to version control
  - Verify signatures with verify-manifest.js before distribution
`);
    process.exit(args.includes('--help') ? 0 : 1);
  }
  
  const [manifestPath, privateKeyPath, keyId, algorithm] = args;
  
  try {
    const signer = new ManifestSigner();
    const signedManifest = await signer.signManifest(manifestPath, privateKeyPath, keyId, algorithm);
    
    // Test signature verification
    if (signer.verifySignature(signedManifest)) {
      console.log('✅ Signature verification: PASSED');
    } else {
      console.log('❌ Signature verification: FAILED');
      process.exit(1);
    }
    
    console.log('\n🎉 Manifest signing completed successfully!');
  } catch (error) {
    console.error('❌ Signing failed:', error.message);
    process.exit(1);
  }
}

// Run CLI if executed directly
if (require.main === module) {
  main().catch(error => {
    console.error('Unexpected error:', error);
    process.exit(1);
  });
}

module.exports = ManifestSigner;
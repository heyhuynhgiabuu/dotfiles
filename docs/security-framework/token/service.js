/**
 * OpenCode Plugin Token Service
 * 
 * Short-lived capability token management with cryptographic binding:
 * - JWT-style tokens with Ed25519 signatures
 * - Plugin identity binding via public key fingerprints
 * - Token revocation and refresh mechanisms
 * - Secure token validation and cleanup
 */

const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

class TokenService {
  constructor(options = {}) {
    this.keyManager = options.keyManager || require('./keys');
    this.revocationStore = options.revocationStore || require('./revocation_store');
    this.auditLogger = options.auditLogger || require('../audit/logger');
    
    // Default token TTL: 5 minutes for access tokens
    this.defaultAccessTTL = options.accessTTL || 300;
    this.defaultRefreshTTL = options.refreshTTL || 3600; // 1 hour
    
    this.issuer = 'opencode-plugin-system';
    this.algorithm = 'EdDSA';
  }

  /**
   * Issue capability token for plugin
   * @param {string} pluginId - Plugin identifier
   * @param {array} capabilities - Requested capabilities
   * @param {number} ttlSeconds - Token TTL in seconds
   * @param {string} pluginPublicKeyFingerprint - Plugin public key binding
   * @param {object} options - Additional options
   * @returns {object} Token and metadata
   */
  async issueToken(pluginId, capabilities = [], ttlSeconds = null, pluginPublicKeyFingerprint = null, options = {}) {
    try {
      // Validate inputs
      this.validateTokenRequest(pluginId, capabilities, ttlSeconds);
      
      const now = Math.floor(Date.now() / 1000);
      const ttl = ttlSeconds || this.defaultAccessTTL;
      const jti = crypto.randomUUID();
      
      // Create token payload
      const payload = {
        iss: this.issuer,
        sub: pluginId,
        aud: 'opencode-plugin',
        iat: now,
        exp: now + ttl,
        jti,
        capabilities,
        plugin_pub: pluginPublicKeyFingerprint,
        nonce: options.nonce || crypto.randomBytes(16).toString('hex')
      };
      
      // Create token
      const token = this.createToken(payload);
      
      // Audit log token issuance
      await this.auditLogger.log({
        event_type: 'TOKEN_ISSUE',
        actor: { type: 'system', id: 'token-service' },
        data: {
          plugin_id: pluginId,
          jti,
          capabilities,
          ttl,
          expires_at: new Date((now + ttl) * 1000).toISOString()
        }
      });
      
      console.log(`🎫 Token issued for ${pluginId}: ${jti} (TTL: ${ttl}s)`);
      
      return {
        access_token: token,
        token_type: 'Bearer',
        expires_in: ttl,
        jti,
        capabilities
      };
    } catch (error) {
      await this.auditLogger.log({
        event_type: 'TOKEN_ISSUE_FAILURE',
        actor: { type: 'system', id: 'token-service' },
        data: {
          plugin_id: pluginId,
          error: error.message,
          capabilities
        }
      });
      throw error;
    }
  }

  /**
   * Issue refresh token for long-lived operations
   * @param {string} pluginId - Plugin identifier
   * @param {string} accessTokenJti - Associated access token JTI
   * @returns {object} Refresh token
   */
  async issueRefreshToken(pluginId, accessTokenJti) {
    const now = Math.floor(Date.now() / 1000);
    const jti = crypto.randomUUID();
    
    const payload = {
      iss: this.issuer,
      sub: pluginId,
      aud: 'opencode-refresh',
      iat: now,
      exp: now + this.defaultRefreshTTL,
      jti,
      type: 'refresh',
      access_jti: accessTokenJti
    };
    
    const token = this.createToken(payload);
    
    await this.auditLogger.log({
      event_type: 'REFRESH_TOKEN_ISSUE',
      actor: { type: 'system', id: 'token-service' },
      data: {
        plugin_id: pluginId,
        refresh_jti: jti,
        access_jti: accessTokenJti
      }
    });
    
    return {
      refresh_token: token,
      expires_in: this.defaultRefreshTTL,
      jti
    };
  }

  /**
   * Validate token and return claims
   * @param {string} token - Token to validate
   * @param {array} requiredCapabilities - Required capabilities
   * @param {string} pluginId - Expected plugin ID
   * @returns {object} Validation result and claims
   */
  async validateToken(token, requiredCapabilities = [], pluginId = null) {
    try {
      // Parse token structure
      const parts = token.split('.');
      if (parts.length !== 3) {
        throw new Error('Invalid token format');
      }
      
      const [headerB64, payloadB64, signatureB64] = parts;
      
      // Decode header and payload
      const header = JSON.parse(Buffer.from(headerB64, 'base64url').toString());
      const payload = JSON.parse(Buffer.from(payloadB64, 'base64url').toString());
      
      // Validate header
      if (header.alg !== this.algorithm) {
        throw new Error(`Unsupported algorithm: ${header.alg}`);
      }
      
      // Verify signature
      const message = `${headerB64}.${payloadB64}`;
      const signature = Buffer.from(signatureB64, 'base64url');
      
      const isValidSignature = crypto.verify(
        null,
        Buffer.from(message),
        this.keyManager.publicKey,
        signature
      );
      
      if (!isValidSignature) {
        throw new Error('Invalid token signature');
      }
      
      // Validate claims
      const now = Math.floor(Date.now() / 1000);
      
      if (payload.exp <= now) {
        throw new Error('Token expired');
      }
      
      if (payload.iss !== this.issuer) {
        throw new Error('Invalid issuer');
      }
      
      if (pluginId && payload.sub !== pluginId) {
        throw new Error('Plugin ID mismatch');
      }
      
      // Check revocation
      const isRevoked = await this.revocationStore.isRevoked(payload.jti);
      if (isRevoked) {
        throw new Error('Token has been revoked');
      }
      
      // Validate capabilities
      const tokenCapabilities = payload.capabilities || [];
      const missingCapabilities = requiredCapabilities.filter(
        cap => !tokenCapabilities.includes(cap)
      );
      
      if (missingCapabilities.length > 0) {
        throw new Error(`Missing capabilities: ${missingCapabilities.join(', ')}`);
      }
      
      // Successful validation
      await this.auditLogger.log({
        event_type: 'TOKEN_VALIDATE_SUCCESS',
        actor: { type: 'plugin', id: payload.sub },
        data: {
          jti: payload.jti,
          capabilities: tokenCapabilities,
          required_capabilities: requiredCapabilities
        }
      });
      
      return {
        valid: true,
        claims: payload,
        capabilities: tokenCapabilities
      };
      
    } catch (error) {
      await this.auditLogger.log({
        event_type: 'TOKEN_VALIDATE_FAILURE',
        actor: { type: 'system', id: 'token-service' },
        data: {
          error: error.message,
          required_capabilities: requiredCapabilities,
          plugin_id: pluginId
        }
      });
      
      return {
        valid: false,
        error: error.message
      };
    }
  }

  /**
   * Revoke token by JTI
   * @param {string} jti - Token identifier to revoke
   * @param {string} reason - Revocation reason
   */
  async revokeToken(jti, reason = 'manual_revocation') {
    try {
      // Add to revocation store with appropriate TTL
      const expiresAt = Date.now() + (this.defaultAccessTTL * 1000);
      await this.revocationStore.revoke(jti, expiresAt);
      
      await this.auditLogger.log({
        event_type: 'TOKEN_REVOKE',
        actor: { type: 'system', id: 'token-service' },
        data: {
          jti,
          reason,
          revoked_at: new Date().toISOString()
        }
      });
      
      console.log(`🚫 Token revoked: ${jti} (${reason})`);
    } catch (error) {
      await this.auditLogger.log({
        event_type: 'TOKEN_REVOKE_FAILURE',
        actor: { type: 'system', id: 'token-service' },
        data: {
          jti,
          error: error.message
        }
      });
      throw error;
    }
  }

  /**
   * Refresh access token using refresh token
   * @param {string} refreshToken - Valid refresh token
   * @param {boolean} rotateRefreshToken - Whether to rotate refresh token
   * @returns {object} New tokens
   */
  async refreshAccessToken(refreshToken, rotateRefreshToken = true) {
    try {
      // Validate refresh token
      const validation = await this.validateToken(refreshToken);
      if (!validation.valid) {
        throw new Error(`Invalid refresh token: ${validation.error}`);
      }
      
      const claims = validation.claims;
      if (claims.type !== 'refresh') {
        throw new Error('Not a refresh token');
      }
      
      // Revoke old refresh token if rotating
      if (rotateRefreshToken) {
        await this.revokeToken(claims.jti, 'refresh_rotation');
      }
      
      // Issue new access token with same capabilities as original
      const originalAccessToken = await this.getTokenClaims(claims.access_jti);
      const newTokens = await this.issueToken(
        claims.sub,
        originalAccessToken?.capabilities || [],
        this.defaultAccessTTL,
        originalAccessToken?.plugin_pub
      );
      
      // Issue new refresh token if rotating
      if (rotateRefreshToken) {
        const newRefreshToken = await this.issueRefreshToken(
          claims.sub,
          newTokens.jti
        );
        newTokens.refresh_token = newRefreshToken.refresh_token;
        newTokens.refresh_expires_in = newRefreshToken.expires_in;
      }
      
      await this.auditLogger.log({
        event_type: 'TOKEN_REFRESH',
        actor: { type: 'plugin', id: claims.sub },
        data: {
          old_refresh_jti: claims.jti,
          new_access_jti: newTokens.jti,
          rotated: rotateRefreshToken
        }
      });
      
      return newTokens;
    } catch (error) {
      await this.auditLogger.log({
        event_type: 'TOKEN_REFRESH_FAILURE',
        actor: { type: 'system', id: 'token-service' },
        data: {
          error: error.message
        }
      });
      throw error;
    }
  }

  /**
   * Create signed token from payload
   * @param {object} payload - Token payload
   * @returns {string} Signed token
   */
  createToken(payload) {
    const header = {
      alg: this.algorithm,
      typ: 'JWT',
      kid: this.keyManager.keyId || 'default'
    };
    
    const headerB64 = Buffer.from(JSON.stringify(header)).toString('base64url');
    const payloadB64 = Buffer.from(JSON.stringify(payload)).toString('base64url');
    const message = `${headerB64}.${payloadB64}`;
    
    const signature = crypto.sign(null, Buffer.from(message), this.keyManager.privateKey);
    const signatureB64 = signature.toString('base64url');
    
    return `${message}.${signatureB64}`;
  }

  /**
   * Validate token request parameters
   * @param {string} pluginId - Plugin identifier
   * @param {array} capabilities - Requested capabilities
   * @param {number} ttlSeconds - Token TTL
   */
  validateTokenRequest(pluginId, capabilities, ttlSeconds) {
    if (!pluginId || typeof pluginId !== 'string' || pluginId.length === 0) {
      throw new Error('Valid plugin ID is required');
    }
    
    if (!Array.isArray(capabilities)) {
      throw new Error('Capabilities must be an array');
    }
    
    // Validate capability names
    const validCapabilities = new Set([
      'notify', 'read_env', 'write_env', 'read_files', 'write_files',
      'network', 'execute', 'debug'
    ]);
    
    for (const cap of capabilities) {
      if (!validCapabilities.has(cap)) {
        throw new Error(`Invalid capability: ${cap}`);
      }
    }
    
    if (ttlSeconds !== null && (typeof ttlSeconds !== 'number' || ttlSeconds <= 0)) {
      throw new Error('TTL must be a positive number');
    }
    
    // Enforce maximum TTL for security
    const maxTTL = 24 * 60 * 60; // 24 hours
    if (ttlSeconds > maxTTL) {
      throw new Error(`TTL cannot exceed ${maxTTL} seconds`);
    }
  }

  /**
   * Get token claims without full validation (for internal use)
   * @param {string} jti - Token identifier
   * @returns {object|null} Token claims
   */
  async getTokenClaims(jti) {
    // This would typically query a token store
    // For now, return null as we don't persist active tokens
    return null;
  }

  /**
   * Cleanup expired tokens from revocation store
   */
  async cleanupExpiredTokens() {
    try {
      await this.revocationStore.cleanupExpired();
      console.log('🧹 Cleaned up expired token revocations');
    } catch (error) {
      console.error('Failed to cleanup expired tokens:', error);
    }
  }

  /**
   * Get token service statistics
   * @returns {object} Service statistics
   */
  getStats() {
    return {
      issuer: this.issuer,
      algorithm: this.algorithm,
      default_access_ttl: this.defaultAccessTTL,
      default_refresh_ttl: this.defaultRefreshTTL,
      key_id: this.keyManager.keyId || 'default'
    };
  }
}

module.exports = TokenService;
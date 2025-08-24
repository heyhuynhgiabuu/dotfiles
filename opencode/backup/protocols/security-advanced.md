# Security Advanced Protocol

**LOAD TRIGGER**: Security-sensitive operations, devops/security agents active, or security vulnerabilities detected.

## Security-First Design Principles
- **Defense in Depth**: Multiple layers of security controls
- **Least Privilege**: Minimum permissions required for operations
- **Fail-Safe Defaults**: Secure behavior by default
- **Explicit Authorization**: All operations require explicit permission

## Automated Security Validation

### Pre-Operation Security Checks
```javascript
function validateSecurityPreconditions(operation) {
  // Check user authorization
  if (!isAuthorized(operation.user, operation.action)) {
    throw new SecurityError('Unauthorized access attempt');
  }
  
  // Validate input data
  if (!validateInput(operation.data)) {
    throw new SecurityError('Invalid input data');
  }
  
  // Check rate limits
  if (isRateLimitExceeded(operation.user)) {
    throw new SecurityError('Rate limit exceeded');
  }
  
  // Verify operation context
  if (!isSecureContext(operation.context)) {
    throw new SecurityError('Insecure operation context');
  }
}
```

### Input Validation and Sanitization
```javascript
function validateAndSanitizeInput(input) {
  // Remove potentially dangerous characters
  const sanitized = removeDangerousCharacters(input);
  
  // Validate against expected format
  if (!matchesExpectedFormat(sanitized)) {
    throw new ValidationError('Input format validation failed');
  }
  
  // Check for malicious patterns
  if (containsMaliciousPatterns(sanitized)) {
    throw new SecurityError('Malicious input detected');
  }
  
  // Apply length limits
  if (sanitized.length > MAX_INPUT_LENGTH) {
    throw new ValidationError('Input exceeds maximum length');
  }
  
  return sanitized;
}
```

### Runtime Security Monitoring
```javascript
function monitorSecurityRuntime(operation) {
  // Monitor for anomalies
  const anomalies = detectAnomalies(operation);
  if (anomalies.length > 0) {
    logSecurityEvent('Anomaly detected', { operation, anomalies });
    triggerSecurityAlert(anomalies);
  }
  
  // Check for sensitive data exposure
  if (containsSensitiveData(operation.output)) {
    logSecurityEvent('Sensitive data exposure', { operation });
    sanitizeOutput(operation.output);
  }
  
  // Validate operation integrity
  if (!verifyOperationIntegrity(operation)) {
    throw new SecurityError('Operation integrity check failed');
  }
}
```

## Error Classification with Security Awareness

### Security Error Types
- **Authentication Failures**: Invalid credentials, expired tokens
- **Authorization Violations**: Access control breaches, privilege escalation
- **Input Attacks**: Injection attempts, malicious payloads
- **Data Breaches**: Unauthorized data access, information disclosure

### Security-Aware Error Classification
```javascript
function classifyError(error) {
  // Check for security errors first
  if (isSecurityError(error)) {
    return {
      category: 'SECURITY',
      subcategory: determineSecurityErrorType(error),
      severity: 'HIGH'
    };
  }
  
  // Other error classifications...
  return {
    category: determineCategory(error),
    subcategory: determineSubcategory(error),
    severity: determineSeverity(error),
    requiresSecurityReview: containsSecurityImplications(error)
  };
}
```

## Secure Recovery Strategies

### Security-Aware Retry Strategy
```javascript
function implementSecureRetryStrategy(error, context) {
  // Security errors should not be retried automatically
  if (isSecurityError(error)) {
    logSecurityIncident(error, context);
    throw new SecurityError('Security error - retry not permitted');
  }
  
  const retryConfig = getRetryConfiguration(error);
  let lastError = error;
  
  for (let attempt = 1; attempt <= retryConfig.maxAttempts; attempt++) {
    try {
      // Validate security context before retry
      validateSecurityPreconditions(context);
      
      const result = await retryOperation(context);
      logRetrySuccess(attempt, result);
      return result;
    } catch (retryError) {
      lastError = retryError;
      
      // Stop retrying on security errors
      if (isSecurityError(retryError)) {
        logSecurityIncident(retryError, context);
        throw retryError;
      }
      
      if (!shouldContinueRetry(retryError, attempt, retryConfig)) {
        break;
      }
    }
  }
  
  throw new RetryExhaustedError(lastError, retryConfig.maxAttempts);
}
```

### Circuit Breaker with Security Monitoring
```javascript
class SecureCircuitBreaker {
  constructor(serviceName, options = {}) {
    this.serviceName = serviceName;
    this.failureThreshold = options.failureThreshold || 5;
    this.securityFailureThreshold = options.securityFailureThreshold || 2;
    this.recoveryTimeout = options.recoveryTimeout || 60000;
    this.state = 'CLOSED';
    this.failureCount = 0;
    this.securityFailureCount = 0;
  }
  
  async execute(operation) {
    if (this.state === 'OPEN') {
      if (this.shouldAttemptReset()) {
        this.state = 'HALF_OPEN';
      } else {
        throw new CircuitBreakerOpenError(this.serviceName);
      }
    }
    
    try {
      // Validate security before execution
      validateSecurityPreconditions(operation);
      const result = await operation();
      
      if (this.state === 'HALF_OPEN') {
        this.reset();
      }
      
      return result;
    } catch (error) {
      this.recordFailure(error);
      
      if (this.state === 'HALF_OPEN') {
        this.openCircuit();
      }
      
      throw error;
    }
  }
  
  recordFailure(error) {
    this.failureCount++;
    
    // Track security failures separately
    if (isSecurityError(error)) {
      this.securityFailureCount++;
      
      // Lower threshold for security failures
      if (this.securityFailureCount >= this.securityFailureThreshold) {
        this.openCircuit();
        triggerSecurityAlert('Circuit breaker opened due to security failures');
      }
    }
    
    if (this.failureCount >= this.failureThreshold) {
      this.openCircuit();
    }
  }
}
```

## Security Context Management
- **Context Sanitization**: Remove sensitive data from context
- **Access Control**: Context access based on security clearance
- **Encryption**: Sensitive context data encryption
- **Audit Logging**: Context access and modification logging

## Security Integration by Protocol
- **Workflow Security**: All operations require security validation
- **Agent Communication Security**: Message authentication and integrity
- **Context Security**: Secure context preservation and transmission

## Security Monitoring and Analytics

### Security Event Correlation
```javascript
function correlateSecurityEvents(events) {
  const eventGroups = groupEventsByPattern(events);
  const incidents = identifySecurityIncidents(eventGroups);
  const threatAssessment = assessThreatLevels(incidents);
  
  for (const incident of incidents) {
    if (incident.severity === 'CRITICAL') {
      triggerEmergencySecurityResponse(incident);
    } else if (incident.severity === 'HIGH') {
      triggerSecurityIncidentResponse(incident);
    }
  }
  
  return { eventGroups, incidents, threatAssessment };
}
```

### Security Metrics Dashboard
```javascript
function generateSecurityDashboard() {
  const metrics = {
    securityEvents: getSecurityEventCount(),
    failedAuthentications: getFailedAuthCount(),
    accessViolations: getAccessViolationCount(),
    inputValidationFailures: getInputValidationFailureCount(),
    securityIncidents: getSecurityIncidentCount(),
    threatLevel: getCurrentThreatLevel(),
    complianceStatus: getComplianceStatus()
  };
  
  if (metrics.threatLevel === 'CRITICAL') {
    triggerCriticalSecurityAlert(metrics);
  }
  
  const recommendations = generateSecurityRecommendations(metrics);
  
  return { metrics, recommendations, timestamp: new Date().toISOString() };
}
```

## Expected Security Benefits
- **Security Assurance**: 95%+ security event detection and response
- **Error Resilience**: 90%+ successful error recovery with security preservation
- **Incident Response**: <5 minute detection-to-response time for critical security issues
- **Compliance**: 100% audit trail coverage for security and error events

This protocol provides comprehensive security controls, monitoring, and incident response for secure system operations.
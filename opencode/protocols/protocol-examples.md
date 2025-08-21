# Protocol Examples

## Overview

This file contains shared code examples, XML structures, and implementation patterns used across multiple OpenCode protocols. It serves as a centralized reference to avoid duplication and ensure consistency.

## JavaScript Code Examples

### 1. Validation Functions

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

### 2. Monitoring Functions

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

### 3. Performance Monitoring

```javascript
function monitorPerformance(operation) {
  const startTime = performance.now();
  const startTokens = getCurrentTokenUsage();

  const result = executeOperation(operation);

  const endTime = performance.now();
  const endTokens = getCurrentTokenUsage();

  const metrics = {
    responseTime: endTime - startTime,
    tokenUsage: endTokens - startTokens,
    success: result.success,
    resourceUsage: getResourceUsage()
  };

  updatePerformanceMetrics(metrics);
  checkPerformanceThresholds(metrics);

  return result;
}
```

### 4. Error Handling

```javascript
function implementRetryStrategy(error, context) {
  const retryConfig = getRetryConfiguration(error);

  let lastError = error;

  for (let attempt = 1; attempt <= retryConfig.maxAttempts; attempt++) {
    try {
      // Wait before retry (exponential backoff)
      await wait(calculateBackoffDelay(attempt, retryConfig));

      // Attempt operation
      const result = await retryOperation(context);

      // Log successful retry
      logRetrySuccess(attempt, result);

      return result;
    } catch (retryError) {
      lastError = retryError;

      // Log retry attempt
      logRetryAttempt(attempt, retryError);

      // Check if should continue retrying
      if (!shouldContinueRetry(retryError, attempt, retryConfig)) {
        break;
      }
    }
  }

  // All retries exhausted
  throw new RetryExhaustedError(lastError, retryConfig.maxAttempts);
}
```

## XML Structure Examples

### 1. Agent Communication

```xml
<agent_handoff>
  <source>language_agent</source>
  <target>security_agent</target>
  <context_type>authentication_review</context_type>
  <deliverables>
    <code_artifact>src/auth/jwt-handler.js</code_artifact>
    <test_results>15 tests passing, 3 failing on signature validation</test_results>
    <environment_config>JWT_SECRET, TOKEN_EXPIRY settings</environment_config>
  </deliverables>
  <security_review_needed>
    <concern>JWT secret key security in production</concern>
    <concern>token expiration handling</concern>
    <concern>refresh token implementation</concern>
  </security_review_needed>
  <success_criteria>
    - All security vulnerabilities identified and fixed
    - Production authentication working correctly
    - Security best practices validated
  </success_criteria>
</agent_handoff>
```

### 2. Context Snapshot

```xml
<context_snapshot>
  <mission>implement user authentication system</mission>
  <decomposition>phase_breakdown_with_dependencies</decomposition>
  <critical_decisions>
    <decision id="auth_strategy">JWT with refresh tokens</decision>
    <decision id="database">PostgreSQL with Prisma ORM</decision>
  </critical_decisions>
  <implementation_artifacts>
    <artifact>src/auth/jwt-handler.js</artifact>
    <artifact>src/auth/middleware.js</artifact>
    <artifact>database/schema.prisma</artifact>
  </implementation_artifacts>
  <quality_status>
    <verification_results>security_audit_passed</verification_results>
    <remaining_tasks>integration_testing</remaining_tasks>
  </quality_status>
</context_snapshot>
```

### 3. Event Stream

```xml
<agent_context>
  <meta>
    <event_id>unique_identifier</event_id>
    <timestamp>ISO_8601_format</timestamp>
    <source_agent>agent_name</source_agent>
    <target_agent>agent_name</target_agent>
    <workflow_id>workflow_identifier</workflow_id>
  </meta>
  <state>
    <compressed_context>
      <mission>objective_statement</mission>
      <phase>current_phase_number</phase>
      <critical_decisions>key_decisions_made</critical_decisions>
      <constraints>security_cross_platform_etc</constraints>
    </compressed_context>
    <inputs>explicit_inputs_for_target_agent</inputs>
    <expected_outputs>structured_output_format</expected_outputs>
  </state>
  <context_metrics>
    <scs_size>current_shared_context_tokens</scs_size>
    <aws_size>active_working_set_tokens</aws_size>
    <compression_events>count_since_start</compression_events>
  </context_metrics>
</agent_context>
```

## YAML Examples

### 1. Compressed Context Format

```yaml
# Maximum compression for large workflows
MISSION: full-stack React app with auth|dashboard|admin
PROGRESS: auth✓ dashboard✓ admin-UI✓ testing→
STACK: Next.js|TypeScript|TailwindCSS|PostgreSQL|JWT
PHASES: [1]research✓ [2]arch✓ [3]implement✓ [4]test→ [5]deploy
CURRENT: integration testing phase 4 of 5
BLOCKS: CORS issues in production, DB connection pool limits
FIXES_TRIED: cors middleware✓ connection strings✓ env vars✓
DECISIONS: |auth:JWT+refresh| |db:PostgreSQL+Prisma| |deploy:Vercel|
CONSTRAINTS: |cross-platform| |no-new-major-deps| |API-backward-compat|
NEXT: resolve CORS for production deployment, optimize DB connections
CONTEXT: 3 weeks dev, 2 blockers remaining, target production next week
```

### 2. Micro Context Format

```yaml
GOAL: fix authentication bug
STATUS: debugging JWT validation
ERROR: token signature verification failed
NEXT: check secret key configuration
```

## Protocol-Specific Patterns

### 1. Security Validation Pattern

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

### 2. Context Compression Pattern

```javascript
function compressContext(context, compressionLevel) {
  // Level 1: Basic deduplication
  if (compressionLevel >= 1) {
    context = applyDeduplication(context);
  }

  // Level 2: Semantic compression
  if (compressionLevel >= 2) {
    context = applySemanticCompression(context);
  }

  // Level 3: Lossy compression
  if (compressionLevel >= 3) {
    context = applyLossyCompression(context);
  }

  // Level 4: Extreme compression
  if (compressionLevel >= 4) {
    context = applyExtremeCompression(context);
  }

  return {
    compressedContext: context,
    compressionRatio: calculateCompressionRatio(context),
    quality: assessCompressionQuality(context)
  };
}
```

### 3. Workflow Checkpoint Pattern

```javascript
function generateWorkflowCheckpoint(workflowId, stage, context) {
  const checkpointId = `workflow_${workflowId}_stage_${stage}_complete`;

  const checkpoint = {
    checkpoint_id: checkpointId,
    timestamp: new Date().toISOString(),
    workflow_state: {
      stage_completed: stage,
      next_stage: getNextStage(stage),
      progress_percentage: calculateProgress(stage)
    },
    context_snapshot: createContextSnapshot(context),
    resume_instructions: generateResumeInstructions(stage, context)
  };

  // Store checkpoint
  storeCheckpoint(checkpoint);

  return checkpoint;
}
```

## Error Handling Patterns

### 1. Circuit Breaker Pattern

```javascript
class CircuitBreaker {
  constructor(serviceName, options = {}) {
    this.serviceName = serviceName;
    this.failureThreshold = options.failureThreshold || 5;
    this.recoveryTimeout = options.recoveryTimeout || 60000;
    this.monitoringPeriod = options.monitoringPeriod || 10000;

    this.state = 'CLOSED'; // CLOSED, OPEN, HALF_OPEN
    this.failureCount = 0;
    this.lastFailureTime = null;
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
      const result = await operation();

      if (this.state === 'HALF_OPEN') {
        this.reset();
      }

      return result;
    } catch (error) {
      this.recordFailure();

      if (this.state === 'HALF_OPEN') {
        this.openCircuit();
      }

      throw error;
    }
  }

  recordFailure() {
    this.failureCount++;
    this.lastFailureTime = Date.now();

    if (this.failureCount >= this.failureThreshold) {
      this.openCircuit();
    }
  }

  openCircuit() {
    this.state = 'OPEN';
    logCircuitBreakerOpen(this.serviceName);
  }

  reset() {
    this.state = 'CLOSED';
    this.failureCount = 0;
    this.lastFailureTime = null;
    logCircuitBreakerReset(this.serviceName);
  }

  shouldAttemptReset() {
    return this.lastFailureTime &&
           (Date.now() - this.lastFailureTime) > this.recoveryTimeout;
  }
}
```

### 2. Graceful Degradation Pattern

```javascript
function implementGracefulDegradation(error, context) {
  // Assess system capacity and requirements
  const systemCapacity = assessSystemCapacity();
  const operationRequirements = getOperationRequirements(context);

  // Determine degradation strategy
  const degradationStrategy = selectDegradationStrategy(
    systemCapacity,
    operationRequirements
  );

  // Apply degradation
  switch (degradationStrategy) {
    case 'REDUCE_QUALITY':
      return executeWithReducedQuality(context);
    case 'LIMIT_FEATURES':
      return executeWithLimitedFeatures(context);
    case 'DELAY_PROCESSING':
      return scheduleForLater(context);
    case 'USE_CACHE':
      return executeFromCache(context);
    default:
      throw new DegradationFailedError(error);
  }
}
```

## Performance Optimization Patterns

### 1. Resource-Aware Processing

```javascript
function optimizeResourceUsage(operation) {
  const resources = assessAvailableResources();
  const operationRequirements = getOperationRequirements(operation);

  if (resources.cpu < operationRequirements.cpu) {
    return scheduleForLater(operation);
  }

  if (resources.memory < operationRequirements.memory) {
    return useMemoryOptimizedVersion(operation);
  }

  return executeWithOptimalResources(operation);
}
```

### 2. Intelligent Caching

```javascript
function getCachedResult(operation) {
  const cacheKey = generateCacheKey(operation);

  if (cache.has(cacheKey)) {
    const cached = cache.get(cacheKey);
    if (isCacheValid(cached)) {
      return cached.result;
    } else {
      cache.delete(cacheKey);
    }
  }

  const result = executeOperation(operation);
  cache.set(cacheKey, { result, timestamp: Date.now() });

  return result;
}
```

## Best Practices

### 1. Code Example Guidelines
- Include realistic, working examples
- Use consistent naming conventions
- Add comments explaining complex logic
- Test examples before including them
- Keep examples focused and concise

### 2. XML Structure Guidelines
- Use consistent indentation and formatting
- Include all required elements
- Add comments for complex structures
- Validate XML syntax
- Follow established schema patterns

### 3. Pattern Documentation
- Document the purpose of each pattern
- Include usage examples
- Explain benefits and trade-offs
- Reference related patterns
- Update patterns as protocols evolve

This file serves as the central repository for all shared examples and patterns used across OpenCode protocols, ensuring consistency and reducing duplication.
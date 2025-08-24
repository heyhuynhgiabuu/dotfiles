# Shared Schemas and Examples Protocol

## Overview

This protocol consolidates all shared schemas, XML structures, code examples, and implementation patterns used across OpenCode protocols. It serves as the single source of truth for data structures, event formats, and reusable code patterns.

## Core Event Schema (12-Factor Compliant)

All agent events MUST follow this base schema for stateless operations and workflow resumability:

```xml
<agent_event>
  <meta>
    <event_id>unique_identifier_[timestamp]_[source]_[target]</event_id>
    <timestamp>ISO_8601_format</timestamp>
    <event_type>workflow_start|phase_start|phase_complete|checkpoint|error_recovery|workflow_complete</event_type>
    <source_agent>originating_agent_name</source_agent>
    <target_agent>receiving_agent_name_or_user</target_agent>
    <workflow_id>persistent_workflow_identifier</workflow_id>
    <phase_id>current_phase_number</phase_id>
  </meta>
  
  <context>
    <mission>core_objective_statement</mission>
    <constraints>
      <cross_platform>macOS_and_Linux</cross_platform>
      <dependencies>no_new_without_approval</dependencies>
      <security>applicable_security_requirements</security>
      <permissions>opencode_json_constraints</permissions>
    </constraints>
    <previous_outputs>structured_results_from_prior_phases</previous_outputs>
    <current_inputs>explicit_inputs_for_current_phase</current_inputs>
    <expected_outputs>structured_format_for_deliverables</expected_outputs>
  </context>
  
  <state>
    <critical_decisions>
      <decision id="key_choice_1">chosen_approach_with_rationale</decision>
      <decision id="key_choice_2">selected_technology_with_justification</decision>
    </critical_decisions>
    <active_risks>
      <risk id="security_concern">mitigation_approach</risk>
      <risk id="platform_compatibility">validation_strategy</risk>
    </active_risks>
    <quality_gates>
      <gate>security_review_required</gate>
      <gate>cross_platform_testing</gate>
      <gate>code_review_standards</gate>
    </quality_gates>
  </state>
  
  <metrics>
    <context_size>
      <scs_tokens>shared_context_slice_size</scs_tokens>
      <aws_tokens>active_working_set_size</aws_tokens>
      <compression_ratio>percentage_if_compressed</compression_ratio>
    </context_size>
    <workflow_progress>
      <phases_complete>number</phases_complete>
      <phases_remaining>number</phases_remaining>
      <estimated_completion>percentage</estimated_completion>
    </workflow_progress>
  </metrics>
</agent_event>
```

## Event Types and Specialized Schemas

### 1. Workflow Start Event

```xml
<agent_event>
  <meta>
    <event_type>workflow_start</event_type>
    <source_agent>alpha</source_agent>
    <target_agent>workflow_system</target_agent>
  </meta>
  <context>
    <mission>detailed_user_request_and_objective</mission>
    <scope>
      <complexity>simple|complex|multi_phase</complexity>
      <estimated_phases>number</estimated_phases>
      <agent_assignments>
        <phase id="1" agent="beta">analysis_and_architecture</phase>
        <phase id="2" agent="language">implementation</phase>
        <phase id="3" agent="security">vulnerability_audit</phase>
      </agent_assignments>
    </scope>
  </context>
  <state>
    <decomposition_complete>true</decomposition_complete>
    <chrome_auto_start>required|not_required</chrome_auto_start>
    <user_checkpoints>
      <checkpoint phase="1">architecture_approval</checkpoint>
      <checkpoint phase="3">security_signoff</checkpoint>
    </user_checkpoints>
  </state>
</agent_event>
```

### 2. Phase Handoff Event

```xml
<agent_event>
  <meta>
    <event_type>phase_start</event_type>
    <source_agent>alpha</source_agent>
    <target_agent>specialized_agent_name</target_agent>
  </meta>
  <context>
    <phase_objective>specific_deliverable_for_this_phase</phase_objective>
    <task_details>
      <primary_task>main_deliverable</primary_task>
      <secondary_tasks>
        <task>validation_requirement</task>
        <task>documentation_update</task>
      </secondary_tasks>
    </task_details>
    <required_tools>
      <tool>webfetch_for_research</tool>
      <tool>chrome_mcp_if_needed</tool>
      <tool>context_analysis</tool>
    </required_tools>
  </context>
  <state>
    <phase_autonomy>
      <autonomous_execution>true</autonomous_execution>
      <approval_gates>security_review_only</approval_gates>
      <escalation_triggers>
        <trigger>unknown_dependency_found</trigger>
        <trigger>security_vulnerability_detected</trigger>
      </escalation_triggers>
    </phase_autonomy>
  </state>
</agent_event>
```

### 3. Context Snapshot Schema

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

### 4. Error Recovery Schema

```xml
<error_checkpoint>
  <checkpoint_id>workflow_[id]_error_[error_type]</checkpoint_id>
  <error_context>
    <error_type>permission_denied|dependency_missing|context_overflow|anchor_ambiguity</error_type>
    <error_location>specific_step_or_phase_where_error_occurred</error_location>
    <attempted_resolution>what_was_tried_to_resolve</attempted_resolution>
    <partial_completion>work_completed_before_error</partial_completion>
  </error_context>
  <recovery_strategy>
    <immediate_options>
      <option priority="high">retry_with_adjusted_parameters</option>
      <option priority="medium">escalate_to_specialized_agent</option>
      <option priority="low">request_user_intervention</option>
    </immediate_options>
    <rollback_required>true|false</rollback_required>
    <context_integrity>preserved|needs_reconstruction</context_integrity>
  </recovery_strategy>
  <resume_plan>
    <recovery_steps>specific_actions_to_resolve_error</recovery_steps>
    <validation_steps>how_to_verify_resolution</validation_steps>
    <continuation_point>where_to_resume_workflow</continuation_point>
  </resume_plan>
</error_checkpoint>
```

## JavaScript Implementation Patterns

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

### 2. Performance Monitoring

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

### 3. Error Handling Patterns

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

### 4. Context Management Patterns

```javascript
function selectOptimalContextFormat(contextSize, agentType, operationType) {
  // Micro context for small tasks
  if (contextSize < 500) {
    return CompressedYAMLFormat();
  }

  // Standard context for medium tasks
  if (contextSize < 2000) {
    return SingleMessageXMLFormat();
  }

  // Event stream for inter-agent communication
  if (operationType === "inter_agent") {
    return EventStreamFormat();
  }

  // Maximum compression for large contexts
  return TokenOptimizedFormat();
}
```

### 5. Security Monitoring

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

### 6. Agent Communication Patterns

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

## YAML Format Examples

### 1. Compressed Context Format

```yaml
# Ultra-compressed context for large workflows
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

## Configuration Schemas

### 1. Agent Configuration Schema

```json
{
  "agent_name": {
    "model": "claude-3-5-sonnet-20241022",
    "instructions": "path/to/prompt.md",
    "tools": ["tool1", "tool2"],
    "capabilities": {
      "technical": ["languages", "frameworks"],
      "cognitive": ["problemSolving", "creativity"],
      "operational": ["taskManagement", "errorHandling"]
    },
    "specialization": {
      "domain": "category",
      "expertise_level": "expert|intermediate|basic"
    }
  }
}
```

### 2. Context Quality Metrics Schema

```json
{
  "relevance_metrics": {
    "relevance_score": 0.85,
    "critical_info_placement": 0.92,
    "redundancy_ratio": 0.12,
    "staleness_ratio": 0.08
  },
  "structure_metrics": {
    "information_density": 0.78,
    "block_size_avg": 145,
    "boundary_clarity": "adequate",
    "flow_disruption_score": "optimized"
  },
  "performance_metrics": {
    "response_quality": 0.89,
    "processing_time": 2.3,
    "error_rate": 0.05,
    "consistency_score": 0.91
  }
}
```

## Event Validation Rules

### 1. Required Fields Validation
- All meta, context.mission, and state sections must be present
- event_id must be unique across the entire workflow
- timestamp must be sequential within workflow
- source_agent and target_agent must be valid agent names

### 2. Context Completeness Validation
- Receiving agent must have complete context for autonomous operation
- Critical decisions and constraints must be preserved across events
- All events must validate against the base schema
- Compressed contexts must retain all critical information

### 3. Schema Compliance Validation

```javascript
function validateEventSchema(event) {
  // Validate required fields
  const requiredFields = ['meta', 'context', 'state', 'metrics'];
  for (const field of requiredFields) {
    if (!event[field]) {
      throw new SchemaValidationError(`Missing required field: ${field}`);
    }
  }

  // Validate event structure
  if (!isValidEventStructure(event)) {
    throw new SchemaValidationError('Invalid event structure');
  }

  // Validate context completeness
  if (!hasCompleteContext(event.context)) {
    throw new SchemaValidationError('Incomplete context for autonomous operation');
  }

  return { valid: true, event: event };
}
```

## Best Practices

### 1. Schema Design Guidelines
- Use consistent naming conventions across all schemas
- Include validation rules and constraints
- Provide clear documentation for each field
- Design for extensibility and backward compatibility

### 2. Event Generation Guidelines
- Include sufficient context for autonomous operation
- Use descriptive event and checkpoint identifiers
- Validate event data before transmission
- Include performance and quality metrics

### 3. Code Pattern Guidelines
- Include realistic, working examples
- Use consistent naming and formatting
- Add comments explaining complex logic
- Test all patterns before inclusion

### 4. Implementation Guidelines
- Follow established schema patterns
- Validate all data against schemas
- Handle schema evolution gracefully
- Monitor schema compliance continuously

## Integration References

This protocol provides the foundational schemas and patterns for:
- **Unified Context Protocol**: Event formats and context structures
- **Workflow Protocol**: Checkpoint and state schemas
- **Security Protocol**: Validation and monitoring patterns
- **Agent Specialization**: Communication and handoff schemas

All other protocols reference and extend these base schemas for consistent system-wide data structure and communication patterns.

## Expected Benefits

- **Consistency**: 100% consistent data structures across all protocols
- **Validation**: Comprehensive schema validation prevents data corruption
- **Interoperability**: Seamless communication between all system components
- **Maintainability**: Centralized schema management reduces duplication
- **Performance**: Optimized data structures for efficient processing

## Implementation Checklist

- [ ] Core event schema implemented and validated
- [ ] All specialized event types defined
- [ ] JavaScript patterns tested and documented
- [ ] YAML format examples validated
- [ ] Configuration schemas established
- [ ] Event validation rules implemented
- [ ] Integration with all protocols verified
- [ ] Schema evolution strategy defined

This consolidated protocol serves as the single source of truth for all data structures, event formats, and implementation patterns across the OpenCode system.
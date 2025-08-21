# Checkpoint Schema Protocol

## Overview

This protocol defines the unified checkpoint schema and structures used across all OpenCode agent workflows. It consolidates checkpoint definitions, XML structures, and validation rules into a single, authoritative reference.

## Checkpoint Types

### 1. Phase Boundary Checkpoints

Generated after each major workflow phase to enable resumability:

```xml
<workflow_checkpoint>
  <checkpoint_id>workflow_[id]_stage_[n]_complete</checkpoint_id>
  <timestamp>ISO_8601_format</timestamp>
  <workflow_state>
    <stage_completed>mission_planning|implementation|verification</stage_completed>
    <next_stage>implementation|verification|complete</stage_completed>
    <progress_percentage>33|67|100</progress_percentage>
  </workflow_state>
  <context_snapshot>
    <mission>original_user_request_and_objective</mission>
    <decomposition>phase_breakdown_with_dependencies</decomposition>
    <critical_decisions>
      <decision id="architecture">chosen_approach_with_rationale</decision>
      <decision id="technology">selected_tools_and_libraries</decision>
    </critical_decisions>
    <implementation_artifacts>
      <artifact>file_created_or_modified</artifact>
      <artifact>configuration_change</artifact>
    </implementation_artifacts>
    <quality_status>
      <verification_results>security_cross_platform_code_review</verification_results>
      <remaining_tasks>items_still_pending</remaining_tasks>
    </quality_status>
  </context_snapshot>
  <resume_instructions>
    <next_step>specific_action_to_take</next_step>
    <required_context>information_needed_for_continuation</required_context>
    <validation_required>context_integrity_check</validation_required>
  </resume_instructions>
</workflow_checkpoint>
```

### 2. User Approval Checkpoints

Generated when user decision impacts workflow direction:

```xml
<approval_checkpoint>
  <checkpoint_id>workflow_[id]_approval_[decision_point]</checkpoint_id>
  <decision_required>
    <decision_type>architecture_choice|technology_selection|approach_validation</decision_type>
    <options>
      <option id="1" pros="benefits" cons="limitations">approach_description</option>
      <option id="2" pros="benefits" cons="limitations">alternative_approach</option>
    </options>
    <recommendation>preferred_option_with_rationale</recommendation>
  </decision_required>
  <context_for_decision>
    <analysis_complete>research_and_impact_assessment</analysis_complete>
    <trade_offs>detailed_comparison_of_approaches</trade_offs>
    <implications>long_term_consequences_of_choice</implications>
  </context_for_decision>
  <workflow_continuation>
    <on_approval>continue_with_implementation</on_approval>
    <on_rejection>return_to_planning_with_feedback</on_rejection>
    <on_modification>adjust_approach_based_on_input</on_modification>
  </workflow_continuation>
</approval_checkpoint>
```

### 3. Error Recovery Checkpoints

Generated when workflow encounters blocking issues:

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

## Checkpoint Implementation

### 1. Checkpoint Generation

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

### 2. Checkpoint Storage

```javascript
function storeCheckpoint(checkpoint) {
  // Store using Serena memory system
  const memoryKey = `checkpoint_${checkpoint.checkpoint_id}`;

  serena_write_memory({
    memory_name: memoryKey,
    content: JSON.stringify(checkpoint, null, 2)
  });

  // Update checkpoint index
  updateCheckpointIndex(checkpoint);
}
```

### 3. Checkpoint Retrieval

```javascript
function retrieveCheckpoint(checkpointId) {
  const memoryKey = `checkpoint_${checkpointId}`;

  const checkpointData = serena_read_memory(memoryKey);

  if (!checkpointData) {
    throw new CheckpointNotFoundError(checkpointId);
  }

  return JSON.parse(checkpointData);
}
```

## Checkpoint Validation

### 1. Context Integrity Validation

```javascript
function validateCheckpointContext(checkpoint) {
  // Validate required fields
  const requiredFields = [
    'checkpoint_id',
    'timestamp',
    'workflow_state',
    'context_snapshot',
    'resume_instructions'
  ];

  for (const field of requiredFields) {
    if (!checkpoint[field]) {
      throw new CheckpointValidationError(`Missing required field: ${field}`);
    }
  }

  // Validate context snapshot
  validateContextSnapshot(checkpoint.context_snapshot);

  // Validate resume instructions
  validateResumeInstructions(checkpoint.resume_instructions);

  return {
    valid: true,
    validation_details: 'All checkpoint validations passed'
  };
}
```

### 2. Resume Capability Validation

```javascript
function validateResumeCapability(checkpoint) {
  // Check if all referenced resources exist
  const resourcesValid = validateReferencedResources(checkpoint);

  // Check if context is still relevant
  const contextRelevance = assessContextRelevance(checkpoint);

  // Check if workflow can continue from this point
  const continuationFeasibility = assessContinuationFeasibility(checkpoint);

  return {
    canResume: resourcesValid && contextRelevance && continuationFeasibility,
    issues: identifyResumeIssues(checkpoint),
    recommendations: generateResumeRecommendations(checkpoint)
  };
}
```

## Checkpoint Management

### 1. Checkpoint Lifecycle

```javascript
function manageCheckpointLifecycle(workflowId) {
  // Get all checkpoints for workflow
  const checkpoints = getWorkflowCheckpoints(workflowId);

  // Identify active checkpoint
  const activeCheckpoint = findActiveCheckpoint(checkpoints);

  // Clean up old checkpoints
  cleanupOldCheckpoints(checkpoints, activeCheckpoint);

  // Archive completed workflow checkpoints
  archiveCompletedWorkflowCheckpoints(workflowId, checkpoints);

  return {
    activeCheckpoint: activeCheckpoint,
    cleanedCount: checkpoints.length - getRemainingCheckpoints(workflowId),
    archivedCount: getArchivedCheckpoints(workflowId)
  };
}
```

### 2. Checkpoint Cleanup

```javascript
function cleanupOldCheckpoints(checkpoints, activeCheckpoint) {
  const retentionPolicy = getCheckpointRetentionPolicy();

  const checkpointsToRemove = checkpoints.filter(checkpoint =>
    shouldRemoveCheckpoint(checkpoint, activeCheckpoint, retentionPolicy)
  );

  for (const checkpoint of checkpointsToRemove) {
    removeCheckpoint(checkpoint.checkpoint_id);
  }

  return checkpointsToRemove.length;
}
```

## Integration with Protocols

### 1. Workflow Protocol Integration

**13-Step Workflow Checkpoints**:
- **Stage 1 Checkpoint**: After mission planning completion
- **Stage 2 Checkpoint**: After implementation completion
- **Stage 3 Checkpoint**: After verification completion

### 2. Context Management Integration

**Context Preservation Checkpoints**:
- **Compression Checkpoints**: After context compression events
- **Version Checkpoints**: After context version changes
- **State Checkpoints**: After significant state changes

### 3. Error Handling Integration

**Error Recovery Checkpoints**:
- **Error State Checkpoints**: Capture state before error
- **Recovery Checkpoints**: After successful error recovery
- **Rollback Checkpoints**: After error rollback operations

## Checkpoint Best Practices

### 1. Checkpoint Creation
- Create checkpoints at logical workflow boundaries
- Include sufficient context for autonomous resumption
- Use descriptive checkpoint identifiers
- Validate checkpoint data before storage

### 2. Checkpoint Usage
- Validate checkpoint integrity before resuming
- Check context relevance before using checkpoint data
- Handle checkpoint corruption gracefully
- Provide clear error messages for invalid checkpoints

### 3. Checkpoint Maintenance
- Implement retention policies for old checkpoints
- Regularly validate stored checkpoints
- Clean up unused or obsolete checkpoints
- Monitor checkpoint storage usage

## Schema Validation

### 1. XML Schema Definition

```xml
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:element name="workflow_checkpoint">
    <xs:complexType>
      <xs:sequence>
        <xs:element name="checkpoint_id" type="xs:string"/>
        <xs:element name="timestamp" type="xs:dateTime"/>
        <xs:element name="workflow_state" type="workflowStateType"/>
        <xs:element name="context_snapshot" type="contextSnapshotType"/>
        <xs:element name="resume_instructions" type="resumeInstructionsType"/>
      </xs:sequence>
    </xs:complexType>
  </xs:element>

  <xs:complexType name="workflowStateType">
    <xs:sequence>
      <xs:element name="stage_completed" type="xs:string"/>
      <xs:element name="next_stage" type="xs:string"/>
      <xs:element name="progress_percentage" type="xs:int"/>
    </xs:sequence>
  </xs:complexType>

  <xs:complexType name="contextSnapshotType">
    <xs:sequence>
      <xs:element name="mission" type="xs:string"/>
      <xs:element name="decomposition" type="xs:string"/>
      <xs:element name="critical_decisions" type="criticalDecisionsType"/>
      <xs:element name="implementation_artifacts" type="artifactsType"/>
      <xs:element name="quality_status" type="qualityStatusType"/>
    </xs:sequence>
  </xs:complexType>

  <xs:complexType name="resumeInstructionsType">
    <xs:sequence>
      <xs:element name="next_step" type="xs:string"/>
      <xs:element name="required_context" type="xs:string"/>
      <xs:element name="validation_required" type="xs:string"/>
    </xs:sequence>
  </xs:complexType>
</xs:schema>
```

### 2. Schema Validation Implementation

```javascript
function validateCheckpointSchema(checkpoint) {
  // Load XML schema
  const schema = loadCheckpointSchema();

  // Parse checkpoint as XML
  const checkpointXml = convertToXml(checkpoint);

  // Validate against schema
  const validationResult = validateXmlAgainstSchema(checkpointXml, schema);

  if (!validationResult.valid) {
    throw new SchemaValidationError(validationResult.errors);
  }

  return {
    valid: true,
    schemaVersion: schema.version,
    validationDetails: validationResult.details
  };
}
```

## Monitoring and Analytics

### 1. Checkpoint Metrics

```javascript
function collectCheckpointMetrics() {
  const metrics = {
    totalCheckpoints: getTotalCheckpointCount(),
    activeCheckpoints: getActiveCheckpointCount(),
    storageUsage: getCheckpointStorageUsage(),
    averageSize: getAverageCheckpointSize(),
    creationRate: getCheckpointCreationRate(),
    usageRate: getCheckpointUsageRate(),
    successRate: getCheckpointResumeSuccessRate()
  };

  // Store metrics for analysis
  storeCheckpointMetrics(metrics);

  // Generate checkpoint health report
  generateCheckpointHealthReport(metrics);

  return metrics;
}
```

### 2. Checkpoint Health Monitoring

```javascript
function monitorCheckpointHealth() {
  // Check checkpoint storage health
  const storageHealth = checkCheckpointStorageHealth();

  // Validate random sample of checkpoints
  const validationResults = validateCheckpointSample();

  // Check for corruption patterns
  const corruptionPatterns = detectCorruptionPatterns();

  // Generate health report
  const healthReport = {
    storageHealth: storageHealth,
    validationResults: validationResults,
    corruptionPatterns: corruptionPatterns,
    recommendations: generateHealthRecommendations(storageHealth, validationResults)
  };

  // Alert on critical issues
  if (healthReport.criticalIssues > 0) {
    triggerCheckpointHealthAlert(healthReport);
  }

  return healthReport;
}
```

This protocol provides the complete checkpoint schema and management system for all OpenCode agent workflows, ensuring consistent, reliable, and resumable operations across the entire system.
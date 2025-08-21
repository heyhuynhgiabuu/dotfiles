# Workflow Checkpoints Protocol

## Overview

This protocol defines the checkpoint architecture for workflow persistence and resumability, enabling workflows to pause and resume from any major phase boundary.

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

For complete checkpoint implementation details, see `checkpoint-schema.md` which provides:

- **Storage Strategy**: Memory storage using Serena system
- **Context Compression**: Techniques for minimizing checkpoint size
- **Resume Validation**: Complete validation protocol for checkpoint resumption
- **Error Handling**: Recovery mechanisms for invalid checkpoints

### Integration Reference
Use the checkpoint schema protocol for all checkpoint-related implementations, including storage, validation, and resumption logic.

## Checkpoint Persistence Strategy

**Memory Storage**: Store checkpoints using the serena memory system for cross-session persistence:

```
serena_write_memory(
  memory_name="workflow_[id]_checkpoint_[timestamp]",
  content=structured_checkpoint_xml
)
```

**Context Compression**: Minimize checkpoint size while preserving critical information:
- Compress verbose reasoning into bullet outcomes
- Abstract repeated patterns into references
- Maintain complete context for autonomous resumption
- Preserve all critical decisions and constraints

## Resume Validation Protocol

**Before resuming any workflow from checkpoint:**

1. **Context Integrity Check**: Validate that all referenced files, decisions, and constraints are still valid
2. **Environment Verification**: Confirm that dependencies, permissions, and platform requirements remain unchanged
3. **Progress Validation**: Verify that completed steps are still in expected state
4. **Agent Capability Check**: Ensure required agents and tools are available for continuation

**Resume Workflow**:
```xml
<resume_validation>
  <checkpoint_validity>
    <context_current>true|false</context_current>
    <dependencies_available>true|false</dependencies_available>
    <progress_intact>true|false</progress_intact>
    <agent_capabilities>verified|needs_update</agent_capabilities>
  </checkpoint_validity>
  <resume_action>
    <validation_passed>continue_from_checkpoint</validation_passed>
    <validation_failed>reconstruct_context_and_retry</validation_failed>
    <partial_validity>selective_replay_from_last_valid_point</partial_validity>
  </resume_action>
</resume_validation>
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

## Integration with Other Protocols

### Context Management Integration
- Apply checkpoint compression using Context Rot principles
- Preserve context integrity across checkpoint boundaries
- Validate context consistency during checkpoint operations
- Optimize checkpoint storage using context compression techniques

### Workflow Integration
- Generate checkpoints at logical workflow boundaries
- Enable workflow resumption from any checkpoint
- Maintain workflow state consistency across checkpoints
- Handle workflow interruption gracefully with checkpoints

### Error Handling Integration
- Create error recovery checkpoints for workflow failures
- Enable workflow rollback to previous checkpoints
- Preserve error context for debugging and recovery
- Implement checkpoint-based error recovery strategies

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

## Expected Benefits

- **Workflow Resumability**: Resume workflows from any major phase boundary
- **Error Recovery**: Quick recovery from workflow failures
- **Context Preservation**: Maintain complete workflow context across sessions
- **Debugging Support**: Detailed checkpoint history for troubleshooting
- **Resource Efficiency**: Optimized checkpoint storage and retrieval

This protocol provides the complete checkpoint architecture for workflow persistence, enabling robust, resumable, and reliable workflow execution across the OpenCode agent system.
# Control Flow Protocol

## Overview

This protocol defines the control flow ownership and management system, enabling custom loop control with human approval breaks, async operation handling, and intelligent workflow pausing between tool selection and execution.

## Core Principle

**"If you own your control flow, you can do lots of fun things."**

Own control flow implementation enables custom loop control with human approval breaks, async operation handling, and intelligent workflow pausing between tool selection and execution.

## Control Flow Categories

### Immediate Operations (Continue Loop)
- Safe read operations (file reads, status checks)
- Low-risk calculations and analysis
- Information gathering and research
- Local file system operations (non-destructive)

### Approval Required Operations (Break Loop)
- File writes and edits
- External API calls
- System configuration changes
- Deployment or build operations
- Database modifications

### Human Review Operations (Break Loop + Human Validation)
- High-stakes destructive operations
- Security-sensitive changes
- Architecture decisions with broad impact
- Operations that could affect production systems

## Control Flow Implementation

### Core Loop Structure

```python
def handle_workflow_step(workflow_thread: WorkflowThread):
    while True:
        # Get next step from LLM
        next_step = await determine_next_step(
            context=format_context(workflow_thread),
            format=select_optimal_context_format(workflow_thread.size)
        )

        # Log the intended action
        workflow_thread.events.append({
            'type': 'action_planned',
            'action': next_step,
            'timestamp': datetime.now().isoformat()
        })

        # Apply control flow logic
        if next_step.intent == 'research_information':
            # IMMEDIATE: Safe read operation - continue loop
            result = await execute_research(next_step)
            workflow_thread.events.append({
                'type': 'research_completed',
                'result': result,
                'timestamp': datetime.now().isoformat()
            })
            continue

        elif next_step.intent == 'edit_file':
            # APPROVAL REQUIRED: File modification - break loop
            workflow_thread.events.append({
                'type': 'approval_requested',
                'operation': next_step,
                'risk_level': 'medium'
            })
            await save_checkpoint(workflow_thread)
            await request_approval(next_step, risk_level='medium')
            break  # Wait for approval webhook

        elif next_step.intent == 'deploy_to_production':
            # HUMAN REVIEW: High-stakes operation - break loop with validation
            workflow_thread.events.append({
                'type': 'human_review_required',
                'operation': next_step,
                'risk_level': 'high',
                'review_criteria': [
                    'security_implications',
                    'rollback_strategy',
                    'impact_assessment'
                ]
            })
            await save_checkpoint(workflow_thread)
            await require_human_review(next_step, criteria=['security', 'rollback', 'impact'])
            break  # Wait for human validation

        elif next_step.intent == 'request_clarification':
            # ASYNC: Human input needed - break loop
            workflow_thread.events.append({
                'type': 'clarification_requested',
                'question': next_step.question
            })
            await save_checkpoint(workflow_thread)
            await request_user_input(next_step.question)
            break  # Wait for user response

        elif next_step.intent == 'workflow_complete':
            # COMPLETION: Generate final checkpoint and exit
            await generate_completion_checkpoint(workflow_thread)
            return next_step.final_result
```

### Operation Risk Classification

**Risk Assessment Matrix**:
```python
def classify_operation_risk(operation: Operation) -> RiskLevel:
    if operation.category == 'read_only':
        return RiskLevel.IMMEDIATE
    elif operation.affects == 'local_files' and operation.type == 'write':
        return RiskLevel.APPROVAL_REQUIRED
    elif operation.affects == 'external_systems':
        return RiskLevel.APPROVAL_REQUIRED
    elif operation.affects == 'production' or operation.type == 'destructive':
        return RiskLevel.HUMAN_REVIEW
    else:
        return RiskLevel.APPROVAL_REQUIRED  # Default to safe
```

### Custom Control Flow Examples

1. **Development Workflow**:
```python
# Research (immediate) → Planning (immediate) → Implementation (approval) → Testing (approval) → Deployment (human review)
```

2. **Security Audit**:
```python
# Code Analysis (immediate) → Vulnerability Detection (immediate) → Fix Recommendations (approval) → Apply Fixes (human review)
```

3. **Architecture Decision**:
```python
# Requirements Analysis (immediate) → Option Research (immediate) → Impact Assessment (immediate) → Decision Recommendation (human review)
```

## Async Operation Handling

### Long-Running Operations

```python
async def handle_long_running_operation(workflow_thread: WorkflowThread, operation: Operation):
    # Start operation
    workflow_thread.events.append({
        'type': 'long_operation_started',
        'operation_id': operation.id,
        'estimated_duration': operation.estimated_time
    })

    # Save checkpoint before starting
    await save_checkpoint(workflow_thread)

    # Initiate operation (CI/CD, training, external API, etc.)
    task_id = await start_async_operation(operation)

    # Break loop - will resume via webhook when complete
    await register_completion_webhook(task_id, workflow_thread.id)
    return 'PAUSED_FOR_ASYNC_OPERATION'
```

### Resume After Async Operation

```python
async def handle_async_completion(webhook_data: WebhookData):
    workflow_thread = await load_workflow(webhook_data.workflow_id)

    # Add completion event
    workflow_thread.events.append({
        'type': 'async_operation_completed',
        'operation_id': webhook_data.operation_id,
        'result': webhook_data.result,
        'success': webhook_data.success
    })

    # Resume workflow from checkpoint
    await resume_workflow(workflow_thread)
```

## Human-in-the-Loop Integration

### Approval Request Format

```xml
<approval_request>
  <operation_summary>brief description of intended action</operation_summary>
  <risk_assessment>
    <risk_level>medium|high</risk_level>
    <potential_impact>what could go wrong</potential_impact>
    <mitigation_strategy>how to handle failures</mitigation_strategy>
  </risk_assessment>
  <context>
    <current_state>where we are in the workflow</current_state>
    <intended_outcome>what this operation will achieve</intended_outcome>
    <alternatives>other approaches considered</alternatives>
  </context>
  <approval_options>
    <approve>proceed with operation as planned</approve>
    <modify>suggest changes before proceeding</modify>
    <reject>skip this operation</reject>
    <escalate>get additional review</escalate>
  </approval_options>
</approval_request>
```

## Benefits of Control Flow Ownership

1. **Granular Control**: Pause between tool selection and execution
2. **Risk Management**: Appropriate approval levels for different operations
3. **Async Support**: Handle long-running operations without blocking
4. **Human Safety**: Human validation for high-stakes decisions
5. **Resume Capability**: Restart from any control flow break point
6. **Audit Trail**: Complete log of all decisions and approvals

## Integration with Checkpoints

Every control flow break generates an automatic checkpoint, enabling seamless resumption when operations complete or approvals are granted.

### Checkpoint Integration

**Integration with Checkpoints**: Every control flow break generates an automatic checkpoint, enabling seamless resumption when operations complete or approvals are granted.

## Control Flow Best Practices

### 1. Operation Classification
- Clearly define risk levels for different operation types
- Use consistent classification criteria across all operations
- Regularly review and update risk classifications
- Document classification rationale for transparency

### 2. Approval Management
- Implement appropriate approval workflows for different risk levels
- Provide clear context and rationale for approval requests
- Set reasonable timeouts for approval responses
- Handle approval denials gracefully with alternative approaches

### 3. Async Operation Handling
- Monitor long-running operations for progress and health
- Provide status updates for async operations
- Implement proper timeout and cancellation mechanisms
- Handle async operation failures with appropriate recovery strategies

### 4. Human-in-the-Loop Design
- Design human interaction points to be informative and actionable
- Provide sufficient context for human decision-making
- Minimize human intervention points while maintaining safety
- Implement escalation paths for complex decisions

## Performance Considerations

### 1. Control Flow Efficiency
- Minimize control flow breaks for high-frequency operations
- Batch related operations to reduce approval overhead
- Implement intelligent approval routing to reduce delays
- Cache approval decisions for similar operations

### 2. Resource Management
- Monitor resource usage during control flow operations
- Implement resource limits for different operation types
- Optimize checkpoint creation and storage
- Balance control flow safety with performance requirements

### 3. Scalability
- Design control flow system to handle multiple concurrent workflows
- Implement efficient event processing for async operations
- Scale approval management for large numbers of operations
- Optimize checkpoint storage and retrieval

## Error Handling in Control Flow

### 1. Operation Failures
- Handle operation failures gracefully within control flow
- Provide clear error context for debugging and recovery
- Implement retry mechanisms with appropriate backoff strategies
- Escalate critical failures to human operators when needed

### 2. Approval Timeouts
- Implement timeout mechanisms for approval requests
- Provide fallback strategies for timed-out approvals
- Notify stakeholders of approval delays
- Implement approval escalation for urgent operations

### 3. Async Operation Issues
- Monitor async operations for failures and timeouts
- Implement recovery strategies for failed async operations
- Provide status updates and error notifications
- Handle async operation cancellation gracefully

## Monitoring and Analytics

### 1. Control Flow Metrics
- Track operation approval rates and times
- Monitor async operation completion rates
- Measure human intervention frequency and duration
- Analyze control flow efficiency and bottlenecks

### 2. Performance Analytics
- Monitor control flow impact on overall system performance
- Track approval and operation completion times
- Analyze error rates and recovery effectiveness
- Generate performance reports and optimization recommendations

### 3. Audit and Compliance
- Maintain detailed audit logs of all control flow decisions
- Track approval chains and decision rationales
- Implement compliance reporting for control flow operations
- Ensure audit trail integrity and availability

## Integration with Other Protocols

### Workflow Integration
- Apply control flow principles to workflow execution
- Use control flow breaks at appropriate workflow boundaries
- Implement workflow-level approval and validation points
- Handle workflow interruptions and resumptions

### Error Handling Integration
- Apply control flow error handling patterns
- Use control flow breaks for error recovery decisions
- Implement error escalation through control flow mechanisms
- Handle error recovery with appropriate approval levels

### Security Integration
- Apply security controls to control flow operations
- Implement security approvals for sensitive operations
- Use control flow to enforce security boundaries
- Monitor security-related control flow decisions

This protocol provides the complete framework for implementing sophisticated control flow management, enabling safe, efficient, and scalable operation execution with appropriate human oversight and automated decision-making.
# Unified Event Schema for OpenCode Agents (12-Factor)

## Purpose
Define structured XML event formats for all agent communications, enabling stateless operations, context engineering, and workflow resumability according to 12-factor agent principles.

## Core Event Structure

All agent events MUST follow this base schema:

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

## Event Types and Schemas

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

### 2. Phase Start Event

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

### 3. Phase Complete Event

```xml
<agent_event>
  <meta>
    <event_type>phase_complete</event_type>
    <source_agent>specialized_agent_name</source_agent>
    <target_agent>alpha</target_agent>
  </meta>
  <context>
    <deliverables>
      <primary_output>
        <type>architecture_document|implementation_code|security_audit</type>
        <location>file_path_or_description</location>
        <validation_status>passed|requires_review</validation_status>
      </primary_output>
      <secondary_outputs>
        <output>documentation_updates</output>
        <output>configuration_changes</output>
      </secondary_outputs>
    </deliverables>
    <next_phase_inputs>structured_data_for_next_agent</next_phase_inputs>
  </context>
  <state>
    <quality_gates_status>
      <gate name="security_review">passed|pending|failed</gate>
      <gate name="cross_platform_test">passed|pending|failed</gate>
      <gate name="code_standards">passed|pending|failed</gate>
    </quality_gates_status>
    <risks_identified>
      <risk>potential_issue_description</risk>
      <mitigation>recommended_action</mitigation>
    </risks_identified>
    <recommendations>
      <recommendation>improvement_suggestion</recommendation>
      <recommendation>optimization_opportunity</recommendation>
    </recommendations>
  </state>
</agent_event>
```

### 4. Checkpoint Event (Pause/Resume)

```xml
<agent_event>
  <meta>
    <event_type>checkpoint</event_type>
    <source_agent>alpha</source_agent>
    <target_agent>checkpoint_system</target_agent>
  </meta>
  <context>
    <checkpoint_reason>phase_boundary|user_approval|context_compression</checkpoint_reason>
    <resumable_state>
      <compressed_workflow>
        <completed_phases>
          <phase id="1" agent="beta" status="complete">architecture_analysis</phase>
          <phase id="2" agent="language" status="in_progress">implementation</phase>
        </completed_phases>
        <pending_phases>
          <phase id="3" agent="security">vulnerability_audit</phase>
          <phase id="4" agent="reviewer">final_review</phase>
        </pending_phases>
      </compressed_workflow>
      <critical_context>
        <decisions>key_architectural_choices</decisions>
        <constraints>unchanged_requirements</constraints>
        <artifacts>files_created_or_modified</artifacts>
      </critical_context>
    </resumable_state>
  </context>
  <state>
    <resume_instructions>
      <next_action>specific_step_to_take</next_action>
      <required_validation>context_integrity_check</required_validation>
      <agent_assignment>which_agent_should_continue</agent_assignment>
    </resume_instructions>
  </state>
</agent_event>
```

### 5. Error Recovery Event

```xml
<agent_event>
  <meta>
    <event_type>error_recovery</event_type>
    <source_agent>failed_agent_name</source_agent>
    <target_agent>alpha</target_agent>
  </meta>
  <context>
    <error_details>
      <error_type>permission_denied|anchor_ambiguity|context_overflow|dependency_missing</error_type>
      <error_description>specific_issue_encountered</error_description>
      <attempted_resolution>what_was_tried</attempted_resolution>
    </error_details>
    <current_state>
      <partial_outputs>work_completed_before_error</partial_outputs>
      <rollback_needed>true|false</rollback_needed>
      <context_integrity>preserved|compromised</context_integrity>
    </current_state>
  </context>
  <state>
    <recovery_options>
      <option priority="high">retry_with_adjusted_parameters</option>
      <option priority="medium">escalate_to_specialized_agent</option>
      <option priority="low">request_user_intervention</option>
    </recovery_options>
    <workflow_impact>
      <phases_affected>list_of_phases</phases_affected>
      <delay_estimate>time_or_effort_impact</delay_estimate>
      <alternative_approaches>backup_strategies</alternative_approaches>
    </workflow_impact>
  </state>
</agent_event>
```

## Agent-Specific Event Extensions

### Language Agent Events
- Include `language_context` with target languages, frameworks, patterns
- Add `code_quality_metrics` for complexity, test coverage, performance
- Specify `optimization_targets` for performance, maintainability, security

### Security Agent Events  
- Include `threat_model` assessment and vulnerability categories
- Add `compliance_requirements` for standards and regulations
- Specify `security_testing_results` with tools used and findings

### DevOps Agent Events
- Include `infrastructure_context` with platforms, containers, deployment targets
- Add `automation_metrics` for build times, success rates, resource usage
- Specify `deployment_strategy` with rollback procedures and monitoring

### Frontend-UIUX Agent Events
- Include `design_context` with user personas, accessibility requirements
- Add `ux_metrics` for usability testing, performance benchmarks
- Specify `responsive_design` requirements and browser compatibility

## Event Validation Rules

1. **Required Fields**: All meta, context.mission, and state sections must be present
2. **ID Uniqueness**: event_id must be unique across the entire workflow
3. **Temporal Ordering**: timestamp must be sequential within workflow
4. **Agent Validation**: source_agent and target_agent must be valid agent names
5. **Context Completeness**: Receiving agent must have complete context for autonomous operation
6. **State Consistency**: Critical decisions and constraints must be preserved across events
7. **Schema Compliance**: All events must validate against the base schema
8. **Compression Validation**: Compressed contexts must retain all critical information

## Implementation Guidelines

### For Alpha Agent (Orchestrator)
- Generate workflow_start event before delegation
- Emit phase_start events with complete context for each specialized agent
- Process phase_complete events and generate checkpoints
- Handle error_recovery events and orchestrate resolution

### For Specialized Agents
- Accept phase_start events as complete context (no external dependencies)
- Operate autonomously within provided context and constraints
- Emit phase_complete events with structured outputs
- Generate error_recovery events when encountering blocking issues

### For Context Management
- Monitor event stream for compression triggers
- Generate checkpoint events at phase boundaries
- Validate event schema compliance
- Maintain event stream integrity for resumability

## Benefits of Structured Events

1. **Stateless Operations**: Each agent gets complete context, no hidden dependencies
2. **Resumability**: Workflow can restart from any checkpoint with full context restoration
3. **Debuggability**: Clear event trail shows all decisions and state transitions
4. **Context Engineering**: Explicit structure prevents context drift and ambiguity
5. **Token Efficiency**: Compressed, structured context reduces token usage
6. **Quality Assurance**: Built-in validation and quality gates in event structure
7. **Cross-Platform Consistency**: Constraints and requirements explicitly preserved
8. **Error Recovery**: Structured error handling with clear recovery paths

This event schema enables OpenCode to achieve 12-factor agent compliance with production-ready reliability, observability, and maintainability.
# Serena MCP Agent Integration Checklist

This document provides a comprehensive checklist and guidelines for integrating Serena MCP meta-tools into OpenCode agents that currently don't meet the standard.

## Overview

According to the Global Development Assistant - Enhanced Operating Protocol in `opencode/AGENTS.md`, all agents must utilize Serena's meta-tools for autonomous self-reflection:
- `think_about_collected_information` - After data gathering to verify sufficiency and relevance
- `think_about_task_adherence` - Before implementation to ensure actions align with the original mission
- `think_about_whether_you_are_done` - At the end to confirm all tasks are complete

## Agents Requiring Updates

After reviewing all agent files, the following agents need Serena MCP integration:

### Priority Agents (Must be updated first)
1. code-reviewer.md
2. backend-architect.md
3. database-admin.md
4. api-reviewer.md
5. architect-reviewer.md
6. database-optimizer.md
7. security-audit.md
8. performance-engineer.md
9. devops-deployer.md

### All Other Agents
All remaining agents in the `opencode/agent/` directory also require updates.

## Standard Integration Template

### 1. Serena MCP Integration Section

Add this section to each agent documentation:

```markdown
## Serena MCP Integration

This agent follows the Serena MCP (Meta-Control Protocol) for autonomous self-reflection and quality assurance:

### Required Meta-Tool Integrations

1. **think_about_collected_information**: Called after data gathering phases to verify sufficiency and relevance of collected information
2. **think_about_task_adherence**: Called before implementation to ensure actions align with the original mission
3. **think_about_whether_you_are_done**: Called at the end of workflow to confirm all tasks are complete

### Integration Pattern

The agent must incorporate these meta-tools at specific workflow checkpoints:
- After initial analysis and research
- Before making any changes or recommendations
- At the conclusion of the task

### Example Usage

```markdown
#### Self-Reflection Checkpoint

After gathering information about the subject matter:



Before implementing any recommendations:



At task completion to ensure all requirements are met:


```
```

### 2. Updated Verification Checklist

Replace or add to the existing verification checklist with this standardized format:

```markdown
## Formal Verification

---
**VERIFICATION CHECKLIST**
* Self-reflection: Results from Serena 'think' tools (collected_information, task_adherence, whether_you_are_done) are logged and reviewed.
* Workload complete: All tasks from the mission have been fully implemented?
* Quality assured: Output adheres to ALL standards and requirements?
* Consistency maintained: Recommendations align with existing patterns?

Final Outcome:
- Status: {PASS/PARTIAL/FAIL - ALL checks must PASS}
- Verdict: {Concise summary or remaining issues}
---
```

### 3. Workflow Integration Example

Add this example to show how the agent should integrate the meta-tools in its workflow:

```markdown
## Workflow Integration Example

### Phase 1: Analysis
1. Review the provided subject matter
2. Identify key components and issues
3. **Self-reflection**: Call `think_about_collected_information` to verify analysis completeness

### Phase 2: Evaluation
1. Apply domain expertise to identify issues
2. Formulate recommendations
3. **Self-reflection**: Call `think_about_task_adherence` to ensure recommendations align with the original mission

### Phase 3: Output
1. Generate structured feedback
2. Provide actionable recommendations
3. **Self-reflection**: Call `think_about_whether_you_are_done` to confirm all requirements are met
```

## Priority Implementation Checklist

### For code-reviewer.md

- [ ] Add Serena MCP Integration section with meta-tool usage guidelines
- [ ] Update Configuration Change Review section to include self-reflection checkpoints
- [ ] Add example usage of meta-tools in the review process
- [ ] Update Review Output Format to include self-reflection results
- [ ] Add Formal Verification section with Serena MCP checklist

### For backend-architect.md

- [ ] Add Serena MCP Integration section with meta-tool usage guidelines
- [ ] Update Focus Areas to include self-reflection checkpoints
- [ ] Add example usage of meta-tools in the architecture design process
- [ ] Update Output Format to include self-reflection results
- [ ] Add Formal Verification section with Serena MCP checklist

### For database-admin.md

- [ ] Add Serena MCP Integration section with meta-tool usage guidelines
- [ ] Update Focus Areas to include self-reflection checkpoints
- [ ] Add example usage of meta-tools in database operations
- [ ] Update Output Format to include self-reflection results
- [ ] Add Formal Verification section with Serena MCP checklist

### For All Other Core Agents

Apply the same checklist pattern to:
- api-reviewer.md
- architect-reviewer.md
- database-optimizer.md
- security-audit.md
- performance-engineer.md
- devops-deployer.md
- And all other agents in the directory

## Implementation Guidelines

### For Documentation Updates

1. **Placement**: Add the Serena MCP Integration section after the main description but before the Approach/Process sections
2. **Language**: Use clear, actionable language that explains when and why to use each meta-tool
3. **Examples**: Include concrete examples showing where in the workflow each tool should be called
4. **Integration**: Show how the self-reflection results should be incorporated into the agent's output

### For Code Integration (if applicable)

If agents have any code components, ensure they:
1. Call the appropriate meta-tools at the specified workflow checkpoints
2. Log or report the results of these tools
3. Use the self-reflection results to adjust their behavior if needed

## Sample Implementation for code-reviewer.md

Here's how the code-reviewer.md should be updated:

```markdown
## Serena MCP Integration

This agent follows the Serena MCP (Meta-Control Protocol) for autonomous self-reflection and quality assurance:

### Required Meta-Tool Integrations

1. **think_about_collected_information**: Called after reviewing code changes to verify sufficiency and relevance of identified issues
2. **think_about_task_adherence**: Called before generating feedback to ensure recommendations align with the review mission
3. **think_about_whether_you_are_done**: Called at the end to confirm all critical issues have been identified and addressed

### Integration Pattern

The agent incorporates these meta-tools at specific review checkpoints:
- After initial code analysis and issue identification
- Before generating the final review feedback
- At conclusion to ensure comprehensive coverage

### Example Usage

During a code review workflow:


> Review: I've identified 5 critical configuration issues, 3 high-priority code quality issues, and 7 suggestions. The analysis appears comprehensive and covers all changed files.


> Review: My feedback aligns with the mission to review for security and maintainability. All identified issues are properly categorized by severity and include actionable recommendations.


> Review: All changed files have been reviewed. Critical configuration issues have been flagged. Security vulnerabilities have been identified. The review is complete and comprehensive.
```

## Final Verification Checklist

After implementing the Serena MCP integration, each agent should be verified against this checklist:

- [ ] Serena MCP Integration section added with clear guidelines
- [ ] All three required meta-tools are documented with usage instructions
- [ ] Example usage is provided showing integration points in the workflow
- [ ] Formal Verification section includes Serena MCP checklist items
- [ ] Existing workflow/process sections reference the self-reflection checkpoints
- [ ] Output format includes space for self-reflection results
- [ ] Agent example call (if present) is updated to show meta-tool usage

This comprehensive approach ensures all agents meet the Serena MCP standard while maintaining their specialized functionality and expertise.
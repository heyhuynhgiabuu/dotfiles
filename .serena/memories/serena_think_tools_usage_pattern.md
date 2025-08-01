# Serena MCP 'think' Tools Usage Pattern

## Purpose
- Integrate Serena's meta-tools (`think_about_collected_information`, `think_about_task_adherence`, `think_about_whether_you_are_done`) into agent workflows for self-reflection and chain-of-thought reasoning.

## Best Practices
- After major data gathering (symbol search, pattern analysis), call `think_about_collected_information` to verify sufficiency and relevance of information.
- Before code modification or verification, call `think_about_task_adherence` to ensure all actions align with the original mission.
- At the end of the workflow, call `think_about_whether_you_are_done` to confirm all tasks are complete and nothing is missed.
- Log or report the results of these tools as part of the verification checklist and final report.

## Example Workflow
1. Gather symbols and context → `think_about_collected_information`
2. Plan and validate actions → `think_about_task_adherence`
3. Execute changes
4. Re-validate context → `think_about_collected_information`
5. Final checklist → `think_about_whether_you_are_done`

## Benefits
- Enables autonomous self-reflection and error prevention
- Improves reliability and quality of agent workflows
- Provides clear checkpoints for complex tasks

---
This pattern should be referenced in agent design and workflow documentation for all OpenCode/Serena integrations.
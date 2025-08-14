# Unified Agent Orchestration Template

> Use this template for all multi-agent workflows, from simple to enterprise-grade.  
> Designed for the alpha-agent to support both basic and advanced (BMAD) orchestration.

---

## 1. Template Selection Guide

- **Simple Tasks (1-3 steps):** Use Sequential or Parallel sections.
- **Medium Tasks (4-6 steps):** Add Review/Validation or Conditional logic.
- **Complex/High-Risk Tasks (7+ steps, or requiring quality gates):** Use BMAD Extensions (context chaining, self-reflection, checkpoints, risk management).

---

## 2. Orchestration Patterns

### Sequential Orchestration

**Best for:** Step-by-step tasks where each depends on the previous.

```markdown
### Workflow: [Workflow Name]

1. [Agent 1]: [Task description]
2. [Agent 2]: [Task description]
3. [Agent 3]: [Task description]
...
```

---

### Parallel Orchestration

**Best for:** Independent tasks that can run simultaneously.

```markdown
### Workflow: [Workflow Name]

- [Agent 1]: [Task description]
- [Agent 2]: [Task description]
- [Agent 3]: [Task description]
...
# These agents run in parallel, then results are aggregated.
```

---

### Conditional Orchestration

**Best for:** Workflows with decision points.

```markdown
### Workflow: [Workflow Name]

1. [Agent 1]: [Task description]
2. If [Condition A]:
    - [Agent 2]: [Task description]
   Else:
    - [Agent 3]: [Task description]
3. [Agent 4]: [Next task]
```

---

### Review/Validation Orchestration

**Best for:** Tasks requiring validation and quality assurance.

```markdown
### Workflow: [Workflow Name]

1. [Main agent]: [Perform main task]
2. [Review agent]: [Review the result]
3. If needed, [Fix agent]: [Fix or improve based on feedback]
```

---

### Multi-Phase Orchestration

**Best for:** Large projects with distinct phases.

```markdown
### Workflow: [Workflow Name]

**Phase 1: [Phase Name]**
1. [Agent 1]: [Task description]
2. [Agent 2]: [Task description]

**Phase 2: [Phase Name]**
3. [Agent 3]: [Task description]
4. [Agent 4]: [Task description]

**Phase 3: Validation**
5. [Review Agent]: [Review and validate all phases]
6. If needed, [Fix Agent]: [Address any issues found]
```

---

## 3. BMAD Extensions (For Complex/High-Risk Workflows)

### BMAD Phase Structure

```markdown
### BMAD Workflow: [Workflow Name]
**Complexity**: [Basic/Standard/Advanced] | **Risk Level**: [Low/Medium/High]

**Context Chain Overview:** 
[Agent A] → [Deliverable] → [Agent B] → [Deliverable] → [Agent C]

---

**Phase 1: [Phase Name]** 🚧 *USER CHECKPOINT*
**Objective:** [Clear phase goal]
**Context Input:** [What information is needed to start]

1. **[Agent Role]**: [Task description]
   - **Deliverables:** [Specific outputs]
   - **Context Output:** [Information passed to next agent]
   - **Quality Gate:** [Success criteria]

**Self-Reflection Gate:** 
- ✅ Phase objectives achieved?
- ✅ Context complete for next phase?
- ✅ Quality standards met?
- ✅ Ready for user checkpoint?

**User Checkpoint Decision:** [What user needs to approve to proceed]

---

**Phase 2: [Phase Name]** 🚧 *USER CHECKPOINT*
[Repeat structure for each phase]

---

**Final Validation:**
- **Integration Test:** [How to verify all parts work together]
- **Acceptance Criteria:** [Business/technical validation]
- **Rollback Plan:** [If final validation fails]
```

---

### BMAD Context Chaining Patterns

- **Progressive Context Building:** Each agent adds to a cumulative context document.
- **Parallel Context Aggregation:** Multiple agents work with shared base context, results aggregated.
- **Layered Context Validation:** Context validation between agent handoffs.
- **Conditional Context Routing:** Context routing based on decision points.

---

### BMAD Checkpoint Types

- **User Decision Checkpoints:** Require user input to proceed.
- **Quality Gate Checkpoints:** Automated validation against criteria.
- **Stakeholder Review Checkpoints:** Formal review and approval.
- **Risk Assessment Checkpoints:** Evaluate risk factors and mitigation.

---

### BMAD Self-Reflection Log

```markdown
**Self-Reflection Log - [Phase/Task Name]**
**Timestamp**: [Date and time]
**Agent**: [Reflecting agent name]

**Objective Achievement**: ✅/⚠️/❌
[Detailed assessment]

**Quality Assessment**: ✅/⚠️/❌
[Quality evaluation and concerns]

**Context Status**: ✅/⚠️/❌
[Context completeness and handoff readiness]

**Risk Assessment**: ✅/⚠️/❌
[Risk identification and mitigation status]

**Process Effectiveness**: ✅/⚠️/❌
[Workflow and process evaluation]

**Recommendations**: 
[Specific actionable recommendations]

**Next Steps**:
[Clear next actions required]
```

---

## 4. Best Practices

- **Match agent expertise to task.**
- **Include validation and review for critical tasks.**
- **Plan for failure and error handling.**
- **Use context chaining for multi-phase workflows.**
- **Document all checkpoints and decisions.**
- **Continuously evolve templates based on feedback and outcomes.**

---

> **Note:**  
> The alpha-agent should select the minimal template needed for the task, but always allow for BMAD rigor when required.  
> For simple tasks, skip advanced sections. For complex/critical tasks, use all BMAD features.

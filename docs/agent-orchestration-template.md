# Agent Orchestration Template

> Use these templates to plan workflows for complex tasks involving multiple subagents. These templates are designed for plan mode to automatically generate structured workflows and implementation prompts.

---

## 1. Sequential Orchestration

**Best for**: Tasks requiring step-by-step execution where each step depends on the previous one.

```markdown
### Workflow: [Workflow Name]

1. [Agent 1]: [Task description]
2. [Agent 2]: [Task description]
3. [Agent 3]: [Task description]
...
```

**Example Use Cases:**
- Code development workflow (design → implement → test → deploy)
- Documentation creation (research → write → review → publish)
- Bug fixing (investigate → fix → test → verify)

---

## 2. Parallel Orchestration

**Best for**: Independent tasks that can run simultaneously to save time.

```markdown
### Workflow: [Workflow Name]

- [Agent 1]: [Task description]
- [Agent 2]: [Task description]
- [Agent 3]: [Task description]
...
# These agents run in parallel, then results are aggregated.
```

**Example Use Cases:**
- Multi-component optimization (frontend + backend + database)
- Cross-platform testing (macOS + Linux + Windows)
- Content creation (docs + examples + tutorials)

---

## 3. Conditional Orchestration

**Best for**: Workflows that need different paths based on analysis or conditions.

```markdown
### Workflow: [Workflow Name]

1. [Agent 1]: [Task description]
2. If [Condition A]:
    - [Agent 2]: [Task description]
   Else:
    - [Agent 3]: [Task description]
3. [Agent 4]: [Next task]
```

**Example Use Cases:**
- Platform-specific configurations (if macOS → Agent A, if Linux → Agent B)
- Error handling workflows (if error type X → fix A, else → fix B)
- Feature deployment (if feature flag enabled → deploy, else → skip)

---

## 4. Review/Validation Orchestration

**Best for**: Critical tasks requiring validation and quality assurance.

```markdown
### Workflow: [Workflow Name]

1. [Main agent]: [Perform main task]
2. [Review agent]: [Review the result of the main agent]
3. If needed, [Fix agent]: [Fix or improve based on feedback]
```

**Example Use Cases:**
- Security-sensitive implementations (implement → security-audit → fix)
- Production deployments (deploy → validate → rollback if needed)
- Code refactoring (refactor → code-reviewer → performance-engineer)

---

## 5. Multi-Phase Orchestration (Complex Workflows)

**Best for**: Large projects with distinct phases requiring different skill sets.

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

**Example Use Cases:**
- Full-stack feature development (backend → frontend → testing → deployment)
- Infrastructure migration (plan → migrate → test → validate → cleanup)
- Product launch (develop → test → document → deploy → monitor)

---

## 6. Hybrid Orchestration (Sequential + Parallel)

**Best for**: Complex workflows combining sequential dependencies with parallel optimization.

```markdown
### Workflow: [Workflow Name]

**Sequential Foundation:**
1. [Setup Agent]: [Initial preparation]

**Parallel Execution:**
- [Agent A]: [Parallel task A]
- [Agent B]: [Parallel task B] 
- [Agent C]: [Parallel task C]

**Sequential Completion:**
2. [Integration Agent]: [Merge parallel results]
3. [Validation Agent]: [Final validation]
```

**Example Use Cases:**
- CI/CD pipeline (setup → [test + build + security scan] → deploy → verify)
- Performance optimization (setup → [frontend + backend + database] → integrate → benchmark)
- Content publishing (setup → [write + design + translate] → review → publish)

---

## 7. YAML/Markdown Template (Structured)

**Best for**: Complex workflows requiring precise dependency management and conditional logic.

```yaml
workflow_name: [Workflow Name]
description: [Brief workflow description]
phases:
  - name: [Phase Name]
    steps:
      - agent: [Agent name]
        description: [Task description]
        depends_on: [Previous step (if any)]
        condition: [Condition (if any)]
        parallel_with: [Other steps that can run in parallel]
      - agent: [Agent name]
        description: [Task description]
        depends_on: [Previous step]
validation:
  - agent: [Review Agent]
    description: [Validation task]
    triggers_on: [completion_of_phase_1, completion_of_phase_2]
```

**Example Use Cases:**
- Enterprise deployment workflows
- Multi-team coordination projects
- Compliance-required processes

---

## 🎯 Template Selection Guide

### Simple Tasks (1-3 steps):
- **Sequential**: For straightforward step-by-step tasks
- **Parallel**: For independent tasks that can run simultaneously

### Medium Tasks (4-6 steps):
- **Review/Validation**: For tasks requiring quality assurance
- **Conditional**: For tasks with decision points
- **Multi-Phase**: For tasks with distinct phases

### Complex Tasks (7+ steps):
- **Hybrid**: For mixed sequential/parallel requirements
- **YAML/Structured**: For enterprise-grade workflows with dependencies

### By Risk Level:
- **Low Risk**: Sequential, Parallel
- **Medium Risk**: Review/Validation, Multi-Phase
- **High Risk**: Hybrid, YAML/Structured (with extensive validation)

---

## 💡 Best Practices

### Agent Selection:
- **Match expertise to task**: Use domain-specific agents for specialized work
- **Include validation**: Always have review agents for critical tasks
- **Consider dependencies**: Ensure agents have required context from previous steps

### Workflow Design:
- **Start simple**: Use basic templates and combine as needed
- **Plan for failure**: Include conditional paths for error handling
- **Optimize for speed**: Use parallel execution where possible
- **Validate often**: Include review steps at critical junctions

### Implementation Prompts:
- **Be specific**: Include exact requirements and constraints
- **Define success**: Clear deliverable and quality criteria
- **Provide context**: Background information for agents
- **Include validation**: How to verify successful completion

---

## 🔄 Template Evolution

These templates should be updated based on:
- **Success patterns**: Templates that consistently work well
- **Failure analysis**: Common failure points and mitigations
- **New agent capabilities**: As new specialized agents are added
- **User feedback**: Improvements based on real-world usage

> **Note**: When plan mode processes your request, it will automatically select the most appropriate template based on task complexity, risk level, and requirements. You can also explicitly request a specific orchestration pattern if needed.
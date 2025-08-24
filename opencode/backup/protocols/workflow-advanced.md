# Workflow Advanced Protocol

**LOAD TRIGGER**: Complex tasks requiring 4+ sequential steps, structured planning, or checkpoint management.

## 13-Step Structured Workflow

### Stage 1: Mission & Planning (Steps 1-7)

#### 1. Mission Understanding
- Analyze user request beyond surface level
- Identify fundamental problem and ultimate goal
- Synthesize core intent, rationale, and critical nuances

#### 2. Mission Decomposition
- Use EmpiricalRigor to decompose into granular, SMART phases and tasks
- Create sequential dependency-ordered breakdown
- Format: `### Phase {num}: {name}` → `#### {phase}.{task}: {description}`

#### 3. Pre-existing Tech Analysis
- Proactively search workspace files for relevant existing elements
- Identify reusable patterns, libraries, architectural choices

#### 4. Research & Verification
- THE PROBLEM CANNOT BE SOLVED WITHOUT EXTENSIVE INTERNET RESEARCH
- Use webfetch to research libraries, frameworks, dependencies
- Recursively gather information by fetching additional links

#### 5. Tech to Introduce
- State final choices for NEW technology/dependencies to add
- Justify each addition based on research

#### 6. Pre-Implementation Synthesis
- High-level executive summary of solution approach
- "In order to fulfill X, I will do Y using Z"

#### 7. Impact Analysis
- Evaluate code signature changes, performance implications, security risks
- Conduct adversarial self-critique (Red Team analysis)

#### 7.1. Stage 1 Checkpoint Generation
**MANDATORY**: Generate phase boundary checkpoint after completing mission planning.

### Stage 2: Implementation (Steps 8-10)

#### 8. Implementation Trajectory
- Decompose plan into highly detailed, practically-oriented implementation workload
- Register EVERY task for progress tracking

#### 9. Implementation
- Execute each task with surgical precision
- Use sub-headings: `## 9.{phase}.{task}: {description}`
- Apply AppropriateComplexity - robust but not over-engineered

#### 10. Cleanup Actions
- Apply PurityAndCleanliness - remove ALL obsolete artifacts
- Ensure code signature changes propagate to callers

### Stage 3: Verification & Completion (Steps 11-13)

#### 11. Formal Verification
```markdown
---
**VERIFICATION CHECKLIST**
* Anchor verified: All edits made at correct, intended locations?
* Workload complete: {ENTIRE workload from ##2 and ##8 fully implemented?}
* Impact handled: {All impacts from ##7 properly mitigated?}
* Quality assured: {Code adheres to ALL maxims and standards?}
* Cleanup performed: {PurityAndCleanliness enforced?}
* Tests passing: {All existing tests still pass?}

Final Outcome:
- Status: {PASS/PARTIAL/FAIL - ALL checks must PASS}
---
```

#### 12. Suggestions
- Ideas/features correctly excluded per AppropriateComplexity
- Alternative approaches identified during implementation

#### 13. Summary
- Brief restatement of mission accomplishment
- Key elements cleaned up for future reference

## Checkpoint Architecture

### Checkpoint Types
- **Phase Boundary**: After each major workflow stage (1, 2, 3)
- **User Approval**: When user decision impacts workflow direction
- **Error Recovery**: When workflow encounters blocking issues

### Checkpoint Storage
Store checkpoints using Serena memory system for cross-session persistence.

### Resume Validation Protocol
Before resuming any workflow from checkpoint:
1. **Context Integrity Check**: Validate referenced files, decisions, constraints
2. **Environment Verification**: Confirm dependencies, permissions, platform requirements
3. **Progress Validation**: Verify completed steps are in expected state

## Error Recovery
- **Stall Detection**: Two consecutive batches without checklist advancement → restart minimal scaffold
- **Anchor Integrity**: Halt edits until unique anchor confirmed
- **Permission Denial**: Narrow scope, retry once, surface required permission
- **Token Burst Control**: Compress if projected AWS growth >15%

## State Management
- **Simple Tasks** (≤2 steps): Execute directly, skip checklist
- **Complex Tasks** (≥3 steps): Use full protocol with mandatory checkpoints
- **State Persistence**: For 4+ steps, manage checklist in conversation
- **Autonomous Execution**: Once approved, execute entire plan autonomously

This protocol provides structured, resilient, and resumable workflow execution for complex multi-step tasks.
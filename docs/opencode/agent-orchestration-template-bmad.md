# BMAD Agent Orchestration Template

> **BMAD = Business Model Analysis & Development**  
> Enhanced orchestration templates for complex, multi-agent workflows with built-in quality gates, context chaining, and user checkpoints.

**Use these templates for sophisticated workflows requiring:**
- Multi-phase execution with clear deliverables
- Cross-agent context propagation  
- Strategic user decision points
- Continuous quality validation
- Self-reflection and improvement loops

---

## 🎯 BMAD Template Categories

### **By Complexity Level:**
- **Basic BMAD** (3-5 steps): Simple enhancements with minimal checkpoints
- **Standard BMAD** (6-10 steps): Full BMAD protocol with phase gates
- **Advanced BMAD** (11+ steps): Enterprise-grade with comprehensive validation

### **By Risk Level:**
- **Low Risk**: Checkpoint at completion only
- **Medium Risk**: Phase-based checkpoints
- **High Risk**: Step-by-step validation with fallback plans

---

## 🔄 BMAD Core Templates

### **1. Sequential BMAD (Step-by-Step Excellence)**

**Best for**: Tasks requiring strict dependency order with quality gates

```markdown
### 🎯 BMAD Workflow: [Workflow Name]
**Complexity**: [Basic/Standard/Advanced] | **Risk Level**: [Low/Medium/High]

**Context Chain Overview**: 
[Agent A] → [Deliverable] → [Agent B] → [Deliverable] → [Agent C]

---

**Phase 1: [Phase Name]** 🚧 *USER CHECKPOINT*
**Objective**: [Clear phase goal]
**Context Input**: [What information is needed to start]

1. **[Agent Role]**: [Task description]
   - **Deliverables**: [Specific outputs]
   - **Context Output**: [Information passed to next agent]
   - **Quality Gate**: [Success criteria]

2. **[Agent Role]**: [Task description]  
   - **Context Input**: [Information received from previous agent]
   - **Deliverables**: [Specific outputs]
   - **Context Output**: [Information passed to next agent]

**Self-Reflection Gate**: 
- ✅ Phase objectives achieved?
- ✅ Context complete for next phase?
- ✅ Quality standards met?
- ✅ Ready for user checkpoint?

**User Checkpoint Decision**: [What user needs to approve to proceed]

---

**Phase 2: [Phase Name]** 🚧 *USER CHECKPOINT*
[Repeat structure for each phase]

---

**Final Validation**:
- **Integration Test**: [How to verify all parts work together]
- **Acceptance Criteria**: [Business/technical validation]
- **Rollback Plan**: [If final validation fails]
```

**Example Use Cases:**
- Full-stack feature development (analysis → design → implementation → testing → deployment)
- Security-critical implementations (design → code → review → audit → deploy)
- Data migration projects (planning → extraction → transformation → validation → deployment)

---

### **2. Parallel BMAD (Concurrent Excellence)**

**Best for**: Independent workstreams that converge at integration points

```markdown
### 🎯 BMAD Workflow: [Workflow Name]
**Complexity**: [Basic/Standard/Advanced] | **Risk Level**: [Low/Medium/High]

**Context Synchronization Strategy**: [How parallel agents stay coordinated]

---

**Phase 1: Preparation & Context Setup** 🚧 *USER CHECKPOINT*
1. **[Coordination Agent]**: Context preparation
   - **Shared Context Document**: [Central information repository]
   - **Parallel Agent Briefing**: [What each agent needs to know]
   - **Integration Plan**: [How results will be merged]

---

**Phase 2: Parallel Execution**
**Context Sync Point**: [Regular coordination mechanism]

**Workstream A:**
- **[Agent A]**: [Task description]
  - **Context Input**: [Shared context + specific requirements]
  - **Deliverables**: [Specific outputs]
  - **Progress Updates**: [How to report status]

**Workstream B:**
- **[Agent B]**: [Task description]
  - **Context Input**: [Shared context + specific requirements]  
  - **Deliverables**: [Specific outputs]
  - **Cross-Dependencies**: [Dependencies on other workstreams]

**Workstream C:**
- **[Agent C]**: [Task description]
  - **Context Input**: [Shared context + specific requirements]
  - **Deliverables**: [Specific outputs]
  - **Quality Standards**: [Specific validation criteria]

**Mid-Phase Self-Reflection** (for each workstream):
- ✅ Individual objectives on track?
- ✅ Cross-workstream dependencies managed?
- ✅ Integration risks identified?

---

**Phase 3: Integration & Validation** 🚧 *USER CHECKPOINT*
1. **[Integration Agent]**: Merge parallel results
   - **Context Input**: [All workstream outputs]
   - **Integration Process**: [Step-by-step merge process]
   - **Conflict Resolution**: [How to handle incompatibilities]

2. **[Validation Agent]**: End-to-end testing
   - **Integration Testing**: [Verify combined system works]
   - **Performance Validation**: [System meets performance criteria]
   - **User Acceptance**: [Business validation]

**Final Self-Reflection Gate**:
- ✅ All workstreams successfully integrated?
- ✅ System performance acceptable?
- ✅ User requirements fulfilled?
```

**Example Use Cases:**
- Multi-platform development (iOS + Android + Web simultaneously)
- Infrastructure setup (compute + storage + networking + security)
- Content creation (writing + design + video + translation)

---

### **3. Review/Validation BMAD (Quality-First)**

**Best for**: High-risk tasks requiring multiple validation layers

```markdown
### 🎯 BMAD Workflow: [Workflow Name]
**Complexity**: [Basic/Standard/Advanced] | **Risk Level**: HIGH

**Validation Strategy**: Multi-layer review with progressive refinement

---

**Phase 1: Initial Implementation**
1. **[Primary Agent]**: Core implementation
   - **Context Input**: [Requirements and constraints]
   - **Deliverables**: [Working implementation]
   - **Self-Assessment**: [Agent's quality evaluation]

**Immediate Self-Reflection**:
- ✅ Implementation matches requirements?
- ✅ Code quality meets standards?
- ✅ Ready for expert review?

---

**Phase 2: Expert Review** 🚧 *USER CHECKPOINT*
2. **[Domain Expert Agent]**: Specialized review
   - **Context Input**: [Implementation + requirements]
   - **Review Criteria**: [Domain-specific quality standards]
   - **Feedback Report**: [Detailed improvement recommendations]

3. **[Security/Performance Agent]**: Risk assessment
   - **Context Input**: [Implementation + domain review]
   - **Risk Analysis**: [Security/performance vulnerability assessment]
   - **Mitigation Plan**: [How to address identified risks]

**Review Self-Reflection**:
- ✅ All critical issues identified?
- ✅ Mitigation strategies viable?
- ✅ Implementation safe to refine?

---

**Phase 3: Refinement & Validation** 🚧 *USER CHECKPOINT*
4. **[Primary Agent]**: Address feedback
   - **Context Input**: [All review feedback and mitigation plans]
   - **Refinement Process**: [How to implement improvements]
   - **Validation Testing**: [Verify fixes don't break functionality]

5. **[Final Validator]**: Production readiness
   - **Context Input**: [Refined implementation + all review history]
   - **Final Validation**: [Comprehensive system check]
   - **Go/No-Go Decision**: [Production deployment recommendation]

**Final Self-Reflection Gate**:
- ✅ All review feedback addressed?
- ✅ System meets all quality standards?
- ✅ Risk mitigation complete?
- ✅ Ready for production deployment?
```

**Example Use Cases:**
- Security-sensitive features (payment processing, user authentication)
- Performance-critical systems (real-time processing, high-traffic endpoints)
- Compliance-required implementations (healthcare, financial services)

---

### **4. Conditional BMAD (Adaptive Execution)**

**Best for**: Workflows with decision points based on analysis or environmental factors

```markdown
### 🎯 BMAD Workflow: [Workflow Name]
**Complexity**: [Basic/Standard/Advanced] | **Risk Level**: [Low/Medium/High]

**Decision Strategy**: [How decisions will be made and by whom]

---

**Phase 1: Analysis & Decision Point Setup**
1. **[Analyst Agent]**: Environmental analysis
   - **Context Input**: [Current system state, requirements]
   - **Analysis Deliverables**: [Comprehensive situation assessment]
   - **Decision Criteria**: [Clear factors for path selection]

**Decision Self-Reflection**:
- ✅ Analysis comprehensive and accurate?
- ✅ Decision criteria clear and measurable?
- ✅ All relevant factors considered?

---

**Phase 2: Conditional Execution** 🚧 *USER CHECKPOINT*

**Decision Point**: [Specific condition to evaluate]

**Path A: [Condition A Met]**
- **[Agent A1]**: [Task specific to condition A]
  - **Context Input**: [Analysis results + condition A requirements]
  - **Deliverables**: [Path A specific outputs]
  - **Success Criteria**: [How to measure Path A success]

- **[Agent A2]**: [Follow-up task for Path A]
  - **Context Input**: [Results from Agent A1]
  - **Deliverables**: [Final Path A outputs]

**Path B: [Condition B Met]**
- **[Agent B1]**: [Task specific to condition B]
  - **Context Input**: [Analysis results + condition B requirements]
  - **Deliverables**: [Path B specific outputs]
  - **Success Criteria**: [How to measure Path B success]

- **[Agent B2]**: [Follow-up task for Path B]
  - **Context Input**: [Results from Agent B1]
  - **Deliverables**: [Final Path B outputs]

**Path C: [Fallback/Default]**
- **[Agent C]**: [Default approach when neither A nor B applies]
  - **Context Input**: [Analysis results + fallback requirements]
  - **Deliverables**: [Fallback solution outputs]

**Path Selection Self-Reflection**:
- ✅ Correct path selected based on criteria?
- ✅ Path-specific execution successful?
- ✅ Results meet path-specific success criteria?

---

**Phase 3: Convergence & Validation** 🚧 *USER CHECKPOINT*
3. **[Integration Agent]**: Path-independent validation
   - **Context Input**: [Results from selected execution path]
   - **Universal Validation**: [Tests that apply regardless of path taken]
   - **Success Confirmation**: [Overall workflow success verification]

**Final Self-Reflection Gate**:
- ✅ Selected path achieved intended outcome?
- ✅ Universal quality standards met?
- ✅ Future path selection criteria validated?
```

**Example Use Cases:**
- Platform-specific deployments (cloud provider selection based on requirements)
- Technology migration strategies (gradual vs. big-bang based on system complexity)
- Bug fixing approaches (quick fix vs. comprehensive refactor based on severity)

---

### **5. Advanced Multi-Phase BMAD (Enterprise Workflows)**

**Best for**: Complex projects with multiple distinct phases and stakeholder involvement

```markdown
### 🎯 BMAD Workflow: [Workflow Name]
**Complexity**: ADVANCED | **Risk Level**: [Medium/High]

**Stakeholder Involvement**: [Who participates in checkpoints]
**Context Evolution**: [How context builds through phases]

---

**Phase 1: Discovery & Planning** 🚧 *STAKEHOLDER CHECKPOINT*
**Objective**: [Clear understanding of requirements and approach]

1. **Business Analyst**: Requirements gathering
   - **Context Input**: [Business objectives, user needs]
   - **Deliverables**: [Requirements document, user stories]
   - **Stakeholder Validation**: [Business review and approval]

2. **Solution Architect**: Technical planning
   - **Context Input**: [Requirements + technical constraints]
   - **Deliverables**: [Technical architecture, technology selection]
   - **Technical Validation**: [Architecture review, feasibility confirmation]

3. **Project Manager**: Resource planning
   - **Context Input**: [Requirements + technical plan]
   - **Deliverables**: [Project timeline, resource allocation, risk assessment]
   - **Planning Validation**: [Timeline and resource approval]

**Phase 1 Self-Reflection**:
- ✅ Requirements complete and validated?
- ✅ Technical approach feasible and optimal?
- ✅ Project plan realistic and achievable?
- ✅ All stakeholders aligned?

**User Checkpoint**: Go/No-Go decision for development phase

---

**Phase 2: Implementation** 🚧 *TECHNICAL CHECKPOINT*
**Objective**: [Deliver working system according to specifications]

4. **Backend Developer**: Core system implementation
   - **Context Input**: [Technical architecture + requirements]
   - **Deliverables**: [API implementation, database schema, core logic]
   - **Quality Gates**: [Unit tests, code coverage, performance benchmarks]

5. **Frontend Developer**: User interface implementation
   - **Context Input**: [UI requirements + backend API specification]
   - **Deliverables**: [User interface, responsive design, accessibility compliance]
   - **Quality Gates**: [Cross-browser testing, accessibility audit, UI/UX validation]

6. **Integration Specialist**: System integration
   - **Context Input**: [Backend + frontend implementations]
   - **Deliverables**: [Integrated system, integration tests, deployment configuration]
   - **Quality Gates**: [End-to-end testing, performance validation, security scanning]

**Phase 2 Self-Reflection**:
- ✅ All components implemented to specification?
- ✅ Integration successful and stable?
- ✅ System meets performance requirements?
- ✅ Ready for quality assurance phase?

**Technical Checkpoint**: System readiness for testing

---

**Phase 3: Quality Assurance** 🚧 *QUALITY CHECKPOINT*
**Objective**: [Validate system quality and readiness for production]

7. **QA Engineer**: Comprehensive testing
   - **Context Input**: [Integrated system + test requirements]
   - **Deliverables**: [Test plan execution, bug reports, quality metrics]
   - **Quality Gates**: [Test coverage goals, bug severity thresholds]

8. **Security Auditor**: Security validation
   - **Context Input**: [System implementation + security requirements]
   - **Deliverables**: [Security assessment, vulnerability report, remediation plan]
   - **Quality Gates**: [Security compliance, vulnerability risk assessment]

9. **Performance Engineer**: Performance validation
   - **Context Input**: [System under test + performance criteria]
   - **Deliverables**: [Performance benchmarks, optimization recommendations]
   - **Quality Gates**: [Performance SLA compliance, scalability validation]

**Phase 3 Self-Reflection**:
- ✅ All critical bugs resolved?
- ✅ Security vulnerabilities addressed?
- ✅ Performance meets requirements?
- ✅ System ready for production deployment?

**Quality Checkpoint**: Production readiness validation

---

**Phase 4: Deployment & Validation** 🚧 *PRODUCTION CHECKPOINT*
**Objective**: [Successfully deploy and validate production system]

10. **DevOps Engineer**: Production deployment
    - **Context Input**: [Validated system + deployment requirements]
    - **Deliverables**: [Production deployment, monitoring setup, backup procedures]
    - **Quality Gates**: [Deployment success, monitoring active, rollback tested]

11. **Business Validator**: User acceptance
    - **Context Input**: [Production system + business requirements]
    - **Deliverables**: [User acceptance testing, business validation, go-live approval]
    - **Quality Gates**: [User acceptance criteria, business objective validation]

12. **Support Specialist**: Operations handover
    - **Context Input**: [Production system + support requirements]
    - **Deliverables**: [Support documentation, monitoring procedures, incident response plan]
    - **Quality Gates**: [Support team training, documentation completeness]

**Phase 4 Self-Reflection**:
- ✅ Deployment successful and stable?
- ✅ Business objectives achieved?
- ✅ Support procedures in place?
- ✅ Project deliverables complete?

**Production Checkpoint**: Final project approval and closure

---

**Final Project Self-Reflection**:
- ✅ All project objectives achieved?
- ✅ Quality standards consistently met?
- ✅ Stakeholder expectations fulfilled?
- ✅ Lessons learned documented for future projects?
```

**Example Use Cases:**
- Enterprise software development projects
- Large-scale system migrations
- Regulatory compliance implementations
- Mission-critical system deployments

---

## 🎯 BMAD Template Selection Guide

### **Complexity-Based Selection:**

| Task Complexity | Agent Count | Template Recommendation |
|----------------|-------------|-------------------------|
| Simple (1-3 steps) | 1-2 agents | Basic Sequential BMAD |
| Medium (4-6 steps) | 2-4 agents | Standard Sequential/Parallel BMAD |
| Complex (7-10 steps) | 4-8 agents | Review/Validation or Conditional BMAD |
| Enterprise (11+ steps) | 8+ agents | Advanced Multi-Phase BMAD |

### **Risk-Based Selection:**

| Risk Level | Quality Gates | Template Recommendation |
|------------|---------------|-------------------------|
| Low | Minimal checkpoints | Basic Sequential/Parallel |
| Medium | Phase checkpoints | Standard BMAD templates |
| High | Step-by-step validation | Review/Validation BMAD |
| Critical | Comprehensive validation | Advanced Multi-Phase BMAD |

### **Domain-Based Selection:**

| Domain | Primary Concerns | Template Recommendation |
|--------|------------------|-------------------------|
| Security | Validation, compliance | Review/Validation BMAD |
| Performance | Optimization, testing | Parallel + Review BMAD |
| Integration | Compatibility, dependencies | Sequential BMAD |
| Innovation | Experimentation, iteration | Conditional BMAD |
| Enterprise | Governance, compliance | Advanced Multi-Phase BMAD |

---

## 📊 BMAD Context Chaining Patterns

### **Pattern 1: Progressive Context Building**
```
Agent A → Context Document v1 → Agent B → Context Document v2 → Agent C
```
Each agent adds to a cumulative context document.

### **Pattern 2: Parallel Context Aggregation**
```
Context Base → [Agent A, Agent B, Agent C] → Context Aggregator → Final Context
```
Multiple agents work with shared base context, results aggregated.

### **Pattern 3: Layered Context Validation**
```
Agent A → Context → Validator → Validated Context → Agent B
```
Context validation between agent handoffs.

### **Pattern 4: Conditional Context Routing**
```
Agent A → Decision → [Context Path A, Context Path B] → Respective Agents
```
Context routing based on decision points.

---

## 🚧 BMAD Checkpoint Strategies

### **Checkpoint Types:**

1. **User Decision Checkpoints** 🚧
   - Require user input to proceed
   - Present clear options and recommendations
   - Document decision rationale

2. **Quality Gate Checkpoints** ✅
   - Automated validation against criteria
   - Proceed only if quality standards met
   - Flag issues for resolution

3. **Stakeholder Review Checkpoints** 👥
   - Business/technical stakeholder involvement
   - Formal review and approval process
   - Document stakeholder feedback

4. **Risk Assessment Checkpoints** ⚠️
   - Evaluate risk factors and mitigation
   - Proceed/pause/abort decisions
   - Update risk register

### **Checkpoint Best Practices:**

- **Clear Criteria**: Define success/failure conditions upfront
- **Options Presentation**: Always provide user with clear choices
- **Impact Analysis**: Explain consequences of each option
- **Documentation**: Record all checkpoint decisions and rationale
- **Escalation Paths**: Define what happens if checkpoint fails

---

## 🔍 BMAD Self-Reflection Framework

### **Reflection Triggers:**
- After each significant task completion
- Before major decision points
- At phase transitions
- When quality issues detected
- At project milestones

### **Reflection Dimensions:**

**1. Objective Achievement**
- Were phase/task objectives met?
- What worked well and what didn't?
- Any unexpected outcomes?

**2. Quality Assessment**
- Does output meet quality standards?
- Are there any quality concerns?
- What quality improvements needed?

**3. Context Completeness**
- Is context sufficient for next agent/phase?
- Any missing information or dependencies?
- Context validation successful?

**4. Risk Management**
- Any new risks identified?
- Are existing risks properly mitigated?
- Risk level acceptable for proceeding?

**5. Process Effectiveness**
- Is the workflow proceeding as planned?
- Any process improvements needed?
- Resource allocation optimal?

### **Reflection Output Format:**
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

## 💡 BMAD Implementation Tips

### **Context Management Excellence**
- **Centralized Context**: Use shared documents for context continuity
- **Version Control**: Track context evolution through workflow phases
- **Validation Points**: Verify context completeness at handoffs
- **Context Inheritance**: New agents inherit full context from predecessors

### **Checkpoint Optimization**
- **Smart Timing**: Checkpoint when decisions actually impact direction
- **Batch Decisions**: Group related decisions to minimize interruptions
- **Pre-approved Paths**: Define auto-approval criteria for routine decisions
- **Escalation Clarity**: Clear escalation paths when checkpoints fail

### **Quality Assurance Integration**
- **Continuous Validation**: Quality checks throughout, not just at end
- **Multi-Layer Review**: Different types of validation for comprehensive coverage
- **Automated Gates**: Use automated checks where possible
- **Quality Metrics**: Define measurable quality criteria upfront

### **Agent Coordination**
- **Clear Handoffs**: Explicit handoff protocols between agents
- **Dependency Management**: Track and manage inter-agent dependencies
- **Communication Standards**: Standardized communication formats
- **Conflict Resolution**: Clear processes for resolving agent conflicts

---

## 🔄 Template Evolution and Customization

### **Template Customization Guidelines**
- Start with closest matching base template
- Add domain-specific quality gates
- Customize context requirements for your use case
- Adjust checkpoint frequency based on risk level
- Include domain-specific agent roles

### **Template Evolution Process**
- Collect feedback from template usage
- Identify common patterns and pain points
- Evolve templates based on real-world experience
- Maintain template version history
- Share successful customizations with team

### **Success Metrics**
- **Quality**: Consistent delivery of high-quality outcomes
- **Efficiency**: Reduced rework and faster delivery
- **Risk Mitigation**: Fewer production issues and surprises
- **Stakeholder Satisfaction**: Improved user and business satisfaction
- **Team Learning**: Continuous improvement and knowledge sharing

---

> **Remember**: BMAD templates are frameworks for excellence. Adapt them to your specific context while maintaining the core principles of multi-phase execution, quality validation, context continuity, and strategic user involvement.
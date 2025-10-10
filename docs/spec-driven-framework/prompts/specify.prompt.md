# Create a feature specification

You are an expert product manager and technical writer. Create a comprehensive feature specification that bridges business requirements with technical implementation.

## Your Task

Given the feature description provided as an argument, create a specification that:

1. **Parse the user description** to understand the core feature requirements
2. **Auto-detect project context** by analyzing existing files and structure
3. **Extract key concepts**: actors, actions, data, constraints, success criteria
4. **Mark ambiguities** with [NEEDS CLARIFICATION: specific question] for any assumptions
5. **Write user scenarios** in plain language for business stakeholders
6. **Define functional requirements** that are testable and unambiguous
7. **Identify key entities** and data relationships
8. **Create acceptance criteria** with measurable success conditions

## Specification Structure

### User Scenarios & Testing _(mandatory)_

- **Primary User Story**: Main user journey in plain language
- **Acceptance Scenarios**: Given/When/Then format for testing
- **Edge Cases**: Boundary conditions and error scenarios

### Requirements _(mandatory)_

- **Functional Requirements**: FR-001, FR-002 format with MUST/SHOULD statements
- **Key Entities**: Data objects and relationships
- **Non-Functional Requirements**: Performance, security, usability

### Review & Acceptance Checklist

- [ ] No implementation details (no tech stack, APIs, code structure)
- [ ] Focused on user value and business needs
- [ ] Requirements are testable and unambiguous
- [ ] Success criteria are measurable
- [ ] Scope is clearly bounded

## Guidelines

### Content Quality

- ✅ **Business-focused**: Written for non-technical stakeholders
- ✅ **Testable**: Every requirement can be verified with specific test cases
- ✅ **Unambiguous**: No vague terms like "fast", "user-friendly", "robust"
- ✅ **Measurable**: Success criteria include specific metrics or conditions

### Technical Considerations

- ❌ **No implementation details**: Don't specify languages, frameworks, or architecture
- ❌ **No premature optimization**: Focus on user needs, not technical constraints
- ❌ **No assumptions**: Mark everything unclear with [NEEDS CLARIFICATION]

### Common Pitfalls to Avoid

- "The system should be fast" → "Page load time < 2 seconds on 3G connection"
- "Users should easily find products" → "85% of users find target product within 3 clicks"
- "System should handle errors gracefully" → "Error messages explain the problem and provide next steps"

## Output Format

Create the specification in the standard format with:

- Clear section headers
- Bullet points for requirements
- [NEEDS CLARIFICATION] markers for ambiguities
- Checklist items for validation

## Success Criteria

The specification is complete when:

- ✅ Business stakeholders can understand and approve it
- ✅ Developers can estimate implementation effort
- ✅ Testers can write comprehensive test cases
- ✅ Product managers can track progress against requirements
- ✅ No [NEEDS CLARIFICATION] markers remain

---

**Context**: $ARGUMENTS
**Project Type**: Auto-detected from existing codebase
**Framework**: OpenCode Spec-Driven Development

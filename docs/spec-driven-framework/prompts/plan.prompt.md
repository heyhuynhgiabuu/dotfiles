# Create an implementation plan

You are an expert software architect and technical lead. Create a comprehensive implementation plan that bridges business requirements with technical execution.

## Your Task

Given the feature specification, create an implementation plan that:

1. **Load and analyze the feature specification** to understand requirements
2. **Auto-detect project context** from existing codebase and files
3. **Fill technical context** with detected language, framework, and project type
4. **Evaluate constitution compliance** against development standards
5. **Create project structure** based on detected project type
6. **Plan phased execution** with clear deliverables and dependencies
7. **Generate research tasks** for technical unknowns
8. **Design contracts and interfaces** for the detected tech stack

## Plan Structure

### Technical Context _(auto-detected)_

- **Language/Version**: Detected from package.json, go.mod, Cargo.toml, etc.
- **Primary Dependencies**: Detected frameworks and libraries
- **Storage**: Database or storage solutions detected
- **Testing**: Testing frameworks detected
- **Target Platform**: Web, mobile, CLI, API, etc.
- **Project Type**: web-app, mobile-app, cli-tool, library, api-service
- **Performance Goals**: From spec or NEEDS CLARIFICATION
- **Constraints**: Technical and business constraints

### Constitution Check _(mandatory gate)_

**Simplicity**:

- Projects: Maximum 3 sub-projects
- Using framework directly (no wrapper classes)
- Single data model (no unnecessary DTOs)
- Avoiding over-engineering patterns

**Architecture**:

- Every feature as library (no direct app code)
- Libraries with clear CLI interfaces
- Library documentation in llms.txt format

**Testing (NON-NEGOTIABLE)**:

- TDD mandatory: Tests written before implementation
- Red-Green-Refactor cycle strictly enforced
- Real dependencies used (no mocks for core functionality)
- Integration tests for contracts and shared schemas

**Observability**:

- Structured logging implemented
- Error context sufficient for debugging

### Project Structure _(auto-adapted)_

#### Universal Structure Options:

**Web Application (React/Vue + API)**:

```
frontend/
├── src/components/, pages/, services/
├── tests/unit/, integration/, e2e/
└── package.json

backend/
├── src/models/, routes/, services/
├── tests/contract/, integration/
└── package.json
```

**API Service (FastAPI/Express/Spring)**:

```
src/
├── models/, routes/, services/, middleware/
├── tests/unit/, integration/, contract/
└── docs/api/, contracts/
```

**CLI Tool (Python/Go/Rust)**:

```
cmd/
├── [tool-name]/main.go
pkg/
├── [library-name]/
├── [library-name]/
internal/
└── [private-code]/
```

**Mobile App (React Native/Flutter)**:

```
src/
├── components/, screens/, services/
├── android/, ios/ (platform-specific)
└── tests/
```

**Library/Package**:

```
src/ or lib/
├── [main-code]/
examples/
├── [usage-examples]/
tests/
└── [comprehensive-tests]/
```

### Phase Execution

#### Phase 0: Research & Analysis

1. **Extract unknowns** from Technical Context
   - For each NEEDS CLARIFICATION → research task
   - For each dependency → best practices research
   - For each integration → patterns research

2. **Generate research tasks**:

   ```
   For each unknown: "Research {unknown} for {project-type}"
   For each technology: "Find best practices for {tech} in {domain}"
   ```

3. **Consolidate findings** in research.md

#### Phase 1: Design & Contracts

1. **Extract entities** from feature spec → data-model.md
2. **Generate API contracts** → contracts/ directory
3. **Create failing tests** (TDD requirement)
4. **Update agent context** for detected AI assistants

#### Phase 2: Task Planning

Generate structured tasks with dependencies and parallel execution markers

## Success Criteria

The plan is complete when:

- ✅ **Technical context filled** with auto-detected information
- ✅ **Constitution check passed** or violations justified
- ✅ **Project structure defined** for detected project type
- ✅ **All NEEDS CLARIFICATION resolved** through research
- ✅ **Contracts designed** for detected tech stack
- ✅ **Failing tests created** (TDD compliance)
- ✅ **Task dependencies mapped** with parallel execution opportunities

## Output Deliverables

1. **research.md**: All technical unknowns resolved
2. **data-model.md**: Entity definitions and relationships
3. **contracts/**: API specifications and data contracts
4. **tests/**: Failing test files (contract, integration)
5. **[agent].md**: Updated context for AI assistants
6. **plan.md**: This comprehensive planning document

## Constitution Compliance

**MANDATORY**: Plan must demonstrate compliance with:

- Library-first architecture
- TDD methodology
- Simplicity principles
- Cross-platform compatibility
- Observability requirements

**JUSTIFICATION REQUIRED**: Any violations must be explicitly justified with business rationale and risk mitigation strategies.

---

**Input**: Feature specification from spec.md
**Project Context**: Auto-detected from existing codebase
**Framework**: OpenCode Spec-Driven Development

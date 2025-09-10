# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`
**Project Type**: [AUTO-DETECTED: web/mobile/cli/library/etc.]

## Execution Flow (/plan command scope)

```
1. Load feature spec from Input path
   → If not found: ERROR "No feature spec at {path}"
2. Auto-detect project type and tech stack
   → Analyze existing files: package.json, Cargo.toml, go.mod, etc.
   → Detect frameworks: React, Vue, Express, FastAPI, etc.
   → Set project structure based on type
3. Fill Technical Context (scan for NEEDS CLARIFICATION)
   → Detect Project Type from existing codebase
   → Set Structure Decision based on project type and conventions
4. Evaluate Constitution Check section below
   → If violations exist: Document in Complexity Tracking
   → If no justification possible: ERROR "Simplify approach first"
   → Update Progress Tracking: Initial Constitution Check
5. Execute Phase 0 → research.md
   → If NEEDS CLARIFICATION remain: ERROR "Resolve unknowns"
6. Execute Phase 1 → contracts, data-model.md, quickstart.md, agent-specific template file
7. Re-evaluate Constitution Check section
   → If new violations: Refactor design, return to Phase 1
   → Update Progress Tracking: Post-Design Constitution Check
8. Plan Phase 2 → Describe task generation approach (DO NOT create tasks.md)
9. STOP - Ready for /tasks command
```

**IMPORTANT**: The /plan command STOPS at step 8. Phases 2-4 are executed by other commands:

- Phase 2: /tasks command creates tasks.md
- Phase 3-4: Implementation execution (manual or via tools)

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## Technical Context

**Language/Version**: [AUTO-DETECTED: Node.js 18, Python 3.11, Go 1.21, Rust 1.75, etc.]
**Primary Dependencies**: [AUTO-DETECTED: React, Express, FastAPI, Axum, etc.]
**Storage**: [AUTO-DETECTED: PostgreSQL, MongoDB, Redis, SQLite, files, etc.]
**Testing**: [AUTO-DETECTED: Jest, pytest, cargo test, etc.]
**Target Platform**: [AUTO-DETECTED: Web browser, Linux server, iOS/Android, CLI, etc.]
**Project Type**: [AUTO-DETECTED: web-app, mobile-app, cli-tool, library, api-service, etc.]
**Performance Goals**: [From spec or NEEDS CLARIFICATION]
**Constraints**: [From spec or NEEDS CLARIFICATION]
**Scale/Scope**: [From spec or NEEDS CLARIFICATION]

## Constitution Check

_GATE: Must pass before Phase 0 research. Re-check after Phase 1 design._

**Simplicity**:

- Projects: [#] (max 3 - e.g., api, cli, tests)
- Using framework directly? (no wrapper classes)
- Single data model? (no DTOs unless serialization differs)
- Avoiding patterns? (no Repository/UoW without proven need)

**Architecture**:

- EVERY feature as library? (no direct app code)
- Libraries listed: [name + purpose for each]
- CLI per library: [commands with --help/--version/--format]
- Library docs: llms.txt format planned?

**Testing (NON-NEGOTIABLE)**:

- TDD mandatory: Tests written → User approved → Tests fail → Then implement
- Git commits show tests before implementation?
- Order: Contract→Integration→E2E→Unit strictly followed?
- Real dependencies used? (actual DBs, not mocks)
- Integration tests for: new libraries, contract changes, shared schemas?
- FORBIDDEN: Implementation before test, skipping RED phase

**Observability**:

- Structured logging included?
- Frontend logs → backend? (unified stream)
- Error context sufficient?

**Versioning**:

- Version number assigned? (MAJOR.MINOR.BUILD)
- BUILD increments on every change?
- Breaking changes handled? (parallel tests, migration plan)

**Cross-Platform**:

- Platform detection: macOS/Linux/Windows/iOS/Android/Web
- Path handling: No hardcoded paths, use platform-agnostic utilities
- Dependencies: Compatible across target platforms
- Testing: Platform-specific test scenarios included

## Project Structure

### Universal Structure (Auto-adapted)

```
# Auto-detected based on project type and existing structure

Option 1: Web Application (React/Vue + API)
├── frontend/
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   └── services/
│   ├── tests/
│   └── package.json
├── backend/
│   ├── src/
│   │   ├── models/
│   │   ├── routes/
│   │   └── services/
│   ├── tests/
│   └── package.json
└── shared/
    ├── types/
    └── constants/

Option 2: API Service (FastAPI/Express/Spring)
├── src/
│   ├── models/
│   ├── routes/
│   ├── services/
│   └── middleware/
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
└── docs/
    ├── api/
    └── contracts/

Option 3: CLI Tool (Python/Go/Rust)
├── cmd/
│   └── [tool-name]/
├── pkg/
│   ├── [library-name]/
│   └── [library-name]/
├── internal/
│   └── [private-code]/
└── tests/

Option 4: Mobile App (React Native/Flutter)
├── src/
│   ├── components/
│   ├── screens/
│   ├── services/
│   └── utils/
├── android/
├── ios/
└── tests/

Option 5: Library/Package (Any language)
├── src/ or lib/
├── examples/
├── tests/
└── docs/
```

**Structure Decision**: [AUTO-DETECTED based on existing files and project type]

### Documentation (this feature)

```
specs/[###-feature-name]/
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── contracts/           # Phase 1 output (/plan command)
│   ├── api-spec.json
│   ├── events-spec.md
│   └── data-contracts.md
└── tasks.md             # Phase 2 output (/tasks command - NOT created by /plan)
```

## Phase 0: Research & Analysis

1. **Extract unknowns from Technical Context** above:
   - For each NEEDS CLARIFICATION → research task
   - For each dependency → best practices task
   - For each integration → patterns task

2. **Generate and dispatch research agents**:

   ```
   For each unknown in Technical Context:
     Task: "Research {unknown} for {project-type} {feature-context}"
   For each technology choice:
     Task: "Find best practices for {tech} in {project-type} development"
   ```

3. **Consolidate findings** in `research.md` using format:
   - Decision: [what was chosen]
   - Rationale: [why chosen]
   - Alternatives considered: [what else evaluated]

**Output**: research.md with all NEEDS CLARIFICATION resolved

## Phase 1: Design & Contracts

_Prerequisites: research.md complete_

1. **Extract entities from feature spec** → `data-model.md`:
   - Entity name, fields, relationships
   - Validation rules from requirements
   - State transitions if applicable

2. **Generate API contracts** from functional requirements:
   - For each user action → endpoint or interface
   - Use standard patterns for detected project type
   - Output OpenAPI/GraphQL/CLI spec to `/contracts/`

3. **Generate contract tests** from contracts:
   - One test file per endpoint/interface
   - Assert request/response schemas
   - Tests must fail (no implementation yet)

4. **Extract test scenarios** from user stories:
   - Each story → integration test scenario
   - Quickstart test = story validation steps

5. **Update agent file incrementally** (O(1) operation):
   - Run `/scripts/update-agent-context.sh [agent-type]` for detected AI assistants
   - If exists: Add only NEW tech from current plan
   - Preserve manual additions between markers
   - Keep under 150 lines for token efficiency
   - Update recent changes (keep last 3)

**Output**: data-model.md, /contracts/\*, failing tests, quickstart.md, agent-specific file

## Phase 2: Task Planning Approach

_This section describes what the /tasks command will do - DO NOT execute during /plan_

**Task Generation Strategy**:

- Load `/templates/tasks-template.md` as base
- Generate tasks from Phase 1 design docs (contracts, data model, quickstart)
- Each contract → contract test task [P]
- Each entity → model creation task [P]
- Each user story → integration test task
- Implementation tasks to make tests pass

**Ordering Strategy**:

- TDD order: Tests before implementation
- Dependency order: Models before services before UI
- Mark [P] for parallel execution (independent files)

**Estimated Output**: 25-30 numbered, ordered tasks in tasks.md

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

## Phase 3+: Future Implementation

_These phases are beyond the scope of the /plan command_

**Phase 3**: Task execution (/tasks command creates tasks.md)
**Phase 4**: Implementation (execute tasks.md following constitutional principles)
**Phase 5**: Validation (run tests, execute quickstart.md, performance validation)

## Complexity Tracking

_Fill ONLY if Constitution Check has violations that must be justified_

| Violation                  | Why Needed         | Simpler Alternative Rejected Because |
| -------------------------- | ------------------ | ------------------------------------ |
| [e.g., 4th project]        | [current need]     | [why 3 projects insufficient]        |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient]  |

## Progress Tracking

_This checklist is updated during execution flow_

**Phase Status**:

- [ ] Phase 0: Research complete (/plan command)
- [ ] Phase 1: Design complete (/plan command)
- [ ] Phase 2: Task planning complete (/plan command - describe approach only)
- [ ] Phase 3: Tasks generated (/tasks command)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:

- [ ] Initial Constitution Check: PASS
- [ ] Post-Design Constitution Check: PASS
- [ ] All NEEDS CLARIFICATION resolved
- [ ] Complexity deviations documented

---

_Based on OpenCode Spec-Driven Development Framework v1.0_

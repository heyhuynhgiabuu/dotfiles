# Generate implementation tasks

You are an expert project manager and software engineer. Break down the implementation plan into executable, prioritized tasks with clear dependencies and parallel execution opportunities.

## Your Task

Given the design documents (plan.md, data-model.md, contracts/, research.md), generate a comprehensive task list that:

1. **Load design documents** from the feature directory
2. **Auto-detect project structure** and tech stack conventions
3. **Generate tasks by category** with appropriate file paths
4. **Apply TDD principles** (tests before implementation)
5. **Mark parallel execution** opportunities with [P]
6. **Define dependencies** and execution order
7. **Include validation checkpoints** and quality gates

## Task Categories & Structure

### Phase 3.1: Setup (Project Initialization)

- **Auto-detected**: Based on project type and existing structure
- **Dependencies**: None (can run first)
- **Parallel**: Most setup tasks can run in parallel [P]

### Phase 3.2: Tests First (TDD - CRITICAL)

- **MANDATORY**: Tests MUST be written and MUST FAIL before implementation
- **Contract Tests**: From contracts/ directory
- **Integration Tests**: From user stories and acceptance criteria
- **Parallel**: All test creation can be parallel [P]

### Phase 3.3: Core Implementation

- **Prerequisites**: Failing tests from Phase 3.2
- **Sequential**: Most implementation requires dependencies
- **Parallel**: Independent files can be parallel [P]

### Phase 3.4: Integration

- **Prerequisites**: Core implementation complete
- **Tech-specific**: Database, middleware, external services
- **Parallel**: Service integration can be parallel [P]

### Phase 3.5: Polish

- **Prerequisites**: Integration complete
- **Quality**: Unit tests, performance, documentation
- **Parallel**: Most polish tasks can be parallel [P]

## Task Format Requirements

### Standard Format: `[ID] [P?] Description`

- **ID**: T001, T002, T003... (sequential numbering)
- **[P]**: Mark for parallel execution (different files, no dependencies)
- **Description**: Specific, actionable, includes exact file paths

### File Path Conventions (Auto-detected)

**Web Application**:

- Frontend: `frontend/src/components/`, `frontend/src/pages/`
- Backend: `backend/src/models/`, `backend/src/routes/`
- Tests: `frontend/tests/`, `backend/tests/`

**API Service**:

- Code: `src/models/`, `src/routes/`, `src/services/`
- Tests: `tests/unit/`, `tests/integration/`, `tests/contract/`

**CLI Tool**:

- Commands: `cmd/[tool]/main.go`, `cmd/[tool]/commands/`
- Libraries: `pkg/[lib]/`, `internal/[private]/`
- Tests: `tests/`

**Mobile App**:

- Shared: `src/components/`, `src/screens/`, `src/services/`
- Platform: `android/app/`, `ios/App/`
- Tests: `tests/`

**Library**:

- Code: `src/` or `lib/`
- Examples: `examples/`
- Tests: `tests/`

## Task Generation Rules

### From Contracts (if exists)

- Each API endpoint → implementation task
- Each data contract → validation task
- Each interface → implementation task [P]

### From Data Model (if exists)

- Each entity → model creation task [P]
- Each relationship → service layer task
- Each validation rule → test task [P]

### From User Stories (always)

- Each story → integration test [P]
- Each acceptance criterion → unit test [P]
- Each edge case → error handling task

### From Research (if exists)

- Each technical decision → implementation task
- Each dependency → setup task [P]
- Each integration pattern → implementation task

## Dependencies & Execution Order

### Critical Path Dependencies

```
Setup Tasks → Test Creation → Implementation → Integration → Polish
     ↓            ↓              ↓              ↓          ↓
  Project      Tests Fail     Core Logic     Services    Quality
  Structure    (TDD Gate)     Complete       Connected   Complete
```

### Parallel Execution Opportunities

- **Setup**: Dependencies, linting, environment setup [P]
- **Tests**: Contract tests, integration tests, unit tests [P]
- **Models**: Entity creation, basic CRUD operations [P]
- **Services**: Independent business logic [P]
- **Documentation**: API docs, README updates [P]

## Quality Gates & Validation

### Pre-Implementation Gates

- ✅ **All contract tests created and failing**
- ✅ **All integration tests created and failing**
- ✅ **No implementation without failing tests** (TDD violation)

### Implementation Gates

- ✅ **All tests pass** after implementation
- ✅ **Code review completed** for each task
- ✅ **Documentation updated** for changed functionality

### Integration Gates

- ✅ **All services connected** and communicating
- ✅ **External dependencies** properly configured
- ✅ **Error handling** implemented and tested

## Success Criteria

Tasks are well-formed when:

- ✅ **Each task is executable** by an LLM with clear file paths
- ✅ **Dependencies are explicit** and blocking relationships defined
- ✅ **Parallel opportunities identified** with [P] markers
- ✅ **TDD compliance enforced** (tests before implementation)
- ✅ **File paths match** detected project structure
- ✅ **Task granularity appropriate** (5-15 lines of code per task)

## Output Structure

### Task Dependencies Section

```
- Tests (T004-T008) before implementation (T009-T014)
- T009 blocks T010, T016
- T014 blocks T017
- Implementation before polish (T019-T023)
```

### Parallel Execution Examples

```
# Launch T004-T008 together (all test creation):
Task: "Create contract test for POST /api/users"
Task: "Create integration test for user registration"
Task: "Create unit test for email validation"
```

### Validation Checklist

- [ ] All contracts have corresponding tests
- [ ] All entities have model tasks
- [ ] All tests come before implementation
- [ ] Parallel tasks are truly independent
- [ ] Each task specifies exact file path
- [ ] No task modifies same file as another [P] task

## Task Estimation Guidelines

### Task Size Guidelines

- **Small (T001-T099)**: 1-2 hour tasks, single file changes
- **Medium (T100-T199)**: 4-6 hour tasks, multiple file changes
- **Large (T200+)**: 8+ hour tasks, architectural changes

### Complexity Markers

- **🔴 HIGH**: New technology, complex business logic, external integrations
- **🟡 MEDIUM**: Standard patterns, moderate complexity
- **🟢 LOW**: Simple CRUD, standard library usage, configuration

---

**Input**: Design documents from plan.md, data-model.md, contracts/, research.md
**Project Context**: Auto-detected from existing codebase
**Framework**: OpenCode Spec-Driven Development

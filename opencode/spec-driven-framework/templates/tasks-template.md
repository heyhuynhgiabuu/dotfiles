# Tasks: [FEATURE NAME]

**Input**: Design documents from `/specs/[###-feature-name]/`
**Prerequisites**: plan.md (required), research.md, data-model.md, contracts/
**Project Type**: [AUTO-DETECTED: web/mobile/cli/library/etc.]

## Execution Flow (main)

```
1. Load plan.md from feature directory
   → If not found: ERROR "No implementation plan found"
   → Extract: tech stack, libraries, structure, project type
2. Auto-detect project structure and conventions
   → Analyze existing directories: src/, lib/, app/, cmd/, pkg/
   → Detect language-specific patterns: Python imports, Go modules, Rust crates
   → Set file paths based on detected project structure
3. Load optional design documents:
   → Always read plan.md for tech stack and libraries
   → IF EXISTS: Read data-model.md for entities
   → IF EXISTS: Read contracts/ for API endpoints or interfaces
   → IF EXISTS: Read research.md for technical decisions
   → IF EXISTS: Read quickstart.md for test scenarios

   Note: Not all projects have all documents. For example:
   - CLI tools might not have contracts/
   - Simple libraries might not need data-model.md
   - Generate tasks based on what's available

4. Generate tasks by category:
   → Setup: project init, dependencies, linting (auto-detected)
   → Tests: contract tests, integration tests (TDD mandatory)
   → Core: models, services, CLI commands, endpoints (project-type specific)
   → Integration: DB, middleware, logging (tech-stack specific)
   → Polish: unit tests, performance, docs (universal)

5. Apply task rules:
   → Different files = mark [P] for parallel
   → Same file = sequential (no [P])
   → Tests before implementation (TDD)
   → Dependencies block parallel execution

6. Number tasks sequentially (T001, T002...)
7. Generate dependency graph
8. Create parallel execution examples
9. Validate task completeness:
   → All contracts have tests?
   → All entities have models?
   → All endpoints implemented?
10. Return: SUCCESS (tasks ready for execution)
```

## Format: `[ID] [P?] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths based on auto-detected project structure

## Universal Path Conventions

- **Web App (React/Vue + API)**: `frontend/src/`, `backend/src/`, `shared/`
- **API Service**: `src/`, `tests/`, `docs/`
- **CLI Tool**: `cmd/`, `pkg/`, `internal/`
- **Mobile App**: `src/`, `android/`, `ios/`
- **Library**: `src/` or `lib/`, `examples/`, `tests/`
- **Auto-detected** based on existing files and project type

## Phase 3.1: Setup (Auto-detected)

- [ ] T001 Create project structure per implementation plan
- [ ] T002 Initialize [language] project with [framework] dependencies
- [ ] T003 [P] Configure linting and formatting tools
- [ ] T004 [P] Set up development environment (dev dependencies, scripts)

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3

**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**

- [ ] T005 [P] Contract test POST /api/users in tests/contract/test_users_post.py
- [ ] T006 [P] Contract test GET /api/users/{id} in tests/contract/test_users_get.py
- [ ] T007 [P] Integration test user registration in tests/integration/test_registration.py
- [ ] T008 [P] Integration test auth flow in tests/integration/test_auth.py

## Phase 3.3: Core Implementation (ONLY after tests are failing)

- [ ] T009 [P] User model in src/models/user.py
- [ ] T010 [P] UserService CRUD in src/services/user_service.py
- [ ] T011 [P] CLI --create-user in src/cli/user_commands.py
- [ ] T012 POST /api/users endpoint in src/routes/users.py
- [ ] T013 GET /api/users/{id} endpoint in src/routes/users.py
- [ ] T014 Input validation in src/middleware/validation.py
- [ ] T015 Error handling and logging in src/middleware/error_handler.py

## Phase 3.4: Integration (Tech-stack specific)

- [ ] T016 Connect UserService to database in src/services/database.py
- [ ] T017 Authentication middleware in src/middleware/auth.py
- [ ] T018 Request/response logging in src/middleware/logging.py
- [ ] T019 CORS and security headers in src/middleware/security.py

## Phase 3.5: Polish (Universal)

- [ ] T020 [P] Unit tests for validation in tests/unit/test_validation.py
- [ ] T021 Performance tests (<200ms p95) in tests/performance/test_response_time.py
- [ ] T022 [P] Update API documentation in docs/api.md
- [ ] T023 Remove code duplication in src/utils/helpers.py
- [ ] T024 Run quickstart validation in tests/e2e/test_quickstart.py

## Dependencies

- Tests (T005-T008) before implementation (T009-T015)
- T009 blocks T010, T016
- T014 blocks T017
- Implementation before polish (T020-T024)

## Parallel Example

```
# Launch T005-T008 together (all contract tests):
Task: "Contract test POST /api/users in tests/contract/test_users_post.py"
Task: "Contract test GET /api/users/{id} in tests/contract/test_users_get.py"
Task: "Integration test user registration in tests/integration/test_registration.py"
Task: "Integration test auth flow in tests/integration/test_auth.py"

# Then launch T009-T011 together (independent models/services):
Task: "User model in src/models/user.py"
Task: "UserService CRUD in src/services/user_service.py"
Task: "CLI --create-user in src/cli/user_commands.py"
```

## Notes

- [P] tasks = different files, no dependencies
- Verify tests fail before implementing (TDD requirement)
- Commit after each task completion
- Avoid: vague tasks, same file conflicts

## Task Generation Rules

_Applied during main() execution_

1. **From Contracts** (if exists):
   - Each contract file → contract test task [P]
   - Each endpoint/interface → implementation task
   - Each data contract → validation task

2. **From Data Model** (if exists):
   - Each entity → model creation task [P]
   - Relationships → service layer tasks
   - Validation rules → test tasks

3. **From User Stories** (always):
   - Each story → integration test [P]
   - Quickstart scenarios → validation tasks
   - Edge cases → additional test tasks

4. **Project-Type Specific**:
   - **Web App**: Frontend/backend separation, API contracts
   - **CLI Tool**: Command structure, argument parsing, help text
   - **Mobile App**: Platform-specific UI, native integrations
   - **Library**: Public API, examples, documentation
   - **API Service**: Endpoints, middleware, authentication

5. **Tech-Stack Specific**:
   - **Node.js**: package.json, npm scripts, ES modules/CommonJS
   - **Python**: requirements.txt, setup.py, virtual environments
   - **Go**: go.mod, go.sum, package structure
   - **Rust**: Cargo.toml, Cargo.lock, crate structure
   - **Java**: pom.xml/gradle, package structure, build tools

## Validation Checklist

_GATE: Checked by main() before returning_

- [ ] All contracts have corresponding tests
- [ ] All entities have model tasks
- [ ] All tests come before implementation (TDD)
- [ ] Parallel tasks truly independent
- [ ] Each task specifies exact file path
- [ ] No task modifies same file as another [P] task
- [ ] Project structure matches detected type
- [ ] Tech stack conventions followed

## Auto-Detection Results

_Generated during execution_

**Project Type**: [web-app/mobile-app/cli-tool/library/api-service]
**Primary Language**: [javascript/python/go/rust/java/etc.]
**Framework**: [react/vue/express/fastapi/axum/actix/etc.]
**Structure**: [frontend+backend/single-service/cli+lib/mobile+api/etc.]
**Testing**: [jest/pytest/cargo-test/junit/etc.]
**Paths**: [src/lib/app/cmd/pkg/etc.]

---

_Generated by OpenCode Spec-Driven Development Framework v1.0_

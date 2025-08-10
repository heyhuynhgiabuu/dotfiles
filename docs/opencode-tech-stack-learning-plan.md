# sst/opencode Tech Stack & Actionable Learning Plan (TypeScript · Bun · Go)

Date: 2025-08-10

This document summarizes the public tech stack of the `sst/opencode` repo (dev branch) and provides a practical learning plan aligned to TypeScript, Bun, and complementary Go skills.

---

## 1) Tech Stack Profile

- Languages & Runtimes
  - TypeScript (ESM-first; "type": "module")
  - Bun runtime (declared via packageManager, used to run scripts)
  - Node compatibility via types; Bun preferred for local dev
  - No Go code in-repo (see complementary plan)

- Frameworks & Libraries
  - CLI: yargs (command parsing), @clack/prompts (interactive prompts)
  - API/Server: hono (fast ESM web framework), zod (schema validation)
  - AI/Agents: `ai` SDK, `@opencode-ai/plugin`, `@opencode-ai/sdk`
  - MCP: `@modelcontextprotocol/sdk` for Model Context Protocol integrations
  - Utilities: remeda, isomorphic-git, tree-sitter (and grammars)

- Tooling
  - Runtime/build: Bun (fast TS/ESM execution)
  - Type checking: tsc (extends `@tsconfig/bun`)
  - Format: prettier (opinionated config)
  - CI: GitHub Actions workflows present in repo

- Structure Patterns (typical)
  - Monorepo/workspaces: packages/*, cloud/*, sdk/*
  - CLI entry: packages/opencode/src/index.ts
  - Commands in src/cli/cmd/*
  - Docs and scripts directories for developer workflows

- Integration Points
  - MCP commands/clients
  - GitHub Actions: usage via @actions/core and @actions/github

---

## 2) Dependencies & Scripts Overview

- Key Runtime Dependencies (name → purpose)
  - `@modelcontextprotocol/sdk` → MCP client/server integration
  - `hono` → HTTP server/router
  - `zod` → Validation and schema
  - `ai` → LLM integration
  - `yargs` → CLI argument parsing
  - `remeda` → Utilities
  - `isomorphic-git` → Git ops in JS
  - `tree-sitter` (plus grammars) → parsing/code analysis
  - `@clack/prompts` → interactive prompts

- Dev Dependencies
  - `prettier` → formatting
  - `@tsconfig/bun` → TS baseline for Bun
  - `@types/*` → ambient types

- Scripts (typical examples)
  - `dev`: Run main CLI with Bun (development conditions)
  - `typecheck`: Run TypeScript checks across workspaces
  - `postinstall`: Repo hook bootstrap (e.g., git hooks)

- TypeScript Conventions
  - ESM modules, strict mode, `moduleResolution: bundler` (or via tsconfig preset)
  - DOM, ESNext libs enabled where needed

---

## 3) Actionable Learning Plan (2–3 Weeks)

### A. TypeScript Essentials (2–3 days)
- Topics
  - ESM imports/exports, strict typing, generics, union/intersection types
  - Runtime validation with zod; inferring TS types from zod schemas
  - Project TS config aligned with `@tsconfig/bun`
- Exercises
  - Build a small CLI command with yargs + zod validation
  - Add a new subcommand to a sample CLI (e.g., `hello`, `version`)

### B. Bun Runtime (2–3 days)
- Topics
  - Install Bun; use `bun install`, `bun run`, `bunx`
  - Running TS directly; differences vs Node (ESM-first, speed, test runner)
  - Using Bun for monorepos/workspaces
- Exercises
  - Port a Node script to Bun and compare performance
  - Write minimal HTTP server with hono; hit a JSON endpoint

### C. Repo Patterns: Monorepo, CLI, Agents (3–5 days)
- Topics
  - Workspaces layout; packages/opencode structure; src/cli/cmd/* patterns
  - Command composition (yargs), prompts with @clack/prompts
  - Validation with zod; organizing utilities; isomorphic-git usage
  - Intro to MCP via @modelcontextprotocol/sdk
- Exercises
  - Create a new workspace package (e.g., `packages/example-plugin`)
  - Implement a CLI command that calls a simple MCP client or local HTTP API

### D. Go (Complementary, parallel 1–2 weeks)
- Rationale
  - While not in the repo, Go pairs well for CLIs/services that integrate via HTTP/MCP
- Topics
  - Modules, error handling, context
  - Build a CLI with cobra or urfave/cli
  - REST API with chi or gin, JSON validation, logging
- Exercises
  - Go microservice exposing `/health` and `/v1/items` CRUD
  - Call it from a TS CLI (hono fetch or native fetch) and validate with zod

### Weekly Plan Snapshot
- Week 1: TS + Bun fundamentals; small CLI and HTTP server
- Week 2: Monorepo plugin/agent patterns; MCP client usage; finish a mini-agent
- Week 3: Go service + TS CLI integration; optional deploy

---

## 4) Hands-On Checklist

- [ ] Install Bun and verify (`bun --version`)
- [ ] Initialize a TS project and adopt `@tsconfig/bun`
- [ ] Build a CLI command with yargs + zod
- [ ] Create a hono server with 2 routes (JSON + static)
- [ ] Add MCP client call stub (list tools, send a request)
- [ ] Implement a Go microservice and integrate from TS CLI
- [ ] Add prettier and run formatting
- [ ] Typecheck entire workspace

---

## 5) Sources & Links (retrieved 2025-08-10)

- Repo artifact: package.json (dev): https://github.com/sst/opencode/blob/dev/package.json
- TypeScript: https://www.typescriptlang.org/docs/ | TSConfig: https://www.typescriptlang.org/tsconfig
- Bun: https://bun.sh/docs
- Hono: https://hono.dev/
- Zod: https://zod.dev/
- MCP SDK: https://github.com/modelcontextprotocol/sdk
- yargs: https://github.com/yargs/yargs
- remeda: https://remedajs.com/
- isomorphic-git: https://isomorphic-git.org/

Notes
- Some repo details (e.g., full workflows, subpackage READMEs) may change; confirm against the dev branch when following this plan.

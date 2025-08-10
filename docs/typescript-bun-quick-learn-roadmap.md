# TypeScript + Bun: 2-Week Quick Learn Roadmap

All info is current as of 2025-08-10 and prioritizes official sources. Focus: backend and scripting, cross-platform (macOS/Linux), minimal fluff.

---

## 1) Two-Week Plan

### Week 1: Foundations & Core Skills

- Day 1: Environment Setup
  - Install Bun (macOS/Linux)
  - Initialize a Bun + TypeScript project
  - Editor setup (VS Code, Neovim)
  - Lint/format basics

- Day 2: TypeScript Essentials for Bun
  - Type annotations, interfaces, types
  - Modules (ESM), imports/exports
  - tsconfig.json: strict mode, target, moduleResolution

- Day 3: Bun Runtime Fundamentals
  - Running scripts: `bun run`, `bunx`
  - TypeScript transpile: built-in, no `tsc` needed
  - Environment variables: `.env`, `Bun.env`
  - Bun test runner basics

- Day 4: HTTP Servers & Routing
  - `Bun.serve` basics
  - Routing patterns (manual, with frameworks)
  - Middleware: simple patterns

- Day 5: Package Management & Modules
  - `bun add/remove/update`
  - ESM/CJS support, import caveats
  - `bunfig.toml` vs `package.json`

- Day 6: File System, Process, Async
  - Bun’s fs/process APIs
  - Async/await, Promises
  - Workers/threads intro

- Day 7: Review & Mini-Project Start
  - Recap week
  - Start mini REST API project

### Week 2: Building, Testing, Deploying

- Day 8: Testing with Bun
  - `bun test` (mocks, watch mode)
  - Snapshot testing
  - Coverage (if available)

- Day 9: Debugging & Tooling
  - Stack traces, source maps
  - Debugging in VS Code/Neovim
  - Logging best practices

- Day 10: Build & Deploy
  - Bundling: `bun build`
  - Env vars for prod/dev
  - Docker basics (macOS/Linux)
  - Vercel/Fly.io pointers

- Day 11: Performance & Profiling
  - `bun bench`
  - Profiling, flamegraphs (if supported)
  - Common performance pitfalls

- Day 12: Frameworks & DB Access
  - Try Hono/Elysia (if needed)
  - Database: SQLite quickstart, ORM notes

- Day 13: Complete Mini-Project
  - Add validation, tests, benchmarks

- Day 14: Review, Stretch Topics
  - WebSockets, SSE, workers
  - Edge/serverless notes
  - Final review & next steps

---

## 2) Setup Guide (Copy-Paste Ready)

Install Bun (macOS/Linux):

```sh
curl -fsSL https://bun.sh/install | bash
# Add to PATH if needed (Linux):
echo 'export PATH="$HOME/.bun/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
# Or for zsh:
echo 'export PATH="$HOME/.bun/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc
bun --version  # Verify install
```

- Official install: https://bun.sh/docs/install (2025-08-10)

Initialize a Bun + TypeScript project:

```sh
bun init
# Answer prompts (choose TypeScript)
bun add -d typescript
```

- `bun init` docs: https://bun.sh/docs/cli/init (2025-08-10)

Recommended tsconfig.json:

```jsonc
{
  "compilerOptions": {
    "target": "esnext",
    "module": "esnext",
    "moduleResolution": "bundler",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true
  }
}
```

- TSConfig reference: https://www.typescriptlang.org/tsconfig (2025-08-10)

Lint/Format (optional, minimal):

```sh
bun add -d prettier
npx prettier --write .
# Or Biome (fast, all-in-one):
bun add -d @biomejs/biome
npx biome check .
```

- Prettier: https://prettier.io/docs/en/install.html (2025-08-10)
- Biome: https://biomejs.dev/docs/getting-started/ (2025-08-10)

---

## 3) Hands-on Exercises

Hello World HTTP Server:

```ts
// server.ts
Bun.serve({
  port: 3000,
  fetch(req) {
    return new Response("Hello, Bun!");
  },
});
```

```sh
bun run server.ts
```

JSON Endpoint & Static Files:

```ts
Bun.serve({
  fetch(req) {
    if (req.url.endsWith("/json")) {
      return Response.json({ ok: true });
    }
    return new Response(Bun.file("index.html"));
  },
});
```

CLI Tool with Arg Parsing:

```ts
const [,, ...args] = process.argv;
console.log("Args:", args);
```

```sh
bun run cli.ts foo bar
```

File IO & Network Call:

```ts
const data = await Bun.file("input.txt").text();
const res = await fetch("https://api.github.com");
console.log(await res.json());
```

Test-First Example:

```ts
// sum.ts
export function sum(a: number, b: number) { return a + b; }
// sum.test.ts
import { sum } from "./sum";
import { expect, test } from "bun:test";
test("sum adds", () => expect(sum(1, 2)).toBe(3));
```

```sh
bun test
```

Mock/Snapshot Example:

```ts
import { mock, test } from "bun:test";
test("mock fetch", async () => {
  mock.global("fetch", async () => new Response("ok"));
  // ...test code
});
```

Mini Project: REST API (CRUD)
- Implement in-memory store (array/object)
- Endpoints: GET/POST/PUT/DELETE
- Add input validation (simple type checks)
- Write tests for each endpoint
- Benchmark with `bun bench`

---

## 4) Reference Cheatsheet

Common Bun Commands:
- `bun run <file>` — Run script (TS/JS)
- `bun test` — Run tests
- `bun add <pkg>` — Add package
- `bun remove <pkg>` — Remove package
- `bun upgrade` — Upgrade Bun
- `bun create <template>` — Scaffold project
- `bunx <tool>` — Run CLI tools

Config Files:
- `package.json` — Standard Node/Bun config
- `bunfig.toml` — Bun-specific config (optional)

TypeScript Flags for Bun:
- `"module": "esnext"`
- `"moduleResolution": "bundler"`
- `"target": "esnext"`
- `"strict": true`

ESM Import Patterns:

```ts
import fs from "fs"; // ESM
import { readFile } from "fs";
import pkg from "./package.json" assert { type: "json" };
```

- Use `.js`/`.ts` extensions in imports if needed.

URL/File Path Helpers:

```ts
import { fileURLToPath } from "url";
const __filename = fileURLToPath(import.meta.url);
```

Env Loading:
- `.env` auto-loaded by Bun
- Access with `Bun.env.MY_VAR`

---

## 5) Links & Sources

- Bun Official Docs: https://bun.sh/docs (2025-08-10)
- Bun API Reference: https://bun.sh/docs/api (2025-08-10)
- Bun.serve: https://bun.sh/docs/api/http (2025-08-10)
- Bun test: https://bun.sh/docs/test (2025-08-10)
- TypeScript Handbook: https://www.typescriptlang.org/docs/handbook/intro.html (2025-08-10)
- TSConfig Reference: https://www.typescriptlang.org/tsconfig (2025-08-10)
- Bun Examples: https://github.com/oven-sh/bun-examples (2025-08-10)
- Hono Framework: https://hono.dev/ (2025-08-10)
- Elysia Framework: https://elysiajs.com/ (2025-08-10)
- Biome: https://biomejs.dev/docs/getting-started/ (2025-08-10)
- Prettier: https://prettier.io/docs/en/install.html (2025-08-10)
- SQLite with Bun: https://bun.sh/docs/api/sqlite (2025-08-10)

---

## 6) Pitfalls & Gotchas

- Node vs Bun APIs: Not all Node.js modules are supported; check compatibility (https://bun.sh/docs/nodejs/compatibility).
- ESM-Only: Bun is ESM-first; avoid CJS unless necessary.
- Dynamic Import/Top-level Await: Supported, but check for edge cases.
- Path Resolution: Use explicit extensions; relative paths may differ from Node.
- Testing: Some Node test patterns (e.g., Jest-specific) may not work; use Bun’s test API.
- tsconfig Interop: Use `"moduleResolution": "bundler"` for best results.

---

## 7) Stretch Topics

- WebSockets/SSE: https://bun.sh/docs/api/websocket
- Workers/Threads: https://bun.sh/docs/api/worker
- Edge/Serverless: Vercel Bun runtime notes (https://vercel.com/docs/runtimes#bun) (2025-08-10)
- ORM/DB Clients: Many Node ORMs (Prisma, Drizzle) may not work; prefer Bun’s SQLite API

SQLite Quickstart:

```ts
import { Database } from "bun:sqlite";
const db = new Database("mydb.sqlite");
db.query("CREATE TABLE ...").run();
```

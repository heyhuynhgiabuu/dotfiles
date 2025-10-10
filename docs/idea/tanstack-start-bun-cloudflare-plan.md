# The ACTUAL Cloudflare Stack - Complete Implementation Plan

**Last Updated:** October 5, 2025  
**Time Commitment:** 2 hours/day  
**Total Duration:** 10-14 weeks  
**Architecture:** Monorepo with separate backend/frontend

---

## Stack Architecture

```
STRUCTURE:   Monorepo (apps/api + apps/web)
BACKEND:     Bun + Hono + Cloudflare Workers
DATABASE:    Cloudflare D1 + Drizzle ORM
FRONTEND:    TanStack Start (client-focused)
STYLING:     Tailwind CSS + shadcn/ui
AUTH:        Clerk
DEPLOY:      Wrangler CLI
COST:        $0/month (free tier)
```

**Why this architecture:**

- ✅ Clean separation of concerns
- ✅ Backend API is reusable (mobile app later)
- ✅ Frontend is just a client (no server functions confusion)
- ✅ Both deploy to Cloudflare (Workers + Pages)
- ✅ Type-safe with shared types

---

## Directory Structure

```
my-dashboard/
  apps/
    api/                    # Hono backend (Cloudflare Workers)
      src/
        routes/
          tasks.ts
          auth.ts
        db/
          schema.ts
          index.ts
        middleware/
          auth.ts
        index.ts
      wrangler.toml
      package.json
      tsconfig.json

    web/                    # TanStack Start frontend (Cloudflare Pages)
      src/
        routes/
          __root.tsx
          index.tsx
          dashboard.tsx
        components/
          ui/               # shadcn/ui
        lib/
          api.ts           # API client
        hooks/
      public/
      app.config.ts
      package.json
      tsconfig.json
      wrangler.toml

  packages/
    types/                  # Shared TypeScript types
      src/
        index.ts
      package.json

  bun.lockb
  package.json              # Root package.json (workspace)
  turbo.json                # Turborepo config
```

---

## Prerequisites

```bash
# Install Bun
curl -fsSL https://bun.sh/install | bash
bun --version

# Install Wrangler
bun add -g wrangler
wrangler login

# Install Turborepo
bun add -g turbo
```

**Accounts needed:**

- Cloudflare (https://dash.cloudflare.com)
- Clerk (https://clerk.com)
- GitHub (for deployment)

---

## Phase 1: Monorepo Setup (Week 1)

### Day 1-2: Create Monorepo (4 hours)

```bash
# Create project root
mkdir my-dashboard
cd my-dashboard

# Initialize workspace
bun init -y

# Create directory structure
mkdir -p apps/api/src/{routes,db,middleware}
mkdir -p apps/web/src/{routes,components,lib,hooks}
mkdir -p packages/types/src
```

**Root package.json:**

```json
{
  "name": "my-dashboard",
  "private": true,
  "workspaces": ["apps/*", "packages/*"],
  "scripts": {
    "dev": "turbo dev",
    "build": "turbo build",
    "deploy": "turbo deploy"
  },
  "devDependencies": {
    "turbo": "latest",
    "typescript": "^5.0.0"
  }
}
```

**turbo.json:**

```json
{
  "$schema": "https://turbo.build/schema.json",
  "pipeline": {
    "dev": {
      "cache": false,
      "persistent": true
    },
    "build": {
      "dependsOn": ["^build"],
      "outputs": [".output/**", "dist/**"]
    },
    "deploy": {
      "dependsOn": ["build"]
    }
  }
}
```

**Checkpoint:**

```
✓ Monorepo structure created
✓ Turborepo configured
✓ Workspace ready
```

---

### Day 3-4: Backend Setup (Hono + D1) (4 hours)

**Install backend packages:**

```bash
cd apps/api
bun init -y
bun add hono
bun add drizzle-orm
bun add -D drizzle-kit wrangler @cloudflare/workers-types
```

**apps/api/package.json:**

```json
{
  "name": "api",
  "scripts": {
    "dev": "wrangler dev src/index.ts",
    "build": "echo 'Backend build via wrangler'",
    "deploy": "wrangler deploy",
    "db:generate": "drizzle-kit generate",
    "db:migrate": "wrangler d1 execute my-dashboard-db --remote --file=./drizzle/0000_init.sql"
  },
  "dependencies": {
    "hono": "latest",
    "drizzle-orm": "latest"
  },
  "devDependencies": {
    "drizzle-kit": "latest",
    "wrangler": "latest",
    "@cloudflare/workers-types": "latest"
  }
}
```

**apps/api/wrangler.toml:**

```toml
name = "my-dashboard-api"
main = "src/index.ts"
compatibility_date = "2025-10-05"

[[d1_databases]]
binding = "DB"
database_name = "my-dashboard-db"
database_id = "YOUR_DATABASE_ID"  # Get from: wrangler d1 create my-dashboard-db
```

**apps/api/src/db/schema.ts:**

```typescript
import { sqliteTable, text, integer } from "drizzle-orm/sqlite-core";
import { sql } from "drizzle-orm";

export const tasks = sqliteTable("tasks", {
  id: text("id").primaryKey(),
  userId: text("user_id").notNull(),
  title: text("title").notNull(),
  completed: integer("completed", { mode: "boolean" }).default(false),
  createdAt: text("created_at").default(sql`CURRENT_TIMESTAMP`),
});

export type Task = typeof tasks.$inferSelect;
export type NewTask = typeof tasks.$inferInsert;
```

**apps/api/src/db/index.ts:**

```typescript
import { drizzle } from "drizzle-orm/d1";
import * as schema from "./schema";

export function getDb(db: D1Database) {
  return drizzle(db, { schema });
}

export * from "./schema";
```

**apps/api/drizzle.config.ts:**

```typescript
import type { Config } from "drizzle-kit";

export default {
  schema: "./src/db/schema.ts",
  out: "./drizzle",
  dialect: "sqlite",
  driver: "d1-http",
  dbCredentials: {
    accountId: process.env.CLOUDFLARE_ACCOUNT_ID!,
    databaseId: process.env.CLOUDFLARE_DATABASE_ID!,
    token: process.env.CLOUDFLARE_API_TOKEN!,
  },
} satisfies Config;
```

**apps/api/src/index.ts:**

```typescript
import { Hono } from "hono";
import { cors } from "hono/cors";
import tasks from "./routes/tasks";

type Bindings = {
  DB: D1Database;
};

const app = new Hono<{ Bindings: Bindings }>();

app.use("/*", cors());

app.get("/", (c) => c.json({ message: "API running" }));

app.route("/tasks", tasks);

export default app;
```

**apps/api/src/routes/tasks.ts:**

```typescript
import { Hono } from "hono";
import { getDb, tasks, type Task, type NewTask } from "../db";
import { eq } from "drizzle-orm";

type Bindings = {
  DB: D1Database;
};

const app = new Hono<{ Bindings: Bindings }>();

app.get("/", async (c) => {
  const db = getDb(c.env.DB);
  const userId = c.req.header("x-user-id") || "demo-user";
  const allTasks = await db
    .select()
    .from(tasks)
    .where(eq(tasks.userId, userId))
    .all();
  return c.json(allTasks);
});

app.post("/", async (c) => {
  const db = getDb(c.env.DB);
  const userId = c.req.header("x-user-id") || "demo-user";
  const body = await c.req.json<{ title: string }>();

  const newTask: NewTask = {
    id: crypto.randomUUID(),
    userId,
    title: body.title,
    completed: false,
  };

  await db.insert(tasks).values(newTask);
  return c.json(newTask, 201);
});

app.patch("/:id", async (c) => {
  const db = getDb(c.env.DB);
  const id = c.req.param("id");
  const body = await c.req.json<{ completed: boolean }>();

  await db
    .update(tasks)
    .set({ completed: body.completed })
    .where(eq(tasks.id, id));
  return c.json({ success: true });
});

app.delete("/:id", async (c) => {
  const db = getDb(c.env.DB);
  const id = c.req.param("id");

  await db.delete(tasks).where(eq(tasks.id, id));
  return c.json({ success: true });
});

export default app;
```

**Create database:**

```bash
cd apps/api

# Create D1 database
wrangler d1 create my-dashboard-db
# Copy database_id to wrangler.toml

# Generate migration
bun run db:generate

# Run migration locally
wrangler d1 execute my-dashboard-db --local --file=./drizzle/0000_init.sql

# Test locally
bun run dev
# Visit http://localhost:8787
```

**Checkpoint:**

```
✓ Hono API running
✓ D1 database created
✓ Drizzle ORM configured
✓ CRUD routes work
✓ Local dev at :8787
```

---

### Day 5-7: Frontend Setup (TanStack Start) (6 hours)

```bash
cd apps/web

# Create base with shadcn
bun init --react=shadcn
```

**Install TanStack Start:**

```bash
bun add @tanstack/react-router @tanstack/router-devtools @tanstack/start vinxi react-dom
bun add -D @tanstack/router-plugin
```

**apps/web/package.json:**

```json
{
  "name": "web",
  "scripts": {
    "dev": "vinxi dev",
    "build": "vinxi build",
    "deploy": "wrangler pages deploy .output/public --project-name=my-dashboard"
  },
  "dependencies": {
    "@tanstack/react-router": "latest",
    "@tanstack/router-devtools": "latest",
    "@tanstack/start": "latest",
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "vinxi": "latest"
  },
  "devDependencies": {
    "@tanstack/router-plugin": "latest",
    "wrangler": "latest"
  }
}
```

**apps/web/app.config.ts:**

```typescript
import { defineConfig } from "@tanstack/start/config";
import { TanStackRouterVite } from "@tanstack/router-plugin/vite";

export default defineConfig({
  vite: {
    plugins: [
      TanStackRouterVite({
        routesDirectory: "./src/routes",
        generatedRouteTree: "./src/routeTree.gen.ts",
      }),
    ],
  },
});
```

**apps/web/src/lib/api.ts:**

```typescript
const API_URL = import.meta.env.VITE_API_URL || "http://localhost:8787";

export async function apiFetch<T>(
  path: string,
  options?: RequestInit,
): Promise<T> {
  const res = await fetch(`${API_URL}${path}`, {
    ...options,
    headers: {
      "Content-Type": "application/json",
      "x-user-id": "demo-user", // TODO: Replace with Clerk user ID
      ...options?.headers,
    },
  });

  if (!res.ok) throw new Error(`API error: ${res.statusText}`);
  return res.json();
}

export const api = {
  tasks: {
    list: () => apiFetch<Task[]>("/tasks"),
    create: (title: string) =>
      apiFetch<Task>("/tasks", {
        method: "POST",
        body: JSON.stringify({ title }),
      }),
    update: (id: string, completed: boolean) =>
      apiFetch<{ success: boolean }>(`/tasks/${id}`, {
        method: "PATCH",
        body: JSON.stringify({ completed }),
      }),
    delete: (id: string) =>
      apiFetch<{ success: boolean }>(`/tasks/${id}`, {
        method: "DELETE",
      }),
  },
};

type Task = {
  id: string;
  userId: string;
  title: string;
  completed: boolean;
  createdAt: string;
};
```

**apps/web/src/routes/\_\_root.tsx:**

```typescript
import { createRootRoute, Link, Outlet } from "@tanstack/react-router"
import { TanStackRouterDevtools } from "@tanstack/router-devtools"
import "../index.css"

export const Route = createRootRoute({
  component: RootComponent,
})

function RootComponent() {
  return (
    <html lang="en">
      <head>
        <meta charSet="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>My Dashboard</title>
      </head>
      <body>
        <nav className="bg-gray-900 text-white p-4 shadow-lg">
          <div className="container mx-auto flex gap-6">
            <Link to="/" className="hover:text-blue-400 transition">Home</Link>
            <Link to="/dashboard" className="hover:text-blue-400 transition">Dashboard</Link>
          </div>
        </nav>
        <main>
          <Outlet />
        </main>
        <TanStackRouterDevtools position="bottom-right" />
      </body>
    </html>
  )
}
```

**apps/web/src/routes/index.tsx:**

```typescript
import { createFileRoute, Link } from "@tanstack/react-router"
import { Button } from "~/components/ui/button"

export const Route = createFileRoute("/")({
  component: Home,
})

function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-indigo-500 via-purple-500 to-pink-500">
      <div className="container mx-auto px-4 py-20 text-center text-white">
        <h1 className="text-6xl font-bold mb-6">Your Dashboard</h1>
        <p className="text-xl mb-8 text-white/90">
          Hono backend + TanStack Start frontend on Cloudflare
        </p>
        <Button size="lg" asChild className="bg-white text-indigo-600 hover:bg-gray-100">
          <Link to="/dashboard">Get Started →</Link>
        </Button>
      </div>
    </div>
  )
}
```

**apps/web/src/routes/dashboard.tsx:**

```typescript
import { createFileRoute } from "@tanstack/react-router"
import { useState, useEffect } from "react"
import { api } from "~/lib/api"
import { Button } from "~/components/ui/button"
import { Input } from "~/components/ui/input"
import { Card, CardHeader, CardTitle, CardContent } from "~/components/ui/card"
import { Checkbox } from "~/components/ui/checkbox"

export const Route = createFileRoute("/dashboard")({
  component: Dashboard,
})

type Task = {
  id: string
  userId: string
  title: string
  completed: boolean
  createdAt: string
}

function Dashboard() {
  const [tasks, setTasks] = useState<Task[]>([])
  const [newTask, setNewTask] = useState("")
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadTasks()
  }, [])

  async function loadTasks() {
    setLoading(true)
    const data = await api.tasks.list()
    setTasks(data)
    setLoading(false)
  }

  async function addTask() {
    if (!newTask.trim()) return
    await api.tasks.create(newTask)
    setNewTask("")
    loadTasks()
  }

  async function toggleTask(id: string, completed: boolean) {
    await api.tasks.update(id, !completed)
    loadTasks()
  }

  async function deleteTask(id: string) {
    await api.tasks.delete(id)
    loadTasks()
  }

  return (
    <div className="container mx-auto p-8 max-w-4xl">
      <h1 className="text-4xl font-bold mb-8">Dashboard</h1>

      <Card className="mb-8">
        <CardHeader>
          <CardTitle>Add Task</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex gap-2">
            <Input
              value={newTask}
              onChange={(e) => setNewTask(e.target.value)}
              onKeyDown={(e) => e.key === "Enter" && addTask()}
              placeholder="What needs to be done?"
            />
            <Button onClick={addTask}>Add</Button>
          </div>
        </CardContent>
      </Card>

      <div className="space-y-2">
        {loading ? (
          <p className="text-gray-500">Loading...</p>
        ) : tasks.length === 0 ? (
          <p className="text-gray-500">No tasks yet. Add one above!</p>
        ) : (
          tasks.map((task) => (
            <Card key={task.id}>
              <CardContent className="flex items-center justify-between p-4">
                <div className="flex items-center gap-3">
                  <Checkbox
                    checked={task.completed}
                    onCheckedChange={() => toggleTask(task.id, task.completed)}
                  />
                  <span className={task.completed ? "line-through text-gray-500" : ""}>
                    {task.title}
                  </span>
                </div>
                <Button
                  variant="destructive"
                  size="sm"
                  onClick={() => deleteTask(task.id)}
                >
                  Delete
                </Button>
              </CardContent>
            </Card>
          ))
        )}
      </div>
    </div>
  )
}
```

**apps/web/src/router.tsx:**

```typescript
import { createRouter } from "@tanstack/react-router";
import { routeTree } from "./routeTree.gen";

export const router = createRouter({
  routeTree,
});

declare module "@tanstack/react-router" {
  interface Register {
    router: typeof router;
  }
}
```

**apps/web/src/client.tsx:**

```typescript
import { hydrateRoot } from "react-dom/client"
import { StartClient } from "@tanstack/start"
import { router } from "./router"

hydrateRoot(document.getElementById("root")!, <StartClient router={router} />)
```

**apps/web/src/ssr.tsx:**

```typescript
import {
  createStartHandler,
  defaultStreamHandler,
} from "@tanstack/start/server";
import { getRouterManifest } from "@tanstack/start/router-manifest";
import { router } from "./router";

export default createStartHandler({
  createRouter() {
    return router;
  },
  getRouterManifest,
})(defaultStreamHandler);
```

**apps/web/wrangler.toml:**

```toml
name = "my-dashboard-web"
compatibility_date = "2025-10-05"
pages_build_output_dir = ".output/public"
```

**Test frontend:**

```bash
cd apps/web
bun run dev
# Visit http://localhost:3000
```

**Checkpoint:**

```
✓ TanStack Start running
✓ API client configured
✓ Dashboard with tasks CRUD
✓ shadcn/ui components
✓ Frontend at :3000, backend at :8787
```

---

## Phase 2: Full Integration (Week 2)

### Day 8-10: Run Both Together (6 hours)

**Root package.json (update scripts):**

```json
{
  "scripts": {
    "dev": "turbo dev",
    "dev:api": "cd apps/api && bun run dev",
    "dev:web": "cd apps/web && bun run dev",
    "build": "turbo build",
    "deploy:api": "cd apps/api && bun run deploy",
    "deploy:web": "cd apps/web && bun run deploy"
  }
}
```

**Run everything:**

```bash
# Terminal 1: Backend
bun run dev:api

# Terminal 2: Frontend
bun run dev:web

# OR use Turborepo (parallel)
bun run dev
```

**Test flow:**

1. Open http://localhost:3000
2. Add task → POST to http://localhost:8787/tasks
3. See task appear
4. Toggle/delete task → PATCH/DELETE to backend

---

### Day 11-14: Deploy to Cloudflare (6 hours)

**Deploy backend:**

```bash
cd apps/api

# Deploy API
wrangler deploy

# Migrate database
wrangler d1 execute my-dashboard-db --remote --file=./drizzle/0000_init.sql

# Get API URL
# Example: https://my-dashboard-api.workers.dev
```

**Update frontend env:**

```bash
cd apps/web

# Create .env.production
echo 'VITE_API_URL=https://my-dashboard-api.workers.dev' > .env.production
```

**Deploy frontend:**

```bash
bun run build
bun run deploy

# Get frontend URL
# Example: https://my-dashboard.pages.dev
```

**End of Week 2 Milestone:**

- ✅ Backend API on Cloudflare Workers
- ✅ Frontend on Cloudflare Pages
- ✅ D1 database running
- ✅ Full CRUD working
- ✅ Both deployed and connected

---

## Phase 3: Shared Types (Week 3)

### Day 15-17: Type Safety Across Monorepo (6 hours)

**packages/types/package.json:**

```json
{
  "name": "@my-dashboard/types",
  "version": "0.0.1",
  "main": "./src/index.ts",
  "types": "./src/index.ts"
}
```

**packages/types/src/index.ts:**

```typescript
export type Task = {
  id: string;
  userId: string;
  title: string;
  completed: boolean;
  createdAt: string;
};

export type NewTask = Omit<Task, "id" | "createdAt">;

export type ApiResponse<T> = {
  data?: T;
  error?: string;
};

export type TasksListResponse = ApiResponse<Task[]>;
export type TaskCreateRequest = { title: string };
export type TaskUpdateRequest = { completed: boolean };
```

**Update backend to use shared types:**

```typescript
// apps/api/src/routes/tasks.ts
import type { Task, TaskCreateRequest } from "@my-dashboard/types";

app.post("/", async (c) => {
  const body = await c.req.json<TaskCreateRequest>();
  // ...
});
```

**Update frontend to use shared types:**

```typescript
// apps/web/src/lib/api.ts
import type { Task, TaskCreateRequest } from "@my-dashboard/types";

export const api = {
  tasks: {
    list: () => apiFetch<Task[]>("/tasks"),
    create: (title: string) =>
      apiFetch<Task>("/tasks", {
        method: "POST",
        body: JSON.stringify({ title } as TaskCreateRequest),
      }),
  },
};
```

**Checkpoint:**

```
✓ Shared types package
✓ Backend uses types
✓ Frontend uses types
✓ No type duplication
```

---

## Phase 4: Authentication (Week 4-5)

### Day 18-21: Clerk Setup (6 hours)

**Install Clerk:**

```bash
# Frontend
cd apps/web
bun add @clerk/clerk-react

# Backend
cd apps/api
bun add @clerk/backend
```

**Clerk dashboard setup:**

1. Create app at https://clerk.com
2. Copy publishable key and secret key
3. Add allowed origins: `http://localhost:3000` and `https://my-dashboard.pages.dev`

**apps/web/.env:**

```bash
VITE_CLERK_PUBLISHABLE_KEY=pk_test_xxx
```

**Wrap app with Clerk:**

```typescript
// apps/web/src/routes/__root.tsx
import { ClerkProvider, SignedIn, SignedOut, SignInButton, UserButton } from "@clerk/clerk-react"

const clerkPubKey = import.meta.env.VITE_CLERK_PUBLISHABLE_KEY

function RootComponent() {
  return (
    <ClerkProvider publishableKey={clerkPubKey}>
      <html lang="en">
        <head>
          <meta charSet="UTF-8" />
          <title>My Dashboard</title>
        </head>
        <body>
          <nav className="bg-gray-900 text-white p-4">
            <div className="container mx-auto flex justify-between items-center">
              <div className="flex gap-6">
                <Link to="/">Home</Link>
                <SignedIn>
                  <Link to="/dashboard">Dashboard</Link>
                </SignedIn>
              </div>
              <div>
                <SignedOut>
                  <SignInButton mode="modal">
                    <Button>Sign In</Button>
                  </SignInButton>
                </SignedOut>
                <SignedIn>
                  <UserButton />
                </SignedIn>
              </div>
            </div>
          </nav>
          <Outlet />
        </body>
      </html>
    </ClerkProvider>
  )
}
```

**Protect dashboard route:**

```typescript
// apps/web/src/routes/dashboard.tsx
import { useUser } from "@clerk/clerk-react"
import { useNavigate } from "@tanstack/react-router"
import { useEffect } from "react"

function Dashboard() {
  const { isSignedIn, user, isLoaded } = useUser()
  const navigate = useNavigate()

  useEffect(() => {
    if (isLoaded && !isSignedIn) {
      navigate({ to: "/" })
    }
  }, [isLoaded, isSignedIn])

  if (!isLoaded) return <div>Loading...</div>
  if (!isSignedIn) return null

  // ... rest of component
}
```

**Update API client to send auth token:**

```typescript
// apps/web/src/lib/api.ts
import { useAuth } from "@clerk/clerk-react";

export function useApi() {
  const { getToken } = useAuth();

  async function apiFetch<T>(path: string, options?: RequestInit): Promise<T> {
    const token = await getToken();

    const res = await fetch(`${API_URL}${path}`, {
      ...options,
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
        ...options?.headers,
      },
    });

    if (!res.ok) throw new Error(`API error: ${res.statusText}`);
    return res.json();
  }

  return {
    tasks: {
      list: () => apiFetch<Task[]>("/tasks"),
      // ... rest
    },
  };
}
```

**Backend auth middleware:**

```typescript
// apps/api/src/middleware/auth.ts
import { createMiddleware } from "hono/factory";
import { verifyToken } from "@clerk/backend";

export const authMiddleware = createMiddleware<{
  Bindings: { CLERK_SECRET_KEY: string };
}>(async (c, next) => {
  const authHeader = c.req.header("Authorization");

  if (!authHeader?.startsWith("Bearer ")) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  const token = authHeader.substring(7);

  try {
    const payload = await verifyToken(token, {
      secretKey: c.env.CLERK_SECRET_KEY,
    });

    c.set("userId", payload.sub);
    await next();
  } catch (err) {
    return c.json({ error: "Invalid token" }, 401);
  }
});
```

**Use auth middleware:**

```typescript
// apps/api/src/routes/tasks.ts
import { authMiddleware } from "../middleware/auth";

app.use("/*", authMiddleware);

app.get("/", async (c) => {
  const userId = c.get("userId");
  const db = getDb(c.env.DB);
  const allTasks = await db
    .select()
    .from(tasks)
    .where(eq(tasks.userId, userId))
    .all();
  return c.json(allTasks);
});
```

**Update wrangler.toml:**

```toml
# apps/api/wrangler.toml
[vars]
CLERK_SECRET_KEY = "sk_test_xxx"
```

**Checkpoint:**

```
✓ Clerk authentication
✓ Protected routes
✓ Backend validates tokens
✓ User-specific data
```

---

## Phase 5: Production Features (Week 6-8)

### Week 6: Advanced UI

**Day 22-25: More shadcn components (6 hours)**

```bash
cd apps/web
bunx shadcn@latest add dialog
bunx shadcn@latest add dropdown-menu
bunx shadcn@latest add avatar
bunx shadcn@latest add badge
bunx shadcn@latest add separator
```

**Enhanced dashboard with dialogs:**

```typescript
// apps/web/src/routes/dashboard.tsx
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "~/components/ui/dialog"
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "~/components/ui/dropdown-menu"

function Dashboard() {
  const [editingTask, setEditingTask] = useState<Task | null>(null)

  return (
    <div className="container mx-auto p-8">
      {/* ... */}

      <Dialog open={!!editingTask} onOpenChange={(open) => !open && setEditingTask(null)}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Edit Task</DialogTitle>
          </DialogHeader>
          <Input
            defaultValue={editingTask?.title}
            onKeyDown={(e) => {
              if (e.key === "Enter") {
                // Update task logic
                setEditingTask(null)
              }
            }}
          />
        </DialogContent>
      </Dialog>
    </div>
  )
}
```

---

### Week 7: Database Expansion

**Day 26-28: More tables (6 hours)**

```typescript
// apps/api/src/db/schema.ts
export const expenses = sqliteTable("expenses", {
  id: text("id").primaryKey(),
  userId: text("user_id").notNull(),
  amount: integer("amount").notNull(),
  category: text("category").notNull(),
  description: text("description"),
  createdAt: text("created_at").default(sql`CURRENT_TIMESTAMP`),
});

export const categories = sqliteTable("categories", {
  id: text("id").primaryKey(),
  userId: text("user_id").notNull(),
  name: text("name").notNull(),
  color: text("color").notNull(),
});
```

**Create routes:**

```typescript
// apps/api/src/routes/expenses.ts
import { Hono } from "hono";
import { getDb, expenses } from "../db";

const app = new Hono();

app.get("/", async (c) => {
  const userId = c.get("userId");
  const db = getDb(c.env.DB);
  const allExpenses = await db
    .select()
    .from(expenses)
    .where(eq(expenses.userId, userId))
    .all();
  return c.json(allExpenses);
});

// ... CRUD operations

export default app;
```

**Add to main API:**

```typescript
// apps/api/src/index.ts
import expenses from "./routes/expenses";

app.route("/expenses", expenses);
```

---

### Week 8: Analytics

**Day 29-35: Charts and stats (8 hours)**

```bash
cd apps/web
bun add recharts
bunx shadcn@latest add chart
```

**Create analytics route:**

```typescript
// apps/web/src/routes/analytics.tsx
import { createFileRoute } from "@tanstack/react-router"
import { useApi } from "~/lib/api"
import { useEffect, useState } from "react"
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer } from "recharts"
import { Card, CardHeader, CardTitle, CardContent } from "~/components/ui/card"

export const Route = createFileRoute("/analytics")({
  component: Analytics,
})

function Analytics() {
  const api = useApi()
  const [stats, setStats] = useState([])

  useEffect(() => {
    api.expenses.stats().then(setStats)
  }, [])

  return (
    <div className="container mx-auto p-8">
      <h1 className="text-3xl font-bold mb-8">Analytics</h1>

      <Card>
        <CardHeader>
          <CardTitle>Spending by Category</CardTitle>
        </CardHeader>
        <CardContent>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={stats}>
              <XAxis dataKey="category" />
              <YAxis />
              <Tooltip />
              <Bar dataKey="total" fill="#8884d8" />
            </BarChart>
          </ResponsiveContainer>
        </CardContent>
      </Card>
    </div>
  )
}
```

**Backend stats endpoint:**

```typescript
// apps/api/src/routes/expenses.ts
app.get("/stats", async (c) => {
  const userId = c.get("userId");
  const db = getDb(c.env.DB);

  const stats = await db
    .select({
      category: expenses.category,
      total: sql<number>`sum(${expenses.amount})`,
    })
    .from(expenses)
    .where(eq(expenses.userId, userId))
    .groupBy(expenses.category)
    .all();

  return c.json(stats);
});
```

---

## Phase 6: Performance & Polish (Week 9-10)

### Day 36-42: Optimization (10 hours)

**React Query for caching:**

```bash
cd apps/web
bun add @tanstack/react-query
```

**Setup query client:**

```typescript
// apps/web/src/routes/__root.tsx
import { QueryClient, QueryClientProvider } from "@tanstack/react-query"

const queryClient = new QueryClient()

function RootComponent() {
  return (
    <ClerkProvider publishableKey={clerkPubKey}>
      <QueryClientProvider client={queryClient}>
        {/* ... */}
      </QueryClientProvider>
    </ClerkProvider>
  )
}
```

**Use queries:**

```typescript
// apps/web/src/routes/dashboard.tsx
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query"

function Dashboard() {
  const api = useApi()
  const queryClient = useQueryClient()

  const { data: tasks = [], isLoading } = useQuery({
    queryKey: ["tasks"],
    queryFn: () => api.tasks.list(),
  })

  const createMutation = useMutation({
    mutationFn: (title: string) => api.tasks.create(title),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["tasks"] })
    },
  })

  return (
    // ... use tasks and createMutation.mutate()
  )
}
```

**Add loading states:**

```typescript
{isLoading ? (
  <div className="flex items-center justify-center p-8">
    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900" />
  </div>
) : (
  // ... tasks list
)}
```

**Error boundaries:**

```typescript
// apps/web/src/components/ErrorBoundary.tsx
import { Component, type ReactNode } from "react"
import { Card, CardHeader, CardTitle, CardContent } from "./ui/card"
import { Button } from "./ui/button"

export class ErrorBoundary extends Component<
  { children: ReactNode },
  { hasError: boolean }
> {
  constructor(props) {
    super(props)
    this.state = { hasError: false }
  }

  static getDerivedStateFromError() {
    return { hasError: true }
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="container mx-auto p-8">
          <Card>
            <CardHeader>
              <CardTitle>Something went wrong</CardTitle>
            </CardHeader>
            <CardContent>
              <Button onClick={() => this.setState({ hasError: false })}>
                Try again
              </Button>
            </CardContent>
          </Card>
        </div>
      )
    }

    return this.props.children
  }
}
```

---

## Final Production Checklist

### Before Launch (Week 10, Day 43-49)

**Environment variables:**

```bash
# apps/api/.env.production
CLERK_SECRET_KEY=sk_live_xxx
CLOUDFLARE_ACCOUNT_ID=xxx
CLOUDFLARE_DATABASE_ID=xxx

# apps/web/.env.production
VITE_API_URL=https://api.yourdomain.com
VITE_CLERK_PUBLISHABLE_KEY=pk_live_xxx
```

**Security headers:**

```typescript
// apps/api/src/index.ts
app.use("/*", async (c, next) => {
  await next();
  c.header("X-Content-Type-Options", "nosniff");
  c.header("X-Frame-Options", "DENY");
  c.header("X-XSS-Protection", "1; mode=block");
});
```

**Rate limiting:**

```bash
cd apps/api
bun add hono-rate-limiter
```

```typescript
// apps/api/src/index.ts
import { rateLimiter } from "hono-rate-limiter";

app.use(
  rateLimiter({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // limit each IP to 100 requests per windowMs
  }),
);
```

**Error tracking (optional):**

```bash
bun add @sentry/react @sentry/bun
```

**Performance monitoring:**

```bash
# apps/web/src/index.tsx
import * as Sentry from "@sentry/react"

Sentry.init({
  dsn: "YOUR_SENTRY_DSN",
  integrations: [new Sentry.BrowserTracing()],
  tracesSampleRate: 1.0,
})
```

**Final deployment:**

```bash
# Deploy backend
cd apps/api
bun run deploy

# Deploy frontend
cd apps/web
bun run build
bun run deploy

# Test production
# Visit https://my-dashboard.pages.dev
```

---

## Cost Breakdown (Free Tier)

```
Cloudflare Workers:   100,000 requests/day  = $0
Cloudflare Pages:     Unlimited bandwidth    = $0
Cloudflare D1:        5GB storage            = $0
Clerk:                10,000 MAU              = $0
Total:                                         $0/month
```

**Paid tier triggers:**

- Workers > 100k req/day: $0.50 per million
- D1 > 5GB: $0.75/GB
- Clerk > 10k MAU: $25/month

---

## Development Workflow

```bash
# Daily development
bun run dev              # Start both API + web

# Make changes
# - Backend: apps/api/src/*
# - Frontend: apps/web/src/*
# - Types: packages/types/src/*

# Deploy
bun run build
bun run deploy:api
bun run deploy:web
```

---

## Common Issues

**CORS errors:**

- Add your domain to Hono CORS config
- Update Clerk allowed origins

**Type errors:**

- Run `bun install` in root after adding shared types
- Clear `.turbo` cache: `rm -rf .turbo`

**Database issues:**

- Local: `wrangler d1 execute DB --local --command "SELECT * FROM tasks"`
- Remote: `wrangler d1 execute DB --remote --command "SELECT * FROM tasks"`

**Build failures:**

- Delete `.output` folders
- Clear Bun cache: `bun pm cache rm`

---

## Next Steps

After completing this plan (10-14 weeks):

**Week 11+: Advanced Features**

- [ ] File uploads (Cloudflare R2)
- [ ] Real-time updates (WebSockets via Durable Objects)
- [ ] Email notifications (Resend)
- [ ] PDF export (Puppeteer on Workers)
- [ ] Mobile app (React Native with same API)

**Week 12+: Scaling**

- [ ] CDN caching strategies
- [ ] Database indexing optimization
- [ ] API response compression
- [ ] Image optimization (Cloudflare Images)

**Week 13+: Team Features**

- [ ] Multi-tenancy
- [ ] Role-based access control
- [ ] Workspace invitations
- [ ] Audit logs

---

## Summary

**What you built:**

```
✓ Hono REST API (Cloudflare Workers)
✓ TanStack Start frontend (Cloudflare Pages)
✓ Cloudflare D1 database (SQLite)
✓ Drizzle ORM (type-safe queries)
✓ Clerk authentication
✓ shadcn/ui components
✓ Shared TypeScript types
✓ Full CRUD operations
✓ Analytics dashboard
✓ Production deployment
```

**Tech mastered:**

- Monorepo with Turborepo
- Cloudflare Workers + Pages
- Hono web framework
- TanStack Router + Start
- Drizzle ORM
- Clerk auth
- React Query
- shadcn/ui

**Cost:** $0/month (free tier limits: 100k req/day, 5GB DB, 10k users)

**Time:** 10-14 weeks @ 2 hours/day = 140-200 hours total

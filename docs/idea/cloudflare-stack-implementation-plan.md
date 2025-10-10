# Cloudflare Stack Implementation Plan

**Last Updated:** October 5, 2025  
**Time Commitment:** 2 hours/day  
**Total Duration:** 8-12 weeks  
**Skill Level:** Intermediate (3 years experience)

---

## Stack Overview

```
PLATFORM:    Cloudflare Workers + Pages
FRONTEND:    React Router v7 (Remix successor) on Cloudflare Pages
BACKEND:     Hono on Cloudflare Workers
DATABASE:    Cloudflare D1 (SQLite) + Drizzle ORM
STYLING:     Tailwind CSS + shadcn/ui
AUTH:        Clerk
DEPLOY:      Wrangler CLI
COST:        $0-5/month
```

---

## Prerequisites

### Required Tools

```bash
# Install Node.js 20+ (or use Bun)
node --version  # Should be v20+

# Install Bun (faster runtime)
curl -fsSL https://bun.sh/install | bash

# Install Wrangler (Cloudflare CLI)
npm install -g wrangler

# Verify installations
bun --version
wrangler --version
```

### Required Accounts

1. **Cloudflare Account** - https://dash.cloudflare.com/sign-up
2. **GitHub Account** - For Git hosting
3. **Clerk Account** - https://clerk.com (auth)

### Required Knowledge

- TypeScript basics
- React fundamentals
- Basic SQL understanding
- Git commands
- Command line comfort

---

## Phase 1: Foundation (Weeks 1-2)

### Week 1: Environment Setup + React Router Basics

**Day 1-2: Setup & First Deployment (4 hours)**

```bash
# Login to Cloudflare
wrangler login

# Create React Router project for Cloudflare
npx create-cloudflare@latest my-dashboard --framework=react-router

# Navigate to project
cd my-dashboard

# Install dependencies
npm install

# Run development server
npm run dev
# Open http://localhost:5173
```

**Expected Output:**

- Default React Router app running locally
- Understanding of project structure

**Checkpoint:**

```
✓ Project created
✓ Dev server runs
✓ Can see default page at localhost:5173
```

---

**Day 3-4: React Router Routing Basics (4 hours)**

**File Structure:**

```
app/
  routes/
    _index.tsx          # Home page (/)
    about.tsx           # About page (/about)
    dashboard.tsx       # Dashboard (/dashboard)
```

**Create routes:**

```typescript
// app/routes/about.tsx
export default function About() {
  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold">About Page</h1>
      <p className="mt-4">Learning React Router v7 on Cloudflare!</p>
    </div>
  );
}
```

```typescript
// app/routes/dashboard.tsx
export default function Dashboard() {
  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold">Dashboard</h1>
      <p className="mt-4">Your personal dashboard</p>
    </div>
  );
}
```

**Update navigation in root.tsx:**

```typescript
// app/root.tsx
import { Links, Meta, Outlet, Scripts, Link } from "react-router";

export default function App() {
  return (
    <html lang="en">
      <head>
        <meta charSet="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <Meta />
        <Links />
      </head>
      <body>
        <nav className="bg-gray-800 text-white p-4">
          <div className="container mx-auto flex gap-4">
            <Link to="/" className="hover:underline">Home</Link>
            <Link to="/about" className="hover:underline">About</Link>
            <Link to="/dashboard" className="hover:underline">Dashboard</Link>
          </div>
        </nav>
        <Outlet />
        <Scripts />
      </body>
    </html>
  );
}
```

**Checkpoint:**

```
✓ Created 3 routes
✓ Navigation works
✓ Understand file-based routing
```

---

**Day 5-6: Loaders (Data Fetching) (4 hours)**

**Learn server-side data loading:**

```typescript
// app/routes/users.tsx
import { json } from "react-router";
import { useLoaderData } from "react-router";
import type { Route } from "./+types/users";

// Server-side data fetching
export async function loader({ context }: Route.LoaderArgs) {
  // Simulate API call
  const users = [
    { id: 1, name: 'John Doe', email: 'john@example.com' },
    { id: 2, name: 'Jane Smith', email: 'jane@example.com' },
  ];

  return json({ users });
}

// Client-side component
export default function Users({ loaderData }: Route.ComponentProps) {
  const { users } = loaderData;

  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold mb-4">Users</h1>
      <div className="space-y-2">
        {users.map(user => (
          <div key={user.id} className="p-4 border rounded">
            <h2 className="font-bold">{user.name}</h2>
            <p className="text-gray-600">{user.email}</p>
          </div>
        ))}
      </div>
    </div>
  );
}
```

**Checkpoint:**

```
✓ Understand loaders
✓ Fetch data server-side
✓ Display data in component
```

---

**Day 7: First Deployment to Cloudflare Pages (2 hours)**

```bash
# Build the project
npm run build

# Deploy to Cloudflare Pages
npm run deploy

# Follow prompts:
# - Create new project? Yes
# - Project name: my-dashboard
# - Production branch: main
```

**Expected Output:**

- Live URL: `https://my-dashboard.pages.dev`
- Working app on the internet

**Checkpoint:**

```
✓ App deployed to Cloudflare
✓ Live URL accessible
✓ Understand deployment process
```

---

### Week 2: Tailwind + shadcn/ui

**Day 8-9: Tailwind CSS Setup (4 hours)**

```bash
# Install Tailwind
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
```

**Configure Tailwind:**

```typescript
// tailwind.config.ts
import type { Config } from "tailwindcss";

export default {
  content: ["./app/**/{**,.client,.server}/**/*.{js,jsx,ts,tsx}"],
  theme: {
    extend: {},
  },
  plugins: [],
} satisfies Config;
```

**Create CSS file:**

```css
/* app/tailwind.css */
@tailwind base;
@tailwind components;
@tailwind utilities;
```

**Import in root:**

```typescript
// app/root.tsx
import "./tailwind.css"; // Add this line
```

**Test Tailwind:**

```typescript
// app/routes/_index.tsx
export default function Index() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-500 to-purple-600">
      <div className="container mx-auto px-4 py-16">
        <h1 className="text-5xl font-bold text-white mb-4">
          Welcome to My Dashboard
        </h1>
        <p className="text-xl text-white/80">
          Built with React Router v7 + Cloudflare + Tailwind CSS
        </p>
        <button className="mt-8 px-6 py-3 bg-white text-blue-600 font-semibold rounded-lg hover:bg-blue-50 transition">
          Get Started
        </button>
      </div>
    </div>
  );
}
```

**Checkpoint:**

```
✓ Tailwind working
✓ Styles apply correctly
✓ Understand utility classes
```

---

**Day 10-11: shadcn/ui Setup (4 hours)**

```bash
# Install shadcn/ui
npx shadcn@latest init

# Select options:
# - Style: Default
# - Base color: Slate
# - CSS variables: Yes
# - Where is your global CSS: app/tailwind.css
# - Path alias: ~/*

# Add components
npx shadcn@latest add button
npx shadcn@latest add card
npx shadcn@latest add input
npx shadcn@latest add form
npx shadcn@latest add label
```

**Test components:**

```typescript
// app/routes/components-demo.tsx
import { Button } from "~/components/ui/button";
import { Card, CardHeader, CardTitle, CardContent } from "~/components/ui/card";
import { Input } from "~/components/ui/input";
import { Label } from "~/components/ui/label";

export default function ComponentsDemo() {
  return (
    <div className="container mx-auto p-8">
      <h1 className="text-3xl font-bold mb-8">shadcn/ui Components</h1>

      <div className="grid gap-8">
        <Card>
          <CardHeader>
            <CardTitle>Button Examples</CardTitle>
          </CardHeader>
          <CardContent className="flex gap-2">
            <Button>Default</Button>
            <Button variant="secondary">Secondary</Button>
            <Button variant="outline">Outline</Button>
            <Button variant="destructive">Destructive</Button>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Form Elements</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <Label htmlFor="email">Email</Label>
              <Input id="email" type="email" placeholder="you@example.com" />
            </div>
            <div>
              <Label htmlFor="password">Password</Label>
              <Input id="password" type="password" />
            </div>
            <Button>Submit</Button>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
```

**Checkpoint:**

```
✓ shadcn/ui installed
✓ Components working
✓ Understand component usage
```

---

**Day 12-14: Build Landing Page (6 hours)**

**Create a polished landing page using what you learned:**

```typescript
// app/routes/_index.tsx
import { Button } from "~/components/ui/button";
import { Card, CardHeader, CardTitle, CardContent } from "~/components/ui/card";
import { Link } from "react-router";

export default function Index() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-indigo-500 via-purple-500 to-pink-500">
      {/* Hero Section */}
      <div className="container mx-auto px-4 py-20">
        <div className="text-center text-white">
          <h1 className="text-6xl font-bold mb-6">
            Your Personal Dashboard
          </h1>
          <p className="text-xl mb-8 text-white/90">
            Track tasks, manage expenses, and boost productivity
          </p>
          <div className="flex gap-4 justify-center">
            <Button size="lg" asChild>
              <Link to="/dashboard">Get Started</Link>
            </Button>
            <Button size="lg" variant="outline" asChild>
              <Link to="/about">Learn More</Link>
            </Button>
          </div>
        </div>

        {/* Features */}
        <div className="grid md:grid-cols-3 gap-6 mt-20">
          <Card>
            <CardHeader>
              <CardTitle>📝 Task Management</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-gray-600">
                Organize your tasks and stay on top of your goals
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>💰 Expense Tracking</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-gray-600">
                Monitor your spending and save money
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>📊 Analytics</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-gray-600">
                Visualize your progress with beautiful charts
              </p>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
```

**Checkpoint:**

```
✓ Beautiful landing page
✓ Using Tailwind + shadcn/ui together
✓ Responsive design
✓ Deploy to Cloudflare
```

**End of Week 2 Milestone:**

- Working React Router v7 app
- Tailwind CSS + shadcn/ui integrated
- Deployed to Cloudflare Pages
- Beautiful UI

---

## Phase 2: Backend + Database (Weeks 3-5)

### Week 3: Cloudflare D1 Database

**Day 15-16: D1 Setup (4 hours)**

```bash
# Create D1 database
wrangler d1 create my-dashboard-db

# Output will show:
# database_id = "xxxx-xxxx-xxxx-xxxx"
# Copy this ID!
```

**Add to wrangler.toml:**

```toml
# wrangler.toml
name = "my-dashboard"
compatibility_date = "2025-10-05"

[[d1_databases]]
binding = "DB"
database_name = "my-dashboard-db"
database_id = "YOUR_DATABASE_ID_HERE"  # Paste the ID from above
```

**Create schema:**

```sql
-- schema.sql
CREATE TABLE tasks (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  completed INTEGER DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_id ON tasks(user_id);

CREATE TABLE expenses (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  amount REAL NOT NULL,
  category TEXT NOT NULL,
  description TEXT,
  date DATE NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_expenses ON expenses(user_id);
```

**Run migration:**

```bash
# Apply schema to local D1
wrangler d1 execute my-dashboard-db --local --file=./schema.sql

# Apply schema to production D1
wrangler d1 execute my-dashboard-db --remote --file=./schema.sql
```

**Checkpoint:**

```
✓ D1 database created
✓ Schema applied
✓ Can query database
```

---

**Day 17-18: Drizzle ORM Setup (4 hours)**

```bash
# Install Drizzle
npm install drizzle-orm
npm install -D drizzle-kit
```

**Create Drizzle schema:**

```typescript
// app/db/schema.ts
import { sqliteTable, text, integer, real } from "drizzle-orm/sqlite-core";

export const tasks = sqliteTable("tasks", {
  id: text("id").primaryKey(),
  userId: text("user_id").notNull(),
  title: text("title").notNull(),
  description: text("description"),
  completed: integer("completed").default(0),
  createdAt: integer("created_at", { mode: "timestamp" }),
});

export const expenses = sqliteTable("expenses", {
  id: text("id").primaryKey(),
  userId: text("user_id").notNull(),
  amount: real("amount").notNull(),
  category: text("category").notNull(),
  description: text("description"),
  date: text("date").notNull(),
  createdAt: integer("created_at", { mode: "timestamp" }),
});
```

**Create DB instance:**

```typescript
// app/db/index.ts
import { drizzle } from "drizzle-orm/d1";
import * as schema from "./schema";

export function getDb(env: any) {
  return drizzle(env.DB, { schema });
}
```

**Checkpoint:**

```
✓ Drizzle ORM configured
✓ Schema defined in TypeScript
✓ Type-safe queries ready
```

---

**Day 19-21: First CRUD Operations (6 hours)**

**Create tasks route with database:**

```typescript
// app/routes/tasks.tsx
import { json } from "react-router";
import { useLoaderData, Form, useNavigation } from "react-router";
import type { Route } from "./+types/tasks";
import { getDb } from "~/db";
import { tasks } from "~/db/schema";
import { eq } from "drizzle-orm";
import { Button } from "~/components/ui/button";
import { Card, CardHeader, CardTitle, CardContent } from "~/components/ui/card";
import { Input } from "~/components/ui/input";
import { Checkbox } from "~/components/ui/checkbox";

// Load all tasks
export async function loader({ context }: Route.LoaderArgs) {
  const db = getDb(context.cloudflare.env);

  const allTasks = await db
    .select()
    .from(tasks)
    .where(eq(tasks.userId, 'demo-user'))  // Hardcoded for now
    .all();

  return json({ tasks: allTasks });
}

// Handle form submissions
export async function action({ request, context }: Route.ActionArgs) {
  const db = getDb(context.cloudflare.env);
  const formData = await request.formData();
  const intent = formData.get('intent');

  if (intent === 'create') {
    const title = formData.get('title') as string;

    await db.insert(tasks).values({
      id: crypto.randomUUID(),
      userId: 'demo-user',
      title,
      completed: 0,
      createdAt: new Date(),
    });
  }

  if (intent === 'toggle') {
    const taskId = formData.get('taskId') as string;
    const currentState = formData.get('completed') === '1';

    await db
      .update(tasks)
      .set({ completed: currentState ? 0 : 1 })
      .where(eq(tasks.id, taskId));
  }

  if (intent === 'delete') {
    const taskId = formData.get('taskId') as string;

    await db
      .delete(tasks)
      .where(eq(tasks.id, taskId));
  }

  return json({ success: true });
}

export default function Tasks({ loaderData }: Route.ComponentProps) {
  const { tasks: taskList } = loaderData;
  const navigation = useNavigation();
  const isSubmitting = navigation.state === 'submitting';

  return (
    <div className="container mx-auto p-8">
      <Card>
        <CardHeader>
          <CardTitle>Tasks</CardTitle>
        </CardHeader>
        <CardContent>
          {/* Add Task Form */}
          <Form method="post" className="mb-6">
            <input type="hidden" name="intent" value="create" />
            <div className="flex gap-2">
              <Input
                name="title"
                placeholder="Add a new task..."
                required
                disabled={isSubmitting}
              />
              <Button type="submit" disabled={isSubmitting}>
                {isSubmitting ? 'Adding...' : 'Add'}
              </Button>
            </div>
          </Form>

          {/* Task List */}
          <div className="space-y-2">
            {taskList.length === 0 ? (
              <p className="text-gray-500 text-center py-8">No tasks yet. Add one above!</p>
            ) : (
              taskList.map((task) => (
                <div key={task.id} className="flex items-center gap-2 p-3 border rounded">
                  <Form method="post" className="flex-1 flex items-center gap-2">
                    <input type="hidden" name="intent" value="toggle" />
                    <input type="hidden" name="taskId" value={task.id} />
                    <input type="hidden" name="completed" value={task.completed} />
                    <button type="submit" className="flex items-center gap-2">
                      <Checkbox checked={task.completed === 1} />
                      <span className={task.completed === 1 ? 'line-through text-gray-500' : ''}>
                        {task.title}
                      </span>
                    </button>
                  </Form>

                  <Form method="post">
                    <input type="hidden" name="intent" value="delete" />
                    <input type="hidden" name="taskId" value={task.id} />
                    <Button variant="destructive" size="sm" type="submit">
                      Delete
                    </Button>
                  </Form>
                </div>
              ))
            )}
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
```

**Test locally:**

```bash
# Run with local D1
npm run dev

# Open http://localhost:5173/tasks
# Add tasks, toggle, delete
```

**Checkpoint:**

```
✓ Create tasks
✓ Read tasks from DB
✓ Update task status
✓ Delete tasks
✓ Forms working
```

---

### Week 4: Authentication with Clerk

**Day 22-23: Clerk Setup (4 hours)**

```bash
# Install Clerk
npm install @clerk/react-router
```

**Create Clerk account:**

1. Go to https://clerk.com
2. Sign up
3. Create new application
4. Copy publishable key and secret key

**Add to wrangler.toml:**

```toml
# wrangler.toml
[vars]
CLERK_PUBLISHABLE_KEY = "pk_test_xxxxx"

[[d1_databases]]
binding = "DB"
database_name = "my-dashboard-db"
database_id = "your-db-id"
```

**Add secret key:**

```bash
# Add secret to Cloudflare (don't commit this!)
wrangler secret put CLERK_SECRET_KEY
# Paste your secret key when prompted
```

**Setup Clerk in root:**

```typescript
// app/root.tsx
import { ClerkApp } from "@clerk/react-router";
import { rootAuthLoader } from "@clerk/react-router/ssr.server";
import { Links, Meta, Outlet, Scripts, Link } from "react-router";
import "./tailwind.css";

export const loader = (args) => rootAuthLoader(args);

function App() {
  return (
    <html lang="en">
      <head>
        <meta charSet="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <Meta />
        <Links />
      </head>
      <body>
        <nav className="bg-gray-800 text-white p-4">
          <div className="container mx-auto flex gap-4 justify-between">
            <div className="flex gap-4">
              <Link to="/" className="hover:underline">Home</Link>
              <Link to="/dashboard" className="hover:underline">Dashboard</Link>
              <Link to="/tasks" className="hover:underline">Tasks</Link>
            </div>
          </div>
        </nav>
        <Outlet />
        <Scripts />
      </body>
    </html>
  );
}

export default ClerkApp(App);
```

**Create protected route:**

```typescript
// app/routes/dashboard.tsx
import { getAuth } from "@clerk/react-router/ssr.server";
import { redirect, json } from "react-router";
import type { Route } from "./+types/dashboard";
import { SignedIn, SignedOut, SignInButton, UserButton } from "@clerk/react-router";
import { Card, CardHeader, CardTitle, CardContent } from "~/components/ui/card";

export async function loader(args: Route.LoaderArgs) {
  const { userId } = await getAuth(args);

  // If not signed in, redirect to home
  if (!userId) {
    return redirect("/");
  }

  return json({ userId });
}

export default function Dashboard({ loaderData }: Route.ComponentProps) {
  return (
    <div className="container mx-auto p-8">
      <div className="flex justify-between items-center mb-8">
        <h1 className="text-3xl font-bold">Dashboard</h1>
        <UserButton />
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Welcome!</CardTitle>
        </CardHeader>
        <CardContent>
          <p>You are signed in. User ID: {loaderData.userId}</p>
        </CardContent>
      </Card>
    </div>
  );
}
```

**Update home page with sign in:**

```typescript
// app/routes/_index.tsx
import { SignedIn, SignedOut, SignInButton, UserButton } from "@clerk/react-router";
import { Button } from "~/components/ui/button";
import { Link } from "react-router";

export default function Index() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-indigo-500 via-purple-500 to-pink-500">
      <div className="container mx-auto px-4 py-20 text-center text-white">
        <h1 className="text-6xl font-bold mb-6">Your Personal Dashboard</h1>
        <p className="text-xl mb-8">Track tasks, manage expenses, boost productivity</p>

        <SignedOut>
          <SignInButton mode="modal">
            <Button size="lg">Sign In to Get Started</Button>
          </SignInButton>
        </SignedOut>

        <SignedIn>
          <div className="flex gap-4 justify-center items-center">
            <Button size="lg" asChild>
              <Link to="/dashboard">Go to Dashboard</Link>
            </Button>
            <UserButton />
          </div>
        </SignedIn>
      </div>
    </div>
  );
}
```

**Checkpoint:**

```
✓ Clerk authentication working
✓ Sign in/sign out functional
✓ Protected routes
✓ User info available
```

---

**Day 24-28: Connect Auth to Database (8 hours)**

**Update tasks to use real user ID:**

```typescript
// app/routes/tasks.tsx
import { getAuth } from "@clerk/react-router/ssr.server";
import { redirect } from "react-router";

export async function loader({ context, request }: Route.LoaderArgs) {
  const { userId } = await getAuth({ request, context });

  if (!userId) {
    return redirect("/");
  }

  const db = getDb(context.cloudflare.env);

  const userTasks = await db
    .select()
    .from(tasks)
    .where(eq(tasks.userId, userId)) // Use real user ID!
    .all();

  return json({ tasks: userTasks, userId });
}

export async function action({ request, context }: Route.ActionArgs) {
  const { userId } = await getAuth({ request, context });

  if (!userId) {
    return redirect("/");
  }

  const db = getDb(context.cloudflare.env);
  const formData = await request.formData();
  const intent = formData.get("intent");

  if (intent === "create") {
    const title = formData.get("title") as string;

    await db.insert(tasks).values({
      id: crypto.randomUUID(),
      userId, // Use real user ID!
      title,
      completed: 0,
      createdAt: new Date(),
    });
  }

  // ... rest of the code
}
```

**Checkpoint:**

```
✓ Tasks tied to logged-in user
✓ Each user sees only their tasks
✓ Auth + DB working together
```

**End of Week 4 Milestone:**

- Full authentication working
- Database with user-specific data
- CRUD operations complete

---

### Week 5: Hono Backend (Optional Separate API)

**Note:** You can skip this if you're happy with React Router loaders/actions. This is for learning Hono separately.

**Day 29-30: Hono Worker Setup (4 hours)**

```bash
# Create separate backend folder
mkdir backend
cd backend

# Initialize Hono project
npm init -y
npm install hono
npm install -D wrangler
```

**Create Hono API:**

```typescript
// backend/src/index.ts
import { Hono } from "hono";
import { cors } from "hono/cors";

type Bindings = {
  DB: D1Database;
};

const app = new Hono<{ Bindings: Bindings }>();

app.use(
  "/*",
  cors({
    origin: ["http://localhost:5173", "https://your-app.pages.dev"],
    credentials: true,
  }),
);

app.get("/health", (c) => {
  return c.json({ status: "ok", timestamp: Date.now() });
});

app.get("/api/tasks", async (c) => {
  const { results } = await c.env.DB.prepare(
    "SELECT * FROM tasks WHERE user_id = ?",
  )
    .bind("demo-user")
    .all();

  return c.json({ tasks: results });
});

app.post("/api/tasks", async (c) => {
  const { title } = await c.req.json();

  await c.env.DB.prepare(
    "INSERT INTO tasks (id, user_id, title, completed) VALUES (?, ?, ?, ?)",
  )
    .bind(crypto.randomUUID(), "demo-user", title, 0)
    .run();

  return c.json({ success: true });
});

export default app;
```

**Checkpoint:**

```
✓ Hono API created
✓ Can deploy as separate Worker
✓ Understand separation of concerns
```

**Decision Point:**

- Keep using React Router actions/loaders (simpler)
- OR use separate Hono API (more complex but clearer separation)

---

## Phase 3: Complete App (Weeks 6-8)

### Week 6: Expenses Feature

**Day 31-35: Build Expense Tracker (10 hours)**

```typescript
// app/routes/expenses.tsx
import { json, redirect } from "react-router";
import { useLoaderData, Form } from "react-router";
import type { Route } from "./+types/expenses";
import { getAuth } from "@clerk/react-router/ssr.server";
import { getDb } from "~/db";
import { expenses } from "~/db/schema";
import { eq, desc } from "drizzle-orm";
import { Card, CardHeader, CardTitle, CardContent } from "~/components/ui/card";
import { Button } from "~/components/ui/button";
import { Input } from "~/components/ui/input";
import { Label } from "~/components/ui/label";

const CATEGORIES = ['Food', 'Transport', 'Shopping', 'Entertainment', 'Bills', 'Other'];

export async function loader({ context, request }: Route.LoaderArgs) {
  const { userId } = await getAuth({ request, context });
  if (!userId) return redirect("/");

  const db = getDb(context.cloudflare.env);

  const userExpenses = await db
    .select()
    .from(expenses)
    .where(eq(expenses.userId, userId))
    .orderBy(desc(expenses.date))
    .all();

  const total = userExpenses.reduce((sum, exp) => sum + exp.amount, 0);

  return json({ expenses: userExpenses, total });
}

export async function action({ request, context }: Route.ActionArgs) {
  const { userId } = await getAuth({ request, context });
  if (!userId) return redirect("/");

  const db = getDb(context.cloudflare.env);
  const formData = await request.formData();
  const intent = formData.get('intent');

  if (intent === 'create') {
    await db.insert(expenses).values({
      id: crypto.randomUUID(),
      userId,
      amount: parseFloat(formData.get('amount') as string),
      category: formData.get('category') as string,
      description: formData.get('description') as string,
      date: formData.get('date') as string,
      createdAt: new Date(),
    });
  }

  if (intent === 'delete') {
    const expenseId = formData.get('expenseId') as string;
    await db.delete(expenses).where(eq(expenses.id, expenseId));
  }

  return json({ success: true });
}

export default function Expenses({ loaderData }: Route.ComponentProps) {
  const { expenses: expenseList, total } = loaderData;

  return (
    <div className="container mx-auto p-8">
      <div className="grid md:grid-cols-2 gap-8">
        {/* Add Expense Form */}
        <Card>
          <CardHeader>
            <CardTitle>Add Expense</CardTitle>
          </CardHeader>
          <CardContent>
            <Form method="post" className="space-y-4">
              <input type="hidden" name="intent" value="create" />

              <div>
                <Label htmlFor="amount">Amount</Label>
                <Input id="amount" name="amount" type="number" step="0.01" required />
              </div>

              <div>
                <Label htmlFor="category">Category</Label>
                <select
                  id="category"
                  name="category"
                  className="w-full border rounded p-2"
                  required
                >
                  {CATEGORIES.map(cat => (
                    <option key={cat} value={cat}>{cat}</option>
                  ))}
                </select>
              </div>

              <div>
                <Label htmlFor="description">Description</Label>
                <Input id="description" name="description" />
              </div>

              <div>
                <Label htmlFor="date">Date</Label>
                <Input id="date" name="date" type="date" required />
              </div>

              <Button type="submit" className="w-full">Add Expense</Button>
            </Form>
          </CardContent>
        </Card>

        {/* Expenses List */}
        <div className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Total: ${total.toFixed(2)}</CardTitle>
            </CardHeader>
          </Card>

          {expenseList.map((expense) => (
            <Card key={expense.id}>
              <CardContent className="p-4">
                <div className="flex justify-between items-start">
                  <div>
                    <p className="font-bold">${expense.amount.toFixed(2)}</p>
                    <p className="text-sm text-gray-600">{expense.category}</p>
                    <p className="text-sm">{expense.description}</p>
                    <p className="text-xs text-gray-400">{expense.date}</p>
                  </div>
                  <Form method="post">
                    <input type="hidden" name="intent" value="delete" />
                    <input type="hidden" name="expenseId" value={expense.id} />
                    <Button variant="destructive" size="sm">Delete</Button>
                  </Form>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    </div>
  );
}
```

**Checkpoint:**

```
✓ Expense tracking works
✓ Categories organized
✓ Total calculation
✓ CRUD operations
```

---

### Week 7-8: Polish & Deploy

**Day 36-42: Final Polish (14 hours)**

**Tasks:**

1. Improve UI/UX
2. Add loading states
3. Error handling
4. Responsive design
5. Deploy to production
6. Test everything

**Loading states example:**

```typescript
// app/routes/tasks.tsx
import { useNavigation } from "react-router";

export default function Tasks({ loaderData }: Route.ComponentProps) {
  const navigation = useNavigation();
  const isLoading = navigation.state === 'loading';
  const isSubmitting = navigation.state === 'submitting';

  if (isLoading) {
    return (
      <div className="container mx-auto p-8">
        <Card>
          <CardContent className="p-8 text-center">
            <p>Loading tasks...</p>
          </CardContent>
        </Card>
      </div>
    );
  }

  // ... rest of component
}
```

**Error boundary:**

```typescript
// app/routes/tasks.tsx
import { isRouteErrorResponse, useRouteError } from "react-router";

export function ErrorBoundary() {
  const error = useRouteError();

  if (isRouteErrorResponse(error)) {
    return (
      <div className="container mx-auto p-8">
        <Card>
          <CardHeader>
            <CardTitle>Oops! {error.status}</CardTitle>
          </CardHeader>
          <CardContent>
            <p>{error.statusText}</p>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="container mx-auto p-8">
      <Card>
        <CardHeader>
          <CardTitle>Error</CardTitle>
        </CardHeader>
        <CardContent>
          <p>Something went wrong!</p>
        </CardContent>
      </Card>
    </div>
  );
}
```

**Final deployment:**

```bash
# Build and deploy
npm run build
npm run deploy

# Check live site
# Visit https://your-app.pages.dev
```

**Checkpoint:**

```
✓ All features working
✓ Error handling implemented
✓ Loading states added
✓ Responsive design
✓ Deployed to production
```

---

## Milestones & Checkpoints

### Week 2 Milestone

- [ ] React Router v7 app running
- [ ] Tailwind + shadcn/ui working
- [ ] Beautiful landing page
- [ ] Deployed to Cloudflare Pages

### Week 4 Milestone

- [ ] D1 database configured
- [ ] Drizzle ORM working
- [ ] Clerk authentication
- [ ] User-specific data

### Week 6 Milestone

- [ ] Tasks feature complete
- [ ] Expenses feature complete
- [ ] All CRUD operations working

### Week 8 Milestone (FINAL)

- [ ] Polished UI
- [ ] Error handling
- [ ] Loading states
- [ ] Production deployment
- [ ] All features working

---

## Common Pitfalls

### 1. Database ID Confusion

**Problem:** Using wrong database ID in wrangler.toml

**Solution:**

```bash
# Always copy the EXACT ID from wrangler output
wrangler d1 create my-db
# Copy: database_id = "xxxx-xxxx-xxxx"
```

### 2. CORS Issues

**Problem:** Frontend can't talk to backend

**Solution:**

```typescript
// In Hono worker
app.use(
  "/*",
  cors({
    origin: ["http://localhost:5173", "https://your-app.pages.dev"],
    credentials: true,
  }),
);
```

### 3. Environment Variables

**Problem:** Clerk keys not working

**Solution:**

```bash
# Secrets use wrangler secret
wrangler secret put CLERK_SECRET_KEY

# Regular vars in wrangler.toml
[vars]
CLERK_PUBLISHABLE_KEY = "pk_test_xxx"
```

### 4. D1 Local vs Remote

**Problem:** Data exists locally but not in production

**Solution:**

```bash
# Always run migrations on BOTH
wrangler d1 execute my-db --local --file=schema.sql
wrangler d1 execute my-db --remote --file=schema.sql
```

### 5. Type Errors with Context

**Problem:** `context.cloudflare.env` type errors

**Solution:**

```typescript
// Add type definition
type Env = {
  DB: D1Database;
  CLERK_SECRET_KEY: string;
};

// Use in loader/action
export async function loader({ context }: Route.LoaderArgs) {
  const env = context.cloudflare.env as Env;
  const db = getDb(env);
}
```

---

## Resources

### Official Docs

- React Router v7: https://reactrouter.com/dev
- Cloudflare Pages: https://developers.cloudflare.com/pages
- Cloudflare Workers: https://developers.cloudflare.com/workers
- Cloudflare D1: https://developers.cloudflare.com/d1
- Drizzle ORM: https://orm.drizzle.team
- Hono: https://hono.dev
- Clerk: https://clerk.com/docs
- Tailwind CSS: https://tailwindcss.com/docs
- shadcn/ui: https://ui.shadcn.com

### Learning Resources

- React Router Tutorial: https://reactrouter.com/dev/start/tutorial
- Cloudflare Workers Tutorials: https://developers.cloudflare.com/workers/tutorials
- Drizzle Quick Start: https://orm.drizzle.team/docs/quick-start

### Community

- React Router Discord: https://rmx.as/discord
- Cloudflare Discord: https://discord.gg/cloudflaredev
- Hono Discord: https://discord.gg/hono

---

## Daily Progress Tracker

Create a file: `progress.md`

```markdown
# My Progress Log

## Week 1

- [ ] Day 1: Setup environment
- [ ] Day 2: First deployment
- [ ] Day 3: Routing basics
- [ ] Day 4: More routes
- [ ] Day 5: Loaders
- [ ] Day 6: Actions
- [ ] Day 7: Deploy

## Week 2

- [ ] Day 8: Tailwind setup
- [ ] Day 9: Tailwind practice
- [ ] Day 10: shadcn/ui install
- [ ] Day 11: shadcn components
- [ ] Day 12: Landing page start
- [ ] Day 13: Landing page polish
- [ ] Day 14: Deploy & review

... continue for all weeks
```

---

## Success Criteria

### You've succeeded when you can:

1. **Explain** how React Router file-based routing works
2. **Create** new routes without looking at docs
3. **Fetch** data using loaders
4. **Submit** forms using actions
5. **Query** D1 database with Drizzle
6. **Style** components with Tailwind + shadcn/ui
7. **Protect** routes with Clerk auth
8. **Deploy** to Cloudflare Pages
9. **Debug** errors independently
10. **Build** new features without tutorials

---

## After Completion

### Next Steps:

1. **Add more features:**
   - Notes/journal
   - Habit tracker
   - Charts/analytics
   - Export data

2. **Learn advanced topics:**
   - Cloudflare Workers AI
   - R2 storage (images)
   - KV store (caching)
   - Queues (background jobs)

3. **Build second project:**
   - Apply what you learned
   - Different domain
   - More complexity

4. **Share your work:**
   - Deploy publicly
   - Write blog post
   - Show to friends
   - Get feedback

---

## Emergency Help

### If You Get Stuck:

1. **Read the error message** (actually read it, don't skip)
2. **Check this guide** for the specific issue
3. **Search official docs** (not random blogs)
4. **Ask specific questions** (not "it doesn't work")
5. **Share error messages** and relevant code

### Questions Format:

**Bad:** "My app doesn't work, help!"

**Good:**

```
I'm on Day 15, setting up D1 database.
When I run: wrangler d1 execute my-db --local --file=schema.sql
I get error: [paste exact error]
I've tried: [what you tried]
```

---

## Final Notes

- **Don't skip steps** - each builds on previous
- **Actually type the code** - don't copy/paste blindly
- **Commit often** - git commit after each checkpoint
- **Deploy early** - deploy at end of each week
- **Take breaks** - 2 hours then stop
- **Track progress** - update progress.md daily
- **Ask questions** - don't stay stuck > 30 minutes

**Remember:** This is a marathon, not a sprint. 2 hours/day for 8 weeks = 112 hours of focused learning. That's MORE than most bootcamps.

**You got this. Start Monday. Build something real.**

---

**Last Updated:** October 5, 2025  
**Next Review:** After Week 2 (adjust timeline if needed)

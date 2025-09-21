# ocusage MVP - KISS Approach

## Reality Check

The comprehensive plan was overengineered garbage. This is the KISS MVP.

## What ocusage Actually Does

Track OpenCode usage. Show charts. That's it.

## Tech Stack (KISS)

```
- Runtime: Bun + TypeScript (same as OpenCode)
- API: Hono (same as OpenCode)
- Frontend: Plain HTML/CSS/TS (no framework)
- Database: SQLite (Bun.file())
- Deployment: Single binary
```

## MVP Features (Week 1-2)

1. **Data Collection**: OpenCode plugin streams basic events
2. **Storage**: SQLite database with 3 tables
3. **API**: 5 endpoints max
4. **Frontend**: One HTML page with charts
5. **Charts**: Basic usage graphs

## Database Schema

```sql
-- Keep it simple
CREATE TABLE sessions (
    id TEXT PRIMARY KEY,
    user_id TEXT,
    started_at INTEGER,
    ended_at INTEGER,
    tool_count INTEGER,
    success BOOLEAN
);

CREATE TABLE tools (
    id INTEGER PRIMARY KEY,
    session_id TEXT,
    tool_name TEXT,
    duration_ms INTEGER,
    timestamp INTEGER
);

CREATE TABLE costs (
    id INTEGER PRIMARY KEY,
    session_id TEXT,
    provider TEXT,
    tokens_used INTEGER,
    cost_cents INTEGER,
    timestamp INTEGER
);
```

## API Endpoints

```typescript
// Only 5 endpoints needed
POST /api/events       // Receive usage data
GET /api/stats         // Basic stats
GET /api/sessions      // Session list
GET /api/charts        // Chart data
GET /                  // Serve dashboard HTML
```

## Project Structure

```
ocusage/
├── src/
│   ├── index.ts       # Bun server + Hono routes
│   ├── db.ts          # SQLite operations
│   └── plugin.ts      # OpenCode plugin
├── static/
│   ├── index.html     # Dashboard
│   └── charts.ts      # Chart rendering (TypeScript)
├── package.json
└── README.md
```

## OpenCode Plugin (30 lines max)

```typescript
export async function ocusagePlugin({ project, client }) {
  const OCUSAGE_URL = process.env.OCUSAGE_URL || "http://localhost:3001";

  return {
    "session.created": async (session) => {
      await fetch(`${OCUSAGE_URL}/api/events`, {
        method: "POST",
        body: JSON.stringify({ type: "session_start", session }),
      });
    },
    "tool.execute.after": async (tool, result) => {
      await fetch(`${OCUSAGE_URL}/api/events`, {
        method: "POST",
        body: JSON.stringify({ type: "tool_used", tool, result }),
      });
    },
  };
}
```

## Dashboard (Basic HTML)

```html
<!DOCTYPE html>
<html>
  <head>
    <title>ocusage</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  </head>
  <body>
    <h1>OpenCode Usage</h1>
    <div>
      <canvas id="sessionsChart"></canvas>
      <canvas id="toolsChart"></canvas>
    </div>
    <script src="/charts.js"></script>
  </body>
</html>
```

**Note:** Frontend will be compiled TypeScript served as JS

## Implementation Plan

**Week 1:**

- Day 1-2: Setup Bun project, basic HTTP server
- Day 3-4: SQLite database, basic API endpoints
- Day 5-7: OpenCode plugin, data collection

**Week 2:**

- Day 1-3: HTML dashboard with charts
- Day 4-5: Polish and bug fixes
- Day 6-7: Documentation and deployment

## Success Metrics

- Plugin collects data from OpenCode
- Dashboard shows usage charts
- Runs as single binary
- < 1000 lines of code total

## What We DON'T Build

- User authentication (later)
- Teams/organizations (later)
- Real-time updates (later)
- Cost optimization (later)
- ML insights (later)
- Multiple databases (never)
- Microservices (never)

## Files to Create

1. `src/index.ts` - Main server
2. `src/db.ts` - Database operations
3. `src/plugin.ts` - OpenCode plugin
4. `static/index.html` - Dashboard
5. `static/charts.ts` - Chart logic (TypeScript)
6. `package.json` - Dependencies
7. `bun.lockb` - Lock file

## Next Steps After MVP

Only after MVP is working and people use it:

1. Add user accounts (SQLite table)
2. Add cost tracking improvements
3. Add more chart types
4. Add basic filters

## The Rule

If it takes more than 2 weeks or 1000 lines of code, it's not MVP.

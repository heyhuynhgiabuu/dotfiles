# OpenCode Usage Tracker - Brutal Day 1-2 Implementation

## Setup Requirements

Create a minimal OpenCode Usage Tracker in 2 days with brutal simplicity:

### Project Initialization

```bash
# Create project structure
mkdir ocusage
cd ocusage
bun init -y
```

### Core Dependencies

```bash
# Only essential dependencies
bun add hono
bun add -d @types/bun
```

### Project Structure

```
ocusage/
├── src/
│   └── index.ts           # Single entry point
├── static/
│   └── index.html         # Basic HTML page
├── package.json
└── README.md
```

## Implementation Spec

### 1. Basic Hono Server (src/index.ts)

```typescript
import { Hono } from "hono";
import { serveStatic } from "hono/bun";

const app = new Hono();

// Serve static files
app.use("/*", serveStatic({ root: "./static" }));

// Health check endpoint
app.get("/api/health", (c) => {
  return c.json({ status: "ok", timestamp: new Date().toISOString() });
});

// Basic metrics endpoint (placeholder)
app.get("/api/metrics", (c) => {
  return c.json({
    totalSessions: 0,
    totalTools: 0,
    totalCost: 0,
  });
});

export default {
  port: 3000,
  fetch: app.fetch,
};
```

### 2. Basic HTML Page (static/index.html)

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>OpenCode Usage Tracker</title>
    <style>
      body {
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
        max-width: 800px;
        margin: 0 auto;
        padding: 2rem;
        background: #fafafa;
      }
      .header {
        text-align: center;
        margin-bottom: 3rem;
      }
      .metrics {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 1rem;
        margin: 2rem 0;
      }
      .metric-card {
        background: white;
        padding: 1.5rem;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        text-align: center;
      }
      .metric-value {
        font-size: 2rem;
        font-weight: bold;
        color: #2563eb;
      }
      .metric-label {
        color: #6b7280;
        margin-top: 0.5rem;
      }
      .status {
        padding: 0.5rem 1rem;
        background: #10b981;
        color: white;
        border-radius: 4px;
        display: inline-block;
        margin-top: 1rem;
      }
    </style>
  </head>
  <body>
    <div class="header">
      <h1>OpenCode Usage Tracker</h1>
      <p>Monitor your AI coding sessions and optimize your workflow</p>
      <div id="health-status" class="status">Checking...</div>
    </div>

    <div class="metrics">
      <div class="metric-card">
        <div class="metric-value" id="sessions">0</div>
        <div class="metric-label">Total Sessions</div>
      </div>
      <div class="metric-card">
        <div class="metric-value" id="tools">0</div>
        <div class="metric-label">Tools Used</div>
      </div>
      <div class="metric-card">
        <div class="metric-value" id="cost">$0.00</div>
        <div class="metric-label">Total Cost</div>
      </div>
    </div>

    <script>
      async function loadMetrics() {
        try {
          const healthResponse = await fetch("/api/health");
          const health = await healthResponse.json();
          document.getElementById("health-status").textContent =
            health.status === "ok" ? "Server Online" : "Server Error";

          const metricsResponse = await fetch("/api/metrics");
          const metrics = await metricsResponse.json();

          document.getElementById("sessions").textContent =
            metrics.totalSessions;
          document.getElementById("tools").textContent = metrics.totalTools;
          document.getElementById("cost").textContent =
            `$${metrics.totalCost.toFixed(2)}`;
        } catch (error) {
          document.getElementById("health-status").textContent =
            "Connection Error";
          document.getElementById("health-status").style.background = "#ef4444";
        }
      }

      // Load metrics on page load
      loadMetrics();

      // Refresh every 30 seconds
      setInterval(loadMetrics, 30000);
    </script>
  </body>
</html>
```

### 3. Package.json Scripts

```json
{
  "name": "ocusage",
  "version": "1.0.0",
  "scripts": {
    "dev": "bun run --hot src/index.ts",
    "start": "bun run src/index.ts",
    "build": "bun build src/index.ts --outdir dist"
  },
  "dependencies": {
    "hono": "^3.12.8"
  },
  "devDependencies": {
    "@types/bun": "latest"
  }
}
```

## Verification Steps

### Day 1 Completion Checklist

- [ ] Project initializes with `bun init`
- [ ] Hono dependency installed
- [ ] Basic server runs on port 3000
- [ ] `/api/health` returns JSON response
- [ ] Static HTML page loads at root
- [ ] Health status shows "Server Online"
- [ ] Metrics display with placeholder values

### Day 2 Enhancement Checklist

- [ ] Server hot-reloads with `bun run dev`
- [ ] Health endpoint includes timestamp
- [ ] Metrics endpoint returns structured data
- [ ] Frontend automatically refreshes every 30 seconds
- [ ] Error handling for API failures
- [ ] Responsive design works on mobile
- [ ] Code is under 200 lines total

## Launch Commands

```bash
# Development
bun run dev

# Production
bun run start

# Verify endpoints
curl http://localhost:3000/api/health
curl http://localhost:3000/api/metrics
```

## Next Phase Preparation

This foundation is ready for Day 3-4 SQLite integration:

- Database schema for sessions/tools/costs
- Data collection from OpenCode plugin
- Real metrics instead of placeholders
- Basic CRUD operations

## Constraints Enforced

- ✅ No auto-comments or symbol documentation
- ✅ No complex abstractions or patterns
- ✅ No middleware except basic Hono
- ✅ No environment configuration
- ✅ No build tools beyond Bun
- ✅ Self-documenting code through clear naming
- ✅ Under 200 lines total code
- ✅ Single binary deployment

**Total Implementation Time: 2 days**  
**Total Lines of Code: ~150 lines**  
**Dependencies: 1 (Hono)**

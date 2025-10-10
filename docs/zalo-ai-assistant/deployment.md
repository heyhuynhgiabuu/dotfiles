# Zalo AI Assistant - Deployment Guide

## Overview

This guide covers deploying the Zalo AI Assistant to production using Cloudflare Pages with KISS principles. The deployment strategy focuses on simplicity, reliability, and cost-effectiveness for solo developers.

## Deployment Architecture

### Production Stack

- **Hosting**: Cloudflare Pages (serverless)
- **Database**: Cloudflare D1 (SQLite)
- **Storage**: Cloudflare R2 (S3-compatible)
- **CDN**: Cloudflare (integrated)
- **DNS**: Cloudflare (optional)
- **Monitoring**: Cloudflare Analytics + custom logging

### Cost Overview

```
Cloudflare Pages: Free (100 builds/day, 500 builds/month)
Cloudflare D1: Free (5GB storage, 25M queries/month)
Cloudflare R2: $0.015/GB storage + $0.36/million requests
Domain: ~$10/year (optional, can use pages.dev subdomain)
Total estimated cost: $5-15/month for small business usage
```

## Production Setup

### 1. Cloudflare Account Setup

```bash
# Install Wrangler CLI
npm install -g wrangler

# Login to Cloudflare
wrangler login

# Verify account
wrangler whoami
```

### 2. Project Configuration

Create `wrangler.toml`:

```toml
name = "zalo-ai-assistant"
compatibility_date = "2024-01-01"
main = "src/index.ts"

[build]
command = "bun run build"

[[d1_databases]]
binding = "DB"
database_name = "zalo-ai-assistant-db"
database_id = "your-database-id"

[[r2_buckets]]
binding = "STORAGE"
bucket_name = "zalo-ai-assistant-files"

[vars]
NODE_ENV = "production"

[env.production]
name = "zalo-ai-assistant"

[env.staging]
name = "zalo-ai-assistant-staging"
```

### 3. Environment Variables Setup

```bash
# Set production secrets
wrangler secret put JWT_SECRET
wrangler secret put ZALO_APP_SECRET
wrangler secret put ZALO_OA_ACCESS_TOKEN
wrangler secret put OPENAI_API_KEY

# Set public variables
wrangler pages var set ZALO_APP_ID your_app_id
wrangler pages var set ZALO_OA_ID your_oa_id
wrangler pages var set ZALO_WEBHOOK_URL https://your-domain.pages.dev/api/zalo/webhook
```

### 4. Database Migration

```bash
# Create D1 database
wrangler d1 create zalo-ai-assistant-db

# Run migrations
wrangler d1 migrations apply zalo-ai-assistant-db --local
wrangler d1 migrations apply zalo-ai-assistant-db --remote
```

### 5. Storage Setup

```bash
# Create R2 bucket
wrangler r2 bucket create zalo-ai-assistant-files

# Configure CORS for R2
wrangler r2 bucket cors put zalo-ai-assistant-files --file cors.json
```

CORS configuration (`cors.json`):

```json
[
  {
    "AllowedOrigins": ["https://your-domain.pages.dev"],
    "AllowedMethods": ["GET", "PUT", "POST", "DELETE"],
    "AllowedHeaders": ["*"],
    "ExposeHeaders": ["ETag"],
    "MaxAgeSeconds": 3600
  }
]
```

## Deployment Process

### 1. Automated Deployment (Recommended)

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Cloudflare Pages

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Bun
        uses: oven-sh/setup-bun@v1
        with:
          bun-version: latest

      - name: Install dependencies
        run: bun install

      - name: Run tests
        run: bun run test

      - name: Build
        run: bun run build

      - name: Deploy to Cloudflare Pages
        uses: cloudflare/pages-action@v1
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
          projectName: zalo-ai-assistant
          directory: dist
          gitHubToken: ${{ secrets.GITHUB_TOKEN }}
```

### 2. Manual Deployment

```bash
# Build for production
bun run build

# Deploy to Cloudflare Pages
wrangler pages deploy dist --project-name=zalo-ai-assistant

# Or deploy to staging
wrangler pages deploy dist --project-name=zalo-ai-assistant-staging
```

### 3. Database Deployment

```bash
# Apply migrations to production
wrangler d1 migrations apply zalo-ai-assistant-db --remote

# Backup before major changes
wrangler d1 backup create zalo-ai-assistant-db

# Check migration status
wrangler d1 migrations list zalo-ai-assistant-db --remote
```

## Build Configuration

### 1. Production Build Script

Update `package.json`:

```json
{
  "scripts": {
    "build": "bun run build:clean && bun run build:app && bun run build:assets",
    "build:clean": "rm -rf dist",
    "build:app": "bun build src/index.ts --outdir=dist --target=bun --minify",
    "build:assets": "cp -r public/* dist/",
    "build:check": "tsc --noEmit && bun run lint",
    "deploy": "bun run build:check && bun run build && wrangler pages deploy dist",
    "deploy:staging": "bun run build && wrangler pages deploy dist --env=staging"
  }
}
```

### 2. Build Optimization

Create `build.ts`:

```typescript
import { build } from "bun";
import { copyFile, mkdir, readdir } from "fs/promises";
import { join } from "path";

async function buildProduction() {
  console.log("Building for production...");

  // Build TypeScript
  await build({
    entrypoints: ["src/index.ts"],
    outdir: "dist",
    target: "bun",
    minify: true,
    sourcemap: "external",
  });

  // Copy static assets
  await copyAssets();

  // Generate build info
  await generateBuildInfo();

  console.log("Build completed successfully");
}

async function copyAssets() {
  const publicDir = "public";
  const distDir = "dist";

  await mkdir(distDir, { recursive: true });

  const files = await readdir(publicDir, { recursive: true });
  for (const file of files) {
    if (typeof file === "string") {
      await copyFile(join(publicDir, file), join(distDir, file));
    }
  }
}

async function generateBuildInfo() {
  const buildInfo = {
    buildTime: new Date().toISOString(),
    version: process.env.npm_package_version || "1.0.0",
    commit: process.env.GITHUB_SHA || "unknown",
    environment: "production",
  };

  await Bun.write("dist/build-info.json", JSON.stringify(buildInfo, null, 2));
}

if (import.meta.main) {
  buildProduction();
}
```

## Environment Configuration

### 1. Production Environment Variables

Create production `.env`:

```env
# Application
NODE_ENV=production
JWT_SECRET=your-production-jwt-secret
API_BASE_URL=https://your-domain.pages.dev

# Database
DATABASE_URL=your-d1-database

# Zalo Configuration
ZALO_APP_ID=your_production_app_id
ZALO_APP_SECRET=your_production_app_secret
ZALO_OA_ID=your_production_oa_id
ZALO_WEBHOOK_URL=https://your-domain.pages.dev/api/zalo/webhook
ZALO_WEBHOOK_SECRET=your_production_webhook_secret
ZALO_OA_ACCESS_TOKEN=your_production_oa_token

# AI Services
OPENAI_API_KEY=your_production_openai_key
OPENAI_MODEL=gpt-3.5-turbo
OPENAI_MAX_TOKENS=150

# File Storage
R2_BUCKET=zalo-ai-assistant-files
R2_ACCOUNT_ID=your_cloudflare_account_id
R2_ACCESS_KEY=your_r2_access_key
R2_SECRET_KEY=your_r2_secret_key
R2_CDN_URL=https://cdn.your-domain.com

# Monitoring
LOG_LEVEL=info
ANALYTICS_ENABLED=true

# Email (optional)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_production_email
SMTP_PASS=your_production_password
```

### 2. Configuration Validation

Create `src/config/validate.ts`:

```typescript
export function validateConfig() {
  const required = [
    "ZALO_APP_ID",
    "ZALO_APP_SECRET",
    "ZALO_OA_ACCESS_TOKEN",
    "JWT_SECRET",
    "OPENAI_API_KEY",
  ];

  const missing = required.filter((key) => !process.env[key]);

  if (missing.length > 0) {
    throw new Error(
      `Missing required environment variables: ${missing.join(", ")}`,
    );
  }

  console.log("✓ All required environment variables are set");
}

export const config = {
  app: {
    env: process.env.NODE_ENV || "development",
    port: parseInt(process.env.PORT || "3000"),
    jwtSecret: process.env.JWT_SECRET!,
  },
  zalo: {
    appId: process.env.ZALO_APP_ID!,
    appSecret: process.env.ZALO_APP_SECRET!,
    oaId: process.env.ZALO_OA_ID!,
    webhookUrl: process.env.ZALO_WEBHOOK_URL!,
    webhookSecret: process.env.ZALO_WEBHOOK_SECRET!,
    accessToken: process.env.ZALO_OA_ACCESS_TOKEN!,
  },
  ai: {
    provider: "openai",
    apiKey: process.env.OPENAI_API_KEY!,
    model: process.env.OPENAI_MODEL || "gpt-3.5-turbo",
    maxTokens: parseInt(process.env.OPENAI_MAX_TOKENS || "150"),
  },
  storage: {
    bucket: process.env.R2_BUCKET!,
    accountId: process.env.R2_ACCOUNT_ID!,
    accessKey: process.env.R2_ACCESS_KEY!,
    secretKey: process.env.R2_SECRET_KEY!,
    cdnUrl: process.env.R2_CDN_URL!,
  },
};
```

## Database Deployment

### 1. Migration Management

Create `src/db/migrations/deploy.ts`:

```typescript
import { drizzle } from "drizzle-orm/d1";

export async function deployMigrations(db: D1Database) {
  console.log("Deploying database migrations...");

  // Create migrations table
  await db.exec(`
    CREATE TABLE IF NOT EXISTS __migrations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      filename TEXT UNIQUE NOT NULL,
      executed_at INTEGER DEFAULT (unixepoch())
    )
  `);

  // Get executed migrations
  const executed = await db.prepare("SELECT filename FROM __migrations").all();
  const executedFiles = new Set(executed.results.map((m) => m.filename));

  // Run new migrations
  const migrations = [
    "001_initial_schema.sql",
    "002_add_customers.sql",
    "003_add_files.sql",
    "004_add_analytics.sql",
  ];

  for (const migration of migrations) {
    if (!executedFiles.has(migration)) {
      console.log(`Running migration: ${migration}`);

      const sql = await getMigrationSQL(migration);
      await db.exec(sql);

      await db
        .prepare("INSERT INTO __migrations (filename) VALUES (?)")
        .bind(migration)
        .run();
    }
  }

  console.log("✓ Database migrations completed");
}

async function getMigrationSQL(filename: string): Promise<string> {
  // In production, migrations should be embedded in the build
  const migrations = {
    "001_initial_schema.sql": `
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        zalo_id TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        email TEXT,
        settings JSON DEFAULT '{}',
        created_at INTEGER DEFAULT (unixepoch())
      );
    `,
    // ... other migrations
  };

  return migrations[filename] || "";
}
```

### 2. Data Seeding for Production

```typescript
export async function seedProductionData(db: D1Database) {
  // Only run in development or with explicit flag
  if (process.env.NODE_ENV === "production" && !process.env.ALLOW_SEED) {
    console.log("Skipping data seeding in production");
    return;
  }

  console.log("Seeding production data...");

  // Add any necessary production data
  // Be very careful with this in production!

  console.log("✓ Production data seeded");
}
```

## SSL and Custom Domain

### 1. Custom Domain Setup

```bash
# Add custom domain to Cloudflare Pages
wrangler pages domain add your-domain.com --project-name=zalo-ai-assistant

# Verify domain
wrangler pages domain list --project-name=zalo-ai-assistant
```

### 2. SSL Configuration

Cloudflare automatically provides SSL certificates. For custom domains:

1. Add domain to Cloudflare DNS
2. Update nameservers to Cloudflare
3. Enable "Always Use HTTPS" in SSL/TLS settings
4. Set SSL/TLS encryption mode to "Full (strict)"

## Monitoring and Health Checks

### 1. Health Check Endpoint

Create `src/api/health.ts`:

```typescript
export async function healthCheck(c: Context) {
  const checks = {
    timestamp: Date.now(),
    environment: process.env.NODE_ENV,
    version: process.env.npm_package_version || "1.0.0",
    uptime: process.uptime?.() || 0,
    status: "healthy",
    services: {},
  };

  try {
    // Check database
    checks.services.database = await checkDatabase();

    // Check Zalo API
    checks.services.zalo = await checkZaloAPI();

    // Check AI service
    checks.services.ai = await checkAIService();

    // Check file storage
    checks.services.storage = await checkStorage();
  } catch (error) {
    checks.status = "unhealthy";
    checks.error = error.message;
  }

  const statusCode = checks.status === "healthy" ? 200 : 503;
  return c.json(checks, statusCode);
}

async function checkDatabase(): Promise<string> {
  // Simple query to check database connectivity
  const result = await db.prepare("SELECT 1").first();
  return result ? "healthy" : "unhealthy";
}

async function checkZaloAPI(): Promise<string> {
  try {
    const response = await fetch("https://openapi.zalo.me/v2.0/oa/getprofile", {
      headers: {
        access_token: process.env.ZALO_OA_ACCESS_TOKEN!,
      },
    });
    return response.ok ? "healthy" : "unhealthy";
  } catch {
    return "unhealthy";
  }
}

async function checkAIService(): Promise<string> {
  try {
    const response = await fetch("https://api.openai.com/v1/models", {
      headers: {
        Authorization: `Bearer ${process.env.OPENAI_API_KEY}`,
      },
    });
    return response.ok ? "healthy" : "unhealthy";
  } catch {
    return "unhealthy";
  }
}

async function checkStorage(): Promise<string> {
  try {
    // Simple R2 connectivity check
    const response = await fetch(
      `https://${process.env.R2_BUCKET}.r2.cloudflarestorage.com/`,
    );
    return response.status < 500 ? "healthy" : "unhealthy";
  } catch {
    return "unhealthy";
  }
}
```

### 2. Uptime Monitoring

Setup external monitoring with services like:

- **UptimeRobot** (free): Monitor `/api/health` endpoint
- **Pingdom**: Advanced monitoring with alerts
- **Cloudflare Health Checks**: Built-in monitoring

## Rollback Strategy

### 1. Deployment Rollback

```bash
# List deployments
wrangler pages deployment list --project-name=zalo-ai-assistant

# Promote previous deployment
wrangler pages deployment promote <DEPLOYMENT_ID> --project-name=zalo-ai-assistant

# Rollback database (if needed)
wrangler d1 backup restore zalo-ai-assistant-db --backup-id=<BACKUP_ID>
```

### 2. Automated Rollback

Create rollback script `scripts/rollback.sh`:

```bash
#!/bin/bash

set -e

echo "Starting rollback process..."

# Get current deployment
CURRENT=$(wrangler pages deployment list --project-name=zalo-ai-assistant --format=json | jq -r '.[0].id')
echo "Current deployment: $CURRENT"

# Get previous deployment
PREVIOUS=$(wrangler pages deployment list --project-name=zalo-ai-assistant --format=json | jq -r '.[1].id')
echo "Previous deployment: $PREVIOUS"

# Confirm rollback
read -p "Rollback from $CURRENT to $PREVIOUS? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  # Promote previous deployment
  wrangler pages deployment promote $PREVIOUS --project-name=zalo-ai-assistant
  echo "✓ Rollback completed"
else
  echo "Rollback cancelled"
fi
```

## Security Considerations

### 1. Environment Security

```bash
# Rotate secrets regularly
wrangler secret put JWT_SECRET --force
wrangler secret put ZALO_APP_SECRET --force

# Use different secrets for staging/production
wrangler secret put JWT_SECRET --env=staging
wrangler secret put JWT_SECRET --env=production
```

### 2. Access Control

- Use Cloudflare Access for admin endpoints
- Implement IP whitelisting for sensitive operations
- Enable WAF rules for DDoS protection
- Use Bot Fight Mode for automated protection

### 3. Content Security Policy

Add CSP headers in `src/middleware/security.ts`:

```typescript
export function securityHeaders() {
  return {
    "Content-Security-Policy": [
      "default-src 'self'",
      "script-src 'self' 'unsafe-inline' cdn.tailwindcss.com",
      "style-src 'self' 'unsafe-inline' cdn.tailwindcss.com",
      "img-src 'self' data: https:",
      "connect-src 'self' https://api.openai.com https://openapi.zalo.me",
      "font-src 'self' data:",
      "object-src 'none'",
      "base-uri 'self'",
      "frame-ancestors 'none'",
    ].join("; "),
    "X-Frame-Options": "DENY",
    "X-Content-Type-Options": "nosniff",
    "Referrer-Policy": "strict-origin-when-cross-origin",
    "Permissions-Policy": "camera=(), microphone=(), geolocation=()",
  };
}
```

## Performance Optimization

### 1. Caching Strategy

```typescript
// Cache headers for static assets
export function setCacheHeaders(path: string) {
  if (path.match(/\.(js|css|png|jpg|gif|ico|svg)$/)) {
    return {
      "Cache-Control": "public, max-age=31536000, immutable",
    };
  }

  if (path.match(/\.(html|json)$/)) {
    return {
      "Cache-Control": "public, max-age=300, s-maxage=86400",
    };
  }

  return {
    "Cache-Control": "public, max-age=0, must-revalidate",
  };
}
```

### 2. Asset Optimization

```bash
# Optimize images before deployment
bun run optimize:images

# Compress assets
bun run compress:assets

# Generate service worker for caching
bun run generate:sw
```

This deployment guide provides a complete, production-ready deployment strategy for the Zalo AI Assistant, following KISS principles while ensuring reliability, security, and performance.

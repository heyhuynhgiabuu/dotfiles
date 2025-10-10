# Zalo AI Assistant - Development Setup Guide

## Overview

This guide walks you through setting up a local development environment for the Zalo AI Assistant. The setup follows KISS principles with minimal dependencies and maximum productivity for solo development.

## Prerequisites

### Required Software

1. **Bun.js (Latest)**

   ```bash
   curl -fsSL https://bun.sh/install | bash
   ```

2. **Git**

   ```bash
   # macOS
   git --version  # Usually pre-installed

   # Linux
   sudo apt update && sudo apt install git
   ```

3. **VSCode (Recommended)**
   - Download from [code.visualstudio.com](https://code.visualstudio.com/)

### Development Tools

```bash
# Verify installations
bun --version    # Should be 1.0.0+
git --version    # Should be 2.30.0+
node --version   # Optional, Bun can replace Node.js
```

## Project Setup

### 1. Clone and Initialize

```bash
# Clone the repository
git clone https://github.com/yourusername/zalo-ai-assistant.git
cd zalo-ai-assistant

# Install dependencies
bun install

# Copy environment template
cp .env.example .env
```

### 2. Environment Configuration

Create `.env` file with the following variables:

```env
# Basic Configuration
NODE_ENV=development
PORT=3000
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production

# Database
DATABASE_URL=./database.sqlite

# Zalo Configuration
ZALO_APP_ID=your_zalo_app_id
ZALO_APP_SECRET=your_zalo_app_secret
ZALO_OA_ID=your_official_account_id
ZALO_WEBHOOK_URL=http://localhost:3000/api/zalo/webhook
ZALO_WEBHOOK_SECRET=your_webhook_secret
ZALO_OA_ACCESS_TOKEN=your_oa_access_token

# AI Configuration
OPENAI_API_KEY=your_openai_api_key
OPENAI_MODEL=gpt-3.5-turbo

# File Storage (Development)
STORAGE_TYPE=local
UPLOAD_PATH=./uploads
UPLOAD_URL=http://localhost:3000/uploads

# Optional: External Services
EMAIL_FROM=noreply@yourapp.com
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASS=your_app_password
```

### 3. Database Setup

```bash
# Create database directory
mkdir -p data

# Run database migrations
bun run db:migrate

# Seed development data (optional)
bun run db:seed
```

### 4. File Storage Setup

```bash
# Create upload directories
mkdir -p uploads/files
mkdir -p uploads/thumbnails
mkdir -p uploads/temp

# Set permissions (Linux/macOS)
chmod 755 uploads
```

## Project Structure

```
zalo-ai-assistant/
├── src/
│   ├── api/                 # API routes
│   │   ├── auth.ts
│   │   ├── messages.ts
│   │   ├── customers.ts
│   │   ├── files.ts
│   │   └── zalo.ts
│   ├── services/            # Business logic
│   │   ├── auth.service.ts
│   │   ├── zalo.service.ts
│   │   ├── ai.service.ts
│   │   └── file.service.ts
│   ├── db/                  # Database
│   │   ├── connection.ts
│   │   ├── schema/
│   │   └── migrations/
│   ├── utils/               # Utilities
│   │   ├── validation.ts
│   │   ├── crypto.ts
│   │   └── logger.ts
│   ├── middleware/          # Express middleware
│   │   ├── auth.ts
│   │   ├── cors.ts
│   │   └── error.ts
│   └── index.ts             # Application entry point
├── public/                  # Static files
│   ├── index.html
│   ├── dashboard.html
│   ├── css/
│   ├── js/
│   └── assets/
├── tests/                   # Test files
│   ├── unit/
│   ├── integration/
│   └── fixtures/
├── docs/                    # Documentation
├── uploads/                 # File uploads (dev only)
├── data/                    # Database files (dev only)
├── package.json
├── bun.lockb
├── .env
├── .env.example
├── .gitignore
└── README.md
```

## Development Commands

### Essential Commands

```bash
# Start development server
bun run dev

# Run tests
bun run test

# Run tests in watch mode
bun run test:watch

# Build for production
bun run build

# Start production server
bun run start

# Database commands
bun run db:migrate       # Run migrations
bun run db:rollback      # Rollback last migration
bun run db:seed          # Seed test data
bun run db:reset         # Reset database

# Code quality
bun run lint             # Run ESLint
bun run format           # Run Prettier
bun run type-check       # Run TypeScript check
```

### Package.json Scripts

```json
{
  "scripts": {
    "dev": "bun run --watch src/index.ts",
    "build": "bun build src/index.ts --outdir=dist --target=bun",
    "start": "bun run dist/index.js",
    "test": "bun test",
    "test:watch": "bun test --watch",
    "lint": "eslint src/**/*.ts",
    "format": "prettier --write src/**/*.ts",
    "type-check": "tsc --noEmit",
    "db:migrate": "bun run src/db/migrate.ts",
    "db:seed": "bun run src/db/seed.ts",
    "db:reset": "rm -f data/database.sqlite && bun run db:migrate && bun run db:seed"
  }
}
```

## VSCode Configuration

### Recommended Extensions

Install these extensions for the best development experience:

```json
{
  "recommendations": [
    "esbenp.prettier-vscode",
    "ms-vscode.vscode-typescript-next",
    "bradlc.vscode-tailwindcss",
    "ms-vscode.vscode-eslint",
    "ms-vscode.vscode-json",
    "ms-vscode.test-adapter-converter",
    "oven.bun-vscode"
  ]
}
```

### Workspace Settings

Create `.vscode/settings.json`:

```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true,
    "source.organizeImports": true
  },
  "typescript.preferences.importModuleSpecifier": "relative",
  "emmet.includeLanguages": {
    "javascript": "javascriptreact",
    "typescript": "typescriptreact"
  },
  "files.exclude": {
    "**/node_modules": true,
    "**/dist": true,
    "**/bun.lockb": true,
    "**/.env": true,
    "**/data": true,
    "**/uploads": true
  }
}
```

### Launch Configuration

Create `.vscode/launch.json` for debugging:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug Bun App",
      "type": "node",
      "request": "launch",
      "program": "${workspaceFolder}/src/index.ts",
      "runtimeExecutable": "bun",
      "runtimeArgs": ["--inspect"],
      "env": {
        "NODE_ENV": "development"
      },
      "console": "integratedTerminal",
      "sourceMaps": true
    }
  ]
}
```

## Database Development

### Schema Management

```typescript
// src/db/migrate.ts
import { Database } from "bun:sqlite";
import { readdir } from "fs/promises";
import { join } from "path";

async function runMigrations() {
  const db = new Database("./data/database.sqlite");

  // Create migrations table
  db.exec(`
    CREATE TABLE IF NOT EXISTS migrations (
      id INTEGER PRIMARY KEY,
      filename TEXT UNIQUE,
      executed_at INTEGER DEFAULT (unixepoch())
    )
  `);

  // Get executed migrations
  const executed = db.prepare("SELECT filename FROM migrations").all();
  const executedFiles = new Set(executed.map((m) => m.filename));

  // Get migration files
  const migrationDir = join(__dirname, "migrations");
  const files = await readdir(migrationDir);
  const migrationFiles = files.filter((f) => f.endsWith(".sql")).sort();

  // Run new migrations
  for (const file of migrationFiles) {
    if (!executedFiles.has(file)) {
      console.log(`Running migration: ${file}`);
      const sql = await Bun.file(join(migrationDir, file)).text();
      db.exec(sql);

      db.prepare("INSERT INTO migrations (filename) VALUES (?)").run(file);
    }
  }

  db.close();
  console.log("Migrations completed");
}

if (import.meta.main) {
  runMigrations();
}
```

### Test Data Seeding

```typescript
// src/db/seed.ts
import { Database } from "bun:sqlite";
import { createHash } from "crypto";

async function seedDatabase() {
  const db = new Database("./data/database.sqlite");

  // Clear existing test data
  db.exec(`
    DELETE FROM messages;
    DELETE FROM customers;
    DELETE FROM users WHERE zalo_id LIKE 'test_%';
  `);

  // Create test user
  const testUser = {
    id: "user_test_123",
    zalo_id: "test_user_123",
    name: "Test User",
    email: "test@example.com",
    settings: JSON.stringify({
      auto_reply: true,
      business_hours: {
        enabled: true,
        start: "09:00",
        end: "18:00",
      },
    }),
  };

  db.prepare(
    `
    INSERT INTO users (id, zalo_id, name, email, settings)
    VALUES (?, ?, ?, ?, ?)
  `,
  ).run(
    testUser.id,
    testUser.zalo_id,
    testUser.name,
    testUser.email,
    testUser.settings,
  );

  // Create test customers
  const customers = [
    {
      id: "customer_test_1",
      user_id: testUser.id,
      zalo_id: "test_customer_1",
      name: "Nguyễn Văn A",
      phone: "+84123456789",
    },
    {
      id: "customer_test_2",
      user_id: testUser.id,
      zalo_id: "test_customer_2",
      name: "Trần Thị B",
      phone: "+84987654321",
    },
  ];

  const insertCustomer = db.prepare(`
    INSERT INTO customers (id, user_id, zalo_id, name, phone)
    VALUES (?, ?, ?, ?, ?)
  `);

  customers.forEach((customer) => {
    insertCustomer.run(
      customer.id,
      customer.user_id,
      customer.zalo_id,
      customer.name,
      customer.phone,
    );
  });

  // Create test messages
  const messages = [
    {
      id: "msg_test_1",
      user_id: testUser.id,
      customer_id: "customer_test_1",
      type: "incoming",
      content: "Xin chào, tôi muốn hỏi về sản phẩm",
      created_at: Date.now() - 3600000,
    },
    {
      id: "msg_test_2",
      user_id: testUser.id,
      customer_id: "customer_test_1",
      type: "outgoing",
      content: "Chào anh! Anh muốn hỏi về sản phẩm nào ạ?",
      is_auto_reply: true,
      created_at: Date.now() - 3500000,
    },
  ];

  const insertMessage = db.prepare(`
    INSERT INTO messages (id, user_id, customer_id, type, content, is_auto_reply, created_at)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `);

  messages.forEach((message) => {
    insertMessage.run(
      message.id,
      message.user_id,
      message.customer_id,
      message.type,
      message.content,
      message.is_auto_reply || false,
      message.created_at,
    );
  });

  db.close();
  console.log("Database seeded with test data");
}

if (import.meta.main) {
  seedDatabase();
}
```

## Development Workflow

### 1. Daily Development

```bash
# Start your day
git pull origin main
bun install  # In case of new dependencies

# Start development server
bun run dev

# In another terminal, run tests in watch mode
bun run test:watch
```

### 2. Feature Development

```bash
# Create feature branch
git checkout -b feature/customer-search

# Make changes, test frequently
bun run test

# Check code quality
bun run lint
bun run format
bun run type-check

# Commit changes
git add .
git commit -m "feat: add customer search functionality"
```

### 3. Testing Changes

```bash
# Run all tests
bun run test

# Test specific file
bun test tests/services/zalo.service.test.ts

# Reset database for fresh testing
bun run db:reset
```

## Debugging

### Application Debugging

```bash
# Start with debugger
bun run --inspect src/index.ts

# Or use VSCode debugger (F5)
```

### Database Debugging

```bash
# Connect to SQLite database
sqlite3 data/database.sqlite

# Common queries
.tables
.schema users
SELECT * FROM users LIMIT 5;
```

### Network Debugging

```bash
# Test API endpoints
curl http://localhost:3000/api/health

# Test authentication
curl -H "Authorization: Bearer your_jwt_token" \
     http://localhost:3000/api/users/profile
```

## Common Issues & Solutions

### 1. Port Already in Use

```bash
# Find process using port 3000
lsof -i :3000

# Kill process
kill -9 <PID>

# Or use different port
PORT=3001 bun run dev
```

### 2. Database Locked

```bash
# Stop all processes using database
pkill -f "bun"

# Remove database lock
rm -f data/database.sqlite-wal
rm -f data/database.sqlite-shm
```

### 3. Permission Issues

```bash
# Fix upload directory permissions
chmod -R 755 uploads

# Fix database permissions
chmod 644 data/database.sqlite
```

### 4. Dependency Issues

```bash
# Clear and reinstall
rm -rf node_modules bun.lockb
bun install

# Update dependencies
bun update
```

## Performance Tips

### 1. Development Server

```bash
# Use --hot for faster reloading
bun run --hot src/index.ts

# Disable source maps for faster startup
BUN_JSC_forceRAMSize=0 bun run dev
```

### 2. Database Performance

```sql
-- Add indexes for development queries
CREATE INDEX idx_messages_created_at ON messages(created_at);
CREATE INDEX idx_customers_user_id ON customers(user_id);
```

### 3. File Watching

Create `.bunignore` to exclude files from watching:

```
node_modules/
dist/
uploads/
data/
.git/
*.log
```

## Production Build Testing

### Build and Test

```bash
# Build production version
bun run build

# Test production build locally
NODE_ENV=production bun run start

# Test with production database
cp data/database.sqlite data/database.prod.sqlite
DATABASE_URL=./data/database.prod.sqlite bun run start
```

### Environment Validation

```bash
# Validate environment variables
bun run src/utils/validate-env.ts

# Test external service connections
bun run src/utils/health-check.ts
```

This development setup guide provides everything you need to get started with the Zalo AI Assistant project efficiently and productively, following KISS principles for solo development.

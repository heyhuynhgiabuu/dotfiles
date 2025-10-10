# Online Wedding Card - Comprehensive Spec

> **Brutal truth:** This is a 2-3 week project. Follow the spec strictly. No feature creep. Ship the MVP.

## 📚 Specification Documents

1. **[Requirements](./requirements.md)** - What we're building and why
2. **[Design](./design.md)** - How we're building it (architecture, APIs, components)
3. **[Tasks](./tasks.md)** - Step-by-step implementation plan

## 🎯 Project Overview

**What:** Digital wedding invitation with RSVP, guest management, and photo gallery  
**Stack:** Cloudflare (Workers + Pages + D1 + R2)  
**Timeline:** 2-3 weeks to MVP  
**Cost:** $0/month (free tier)

## ⚡ Quick Start

### Prerequisites

```bash
# 1. Install tools
nvm use 22
npm i -g wrangler bun

# 2. Create Cloudflare account (free)
# Visit: https://dash.cloudflare.com

# 3. Create Clerk account (free)
# Visit: https://clerk.com

# 4. Create Resend account (free)
# Visit: https://resend.com
```

### Setup (5 minutes)

```bash
# 1. Create project directory
mkdir wedding-card && cd wedding-card

# 2. Initialize monorepo
bun init -y
mkdir -p apps/{api,web} packages/types

# 3. Setup Turborepo
bun add -D turbo
echo '{"$schema":"https://turbo.build/schema.json","pipeline":{"build":{"outputs":["dist/**",".next/**"]},"dev":{"cache":false}}}' > turbo.json

# 4. Create D1 database
wrangler d1 create wedding-card-db

# 5. Create R2 bucket
wrangler r2 bucket create wedding-card-photos

# 6. Copy .env.example
cp .env.example .env
# Fill in your API keys
```

### Development

```bash
# Install all dependencies
bun install

# Run backend (Hono API)
cd apps/api && bun dev

# Run frontend (TanStack Start)
cd apps/web && bun dev

# Run both concurrently
turbo dev
```

### Deployment

```bash
# Deploy backend to Cloudflare Workers
cd apps/api && wrangler deploy

# Deploy frontend to Cloudflare Pages
cd apps/web && wrangler pages deploy dist
```

## 🏗️ Tech Stack

### Frontend (TanStack Start)

- **Framework:** TanStack Start (React-based, file-based routing)
- **Styling:** Tailwind CSS + shadcn/ui
- **Forms:** React Hook Form + Zod
- **State:** TanStack Query
- **Animations:** Framer Motion
- **Deploy:** Cloudflare Pages

### Backend (Hono)

- **Framework:** Hono (fastest web framework for Workers)
- **Runtime:** Cloudflare Workers (edge computing)
- **Database:** Cloudflare D1 (serverless SQLite)
- **ORM:** Drizzle ORM
- **Storage:** Cloudflare R2 (S3-compatible)
- **Auth:** Clerk (JWT-based)
- **Email:** Resend (transactional)

### Why Cloudflare Stack?

1. **$0/month** - Entire stack is free tier
2. **Global edge** - Fast everywhere (300+ cities)
3. **Zero config** - No servers, no Kubernetes
4. **Auto-scaling** - Handles traffic spikes
5. **Built-in CDN** - Assets cached globally
6. **Modern DX** - TypeScript, Bun, ESM

## 📋 Core Features (MVP)

### Public Features

- ✅ Landing page with countdown timer
- ✅ Story timeline with photos
- ✅ Event details with embedded map
- ✅ RSVP form with email confirmation
- ✅ QR code generation for check-in
- ✅ Photo gallery (approved photos only)

### Admin Features (Protected)

- ✅ Authentication via Clerk
- ✅ Guest management (list, edit, delete)
- ✅ RSVP tracking and analytics
- ✅ QR code check-in system
- ✅ Photo approval workflow
- ✅ CSV export

## 📐 Architecture

```
┌─────────────────────────────────────────┐
│         Cloudflare Global Edge          │
├─────────────────────────────────────────┤
│                                          │
│  ┌──────────┐        ┌──────────┐      │
│  │  Pages   │───────▶│ Workers  │      │
│  │  (CDN)   │  API   │  (Hono)  │      │
│  └──────────┘        └─────┬────┘      │
│                            │            │
│                            ▼            │
│              ┌─────────────────────┐   │
│              │  D1 (SQLite)        │   │
│              │  R2 (Storage)       │   │
│              └─────────────────────┘   │
│                                         │
└─────────────────────────────────────────┘
              │              │
              ▼              ▼
        ┌─────────┐    ┌──────────┐
        │  Clerk  │    │  Resend  │
        │  (Auth) │    │  (Email) │
        └─────────┘    └──────────┘
```

## 🗂️ Project Structure

```
wedding-card/
├── apps/
│   ├── api/                    # Hono backend
│   │   ├── src/
│   │   │   ├── index.ts
│   │   │   ├── routes/         # API endpoints
│   │   │   ├── db/             # Drizzle schema
│   │   │   ├── middleware/     # Auth, CORS, etc.
│   │   │   └── lib/            # Utilities
│   │   └── wrangler.toml
│   │
│   └── web/                    # TanStack Start frontend
│       ├── src/
│       │   ├── routes/         # File-based routing
│       │   ├── components/     # React components
│       │   └── lib/            # API client
│       └── app.config.ts
│
├── packages/
│   └── types/                  # Shared TypeScript types
│
├── turbo.json
└── package.json
```

## 🚀 Implementation Phases

### Week 1: Core Features

- **Day 1-2:** Project setup + authentication
- **Day 3-4:** RSVP system (form + backend)
- **Day 5-7:** Landing page + photo gallery

### Week 2: Admin Dashboard

- **Day 8-9:** Admin dashboard + guest management
- **Day 10-11:** Check-in system (QR scanner)
- **Day 12-13:** Photo management + approval
- **Day 14:** Testing + deployment

### Week 3: Polish & Launch

- **Day 15-16:** UI/UX polish + accessibility
- **Day 17-18:** Performance optimization
- **Day 19-20:** Content + launch prep
- **Day 21:** Launch! 🎉

## 🎨 Design System

### Colors (Tailwind Config)

```typescript
colors: {
  wedding: {
    primary: '#D4AF37',   // Gold
    secondary: '#F5F5DC', // Beige
    accent: '#8B7355',    // Tan
    dark: '#2C2C2C',
    light: '#FFFFFF',
  }
}
```

### Typography

```css
font-heading: "Playfair Display", serif; /* Elegant */
font-body: "Lato", sans-serif; /* Clean */
```

## 📊 Database Schema

```sql
-- Guests
CREATE TABLE guests (
  id INTEGER PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  num_guests INTEGER DEFAULT 1,
  attendance_status TEXT,  -- 'yes' | 'no' | 'maybe'
  checked_in BOOLEAN DEFAULT 0,
  qr_code TEXT UNIQUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Photos
CREATE TABLE photos (
  id INTEGER PRIMARY KEY,
  r2_key TEXT NOT NULL,
  uploaded_by TEXT,
  approved BOOLEAN DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Admins
CREATE TABLE admins (
  id INTEGER PRIMARY KEY,
  clerk_user_id TEXT UNIQUE NOT NULL,
  email TEXT NOT NULL
);
```

## 🔐 Security

- **Authentication:** Clerk JWT validation on all admin routes
- **Rate Limiting:** 10 RSVP/hour per IP (Cloudflare Workers)
- **Input Validation:** Zod schemas on frontend + backend
- **SQL Injection:** Drizzle ORM (parameterized queries)
- **CORS:** Whitelist domains only
- **Secrets:** Environment variables (never commit)

## 📈 Success Metrics

### Technical

- ✅ Lighthouse score: 95+
- ✅ Load time: < 2s
- ✅ Uptime: 99.9%
- ✅ Mobile responsive: 100%

### Business

- ✅ RSVP completion: 80%+
- ✅ Check-in efficiency: < 2 min/guest
- ✅ Zero critical bugs on event day
- ✅ Happy couple! 💑

## ⚠️ Critical Constraints

1. **Budget:** $0/month (must use free tier)
2. **Timeline:** 2-3 weeks maximum
3. **Team:** 1 developer (you)
4. **Scope:** MVP only, no feature creep

## 🛠️ Troubleshooting

### Common Issues

**Issue:** D1 database not found  
**Fix:** Run `wrangler d1 create wedding-card-db` and update `wrangler.toml`

**Issue:** R2 bucket access denied  
**Fix:** Check `wrangler.toml` has correct bucket binding

**Issue:** Clerk authentication fails  
**Fix:** Verify `CLERK_SECRET_KEY` in `.env` and JWT validation middleware

**Issue:** Images not uploading  
**Fix:** Check R2 bucket CORS settings and presigned URL generation

## 📚 Resources

### Documentation

- [TanStack Start](https://tanstack.com/start)
- [Hono](https://hono.dev)
- [Cloudflare D1](https://developers.cloudflare.com/d1)
- [Drizzle ORM](https://orm.drizzle.team)
- [Clerk](https://clerk.com/docs)
- [shadcn/ui](https://ui.shadcn.com)

### Templates

- See `examples/` folder for code snippets
- Check `/api` routes for backend patterns
- Review `/components` for frontend patterns

## 🎯 Next Steps

1. **Read all 3 spec docs** (requirements, design, tasks)
2. **Setup external services** (Cloudflare, Clerk, Resend)
3. **Follow tasks.md day-by-day**
4. **Ship the MVP in 2 weeks**
5. **Launch and celebrate!** 🎉

---

**Remember:** Stick to the spec. No feature creep. Focus on MVP. You got this! 💪

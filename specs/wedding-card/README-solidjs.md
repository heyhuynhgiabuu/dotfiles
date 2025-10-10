# Wedding Card Project - SolidJS + Cloudflare

> **Stack:** SolidJS + Cloudflare (Pages, Workers, D1, R2, KV)  
> **Timeline:** 16 weeks (plenty of buffer)  
> **Your Capacity:** 2-4 hours/day, familiar with TypeScript/React  
> **Goals:** Learn SolidJS + Ship custom wedding card

## 📁 Documentation Structure

1. **comprehensive-spec.md** - Full requirements, design, and architecture
2. **implementation-guide.md** - Week-by-week plan with code examples
3. **tasks-solidjs.md** - Detailed task breakdown with time estimates

## 🎯 Project Overview

**What You're Building:**

- Modern, mobile-first wedding invitation website
- RSVP system with database storage
- Guest book with moderation
- Admin dashboard for management
- Photo gallery (optimized for mobile)
- All hosted on Cloudflare (100% free tier)

**Why This Makes Sense:**

- ✅ 16 weeks = plenty of time
- ✅ 2-4 hrs/day = more than enough
- ✅ TS/React background = easy SolidJS transition
- ✅ Learning goal + shipping goal aligned

## 🚀 Quick Start

### Day 1 Setup (2-3 hours)

```bash
# 1. Complete SolidJS tutorial first!
# https://www.solidjs.com/tutorial (2 hours)

# 2. Install tools
npm install -g wrangler pnpm

# 3. Login to Cloudflare
wrangler login

# 4. Create project
pnpm create vite wedding-card --template solid-ts
cd wedding-card

# 5. Install dependencies
pnpm add -D tailwindcss postcss autoprefixer
pnpm add -D @cloudflare/workers-types
pnpm add @solidjs/router

# 6. Init Tailwind
pnpm dlx tailwindcss init -p

# 7. Start dev
pnpm dev
```

### Your First Week Goals

**Week 1 (10-14 hours total):**

- ✓ Learn SolidJS basics (4-6 hours)
- ✓ Project setup (2 hours)
- ✓ Basic landing page (4-6 hours)

**Output:** Live landing page on Cloudflare Pages

## 📋 Project Phases

| Week  | Phase            | Key Deliverable             |
| ----- | ---------------- | --------------------------- |
| 1-2   | Setup & Learning | Landing page deployed       |
| 3-4   | RSVP System      | Working RSVP with database  |
| 5-6   | Content          | All sections complete       |
| 7-8   | Guestbook        | Guestbook with moderation   |
| 9-10  | Admin            | Admin dashboard             |
| 11-12 | Features         | Gallery, schedule, registry |
| 13-14 | Testing          | Production-ready            |
| 15-16 | Launch           | Live with custom domain     |

## ⏱️ Time Budget

**Total Work:** 83-118 hours  
**Your Capacity:** 224-448 hours over 16 weeks  
**Buffer:** 106-365 hours (plenty for learning!)

## 🎓 SolidJS Learning Path

**Before You Code (4-6 hours):**

1. Official tutorial (2 hours)
2. Build practice todo app (2 hours)
3. Read reactivity docs (1 hour)
4. Understand key differences from React (30 mins)

**Key Concepts to Master:**

- Signals are functions: `count()` not `count`
- Don't destructure props (breaks reactivity)
- Components run once (no re-renders)
- Effects track dependencies automatically

## 📊 Success Criteria

**MVP (Week 4):**

- [ ] Landing page live
- [ ] RSVP form working
- [ ] Mobile responsive
- [ ] <3s page load

**Launch (Week 16):**

- [ ] Lighthouse score 95+
- [ ] All features complete
- [ ] Zero critical bugs
- [ ] Custom domain configured

## 💰 Cost: $0/month

Everything fits in Cloudflare free tier:

- Pages: Unlimited (1 site)
- Workers: 100k req/day (need <1k)
- D1: 5GB storage (need <100MB)
- R2: 10GB storage (need <1GB)
- KV: 100k reads/day (need <1k)

## 🛠️ Tech Stack Decisions

### Why SolidJS?

- Small bundle (faster than React)
- Fine-grained reactivity (better performance)
- Similar to React (easy transition)
- Perfect for mobile-first apps

### Why Cloudflare?

- Free tier is generous
- Global CDN (fast everywhere)
- Edge compute (low latency)
- All-in-one platform (simpler)

### Why Simple Stack?

- No monorepo complexity
- No authentication service (just password)
- No email service initially (optional)
- Focus on core features first

## 📖 Reading Order

**First Time:**

1. Read comprehensive-spec.md (30 mins) - Understand full scope
2. Read implementation-guide.md (1 hour) - See how to build it
3. Review tasks-solidjs.md (30 mins) - Know what to do when

**Daily Workflow:**

1. Check tasks-solidjs.md for today's work
2. Reference implementation-guide.md for code examples
3. Update progress in tasks-solidjs.md

## 🔄 Workflow

### Daily (2-hour session)

```
0:00 - 0:15  Review progress, pick task
0:15 - 1:30  Focused coding
1:30 - 2:00  Testing, commit, update tasks
```

### Daily (4-hour session)

```
0:00 - 0:30  Review + plan
0:30 - 1:30  SolidJS learning (first 2 weeks only)
1:30 - 3:30  Build feature
3:30 - 4:00  Test + document
```

### Weekly Review

- Check milestone progress
- Adjust timeline if needed
- Celebrate wins
- Plan next week

## 🚨 When to Ask for Help

**Skip the struggle, ask immediately if:**

- Cloudflare deployment fails (config issues are tricky)
- D1 migrations fail (SQL syntax or binding issues)
- Rate limiting doesn't work (KV can be confusing)
- Image optimization unclear (R2 setup has nuances)

**Google first, then ask:**

- SolidJS reactivity questions (good docs)
- TailwindCSS styling (excellent docs)
- TypeScript type errors (usually clear)

## 📝 Progress Tracking

Use this format in tasks-solidjs.md:

```
Week 1: ✓ Complete (12 hours)
Week 2: ⏳ In Progress (4/10 hours)
Week 3: ⚪ Not Started
```

## 🎯 Next Steps

**Right Now:**

1. ✅ Read comprehensive-spec.md
2. ⏳ Complete SolidJS tutorial
3. ⚪ Set up Cloudflare account
4. ⚪ Initialize project
5. ⚪ Deploy "Hello World"

**After Setup:**

- Start Week 1 tasks
- Code 2-4 hours daily
- Update progress weekly
- Launch in 16 weeks!

---

**Questions? Stuck?**  
Reference the implementation-guide.md for detailed code examples and solutions to common issues.

**Good luck! You've got plenty of time to build something amazing.** 🎉

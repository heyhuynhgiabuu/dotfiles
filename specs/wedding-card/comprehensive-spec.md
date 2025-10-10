# Online Wedding Card - Comprehensive Specification

## Brutal Reality Check

**Time Investment:** 40-60 hours for MVP, 80+ hours for full features
**Cost Alternative:** $20-50 for professional templates with 90% of these features
**Lifespan:** 3-6 months of active use, then archived

**This Makes Sense If:**

- Learning Cloudflare Workers + SolidJS ecosystem
- Need specific customization unavailable in templates
- Building reusable codebase for wedding business
- Want complete creative and technical control

**This Is Wasteful If:**

- Just need a card for one wedding
- Timeline is <4 weeks to wedding date
- No interest in maintaining/debugging

## Technical Stack

### Core Technologies

- **Frontend Framework:** SolidJS (small bundle, reactive, fast)
- **Build Tool:** Vite (fast dev, optimized builds)
- **Hosting:** Cloudflare Pages (free tier, global CDN)
- **API Runtime:** Cloudflare Workers (serverless edge functions)
- **Database:** Cloudflare D1 (SQLite at edge, free 5GB)
- **Storage:** Cloudflare R2 (S3-compatible, image hosting)
- **Cache:** Cloudflare KV (rate limiting, sessions)
- **Styling:** TailwindCSS (utility-first, tree-shakeable)

### Development Tools

- **Local Dev:** Wrangler CLI + Vite dev server
- **Type Safety:** TypeScript (strict mode)
- **Code Quality:** Biome (linting + formatting, faster than ESLint)
- **Package Manager:** pnpm (fast, efficient)

## Requirements Phase

### Must Have (MVP - Week 1-2)

1. **Landing Page**
   - Hero section with couple names
   - Save the date countdown
   - Event details (date, time, location)
   - Maps integration (Google Maps embed)
2. **RSVP System**
   - Guest name, email, phone
   - Attendance confirmation (attending/not attending)
   - Guest count (adults/children)
   - Dietary restrictions field
   - Message/wishes field
   - Form validation and error handling
   - Success confirmation
3. **Mobile-First Design**
   - Responsive on all devices
   - Touch-friendly interactions
   - Works on 3G networks
   - Offline-capable (cached content)

4. **Performance**
   - <2s First Contentful Paint
   - <3s Largest Contentful Paint
   - <50KB JavaScript bundle
   - Lazy-loaded images with blur placeholders

### Should Have (Phase 2 - Week 3-4)

1. **Guest Book**
   - Public wishes/messages
   - Moderation system (approve/reject)
   - Real-time updates
2. **Story Section**
   - How we met timeline
   - Couple photos (optimized)
   - Engagement story
3. **Admin Dashboard**
   - Password-protected route
   - View all RSVPs
   - Export to CSV
   - Guestbook moderation
   - Basic analytics (views, RSVPs)

4. **Email Notifications**
   - RSVP confirmation to guest
   - New RSVP alert to couple
   - Via Cloudflare Email Workers or Resend API

### Could Have (Phase 3 - If Time Permits)

1. **Photo Gallery**
   - Engagement photos
   - Pre-wedding shoots
   - Lightbox viewer
2. **Gift Registry**
   - Links to registry sites
   - Cash gift instructions
3. **Schedule/Agenda**
   - Event timeline
   - Ceremony + reception details
4. **Advanced Features**
   - Multi-language support
   - Guest-specific content (unique URLs)
   - Photo upload from guests
   - Live ceremony streaming link

### Won't Have (Out of Scope)

- User authentication (use guest codes if needed)
- Payment processing
- Complex photo editing
- Real-time chat
- Mobile app

## Design Phase

### Information Architecture

```
/ (home)
├── #hero (couple names, date)
├── #story (how we met)
├── #details (event info, maps)
├── #rsvp (form)
├── #guestbook (messages)
├── #gallery (photos)
└── #registry (gift links)

/admin
├── /dashboard (stats)
├── /rsvps (list + export)
└── /guestbook (moderate)

/api
├── POST /rsvp (submit RSVP)
├── POST /guestbook (submit message)
├── GET /guestbook (approved messages)
└── GET /admin/* (protected endpoints)
```

### Data Models

#### RSVP Table

```sql
CREATE TABLE rsvps (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  guest_name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  attending BOOLEAN NOT NULL,
  guest_count INTEGER DEFAULT 1,
  adults INTEGER DEFAULT 1,
  children INTEGER DEFAULT 0,
  dietary_restrictions TEXT,
  message TEXT,
  ip_address TEXT,
  user_agent TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

#### Guestbook Table

```sql
CREATE TABLE guestbook (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  message TEXT NOT NULL,
  approved BOOLEAN DEFAULT 0,
  ip_address TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

#### Analytics Table

```sql
CREATE TABLE analytics (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  event_type TEXT NOT NULL, -- 'page_view', 'rsvp_submit', 'guestbook_submit'
  path TEXT,
  ip_address TEXT,
  user_agent TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### API Design

#### POST /api/rsvp

```typescript
Request:
{
  guestName: string
  email: string
  phone?: string
  attending: boolean
  guestCount: number
  adults: number
  children: number
  dietaryRestrictions?: string
  message?: string
}

Response (200):
{
  success: true
  message: "RSVP received successfully"
  id: number
}

Response (429):
{
  success: false
  error: "Rate limit exceeded. Try again in 1 hour."
}

Response (400):
{
  success: false
  error: "Validation failed"
  fields: { email: "Invalid email format" }
}
```

#### POST /api/guestbook

```typescript
Request:
{
  name: string
  message: string
}

Response (200):
{
  success: true
  message: "Message submitted for approval"
  id: number
}
```

#### GET /api/guestbook

```typescript
Response (200):
{
  messages: [
    {
      id: number
      name: string
      message: string
      createdAt: string
    }
  ]
}
```

### Security Requirements

1. **Rate Limiting (Cloudflare KV)**
   - 5 RSVP submissions per IP per hour
   - 10 guestbook submissions per IP per hour
   - Admin endpoints: 100 requests per IP per minute

2. **Input Validation**
   - Sanitize all text inputs (prevent XSS)
   - Email format validation
   - Phone number format validation
   - Message length limits (500 chars for RSVP, 200 for guestbook)

3. **Admin Protection**
   - Password-based auth (no complex user system)
   - HTTP-only cookies for session
   - CSRF protection via tokens
   - Environment variable for admin password

4. **Data Privacy**
   - No third-party trackers
   - Minimal analytics (first-party only)
   - Clear data retention policy
   - IP addresses hashed for storage

### Performance Budget

| Metric                   | Target | Max   |
| ------------------------ | ------ | ----- |
| JavaScript               | 30KB   | 50KB  |
| CSS                      | 10KB   | 20KB  |
| Images (per page)        | 200KB  | 500KB |
| Total Page Weight        | 500KB  | 1MB   |
| First Contentful Paint   | 1.5s   | 2s    |
| Largest Contentful Paint | 2.5s   | 3s    |
| Time to Interactive      | 3s     | 4s    |
| Lighthouse Score         | 95+    | 90+   |

### Image Optimization Strategy

1. **Upload to R2**
   - Original images in R2 bucket
   - Cloudflare Images for automatic optimization
2. **Delivery**
   - Serve WebP with JPEG fallback
   - Responsive images (srcset)
   - Lazy loading (native loading="lazy")
   - Blur-up placeholders (LQIP)
3. **Sizing**
   - Hero: 1920x1080 (desktop), 768x1024 (mobile)
   - Gallery thumbnails: 400x400
   - Story photos: 800x600

### Mobile-First Design

**Breakpoints:**

- Mobile: 320px - 640px (default)
- Tablet: 641px - 1024px
- Desktop: 1025px+

**Touch Targets:**

- Minimum 44x44px (Apple HIG)
- Sufficient spacing between interactive elements
- No hover-only interactions

**3G Performance:**

- Critical CSS inlined
- Fonts subset and preloaded
- Images lazy-loaded
- Service worker for offline

## Technical Architecture

### Project Structure

```
wedding-card/
├── src/
│   ├── components/
│   │   ├── Hero.tsx
│   │   ├── Story.tsx
│   │   ├── EventDetails.tsx
│   │   ├── RsvpForm.tsx
│   │   ├── Guestbook.tsx
│   │   ├── Gallery.tsx
│   │   └── Admin/
│   │       ├── Dashboard.tsx
│   │       ├── RsvpList.tsx
│   │       └── GuestbookModerator.tsx
│   ├── lib/
│   │   ├── validation.ts
│   │   ├── db.ts
│   │   └── rate-limit.ts
│   ├── routes/
│   │   ├── index.tsx (home)
│   │   └── admin.tsx (dashboard)
│   ├── styles/
│   │   └── global.css
│   └── app.tsx
├── functions/
│   ├── api/
│   │   ├── rsvp.ts (POST)
│   │   ├── guestbook.ts (POST/GET)
│   │   └── admin/
│   │       ├── rsvps.ts
│   │       └── moderate.ts
│   └── _middleware.ts (rate limiting, auth)
├── public/
│   ├── images/
│   └── manifest.json
├── migrations/
│   ├── 0001_create_rsvps.sql
│   ├── 0002_create_guestbook.sql
│   └── 0003_create_analytics.sql
├── wrangler.toml
├── package.json
├── tsconfig.json
├── vite.config.ts
└── tailwind.config.ts
```

### Environment Configuration

**wrangler.toml:**

```toml
name = "wedding-card"
compatibility_date = "2024-01-01"
pages_build_output_dir = "dist"

[env.production]
vars = { ENVIRONMENT = "production" }

[[d1_databases]]
binding = "DB"
database_name = "wedding-card-db"
database_id = "your-d1-id"

[[r2_buckets]]
binding = "IMAGES"
bucket_name = "wedding-card-images"

[[kv_namespaces]]
binding = "RATE_LIMIT"
id = "your-kv-id"

[vars]
ADMIN_PASSWORD_HASH = "your-hashed-password"
```

### Deployment Pipeline

1. **Local Development**

   ```bash
   pnpm install
   pnpm wrangler d1 migrations apply DB --local
   pnpm dev  # Vite + Wrangler
   ```

2. **Production Deployment**
   - Push to main branch
   - Cloudflare Pages auto-builds and deploys
   - Run migrations: `pnpm wrangler d1 migrations apply DB --remote`
   - Environment vars set in Pages dashboard

3. **Preview Deployments**
   - Every PR gets preview URL
   - Uses production D1 (consider separate preview DB)

### Cost Analysis (Cloudflare Free Tier)

| Service | Free Tier                     | Expected Usage                 | Cost |
| ------- | ----------------------------- | ------------------------------ | ---- |
| Pages   | Unlimited                     | 1 site                         | $0   |
| Workers | 100k req/day                  | <1k req/day                    | $0   |
| D1      | 5GB storage, 5M reads/day     | <100MB, <10k reads/day         | $0   |
| R2      | 10GB storage, 1M Class A ops  | <1GB, <1k ops                  | $0   |
| KV      | 100k reads/day, 1k writes/day | <1k reads/day, <100 writes/day | $0   |

**Total Cost: $0/month** (stays within free tier easily)

## Development Roadmap

### Week 1: Foundation

- [ ] Project setup (Vite + SolidJS + Cloudflare)
- [ ] D1 database setup and migrations
- [ ] Landing page with hero section
- [ ] Event details component
- [ ] Basic routing

### Week 2: Core Features

- [ ] RSVP form with validation
- [ ] RSVP API endpoint (Workers)
- [ ] Rate limiting (KV)
- [ ] Mobile responsive design
- [ ] Image optimization setup (R2)

### Week 3: Enhanced Features

- [ ] Guestbook component
- [ ] Guestbook API and moderation
- [ ] Story section with timeline
- [ ] Gallery with lazy loading
- [ ] Performance optimization

### Week 4: Polish & Launch

- [ ] Admin dashboard
- [ ] RSVP list and export
- [ ] Email notifications (optional)
- [ ] Analytics tracking
- [ ] Cross-browser testing
- [ ] DNS setup and launch

## Testing Strategy

### Manual Testing Checklist

- [ ] RSVP form validation (all fields)
- [ ] RSVP submission success/error states
- [ ] Rate limiting works (try 6 submissions)
- [ ] Guestbook submission and approval
- [ ] Mobile responsiveness (Chrome DevTools)
- [ ] 3G network simulation
- [ ] Image lazy loading
- [ ] Admin password protection
- [ ] Cross-browser (Chrome, Safari, Firefox)
- [ ] Accessibility (keyboard nav, screen reader)

### Performance Testing

- [ ] Lighthouse audit (95+ score)
- [ ] WebPageTest (3G simulation)
- [ ] Bundle size analysis
- [ ] Image optimization verification

## Success Metrics

### Technical Metrics

- Lighthouse score: 95+
- Page load <3s on 3G
- Zero runtime errors
- 99.9% uptime (Cloudflare SLA)

### Business Metrics

- RSVP conversion rate: 70%+
- Mobile traffic: 80%+
- Guestbook participation: 30%+
- Zero spam submissions

## Maintenance Plan

### During Event Period

- Monitor analytics daily
- Moderate guestbook 2x daily
- Check RSVP submissions
- Respond to issues within 24h

### Post-Event

- Export all data (RSVPs, guestbook)
- Archive site (keep static version)
- Delete database after 6 months
- Optional: Open-source the codebase

## Brutal Recommendations

### Do This First

1. Start with static HTML + CSS prototype (2 days)
2. Get design approval before adding SolidJS
3. Build RSVP form only, validate concept
4. Add features incrementally based on feedback

### Skip These Initially

- Photo gallery (use Instagram link instead)
- Complex animations (CSS-only is fine)
- Admin dashboard (use D1 console directly)
- Email notifications (check DB manually)

### Realistic Timeline

- **MVP (landing + RSVP):** 2 weeks part-time
- **Full features:** 4-6 weeks part-time
- **Polish and testing:** 1-2 weeks

### When to Use a Template Instead

- Wedding is <6 weeks away
- No technical skills/interest in learning
- Need complex features (live streaming, payments)
- Want professional design out of the box

## Next Steps

1. **Approve this spec** - Confirm requirements align with your needs
2. **Design mockups** - Create visual design before coding
3. **Create tasks** - Break down into implementable chunks
4. **Start coding** - Begin with MVP foundation

---

**Final Brutal Truth:** This is a significant project. Make sure you have:

- 4-6 weeks before wedding for testing
- 10-15 hours/week to dedicate
- Basic TypeScript/React knowledge (SolidJS is similar)
- Cloudflare account set up

If any of these are missing, seriously consider a template service.

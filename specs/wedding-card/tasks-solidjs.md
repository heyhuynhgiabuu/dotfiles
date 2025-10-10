# Wedding Card - SolidJS + Cloudflare Tasks

## Phase 1: Setup & Learning (Week 1-2)

### 1.1 SolidJS Learning

- [ ] Complete SolidJS tutorial (https://www.solidjs.com/tutorial)
- [ ] Build practice todo app with signals and effects
- [ ] Read SolidJS docs on reactivity model
- [ ] Understand key differences from React

**Time:** 4-6 hours
**Output:** Familiarity with SolidJS patterns

### 1.2 Cloudflare Account Setup

- [ ] Create Cloudflare account
- [ ] Install Wrangler CLI: `npm install -g wrangler`
- [ ] Login with `wrangler login`
- [ ] Verify account access

**Time:** 30 minutes
**Output:** Working Cloudflare account

### 1.3 Project Initialization

- [ ] Run `pnpm create vite wedding-card --template solid-ts`
- [ ] Install base dependencies (TailwindCSS, router, types)
- [ ] Set up project folder structure
- [ ] Initialize Git repository
- [ ] Create `.gitignore` for Cloudflare secrets

**Time:** 1 hour
**Output:** Clean project structure

### 1.4 Cloudflare Configuration

- [ ] Create `wrangler.toml` configuration
- [ ] Set up Cloudflare Pages project
- [ ] Connect Git repository to Pages
- [ ] Configure build settings (Vite output)
- [ ] Test automatic deployment

**Time:** 1-2 hours
**Output:** Auto-deploy pipeline working

### 1.5 Basic Landing Page

- [ ] Create `Hero` component (couple names, date)
- [ ] Add countdown timer component
- [ ] Set up TailwindCSS theming
- [ ] Make mobile responsive
- [ ] Deploy to Cloudflare Pages

**Time:** 4-6 hours
**Output:** Live landing page on Cloudflare URL

## Phase 2: RSVP System (Week 3-4)

### 2.1 D1 Database Setup

- [ ] Create D1 database with `wrangler d1 create wedding-card-db`
- [ ] Add D1 binding to `wrangler.toml`
- [ ] Create migration file `0001_create_rsvps.sql`
- [ ] Run migration locally: `wrangler d1 migrations apply DB --local`
- [ ] Run migration remote: `wrangler d1 migrations apply DB --remote`

**Time:** 1-2 hours
**Output:** D1 database ready for use

### 2.2 RSVP Form Component

- [ ] Create `RsvpForm.tsx` with SolidJS signals
- [ ] Add form fields (name, email, attending, guest count)
- [ ] Implement client-side validation
- [ ] Add error/success states
- [ ] Style with TailwindCSS

**Time:** 3-4 hours
**Output:** Functional RSVP form UI

### 2.3 Workers API Endpoint

- [ ] Create `functions/api/rsvp.ts`
- [ ] Set up D1 database binding
- [ ] Implement POST handler for RSVP
- [ ] Add input validation (server-side)
- [ ] Handle errors gracefully
- [ ] Return JSON responses

**Time:** 2-3 hours
**Output:** Working API endpoint

### 2.4 Rate Limiting

- [ ] Create KV namespace: `wrangler kv:namespace create RATE_LIMIT`
- [ ] Add KV binding to `wrangler.toml`
- [ ] Implement rate limit check (5 submissions/hour/IP)
- [ ] Test rate limiting behavior
- [ ] Add rate limit error messages

**Time:** 2 hours
**Output:** Protected API endpoint

### 2.5 Integration & Testing

- [ ] Connect form to API endpoint
- [ ] Test successful submission
- [ ] Test validation errors
- [ ] Test rate limiting
- [ ] Verify database entries in D1 console
- [ ] Test on mobile devices

**Time:** 2-3 hours
**Output:** End-to-end RSVP flow working

## Phase 3: Content Sections (Week 5-6)

### 3.1 Event Details Component

- [ ] Create `EventDetails.tsx` component
- [ ] Add date, time, venue information
- [ ] Create schedule timeline
- [ ] Add dress code section
- [ ] Make responsive

**Time:** 2-3 hours
**Output:** Complete event details section

### 3.2 Maps Integration

- [ ] Get Google Maps embed code
- [ ] Create `MapEmbed.tsx` component
- [ ] Add directions link
- [ ] Test on mobile
- [ ] Add loading state

**Time:** 1-2 hours
**Output:** Interactive map section

### 3.3 Story Section

- [ ] Create `Story.tsx` component
- [ ] Build timeline component
- [ ] Add "How We Met" content
- [ ] Add engagement story
- [ ] Style with animations (CSS only)

**Time:** 3-4 hours
**Output:** Story timeline section

### 3.4 Image Optimization Setup

- [ ] Create R2 bucket: `wrangler r2 bucket create wedding-card-images`
- [ ] Upload images to R2
- [ ] Add R2 binding to `wrangler.toml`
- [ ] Create image component with lazy loading
- [ ] Implement blur-up placeholders (LQIP)
- [ ] Test WebP/JPEG fallback

**Time:** 3-4 hours
**Output:** Optimized image delivery

### 3.5 Performance Optimization

- [ ] Run Lighthouse audit
- [ ] Optimize bundle size (check with `vite-bundle-visualizer`)
- [ ] Add service worker for offline
- [ ] Test on 3G network (Chrome DevTools)
- [ ] Fix performance issues to hit 95+ score

**Time:** 2-3 hours
**Output:** Lighthouse score 95+

## Phase 4: Guestbook (Week 7-8)

### 4.1 Guestbook Database

- [ ] Create migration `0002_create_guestbook.sql`
- [ ] Run migration locally and remotely
- [ ] Add approved column for moderation

**Time:** 30 minutes
**Output:** Guestbook table ready

### 4.2 Guestbook Submission

- [ ] Create `GuestbookForm.tsx` component
- [ ] Add name and message fields
- [ ] Create API endpoint `functions/api/guestbook.ts` (POST)
- [ ] Implement rate limiting (10 submissions/hour)
- [ ] Test submission flow

**Time:** 2-3 hours
**Output:** Guestbook submission working

### 4.3 Display Messages

- [ ] Create `GuestbookList.tsx` component
- [ ] Create GET endpoint for approved messages
- [ ] Display messages with pagination
- [ ] Add real-time polling (optional)
- [ ] Style message cards

**Time:** 2-3 hours
**Output:** Guestbook display working

### 4.4 Moderation System

- [ ] Create admin route `/admin/guestbook`
- [ ] Build moderation UI component
- [ ] Create approve/reject API endpoints
- [ ] Test moderation workflow
- [ ] Add bulk approve/reject

**Time:** 3-4 hours
**Output:** Guestbook moderation working

## Phase 5: Admin Dashboard (Week 9-10)

### 5.1 Admin Authentication

- [ ] Create admin password hash
- [ ] Store password in environment variable
- [ ] Create login page `/admin/login`
- [ ] Implement session with HTTP-only cookies
- [ ] Add logout functionality
- [ ] Protect admin routes

**Time:** 3-4 hours
**Output:** Password-protected admin area

### 5.2 RSVP Management

- [ ] Create `/admin/rsvps` route
- [ ] Build RSVP list component
- [ ] Add filtering (attending/not attending)
- [ ] Add sorting (date, name)
- [ ] Implement CSV export
- [ ] Show total counts

**Time:** 3-4 hours
**Output:** RSVP management dashboard

### 5.3 Analytics Dashboard

- [ ] Create analytics table migration
- [ ] Track page views in Workers
- [ ] Create `/admin/dashboard` route
- [ ] Display key metrics (views, RSVPs, conversion rate)
- [ ] Add simple charts (optional, use Chart.js)

**Time:** 3-4 hours
**Output:** Analytics dashboard

### 5.4 Admin UI Polish

- [ ] Create admin layout component
- [ ] Add navigation menu
- [ ] Style with TailwindCSS
- [ ] Make mobile responsive
- [ ] Test all admin functions

**Time:** 2-3 hours
**Output:** Polished admin interface

## Phase 6: Additional Features (Week 11-12)

### 6.1 Photo Gallery

- [ ] Create `Gallery.tsx` component
- [ ] Upload photos to R2
- [ ] Implement grid layout
- [ ] Add lightbox viewer (use SolidJS library)
- [ ] Add lazy loading
- [ ] Optimize image sizes

**Time:** 4-5 hours
**Output:** Photo gallery section

### 6.2 Schedule Section

- [ ] Create `Schedule.tsx` component
- [ ] Add ceremony timeline
- [ ] Add reception timeline
- [ ] Style with timeline visualization
- [ ] Make responsive

**Time:** 2-3 hours
**Output:** Event schedule section

### 6.3 Gift Registry

- [ ] Create `Registry.tsx` component
- [ ] Add registry links (Amazon, Target, etc.)
- [ ] Add cash gift instructions
- [ ] Add bank details (if applicable)
- [ ] Style cards for each option

**Time:** 1-2 hours
**Output:** Gift registry section

### 6.4 Email Notifications (Optional)

- [ ] Set up email service (Resend, SendGrid, or Cloudflare Email)
- [ ] Create email templates
- [ ] Send RSVP confirmation to guest
- [ ] Send RSVP notification to couple
- [ ] Test email delivery

**Time:** 3-4 hours
**Output:** Automated email notifications

## Phase 7: Testing & Polish (Week 13-14)

### 7.1 Cross-Browser Testing

- [ ] Test on Chrome (desktop + mobile)
- [ ] Test on Safari (desktop + mobile)
- [ ] Test on Firefox
- [ ] Test on Edge
- [ ] Fix browser-specific issues

**Time:** 2-3 hours
**Output:** Works on all major browsers

### 7.2 Mobile Testing

- [ ] Test on real iOS device
- [ ] Test on real Android device
- [ ] Test on various screen sizes
- [ ] Fix touch interaction issues
- [ ] Verify offline functionality

**Time:** 2-3 hours
**Output:** Excellent mobile experience

### 7.3 Performance Audit

- [ ] Run Lighthouse audit (aim for 95+)
- [ ] Check bundle size (<50KB JS)
- [ ] Test on 3G network simulation
- [ ] Optimize images further if needed
- [ ] Add resource hints (preload, prefetch)

**Time:** 2-3 hours
**Output:** Optimized performance

### 7.4 Accessibility Testing

- [ ] Test keyboard navigation
- [ ] Test with screen reader (VoiceOver/NVDA)
- [ ] Check color contrast ratios
- [ ] Add ARIA labels where needed
- [ ] Fix accessibility issues

**Time:** 2-3 hours
**Output:** WCAG 2.1 AA compliant

### 7.5 Security Review

- [ ] Audit SQL queries for injection
- [ ] Verify rate limiting works
- [ ] Check admin authentication
- [ ] Sanitize all user inputs
- [ ] Review CORS settings
- [ ] Test CSRF protection

**Time:** 2 hours
**Output:** Security hardened

### 7.6 Bug Fixes

- [ ] Create bug tracking list
- [ ] Fix all critical bugs
- [ ] Fix high-priority bugs
- [ ] Test fixes don't break other features
- [ ] Final regression testing

**Time:** 4-6 hours
**Output:** Zero critical bugs

## Phase 8: Launch (Week 15-16)

### 8.1 Content Finalization

- [ ] Add all final photos
- [ ] Write all copy text
- [ ] Proofread all content
- [ ] Get partner approval
- [ ] Add final event details

**Time:** 2-3 hours
**Output:** Complete, accurate content

### 8.2 Domain Setup

- [ ] Purchase custom domain (optional)
- [ ] Configure DNS in Cloudflare
- [ ] Set up SSL certificate (auto with Cloudflare)
- [ ] Test custom domain
- [ ] Set up redirects if needed

**Time:** 1-2 hours
**Output:** Custom domain working

### 8.3 SEO & Social

- [ ] Add meta tags (title, description)
- [ ] Add Open Graph tags (Facebook/WhatsApp preview)
- [ ] Add Twitter Card tags
- [ ] Create social sharing image
- [ ] Generate sitemap
- [ ] Test social previews

**Time:** 1-2 hours
**Output:** Great social media previews

### 8.4 Soft Launch

- [ ] Deploy to production
- [ ] Test all features in production
- [ ] Share with close friends (5-10 people)
- [ ] Gather feedback
- [ ] Fix any issues found

**Time:** 2-3 hours
**Output:** Validated production deployment

### 8.5 Public Launch

- [ ] Final testing checklist
- [ ] Make any last-minute changes
- [ ] Announce to all guests
- [ ] Monitor for issues
- [ ] Respond to questions

**Time:** 1-2 hours
**Output:** Live wedding card shared with guests

### 8.6 Monitoring & Maintenance

- [ ] Check analytics daily
- [ ] Moderate guestbook regularly
- [ ] Monitor RSVP submissions
- [ ] Respond to issues within 24h
- [ ] Keep track of guest questions

**Time:** 15-30 mins/day
**Output:** Smooth guest experience

## Total Time Estimate

| Phase               | Min Hours | Max Hours |
| ------------------- | --------- | --------- |
| Setup & Learning    | 12        | 16        |
| RSVP System         | 10        | 14        |
| Content Sections    | 11        | 16        |
| Guestbook           | 8         | 11        |
| Admin Dashboard     | 11        | 15        |
| Additional Features | 10        | 14        |
| Testing & Polish    | 14        | 20        |
| Launch              | 7         | 12        |
| **Total**           | **83**    | **118**   |

**Your Available Time:** 224-448 hours (14-28 hrs/week × 16 weeks)
**Buffer:** 106-365 hours for learning and iteration

## Quick Start Checklist (Day 1)

```bash
# 1. Install prerequisites
npm install -g wrangler pnpm

# 2. Login to Cloudflare
wrangler login

# 3. Create project
pnpm create vite wedding-card --template solid-ts
cd wedding-card

# 4. Install dependencies
pnpm add -D tailwindcss postcss autoprefixer @cloudflare/workers-types
pnpm add @solidjs/router

# 5. Initialize Tailwind
pnpm dlx tailwindcss init -p

# 6. Create wrangler.toml
# (See implementation-guide.md for config)

# 7. Start dev server
pnpm dev
```

## Progress Tracking

Mark tasks as you complete them:

- ⚪ Not Started
- ⏳ In Progress
- ✓ Complete

Update weekly to stay on track!

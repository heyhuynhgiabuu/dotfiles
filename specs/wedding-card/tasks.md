# Online Wedding Card - Implementation Tasks

## Week 1: Foundation & Core Features

### Day 1-2: Project Setup

- [ ] **Setup monorepo structure**
  - Initialize Turborepo workspace
  - Create `apps/api` and `apps/web` directories
  - Setup `packages/types` for shared types
  - Configure `turbo.json` for build pipeline
- [ ] **Backend setup (Hono + Cloudflare Workers)**
  - Install dependencies: `hono`, `drizzle-orm`, `@cloudflare/workers-types`
  - Create `wrangler.toml` configuration
  - Setup D1 database: `wrangler d1 create wedding-card-db`
  - Configure Drizzle ORM with D1
  - Create initial schema (`guests`, `photos`, `admins`)
  - Run migrations: `wrangler d1 migrations apply`

- [ ] **Frontend setup (TanStack Start)**
  - Initialize TanStack Start app
  - Install dependencies: `tailwindcss`, `shadcn/ui`, `@tanstack/react-query`
  - Configure Tailwind with wedding theme colors
  - Setup `app.config.ts` for Cloudflare Pages
  - Install shadcn/ui components: button, form, input, card, dialog

- [ ] **Setup authentication (Clerk)**
  - Create Clerk application
  - Install `@clerk/clerk-react` in frontend
  - Configure Clerk provider in root layout
  - Setup protected admin routes
  - Create middleware for JWT validation in backend

### Day 3-4: RSVP System

- [ ] **Backend: RSVP API**
  - Create `/api/rsvp` POST endpoint
  - Implement Zod validation schema
  - Generate unique QR code (using `qrcode` package)
  - Store guest data in D1 database
  - Send confirmation email via Resend
  - Add rate limiting (10 requests/hour per IP)

- [ ] **Frontend: RSVP Form**
  - Create `/rsvp` route
  - Build form with React Hook Form + Zod
  - Add fields: name, email, phone, num guests, dietary restrictions
  - Implement client-side validation
  - Show success modal with QR code download
  - Add form error handling

### Day 5-7: Landing Page & Gallery

- [ ] **Frontend: Landing Page**
  - Create hero section with cover image
  - Build countdown timer component
  - Add story timeline section
  - Create event details section (ceremony, reception)
  - Embed Google Maps for venue
  - Add smooth scroll navigation

- [ ] **Backend: Photo Upload**
  - Setup R2 bucket: `wrangler r2 bucket create wedding-card-photos`
  - Create `/api/photos/upload` endpoint
  - Implement image optimization (resize, WebP conversion)
  - Generate thumbnails (300x300)
  - Store metadata in D1 `photos` table

- [ ] **Frontend: Photo Gallery**
  - Create `/gallery` route
  - Build grid layout with lazy loading
  - Implement lightbox view
  - Add photo upload button for guests
  - Show approved photos only (public view)

## Week 2: Admin Dashboard & Polish

### Day 8-9: Admin Dashboard

- [ ] **Backend: Admin APIs**
  - Create `/api/admin/guests` GET endpoint (protected)
  - Add Clerk JWT validation middleware
  - Implement guest filtering (by status)
  - Create `/api/admin/guests/:id` PATCH endpoint
  - Build CSV export functionality

- [ ] **Frontend: Admin Dashboard**
  - Create `/admin` layout with sidebar
  - Build dashboard with stats cards
  - Show recent RSVPs table
  - Add quick action buttons

- [ ] **Frontend: Guest Management**
  - Create `/admin/guests` page
  - Build DataTable with TanStack Table
  - Add search and filter functionality
  - Implement edit guest modal
  - Add CSV export button

### Day 10-11: Check-in System

- [ ] **Backend: Check-in API**
  - Create `/api/admin/checkin/:id` POST endpoint
  - Implement QR code validation
  - Update `checked_in` status in database
  - Add check-in timestamp

- [ ] **Frontend: Check-in Interface**
  - Create `/admin/checkin` page
  - Build QR scanner component (using `@zxing/library`)
  - Add manual search functionality
  - Show guest details on scan
  - One-click check-in button
  - Real-time check-in count

### Day 12-13: Photo Management

- [ ] **Backend: Photo Approval**
  - Create `/api/admin/photos` GET endpoint
  - Add `/api/admin/photos/:id/approve` PATCH endpoint
  - Implement `/api/admin/photos/:id` DELETE endpoint
  - Update approved status in database

- [ ] **Frontend: Photo Admin**
  - Create `/admin/photos` page
  - Display all uploaded photos (grid view)
  - Add approve/reject buttons
  - Implement delete confirmation modal
  - Show approval status badges

### Day 14: Testing & Deployment

- [ ] **Testing**
  - Test RSVP flow end-to-end
  - Verify email delivery (Resend)
  - Test admin authentication
  - Check mobile responsiveness
  - Verify QR code generation/scanning
  - Test rate limiting

- [ ] **Deployment**
  - Configure GitHub Actions workflow
  - Set environment variables in Cloudflare
  - Deploy backend: `wrangler deploy`
  - Deploy frontend: `wrangler pages deploy`
  - Setup custom domain (optional)
  - Configure DNS records

- [ ] **Production Checks**
  - Verify D1 database connection
  - Test R2 bucket access
  - Check Clerk authentication
  - Verify Resend email delivery
  - Monitor Cloudflare logs

## Week 3: Polish & Launch

### Day 15-16: UI/UX Polish

- [ ] **Design Refinement**
  - Add loading states to all forms
  - Improve error messages
  - Add skeleton loaders
  - Implement toast notifications
  - Add micro-animations (Framer Motion)

- [ ] **Accessibility**
  - Add ARIA labels to all interactive elements
  - Test keyboard navigation
  - Verify color contrast (4.5:1)
  - Test with screen reader
  - Add alt text to all images

### Day 17-18: Performance Optimization

- [ ] **Frontend Optimization**
  - Enable code splitting
  - Optimize images (WebP, lazy loading)
  - Add service worker (offline support)
  - Preload critical assets
  - Run Lighthouse audit (target 95+)

- [ ] **Backend Optimization**
  - Add response caching (Cloudflare Cache API)
  - Optimize D1 queries (add indexes)
  - Enable R2 presigned URLs
  - Configure CORS headers

### Day 19-20: Content & Launch Prep

- [ ] **Content Population**
  - Upload hero image
  - Add couple story and photos
  - Fill event details
  - Add venue information
  - Seed initial admin user

- [ ] **Launch Checklist**
  - Test all features in production
  - Send test RSVPs
  - Verify analytics tracking
  - Setup monitoring alerts
  - Create user documentation
  - Prepare launch announcement

### Day 21: Launch & Monitoring

- [ ] **Go Live**
  - Announce to guests via email/social media
  - Monitor server logs
  - Track RSVP submissions
  - Respond to user feedback
  - Fix any critical bugs

## Optional Enhancements (Post-Launch)

### Nice to Have

- [ ] **Multi-language Support**
  - Add i18n with `react-i18next`
  - Translate to Vietnamese/English
  - Add language switcher

- [ ] **Enhanced Gallery**
  - Add photo categories/albums
  - Implement photo comments
  - Add like/favorite functionality
  - Create slideshow mode

- [ ] **Guest Features**
  - Add digital guestbook
  - Create "Will You Be My Bridesmaid?" cards
  - Add song request feature
  - Build seating chart viewer

- [ ] **Advanced Admin**
  - Add guest import (CSV)
  - Create email blast tool
  - Build printable guest list
  - Add analytics dashboard

## Critical Path (MVP - 14 Days)

**Must Have:**

1. ✅ RSVP form with email confirmation
2. ✅ Landing page with event details
3. ✅ Admin dashboard for guest management
4. ✅ QR code check-in system
5. ✅ Photo gallery (view only)

**Can Defer:**

- Photo upload (add post-wedding)
- Multi-language support
- Advanced analytics
- Seating chart

## Dependencies & Prerequisites

### External Services (Setup First)

1. **Cloudflare Account** (free tier)
   - Create Workers & Pages project
   - Setup D1 database
   - Create R2 bucket

2. **Clerk Account** (free tier)
   - Create application
   - Get API keys
   - Configure allowed domains

3. **Resend Account** (free tier)
   - Verify domain
   - Get API key
   - Create email templates

4. **GitHub Account**
   - Create repository
   - Setup GitHub Actions
   - Configure secrets

### Development Tools

- Node.js v22+ (nvm managed)
- Bun (for faster installs)
- Wrangler CLI (`npm i -g wrangler`)
- Git

## Risk Mitigation

### Technical Risks

1. **Cloudflare free tier limits**
   - Monitor usage daily
   - Plan upgrade if needed
   - Set usage alerts

2. **Image storage costs**
   - Limit photo uploads per user
   - Compress images aggressively
   - Delete old photos post-event

3. **Email delivery issues**
   - Test Resend thoroughly
   - Have backup (Gmail SMTP)
   - Monitor bounce rate

### Project Risks

1. **Timeline slip**
   - Focus on MVP first
   - Defer nice-to-haves
   - Work in parallel where possible

2. **Feature creep**
   - Stick to spec document
   - Say no to new requests
   - Plan v2 after launch

## Success Criteria

### Technical Metrics

- ✅ Lighthouse score 95+
- ✅ Load time < 2s
- ✅ Zero downtime during event
- ✅ 100% RSVP email delivery

### Business Metrics

- ✅ 80%+ RSVP completion rate
- ✅ < 5% user support requests
- ✅ Smooth check-in on wedding day
- ✅ Happy couple! 💑

# Online Wedding Card - Requirements Specification

## Project Overview

**Goal:** Digital wedding invitation system with RSVP, guest management, and photo gallery
**Stack:** Cloudflare (Workers + Pages + D1 + R2)
**Timeline:** 2-3 weeks MVP
**Cost:** $0/month (Cloudflare free tier)

## Core Requirements

### 1. Landing Page (Public)

- **Hero Section**
  - Couple names
  - Wedding date & countdown
  - Venue location (embedded map)
  - Cover photo (hero image)
- **Story Section**
  - How we met
  - Timeline of relationship
  - Photo carousel
- **Event Details**
  - Ceremony time & location
  - Reception details
  - Dress code
  - Accommodation suggestions
- **Gallery**
  - Pre-wedding photos
  - Engagement photos
  - Lazy-loaded images from R2

### 2. RSVP System

- **Guest Form**
  - Full name (required)
  - Email (required)
  - Phone (optional)
  - Number of guests (dropdown: 1-5)
  - Dietary restrictions (textarea)
  - Special requests (textarea)
  - Attendance confirmation (Yes/No/Maybe)
- **Validation**
  - Email format check
  - Phone number validation
  - Prevent duplicate submissions (email-based)
- **Confirmation**
  - Success message
  - Email confirmation sent
  - QR code for check-in

### 3. Admin Dashboard (Protected)

- **Authentication**
  - Clerk auth (Google/Email)
  - Admin-only access
- **Guest Management**
  - List all RSVPs (table view)
  - Filter by attendance status
  - Search by name/email
  - Export to CSV
  - Manual guest entry
- **Analytics**
  - Total confirmed guests
  - Pending responses
  - Dietary restrictions summary
  - Check-in status (day of event)
- **Content Management**
  - Upload photos to gallery
  - Edit event details
  - Update story content

### 4. Guest Check-in (Day of Event)

- **QR Scanner**
  - Scan guest QR codes
  - Mark as checked-in
  - Show guest details
  - Table assignment
- **Manual Check-in**
  - Search by name
  - One-click check-in

### 5. Post-Wedding Features

- **Photo Sharing**
  - Guests upload photos
  - Approval workflow (admin)
  - Public gallery
- **Thank You Messages**
  - Automated thank-you emails
  - Personalized messages

## Technical Requirements

### Frontend (TanStack Start)

- **Framework:** TanStack Start (React-based)
- **Styling:** Tailwind CSS + shadcn/ui
- **Animations:** Framer Motion
- **Forms:** React Hook Form + Zod
- **State:** TanStack Query
- **Deploy:** Cloudflare Pages

### Backend (Hono)

- **Framework:** Hono
- **Runtime:** Cloudflare Workers
- **Database:** Cloudflare D1 (SQLite)
- **Storage:** Cloudflare R2 (images/files)
- **Auth:** Clerk (token-based)
- **Email:** Resend (transactional emails)

### Database Schema (D1)

```sql
-- Guests table
CREATE TABLE guests (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  phone TEXT,
  num_guests INTEGER DEFAULT 1,
  dietary_restrictions TEXT,
  special_requests TEXT,
  attendance_status TEXT CHECK(attendance_status IN ('yes', 'no', 'maybe')),
  checked_in INTEGER DEFAULT 0,
  qr_code TEXT UNIQUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Photos table
CREATE TABLE photos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  r2_key TEXT NOT NULL,
  uploaded_by TEXT,
  approved INTEGER DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Admin users table
CREATE TABLE admins (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  clerk_user_id TEXT UNIQUE NOT NULL,
  email TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

## Non-Functional Requirements

### Performance

- **Lighthouse Score:** 95+ on all metrics
- **Load Time:** < 2s on 4G
- **Image Optimization:** WebP format, responsive images
- **CDN:** Cloudflare global edge network

### Security

- **Auth:** Clerk with JWT validation
- **CORS:** Whitelist domains only
- **Rate Limiting:** 10 RSVP/hour per IP
- **Input Validation:** Zod schemas on frontend + backend
- **SQL Injection:** Drizzle ORM (parameterized queries)

### Mobile Responsiveness

- **Breakpoints:** Mobile-first (375px → 1440px)
- **Touch Targets:** Min 44x44px
- **Forms:** Native mobile keyboards
- **Gallery:** Swipe gestures

### Accessibility

- **WCAG 2.1:** AA compliance
- **Semantic HTML:** Proper heading hierarchy
- **ARIA Labels:** Form inputs, buttons
- **Keyboard Navigation:** All features accessible
- **Color Contrast:** 4.5:1 minimum

## Out of Scope (V1)

- ❌ Live streaming
- ❌ Gift registry integration
- ❌ Multi-language support
- ❌ Video uploads
- ❌ Guest messaging/chat
- ❌ Seating chart tool

## Success Metrics

- **RSVP Completion:** 80%+ of invited guests
- **Load Time:** < 2s average
- **Mobile Traffic:** 70%+ (wedding guests use phones)
- **Zero Downtime:** 99.9% uptime
- **Admin Efficiency:** < 2 min to check-in guest

## Constraints

- **Budget:** $0/month (must use free tier)
- **Timeline:** 2-3 weeks to MVP
- **Team Size:** 1 developer
- **Design:** Use existing UI kits (shadcn/ui)

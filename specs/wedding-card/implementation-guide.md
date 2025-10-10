# Wedding Card Implementation Guide

## Timeline: 16 Weeks (Plenty of Buffer)

**Your Capacity:** 14-28 hours/week
**Project Needs:** 10-15 hours/week
**Buffer:** 30-50% extra time for learning + polish

## Learning Path: React → SolidJS

### Key Differences (30 minutes to learn)

| Concept    | React                   | SolidJS                                    |
| ---------- | ----------------------- | ------------------------------------------ |
| Reactivity | Virtual DOM, re-renders | Fine-grained reactivity, no re-renders     |
| State      | `useState`              | `createSignal`                             |
| Effects    | `useEffect`             | `createEffect`                             |
| Memos      | `useMemo`               | `createMemo`                               |
| Components | Can re-render           | Run once, reactive primitives update       |
| Props      | Can be destructured     | **Cannot destructure** (breaks reactivity) |

### Example: Counter

**React:**

```tsx
function Counter() {
  const [count, setCount] = useState(0);

  useEffect(() => {
    console.log("Count changed:", count);
  }, [count]);

  return <button onClick={() => setCount(count + 1)}>{count}</button>;
}
```

**SolidJS:**

```tsx
function Counter() {
  const [count, setCount] = createSignal(0);

  createEffect(() => {
    console.log("Count changed:", count()); // Call like a function
  });

  return <button onClick={() => setCount(count() + 1)}>{count()}</button>;
}
```

### Critical SolidJS Rules

1. **Signals are functions:** `count()` not `count`
2. **Don't destructure props:** `props.name` not `const { name } = props`
3. **Components run once:** No re-renders, only reactive updates
4. **JSX is compiled:** Not runtime like React

### Learning Resources (1-2 days)

1. **SolidJS Tutorial** (2 hours): https://www.solidjs.com/tutorial
2. **SolidJS Docs** (1 hour): https://www.solidjs.com/docs/latest
3. **Build a Todo App** (2 hours): Practice signals, effects, components

## Week-by-Week Plan

### Week 1-2: Foundation + SolidJS Learning (20 hours)

**Goals:**

- Complete SolidJS tutorial
- Set up project structure
- Get local dev environment working
- Deploy "Hello World" to Cloudflare Pages

**Tasks:**

1. Complete SolidJS tutorial and todo app
2. Create Cloudflare account
3. Install Wrangler CLI: `npm install -g wrangler`
4. Initialize project with Vite + SolidJS
5. Set up Cloudflare Pages deployment
6. Configure TailwindCSS
7. Build basic landing page (static HTML/CSS first)
8. Convert to SolidJS components

**Deliverable:** Static landing page deployed to Cloudflare Pages

### Week 3-4: RSVP System (20 hours)

**Goals:**

- D1 database setup
- RSVP form with validation
- Workers API endpoint
- Form submission working

**Tasks:**

1. Set up D1 database (local + remote)
2. Create RSVP table migration
3. Build RSVP form component
4. Implement form validation (client-side)
5. Create Workers API endpoint for RSVP
6. Add rate limiting with KV
7. Connect form to API
8. Test submission flow

**Deliverable:** Working RSVP system with database storage

### Week 5-6: Content & Design (16 hours)

**Goals:**

- Event details section
- Story/timeline section
- Maps integration
- Image optimization

**Tasks:**

1. Create EventDetails component
2. Add Google Maps embed
3. Build Story component with timeline
4. Set up R2 bucket for images
5. Implement image lazy loading
6. Add blur-up placeholders
7. Optimize for mobile
8. Performance testing (Lighthouse)

**Deliverable:** Complete content sections with optimized images

### Week 7-8: Guestbook (12 hours)

**Goals:**

- Guestbook submission
- Moderation system
- Display approved messages

**Tasks:**

1. Create Guestbook table
2. Build submission form
3. Create API endpoints (POST/GET)
4. Display approved messages
5. Add pagination
6. Build moderation UI
7. Implement approve/reject functionality

**Deliverable:** Working guestbook with moderation

### Week 9-10: Admin Dashboard (16 hours)

**Goals:**

- Admin authentication
- RSVP management
- Analytics view

**Tasks:**

1. Implement admin password auth
2. Create admin layout
3. Build RSVP list view
4. Add CSV export
5. Create analytics dashboard
6. Add guestbook moderation UI
7. Test admin workflows

**Deliverable:** Functional admin dashboard

### Week 11-12: Polish & Features (16 hours)

**Goals:**

- Photo gallery
- Schedule section
- Gift registry links
- Email notifications

**Tasks:**

1. Build photo gallery with lightbox
2. Create schedule/agenda component
3. Add gift registry section
4. Set up email notifications (optional)
5. Add countdown timer
6. Implement share functionality
7. Cross-browser testing

**Deliverable:** All features complete

### Week 13-14: Testing & Optimization (12 hours)

**Goals:**

- Performance optimization
- Cross-device testing
- Bug fixes
- Security audit

**Tasks:**

1. Lighthouse audits (target 95+)
2. Mobile testing (real devices)
3. 3G network simulation
4. Accessibility testing
5. Security review
6. Load testing
7. Fix all critical bugs
8. Optimize bundle size

**Deliverable:** Production-ready site

### Week 15-16: Final Polish & Launch (8 hours)

**Goals:**

- Content finalization
- DNS setup
- Soft launch
- Monitoring

**Tasks:**

1. Add final content (photos, text)
2. Set up custom domain
3. Configure SSL
4. Create sitemap
5. Add meta tags (SEO, social sharing)
6. Soft launch to small group
7. Gather feedback
8. Make final adjustments
9. Public launch

**Deliverable:** Live wedding card with custom domain

## Development Setup (Day 1)

### Prerequisites

```bash
# Install Node.js (if not already)
# Install pnpm
npm install -g pnpm

# Install Wrangler
npm install -g wrangler

# Login to Cloudflare
wrangler login
```

### Project Initialization

```bash
# Create project
pnpm create vite wedding-card --template solid-ts
cd wedding-card

# Install dependencies
pnpm add -D tailwindcss postcss autoprefixer
pnpm add -D @cloudflare/workers-types

# Initialize Tailwind
pnpm dlx tailwindcss init -p

# Install Cloudflare Pages adapter
pnpm add -D @solidjs/router
```

### Project Structure Setup

```bash
mkdir -p src/{components,lib,routes,styles}
mkdir -p functions/api/admin
mkdir -p migrations
mkdir -p public/images
```

### wrangler.toml

```toml
name = "wedding-card"
compatibility_date = "2024-01-01"
pages_build_output_dir = "dist"

# D1 Database
[[d1_databases]]
binding = "DB"
database_name = "wedding-card-db"

# R2 Storage
[[r2_buckets]]
binding = "IMAGES"
bucket_name = "wedding-card-images"

# KV for rate limiting
[[kv_namespaces]]
binding = "RATE_LIMIT"
```

### First Migration (migrations/0001_create_rsvps.sql)

```sql
CREATE TABLE IF NOT EXISTS rsvps (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  guest_name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  attending INTEGER NOT NULL, -- 0 or 1
  guest_count INTEGER DEFAULT 1,
  adults INTEGER DEFAULT 1,
  children INTEGER DEFAULT 0,
  dietary_restrictions TEXT,
  message TEXT,
  ip_address TEXT,
  user_agent TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_rsvps_created_at ON rsvps(created_at);
CREATE INDEX idx_rsvps_attending ON rsvps(attending);
```

### Dev Workflow

```bash
# Create D1 database locally
wrangler d1 create wedding-card-db

# Run migrations locally
wrangler d1 migrations apply wedding-card-db --local

# Start dev server
pnpm dev

# In another terminal, start Wrangler for Workers
wrangler pages dev dist --binding DB=wedding-card-db
```

## SolidJS + Cloudflare Integration

### Form Handling Pattern

```tsx
// src/components/RsvpForm.tsx
import { createSignal } from "solid-js";

interface RsvpFormData {
  guestName: string;
  email: string;
  attending: boolean;
  guestCount: number;
  message: string;
}

export function RsvpForm() {
  const [formData, setFormData] = createSignal<RsvpFormData>({
    guestName: "",
    email: "",
    attending: true,
    guestCount: 1,
    message: "",
  });
  const [submitting, setSubmitting] = createSignal(false);
  const [error, setError] = createSignal<string | null>(null);
  const [success, setSuccess] = createSignal(false);

  const handleSubmit = async (e: Event) => {
    e.preventDefault();
    setSubmitting(true);
    setError(null);

    try {
      const response = await fetch("/api/rsvp", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(formData()),
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.message || "Failed to submit RSVP");
      }

      setSuccess(true);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Something went wrong");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} class="space-y-4">
      {success() ? (
        <div class="bg-green-100 text-green-800 p-4 rounded">
          Thank you! Your RSVP has been received.
        </div>
      ) : (
        <>
          <input
            type="text"
            placeholder="Your Name"
            value={formData().guestName}
            onInput={(e) =>
              setFormData({ ...formData(), guestName: e.currentTarget.value })
            }
            required
            class="w-full px-4 py-2 border rounded"
          />

          <input
            type="email"
            placeholder="Email"
            value={formData().email}
            onInput={(e) =>
              setFormData({ ...formData(), email: e.currentTarget.value })
            }
            required
            class="w-full px-4 py-2 border rounded"
          />

          <label class="flex items-center space-x-2">
            <input
              type="checkbox"
              checked={formData().attending}
              onChange={(e) =>
                setFormData({
                  ...formData(),
                  attending: e.currentTarget.checked,
                })
              }
            />
            <span>I will attend</span>
          </label>

          {formData().attending && (
            <input
              type="number"
              min="1"
              placeholder="Number of guests"
              value={formData().guestCount}
              onInput={(e) =>
                setFormData({
                  ...formData(),
                  guestCount: parseInt(e.currentTarget.value),
                })
              }
              class="w-full px-4 py-2 border rounded"
            />
          )}

          <textarea
            placeholder="Message (optional)"
            value={formData().message}
            onInput={(e) =>
              setFormData({ ...formData(), message: e.currentTarget.value })
            }
            class="w-full px-4 py-2 border rounded h-24"
          />

          {error() && (
            <div class="bg-red-100 text-red-800 p-4 rounded">{error()}</div>
          )}

          <button
            type="submit"
            disabled={submitting()}
            class="w-full bg-blue-600 text-white py-3 rounded hover:bg-blue-700 disabled:opacity-50"
          >
            {submitting() ? "Submitting..." : "Submit RSVP"}
          </button>
        </>
      )}
    </form>
  );
}
```

### Workers API Pattern

```typescript
// functions/api/rsvp.ts
interface Env {
  DB: D1Database;
  RATE_LIMIT: KVNamespace;
}

export const onRequestPost: PagesFunction<Env> = async ({ request, env }) => {
  try {
    // Rate limiting
    const ip = request.headers.get("CF-Connecting-IP") || "unknown";
    const rateLimitKey = `rsvp:${ip}`;
    const attempts = await env.RATE_LIMIT.get(rateLimitKey);

    if (attempts && parseInt(attempts) >= 5) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "Rate limit exceeded. Try again in 1 hour.",
        }),
        {
          status: 429,
          headers: { "Content-Type": "application/json" },
        },
      );
    }

    // Parse request
    const data = await request.json();

    // Validate
    if (!data.guestName || !data.email) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "Name and email are required",
        }),
        {
          status: 400,
          headers: { "Content-Type": "application/json" },
        },
      );
    }

    // Insert into D1
    const result = await env.DB.prepare(
      `INSERT INTO rsvps (guest_name, email, phone, attending, guest_count, adults, children, dietary_restrictions, message, ip_address, user_agent)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    )
      .bind(
        data.guestName,
        data.email,
        data.phone || null,
        data.attending ? 1 : 0,
        data.guestCount || 1,
        data.adults || 1,
        data.children || 0,
        data.dietaryRestrictions || null,
        data.message || null,
        ip,
        request.headers.get("User-Agent"),
      )
      .run();

    // Update rate limit
    await env.RATE_LIMIT.put(
      rateLimitKey,
      (parseInt(attempts || "0") + 1).toString(),
      {
        expirationTtl: 3600, // 1 hour
      },
    );

    return new Response(
      JSON.stringify({
        success: true,
        message: "RSVP received successfully",
        id: result.meta.last_row_id,
      }),
      {
        headers: { "Content-Type": "application/json" },
      },
    );
  } catch (error) {
    console.error("RSVP Error:", error);
    return new Response(
      JSON.stringify({
        success: false,
        error: "Internal server error",
      }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      },
    );
  }
};
```

## Daily Workflow

### 2-Hour Session Plan

**First 30 mins:** Review progress, plan today's task
**Next 60 mins:** Focused coding (one feature/component)
**Last 30 mins:** Testing, commit, update progress

### 4-Hour Session Plan

**First hour:** Review + plan + SolidJS learning
**Next 2 hours:** Build feature
**Last hour:** Testing, optimization, documentation

## Key Milestones

- **Week 2:** Landing page live on Cloudflare Pages ✓
- **Week 4:** RSVP system working ✓
- **Week 6:** All content sections complete ✓
- **Week 8:** Guestbook functional ✓
- **Week 10:** Admin dashboard ready ✓
- **Week 12:** All features done ✓
- **Week 14:** Production-ready ✓
- **Week 16:** Launched with custom domain ✓

## Risk Mitigation

### If Behind Schedule

**Week 4:** Drop guestbook, keep RSVP
**Week 8:** Drop admin dashboard, use D1 console
**Week 12:** Drop photo gallery, use simple image grid

### If Ahead of Schedule

**Week 6:** Add animations and micro-interactions
**Week 10:** Build email notification system
**Week 14:** Add advanced analytics

## Success Criteria

### MVP (Week 4)

- [ ] Landing page deployed
- [ ] RSVP form working
- [ ] Mobile responsive
- [ ] <3s page load

### Launch (Week 16)

- [ ] All features complete
- [ ] Lighthouse score 95+
- [ ] Zero critical bugs
- [ ] Custom domain configured
- [ ] Admin can manage RSVPs

## Next Steps

1. **Complete SolidJS tutorial** (2 hours)
2. **Set up Cloudflare account** (30 mins)
3. **Initialize project** (1 hour)
4. **Deploy Hello World** (30 mins)
5. **Start Week 1 tasks**

Ready to start?

# Online Wedding Card - Design Specification

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    Cloudflare Edge                       │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌──────────────┐              ┌──────────────┐         │
│  │ Pages (CDN)  │              │  Workers API │         │
│  │              │              │              │         │
│  │ TanStack     │─────────────▶│    Hono      │         │
│  │ Start App    │   API calls  │   Backend    │         │
│  └──────────────┘              └──────┬───────┘         │
│                                       │                  │
│                                       ▼                  │
│                          ┌────────────────────┐         │
│                          │   Cloudflare D1    │         │
│                          │   (SQLite)         │         │
│                          └────────────────────┘         │
│                                                          │
│  ┌──────────────┐              ┌──────────────┐         │
│  │      R2      │              │   Resend     │         │
│  │  (Storage)   │              │   (Email)    │         │
│  └──────────────┘              └──────────────┘         │
│                                                          │
└─────────────────────────────────────────────────────────┘
                              │
                              ▼
                      ┌───────────────┐
                      │  Clerk Auth   │
                      │  (External)   │
                      └───────────────┘
```

## Monorepo Structure

```
wedding-card/
├── apps/
│   ├── api/                    # Hono backend (Cloudflare Workers)
│   │   ├── src/
│   │   │   ├── index.ts        # Main entry point
│   │   │   ├── routes/
│   │   │   │   ├── rsvp.ts
│   │   │   │   ├── admin.ts
│   │   │   │   ├── photos.ts
│   │   │   │   └── checkin.ts
│   │   │   ├── db/
│   │   │   │   ├── schema.ts   # Drizzle schema
│   │   │   │   └── seed.ts     # Initial data
│   │   │   ├── middleware/
│   │   │   │   ├── auth.ts
│   │   │   │   ├── cors.ts
│   │   │   │   └── ratelimit.ts
│   │   │   └── lib/
│   │   │       ├── email.ts
│   │   │       ├── qr.ts
│   │   │       └── storage.ts
│   │   ├── wrangler.toml
│   │   ├── package.json
│   │   └── drizzle.config.ts
│   │
│   └── web/                    # TanStack Start frontend (Cloudflare Pages)
│       ├── src/
│       │   ├── routes/
│       │   │   ├── index.tsx   # Landing page
│       │   │   ├── rsvp.tsx    # RSVP form
│       │   │   ├── gallery.tsx # Photo gallery
│       │   │   └── admin/
│       │   │       ├── index.tsx
│       │   │       ├── guests.tsx
│       │   │       ├── checkin.tsx
│       │   │       └── photos.tsx
│       │   ├── components/
│       │   │   ├── ui/         # shadcn/ui components
│       │   │   ├── hero.tsx
│       │   │   ├── countdown.tsx
│       │   │   ├── rsvp-form.tsx
│       │   │   ├── photo-uploader.tsx
│       │   │   └── qr-scanner.tsx
│       │   ├── lib/
│       │   │   ├── api.ts      # API client
│       │   │   ├── validators.ts # Zod schemas
│       │   │   └── utils.ts
│       │   └── styles/
│       │       └── globals.css
│       ├── public/
│       │   └── images/
│       ├── package.json
│       └── app.config.ts
│
├── packages/
│   └── types/                  # Shared TypeScript types
│       ├── index.ts
│       └── package.json
│
├── package.json                # Root workspace config
├── turbo.json                  # Turborepo config
├── .env.example
└── README.md
```

## API Design (Hono Backend)

### REST Endpoints

#### Public Endpoints

```typescript
// POST /api/rsvp - Submit RSVP
{
  "email": "john@example.com",
  "fullName": "John Doe",
  "phone": "+1234567890",
  "numGuests": 2,
  "dietaryRestrictions": "Vegetarian",
  "specialRequests": "Wheelchair access",
  "attendanceStatus": "yes"
}

// Response
{
  "success": true,
  "data": {
    "id": 1,
    "qrCode": "base64-encoded-qr",
    "confirmationNumber": "WED-2024-001"
  }
}

// GET /api/photos?approved=true - Get approved photos
{
  "data": [
    {
      "id": 1,
      "url": "https://r2.../photo1.webp",
      "thumbnail": "https://r2.../photo1-thumb.webp",
      "uploadedBy": "Guest Name"
    }
  ]
}

// POST /api/photos/upload - Upload photo (guest)
// Multipart form data
{
  "photo": File,
  "uploadedBy": "Guest Name"
}
```

#### Admin Endpoints (Protected)

```typescript
// GET /api/admin/guests - List all RSVPs
// Headers: Authorization: Bearer <clerk-token>
{
  "data": [
    {
      "id": 1,
      "email": "john@example.com",
      "fullName": "John Doe",
      "numGuests": 2,
      "attendanceStatus": "yes",
      "checkedIn": false,
      "createdAt": "2024-01-01T00:00:00Z"
    }
  ],
  "total": 150,
  "confirmed": 120,
  "pending": 30
}

// PATCH /api/admin/guests/:id - Update guest
{
  "attendanceStatus": "yes",
  "numGuests": 3
}

// POST /api/admin/checkin/:id - Check-in guest
{
  "checkedIn": true,
  "checkedInAt": "2024-06-15T14:30:00Z"
}

// GET /api/admin/export - Export guests to CSV
// Returns CSV file

// POST /api/admin/photos/:id/approve - Approve photo
{
  "approved": true
}

// DELETE /api/admin/photos/:id - Delete photo
```

## Frontend Routes (TanStack Start)

### Public Routes

```typescript
// / - Landing page
- Hero section with countdown
- Story timeline
- Event details
- Gallery preview
- RSVP button

// /rsvp - RSVP form
- Form with validation
- Success confirmation
- QR code download

// /gallery - Photo gallery
- Grid layout
- Lightbox view
- Filter by date
- Upload button (for guests)
```

### Admin Routes (Protected)

```typescript
// /admin - Dashboard
- Stats cards (total guests, confirmed, checked-in)
- Recent RSVPs table
- Quick actions

// /admin/guests - Guest management
- DataTable with filters
- Search functionality
- Edit/delete actions
- Export CSV button

// /admin/checkin - Check-in interface
- QR scanner
- Manual search
- Bulk check-in

// /admin/photos - Photo management
- Grid view of all photos
- Approve/reject buttons
- Delete functionality
```

## Component Architecture

### Core Components

```typescript
// Hero Component
interface HeroProps {
  coupleNames: string;
  weddingDate: Date;
  coverImage: string;
}

// Countdown Component
interface CountdownProps {
  targetDate: Date;
}

// RSVP Form Component
interface RSVPFormProps {
  onSubmit: (data: RSVPData) => void;
  isLoading: boolean;
}

// Photo Gallery Component
interface GalleryProps {
  photos: Photo[];
  onUpload?: (file: File) => void;
  isAdmin?: boolean;
}

// QR Scanner Component
interface QRScannerProps {
  onScan: (guestId: string) => void;
}

// Guest Table Component (Admin)
interface GuestTableProps {
  guests: Guest[];
  onEdit: (guest: Guest) => void;
  onDelete: (id: number) => void;
  onExport: () => void;
}
```

## Database Schema (Drizzle ORM)

```typescript
// apps/api/src/db/schema.ts
import { sqliteTable, text, integer } from "drizzle-orm/sqlite-core";

export const guests = sqliteTable("guests", {
  id: integer("id").primaryKey({ autoIncrement: true }),
  email: text("email").notNull().unique(),
  fullName: text("full_name").notNull(),
  phone: text("phone"),
  numGuests: integer("num_guests").default(1),
  dietaryRestrictions: text("dietary_restrictions"),
  specialRequests: text("special_requests"),
  attendanceStatus: text("attendance_status").$type<"yes" | "no" | "maybe">(),
  checkedIn: integer("checked_in", { mode: "boolean" }).default(false),
  qrCode: text("qr_code").unique(),
  createdAt: text("created_at").default(sql`CURRENT_TIMESTAMP`),
  updatedAt: text("updated_at").default(sql`CURRENT_TIMESTAMP`),
});

export const photos = sqliteTable("photos", {
  id: integer("id").primaryKey({ autoIncrement: true }),
  r2Key: text("r2_key").notNull(),
  uploadedBy: text("uploaded_by"),
  approved: integer("approved", { mode: "boolean" }).default(false),
  createdAt: text("created_at").default(sql`CURRENT_TIMESTAMP`),
});

export const admins = sqliteTable("admins", {
  id: integer("id").primaryKey({ autoIncrement: true }),
  clerkUserId: text("clerk_user_id").notNull().unique(),
  email: text("email").notNull(),
  createdAt: text("created_at").default(sql`CURRENT_TIMESTAMP`),
});
```

## Styling System

### Tailwind Config

```typescript
// tailwind.config.ts
export default {
  theme: {
    extend: {
      colors: {
        wedding: {
          primary: "#D4AF37", // Gold
          secondary: "#F5F5DC", // Beige
          accent: "#8B7355", // Tan
          dark: "#2C2C2C",
          light: "#FFFFFF",
        },
      },
      fontFamily: {
        heading: ["Playfair Display", "serif"],
        body: ["Lato", "sans-serif"],
      },
    },
  },
};
```

### Component Variants

```typescript
// shadcn/ui customization
const buttonVariants = {
  wedding: "bg-wedding-primary hover:bg-wedding-accent text-white",
  outline:
    "border-wedding-primary text-wedding-primary hover:bg-wedding-primary hover:text-white",
};
```

## State Management

### TanStack Query

```typescript
// API queries
const useGuests = () => {
  return useQuery({
    queryKey: ["guests"],
    queryFn: () => api.getGuests(),
  });
};

const useRSVPMutation = () => {
  return useMutation({
    mutationFn: (data: RSVPData) => api.submitRSVP(data),
    onSuccess: () => {
      toast.success("RSVP submitted successfully!");
    },
  });
};
```

### Form State (React Hook Form)

```typescript
const rsvpSchema = z.object({
  email: z.string().email(),
  fullName: z.string().min(2),
  phone: z.string().optional(),
  numGuests: z.number().min(1).max(5),
  dietaryRestrictions: z.string().optional(),
  attendanceStatus: z.enum(["yes", "no", "maybe"]),
});

type RSVPFormData = z.infer<typeof rsvpSchema>;
```

## Security Design

### Authentication Flow

```
1. User visits /admin
2. Redirect to Clerk sign-in
3. Clerk returns JWT token
4. Frontend stores token
5. All API calls include: Authorization: Bearer <token>
6. Hono middleware validates JWT
7. Check if user is in admins table
8. Allow/deny access
```

### Rate Limiting

```typescript
// Cloudflare Workers Rate Limit
const rateLimiter = {
  namespace: "RATE_LIMIT",
  threshold: 10, // 10 requests
  period: 3600, // per hour
  keyGenerator: (c) => c.req.header("cf-connecting-ip"), // by IP
};
```

## Image Optimization

### R2 Storage Structure

```
wedding-card-bucket/
├── photos/
│   ├── original/
│   │   └── {uuid}.jpg
│   ├── optimized/
│   │   └── {uuid}.webp
│   └── thumbnails/
│       └── {uuid}-thumb.webp
└── uploads/
    └── {date}/
        └── {uuid}.jpg
```

### Image Processing

```typescript
// On upload
1. Upload original to R2
2. Generate WebP version (80% quality)
3. Generate thumbnail (300x300)
4. Store all 3 versions
5. Return optimized URLs
```

## Email Templates (Resend)

### RSVP Confirmation

```html
Subject: Wedding RSVP Confirmed - [Couple Names] Hi [Guest Name], Thank you for
confirming your attendance! Wedding Details: - Date: [Date] - Time: [Time] -
Venue: [Venue] Number of Guests: [Number] Your QR Code (for check-in): [QR Code
Image] See you there! [Couple Names]
```

### Admin Notification

```html
Subject: New RSVP Received New RSVP Details: - Guest: [Name] - Email: [Email] -
Guests: [Number] - Status: [Yes/No/Maybe] View in admin: [Link]
```

## Performance Optimizations

### Frontend

- Code splitting (route-based)
- Image lazy loading
- WebP with fallbacks
- Prefetch critical routes
- CDN caching (Cloudflare Pages)

### Backend

- D1 prepared statements
- Response caching (10 min for photos)
- R2 presigned URLs
- Connection pooling

### SEO

- Meta tags (Open Graph)
- Structured data (Event schema)
- Sitemap generation
- robots.txt

## Deployment Strategy

### CI/CD Pipeline

```yaml
# .github/workflows/deploy.yml
on: [push]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - Checkout code
      - Install dependencies
      - Run tests
      - Build frontend (TanStack Start)
      - Build backend (Hono)
      - Deploy to Cloudflare (wrangler deploy)
```

### Environment Variables

```bash
# .env.example
# Clerk Auth
VITE_CLERK_PUBLISHABLE_KEY=pk_test_...
CLERK_SECRET_KEY=sk_test_...

# Cloudflare
CLOUDFLARE_API_TOKEN=...
CLOUDFLARE_ACCOUNT_ID=...

# Resend
RESEND_API_KEY=re_...

# Database
DATABASE_ID=...  # D1 database ID

# R2 Bucket
R2_BUCKET_NAME=wedding-card-photos
R2_ACCESS_KEY_ID=...
R2_SECRET_ACCESS_KEY=...
```

## Testing Strategy

### Unit Tests

- Form validation (Zod schemas)
- Utility functions
- API client

### Integration Tests

- API endpoints (Hono)
- Database operations (Drizzle)
- Email sending (Resend mock)

### E2E Tests (Optional)

- RSVP flow
- Admin check-in
- Photo upload

## Accessibility Checklist

- ✅ Semantic HTML
- ✅ ARIA labels on forms
- ✅ Keyboard navigation
- ✅ Focus indicators
- ✅ Color contrast 4.5:1
- ✅ Alt text on images
- ✅ Screen reader tested

## Mobile-First Breakpoints

```css
/* Mobile: 375px - 767px */
/* Tablet: 768px - 1023px */
/* Desktop: 1024px+ */

@media (min-width: 768px) {
  /* Tablet */
}
@media (min-width: 1024px) {
  /* Desktop */
}
```

## Error Handling

### Frontend

- Form validation errors (inline)
- Network errors (toast notifications)
- 404 pages (custom design)
- Fallback UI (error boundaries)

### Backend

- Validation errors (400)
- Auth errors (401)
- Not found (404)
- Server errors (500)
- Proper error logging (Cloudflare Logs)

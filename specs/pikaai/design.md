# PikaAI - Design Document (Synchronous MVP)

> **Brand:** PikaAI - AI-powered image generation for Vietnamese photographers  
> **Strategy:** FREE tier first, synchronous processing, zero upfront cost

## Architecture Overview

### System Architecture (MVP - Synchronous, No Queues)

```
┌─────────────────────────────────────────────────────────────────┐
│ ADOBE PHOTOSHOP (Desktop Client)                                │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ UXP PLUGIN (React + React Spectrum)                         │ │
│ │ - Minimal UI (trigger generation)                           │ │
│ │ - Loading spinner (6-13s wait)                              │ │
│ │ - Layer Export/Import                                       │ │
│ │ - ~400 lines (simpler without polling)                      │ │
│ └────────────────┬────────────────────────────────────────────┘ │
└──────────────────┼──────────────────────────────────────────────┘
                   │ HTTPS (Wait for response)
                   ▼
┌─────────────────────────────────────────────────────────────────┐
│ WEB DASHBOARD (SolidJS + Solid Start)                           │
│ - Credit purchase (SePay/VietQR)                                │
│ - Job history (D1 queries)                                      │
│ - Vietnamese UI (vi.json)                                       │
│ - Mobile-responsive                                             │
└────────────────┬────────────────────────────────────────────────┘
                 │ HTTPS / TLS 1.3 (JWT Auth)
                 ▼
┌─────────────────────────────────────────────────────────────────┐
│ CLOUDFLARE WORKERS (FREE TIER - Synchronous Processing)         │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ POST /api/generate (SYNCHRONOUS - 6-13s response)          │ │
│ │                                                             │ │
│ │ 1. Deduct credits from D1                                  │ │
│ │ 2. Fetch input images from R2 (2s)                         │ │
│ │ 3. Call Gemini API (WAIT 3-10s) ⚠️ 10s timeout risk       │ │
│ │ 4. Store output in R2 (1s)                                 │ │
│ │ 5. Save job record in D1 (0.5s)                            │ │
│ │ 6. Return result URL immediately                           │ │
│ │                                                             │ │
│ │ Total: 6-13s synchronous response                          │ │
│ └─────────────────────────────────────────────────────────────┘ │
│                                                                   │
│ Other routes:                                                     │
│ - /auth/* (Google OAuth + JWT)                                   │
│ - /upload (R2 streaming)                                          │
│ - /api/sepay/webhook (payment notification)                      │
└────────────────┬──────────────┬───────────────────────────────────┘
                 │              │
        ┌────────▼─────┐   ┌────▼──────────┐
        │ D1 (FREE)    │   │ R2 (FREE)     │
        │ - Users      │   │ - Images      │
        │ - Jobs       │   │ - Results     │
        │ - Credits    │   │               │
        └──────────────┘   └───────────────┘
                                    ▲
                                    │ HTTPS
                           ┌────────┴─────────────┐
                           │ GEMINI API           │
                           │ (Sync call 3-10s)    │
                           └──────────────────────┘
                                    ▲
                                    │ Webhook
                           ┌────────┴─────────────┐
                           │ SEPAY API            │
                           │ (Bank transfers)     │
                           └──────────────────────┘
```

**Key Differences from Queue-Based:**

- ✅ Simpler (no queue setup, no consumer worker)
- ✅ Cheaper (FREE tier works)
- ✅ Immediate results (no polling needed)
- ⚠️ 10s CPU timeout risk on FREE tier
- ⚠️ User waits 6-13s (but acceptable for wedding photos)
- ⚠️ No automatic retry (user clicks again if failed)

┌─────────────────────────────────────────────────────────────┐
│ ADOBE PHOTOSHOP (Client) │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ UXP PLUGIN │ │
│ │ - React Spectrum UI │ │
│ │ - Layer Export Engine │ │
│ │ - API Client (fetch) │ │
│ │ - UXP Secure Storage (JWT) │ │
│ └─────────────────────────────────────────────────────────┘ │
└────────────────┬────────────────────────────────────────────┘
│ HTTPS / TLS 1.3
│ JWT Bearer Auth
▼
┌────────────────────────────────────────────────────────────┐
│ CLOUDFLARE WORKERS (Edge API) │
│ ┌───────────┬────────────┬────────────┬──────────────────┐ │
│ │ Auth │ Upload │ Generate│ Jobs │ │
│ │ Worker │ Worker │ Worker │ Worker │ │
│ │ /auth/\* │ /upload │ /generate │ /jobs/:id │ │
│ └─────┬─────┴──────┬─────┴──────┬─────┴────────┬─────────┘ │
└───────┼────────────┼────────────┼──────────────┼───────────┘
│ │ │ │
┌────▼───┐ ┌───▼────┐ ┌────▼─────┐ ┌────▼─────┐
│ D1 │ │ R2 │ │ QUEUE │ │ KV │
│ Users │ │ Images │ │ Jobs │ │ Cache │
│ Jobs │ │ │ │ │ │ │
│ Credits│ │ │ │ │ │ │
└────────┘ └────────┘ └────┬─────┘ └──────────┘
│ Consume
▼
┌──────────────────────────┐
│ QUEUE CONSUMER WORKER │
│ - Fetch from R2 │
│ - Call Gemini API │
│ - Store result │
│ - Update D1 │
└────────┬─────────────────┘
│ HTTPS
▼
┌──────────────────────────┐
│ GOOGLE GEMINI API │
│ gemini-2.5-flash-image │
└──────────────────────────┘

```

### Data Flow

#### Authentication Flow

```

User → Plugin: Click "Login with Google"
Plugin → Browser: Open OAuth URL
Browser → Google: OAuth consent
Google → Worker: Auth code
Worker → Google: Exchange for tokens
Worker → D1: Create user + session
Worker → Plugin: Return JWT
Plugin → UXP Storage: Save JWT

```

#### Image Generation Flow

```

1. UPLOAD PHASE
   User → Plugin: Select layers + prompt
   Plugin → Photoshop: Export layers as PNG
   Plugin → Worker: Upload images (multipart/form-data)
   Worker → R2: Stream upload (no memory limit)
   Worker → Plugin: Return image keys

2. JOB CREATION
   Plugin → Worker: POST /generate with prompt + keys
   Worker → D1: Deduct credits
   Worker → D1: Create job record (status: pending)
   Worker → Queue: Enqueue job
   Worker → Plugin: Return job ID

3. ASYNC PROCESSING
   Queue → Consumer: Trigger consumer
   Consumer → R2: Fetch input images
   Consumer → D1: Update status (processing)
   Consumer → Gemini API: Generate image
   Gemini API → Consumer: Return result
   Consumer → R2: Store output image
   Consumer → D1: Update status (completed)

4. POLLING & RESULT
   Plugin → Worker: GET /jobs/:id (every 2s)
   Worker → D1: Read job status
   Worker → Plugin: Return status + result URL
   Plugin → R2: Download image
   Plugin → Photoshop: Import as layer

````

## Component Design

### 1. Cloudflare Workers API

#### Tech Stack

```typescript
Runtime: Cloudflare Workers (V8 isolates)
Framework: Hono (lightweight HTTP router)
Language: TypeScript
Deployment: Wrangler CLI
````

#### API Endpoints

**Authentication**

```
POST   /api/auth/google          OAuth code exchange
GET    /api/auth/me              Current user info
POST   /api/auth/logout          Invalidate session
```

**Upload**

```
POST   /api/upload               Upload image to R2
DELETE /api/upload/:key          Delete uploaded image
```

**Generation**

```
POST   /api/generate             Create generation job
GET    /api/jobs/:id             Get job status
GET    /api/jobs                 List user jobs
DELETE /api/jobs/:id             Cancel job
```

**Credits**

```
GET    /api/credits              Get user balance
POST   /api/credits/purchase     Stripe checkout session
POST   /api/webhook/stripe       Stripe webhook handler
```

#### Worker Structure

```typescript
// workers/src/index.ts
import { Hono } from "hono";
import { cors } from "hono/cors";
import { jwt } from "hono/jwt";
import { authRouter } from "./routes/auth";
import { uploadRouter } from "./routes/upload";
import { generateRouter } from "./routes/generate";
import { creditsRouter } from "./routes/credits";

type Bindings = {
  DB: D1Database;
  R2: R2Bucket;
  KV: KVNamespace;
  QUEUE: Queue;
  RATE_LIMITER: DurableObjectNamespace;
  GOOGLE_CLIENT_ID: string;
  GOOGLE_CLIENT_SECRET: string;
  GOOGLE_API_KEY: string;
  STRIPE_SECRET_KEY: string;
};

const app = new Hono<{ Bindings: Bindings }>();

app.use("*", cors());
app.use("/api/*", async (c, next) => {
  // Rate limiting via Durable Objects
  const userId = c.get("userId");
  if (userId) {
    const id = c.env.RATE_LIMITER.idFromName(userId);
    const limiter = c.env.RATE_LIMITER.get(id);
    const resp = await limiter.fetch(c.req.raw);
    if (resp.status === 429) return resp;
  }
  await next();
});

app.route("/api/auth", authRouter);
app.route("/api", uploadRouter);
app.route("/api", generateRouter);
app.route("/api", creditsRouter);

export default app;
```

### 2. Database Schema (D1)

```sql
-- Users table
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  google_id TEXT UNIQUE NOT NULL,
  credits INTEGER DEFAULT 10,
  total_generations INTEGER DEFAULT 0,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_google_id ON users(google_id);

-- Sessions table
CREATE TABLE sessions (
  token TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  expires_at INTEGER NOT NULL,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_sessions_user_id ON sessions(user_id);
CREATE INDEX idx_sessions_expires ON sessions(expires_at);

-- Jobs table
CREATE TABLE jobs (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  status TEXT NOT NULL CHECK(status IN ('pending', 'processing', 'completed', 'failed', 'cancelled')),
  prompt TEXT NOT NULL,
  aspect_ratio TEXT DEFAULT '1:1',
  input_images TEXT, -- JSON array of R2 keys
  output_image TEXT, -- R2 key
  error TEXT,
  created_at INTEGER NOT NULL,
  started_at INTEGER,
  completed_at INTEGER,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_jobs_user_status ON jobs(user_id, status);
CREATE INDEX idx_jobs_status ON jobs(status);
CREATE INDEX idx_jobs_created ON jobs(created_at DESC);

-- Credits transactions table
CREATE TABLE credit_transactions (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  amount INTEGER NOT NULL, -- Positive for purchase, negative for usage
  type TEXT NOT NULL CHECK(type IN ('purchase', 'usage', 'refund', 'bonus')),
  reference TEXT, -- Job ID or Stripe payment ID
  created_at INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_transactions_user ON credit_transactions(user_id, created_at DESC);
```

### 3. R2 Storage Structure

```
Bucket: photoshop-gemini-images

Directory Structure:
/uploads/{user_id}/{uuid}.png          User-uploaded images
/outputs/{user_id}/{job_id}.png        Generated images
/cache/{hash}.png                      Cached generations

Metadata:
- Content-Type: image/png or image/jpeg
- Cache-Control: public, max-age=31536000 (1 year)
- User-Id: {user_id} (custom metadata)
- Job-Id: {job_id} (custom metadata)

Lifecycle Rules:
- Delete /uploads/* after 24 hours
- Keep /outputs/* for 30 days
- Keep /cache/* for 7 days
```

### 4. Queue Configuration

```toml
# wrangler.toml

[[queues.producers]]
queue = "gemini-generation-jobs"
binding = "QUEUE"

[[queues.consumers]]
queue = "gemini-generation-jobs"
max_batch_size = 1              # Process one at a time
max_retries = 3                 # Retry failures
dead_letter_queue = "gemini-dlq"
max_concurrency = 10            # Parallel processing limit
```

**Queue Message Format:**

```typescript
interface JobMessage {
  jobId: string;
  userId: string;
  prompt: string;
  imageKeys: string[]; // R2 keys
  aspectRatio: string; // "1:1", "16:9", etc.
  characterConsistency?: boolean;
  referenceJobId?: string; // For conversational editing
}
```

### 5. Durable Objects (Rate Limiter)

```typescript
// workers/src/durable-objects/rate-limiter.ts

export class RateLimiter {
  state: DurableObjectState;
  requests: Map<string, number>;

  constructor(state: DurableObjectState) {
    this.state = state;
    this.requests = new Map();
  }

  async fetch(request: Request) {
    const url = new URL(request.url);
    const userId = url.searchParams.get("userId");

    if (!userId) {
      return new Response("Missing userId", { status: 400 });
    }

    const now = Date.now();
    const windowStart = now - 60000; // 1 minute window

    // Get request count from storage
    const key = `${userId}:${Math.floor(now / 60000)}`;
    const count = (await this.state.storage.get<number>(key)) || 0;

    // Check limit (10 requests per minute)
    if (count >= 10) {
      return new Response(
        JSON.stringify({
          error: "Rate limit exceeded",
          retryAfter: 60 - Math.floor((now % 60000) / 1000),
        }),
        {
          status: 429,
          headers: { "Content-Type": "application/json" },
        },
      );
    }

    // Increment counter
    await this.state.storage.put(key, count + 1);

    // Set alarm to cleanup old keys
    await this.state.storage.setAlarm(now + 120000); // 2 minutes

    return new Response("OK", { status: 200 });
  }

  async alarm() {
    // Cleanup old request counts
    const now = Date.now();
    const keys = await this.state.storage.list();

    for (const [key, _] of keys) {
      const timestamp = parseInt(key.split(":")[1]) * 60000;
      if (now - timestamp > 120000) {
        await this.state.storage.delete(key);
      }
    }
  }
}
```

### 6. Web Dashboard (SolidJS + Solid Start)

#### Dashboard Structure

```
dashboard/
├── src/
│   ├── routes/                   # File-based routing
│   │   ├── index.tsx             # Home page
│   │   ├── credits.tsx           # Credit purchase
│   │   ├── history.tsx           # Job history
│   │   ├── settings.tsx          # Account settings
│   │   └── api/
│   │       ├── sepay/
│   │       │   └── webhook.ts    # SePay webhook handler
│   │       └── jobs.ts           # Job status API
│   ├── components/
│   │   ├── CreditPurchase.tsx
│   │   ├── JobHistory.tsx
│   │   ├── PaymentInvoice.tsx
│   │   └── VietnameseLayout.tsx
│   ├── locales/
│   │   ├── vi.json               # Vietnamese translations
│   │   └── en.json               # English fallback
│   ├── lib/
│   │   ├── sepay.ts              # SePay client
│   │   └── api.ts                # API client
│   └── entry-server.tsx          # SSR entry
├── public/
│   └── assets/
│       └── banks/                # Vietnamese bank logos
└── app.config.ts
```

#### SePay Integration

```typescript
// routes/credits.tsx
import { createSignal, Show } from 'solid-js'
import { useI18n } from 'solid-i18next'

export default function CreditsPage() {
  const [t] = useI18n()
  const [selectedPackage, setSelectedPackage] = createSignal(null)

  const packages = [
    { credits: 10, vnd: 30_000, usd: 1.20 },
    { credits: 50, vnd: 140_000, usd: 5.60, popular: true },
    { credits: 100, vnd: 250_000, usd: 10 },
    { credits: 500, vnd: 1_000_000, usd: 40 }
  ]

  return (
    <div class="container mx-auto p-6">
      <h1 class="text-3xl font-bold mb-6">{t('credits.title')}</h1>

      <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
        <For each={packages}>
          {(pkg) => (
            <div
              class={`p-6 border rounded-lg cursor-pointer ${pkg.popular ? 'border-blue-500 bg-blue-50' : ''}`}
              onClick={() => setSelectedPackage(pkg)}
            >
              <Show when={pkg.popular}>
                <span class="bg-blue-500 text-white px-2 py-1 rounded text-sm">
                  {t('credits.popular')}
                </span>
              </Show>
              <div class="text-4xl font-bold mt-2">
                {pkg.credits} <span class="text-lg">{t('credits.credits')}</span>
              </div>
              <div class="mt-4">
                <span class="text-2xl font-semibold">{pkg.vnd.toLocaleString('vi-VN')}đ</span>
                <span class="text-gray-500 ml-2">(~${pkg.usd})</span>
              </div>
              <button class="mt-4 w-full bg-blue-500 text-white py-2 rounded">
                {t('credits.buy_now')}
              </button>
            </div>
          )}
        </For>
      </div>

      <Show when={selectedPackage()}>
        <PaymentModal package={selectedPackage()} />
      </Show>
    </div>
  )
}

// components/PaymentModal.tsx
function PaymentModal(props) {
  const [t] = useI18n()
  const paymentMemo = `NAPTHE ${userId} ${props.package.credits}CR`

  return (
    <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center">
      <div class="bg-white p-8 rounded-lg max-w-md">
        <h2 class="text-2xl font-bold mb-4">{t('payment.transfer_instructions')}</h2>

        {/* VietQR Code */}
        <img
          src={`https://qr.sepay.vn/img?acc=${BANK_ACCOUNT}&bank=${BANK_CODE}&amount=${props.package.vnd}&des=${paymentMemo}`}
          alt="VietQR"
          class="w-full mb-4"
        />

        {/* Bank Details */}
        <div class="space-y-2 text-sm">
          <div class="flex justify-between">
            <span class="font-semibold">{t('payment.account_number')}:</span>
            <span>{BANK_ACCOUNT}</span>
          </div>
          <div class="flex justify-between">
            <span class="font-semibold">{t('payment.bank_name')}:</span>
            <span>MBBank</span>
          </div>
          <div class="flex justify-between">
            <span class="font-semibold">{t('payment.amount')}:</span>
            <span class="text-red-500 font-bold">{props.package.vnd.toLocaleString('vi-VN')}đ</span>
          </div>
          <div class="flex justify-between">
            <span class="font-semibold">{t('payment.memo')}:</span>
            <span class="font-mono bg-gray-100 px-2 py-1">{paymentMemo}</span>
          </div>
        </div>

        <div class="mt-6 p-4 bg-yellow-50 rounded">
          <p class="text-sm text-yellow-800">
            ⚠️ {t('payment.memo_warning')}
          </p>
        </div>

        <p class="mt-4 text-center text-sm text-gray-600">
          {t('payment.auto_credit_notice')}
        </p>
      </div>
    </div>
  )
}
```

#### Vietnamese Translations

```json
// locales/vi.json
{
  "credits": {
    "title": "Mua thêm điểm",
    "credits": "điểm",
    "popular": "Phổ biến nhất",
    "buy_now": "Mua ngay"
  },
  "payment": {
    "transfer_instructions": "Hướng dẫn chuyển khoản",
    "account_number": "Số tài khoản",
    "bank_name": "Ngân hàng",
    "amount": "Số tiền",
    "memo": "Nội dung chuyển khoản",
    "memo_warning": "Vui lòng nhập chính xác nội dung chuyển khoản để hệ thống tự động cộng điểm",
    "auto_credit_notice": "Điểm sẽ được cộng tự động sau 10-30 giây"
  }
}
```

### 7. Photoshop UXP Plugin (Minimal)

#### Plugin Structure

```
plugin/
├── manifest.json              UXP manifest v5
├── src/
│   ├── index.tsx             Entry point
│   ├── panels/
│   │   └── MainPanel.tsx     Primary UI
│   ├── components/
│   │   ├── LoginView.tsx     Auth screen
│   │   ├── GenerateView.tsx  Main generation UI
│   │   ├── HistoryView.tsx   Job history
│   │   └── CreditsView.tsx   Credits display
│   ├── api/
│   │   ├── client.ts         HTTP client
│   │   ├── auth.ts           Auth methods
│   │   ├── upload.ts         Upload methods
│   │   └── generate.ts       Generation methods
│   ├── photoshop/
│   │   ├── export.ts         Layer export
│   │   ├── import.ts         Result import
│   │   └── utils.ts          PS helpers
│   └── store/
│       └── state.ts          React state management
└── package.json
```

#### UXP Manifest

```json
{
  "id": "com.example.photoshop-gemini",
  "name": "Gemini Image Generator",
  "version": "1.0.0",
  "main": "index.js",
  "manifestVersion": 5,
  "host": {
    "app": "PS",
    "minVersion": "24.0.0"
  },
  "requiredPermissions": [
    {
      "apiName": "network.fetch",
      "reason": "Required for API communication"
    },
    {
      "apiName": "localStorage",
      "reason": "Store user session"
    },
    {
      "apiName": "launchProcess",
      "reason": "Open OAuth browser window"
    }
  ],
  "entrypoints": [
    {
      "type": "panel",
      "id": "main-panel",
      "label": "Gemini Generator",
      "minimumSize": {
        "width": 320,
        "height": 480
      },
      "maximumSize": {
        "width": 600,
        "height": 1200
      },
      "preferredDockedSize": {
        "width": 400,
        "height": 600
      },
      "preferredFloatingSize": {
        "width": 400,
        "height": 600
      }
    }
  ]
}
```

#### Main UI Component

```typescript
// plugin/src/panels/MainPanel.tsx
import React, { useState, useEffect } from 'react'
import { Provider, defaultTheme, View, Heading, Text, Button, TextField, Picker, Item } from '@adobe/react-spectrum'
import { login, getAuthToken, logout } from '../api/auth'
import { exportLayerAsImage } from '../photoshop/export'
import { generateImage } from '../api/generate'
import { importImageAsLayer } from '../photoshop/import'

export function MainPanel() {
  const [user, setUser] = useState(null)
  const [prompt, setPrompt] = useState('')
  const [aspectRatio, setAspectRatio] = useState('1:1')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)

  useEffect(() => {
    checkAuth()
  }, [])

  async function checkAuth() {
    const token = await getAuthToken()
    if (token) {
      // Validate token and get user
      const userInfo = await fetchUserInfo(token)
      setUser(userInfo)
    }
  }

  async function handleLogin() {
    try {
      const user = await login()
      setUser(user)
    } catch (err) {
      setError(err.message)
    }
  }

  async function handleGenerate() {
    setLoading(true)
    setError(null)

    try {
      // Export selected layers
      const layers = app.activeDocument.layers.filter(l => l.selected)
      if (layers.length === 0) {
        throw new Error('Select at least one layer')
      }

      const imageKeys = []
      for (const layer of layers.slice(0, 3)) {
        const { arrayBuffer, fileName } = await exportLayerAsImage(layer)
        const key = await uploadImage(arrayBuffer, fileName)
        imageKeys.push(key)
      }

      // Create generation job
      const { jobId } = await generateImage(prompt, imageKeys, aspectRatio)

      // Poll for completion
      const resultUrl = await pollJobCompletion(jobId)

      // Import result
      await importImageAsLayer(resultUrl, `Generated: ${prompt.slice(0, 30)}`)

      setPrompt('')
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  if (!user) {
    return (
      <Provider theme={defaultTheme} colorScheme="light">
        <View padding="size-200">
          <Heading level={1}>Gemini Image Generator</Heading>
          <Text>Sign in to start generating images</Text>
          <Button variant="cta" onPress={handleLogin}>
            Login with Google
          </Button>
        </View>
      </Provider>
    )
  }

  return (
    <Provider theme={defaultTheme} colorScheme="light">
      <View padding="size-200">
        <Heading level={1}>Generate Image</Heading>
        <Text>Credits: {user.credits}</Text>

        <TextField
          label="Prompt"
          value={prompt}
          onChange={setPrompt}
          width="100%"
          isRequired
        />

        <Picker
          label="Aspect Ratio"
          selectedKey={aspectRatio}
          onSelectionChange={setAspectRatio}
        >
          <Item key="1:1">Square (1:1)</Item>
          <Item key="16:9">Landscape (16:9)</Item>
          <Item key="9:16">Portrait (9:16)</Item>
          <Item key="4:3">Standard (4:3)</Item>
        </Picker>

        <Button
          variant="cta"
          onPress={handleGenerate}
          isDisabled={loading || !prompt}
        >
          {loading ? 'Generating...' : 'Generate'}
        </Button>

        {error && <Text UNSAFE_style={{ color: 'red' }}>{error}</Text>}
      </View>
    </Provider>
  )
}
```

## Security Design

### Authentication Security

- JWT tokens with 30-day expiration
- Tokens stored in UXP secure storage (encrypted at rest)
- Session validation on every API request
- Automatic token refresh before expiration

### API Security

- HTTPS/TLS 1.3 only (enforced by Cloudflare)
- CORS restricted to plugin origin
- Rate limiting via Durable Objects (10 req/min per user)
- Input validation and sanitization
- SQL injection prevention (parameterized queries)

### Data Security

- R2 objects private by default (signed URLs for access)
- User isolation (can only access own jobs/images)
- Secrets stored in Wrangler secrets (not version control)
- PCI compliance via Stripe (no card data stored)

### Abuse Prevention

- Credit system prevents unlimited API usage
- Rate limiting prevents API spam
- Dead letter queue for failed jobs (manual review)
- Usage monitoring and alerts

## Performance Optimizations

### Caching Strategy

```typescript
// Cache key generation
function getCacheKey(prompt: string, imageKeys: string[]): string {
  const input = JSON.stringify({ prompt, imageKeys: imageKeys.sort() });
  return crypto.subtle
    .digest("SHA-256", new TextEncoder().encode(input))
    .then((buf) =>
      Array.from(new Uint8Array(buf))
        .map((b) => b.toString(16).padStart(2, "0"))
        .join(""),
    );
}

// Cache check before generation
const cacheKey = await getCacheKey(prompt, imageKeys);
const cached = await env.KV.get(`gen:${cacheKey}`, "arrayBuffer");

if (cached) {
  // Return cached image (skip Gemini API)
  return new Response(cached, {
    headers: { "Content-Type": "image/png" },
  });
}

// After generation, cache result
await env.KV.put(`gen:${cacheKey}`, resultBuffer, {
  expirationTtl: 604800, // 7 days
});
```

### Image Optimization

- JPEG compression (quality: 85) for uploads
- PNG compression for final output
- Max resolution: 2048x2048 (Gemini limit)
- Automatic downscaling if exceeded

### Database Optimization

- Indexed queries on user_id, status, created_at
- Automatic cleanup of expired sessions (TTL)
- Batch job status queries

### Network Optimization

- Cloudflare edge caching for static assets
- R2 CDN for image delivery
- Connection pooling in Workers
- HTTP/2 multiplexing

## Error Handling Strategy

### Error Categories

```typescript
enum ErrorCode {
  // Auth errors (4xx)
  UNAUTHORIZED = "UNAUTHORIZED",
  INVALID_TOKEN = "INVALID_TOKEN",

  // Resource errors (4xx)
  INSUFFICIENT_CREDITS = "INSUFFICIENT_CREDITS",
  INVALID_IMAGE = "INVALID_IMAGE",
  IMAGE_TOO_LARGE = "IMAGE_TOO_LARGE",

  // Rate limiting (4xx)
  RATE_LIMIT_EXCEEDED = "RATE_LIMIT_EXCEEDED",

  // Server errors (5xx)
  GEMINI_API_ERROR = "GEMINI_API_ERROR",
  STORAGE_ERROR = "STORAGE_ERROR",
  DATABASE_ERROR = "DATABASE_ERROR",

  // Unknown
  UNKNOWN_ERROR = "UNKNOWN_ERROR",
}

interface ErrorResponse {
  error: ErrorCode;
  message: string;
  retryable: boolean;
  retryAfter?: number;
}
```

### Retry Logic

- Transient errors: Retry 3 times with exponential backoff
- Rate limit errors: Wait and retry after specified time
- Auth errors: No retry, prompt re-authentication
- Resource errors: No retry, show user error

### User-Facing Error Messages

```typescript
const ERROR_MESSAGES: Record<ErrorCode, string> = {
  UNAUTHORIZED: "Please log in again",
  INVALID_TOKEN: "Session expired. Please log in.",
  INSUFFICIENT_CREDITS: "Not enough credits. Purchase more to continue.",
  INVALID_IMAGE: "Selected layer cannot be exported. Try a different layer.",
  IMAGE_TOO_LARGE: "Image exceeds 50MB limit. Resize layer and try again.",
  RATE_LIMIT_EXCEEDED: "Too many requests. Please wait a moment.",
  GEMINI_API_ERROR: "Generation failed. Please try again.",
  STORAGE_ERROR: "Upload failed. Check your connection.",
  DATABASE_ERROR: "Server error. Please try again later.",
  UNKNOWN_ERROR: "Unexpected error. Please try again.",
};
```

## Monitoring & Observability

### Metrics to Track

- API request latency (p50, p95, p99)
- Error rates by endpoint
- Queue processing time
- Gemini API success rate
- Credit usage patterns
- Active users (DAU, MAU)

### Logging Strategy

```typescript
// Structured logging
console.log(
  JSON.stringify({
    timestamp: Date.now(),
    level: "INFO",
    service: "generate-worker",
    userId: userId,
    jobId: jobId,
    action: "job_created",
    metadata: { prompt, imageCount },
  }),
);
```

### Alerts

- Error rate > 5% (1 minute window)
- Queue processing lag > 30s
- Gemini API 429 errors
- Database connection failures
- Unusual credit usage patterns

## Deployment Strategy

### Environment Setup

```
Development: Local Wrangler dev server
Staging: Cloudflare Workers (preview branch)
Production: Cloudflare Workers (main branch)
```

### CI/CD Pipeline

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy-workers:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: oven-sh/setup-bun@v1
      - run: cd workers && bun install
      - run: cd workers && bun run test
      - uses: cloudflare/wrangler-action@v3
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          workingDirectory: workers
```

### Rollback Plan

- Keep previous 3 deployments in Cloudflare dashboard
- One-click rollback via Wrangler CLI
- Database migrations versioned (can roll back)
- R2 versioning enabled (30-day retention)

## Testing Strategy

### Unit Tests

- Worker route handlers
- Database queries
- Image export/import functions
- Cache key generation

### Integration Tests

- Full generation flow (upload → generate → poll → import)
- Auth flow (login → API call → logout)
- Credit purchase flow (Stripe checkout)

### E2E Tests

- Photoshop plugin UI interactions
- Cross-platform testing (Mac + Windows)
- Different Photoshop versions (2024, 2025)

### Load Tests

- 1,000 concurrent generations
- Queue backpressure handling
- Rate limiter effectiveness

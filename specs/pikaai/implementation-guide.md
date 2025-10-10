# PikaAI - Implementation Guide

> **Project:** PikaAI - AI image generation for Vietnamese photographers

## Phase 1: Infrastructure Setup (Week 1)

### 1.1 Cloudflare Account Setup

```bash
# Install Wrangler CLI globally
bun install -g wrangler

# Login to Cloudflare
wrangler login

# Create project directory
mkdir pikaai
cd pikaai
mkdir workers plugin dashboard
```

### 1.2 Create Cloudflare Resources

```bash
cd workers

# Create R2 bucket (FREE tier: 10GB storage)
wrangler r2 bucket create pikaai-images

# Create D1 database (FREE tier: 5GB, 5M reads, 100K writes)
wrangler d1 create pikaai-db
# Save the database_id from output

# NO QUEUES NEEDED FOR MVP (queues require paid plan anyway)
# We'll use synchronous processing instead
```

### 1.3 Workers Project Setup

```bash
# Initialize package.json
cat > package.json << 'EOF'
{
  "name": "pikaai-api",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "wrangler dev",
    "deploy": "wrangler deploy",
    "migrate": "wrangler d1 migrations apply pikaai-db",
    "tail": "wrangler tail"
  },
  "dependencies": {
    "hono": "^4.0.0",
    "@google/generative-ai": "^0.21.0",
    "google-auth-library": "^9.0.0",
    "zod": "^3.22.0",
    "@hono/zod-validator": "^0.2.0"
  },
  "devDependencies": {
    "@cloudflare/workers-types": "^4.0.0",
    "typescript": "^5.0.0",
    "wrangler": "^4.0.0"
  }
}
EOF

bun install
```

### 1.4 Wrangler Configuration (FREE Tier)

```toml
# wrangler.toml
name = "pikaai-api"
main = "src/index.ts"
compatibility_date = "2024-01-01"

# Wrangler v4: Use nodejs_compat flag instead of node_compat
compatibility_flags = ["nodejs_compat"]

# FREE TIER STRATEGY:
# - Start on FREE plan (no cost)
# - 10s CPU timeout (⚠️ risk with Gemini API)
# - Upgrade to Paid ($5/mo) when timeout issues arise

[vars]
GOOGLE_CLIENT_ID = "your-client-id.apps.googleusercontent.com"

[[r2_buckets]]
binding = "R2"
bucket_name = "pikaai-images"

[[d1_databases]]
binding = "DB"
database_name = "pikaai-db"
database_id = "YOUR_DATABASE_ID_HERE"

# NO QUEUES FOR MVP (requires paid plan + adds complexity)
# Using synchronous processing instead

# NO DURABLE OBJECTS FOR FREE TIER MVP
# Use simple in-memory rate limiting first
# Add Durable Objects later when scaling
```

### 1.4.5 TypeScript Configuration

```json
// tsconfig.json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "lib": ["ES2022"],
    "moduleResolution": "bundler",
    "types": ["@cloudflare/workers-types"],
    "jsx": "react-jsx",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules"]
}
```

### 1.5 Database Migrations

```sql
-- migrations/0001_initial.sql
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

CREATE TABLE sessions (
  token TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  expires_at INTEGER NOT NULL,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_sessions_user_id ON sessions(user_id);
CREATE INDEX idx_sessions_expires ON sessions(expires_at);

CREATE TABLE jobs (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  status TEXT NOT NULL CHECK(status IN ('pending', 'processing', 'completed', 'failed', 'cancelled')),
  prompt TEXT NOT NULL,
  aspect_ratio TEXT DEFAULT '1:1',
  input_images TEXT,
  output_image TEXT,
  error TEXT,
  created_at INTEGER NOT NULL,
  started_at INTEGER,
  completed_at INTEGER,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_jobs_user_status ON jobs(user_id, status);
CREATE INDEX idx_jobs_status ON jobs(status);
CREATE INDEX idx_jobs_created ON jobs(created_at DESC);

CREATE TABLE credit_transactions (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  amount INTEGER NOT NULL,
  type TEXT NOT NULL CHECK(type IN ('purchase', 'usage', 'refund', 'bonus')),
  reference TEXT,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_transactions_user ON credit_transactions(user_id, created_at DESC);
```

```bash
# Apply migrations
wrangler d1 migrations apply pikaai-db
```

### 1.6 Set Secrets

```bash
# Google OAuth (required)
wrangler secret put GOOGLE_CLIENT_SECRET
# Paste your Google OAuth client secret

# Google Gemini API (required)
wrangler secret put GOOGLE_API_KEY
# Paste your Gemini API key

# SePay (optional for MVP - can test with manual credit top-up first)
wrangler secret put SEPAY_API_KEY
# Paste your SePay API key when ready

wrangler secret put SEPAY_WEBHOOK_SECRET
# Paste your SePay webhook secret when ready
```

## Phase 2: Backend Implementation (Week 2-3)

### 2.0 Architecture Decision: Synchronous vs Queue-Based

**WHY SYNCHRONOUS (FREE Tier MVP):**

- ✅ Zero upfront cost (FREE tier)
- ✅ Simpler code (no queue consumer)
- ✅ Faster development (6 weeks vs 7 weeks)
- ✅ Easier debugging (single request lifecycle)
- ✅ User gets immediate result (6-13s wait)

**TRADE-OFFS:**

- ⚠️ User waits 6-13 seconds (acceptable for MVP)
- ⚠️ 10s timeout risk on FREE tier (upgrade trigger)
- ⚠️ No automatic retry on transient failures

**UPGRADE PATH (After Validation):**

- Workers Paid ($5/mo): 30s timeout fixes risk
- Add Queues later: For batch processing, retries, scale
- Minimal code changes needed

**Decision:** Start FREE, validate market, upgrade when timeout errors >5%

### 2.1 Project Structure

```
workers/
├── src/
│   ├── index.ts
│   ├── types.ts
│   ├── schemas.ts
│   ├── routes/
│   │   ├── auth.ts
│   │   ├── upload.ts
│   │   ├── generate.ts
│   │   └── credits.ts
│   ├── middleware/
│   │   ├── auth.ts
│   │   └── rate-limit.ts
│   ├── services/
│   │   ├── gemini.ts
│   │   └── storage.ts
│   └── utils/
│       └── crypto.ts
├── migrations/
│   └── 0001_initial.sql
├── wrangler.toml
├── package.json
└── tsconfig.json
```

### 2.2 Validation Schemas

```typescript
// src/schemas.ts
import { z } from "zod";

export const generateRequestSchema = z.object({
  prompt: z
    .string()
    .min(10, "Prompt quá ngắn (tối thiểu 10 ký tự)")
    .max(1000, "Prompt quá dài (tối đa 1000 ký tự)")
    .refine(
      (val) => val.trim().length >= 10,
      "Prompt không được chỉ chứa khoảng trắng",
    ),
  imageKeys: z
    .array(z.string().regex(/^uploads\/[\w-]+\/[\w-]+\.(png|jpg|jpeg)$/))
    .min(1, "Cần ít nhất 1 ảnh")
    .max(3, "Tối đa 3 ảnh"),
  aspectRatio: z.enum(["1:1", "16:9", "9:16", "4:3", "3:4"]).default("1:1"),
});

export const uploadSchema = z.object({
  size: z.number().max(50 * 1024 * 1024, "File quá lớn (tối đa 50MB)"),
  type: z
    .string()
    .regex(/^image\/(png|jpeg|jpg)$/, "Chỉ chấp nhận PNG hoặc JPEG"),
});

export const creditPurchaseSchema = z.object({
  amount: z.number().int().min(1000).max(10000000),
  userId: z.string().uuid(),
  transactionId: z.string().min(1),
});

export const sepayWebhookSchema = z.object({
  status: z.enum(["success", "failed", "pending"]),
  amount: z.number().int().positive(),
  transaction_id: z.string(),
  metadata: z
    .object({
      userId: z.string().uuid(),
    })
    .optional(),
});
```

### 2.3 Types Definition

```typescript
// src/types.ts
export interface Env {
  DB: D1Database;
  R2: R2Bucket;
  GOOGLE_CLIENT_ID: string;
  GOOGLE_CLIENT_SECRET: string;
  GOOGLE_API_KEY: string;
  SEPAY_API_KEY: string;
  SEPAY_WEBHOOK_SECRET: string;
}

export interface User {
  id: string;
  email: string;
  google_id: string;
  credits: number;
  total_generations: number;
  created_at: number;
  updated_at: number;
}

export interface Session {
  token: string;
  user_id: string;
  expires_at: number;
  created_at: number;
}

export interface Job {
  id: string;
  user_id: string;
  status: "pending" | "processing" | "completed" | "failed" | "cancelled";
  prompt: string;
  aspect_ratio: string;
  input_images?: string[];
  output_image?: string;
  error?: string;
  created_at: number;
  started_at?: number;
  completed_at?: number;
}
```

### 2.4 Main Entry Point

```typescript
// src/index.ts
import { Hono } from "hono";
import { cors } from "hono/cors";
import { authRouter } from "./routes/auth";
import { uploadRouter } from "./routes/upload";
import { generateRouter } from "./routes/generate";
import { creditsRouter } from "./routes/credits";
import { authMiddleware } from "./middleware/auth";
import { rateLimitMiddleware } from "./middleware/rate-limit";
import type { Env } from "./types";

const app = new Hono<{ Bindings: Env }>();

app.use(
  "*",
  cors({
    origin: ["https://pikaai.vn", "https://*.pikaai.vn"],
    credentials: true,
  }),
);

app.route("/api/auth", authRouter);

app.use("/api/*", authMiddleware);
app.use("/api/generate", rateLimitMiddleware);

app.route("/api", uploadRouter);
app.route("/api", generateRouter);
app.route("/api", creditsRouter);

app.get("/health", (c) => c.json({ status: "ok" }));

export default app;
```

### 2.5 Authentication Routes

```typescript
// src/routes/auth.ts
import { Hono } from "hono";
import { OAuth2Client } from "google-auth-library";
import type { Env } from "../types";

export const authRouter = new Hono<{ Bindings: Env }>();

authRouter.post("/google", async (c) => {
  const { code } = await c.req.json();

  try {
    // CRITICAL: Match this redirect URI with Google Console OAuth settings
    // Production: https://pikaai.vn/auth/callback
    // Development: http://localhost:3000/auth/callback
    const oauth2Client = new OAuth2Client(
      c.env.GOOGLE_CLIENT_ID,
      c.env.GOOGLE_CLIENT_SECRET,
      "https://pikaai.vn/auth/callback",
    );

    const { tokens } = await oauth2Client.getToken(code);
    const ticket = await oauth2Client.verifyIdToken({
      idToken: tokens.id_token!,
      audience: c.env.GOOGLE_CLIENT_ID,
    });

    const payload = ticket.getPayload();
    if (!payload) throw new Error("Invalid token");

    const { sub: googleId, email } = payload;
    const now = Date.now();

    let user = await c.env.DB.prepare("SELECT * FROM users WHERE google_id = ?")
      .bind(googleId)
      .first();

    if (!user) {
      const userId = crypto.randomUUID();
      await c.env.DB.prepare(
        "INSERT INTO users (id, email, google_id, credits, total_generations, created_at, updated_at) VALUES (?, ?, ?, 10, 0, ?, ?)",
      )
        .bind(userId, email, googleId, now, now)
        .run();

      user = {
        id: userId,
        email,
        google_id: googleId,
        credits: 10,
        total_generations: 0,
      };
    }

    const sessionToken = crypto.randomUUID();
    const expiresAt = now + 30 * 24 * 60 * 60 * 1000;

    await c.env.DB.prepare(
      "INSERT INTO sessions (token, user_id, expires_at, created_at) VALUES (?, ?, ?, ?)",
    )
      .bind(sessionToken, user.id, expiresAt, now)
      .run();

    return c.json({
      token: sessionToken,
      user: {
        id: user.id,
        email: user.email,
        credits: user.credits,
      },
    });
  } catch (error) {
    console.error("Auth error:", error);
    return c.json({ error: "Authentication failed" }, 401);
  }
});

authRouter.get("/me", async (c) => {
  const userId = c.get("userId");

  const user = await c.env.DB.prepare(
    "SELECT id, email, credits, total_generations FROM users WHERE id = ?",
  )
    .bind(userId)
    .first();

  if (!user) {
    return c.json({ error: "User not found" }, 404);
  }

  return c.json({ user });
});

authRouter.post("/logout", async (c) => {
  const token = c.req.header("Authorization")?.replace("Bearer ", "");

  if (token) {
    await c.env.DB.prepare("DELETE FROM sessions WHERE token = ?")
      .bind(token)
      .run();
  }

  return c.json({ success: true });
});
```

### 2.6 Upload Routes

```typescript
// src/routes/upload.ts
import { Hono } from "hono";
import { uploadSchema } from "../schemas";
import type { Env } from "../types";

export const uploadRouter = new Hono<{ Bindings: Env }>();

uploadRouter.post("/upload", async (c) => {
  const userId = c.get("userId");
  const formData = await c.req.formData();
  const file = formData.get("image");

  if (!file || !(file instanceof File)) {
    return c.json({ error: "Không có file được tải lên" }, 400);
  }

  // Validate file with Zod
  const validation = uploadSchema.safeParse({
    size: file.size,
    type: file.type,
  });

  if (!validation.success) {
    return c.json(
      {
        error: validation.error.errors[0].message,
        details: validation.error.errors,
      },
      400,
    );
  }

  const imageKey = `uploads/${userId}/${crypto.randomUUID()}.${file.type.split("/")[1]}`;

  try {
    await c.env.R2.put(imageKey, file.stream(), {
      httpMetadata: {
        contentType: file.type,
      },
      customMetadata: {
        userId,
        uploadedAt: Date.now().toString(),
      },
    });

    return c.json({ imageKey });
  } catch (error) {
    console.error("Upload error:", error);
    return c.json({ error: "Upload failed" }, 500);
  }
});

uploadRouter.delete("/upload/:key", async (c) => {
  const userId = c.get("userId");
  const key = c.req.param("key");

  if (!key.startsWith(`uploads/${userId}/`)) {
    return c.json({ error: "Unauthorized" }, 403);
  }

  try {
    await c.env.R2.delete(key);
    return c.json({ success: true });
  } catch (error) {
    console.error("Delete error:", error);
    return c.json({ error: "Delete failed" }, 500);
  }
});
```

### 2.7 Generation Routes (Synchronous Processing with Zod Validation)

```typescript
// src/routes/generate.ts
import { Hono } from "hono";
import { zValidator } from "@hono/zod-validator";
import { generateImage } from "../services/gemini";
import { generateRequestSchema } from "../schemas";
import type { Env } from "../types";

export const generateRouter = new Hono<{ Bindings: Env }>();

generateRouter.post(
  "/generate",
  zValidator("json", generateRequestSchema),
  async (c) => {
    const userId = c.get("userId");
    const { prompt, imageKeys, aspectRatio } = c.req.valid("json");

    const user = await c.env.DB.prepare(
      "SELECT credits FROM users WHERE id = ?",
    )
      .bind(userId)
      .first();

    if (!user || user.credits < 1) {
      return c.json({ error: "Insufficient credits" }, 402);
    }

    const jobId = crypto.randomUUID();
    const now = Date.now();

    try {
      await c.env.DB.batch([
        c.env.DB.prepare(
          "UPDATE users SET credits = credits - 1, updated_at = ? WHERE id = ?",
        ).bind(now, userId),
        c.env.DB.prepare(
          "INSERT INTO jobs (id, user_id, status, prompt, aspect_ratio, input_images, created_at, started_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
        ).bind(
          jobId,
          userId,
          "processing",
          prompt,
          aspectRatio,
          JSON.stringify(imageKeys),
          now,
          now,
        ),
        c.env.DB.prepare(
          "INSERT INTO credit_transactions (id, user_id, amount, type, reference, created_at) VALUES (?, ?, ?, ?, ?, ?)",
        ).bind(crypto.randomUUID(), userId, -1, "usage", jobId, now),
      ]);

      const images = await Promise.all(
        imageKeys.map(async (key: string) => {
          const obj = await c.env.R2.get(key);
          if (!obj) throw new Error(`Image not found: ${key}`);
          return await obj.arrayBuffer();
        }),
      );

      const outputImageData = await generateImage(
        c.env.GOOGLE_API_KEY,
        prompt,
        images,
        aspectRatio,
      );

      const outputKey = `outputs/${userId}/${jobId}.png`;
      await c.env.R2.put(outputKey, outputImageData, {
        httpMetadata: { contentType: "image/png" },
        customMetadata: { userId, jobId },
      });

      const completedAt = Date.now();

      await c.env.DB.prepare(
        "UPDATE jobs SET status = ?, output_image = ?, completed_at = ? WHERE id = ?",
      )
        .bind("completed", outputKey, completedAt, jobId)
        .run();

      return c.json({
        jobId,
        status: "completed",
        outputImage: outputKey,
        processingTime: completedAt - now,
      });
    } catch (error) {
      console.error("Generation failed:", error);

      await c.env.DB.batch([
        c.env.DB.prepare(
          "UPDATE jobs SET status = ?, error = ?, completed_at = ? WHERE id = ?",
        ).bind("failed", error.message, Date.now(), jobId),
        c.env.DB.prepare(
          "UPDATE users SET credits = credits + 1, updated_at = ? WHERE id = ?",
        ).bind(Date.now(), userId),
        c.env.DB.prepare(
          "INSERT INTO credit_transactions (id, user_id, amount, type, reference, created_at) VALUES (?, ?, ?, ?, ?, ?)",
        ).bind(
          crypto.randomUUID(),
          userId,
          1,
          "refund",
          `failed_${jobId}`,
          Date.now(),
        ),
      ]);

      // Vietnamese error messages for better UX
      const errorMessages: Record<string, string> = {
        "No image generated": "Không tạo được ảnh. Vui lòng thử lại.",
        "Image not found": "Không tìm thấy ảnh tải lên. Vui lòng tải lại.",
        Timeout: "Quá thời gian xử lý. Credit đã được hoàn lại.",
        default: "Tạo ảnh thất bại. Credit đã được hoàn lại.",
      };

      const vietnameseError =
        errorMessages[error.message] || errorMessages.default;

      return c.json(
        {
          error: vietnameseError,
          errorCode: error.message,
          jobId,
          creditRefunded: true,
        },
        500,
      );
    }
  },
);

generateRouter.get("/jobs/:id", async (c) => {
  const userId = c.get("userId");
  const jobId = c.req.param("id");

  const job = await c.env.DB.prepare(
    "SELECT * FROM jobs WHERE id = ? AND user_id = ?",
  )
    .bind(jobId, userId)
    .first();

  if (!job) {
    return c.json({ error: "Job not found" }, 404);
  }

  return c.json({
    job: {
      id: job.id,
      status: job.status,
      prompt: job.prompt,
      aspectRatio: job.aspect_ratio,
      outputImage: job.output_image,
      error: job.error,
      createdAt: job.created_at,
      completedAt: job.completed_at,
    },
  });
});

generateRouter.get("/jobs", async (c) => {
  const userId = c.get("userId");
  const limit = parseInt(c.req.query("limit") || "20");
  const offset = parseInt(c.req.query("offset") || "0");

  const { results } = await c.env.DB.prepare(
    "SELECT id, status, prompt, aspect_ratio, output_image, created_at, completed_at FROM jobs WHERE user_id = ? ORDER BY created_at DESC LIMIT ? OFFSET ?",
  )
    .bind(userId, limit, offset)
    .all();

  return c.json({ jobs: results });
});
```

### 2.8 Gemini Service

```typescript
// src/services/gemini.ts
import { GoogleGenerativeAI } from "@google/generative-ai";

export async function generateImage(
  apiKey: string,
  prompt: string,
  images: ArrayBuffer[],
  aspectRatio: string,
): Promise<ArrayBuffer> {
  const genAI = new GoogleGenerativeAI(apiKey);

  // Use Gemini 2.0 Flash (fastest, cheapest for image generation)
  // Cost: $0.075 per 1K images (vs Pro $1.50)
  const model = genAI.getGenerativeModel({
    model: "gemini-2.0-flash-exp",
  });

  const imageParts = images.map((buf) => ({
    inlineData: {
      data: Buffer.from(buf).toString("base64"),
      mimeType: "image/png",
    },
  }));

  const result = await model.generateContent([
    ...imageParts,
    { text: prompt },
    { text: `Generate in aspect ratio: ${aspectRatio}` },
  ]);

  const response = result.response;
  const imageData = response.candidates?.[0]?.content?.parts?.find(
    (part) => part.inlineData,
  );

  if (!imageData?.inlineData?.data) {
    throw new Error("No image generated from Gemini API");
  }

  return Buffer.from(imageData.inlineData.data, "base64");
}

export async function generateImageMock(
  prompt: string,
  images: ArrayBuffer[],
  aspectRatio: string,
): Promise<ArrayBuffer> {
  await new Promise((resolve) => setTimeout(resolve, 2000));

  const canvas = new OffscreenCanvas(1024, 1024);
  const ctx = canvas.getContext("2d");

  if (ctx) {
    ctx.fillStyle = "#f0f0f0";
    ctx.fillRect(0, 0, 1024, 1024);
    ctx.fillStyle = "#333";
    ctx.font = "24px sans-serif";
    ctx.fillText(`Mock: ${prompt.slice(0, 50)}`, 50, 512);
    ctx.fillText(`Aspect: ${aspectRatio}`, 50, 550);
    ctx.fillText(`Images: ${images.length}`, 50, 588);
  }

  const blob = await canvas.convertToBlob({ type: "image/png" });
  return await blob.arrayBuffer();
}
```

### 2.9 Rate Limiter Middleware (In-Memory)

```typescript
// src/middleware/rate-limit.ts
import type { Context, Next } from "hono";
import type { Env } from "../types";

const rateLimitStore = new Map<string, { count: number; resetAt: number }>();

export async function rateLimitMiddleware(
  c: Context<{ Bindings: Env }>,
  next: Next,
) {
  const userId = c.get("userId");

  if (!userId) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  const now = Date.now();
  const windowStart = Math.floor(now / 60000) * 60000;
  const key = `${userId}:${windowStart}`;

  const existing = rateLimitStore.get(key);

  if (existing && existing.resetAt > now) {
    if (existing.count >= 10) {
      const retryAfter = Math.ceil((existing.resetAt - now) / 1000);
      return c.json(
        {
          error: "Rate limit exceeded",
          limit: 10,
          retryAfter,
        },
        429,
      );
    }
    existing.count++;
  } else {
    rateLimitStore.set(key, { count: 1, resetAt: windowStart + 60000 });
  }

  cleanupExpiredEntries();

  await next();
}

function cleanupExpiredEntries() {
  const now = Date.now();
  for (const [key, value] of rateLimitStore.entries()) {
    if (value.resetAt < now - 120000) {
      rateLimitStore.delete(key);
    }
  }
}
```

### 2.10 Authentication Middleware

```typescript
// src/middleware/auth.ts
import type { Context, Next } from "hono";
import type { Env } from "../types";

export async function authMiddleware(
  c: Context<{ Bindings: Env }>,
  next: Next,
) {
  const authHeader = c.req.header("Authorization");

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return c.json({ error: "Missing authorization token" }, 401);
  }

  const token = authHeader.replace("Bearer ", "");

  const session = await c.env.DB.prepare(
    "SELECT user_id, expires_at FROM sessions WHERE token = ?",
  )
    .bind(token)
    .first();

  if (!session) {
    return c.json({ error: "Invalid session token" }, 401);
  }

  if (session.expires_at < Date.now()) {
    await c.env.DB.prepare("DELETE FROM sessions WHERE token = ?")
      .bind(token)
      .run();
    return c.json({ error: "Session expired" }, 401);
  }

  c.set("userId", session.user_id);
  await next();
}
```

### 2.11 Credits Routes

```typescript
// src/routes/credits.ts
import { Hono } from "hono";
import { sepayWebhookSchema } from "../schemas";
import type { Env } from "../types";

export const creditsRouter = new Hono<{ Bindings: Env }>();

creditsRouter.get("/credits", async (c) => {
  const userId = c.get("userId");

  const user = await c.env.DB.prepare(
    "SELECT credits, total_generations FROM users WHERE id = ?",
  )
    .bind(userId)
    .first();

  if (!user) {
    return c.json({ error: "User not found" }, 404);
  }

  const { results: transactions } = await c.env.DB.prepare(
    "SELECT id, amount, type, reference, created_at FROM credit_transactions WHERE user_id = ? ORDER BY created_at DESC LIMIT 50",
  )
    .bind(userId)
    .all();

  return c.json({
    credits: user.credits,
    totalGenerations: user.total_generations,
    transactions,
  });
});

creditsRouter.post("/credits/webhook/sepay", async (c) => {
  const signature = c.req.header("X-SePay-Signature");

  if (!signature) {
    return c.json({ error: "Missing signature" }, 403);
  }

  const payload = await c.req.text();

  // Verify webhook signature (HMAC SHA-256)
  const expectedSignature = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(payload + c.env.SEPAY_WEBHOOK_SECRET),
  );

  const expectedHex = Array.from(new Uint8Array(expectedSignature))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");

  if (signature !== expectedHex) {
    console.error("Invalid webhook signature");
    return c.json({ error: "Invalid signature" }, 403);
  }

  // Parse and validate webhook payload with Zod
  let parsedData;
  try {
    const rawData = JSON.parse(payload);
    parsedData = sepayWebhookSchema.parse(rawData);
  } catch (error) {
    console.error("Invalid webhook payload:", error);
    return c.json({ error: "Invalid payload format" }, 400);
  }

  if (parsedData.status !== "success") {
    return c.json({ error: "Payment not successful" }, 400);
  }

  const userId = parsedData.metadata?.userId;
  const credits = Math.floor(parsedData.amount / 1000);

  if (!userId) {
    return c.json({ error: "Missing userId in metadata" }, 400);
  }

  if (credits < 1) {
    return c.json({ error: "Amount too low (min 1,000 VND)" }, 400);
  }

  const now = Date.now();

  await c.env.DB.batch([
    c.env.DB.prepare(
      "UPDATE users SET credits = credits + ?, updated_at = ? WHERE id = ?",
    ).bind(credits, now, userId),
    c.env.DB.prepare(
      "INSERT INTO credit_transactions (id, user_id, amount, type, reference, created_at) VALUES (?, ?, ?, ?, ?, ?)",
    ).bind(
      crypto.randomUUID(),
      userId,
      credits,
      "purchase",
      parsedData.transaction_id,
      now,
    ),
  ]);

  return c.json({ success: true, credits });
});
```

````

### 2.12 Testing with Mock Gemini (Recommended First)

Before using real Gemini API (costs money), test with mock:

```typescript
// src/routes/generate.ts (modify temporarily for testing)

// Step 1: Update import to include generateImageMock
import { generateImage, generateImageMock } from "../services/gemini";

// Step 2: Replace this line:
const outputImageData = await generateImage(
  c.env.GOOGLE_API_KEY,
  prompt,
  images,
  aspectRatio,
);

// With this for testing:
const outputImageData = await generateImageMock(prompt, images, aspectRatio);
````

**Testing Flow:**

1. ✅ Use `generateImageMock` for first 10 test generations (2s delay)
2. ✅ Verify credit deduction works correctly
3. ✅ Verify rate limiting enforces 10 req/min
4. ✅ Verify error handling + credit refunds work
5. ✅ Test timeout scenario (modify mock to delay 11s)
6. ✅ Switch to real `generateImage` function
7. ✅ Test with 1-2 real generations (costs ~$0.01)
8. ✅ Monitor response times in logs
9. ✅ Deploy to production if all tests pass

**Timeout Testing (Critical):**

```typescript
// Modify generateImageMock to simulate timeout:
export async function generateImageMock(
  prompt: string,
  images: ArrayBuffer[],
  aspectRatio: string,
): Promise<ArrayBuffer> {
  // Simulate worst-case 11-second Gemini call
  await new Promise((resolve) => setTimeout(resolve, 11000));
  // ... rest of mock code ...
}
```

Run this test locally with `wrangler dev` to verify:

- Credit refund happens automatically
- Error message shows "Generation failed"
- Job status changes to "failed"
- No output image created

### 2.13 Deploy Backend

```bash
cd workers

# Test locally first with mock Gemini
wrangler dev

# Test generation endpoint
curl -X POST https://localhost:8787/api/generate \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"prompt":"test","imageKeys":["uploads/user/test.png"],"aspectRatio":"1:1"}'

# Deploy to Cloudflare FREE tier
wrangler deploy

# Test endpoints
curl https://pikaai-api.YOUR-SUBDOMAIN.workers.dev/health
# Expected: {"status":"ok"}

# Verify environment
wrangler tail
# Watch logs in real-time
```

## Phase 3: Photoshop Plugin (Week 4-5)

### 3.1 Plugin Setup

```bash
cd plugin

# Initialize package.json
cat > package.json << 'EOF'
{
  "name": "pikaai-plugin",
  "version": "1.0.0",
  "description": "PikaAI - AI image generation for Vietnamese photographers",
  "scripts": {
    "build": "uxp-scripts build",
    "watch": "uxp-scripts watch",
    "package": "uxp-scripts package"
  },
  "dependencies": {
    "@adobe/react-spectrum": "^3.0.0",
    "react": "^18.0.0",
    "react-dom": "^18.0.0"
  },
  "devDependencies": {
    "@types/react": "^18.0.0",
    "@types/react-dom": "^18.0.0",
    "typescript": "^5.0.0",
    "uxp-scripts": "^1.0.0"
  }
}
EOF

bun install
```

### 3.2 UXP Manifest

```json
{
  "id": "vn.pikaai.photoshop",
  "name": "PikaAI",
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
      "reason": "Kết nối với API PikaAI để tạo ảnh"
    },
    {
      "apiName": "localStorage",
      "reason": "Lưu phiên đăng nhập người dùng"
    },
    {
      "apiName": "launchProcess",
      "reason": "Mở trình duyệt để đăng nhập Google"
    }
  ],
  "entrypoints": [
    {
      "type": "panel",
      "id": "main-panel",
      "label": "PikaAI",
      "minimumSize": { "width": 320, "height": 480 },
      "maximumSize": { "width": 600, "height": 1200 },
      "preferredDockedSize": { "width": 400, "height": 600 }
    }
  ],
  "icons": [
    {
      "width": 48,
      "height": 48,
      "path": "icons/icon-48.png"
    }
  ]
}
```

### 3.3 Plugin Implementation

Complete implementation files are too large for this document. See design.md for component code examples.

### 3.4 Load Plugin in Photoshop

1. Download UXP Developer Tool
2. Open tool, click "Add Plugin"
3. Select manifest.json
4. Click "Load" to open in Photoshop
5. Test generation flow

## Phase 4: Testing & Polish (Week 6)

### 4.1 Testing Checklist

**Authentication & Credits:**

- [ ] Google OAuth login flow
- [ ] Session token persistence
- [ ] New user gets 10 free credits
- [ ] Credit balance updates after generation
- [ ] Credit refund on generation failure

**Image Generation (Synchronous):**

- [ ] Upload single image (max 50MB)
- [ ] Upload multiple images (max 3)
- [ ] Generate with 1:1 aspect ratio
- [ ] Generate with 16:9 aspect ratio
- [ ] Response time 6-13 seconds
- [ ] Loading spinner during generation
- [ ] Error handling with credit refund

**Rate Limiting:**

- [ ] 10 generations per minute enforced
- [ ] 429 error with retryAfter on limit
- [ ] Rate limit resets after 60 seconds

**Cross-Platform:**

- [ ] Plugin works on macOS Photoshop
- [ ] Plugin works on Windows Photoshop
- [ ] Generated image imports correctly
- [ ] Vietnamese UI displays correctly

**Input Validation (Zod):**

- [ ] Prompt too short (<10 chars) rejected
- [ ] Prompt too long (>1000 chars) rejected
- [ ] Invalid aspect ratio rejected
- [ ] Invalid image key format rejected
- [ ] File size >50MB rejected
- [ ] Non-image file types rejected
- [ ] SePay webhook invalid signature rejected
- [ ] Vietnamese error messages displayed

**Edge Cases:**

- [ ] Insufficient credits error (402)
- [ ] Gemini API timeout handling
- [ ] Network failure recovery
- [ ] Invalid image format rejection

### 4.2 Deployment Checklist

**Infrastructure:**

- [ ] Domain pikaai.vn configured (Cloudflare)
- [ ] SSL certificate active (auto via Cloudflare)
- [ ] R2 bucket created: pikaai-images
- [ ] D1 database created: pikaai-db
- [ ] Database migrations applied

**Secrets & Environment:**

- [ ] GOOGLE_CLIENT_ID set in wrangler.toml
- [ ] GOOGLE_CLIENT_SECRET set via wrangler secret
- [ ] GOOGLE_API_KEY set via wrangler secret
- [ ] SEPAY_API_KEY set via wrangler secret (optional for MVP)
- [ ] SEPAY_WEBHOOK_SECRET set via wrangler secret (optional)

**Workers Deployment:**

- [ ] wrangler deploy successful
- [ ] /health endpoint returns 200
- [ ] CORS allows pikaai.vn domain
- [ ] Rate limiting middleware active

**Plugin Distribution:**

- [ ] UXP plugin packaged (.ccx file)
- [ ] Manifest uses vn.pikaai.photoshop ID
- [ ] Vietnamese permissions descriptions
- [ ] Icon files included (48px)

**Monitoring (Post-MVP):**

- [ ] Cloudflare Analytics enabled
- [ ] Workers logs monitored
- [ ] Track 10s timeout errors for upgrade trigger

## Phase 5: FREE Tier Limitations & Upgrade Path

### 5.1 FREE Tier Risks & Troubleshooting

**10-Second CPU Timeout Risk:**

- Gemini API calls: 6-13 seconds (measured)
- FREE tier limit: 10 seconds CPU time
- **Risk**: Timeouts on slower API calls or high concurrency

**When Timeout Errors Occur:**

1. User sees "Generation failed" with credit refund
2. Job marked as "failed" in database
3. Error logged: "Worker exceeded CPU time limit"

**Troubleshooting Steps:**

```bash
# 1. Check error rate in logs
wrangler tail --format json | grep "exceeded CPU"

# 2. Calculate timeout error rate
# If errors > 5 per 100 requests = UPGRADE NEEDED

# 3. Quick fixes before upgrading:
# - Reduce image resolution before upload (max 2048px)
# - Use gemini-2.0-flash-exp (faster than Pro)
# - Limit to 2 images instead of 3
# - Add timeout handling in code:
```

```typescript
// Add to generate route before Gemini call:
const timeoutPromise = new Promise((_, reject) =>
  setTimeout(() => reject(new Error("Timeout approaching")), 9000),
);

try {
  const outputImageData = await Promise.race([
    generateImage(c.env.GOOGLE_API_KEY, prompt, images, aspectRatio),
    timeoutPromise,
  ]);
} catch (error) {
  // Log and upgrade if this happens frequently
  console.error("Near timeout:", error);
  // ... refund logic ...
}
```

**Monitoring Trigger:**

- If timeout error rate >5%
- Upgrade to Workers Paid plan ($5/mo)
- Gets 30-second CPU timeout instead

### 5.2 Upgrade Path

```bash
# When ready to upgrade (after validating with 10-20 users)
# No code changes needed - just billing change in dashboard

# Cloudflare Workers Paid: $5/mo
# Benefits:
# - 30s CPU timeout (vs 10s)
# - 10M requests/mo (vs 100K)
# - Can add Queues later if needed
```

### 5.3 Cost Management

**FREE Tier MVP (Weeks 1-8):**

- Cloudflare: $0/mo (FREE tier)
- Gemini API: ~$50-150/mo (10-20 beta users × 100 generations)
- **Total**: $50-150/mo

**After Validation (Month 3+):**

- Cloudflare Workers Paid: $5/mo
- Cloudflare R2: $0.36/GB stored + $0.36/GB egress
- Cloudflare D1: FREE (under 5GB)
- Gemini API: ~$1,500-3,000/mo (50K photographers × 2% adoption)
- **Total**: ~$1,500-3,000/mo

**Daily Monitoring Dashboard:**

- Total API calls today
- Credits consumed today
- Error rate (target: <5%)
- Timeout errors (trigger: upgrade at >5%)
- Average response time (target: 6-9s)

**Summary:** 6-week FREE tier MVP with synchronous processing, upgrade when timeout errors exceed 5%

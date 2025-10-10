# PikaAI - Project Specification

> **Brutal Reality:** This is a $10K+ complexity project requiring 7 weeks of focused development. Read the entire spec before committing.

## Overview

**PikaAI** - Hybrid AI creative tool for Vietnamese photographers: Photoshop plugin + SolidJS web dashboard integrating Google Gemini 2.5 Flash Image (Nano Banana) for AI-powered image generation and editing.

**Brand:** "PikaAI - Công cụ AI tạo ảnh thông minh cho nhiếp ảnh gia Việt" (Smart AI image tool for Vietnamese photographers)

**Key Differentiators:**

- Character consistency across multiple generations (perfect for wedding photography)
- Multi-image composition (up to 3 images)
- Conversational editing workflow
- Visual reasoning capabilities
- 10 aspect ratio options
- **Vietnamese-first UI** with VND pricing
- **SePay integration** (35x cheaper than Stripe for Vietnam)

**Infrastructure:** Cloudflare Workers + R2 + D1 + Queues + KV + Durable Objects

**Architecture:** Hybrid approach - Minimal React plugin (UXP compatibility) + Powerful SolidJS/Solid Start web dashboard

## Project Structure

```
specs/photoshop-gemini-plugin/
├── README.md                    ← You are here (Overview)
├── requirements.md              ← Requirements & User Stories
├── design.md                    ← Architecture & Technical Design
├── implementation-guide.md      ← Step-by-Step Implementation
└── vietnamese-market-guide.md   ← Vietnam-Specific Guide
```

**Implementation Structure:**

```
pikaai/
├── plugin/                      # Photoshop UXP Plugin (React)
│   ├── src/
│   │   ├── panels/
│   │   │   └── MainPanel.jsx
│   │   ├── api/
│   │   │   └── client.ts
│   │   └── photoshop/
│   │       ├── export.ts
│   │       └── import.ts
│   └── manifest.json
│
├── dashboard/                   # Web Dashboard (SolidJS + Solid Start)
│   ├── src/
│   │   ├── routes/
│   │   │   ├── index.tsx
│   │   │   ├── credits.tsx
│   │   │   ├── history.tsx
│   │   │   └── api/
│   │   │       └── sepay/
│   │   │           └── webhook.ts
│   │   ├── components/
│   │   └── locales/
│   │       ├── vi.json          # Vietnamese
│   │       └── en.json          # English
│   └── app.config.ts
│
└── workers/                     # Cloudflare Workers
    ├── src/
    │   ├── routes/
    │   └── queue-consumer.ts
    └── wrangler.toml
```

## Quick Links

- **Requirements:** [requirements.md](./requirements.md) - Functional/non-functional requirements, user stories, constraints
- **Design:** [design.md](./design.md) - System architecture, API design, database schema
- **Implementation:** [implementation-guide.md](./implementation-guide.md) - Code examples, setup scripts, deployment

## The Brutal Truth

### Why This Is Hard

**1. You're Competing With Adobe**

- Photoshop already has Adobe Firefly integrated
- Adobe controls the platform (can break your plugin anytime)
- Users already pay $55/mo for Creative Cloud

**2. API Economics Are Brutal**

- Gemini API costs $0.05-0.10 per generation
- At 1,000 generations/day: $1,500-3,000/mo API costs
- Cloudflare costs: ~$10/mo (0.3% of total)
- Need credit system + payment processing

**3. Photoshop Plugin Development Sucks**

- UXP (Unified Extensibility Platform) is clunky
- Limited APIs, breaking changes between versions
- JavaScript/React only (no native performance)
- Adobe review process takes weeks

**4. Technical Nightmares**

- Can't store API keys in plugin (need cloud proxy)
- 3-10s generation latency (feels slow in Photoshop)
- Gemini outputs flat images, Photoshop uses layers
- Rate limits, quotas, auth complexity

**5. Market Reality**

- Small niche: Photoshop users who want Gemini specifically
- Most users stick with built-in Adobe Firefly
- Hard to monetize (Adobe Marketplace takes 30% cut)

### Why This Could Work

**Gemini's Unique Advantages:**

1. **Character Consistency** - Firefly struggles, Gemini excels
2. **Multi-Image Composition** - Unique workflow Adobe doesn't have
3. **Visual Reasoning** - Interprets sketches, diagrams, complex instructions
4. **Conversational Editing** - True multi-turn refinement
5. **World Knowledge** - "Make it look like Wes Anderson film"

**Valid Use Cases:**

- Storyboarding (same character across scenes)
- Product mockups (fuse product into environments)
- Brand asset generation (consistent style)
- Sketch-to-render (concepts to polished images)

## Architecture Overview (MVP - Synchronous)

```
┌─────────────────────────────────────────────┐
│ PHOTOSHOP PLUGIN (React + UXP)              │
│ - Minimal UI (trigger generations)          │
│ - Layer export/import                       │
│ - Loading state (6-13s wait)                │
└─────────────────┬───────────────────────────┘
                  │ API Calls
┌─────────────────▼───────────────────────────┐
│ WEB DASHBOARD (SolidJS + Solid Start)       │
│ - Credit purchase (SePay/VietQR)            │
│ - Job history + analytics                   │
│ - Vietnamese UI (primary)                   │
│ - Payment invoices                          │
│ - Mobile-responsive                         │
└─────────────────┬───────────────────────────┘
                  │ HTTPS (JWT Auth)
┌─────────────────▼───────────────────────────┐
│ CLOUDFLARE WORKERS (Synchronous Processing) │
│ ┌─────────────────────────────────────────┐ │
│ │ /api/generate (Sync - no queues)        │ │
│ │ 1. Upload to R2                         │ │
│ │ 2. Call Gemini API (WAIT 3-10s)         │ │
│ │ 3. Store result in R2                   │ │
│ │ 4. Return immediately                   │ │
│ └─────────────────────────────────────────┘ │
│ - Auth routes                               │
│ - SePay webhook handler                     │
└─────────────────┬───────────────────────────┘
                  │
     ┌────────────┼────────────┐
     ▼            ▼            ▼
┌─────────┐  ┌────────┐  ┌──────────────┐
│ R2      │  │ D1     │  │ Gemini API   │
│ Images  │  │ Users  │  │ (Sync call)  │
└─────────┘  └────────┘  └──────────────┘
```

**Why Synchronous for MVP:**

- ✅ **Simpler** - No queue complexity
- ✅ **Cheaper** - Free tier works (with 10s timeout risk)
- ✅ **Faster to build** - 1 week less development
- ✅ **Immediate results** - No polling needed
- ⚠️ **10s timeout risk** - Gemini must respond fast on free tier
- ⚠️ **No retry logic** - User must click again if failed

**Upgrade Path:** Add queues later when you have 500+ users or revenue to justify $5/mo paid plan

## Cost Breakdown

### MVP (Free Tier - Testing Only)

| Service            | Cost (USD) | Limits                              |
| ------------------ | ---------- | ----------------------------------- |
| Cloudflare Workers | **FREE**   | 10s CPU timeout ⚠️                  |
| R2 Storage         | **FREE**   | 10GB storage, 1M reads              |
| D1 Database        | **FREE**   | 5GB, 5M reads, 100K writes          |
| **TOTAL**          | **$0**     | **Good for 50-100 beta users only** |

⚠️ **Critical Limitation:** Free tier has **10s CPU timeout**. Gemini API takes 3-10s. You WILL hit timeouts occasionally.

**Free Tier Strategy:**

1. Build MVP on free tier
2. Test with mock Gemini responses first
3. Upgrade to paid ($5/mo) when testing real Gemini calls
4. Gemini API costs start when you go live (~$100-500/mo)

### Production (Paid Tier - Recommended)

**Monthly at 1,000 gen/day:**

| Service              | Cost (USD)       |
| -------------------- | ---------------- |
| Cloudflare Workers   | $5               |
| R2 Storage           | $3               |
| D1 Database          | Free             |
| Durable Objects      | $0.05            |
| **Cloudflare Total** | **$8.05**        |
| Gemini API           | **$1,500-3,000** |
| SePay (VPBank PRO)   | **$30**          |
| **TOTAL**            | **$1,538-3,038** |

**Paid tier benefits:** 30s CPU timeout (required for reliable Gemini calls)

**vs Stripe Alternative:** $1,200/mo in fees (3.9% of $30K revenue) → **SePay saves $1,170/month (97% cheaper)**

### Vietnamese Market Pricing (VND)

**Credit Packages:**

| Credits | VND Price  | USD Equiv | Cost/Credit | Best For                     |
| ------- | ---------- | --------- | ----------- | ---------------------------- |
| 10      | 30.000đ    | ~$1.20    | 3.000đ      | Thử nghiệm (Trial)           |
| 50      | 140.000đ   | ~$5.60    | 2.800đ      | Phổ biến nhất (Most Popular) |
| 100     | 250.000đ   | ~$10      | 2.500đ      | Tiết kiệm (Save Money)       |
| 500     | 1.000.000đ | ~$40      | 2.000đ      | Studio chuyên nghiệp (Pro)   |

**Profitability:**

- Gemini API cost: $0.10/generation
- Your cost (all-in): $0.08/generation
- Sell price: $0.10-0.12/generation
- **Margin: 20-50%** (sustainable for Vietnam market)

## Technology Stack

### Backend (Cloudflare)

- **Runtime:** Cloudflare Workers (V8 isolates)
- **Framework:** Hono (lightweight HTTP router)
- **Database:** D1 (SQLite at edge)
- **Storage:** R2 (S3-compatible object storage)
- **Processing:** Synchronous (no queues for MVP)
- **Rate Limiting:** Simple in-memory (upgrade to Durable Objects later)

### Frontend (Dual Stack)

**Photoshop Plugin (Minimal):**

- **Runtime:** UXP (Unified Extensibility Platform)
- **Framework:** React + React Spectrum (Adobe's UI for UXP compatibility)
- **Language:** TypeScript
- **Photoshop API:** v24+ (manifest v5)
- **Purpose:** Trigger generations, import results only

**Web Dashboard (Full-Featured):**

- **Framework:** SolidJS + Solid Start (SSR, file-based routing)
- **Language:** TypeScript
- **Styling:** TailwindCSS
- **i18n:** solid-i18next (Vietnamese + English)
- **Purpose:** Credit management, history, payments, analytics

### External Services

- **AI:** Google Gemini 2.5 Flash Image
- **Auth:** Google OAuth 2.0
- **Payments:** SePay (Vietnamese bank transfers + VietQR)
- **Support:** Zalo OA (Vietnamese messaging)

## Timeline & Milestones (FREE Tier MVP)

### Week 1: Infrastructure Setup (FREE)

- Cloudflare FREE account setup
- Workers project structure
- D1 database schema with Vietnamese fields
- R2 bucket creation
- **No queue setup** (not needed for MVP)

### Week 2: Backend Implementation (Synchronous)

- Authentication routes (Google OAuth + JWT)
- Upload routes (R2 streaming)
- **Generation route (SYNCHRONOUS - no queue)**
- Simple rate limiting (in-memory)
- Mock Gemini responses for testing

### Week 3: Real Gemini Integration

- Replace mock with real Gemini API calls
- **Test on FREE tier** (expect occasional 10s timeouts)
- Error handling (no retry, just fail gracefully)
- Credit deduction + refund on failure

### Week 4: Photoshop Plugin (Minimal)

- UXP manifest configuration
- React UI (login, trigger, loading spinner)
- Layer export/import
- 6-13s loading state
- ~400 lines total (simpler without polling)

### Week 5: Web Dashboard (SolidJS)

- Solid Start setup with SSR
- Credit purchase flow (SePay/VietQR)
- Job history + analytics
- Vietnamese i18n (vi.json)
- Mobile-responsive UI

### Week 6: Testing & Launch Beta

- E2E testing (plugin → dashboard → generation)
- Test 10s timeout edge cases
- Deploy on FREE tier
- Recruit 10-20 beta testers
- **Decision point:** Upgrade to paid if timeout issues

**Total:** 6 weeks to FREE tier MVP → Upgrade to paid ($5/mo) when proven

## Development Environment

### Required Tools

- **Wrangler CLI** - Cloudflare deployment
- **UXP Developer Tool** - Photoshop plugin testing
- **Bun** - JavaScript runtime
- **Git** - Version control
- **Photoshop 2024+** - Target platform

### Required Accounts

**MVP (Free Tier):**

- Cloudflare FREE account
- Google Cloud account FREE tier (OAuth + Gemini API)
- **SePay FREE account** (start with manual credit top-up)
- Adobe Developer account (free)

**Production (When Scaling):**

- Cloudflare Workers Paid ($5/mo) - needed when free tier timeouts become problem
- SePay VPBank PRO ($30/mo) - needed when >100 txn/month
- Vietnamese bank account (for SePay auto-webhook)

### Environment Variables

```bash
# Cloudflare Workers
GOOGLE_CLIENT_ID=xxx.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=xxx
GOOGLE_API_KEY=AIzaXXX
SEPAY_API_KEY=xxx
SEPAY_WEBHOOK_SECRET=xxx

# Web Dashboard (Solid Start)
VITE_API_URL=https://api.pikaai.vn
VITE_DASHBOARD_URL=https://pikaai.vn
PUBLIC_SEPAY_ACCOUNT_NUMBER=1234567890
PUBLIC_SEPAY_BANK=MBBank
PUBLIC_BRAND_NAME=PikaAI

# Photoshop Plugin
VITE_DASHBOARD_URL=https://pikaai.vn
VITE_BRAND_NAME=PikaAI
```

## Success Metrics

### Phase 1: MVP (Week 6)

- [ ] 50 beta users
- [ ] 100 successful generations
- [ ] < 5% error rate
- [ ] Break-even on API costs

### Phase 2: Growth (Month 3)

- [ ] 500 active users
- [ ] 5,000 generations/month
- [ ] $500-1,000 MRR
- [ ] 20% free-to-paid conversion

### Phase 3: Scale (Month 6)

- [ ] 2,000 active users
- [ ] 20,000 generations/month
- [ ] $3,000-5,000 MRR
- [ ] 30% profit margin

## Risks & Mitigation

### Critical Risks

**1. Adobe API Breaking Changes**

- **Mitigation:** Version compatibility matrix, rapid updates

**2. Gemini API Cost Overruns**

- **Mitigation:** Aggressive caching, rate limiting, prepaid credits

**3. User Abuse**

- **Mitigation:** Durable Objects rate limiting, CAPTCHA, monitoring

**4. UXP Plugin Crashes**

- **Mitigation:** Image size validation, memory monitoring, error boundaries

**5. Cloudflare Outages**

- **Mitigation:** Multi-region deployment, queue persistence

## Getting Started

### 1. Read the Specs

- [ ] Read [requirements.md](./requirements.md) completely
- [ ] Review [design.md](./design.md) architecture
- [ ] Skim [implementation-guide.md](./implementation-guide.md)

### 2. Validate Feasibility

- [ ] Test Gemini API with your prompts
- [ ] Confirm Photoshop version compatibility
- [ ] Verify Cloudflare free tier limits
- [ ] Calculate your break-even point

### 3. Start Building

- [ ] Follow implementation-guide.md Phase 1 (Infrastructure)
- [ ] Deploy backend to Cloudflare
- [ ] Build plugin prototype
- [ ] Test end-to-end flow

### 4. Launch Beta

- [ ] Recruit 10-20 beta testers
- [ ] Monitor error rates and costs
- [ ] Iterate on feedback
- [ ] Prepare for Adobe Marketplace submission

## Why Hybrid Architecture is Superior

### ✅ Best of Both Worlds

**Plugin (React + UXP):**

- Direct Photoshop integration (layer access)
- One-click generation from selected layers
- Seamless import as new layer
- Native Photoshop UI (React Spectrum)

**Dashboard (SolidJS + Solid Start):**

- Complex features without UXP limitations
- Mobile access (check status on phone)
- SePay payment integration
- Vietnamese UI optimization
- Team collaboration features
- Analytics and reporting

### ❌ Why Not Pure Plugin?

- UXP can't handle payment processing well
- Limited storage for job history
- No mobile access
- Complex UI is slow in UXP

### ❌ Why Not Pure Web App?

- Manual export/import is clunky
- Can't access Photoshop layers directly
- Less professional integration
- Photographers want native tools

## Support & Resources

### Documentation

- [Gemini API Docs](https://ai.google.dev/gemini-api/docs/image-generation)
- [Cloudflare Workers Docs](https://developers.cloudflare.com/workers/)
- [Adobe UXP Docs](https://developer.adobe.com/photoshop/uxp/)

### Community

- Cloudflare Discord
- Adobe Developer Forum
- r/photoshop

### Learning Resources

- [UXP Plugin Samples](https://github.com/AdobeDocs/uxp-photoshop-plugin-samples)
- [Cloudflare Workers Examples](https://developers.cloudflare.com/workers/examples/)
- [Gemini Cookbook](https://github.com/google-gemini/cookbook)

## Final Recommendation

**FREE Tier MVP Strategy:**

✅ **Start FREE** - Build entire MVP on Cloudflare FREE tier
✅ **Test with mocks** - Mock Gemini responses first
✅ **10-20 beta users** - Validate market fit before paying
✅ **Upgrade when proven** - Switch to paid ($5/mo) when you have users
✅ **Zero upfront cost** - Pay only when you make money

**Build This If:**

- You're targeting **Vietnamese photographers** (wedding, portrait, studio)
- You understand **Vietnamese market psychology** (VND pricing, bank transfers)
- You can **ship MVP in 6 weeks** with synchronous processing
- You're **willing to test on FREE tier** (10s timeout risk acceptable)
- You can provide **Vietnamese support** or learn Vietnamese
- You're **bootstrap-minded** (no upfront costs)

**Don't Build This If:**

- You don't speak Vietnamese (market is 95% Vietnamese-speaking)
- You expect passive income (requires active support)
- You need 100% uptime (free tier has 10s timeout risk)
- You can't handle "try it, iterate fast" approach
- You're not technical enough for Cloudflare + SolidJS

**Why FREE Tier Works for MVP:**

✅ **Validate market** - Test with 10-20 users before spending
✅ **Learn Vietnamese needs** - Iterate based on real feedback
✅ **Prove Gemini value** - Show character consistency works
✅ **Build reputation** - Get testimonials and case studies
✅ **Then scale paid** - Upgrade when you have revenue

**Upgrade Triggers:**

| Trigger          | Action                  | Cost     |
| ---------------- | ----------------------- | -------- |
| 10s timeouts >5% | Upgrade to Workers Paid | +$5/mo   |
| >100 beta users  | Upgrade to Workers Paid | +$5/mo   |
| >100 payments/mo | Upgrade SePay           | +$30/mo  |
| Making $500/mo   | Hire Vietnamese VA      | +$200/mo |

---

**Summary:** Start with FREE tier (6 weeks, $0 upfront). Synchronous Gemini calls with 10s timeout risk. Test with 10-20 Vietnamese photographers. Upgrade to paid ($5/mo) when proven. SePay saves 97% vs Stripe. Target 50K Vietnamese photographers with zero risk, iterate until product-market fit, then scale to $50K MRR.

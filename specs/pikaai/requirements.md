# PikaAI - Requirements

## Project Overview

**Name:** PikaAI (Photoshop AI Plugin + Web Dashboard)  
**Brand:** "PikaAI - Công cụ AI tạo ảnh thông minh cho nhiếp ảnh gia Việt"  
**Target Market:** Vietnamese photographers (wedding, portrait, studio photography)  
**Architecture:** Hybrid - Minimal React plugin + SolidJS web dashboard  
**Infrastructure:** Cloudflare FREE tier (Workers, R2, D1) → Paid when scaling  
**Processing:** Synchronous (no queues for MVP)  
**Payment:** SePay (Vietnamese bank transfers + VietQR)  
**Timeline:** 6 weeks to FREE tier MVP → Upgrade to paid when proven  
**Domain:** pikaai.vn (Vietnamese market focus)  
**Strategy:** Zero upfront cost, validate with 10-20 beta users first

## Problem Statement

### Global Problem

Current image generation tools lack conversational editing capabilities. Adobe Firefly is integrated into Photoshop but struggles with:

- Character consistency across multiple generations (crucial for wedding photos)
- Multi-image composition workflows
- Complex visual reasoning tasks
- Iterative refinement through natural language

### Vietnamese Market Problem

Vietnamese photographers face additional challenges:

- **No AI tools targeting Vietnamese market** (all English-only)
- **Payment friction**: Stripe unavailable/expensive (3.9% fees vs bank transfer)
- **Price sensitivity**: Western pricing ($20/mo) = 1 week salary for many
- **Mobile-first workflow**: Need to check status on phone, not just desktop
- **Language barrier**: English UI blocks adoption

### Solution

Gemini 2.5 Flash Image + Hybrid architecture + SePay integration solves:

- Character consistency (wedding photography use case)
- Vietnamese UI (primary language)
- VND pricing (30.000đ instead of $1.20)
- Bank transfer payments (0.2% cost vs 3.9%)
- Mobile dashboard (check status anywhere)
- Professional wedding workflows (batch generation)

## Core Requirements

### Functional Requirements

#### FR1: User Authentication

- Google OAuth login
- Session management with JWT tokens
- Secure token storage in UXP secure storage
- 30-day session expiration

#### FR2: Image Upload

- Export Photoshop layers as PNG/JPEG
- Support up to 3 images (multi-image fusion)
- Handle images up to 50MB (UXP memory limit)
- Stream upload to R2 (bypass Worker 6MB limit)

#### FR3: Image Generation

- Natural language prompts
- 10 aspect ratio options (1:1, 16:9, 9:16, 4:3, 3:4, etc.)
- Character consistency mode
- Multi-image composition mode
- Conversational editing (multi-turn refinement)

#### FR4: Job Management

- Async job processing via Cloudflare Queues
- Real-time status polling (pending → processing → completed/failed)
- Job history tracking
- Retry logic for failed jobs (up to 3 attempts)

#### FR5: Credit System

- 10 free credits on signup
- Credit deduction before generation
- Insufficient credits error handling
- Credit purchase integration (Stripe)

#### FR6: Result Import

- Download generated images from R2
- Import as new Photoshop layer
- Preserve layer naming and metadata

#### FR7: Vietnamese Language Support (NEW)

- Primary UI language: Vietnamese (vi)
- Fallback language: English (en)
- VND pricing display (primary)
- USD pricing (reference only)
- Vietnamese error messages
- Localized date/time formats (DD/MM/YYYY)

#### FR8: SePay Payment Integration (NEW)

- Display VietQR code for bank transfer
- Show bank account details (account number, bank name)
- Generate payment memo with user ID + credit amount
- Webhook receiver for transaction notifications
- Automatic credit addition (10-30s after transfer)
- Payment invoice generation (Vietnamese VAT format)
- Support major Vietnamese banks (MBBank, TPBank, VPBank, BIDV, etc.)

#### FR9: Web Dashboard (NEW)

- Credit purchase flow (SePay/VietQR)
- Job history with filters
- Usage analytics (daily/monthly charts)
- Payment history + invoices
- Account settings
- Mobile-responsive design
- Offline capability (service worker)
- Vietnamese tax invoice generation

#### FR10: Photographer Workflows (NEW)

- Batch generation (same prompt, multiple styles)
- Wedding preset templates (Vietnamese wedding styles)
- Character consistency workflow (bride/groom across scenes)
- Vietnamese prompt suggestions
- Save favorite prompts
- Share results with clients (shareable links)

### Non-Functional Requirements

#### NFR1: Performance

- Upload latency: < 5s for 10MB images
- Job creation: < 500ms
- Status polling: 2s intervals
- Total generation time: 5-15s (Gemini API dependent)

#### NFR2: Scalability

- Support 10,000 active users on free tier
- Handle 1,000 generations/day without infrastructure scaling
- Queue-based architecture for burst handling

#### NFR3: Security

- No API keys in plugin code
- Secure server-side proxy
- Rate limiting: 10 requests/minute per user
- Input validation and sanitization

#### NFR4: Reliability

- 99.9% uptime for Workers API
- Automatic retry for transient failures
- Dead letter queue for failed jobs
- Graceful degradation on API outages

#### NFR5: Cost Efficiency

- Image caching for identical prompts (30% savings)
- R2 storage optimization (JPEG compression)
- Queue batching to reduce operations
- Free tier Cloudflare services where possible

#### NFR6: Cross-Platform Compatibility

- macOS Photoshop 2024+
- Windows Photoshop 2024+
- UXP manifest v5 compliance

## User Stories

### US1: First-Time User Setup

**As a** Photoshop user  
**I want to** authenticate with Google  
**So that** I can access Gemini image generation

**Acceptance Criteria:**

- OAuth flow completes in < 30s
- 10 free credits granted
- Session persists across Photoshop restarts

### US2: Basic Image Generation

**As a** designer  
**I want to** generate images from text prompts  
**So that** I can create visual concepts quickly

**Acceptance Criteria:**

- Input prompt in plugin panel
- Select aspect ratio
- Generate within 15s
- Import as new layer automatically

### US3: Character Consistency

**As a** illustrator  
**I want to** maintain same character across scenes  
**So that** I can create consistent storyboards

**Acceptance Criteria:**

- Upload reference image (character)
- Generate multiple variations
- Character features remain consistent
- Save character reference for reuse

### US4: Multi-Image Composition

**As a** product designer  
**I want to** combine product image with scene  
**So that** I can create realistic mockups

**Acceptance Criteria:**

- Select up to 3 Photoshop layers
- Upload all layers automatically
- Specify composition instructions
- Generate fused output

### US5: Conversational Editing

**As a** photo editor  
**I want to** refine generated images iteratively  
**So that** I can achieve exact desired result

**Acceptance Criteria:**

- Reference previous generation
- Request specific changes ("blur background", "change lighting")
- Maintain conversation history
- Unlimited refinements within session

### US6: Credit Management (SePay)

**As a** Vietnamese photographer  
**I want to** buy credits via bank transfer  
**So that** I can avoid credit card fees

**Acceptance Criteria:**

- Display VietQR code with bank details
- Show payment memo with user ID
- Credits added automatically after transfer (10-30s)
- Vietnamese invoice for tax reporting
- Price shown in VND (primary) and USD (reference)

### US7: Mobile Dashboard Access (NEW)

**As a** photographer on the go  
**I want to** check generation status on my phone  
**So that** I can monitor work while traveling to photoshoots

**Acceptance Criteria:**

- Dashboard works on mobile browsers
- Responsive UI for small screens
- Load fast on 3G/4G (< 3s)
- Show real-time job status
- Buy credits on mobile

### US8: Vietnamese Language Support (NEW)

**As a** Vietnamese photographer  
**I want to** use the app in Vietnamese  
**So that** I can understand all features clearly

**Acceptance Criteria:**

- All UI text in Vietnamese
- Vietnamese error messages
- VND pricing displayed prominently
- Vietnamese date/time format
- Vietnamese customer support (Zalo)

### US9: Wedding Photography Workflow (NEW)

**As a** wedding photographer  
**I want to** generate bride/groom in multiple scenes  
**So that** I can create consistent wedding albums

**Acceptance Criteria:**

- Select base photo (bride/groom)
- Generate in 5-10 different scenes
- Character appearance stays consistent
- Vietnamese wedding location presets (Hội An, Đà Lạt, etc.)
- Batch export to PSD layers

## Technical Constraints

### Cloudflare Workers

- 128MB memory limit
- 6MB request body limit
- 30s CPU time limit (paid plan)
- No built-in rate limiting

### Photoshop UXP

- JavaScript/React only (no native code)
- Limited Node.js APIs
- No streaming uploads
- 50MB file size crash threshold

### Gemini API

- Rate limit: 60 requests/minute
- Cost: ~$0.05-0.10 per generation
- Response time: 3-10s average
- Max 3 input images

### Browser Compatibility

- UXP uses Chromium-based renderer
- No service workers
- Limited localStorage (use UXP secure storage)

## Success Metrics

### Phase 1 (MVP - Week 6)

- 50 beta users
- 100 successful generations
- < 5% error rate
- Break-even on API costs

### Phase 2 (Growth - Month 3)

- 500 active users
- 5,000 generations/month
- $500-1,000 MRR
- 20% free-to-paid conversion

### Phase 3 (Scale - Month 6)

- 2,000 active users
- 20,000 generations/month
- $3,000-5,000 MRR
- 30% profit margin

## Out of Scope (V1)

- Batch generation (multiple prompts at once)
- Local model execution (offline mode)
- Video generation
- 3D model generation
- Fine-tuning custom models
- API access for developers
- Webhook notifications
- Mobile app integration

## Risks & Mitigation

### Risk 1: Adobe API Breaking Changes

**Impact:** High  
**Probability:** Medium  
**Mitigation:** Monitor Adobe UXP updates, maintain version compatibility matrix

### Risk 2: Gemini API Cost Overruns

**Impact:** Critical  
**Probability:** High  
**Mitigation:** Aggressive caching, rate limiting, credit system with prepayment

### Risk 3: User Abuse (API Spam)

**Impact:** Critical  
**Probability:** High  
**Mitigation:** Durable Objects rate limiting, CAPTCHA for signup, usage monitoring

### Risk 4: UXP Plugin Crashes

**Impact:** Medium  
**Probability:** Medium  
**Mitigation:** Image size validation, memory monitoring, graceful error handling

### Risk 5: Cloudflare Service Outages

**Impact:** Medium  
**Probability:** Low  
**Mitigation:** Multi-region deployment, status page, queue persistence

## Dependencies

### External Services

- Google OAuth (authentication)
- Google Gemini API (image generation)
- Cloudflare Workers/R2/D1/Queues (infrastructure)
- **SePay** (Vietnamese payment processing)
- Adobe UXP (plugin runtime)
- **Zalo OA** (Vietnamese customer support - optional)

### Development Tools

- Wrangler CLI (Cloudflare deployment)
- UXP Developer Tool (plugin testing)
- Bun (JavaScript runtime)
- TypeScript (type safety)
- **Solid Start** (web dashboard framework)
- **TailwindCSS** (styling)
- **solid-i18next** (internationalization)

### Vietnamese Market Requirements

- Vietnamese bank account (for SePay)
- Understanding of Vietnamese wedding photography market
- Vietnamese language support in team
- VietQR integration knowledge
- Vietnamese tax compliance (VAT invoices)

## Compliance & Legal

- GDPR compliance (user data handling)
- Google API Terms of Service
- Adobe Developer Program Terms
- Cloudflare Acceptable Use Policy
- Payment Card Industry (PCI) compliance via Stripe

## Budget Estimates

### Development (One-Time)

- Development time: 7 weeks @ $100/hr = $28,000
- Vietnamese UI/UX design: $1,500
- SePay integration testing: $500
- Beta testing (Vietnam): $500
- Vietnamese legal compliance: $1,000
- **Total:** $31,500

### Operational (Monthly at 1,000 gen/day)

| Service                   | Cost (USD)       | Notes             |
| ------------------------- | ---------------- | ----------------- |
| Cloudflare                | $10              | Workers + R2 + D1 |
| Gemini API                | $1,500-3,000     | Primary cost      |
| SePay (VPBank PRO)        | $30              | 500 txn/mo        |
| Vietnamese support (Zalo) | $200             | Part-time VA      |
| **Total**                 | **$1,740-3,240** |                   |

### vs Stripe Alternative

- Stripe fees: 3.9% of $30K revenue = $1,170/mo
- SePay fees: $30/mo (fixed)
- **Savings: $1,140/mo (97% cheaper)**

### Break-Even Analysis (Vietnamese Market)

**Target:** $3,000/mo revenue

- Average: 2.500đ per credit (~$0.10)
- Monthly: 30,000 credits sold
- Users: 1,000 active @ 30 credits/mo each

**Profitability:**

- Revenue: $3,000/mo
- Costs: $2,400 (Gemini) + $240 (other) = $2,640
- **Net: $360/mo profit** (12% margin)

**Scale to $10K/mo:**

- Need 3,300 active users
- Vietnam has 50,000+ professional photographers
- Target: 7% market penetration (achievable in 12 months)

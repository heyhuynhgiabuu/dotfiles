# Zalo AI Assistant - Authentication Specification

## Overview

This document defines the authentication and authorization system for the Zalo AI Assistant. The system uses Zalo OAuth for user authentication and JWT tokens for session management, following KISS principles.

## Authentication Architecture

### Core Principles

- **OAuth Integration**: Use Zalo OAuth for familiar Vietnamese user experience
- **Stateless Sessions**: JWT tokens for scalable session management
- **Security First**: Secure token handling and validation
- **Simple Flow**: Minimal steps for user authentication
- **Single Sign-On**: Leverage existing Zalo user accounts

### Authentication Flow

```
User → Login Button → Zalo OAuth → Authorization → Token Exchange → Session Created
```

## Zalo OAuth Integration

### OAuth Configuration

```typescript
// OAuth configuration
const ZaloOAuthConfig = {
  clientId: process.env.ZALO_APP_ID,
  clientSecret: process.env.ZALO_APP_SECRET,
  redirectUri: process.env.ZALO_REDIRECT_URI,
  scope: "id,name,picture",
  authEndpoint: "https://oauth.zaloapp.com/v4/permission",
  tokenEndpoint: "https://oauth.zaloapp.com/v4/access_token",
  userInfoEndpoint: "https://graph.zalo.me/v2.0/me",
};
```

### OAuth URLs

#### Authorization URL

```
https://oauth.zaloapp.com/v4/permission?
  app_id={APP_ID}&
  redirect_uri={REDIRECT_URI}&
  state={RANDOM_STATE}
```

#### Token Exchange URL

```
https://oauth.zaloapp.com/v4/access_token
```

**POST Parameters:**

- `app_id`: Zalo App ID
- `app_secret`: Zalo App Secret
- `code`: Authorization code from callback
- `grant_type`: "authorization_code"

#### User Info URL

```
https://graph.zalo.me/v2.0/me?access_token={ACCESS_TOKEN}&fields=id,name,picture
```

## Authentication Flow Implementation

### Step 1: Initiate OAuth Flow

**Frontend Action:**

```javascript
async function initiateZaloLogin() {
  // Generate state for CSRF protection
  const state = generateRandomString(32);
  localStorage.setItem("oauth_state", state);

  // Redirect to Zalo OAuth
  const authUrl = `/api/auth/zalo/redirect?state=${state}`;
  window.location.href = authUrl;
}
```

**Backend Handler:**

```typescript
export async function handleZaloRedirect(c: Context) {
  const state = c.req.query("state");

  // Build authorization URL
  const authUrl = new URL("https://oauth.zaloapp.com/v4/permission");
  authUrl.searchParams.set("app_id", ZaloOAuthConfig.clientId);
  authUrl.searchParams.set("redirect_uri", ZaloOAuthConfig.redirectUri);
  authUrl.searchParams.set("state", state);

  return c.redirect(authUrl.toString());
}
```

### Step 2: Handle OAuth Callback

**Backend Callback Handler:**

```typescript
export async function handleZaloCallback(c: Context) {
  const { code, state } = c.req.query();

  // Validate state parameter
  if (!code || !state) {
    return c.json({ error: "Invalid callback parameters" }, 400);
  }

  try {
    // Exchange code for access token
    const tokenResponse = await fetch(
      "https://oauth.zaloapp.com/v4/access_token",
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          app_id: ZaloOAuthConfig.clientId,
          app_secret: ZaloOAuthConfig.clientSecret,
          code,
          grant_type: "authorization_code",
        }),
      },
    );

    const tokenData = await tokenResponse.json();

    if (tokenData.error) {
      throw new Error(tokenData.error.message);
    }

    // Get user information
    const userResponse = await fetch(
      `https://graph.zalo.me/v2.0/me?access_token=${tokenData.access_token}&fields=id,name,picture`,
    );

    const userData = await userResponse.json();

    // Create or update user in database
    const user = await createOrUpdateUser({
      zalo_id: userData.id,
      name: userData.name,
      avatar_url: userData.picture?.data?.url,
      access_token: tokenData.access_token,
      refresh_token: tokenData.refresh_token,
      token_expires_at: Date.now() + tokenData.expires_in * 1000,
    });

    // Generate JWT token
    const jwtToken = await generateJWT({
      sub: user.id,
      zalo_id: user.zalo_id,
      role: "user",
    });

    // Create session
    await createSession({
      user_id: user.id,
      token_hash: await hashToken(jwtToken),
      expires_at: Date.now() + 7 * 24 * 60 * 60 * 1000, // 7 days
      ip_address: c.req.header("CF-Connecting-IP"),
      user_agent: c.req.header("User-Agent"),
    });

    // Redirect to dashboard with token
    return c.redirect(`/dashboard?token=${jwtToken}`);
  } catch (error) {
    return c.json({ error: "Authentication failed" }, 500);
  }
}
```

### Step 3: JWT Token Management

**JWT Token Structure:**

```typescript
interface JWTPayload {
  sub: string; // User ID
  iat: number; // Issued at
  exp: number; // Expires at
  role: string; // User role
  zalo_id: string; // Zalo user ID
}
```

**Token Generation:**

```typescript
import { SignJWT } from "jose";

async function generateJWT(
  payload: Omit<JWTPayload, "iat" | "exp">,
): Promise<string> {
  const secret = new TextEncoder().encode(process.env.JWT_SECRET);

  return await new SignJWT(payload)
    .setProtectedHeader({ alg: "HS256" })
    .setIssuedAt()
    .setExpirationTime("7d")
    .sign(secret);
}
```

**Token Validation:**

```typescript
import { jwtVerify } from "jose";

async function validateJWT(token: string): Promise<JWTPayload | null> {
  try {
    const secret = new TextEncoder().encode(process.env.JWT_SECRET);
    const { payload } = await jwtVerify(token, secret);
    return payload as JWTPayload;
  } catch (error) {
    return null;
  }
}
```

## Session Management

### Session Storage

Sessions are stored in the database with the following information:

```typescript
interface Session {
  id: string;
  user_id: string;
  token_hash: string; // SHA-256 hash of JWT token
  expires_at: number; // Unix timestamp
  ip_address?: string; // Client IP address
  user_agent?: string; // Client user agent
  is_active: boolean; // Session status
  created_at: number; // Creation timestamp
  last_used_at: number; // Last usage timestamp
}
```

### Session Operations

**Create Session:**

```typescript
async function createSession(
  sessionData: Omit<
    Session,
    "id" | "created_at" | "last_used_at" | "is_active"
  >,
): Promise<Session> {
  const session = {
    id: generateId(),
    ...sessionData,
    is_active: true,
    created_at: Date.now(),
    last_used_at: Date.now(),
  };

  await db.insert(sessions).values(session);
  return session;
}
```

**Validate Session:**

```typescript
async function validateSession(token: string): Promise<Session | null> {
  // Validate JWT token first
  const payload = await validateJWT(token);
  if (!payload) return null;

  // Check session in database
  const tokenHash = await hashToken(token);
  const session = await db
    .select()
    .from(sessions)
    .where(
      and(
        eq(sessions.token_hash, tokenHash),
        eq(sessions.is_active, true),
        gt(sessions.expires_at, Date.now()),
      ),
    )
    .get();

  if (!session) return null;

  // Update last used timestamp
  await db
    .update(sessions)
    .set({ last_used_at: Date.now() })
    .where(eq(sessions.id, session.id));

  return session;
}
```

**Invalidate Session:**

```typescript
async function invalidateSession(token: string): Promise<void> {
  const tokenHash = await hashToken(token);

  await db
    .update(sessions)
    .set({ is_active: false })
    .where(eq(sessions.token_hash, tokenHash));
}
```

## Authentication Middleware

### Request Authentication

```typescript
export async function authMiddleware(c: Context, next: () => Promise<void>) {
  const authHeader = c.req.header("Authorization");

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return c.json({ error: "Authentication required" }, 401);
  }

  const token = authHeader.substring(7);
  const session = await validateSession(token);

  if (!session) {
    return c.json({ error: "Invalid or expired token" }, 401);
  }

  // Get user data
  const user = await db
    .select()
    .from(users)
    .where(eq(users.id, session.user_id))
    .get();

  if (!user || user.status !== "active") {
    return c.json({ error: "User account not active" }, 403);
  }

  // Add user to context
  c.set("user", user);
  c.set("session", session);

  await next();
}
```

### Route Protection

```typescript
// Protected route example
app.get("/api/users/profile", authMiddleware, async (c) => {
  const user = c.get("user");
  return c.json({ success: true, data: user });
});

// Optional authentication
app.get("/api/public/stats", async (c) => {
  const authHeader = c.req.header("Authorization");
  let user = null;

  if (authHeader?.startsWith("Bearer ")) {
    const token = authHeader.substring(7);
    const session = await validateSession(token);
    if (session) {
      user = await getUserById(session.user_id);
    }
  }

  // Return different data based on authentication
  const stats = await getPublicStats(user?.id);
  return c.json({ success: true, data: stats });
});
```

## Frontend Authentication

### Authentication State Management

```typescript
// Authentication state
interface AuthState {
  isAuthenticated: boolean;
  user: User | null;
  token: string | null;
  loading: boolean;
  error: string | null;
}

// Authentication service
class AuthService {
  private state: AuthState = {
    isAuthenticated: false,
    user: null,
    token: null,
    loading: false,
    error: null,
  };

  async login(): Promise<void> {
    this.state.loading = true;
    this.state.error = null;

    try {
      // Redirect to Zalo OAuth
      await initiateZaloLogin();
    } catch (error) {
      this.state.error = error.message;
      this.state.loading = false;
    }
  }

  async logout(): Promise<void> {
    try {
      // Call logout API
      await fetch("/api/auth/logout", {
        method: "POST",
        headers: {
          Authorization: `Bearer ${this.state.token}`,
        },
      });
    } catch (error) {
      console.error("Logout error:", error);
    } finally {
      // Clear local state
      this.clearAuth();
    }
  }

  async loadUser(): Promise<void> {
    const token = localStorage.getItem("auth_token");
    if (!token) return;

    try {
      const response = await fetch("/api/users/profile", {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });

      if (response.ok) {
        const { data } = await response.json();
        this.state.user = data;
        this.state.token = token;
        this.state.isAuthenticated = true;
      } else {
        this.clearAuth();
      }
    } catch (error) {
      this.clearAuth();
    }
  }

  private clearAuth(): void {
    this.state.isAuthenticated = false;
    this.state.user = null;
    this.state.token = null;
    localStorage.removeItem("auth_token");
  }
}
```

### Protected Routes

```javascript
// Route protection utility
function requireAuth() {
  const authService = new AuthService();

  if (!authService.isAuthenticated) {
    window.location.href = "/login";
    return false;
  }

  return true;
}

// Page initialization
document.addEventListener("DOMContentLoaded", async () => {
  const authService = new AuthService();

  // Load user if token exists
  await authService.loadUser();

  // Check if current page requires authentication
  if (document.body.dataset.requireAuth === "true") {
    if (!requireAuth()) return;
  }

  // Initialize page
  initializePage();
});
```

## Security Considerations

### Token Security

**Storage:**

- Store JWT tokens in localStorage (not sessionStorage for persistence)
- Consider httpOnly cookies for enhanced security (future enhancement)
- Never expose tokens in URLs or logs

**Transmission:**

- Always use HTTPS in production
- Include tokens in Authorization headers
- Validate tokens on every protected request

**Expiration:**

- Set reasonable expiration times (7 days default)
- Implement token refresh mechanism
- Automatic logout on token expiration

### CSRF Protection

```typescript
// CSRF token generation
function generateCSRFToken(): string {
  return crypto.randomUUID();
}

// CSRF validation middleware
async function csrfMiddleware(c: Context, next: () => Promise<void>) {
  const method = c.req.method;

  // Skip CSRF for GET requests
  if (method === "GET") {
    await next();
    return;
  }

  const token = c.req.header("X-CSRF-Token") || c.req.query("csrf_token");
  const sessionToken = c.get("session")?.csrf_token;

  if (!token || token !== sessionToken) {
    return c.json({ error: "CSRF token mismatch" }, 403);
  }

  await next();
}
```

### Rate Limiting

```typescript
// Authentication rate limiting
const authRateLimit = new Map<string, { count: number; resetTime: number }>();

async function authRateLimitMiddleware(c: Context, next: () => Promise<void>) {
  const ip = c.req.header("CF-Connecting-IP") || "unknown";
  const now = Date.now();
  const windowMs = 15 * 60 * 1000; // 15 minutes
  const maxAttempts = 10;

  const record = authRateLimit.get(ip) || {
    count: 0,
    resetTime: now + windowMs,
  };

  // Reset if window expired
  if (now > record.resetTime) {
    record.count = 0;
    record.resetTime = now + windowMs;
  }

  // Check limit
  if (record.count >= maxAttempts) {
    return c.json({ error: "Too many authentication attempts" }, 429);
  }

  // Increment counter
  record.count++;
  authRateLimit.set(ip, record);

  await next();
}
```

## Error Handling

### Authentication Errors

```typescript
enum AuthError {
  INVALID_CREDENTIALS = "INVALID_CREDENTIALS",
  TOKEN_EXPIRED = "TOKEN_EXPIRED",
  TOKEN_INVALID = "TOKEN_INVALID",
  USER_INACTIVE = "USER_INACTIVE",
  ZALO_API_ERROR = "ZALO_API_ERROR",
  RATE_LIMITED = "RATE_LIMITED",
}

function handleAuthError(error: AuthError, context?: string): Response {
  const errorMessages = {
    [AuthError.INVALID_CREDENTIALS]: "Invalid login credentials",
    [AuthError.TOKEN_EXPIRED]: "Session expired, please login again",
    [AuthError.TOKEN_INVALID]: "Invalid authentication token",
    [AuthError.USER_INACTIVE]: "User account is inactive",
    [AuthError.ZALO_API_ERROR]: "Zalo authentication service error",
    [AuthError.RATE_LIMITED]: "Too many attempts, please try again later",
  };

  const statusCodes = {
    [AuthError.INVALID_CREDENTIALS]: 401,
    [AuthError.TOKEN_EXPIRED]: 401,
    [AuthError.TOKEN_INVALID]: 401,
    [AuthError.USER_INACTIVE]: 403,
    [AuthError.ZALO_API_ERROR]: 502,
    [AuthError.RATE_LIMITED]: 429,
  };

  return new Response(
    JSON.stringify({
      success: false,
      error: {
        code: error,
        message: errorMessages[error],
        context,
      },
    }),
    {
      status: statusCodes[error] || 500,
      headers: { "Content-Type": "application/json" },
    },
  );
}
```

## Testing Authentication

### Unit Tests

```typescript
// Test JWT token generation and validation
describe("JWT Token Management", () => {
  test("should generate valid JWT token", async () => {
    const payload = {
      sub: "user_123",
      zalo_id: "zalo_456",
      role: "user",
    };

    const token = await generateJWT(payload);
    expect(token).toBeTruthy();

    const decoded = await validateJWT(token);
    expect(decoded.sub).toBe(payload.sub);
    expect(decoded.zalo_id).toBe(payload.zalo_id);
  });

  test("should reject expired tokens", async () => {
    // Create expired token
    const expiredToken = await new SignJWT({ sub: "user_123" })
      .setProtectedHeader({ alg: "HS256" })
      .setExpirationTime("-1h")
      .sign(secret);

    const result = await validateJWT(expiredToken);
    expect(result).toBeNull();
  });
});

// Test session management
describe("Session Management", () => {
  test("should create and validate session", async () => {
    const token = await generateJWT({
      sub: "user_123",
      zalo_id: "zalo_456",
      role: "user",
    });

    const session = await createSession({
      user_id: "user_123",
      token_hash: await hashToken(token),
      expires_at: Date.now() + 86400000,
      ip_address: "127.0.0.1",
    });

    expect(session.id).toBeTruthy();

    const validatedSession = await validateSession(token);
    expect(validatedSession?.user_id).toBe("user_123");
  });
});
```

### Integration Tests

```typescript
// Test OAuth flow
describe("OAuth Integration", () => {
  test("should handle OAuth callback", async () => {
    const mockZaloResponse = {
      access_token: "mock_access_token",
      refresh_token: "mock_refresh_token",
      expires_in: 3600,
    };

    const mockUserResponse = {
      id: "zalo_123",
      name: "Test User",
      picture: { data: { url: "avatar_url" } },
    };

    // Mock external API calls
    fetchMock.mockResponses(
      [JSON.stringify(mockZaloResponse), { status: 200 }],
      [JSON.stringify(mockUserResponse), { status: 200 }],
    );

    const response = await app.request(
      "/api/auth/zalo/callback?code=test_code&state=test_state",
    );

    expect(response.status).toBe(302); // Redirect
    expect(response.headers.get("Location")).toContain("/dashboard?token=");
  });
});
```

This authentication specification provides a complete, secure, and KISS-compliant authentication system for the Zalo AI Assistant, ensuring both security and ease of use for Vietnamese small business owners.

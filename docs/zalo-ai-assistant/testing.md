# Zalo AI Assistant - Testing Strategy

## Overview

This document outlines the comprehensive testing strategy for the Zalo AI Assistant. The approach follows KISS principles with practical testing that ensures reliability while maintaining development speed for solo developers.

## Testing Philosophy

### Core Principles

- **Test What Matters**: Focus on business logic and user-facing functionality
- **Fast Feedback**: Tests should run quickly and provide immediate feedback
- **Simple Setup**: Minimal configuration and easy to run locally
- **Realistic Testing**: Use real scenarios that mirror production usage
- **Automated Where Possible**: Automate repetitive testing tasks

### Testing Pyramid

```
                    E2E Tests (Few)
                  ├─────────────────┤
               Integration Tests (Some)
             ├─────────────────────────┤
          Unit Tests (Many)
    ├───────────────────────────────────┤
```

## Testing Stack

### Tools and Frameworks

- **Test Runner**: Bun Test (built-in, fast)
- **Assertions**: Bun's built-in assertions
- **Mocking**: Bun's built-in mocking
- **E2E Testing**: Playwright (when needed)
- **API Testing**: Simple fetch-based tests
- **Database Testing**: In-memory SQLite

### Test Environment Setup

```typescript
// test-setup.ts
import { beforeAll, afterAll, beforeEach } from "bun:test";
import { Database } from "bun:sqlite";

// Test database setup
export const testDb = new Database(":memory:");

beforeAll(async () => {
  // Initialize test database
  await setupTestDatabase();

  // Setup test environment variables
  process.env.NODE_ENV = "test";
  process.env.JWT_SECRET = "test-secret";
  process.env.ZALO_APP_ID = "test-app-id";
});

afterAll(() => {
  testDb.close();
});

beforeEach(() => {
  // Clean database between tests
  cleanTestDatabase();
});

async function setupTestDatabase() {
  // Run migrations
  const migrations = await getMigrations();
  for (const migration of migrations) {
    testDb.exec(migration);
  }
}

function cleanTestDatabase() {
  // Clean all tables
  testDb.exec("DELETE FROM messages");
  testDb.exec("DELETE FROM customers");
  testDb.exec("DELETE FROM users");
}
```

## Unit Testing

### Service Layer Testing

```typescript
// tests/services/zalo.service.test.ts
import { describe, it, expect, mock } from "bun:test";
import { ZaloService } from "../../src/services/zalo.service";

describe("ZaloService", () => {
  const mockFetch = mock();

  beforeEach(() => {
    global.fetch = mockFetch;
    mockFetch.mockClear();
  });

  describe("sendMessage", () => {
    it("should send message successfully", async () => {
      // Arrange
      mockFetch.mockResolvedValue({
        ok: true,
        json: () =>
          Promise.resolve({
            error: 0,
            message: "success",
            data: { message_id: "msg_123" },
          }),
      });

      const zaloService = new ZaloService({
        accessToken: "test-token",
        oaId: "test-oa-id",
      });

      // Act
      const result = await zaloService.sendMessage("user_123", "Hello world");

      // Assert
      expect(result.success).toBe(true);
      expect(result.messageId).toBe("msg_123");
      expect(mockFetch).toHaveBeenCalledWith(
        "https://openapi.zalo.me/v2.0/oa/message",
        expect.objectContaining({
          method: "POST",
          headers: expect.objectContaining({
            access_token: "test-token",
          }),
        }),
      );
    });

    it("should handle API errors gracefully", async () => {
      // Arrange
      mockFetch.mockResolvedValue({
        ok: false,
        json: () =>
          Promise.resolve({
            error: -1,
            message: "Invalid access token",
          }),
      });

      const zaloService = new ZaloService({
        accessToken: "invalid-token",
        oaId: "test-oa-id",
      });

      // Act & Assert
      await expect(
        zaloService.sendMessage("user_123", "Hello"),
      ).rejects.toThrow("Invalid access token");
    });
  });

  describe("validateWebhook", () => {
    it("should validate webhook signature correctly", () => {
      // Arrange
      const payload = '{"event": "test"}';
      const timestamp = "1640995200";
      const secret = "test-secret";
      const expectedSignature = "expected-signature-hash";

      const zaloService = new ZaloService({
        accessToken: "test-token",
        oaId: "test-oa-id",
        webhookSecret: secret,
      });

      // Act
      const isValid = zaloService.validateWebhook(
        payload,
        timestamp,
        expectedSignature,
      );

      // Assert
      expect(isValid).toBe(true);
    });
  });
});
```

### AI Service Testing

```typescript
// tests/services/ai.service.test.ts
import { describe, it, expect, mock } from "bun:test";
import { AIService } from "../../src/services/ai.service";

describe("AIService", () => {
  const mockFetch = mock();

  beforeEach(() => {
    global.fetch = mockFetch;
  });

  describe("generateResponse", () => {
    it("should generate Vietnamese business response", async () => {
      // Arrange
      mockFetch.mockResolvedValue({
        ok: true,
        json: () =>
          Promise.resolve({
            choices: [
              {
                message: {
                  content:
                    "Xin chào! Cảm ơn anh đã liên hệ. Anh cần hỗ trợ gì ạ?",
                },
              },
            ],
            usage: {
              total_tokens: 45,
            },
          }),
      });

      const aiService = new AIService({
        apiKey: "test-key",
        model: "gpt-3.5-turbo",
      });

      // Act
      const result = await aiService.generateResponse({
        message: "Hello, I need help",
        context: {
          customerName: "Nguyễn Văn A",
          businessType: "restaurant",
          previousMessages: [],
        },
      });

      // Assert
      expect(result.content).toContain("Xin chào");
      expect(result.content).toContain("Cảm ơn");
      expect(result.tokensUsed).toBe(45);
      expect(result.confidence).toBeGreaterThan(0);
    });

    it("should handle API rate limits", async () => {
      // Arrange
      mockFetch.mockResolvedValue({
        ok: false,
        status: 429,
        json: () =>
          Promise.resolve({
            error: {
              type: "rate_limit_exceeded",
              message: "Rate limit exceeded",
            },
          }),
      });

      const aiService = new AIService({
        apiKey: "test-key",
        model: "gpt-3.5-turbo",
      });

      // Act & Assert
      await expect(
        aiService.generateResponse({
          message: "Test message",
          context: {},
        }),
      ).rejects.toThrow("Rate limit exceeded");
    });
  });
});
```

### Database Repository Testing

```typescript
// tests/repositories/user.repository.test.ts
import { describe, it, expect, beforeEach } from "bun:test";
import { UserRepository } from "../../src/repositories/user.repository";
import { testDb } from "../test-setup";

describe("UserRepository", () => {
  let userRepo: UserRepository;

  beforeEach(() => {
    userRepo = new UserRepository(testDb);
  });

  describe("create", () => {
    it("should create user successfully", async () => {
      // Arrange
      const userData = {
        zalo_id: "test_zalo_123",
        name: "Test User",
        email: "test@example.com",
        settings: {
          auto_reply: true,
          business_hours: {
            start: "09:00",
            end: "18:00",
          },
        },
      };

      // Act
      const user = await userRepo.create(userData);

      // Assert
      expect(user.id).toBeTruthy();
      expect(user.zalo_id).toBe("test_zalo_123");
      expect(user.name).toBe("Test User");
      expect(user.email).toBe("test@example.com");
      expect(user.settings.auto_reply).toBe(true);
    });

    it("should enforce unique zalo_id constraint", async () => {
      // Arrange
      const userData = {
        zalo_id: "duplicate_zalo_id",
        name: "User 1",
        email: "user1@example.com",
      };

      await userRepo.create(userData);

      // Act & Assert
      await expect(
        userRepo.create({
          ...userData,
          name: "User 2",
          email: "user2@example.com",
        }),
      ).rejects.toThrow();
    });
  });

  describe("findByZaloId", () => {
    it("should find user by zalo_id", async () => {
      // Arrange
      const userData = {
        zalo_id: "find_test_123",
        name: "Find Test User",
        email: "findtest@example.com",
      };

      const createdUser = await userRepo.create(userData);

      // Act
      const foundUser = await userRepo.findByZaloId("find_test_123");

      // Assert
      expect(foundUser).toBeTruthy();
      expect(foundUser?.id).toBe(createdUser.id);
      expect(foundUser?.name).toBe("Find Test User");
    });

    it("should return null for non-existent user", async () => {
      // Act
      const user = await userRepo.findByZaloId("non_existent_123");

      // Assert
      expect(user).toBeNull();
    });
  });
});
```

## Integration Testing

### API Endpoint Testing

```typescript
// tests/integration/auth.api.test.ts
import { describe, it, expect, beforeEach } from "bun:test";
import { createApp } from "../../src/app";
import { testDb } from "../test-setup";

describe("Authentication API", () => {
  let app: any;

  beforeEach(() => {
    app = createApp({ database: testDb });
  });

  describe("POST /api/auth/zalo/callback", () => {
    it("should authenticate user with valid Zalo code", async () => {
      // Arrange
      const mockZaloResponse = {
        access_token: "mock_access_token",
        refresh_token: "mock_refresh_token",
        expires_in: 3600,
      };

      const mockUserResponse = {
        id: "zalo_user_123",
        name: "Test User",
        picture: {
          data: {
            url: "https://example.com/avatar.jpg",
          },
        },
      };

      // Mock Zalo API calls
      global.fetch = mock()
        .mockResolvedValueOnce({
          ok: true,
          json: () => Promise.resolve(mockZaloResponse),
        })
        .mockResolvedValueOnce({
          ok: true,
          json: () => Promise.resolve(mockUserResponse),
        });

      // Act
      const response = await app.request("/api/auth/zalo/callback", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          code: "valid_auth_code",
          state: "test_state",
        }),
      });

      // Assert
      expect(response.status).toBe(200);

      const result = await response.json();
      expect(result.success).toBe(true);
      expect(result.data.token).toBeTruthy();
      expect(result.data.user.name).toBe("Test User");
      expect(result.data.user.zalo_id).toBe("zalo_user_123");
    });

    it("should handle invalid authorization code", async () => {
      // Arrange
      global.fetch = mock().mockResolvedValue({
        ok: false,
        json: () =>
          Promise.resolve({
            error: {
              code: "invalid_authorization_code",
              message: "The authorization code is invalid",
            },
          }),
      });

      // Act
      const response = await app.request("/api/auth/zalo/callback", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          code: "invalid_code",
          state: "test_state",
        }),
      });

      // Assert
      expect(response.status).toBe(400);

      const result = await response.json();
      expect(result.success).toBe(false);
      expect(result.error.message).toContain("authorization code");
    });
  });
});
```

### Message Flow Testing

```typescript
// tests/integration/message-flow.test.ts
import { describe, it, expect, beforeEach } from "bun:test";
import { createApp } from "../../src/app";
import { testDb } from "../test-setup";

describe("Message Flow Integration", () => {
  let app: any;
  let testUser: any;
  let authToken: string;

  beforeEach(async () => {
    app = createApp({ database: testDb });

    // Create test user and get auth token
    testUser = await createTestUser();
    authToken = await generateTestAuthToken(testUser.id);
  });

  describe("Webhook to AI Response Flow", () => {
    it("should process incoming message and generate AI response", async () => {
      // Mock AI service
      global.fetch = mock().mockResolvedValue({
        ok: true,
        json: () =>
          Promise.resolve({
            choices: [
              {
                message: {
                  content: "Xin chào! Cảm ơn bạn đã liên hệ với chúng tôi.",
                },
              },
            ],
            usage: { total_tokens: 25 },
          }),
      });

      // Step 1: Receive webhook from Zalo
      const webhookPayload = {
        app_id: "test_app_id",
        user_id_by_app: "customer_zalo_123",
        event_name: "user_send_text",
        timestamp: Date.now(),
        message: {
          text: "Xin chào, tôi muốn hỏi về sản phẩm",
          msg_id: "msg_123",
        },
      };

      const webhookResponse = await app.request("/api/zalo/webhook", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(webhookPayload),
      });

      expect(webhookResponse.status).toBe(200);

      // Step 2: Verify message was stored
      const messagesResponse = await app.request("/api/messages", {
        headers: {
          Authorization: `Bearer ${authToken}`,
        },
      });

      const messages = await messagesResponse.json();
      expect(messages.data.length).toBeGreaterThan(0);

      const incomingMessage = messages.data.find((m) => m.type === "incoming");
      expect(incomingMessage).toBeTruthy();
      expect(incomingMessage.content).toBe(
        "Xin chào, tôi muốn hỏi về sản phẩm",
      );

      // Step 3: Verify AI response was generated and sent
      const autoMessage = messages.data.find((m) => m.is_auto_reply === true);
      expect(autoMessage).toBeTruthy();
      expect(autoMessage.content).toContain("Xin chào");
      expect(autoMessage.content).toContain("Cảm ơn");
    });
  });
});
```

## End-to-End Testing

### Browser Testing Setup

```typescript
// tests/e2e/setup.ts
import { test as base, expect } from "@playwright/test";
import { createApp } from "../../src/app";

export const test = base.extend({
  // Setup test app
  app: async ({}, use) => {
    const app = createApp({
      database: testDb,
      port: 3001, // Different port for E2E
    });

    const server = Bun.serve({
      port: 3001,
      fetch: app.fetch,
    });

    await use(app);

    server.stop();
  },
});

export { expect };
```

### Critical User Journey Tests

```typescript
// tests/e2e/user-journey.test.ts
import { test, expect } from "./setup";

test.describe("Complete User Journey", () => {
  test("should complete full authentication and message flow", async ({
    page,
  }) => {
    // Step 1: Visit landing page
    await page.goto("http://localhost:3001");

    // Step 2: Click login button
    await page.click('[data-testid="login-button"]');

    // Step 3: Mock Zalo OAuth (in real test, would use test Zalo account)
    await page.route("**/api/auth/zalo/**", (route) => {
      route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({
          success: true,
          data: {
            token: "test_jwt_token",
            user: {
              id: "user_123",
              name: "Test User",
              zalo_id: "zalo_123",
            },
          },
        }),
      });
    });

    // Step 4: Should redirect to dashboard
    await expect(page).toHaveURL(/.*dashboard/);
    await expect(page.locator('[data-testid="user-name"]')).toContainText(
      "Test User",
    );

    // Step 5: Check messages section
    await page.click('[data-testid="messages-tab"]');
    await expect(page.locator('[data-testid="messages-list"]')).toBeVisible();

    // Step 6: Send a test message
    await page.fill('[data-testid="message-input"]', "Test message");
    await page.click('[data-testid="send-button"]');

    // Step 7: Verify message appears
    await expect(page.locator('[data-testid="message-item"]')).toContainText(
      "Test message",
    );
  });
});
```

## Performance Testing

### Load Testing with Bun

```typescript
// tests/performance/load.test.ts
import { describe, it, expect } from "bun:test";

describe("Performance Tests", () => {
  it("should handle concurrent API requests", async () => {
    const concurrentRequests = 50;
    const requests: Promise<Response>[] = [];

    // Create concurrent requests
    for (let i = 0; i < concurrentRequests; i++) {
      requests.push(
        fetch("http://localhost:3001/api/health", {
          method: "GET",
        }),
      );
    }

    // Wait for all requests
    const startTime = Date.now();
    const responses = await Promise.all(requests);
    const endTime = Date.now();

    // Assert all requests succeeded
    const successCount = responses.filter((r) => r.ok).length;
    expect(successCount).toBe(concurrentRequests);

    // Assert reasonable response time
    const avgResponseTime = (endTime - startTime) / concurrentRequests;
    expect(avgResponseTime).toBeLessThan(100); // Less than 100ms average
  });

  it("should handle message processing efficiently", async () => {
    const messageCount = 100;
    const messages: any[] = [];

    // Generate test messages
    for (let i = 0; i < messageCount; i++) {
      messages.push({
        id: `msg_${i}`,
        content: `Test message ${i}`,
        customer_id: "customer_123",
        type: "incoming",
      });
    }

    // Process messages
    const startTime = Date.now();
    await processMessages(messages);
    const endTime = Date.now();

    // Assert processing time
    const totalTime = endTime - startTime;
    const messagesPerSecond = (messageCount / totalTime) * 1000;

    expect(messagesPerSecond).toBeGreaterThan(50); // At least 50 messages per second
  });
});
```

## Test Data Management

### Test Fixtures

```typescript
// tests/fixtures/index.ts
export const testUsers = {
  validUser: {
    zalo_id: "zalo_user_123",
    name: "Test User",
    email: "test@example.com",
    settings: {
      auto_reply: true,
      business_hours: {
        enabled: true,
        start: "09:00",
        end: "18:00",
      },
    },
  },

  businessOwner: {
    zalo_id: "zalo_business_456",
    name: "Business Owner",
    email: "owner@business.com",
    settings: {
      auto_reply: true,
      business_hours: {
        enabled: true,
        start: "08:00",
        end: "20:00",
      },
      business_context: "Vietnamese restaurant",
    },
  },
};

export const testCustomers = {
  regularCustomer: {
    zalo_id: "zalo_customer_789",
    name: "Nguyễn Văn A",
    phone: "+84123456789",
    tags: ["regular"],
  },

  vipCustomer: {
    zalo_id: "zalo_vip_101",
    name: "Trần Thị B",
    phone: "+84987654321",
    tags: ["vip", "wholesale"],
  },
};

export const testMessages = {
  greeting: {
    type: "incoming",
    content: "Xin chào, tôi muốn hỏi về sản phẩm",
    content_type: "text",
  },

  productInquiry: {
    type: "incoming",
    content: "Bạn có bán iPhone 15 không? Giá bao nhiêu?",
    content_type: "text",
  },

  complaint: {
    type: "incoming",
    content: "Sản phẩm tôi mua hôm qua bị lỗi, tôi muốn đổi trả",
    content_type: "text",
  },
};
```

### Factory Functions

```typescript
// tests/factories/user.factory.ts
import { faker } from "@faker-js/faker";

export class UserFactory {
  static create(overrides = {}) {
    return {
      id: faker.string.uuid(),
      zalo_id: `zalo_${faker.string.alphanumeric(10)}`,
      name: faker.person.fullName(),
      email: faker.internet.email(),
      settings: {
        auto_reply: faker.datatype.boolean(),
        business_hours: {
          enabled: true,
          start: "09:00",
          end: "18:00",
        },
      },
      created_at: Date.now(),
      updated_at: Date.now(),
      ...overrides,
    };
  }

  static createMany(count: number, overrides = {}) {
    return Array.from({ length: count }, () => this.create(overrides));
  }
}
```

## Test Automation

### GitHub Actions Workflow

```yaml
# .github/workflows/test.yml
name: Run Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Bun
        uses: oven-sh/setup-bun@v1
        with:
          bun-version: latest

      - name: Install dependencies
        run: bun install

      - name: Run unit tests
        run: bun test --coverage

      - name: Run integration tests
        run: bun test tests/integration/

      - name: Upload coverage reports
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
```

### Test Scripts

```json
{
  "scripts": {
    "test": "bun test",
    "test:unit": "bun test tests/unit/",
    "test:integration": "bun test tests/integration/",
    "test:e2e": "playwright test",
    "test:watch": "bun test --watch",
    "test:coverage": "bun test --coverage",
    "test:ci": "bun test --coverage --reporter=junit"
  }
}
```

This comprehensive testing strategy ensures the Zalo AI Assistant is reliable, maintainable, and performs well while following KISS principles for solo development productivity.

# Zalo AI Assistant - Zalo Integration Specification

## Overview

This document defines the integration with Zalo Official Account (OA) APIs for the Zalo AI Assistant. The integration handles message receiving, sending, and user management through Zalo's webhook and REST APIs, following KISS principles.

## Zalo API Overview

### Core Integration Points

- **OAuth Authentication**: User login via Zalo OAuth
- **Webhook Receiving**: Incoming messages and events
- **Message Sending**: Outgoing messages and responses
- **User Management**: Customer information and profiles
- **File Handling**: Images, documents, and media

### API Endpoints

```
OAuth: https://oauth.zaloapp.com/v4/
Messages: https://openapi.zalo.me/v2.0/oa/
User Info: https://graph.zalo.me/v2.0/
```

## Zalo Official Account Setup

### App Configuration

```typescript
interface ZaloConfig {
  app_id: string; // Zalo App ID
  app_secret: string; // Zalo App Secret
  oa_id: string; // Official Account ID
  webhook_url: string; // Webhook endpoint URL
  webhook_secret: string; // Webhook verification secret
  access_token: string; // OA access token
}
```

### Environment Variables

```env
ZALO_APP_ID=your_app_id
ZALO_APP_SECRET=your_app_secret
ZALO_OA_ID=your_oa_id
ZALO_WEBHOOK_URL=https://your-domain.com/api/zalo/webhook
ZALO_WEBHOOK_SECRET=your_webhook_secret
ZALO_OA_ACCESS_TOKEN=your_oa_access_token
```

## Webhook Integration

### Webhook Setup

**Zalo Webhook Configuration:**

```json
{
  "webhook": "https://your-domain.com/api/zalo/webhook",
  "events": [
    "user_send_text",
    "user_send_image",
    "user_send_file",
    "user_send_sticker",
    "user_send_location",
    "oa_send_text",
    "user_submit_info",
    "user_click_chatnow"
  ]
}
```

### Webhook Verification

```typescript
export async function verifyZaloWebhook(c: Context) {
  const signature = c.req.header("X-ZEvent-Signature");
  const timestamp = c.req.header("X-ZEvent-Timestamp");
  const body = await c.req.text();

  // Verify signature
  const expectedSignature = await generateSignature(
    body,
    timestamp,
    process.env.ZALO_WEBHOOK_SECRET,
  );

  if (signature !== expectedSignature) {
    return c.json({ error: "Invalid signature" }, 401);
  }

  return c.json({ challenge: c.req.query("challenge") });
}

async function generateSignature(
  body: string,
  timestamp: string,
  secret: string,
): Promise<string> {
  const data = timestamp + body;
  const encoder = new TextEncoder();
  const key = await crypto.subtle.importKey(
    "raw",
    encoder.encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const signature = await crypto.subtle.sign("HMAC", key, encoder.encode(data));
  return Array.from(new Uint8Array(signature))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}
```

### Webhook Event Handling

```typescript
export async function handleZaloWebhook(c: Context) {
  try {
    const event = await c.req.json();

    switch (event.event_name) {
      case "user_send_text":
        await handleTextMessage(event);
        break;
      case "user_send_image":
        await handleImageMessage(event);
        break;
      case "user_send_file":
        await handleFileMessage(event);
        break;
      case "user_send_sticker":
        await handleStickerMessage(event);
        break;
      case "user_send_location":
        await handleLocationMessage(event);
        break;
      case "user_submit_info":
        await handleUserInfo(event);
        break;
      default:
        console.log("Unhandled event:", event.event_name);
    }

    return c.json({ success: true });
  } catch (error) {
    console.error("Webhook error:", error);
    return c.json({ error: "Webhook processing failed" }, 500);
  }
}
```

## Message Processing

### Incoming Text Messages

```typescript
async function handleTextMessage(event: ZaloWebhookEvent) {
  const { sender, recipient, message, timestamp } = event;

  // Get or create customer
  const customer = await getOrCreateCustomer({
    zalo_id: sender.id,
    user_id: await getUserByOaId(recipient.id),
  });

  // Store incoming message
  const incomingMessage = await createMessage({
    customer_id: customer.id,
    user_id: customer.user_id,
    zalo_message_id: message.msg_id,
    type: "incoming",
    content_type: "text",
    content: message.text,
    created_at: timestamp,
  });

  // Check if auto-reply is enabled
  const user = await getUserById(customer.user_id);
  if (!user.settings.auto_reply) return;

  // Check business hours
  if (!isWithinBusinessHours(user.settings.business_hours)) return;

  // Generate AI response
  const aiResponse = await generateAIResponse({
    message: message.text,
    customer,
    context: await getConversationContext(customer.id),
  });

  // Send response
  await sendTextMessage(customer.zalo_id, aiResponse.content);

  // Store outgoing message
  await createMessage({
    customer_id: customer.id,
    user_id: customer.user_id,
    type: "auto",
    content_type: "text",
    content: aiResponse.content,
    is_auto_reply: true,
    metadata: {
      ai_confidence: aiResponse.confidence,
      processing_time: aiResponse.processing_time,
      model: aiResponse.model,
    },
  });
}
```

### Incoming Image Messages

```typescript
async function handleImageMessage(event: ZaloWebhookEvent) {
  const { sender, recipient, message, timestamp } = event;

  // Get customer
  const customer = await getOrCreateCustomer({
    zalo_id: sender.id,
    user_id: await getUserByOaId(recipient.id),
  });

  // Download and store image
  const imageData = await downloadZaloAttachment(
    message.attachments[0].payload.url,
  );
  const file = await storeFile({
    user_id: customer.user_id,
    customer_id: customer.id,
    filename: `image_${Date.now()}.jpg`,
    original_filename: "zalo_image.jpg",
    file_type: "image",
    file_size: imageData.byteLength,
    mime_type: "image/jpeg",
    content: imageData,
  });

  // Store message with file reference
  await createMessage({
    customer_id: customer.id,
    user_id: customer.user_id,
    zalo_message_id: message.msg_id,
    type: "incoming",
    content_type: "image",
    content: `Image: ${file.filename}`,
    metadata: {
      file_id: file.id,
      file_url: file.storage_url,
    },
    created_at: timestamp,
  });

  // Optional: Generate AI response for image
  if (customer.user.settings.auto_reply_images) {
    const response = await generateImageResponse(file.storage_url);
    await sendTextMessage(customer.zalo_id, response);
  }
}
```

## Message Sending

### Send Text Message

```typescript
async function sendTextMessage(
  userId: string,
  text: string,
  options?: SendMessageOptions,
): Promise<ZaloResponse> {
  const payload = {
    recipient: {
      user_id: userId,
    },
    message: {
      text: text,
    },
  };

  const response = await fetch("https://openapi.zalo.me/v2.0/oa/message", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      access_token: process.env.ZALO_OA_ACCESS_TOKEN,
    },
    body: JSON.stringify(payload),
  });

  const result = await response.json();

  if (result.error) {
    throw new ZaloAPIError(result.error.message, result.error.code);
  }

  return result;
}
```

### Send Image Message

```typescript
async function sendImageMessage(
  userId: string,
  imageUrl: string,
  caption?: string,
): Promise<ZaloResponse> {
  const payload = {
    recipient: {
      user_id: userId,
    },
    message: {
      attachment: {
        type: "image",
        payload: {
          url: imageUrl,
        },
      },
    },
  };

  if (caption) {
    payload.message.text = caption;
  }

  const response = await fetch("https://openapi.zalo.me/v2.0/oa/message", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      access_token: process.env.ZALO_OA_ACCESS_TOKEN,
    },
    body: JSON.stringify(payload),
  });

  return await response.json();
}
```

### Send File Message

```typescript
async function sendFileMessage(
  userId: string,
  fileUrl: string,
  filename: string,
): Promise<ZaloResponse> {
  const payload = {
    recipient: {
      user_id: userId,
    },
    message: {
      attachment: {
        type: "file",
        payload: {
          url: fileUrl,
          filename: filename,
        },
      },
    },
  };

  const response = await fetch("https://openapi.zalo.me/v2.0/oa/message", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      access_token: process.env.ZALO_OA_ACCESS_TOKEN,
    },
    body: JSON.stringify(payload),
  });

  return await response.json();
}
```

### Send Template Message

```typescript
async function sendTemplateMessage(
  userId: string,
  template: ZaloTemplate,
): Promise<ZaloResponse> {
  const payload = {
    recipient: {
      user_id: userId,
    },
    message: {
      attachment: {
        type: "template",
        payload: template,
      },
    },
  };

  const response = await fetch("https://openapi.zalo.me/v2.0/oa/message", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      access_token: process.env.ZALO_OA_ACCESS_TOKEN,
    },
    body: JSON.stringify(payload),
  });

  return await response.json();
}

// Template examples
const welcomeTemplate: ZaloTemplate = {
  template_type: "generic",
  elements: [
    {
      title: "Chào mừng bạn!",
      subtitle: "Cảm ơn bạn đã liên hệ với chúng tôi",
      image_url: "https://example.com/welcome.jpg",
      buttons: [
        {
          type: "web_url",
          url: "https://example.com/catalog",
          title: "Xem sản phẩm",
        },
        {
          type: "postback",
          title: "Liên hệ tư vấn",
          payload: "CONTACT_SUPPORT",
        },
      ],
    },
  ],
};
```

## User Information Management

### Get User Profile

```typescript
async function getZaloUserProfile(userId: string): Promise<ZaloUser> {
  const response = await fetch(
    `https://openapi.zalo.me/v2.0/oa/getprofile?data={"user_id":"${userId}"}`,
    {
      headers: {
        access_token: process.env.ZALO_OA_ACCESS_TOKEN,
      },
    },
  );

  const result = await response.json();

  if (result.error) {
    throw new ZaloAPIError(result.error.message, result.error.code);
  }

  return result.data;
}
```

### Update Customer Information

```typescript
async function updateCustomerFromZalo(customerId: string): Promise<void> {
  const customer = await getCustomerById(customerId);
  const zaloProfile = await getZaloUserProfile(customer.zalo_id);

  await updateCustomer(customerId, {
    name: zaloProfile.display_name,
    avatar_url: zaloProfile.avatar,
    updated_at: Date.now(),
  });
}
```

## File Handling

### Download Zalo Attachments

```typescript
async function downloadZaloAttachment(url: string): Promise<ArrayBuffer> {
  const response = await fetch(url, {
    headers: {
      access_token: process.env.ZALO_OA_ACCESS_TOKEN,
    },
  });

  if (!response.ok) {
    throw new Error(`Failed to download attachment: ${response.statusText}`);
  }

  return await response.arrayBuffer();
}
```

### Upload Files to Zalo

```typescript
async function uploadFileToZalo(
  file: ArrayBuffer,
  filename: string,
): Promise<string> {
  const formData = new FormData();
  formData.append("file", new Blob([file]), filename);

  const response = await fetch("https://openapi.zalo.me/v2.0/oa/upload", {
    method: "POST",
    headers: {
      access_token: process.env.ZALO_OA_ACCESS_TOKEN,
    },
    body: formData,
  });

  const result = await response.json();

  if (result.error) {
    throw new ZaloAPIError(result.error.message, result.error.code);
  }

  return result.data.url;
}
```

## AI Integration with Zalo Context

### Context-Aware AI Responses

```typescript
async function generateAIResponse(params: {
  message: string;
  customer: Customer;
  context: ConversationContext;
}): Promise<AIResponse> {
  const { message, customer, context } = params;

  // Build Vietnamese business context
  const systemPrompt = `
Bạn là trợ lý AI cho doanh nghiệp Việt Nam. 
Hãy trả lời một cách lịch sự, chuyên nghiệp và phù hợp với văn hóa kinh doanh Việt Nam.

Thông tin khách hàng:
- Tên: ${customer.name || "Quý khách"}
- Lịch sử: ${context.previousMessages.length} tin nhắn trước đó
- Thẻ: ${customer.tags.join(", ")}

Quy tắc trả lời:
1. Luôn xưng hô lịch sự (anh/chị, quý khách)
2. Sử dụng ngôn ngữ kinh doanh Việt Nam phù hợp
3. Trả lời ngắn gọn, rõ ràng
4. Nếu không hiểu, hỏi lại một cách lịch sự
5. Luôn kết thúc bằng cách hỏi có thể hỗ trợ gì thêm
  `;

  const conversation = [
    { role: "system", content: systemPrompt },
    ...context.previousMessages.map((msg) => ({
      role: msg.type === "incoming" ? "user" : "assistant",
      content: msg.content,
    })),
    { role: "user", content: message },
  ];

  const startTime = Date.now();

  const response = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${process.env.OPENAI_API_KEY}`,
    },
    body: JSON.stringify({
      model: "gpt-3.5-turbo",
      messages: conversation,
      max_tokens: 150,
      temperature: 0.7,
    }),
  });

  const result = await response.json();
  const processingTime = Date.now() - startTime;

  return {
    content: result.choices[0].message.content,
    confidence: 0.85, // Could be calculated based on response quality
    processing_time: processingTime,
    model: "gpt-3.5-turbo",
    tokens_used: result.usage.total_tokens,
  };
}
```

### Conversation Context Management

```typescript
async function getConversationContext(
  customerId: string,
  limit: number = 5,
): Promise<ConversationContext> {
  const messages = await db
    .select()
    .from(messages)
    .where(eq(messages.customer_id, customerId))
    .orderBy(desc(messages.created_at))
    .limit(limit);

  return {
    customerId,
    previousMessages: messages.reverse(),
    messageCount: messages.length,
    lastMessageAt: messages[messages.length - 1]?.created_at,
  };
}
```

## Error Handling

### Zalo API Error Types

```typescript
class ZaloAPIError extends Error {
  constructor(
    message: string,
    public code: number,
    public type: string = "ZALO_API_ERROR",
  ) {
    super(message);
    this.name = "ZaloAPIError";
  }
}

// Common Zalo error codes
enum ZaloErrorCode {
  INVALID_ACCESS_TOKEN = -201,
  RATE_LIMIT_EXCEEDED = -1002,
  USER_BLOCKED_OA = -1004,
  MESSAGE_TOO_LONG = -1005,
  INVALID_USER_ID = -1006,
  OA_NOT_APPROVED = -1007,
}

function handleZaloError(error: any): never {
  const errorMap = {
    [ZaloErrorCode.INVALID_ACCESS_TOKEN]: "Access token không hợp lệ",
    [ZaloErrorCode.RATE_LIMIT_EXCEEDED]: "Vượt quá giới hạn gửi tin",
    [ZaloErrorCode.USER_BLOCKED_OA]: "Người dùng đã chặn OA",
    [ZaloErrorCode.MESSAGE_TOO_LONG]: "Tin nhắn quá dài",
    [ZaloErrorCode.INVALID_USER_ID]: "ID người dùng không hợp lệ",
    [ZaloErrorCode.OA_NOT_APPROVED]: "OA chưa được phê duyệt",
  };

  const message =
    errorMap[error.code] || error.message || "Lỗi API Zalo không xác định";
  throw new ZaloAPIError(message, error.code);
}
```

### Retry Logic

```typescript
async function withRetry<T>(
  operation: () => Promise<T>,
  maxRetries: number = 3,
  delayMs: number = 1000,
): Promise<T> {
  let lastError: Error;

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await operation();
    } catch (error) {
      lastError = error;

      // Don't retry for certain errors
      if (error instanceof ZaloAPIError) {
        if (
          [
            ZaloErrorCode.INVALID_ACCESS_TOKEN,
            ZaloErrorCode.USER_BLOCKED_OA,
            ZaloErrorCode.INVALID_USER_ID,
          ].includes(error.code)
        ) {
          throw error;
        }
      }

      if (attempt === maxRetries) break;

      // Exponential backoff
      await new Promise((resolve) =>
        setTimeout(resolve, delayMs * Math.pow(2, attempt - 1)),
      );
    }
  }

  throw lastError;
}

// Usage
const message = await withRetry(() => sendTextMessage(userId, text));
```

## Rate Limiting

### Zalo API Rate Limits

```typescript
class ZaloRateLimiter {
  private messageQueue: Map<string, number[]> = new Map();
  private readonly messagesPerMinute = 20; // Zalo limit
  private readonly windowMs = 60 * 1000; // 1 minute

  async checkRateLimit(userId: string): Promise<boolean> {
    const now = Date.now();
    const userMessages = this.messageQueue.get(userId) || [];

    // Remove old messages outside the window
    const recentMessages = userMessages.filter(
      (time) => now - time < this.windowMs,
    );

    if (recentMessages.length >= this.messagesPerMinute) {
      return false; // Rate limited
    }

    // Add current message
    recentMessages.push(now);
    this.messageQueue.set(userId, recentMessages);

    return true; // OK to send
  }

  async waitForRateLimit(userId: string): Promise<void> {
    while (!(await this.checkRateLimit(userId))) {
      await new Promise((resolve) => setTimeout(resolve, 1000));
    }
  }
}

const rateLimiter = new ZaloRateLimiter();
```

## Monitoring and Analytics

### Track Zalo API Usage

```typescript
async function trackZaloAPICall(
  endpoint: string,
  success: boolean,
  responseTime: number,
) {
  await db.insert(analytics).values({
    user_id: "system",
    date: new Date().toISOString().split("T")[0],
    metric_type: `zalo_api_${endpoint}`,
    metric_value: success ? 1 : 0,
    metadata: {
      response_time: responseTime,
      success,
    },
  });
}
```

### Health Check

```typescript
export async function checkZaloHealth(): Promise<HealthStatus> {
  try {
    // Test API connectivity
    const response = await fetch("https://openapi.zalo.me/v2.0/oa/getprofile", {
      headers: {
        access_token: process.env.ZALO_OA_ACCESS_TOKEN,
      },
    });

    return {
      service: "zalo",
      status: response.ok ? "healthy" : "unhealthy",
      timestamp: Date.now(),
      details: {
        response_code: response.status,
        access_token_valid: response.ok,
      },
    };
  } catch (error) {
    return {
      service: "zalo",
      status: "unhealthy",
      timestamp: Date.now(),
      error: error.message,
    };
  }
}
```

This Zalo integration specification provides a complete, robust integration with Zalo Official Account APIs while maintaining KISS principles and ensuring reliable message handling for Vietnamese small businesses.

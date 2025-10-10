# Zalo AI Assistant - Real-time Communication Specification

## Overview

This document defines the real-time communication system for the Zalo AI Assistant. The system uses Server-Sent Events (SSE) as the primary method with polling fallback to provide live updates to users about new messages, customer activity, and system status.

## Real-time Architecture

### Core Requirements

- **Live Message Updates**: New messages appear instantly in the dashboard
- **Customer Status**: Online/offline status and typing indicators
- **System Notifications**: Connection status, errors, and alerts
- **Cross-Browser Support**: Works on all modern browsers
- **Fallback Strategy**: Graceful degradation when SSE is not available
- **Bandwidth Efficiency**: Minimal data transfer for updates

### Technology Choices

**Primary: Server-Sent Events (SSE)**

- Native browser support
- Automatic reconnection
- Simple implementation
- Works with Cloudflare Pages
- HTTP/2 multiplexing support

**Fallback: Polling**

- Universal compatibility
- Predictable behavior
- Easy to implement
- Good for low-frequency updates

## Server-Sent Events Implementation

### SSE Endpoint Setup

```typescript
export async function handleSSEConnection(c: Context) {
  const user = c.get("user");
  if (!user) {
    return c.json({ error: "Authentication required" }, 401);
  }

  // Set SSE headers
  const headers = new Headers({
    "Content-Type": "text/event-stream",
    "Cache-Control": "no-cache",
    Connection: "keep-alive",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Cache-Control",
  });

  // Create readable stream
  const stream = new ReadableStream({
    start(controller) {
      // Send initial connection message
      const data = JSON.stringify({
        type: "connection",
        data: { status: "connected", timestamp: Date.now() },
      });
      controller.enqueue(`data: ${data}\n\n`);

      // Register client for updates
      registerSSEClient(user.id, controller);

      // Send heartbeat every 30 seconds
      const heartbeat = setInterval(() => {
        try {
          controller.enqueue(
            `data: ${JSON.stringify({ type: "heartbeat", timestamp: Date.now() })}\n\n`,
          );
        } catch (error) {
          clearInterval(heartbeat);
          unregisterSSEClient(user.id);
        }
      }, 30000);

      // Cleanup on connection close
      return () => {
        clearInterval(heartbeat);
        unregisterSSEClient(user.id);
      };
    },
  });

  return new Response(stream, { headers });
}
```

### SSE Client Management

```typescript
// Store active SSE connections
const sseClients = new Map<string, ReadableStreamDefaultController>();

function registerSSEClient(
  userId: string,
  controller: ReadableStreamDefaultController,
) {
  sseClients.set(userId, controller);
  console.log(`SSE client registered: ${userId}`);
}

function unregisterSSEClient(userId: string) {
  sseClients.delete(userId);
  console.log(`SSE client unregistered: ${userId}`);
}

// Send event to specific user
export function sendSSEEvent(userId: string, event: SSEEvent) {
  const controller = sseClients.get(userId);
  if (!controller) return false;

  try {
    const data = JSON.stringify(event);
    controller.enqueue(`data: ${data}\n\n`);
    return true;
  } catch (error) {
    // Connection closed, remove client
    unregisterSSEClient(userId);
    return false;
  }
}

// Broadcast to all connected users
export function broadcastSSEEvent(event: SSEEvent) {
  for (const [userId] of sseClients) {
    sendSSEEvent(userId, event);
  }
}
```

### Event Types

```typescript
interface SSEEvent {
  type: string;
  data: any;
  timestamp?: number;
  id?: string;
}

// Message events
const newMessageEvent: SSEEvent = {
  type: "new_message",
  data: {
    id: "msg_123",
    customer_id: "customer_456",
    customer_name: "Nguyễn Văn A",
    content: "Xin chào, tôi cần hỗ trợ",
    type: "incoming",
    created_at: Date.now(),
  },
  timestamp: Date.now(),
};

// Customer status events
const customerStatusEvent: SSEEvent = {
  type: "customer_status",
  data: {
    customer_id: "customer_456",
    status: "online",
    last_seen: Date.now(),
  },
  timestamp: Date.now(),
};

// System events
const systemEvent: SSEEvent = {
  type: "system_notification",
  data: {
    level: "info",
    message: "Zalo connection restored",
    action: "zalo_reconnect",
  },
  timestamp: Date.now(),
};
```

## Frontend SSE Client

### SSE Connection Manager

```javascript
class SSEManager {
  constructor(apiUrl, authToken) {
    this.apiUrl = apiUrl;
    this.authToken = authToken;
    this.eventSource = null;
    this.listeners = new Map();
    this.reconnectAttempts = 0;
    this.maxReconnectAttempts = 5;
    this.reconnectDelay = 1000;
    this.isConnected = false;
  }

  connect() {
    if (this.eventSource) {
      this.disconnect();
    }

    try {
      // Create EventSource with auth header (via URL parameter for SSE)
      const url = `${this.apiUrl}/api/events/stream?token=${this.authToken}`;
      this.eventSource = new EventSource(url);

      this.eventSource.onopen = () => {
        console.log("SSE connection opened");
        this.isConnected = true;
        this.reconnectAttempts = 0;
        this.emit("connection", { status: "connected" });
      };

      this.eventSource.onmessage = (event) => {
        try {
          const data = JSON.parse(event.data);
          this.handleEvent(data);
        } catch (error) {
          console.error("Failed to parse SSE event:", error);
        }
      };

      this.eventSource.onerror = () => {
        console.log("SSE connection error");
        this.isConnected = false;
        this.emit("connection", { status: "error" });
        this.scheduleReconnect();
      };
    } catch (error) {
      console.error("Failed to create SSE connection:", error);
      this.fallbackToPolling();
    }
  }

  disconnect() {
    if (this.eventSource) {
      this.eventSource.close();
      this.eventSource = null;
      this.isConnected = false;
    }
  }

  handleEvent(event) {
    console.log("SSE event received:", event.type);
    this.emit(event.type, event.data);
  }

  scheduleReconnect() {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      console.log("Max reconnect attempts reached, falling back to polling");
      this.fallbackToPolling();
      return;
    }

    this.reconnectAttempts++;
    const delay = this.reconnectDelay * Math.pow(2, this.reconnectAttempts - 1);

    setTimeout(() => {
      console.log(`Reconnecting SSE (attempt ${this.reconnectAttempts})`);
      this.connect();
    }, delay);
  }

  fallbackToPolling() {
    console.log("Starting polling fallback");
    this.disconnect();
    this.startPolling();
  }

  // Event listener management
  on(eventType, callback) {
    if (!this.listeners.has(eventType)) {
      this.listeners.set(eventType, []);
    }
    this.listeners.get(eventType).push(callback);
  }

  off(eventType, callback) {
    const callbacks = this.listeners.get(eventType);
    if (callbacks) {
      const index = callbacks.indexOf(callback);
      if (index > -1) {
        callbacks.splice(index, 1);
      }
    }
  }

  emit(eventType, data) {
    const callbacks = this.listeners.get(eventType);
    if (callbacks) {
      callbacks.forEach((callback) => {
        try {
          callback(data);
        } catch (error) {
          console.error("Error in SSE event callback:", error);
        }
      });
    }
  }
}
```

### Polling Fallback

```javascript
class PollingManager {
  constructor(apiUrl, authToken) {
    this.apiUrl = apiUrl;
    this.authToken = authToken;
    this.pollInterval = null;
    this.pollDelay = 5000; // 5 seconds
    this.lastPollTime = 0;
    this.listeners = new Map();
  }

  startPolling() {
    if (this.pollInterval) {
      this.stopPolling();
    }

    this.pollInterval = setInterval(() => {
      this.poll();
    }, this.pollDelay);

    // Initial poll
    this.poll();
  }

  stopPolling() {
    if (this.pollInterval) {
      clearInterval(this.pollInterval);
      this.pollInterval = null;
    }
  }

  async poll() {
    try {
      const response = await fetch(
        `${this.apiUrl}/api/events/poll?since=${this.lastPollTime}`,
        {
          headers: {
            Authorization: `Bearer ${this.authToken}`,
          },
        },
      );

      if (!response.ok) {
        throw new Error(`Polling failed: ${response.statusText}`);
      }

      const { events } = await response.json();
      this.lastPollTime = Date.now();

      events.forEach((event) => {
        this.emit(event.type, event.data);
      });
    } catch (error) {
      console.error("Polling error:", error);
      this.emit("connection", { status: "error" });
    }
  }

  // Reuse event management from SSE manager
  on(eventType, callback) {
    if (!this.listeners.has(eventType)) {
      this.listeners.set(eventType, []);
    }
    this.listeners.get(eventType).push(callback);
  }

  emit(eventType, data) {
    const callbacks = this.listeners.get(eventType);
    if (callbacks) {
      callbacks.forEach((callback) => callback(data));
    }
  }
}
```

## Polling Endpoint

### Poll for Updates

```typescript
export async function handlePolling(c: Context) {
  const user = c.get("user");
  const since = parseInt(c.req.query("since") || "0");

  try {
    // Get events since last poll
    const events = await getEventsForUser(user.id, since);

    return c.json({
      success: true,
      data: {
        events,
        timestamp: Date.now(),
      },
    });
  } catch (error) {
    return c.json({ error: "Failed to fetch events" }, 500);
  }
}

async function getEventsForUser(
  userId: string,
  since: number,
): Promise<SSEEvent[]> {
  const events: SSEEvent[] = [];

  // Get new messages
  const newMessages = await db
    .select()
    .from(messages)
    .where(and(eq(messages.user_id, userId), gt(messages.created_at, since)))
    .orderBy(asc(messages.created_at));

  newMessages.forEach((message) => {
    events.push({
      type: "new_message",
      data: {
        id: message.id,
        customer_id: message.customer_id,
        content: message.content,
        type: message.type,
        created_at: message.created_at,
      },
      timestamp: message.created_at,
    });
  });

  // Get customer status updates
  const customerUpdates = await getCustomerUpdates(userId, since);
  events.push(...customerUpdates);

  // Get system notifications
  const systemUpdates = await getSystemUpdates(userId, since);
  events.push(...systemUpdates);

  return events;
}
```

## Real-time UI Updates

### Message Display Updates

```javascript
class MessageDisplay {
  constructor(containerId) {
    this.container = document.getElementById(containerId);
    this.setupRealtime();
  }

  setupRealtime() {
    // Initialize SSE manager
    this.realtime = new SSEManager("/api", localStorage.getItem("auth_token"));

    // Listen for new messages
    this.realtime.on("new_message", (message) => {
      this.addMessage(message);
      this.playNotificationSound();
      this.updateUnreadCount();
    });

    // Listen for message status updates
    this.realtime.on("message_status", (status) => {
      this.updateMessageStatus(status.message_id, status.status);
    });

    // Start connection
    this.realtime.connect();
  }

  addMessage(message) {
    const messageElement = this.createMessageElement(message);

    // Add with animation
    messageElement.style.opacity = "0";
    messageElement.style.transform = "translateY(20px)";
    this.container.appendChild(messageElement);

    // Animate in
    requestAnimationFrame(() => {
      messageElement.style.transition = "opacity 0.3s, transform 0.3s";
      messageElement.style.opacity = "1";
      messageElement.style.transform = "translateY(0)";
    });

    // Scroll to bottom
    this.scrollToBottom();
  }

  createMessageElement(message) {
    const element = document.createElement("div");
    element.className = `message ${message.type}`;
    element.dataset.messageId = message.id;

    element.innerHTML = `
      <div class="message-header">
        <span class="customer-name">${message.customer_name}</span>
        <span class="timestamp">${this.formatTime(message.created_at)}</span>
      </div>
      <div class="message-content">${this.escapeHtml(message.content)}</div>
      <div class="message-status" data-status="sent">Đã gửi</div>
    `;

    return element;
  }

  updateMessageStatus(messageId, status) {
    const element = this.container.querySelector(
      `[data-message-id="${messageId}"]`,
    );
    if (element) {
      const statusElement = element.querySelector(".message-status");
      statusElement.dataset.status = status;
      statusElement.textContent = this.getStatusText(status);
    }
  }

  playNotificationSound() {
    // Only play if page is not visible
    if (document.hidden) {
      const audio = new Audio("/sounds/notification.mp3");
      audio.volume = 0.5;
      audio.play().catch(() => {}); // Ignore if blocked
    }
  }

  updateUnreadCount() {
    const badge = document.querySelector(".unread-badge");
    if (badge && document.hidden) {
      const current = parseInt(badge.textContent) || 0;
      badge.textContent = current + 1;
      badge.style.display = "block";
    }
  }

  scrollToBottom() {
    this.container.scrollTo({
      top: this.container.scrollHeight,
      behavior: "smooth",
    });
  }

  formatTime(timestamp) {
    return new Date(timestamp).toLocaleTimeString("vi-VN", {
      hour: "2-digit",
      minute: "2-digit",
    });
  }

  escapeHtml(text) {
    const div = document.createElement("div");
    div.textContent = text;
    return div.innerHTML;
  }

  getStatusText(status) {
    const statusMap = {
      sent: "Đã gửi",
      delivered: "Đã nhận",
      read: "Đã đọc",
      failed: "Lỗi",
    };
    return statusMap[status] || status;
  }
}
```

### Customer Status Indicators

```javascript
class CustomerStatus {
  constructor() {
    this.statusMap = new Map();
    this.setupRealtime();
  }

  setupRealtime() {
    window.realtime.on("customer_status", (status) => {
      this.updateCustomerStatus(status.customer_id, status);
    });
  }

  updateCustomerStatus(customerId, status) {
    this.statusMap.set(customerId, status);

    // Update UI indicators
    const indicators = document.querySelectorAll(
      `[data-customer-id="${customerId}"] .status-indicator`,
    );
    indicators.forEach((indicator) => {
      indicator.className = `status-indicator ${status.status}`;
      indicator.title = this.getStatusText(status);
    });

    // Update typing indicators
    if (status.typing) {
      this.showTypingIndicator(customerId);
    } else {
      this.hideTypingIndicator(customerId);
    }
  }

  showTypingIndicator(customerId) {
    const conversation = document.querySelector(
      `[data-customer-id="${customerId}"] .conversation`,
    );
    if (conversation) {
      let indicator = conversation.querySelector(".typing-indicator");
      if (!indicator) {
        indicator = this.createTypingIndicator();
        conversation.appendChild(indicator);
      }
    }
  }

  hideTypingIndicator(customerId) {
    const indicator = document.querySelector(
      `[data-customer-id="${customerId}"] .typing-indicator`,
    );
    if (indicator) {
      indicator.remove();
    }
  }

  createTypingIndicator() {
    const element = document.createElement("div");
    element.className = "typing-indicator";
    element.innerHTML = `
      <div class="typing-dots">
        <span></span>
        <span></span>
        <span></span>
      </div>
      <span class="typing-text">Đang soạn tin...</span>
    `;
    return element;
  }

  getStatusText(status) {
    const now = Date.now();
    const lastSeen = status.last_seen;
    const diffMinutes = Math.floor((now - lastSeen) / (1000 * 60));

    if (status.status === "online") {
      return "Đang hoạt động";
    } else if (diffMinutes < 5) {
      return "Vừa truy cập";
    } else if (diffMinutes < 60) {
      return `${diffMinutes} phút trước`;
    } else {
      const diffHours = Math.floor(diffMinutes / 60);
      return `${diffHours} giờ trước`;
    }
  }
}
```

## Connection Status Management

### Connection Indicator

```javascript
class ConnectionStatus {
  constructor() {
    this.indicator = this.createIndicator();
    document.body.appendChild(this.indicator);
    this.setupRealtime();
  }

  createIndicator() {
    const element = document.createElement("div");
    element.className = "connection-status";
    element.innerHTML = `
      <div class="status-icon"></div>
      <span class="status-text">Đang kết nối...</span>
    `;
    return element;
  }

  setupRealtime() {
    window.realtime.on("connection", (status) => {
      this.updateStatus(status.status);
    });
  }

  updateStatus(status) {
    const icon = this.indicator.querySelector(".status-icon");
    const text = this.indicator.querySelector(".status-text");

    this.indicator.className = `connection-status ${status}`;

    switch (status) {
      case "connected":
        text.textContent = "Đã kết nối";
        setTimeout(() => {
          this.indicator.style.display = "none";
        }, 2000);
        break;

      case "connecting":
        text.textContent = "Đang kết nối...";
        this.indicator.style.display = "block";
        break;

      case "error":
        text.textContent = "Mất kết nối";
        this.indicator.style.display = "block";
        break;

      case "reconnecting":
        text.textContent = "Đang kết nối lại...";
        this.indicator.style.display = "block";
        break;
    }
  }
}
```

## Performance Optimizations

### Event Batching

```typescript
class EventBatcher {
  private events: SSEEvent[] = [];
  private batchTimeout: NodeJS.Timeout | null = null;
  private readonly batchDelay = 100; // 100ms
  private readonly maxBatchSize = 10;

  addEvent(userId: string, event: SSEEvent) {
    this.events.push({ ...event, userId });

    if (this.events.length >= this.maxBatchSize) {
      this.flush();
    } else if (!this.batchTimeout) {
      this.batchTimeout = setTimeout(() => this.flush(), this.batchDelay);
    }
  }

  private flush() {
    if (this.batchTimeout) {
      clearTimeout(this.batchTimeout);
      this.batchTimeout = null;
    }

    if (this.events.length === 0) return;

    // Group events by user
    const userEvents = new Map<string, SSEEvent[]>();
    this.events.forEach((event) => {
      const userId = event.userId;
      if (!userEvents.has(userId)) {
        userEvents.set(userId, []);
      }
      userEvents.get(userId)!.push(event);
    });

    // Send batched events
    userEvents.forEach((events, userId) => {
      if (events.length === 1) {
        sendSSEEvent(userId, events[0]);
      } else {
        sendSSEEvent(userId, {
          type: "batch",
          data: { events },
          timestamp: Date.now(),
        });
      }
    });

    this.events = [];
  }
}

const eventBatcher = new EventBatcher();
```

### Memory Management

```typescript
// Cleanup inactive connections periodically
setInterval(() => {
  const now = Date.now();
  const staleTimeout = 5 * 60 * 1000; // 5 minutes

  sseClients.forEach((controller, userId) => {
    // Send heartbeat to check connection
    try {
      controller.enqueue(
        `data: ${JSON.stringify({ type: "heartbeat", timestamp: now })}\n\n`,
      );
    } catch (error) {
      // Connection is dead, remove it
      unregisterSSEClient(userId);
    }
  });
}, 60000); // Check every minute
```

This real-time communication specification provides a complete, efficient, and KISS-compliant system for delivering live updates to users of the Zalo AI Assistant while ensuring reliable fallback mechanisms and optimal performance.

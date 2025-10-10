# Zalo AI Assistant - Monitoring & Logging

## Overview

This document defines the monitoring, logging, and observability strategy for the Zalo AI Assistant. The approach follows KISS principles with practical monitoring that provides essential insights while maintaining simplicity for solo developers.

## Monitoring Philosophy

### Core Principles

- **Monitor What Matters**: Focus on business metrics and user experience
- **Simple Setup**: Minimal configuration with maximum insight
- **Cost Effective**: Use free tiers and built-in tools where possible
- **Actionable Alerts**: Only alert on issues that require immediate action
- **Progressive Enhancement**: Start basic, add complexity as needed

### Monitoring Stack

- **Application Metrics**: Built-in application logging
- **Infrastructure**: Cloudflare Analytics (built-in)
- **Uptime**: UptimeRobot (free tier)
- **Error Tracking**: Simple error logging and aggregation
- **Business Metrics**: Custom dashboard with key KPIs

## Application Logging

### Logging Framework

```typescript
// src/utils/logger.ts
interface LogEntry {
  timestamp: string;
  level: "debug" | "info" | "warn" | "error";
  service: string;
  message: string;
  metadata?: Record<string, any>;
  requestId?: string;
}

class Logger {
  private serviceName: string;
  private logLevel: string;

  constructor(serviceName: string) {
    this.serviceName = serviceName;
    this.logLevel = process.env.LOG_LEVEL || "info";
  }

  private shouldLog(level: string): boolean {
    const levels = ["debug", "info", "warn", "error"];
    return levels.indexOf(level) >= levels.indexOf(this.logLevel);
  }

  private formatLog(entry: LogEntry): string {
    return JSON.stringify({
      ...entry,
      timestamp: new Date().toISOString(),
      service: this.serviceName,
      environment: process.env.NODE_ENV || "development",
    });
  }

  debug(message: string, metadata?: Record<string, any>, requestId?: string) {
    if (this.shouldLog("debug")) {
      console.log(
        this.formatLog({
          timestamp: "",
          level: "debug",
          service: this.serviceName,
          message,
          metadata,
          requestId,
        }),
      );
    }
  }

  info(message: string, metadata?: Record<string, any>, requestId?: string) {
    if (this.shouldLog("info")) {
      console.log(
        this.formatLog({
          timestamp: "",
          level: "info",
          service: this.serviceName,
          message,
          metadata,
          requestId,
        }),
      );
    }
  }

  warn(message: string, metadata?: Record<string, any>, requestId?: string) {
    if (this.shouldLog("warn")) {
      console.warn(
        this.formatLog({
          timestamp: "",
          level: "warn",
          service: this.serviceName,
          message,
          metadata,
          requestId,
        }),
      );
    }
  }

  error(
    message: string,
    error?: Error,
    metadata?: Record<string, any>,
    requestId?: string,
  ) {
    if (this.shouldLog("error")) {
      console.error(
        this.formatLog({
          timestamp: "",
          level: "error",
          service: this.serviceName,
          message,
          metadata: {
            ...metadata,
            error: error
              ? {
                  name: error.name,
                  message: error.message,
                  stack: error.stack,
                }
              : undefined,
          },
          requestId,
        }),
      );
    }
  }
}

// Export logger instances
export const logger = new Logger("app");
export const apiLogger = new Logger("api");
export const zaloLogger = new Logger("zalo");
export const aiLogger = new Logger("ai");
```

### Request Logging Middleware

```typescript
// src/middleware/logging.ts
import { Context } from "hono";
import { apiLogger } from "../utils/logger";

export function requestLoggingMiddleware() {
  return async (c: Context, next: () => Promise<void>) => {
    const requestId = generateRequestId();
    const startTime = Date.now();

    // Add request ID to context
    c.set("requestId", requestId);

    // Log incoming request
    apiLogger.info(
      "Request started",
      {
        method: c.req.method,
        path: c.req.path,
        userAgent: c.req.header("User-Agent"),
        ip: c.req.header("CF-Connecting-IP") || c.req.header("X-Forwarded-For"),
      },
      requestId,
    );

    try {
      await next();
    } catch (error) {
      // Log error
      apiLogger.error(
        "Request failed",
        error,
        {
          method: c.req.method,
          path: c.req.path,
        },
        requestId,
      );
      throw error;
    } finally {
      // Log response
      const duration = Date.now() - startTime;
      apiLogger.info(
        "Request completed",
        {
          method: c.req.method,
          path: c.req.path,
          status: c.res.status,
          duration,
        },
        requestId,
      );
    }
  };
}

function generateRequestId(): string {
  return `req_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
}
```

### Service-Specific Logging

```typescript
// src/services/zalo.service.ts
import { zaloLogger } from "../utils/logger";

export class ZaloService {
  async sendMessage(userId: string, message: string, requestId?: string) {
    zaloLogger.info(
      "Sending message to Zalo",
      {
        userId,
        messageLength: message.length,
      },
      requestId,
    );

    try {
      const response = await fetch("https://openapi.zalo.me/v2.0/oa/message", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          access_token: this.accessToken,
        },
        body: JSON.stringify({
          recipient: { user_id: userId },
          message: { text: message },
        }),
      });

      const result = await response.json();

      if (result.error) {
        zaloLogger.error(
          "Zalo API error",
          new Error(result.message),
          {
            errorCode: result.error,
            userId,
          },
          requestId,
        );
        throw new Error(result.message);
      }

      zaloLogger.info(
        "Message sent successfully",
        {
          userId,
          messageId: result.data?.message_id,
        },
        requestId,
      );

      return result;
    } catch (error) {
      zaloLogger.error("Failed to send message", error, { userId }, requestId);
      throw error;
    }
  }
}
```

```typescript
// src/services/ai.service.ts
import { aiLogger } from "../utils/logger";

export class AIService {
  async generateResponse(params: any, requestId?: string) {
    const startTime = Date.now();

    aiLogger.info(
      "Generating AI response",
      {
        messageLength: params.message.length,
        hasContext: !!params.context,
      },
      requestId,
    );

    try {
      const response = await fetch(
        "https://api.openai.com/v1/chat/completions",
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${this.apiKey}`,
          },
          body: JSON.stringify({
            model: this.model,
            messages: this.buildMessages(params),
            max_tokens: this.maxTokens,
            temperature: 0.7,
          }),
        },
      );

      const result = await response.json();
      const duration = Date.now() - startTime;

      if (result.error) {
        aiLogger.error(
          "OpenAI API error",
          new Error(result.error.message),
          {
            errorType: result.error.type,
            errorCode: result.error.code,
          },
          requestId,
        );
        throw new Error(result.error.message);
      }

      aiLogger.info(
        "AI response generated",
        {
          tokensUsed: result.usage?.total_tokens,
          responseLength: result.choices[0]?.message?.content?.length,
          duration,
        },
        requestId,
      );

      return {
        content: result.choices[0].message.content,
        tokensUsed: result.usage.total_tokens,
        duration,
      };
    } catch (error) {
      aiLogger.error(
        "Failed to generate AI response",
        error,
        {
          duration: Date.now() - startTime,
        },
        requestId,
      );
      throw error;
    }
  }
}
```

## Metrics Collection

### Application Metrics

```typescript
// src/utils/metrics.ts
interface Metric {
  name: string;
  value: number;
  timestamp: number;
  tags?: Record<string, string>;
}

class MetricsCollector {
  private metrics: Metric[] = [];

  increment(name: string, value: number = 1, tags?: Record<string, string>) {
    this.metrics.push({
      name,
      value,
      timestamp: Date.now(),
      tags,
    });
  }

  timing(name: string, duration: number, tags?: Record<string, string>) {
    this.metrics.push({
      name: `${name}.duration`,
      value: duration,
      timestamp: Date.now(),
      tags,
    });
  }

  gauge(name: string, value: number, tags?: Record<string, string>) {
    this.metrics.push({
      name,
      value,
      timestamp: Date.now(),
      tags,
    });
  }

  // Flush metrics to storage every minute
  async flushMetrics() {
    if (this.metrics.length === 0) return;

    try {
      await this.storeMetrics(this.metrics);
      this.metrics = [];
    } catch (error) {
      logger.error("Failed to flush metrics", error);
    }
  }

  private async storeMetrics(metrics: Metric[]) {
    // Store metrics in database or send to external service
    // For simplicity, we'll store in our database
    const db = getDatabase();

    for (const metric of metrics) {
      await db
        .prepare(
          `
        INSERT INTO metrics (name, value, timestamp, tags)
        VALUES (?, ?, ?, ?)
      `,
        )
        .run(
          metric.name,
          metric.value,
          metric.timestamp,
          JSON.stringify(metric.tags || {}),
        );
    }
  }
}

export const metrics = new MetricsCollector();

// Auto-flush metrics every minute
setInterval(() => {
  metrics.flushMetrics();
}, 60000);
```

### Business Metrics

```typescript
// src/utils/business-metrics.ts
import { metrics } from "./metrics";

export class BusinessMetrics {
  static recordMessageReceived(type: "incoming" | "outgoing", userId: string) {
    metrics.increment("messages.received", 1, {
      type,
      userId,
    });
  }

  static recordAIResponse(
    tokensUsed: number,
    duration: number,
    userId: string,
  ) {
    metrics.increment("ai.responses.generated", 1, { userId });
    metrics.timing("ai.response.duration", duration, { userId });
    metrics.increment("ai.tokens.used", tokensUsed, { userId });
  }

  static recordCustomerInteraction(customerId: string, userId: string) {
    metrics.increment("customers.interactions", 1, {
      customerId,
      userId,
    });
  }

  static recordError(service: string, errorType: string) {
    metrics.increment("errors.occurred", 1, {
      service,
      errorType,
    });
  }

  static recordResponseTime(endpoint: string, duration: number) {
    metrics.timing("api.response.time", duration, {
      endpoint,
    });
  }
}
```

## Health Monitoring

### Health Check System

```typescript
// src/api/health.ts
import { Context } from "hono";

interface HealthCheck {
  name: string;
  status: "healthy" | "unhealthy" | "degraded";
  lastCheck: number;
  responseTime?: number;
  error?: string;
}

export async function healthCheck(c: Context) {
  const checks: HealthCheck[] = [];

  // Database health
  checks.push(await checkDatabase());

  // External services health
  checks.push(await checkZaloAPI());
  checks.push(await checkOpenAI());

  // System health
  checks.push(await checkMemoryUsage());
  checks.push(await checkDiskSpace());

  const overallStatus = checks.every((check) => check.status === "healthy")
    ? "healthy"
    : checks.some((check) => check.status === "unhealthy")
      ? "unhealthy"
      : "degraded";

  const response = {
    status: overallStatus,
    timestamp: Date.now(),
    uptime: process.uptime?.() || 0,
    version: process.env.npm_package_version || "1.0.0",
    environment: process.env.NODE_ENV || "development",
    checks: checks.reduce(
      (acc, check) => {
        acc[check.name] = {
          status: check.status,
          responseTime: check.responseTime,
          error: check.error,
          lastCheck: check.lastCheck,
        };
        return acc;
      },
      {} as Record<string, any>,
    ),
  };

  const statusCode = overallStatus === "healthy" ? 200 : 503;
  return c.json(response, statusCode);
}

async function checkDatabase(): Promise<HealthCheck> {
  const startTime = Date.now();

  try {
    const db = getDatabase();
    await db.prepare("SELECT 1").get();

    return {
      name: "database",
      status: "healthy",
      lastCheck: Date.now(),
      responseTime: Date.now() - startTime,
    };
  } catch (error) {
    return {
      name: "database",
      status: "unhealthy",
      lastCheck: Date.now(),
      responseTime: Date.now() - startTime,
      error: error.message,
    };
  }
}

async function checkZaloAPI(): Promise<HealthCheck> {
  const startTime = Date.now();

  try {
    const response = await fetch("https://openapi.zalo.me/v2.0/oa/getprofile", {
      headers: {
        access_token: process.env.ZALO_OA_ACCESS_TOKEN!,
      },
    });

    const status = response.ok ? "healthy" : "degraded";

    return {
      name: "zalo_api",
      status,
      lastCheck: Date.now(),
      responseTime: Date.now() - startTime,
      error: response.ok ? undefined : `HTTP ${response.status}`,
    };
  } catch (error) {
    return {
      name: "zalo_api",
      status: "unhealthy",
      lastCheck: Date.now(),
      responseTime: Date.now() - startTime,
      error: error.message,
    };
  }
}

async function checkOpenAI(): Promise<HealthCheck> {
  const startTime = Date.now();

  try {
    const response = await fetch("https://api.openai.com/v1/models", {
      headers: {
        Authorization: `Bearer ${process.env.OPENAI_API_KEY}`,
      },
    });

    const status = response.ok ? "healthy" : "degraded";

    return {
      name: "openai_api",
      status,
      lastCheck: Date.now(),
      responseTime: Date.now() - startTime,
      error: response.ok ? undefined : `HTTP ${response.status}`,
    };
  } catch (error) {
    return {
      name: "openai_api",
      status: "unhealthy",
      lastCheck: Date.now(),
      responseTime: Date.now() - startTime,
      error: error.message,
    };
  }
}

async function checkMemoryUsage(): Promise<HealthCheck> {
  try {
    const memUsage = process.memoryUsage();
    const usedMB = Math.round(memUsage.heapUsed / 1024 / 1024);
    const totalMB = Math.round(memUsage.heapTotal / 1024 / 1024);
    const usagePercent = (usedMB / totalMB) * 100;

    let status: "healthy" | "degraded" | "unhealthy" = "healthy";
    if (usagePercent > 90) status = "unhealthy";
    else if (usagePercent > 75) status = "degraded";

    return {
      name: "memory",
      status,
      lastCheck: Date.now(),
      error:
        status !== "healthy"
          ? `Memory usage: ${usagePercent.toFixed(1)}%`
          : undefined,
    };
  } catch (error) {
    return {
      name: "memory",
      status: "unhealthy",
      lastCheck: Date.now(),
      error: error.message,
    };
  }
}

async function checkDiskSpace(): Promise<HealthCheck> {
  // Simplified disk check for Cloudflare Workers
  // In a real environment, you'd check actual disk usage
  return {
    name: "disk",
    status: "healthy",
    lastCheck: Date.now(),
  };
}
```

## Error Tracking

### Error Aggregation

```typescript
// src/utils/error-tracker.ts
interface ErrorReport {
  id: string;
  message: string;
  stack?: string;
  service: string;
  endpoint?: string;
  userId?: string;
  requestId?: string;
  timestamp: number;
  metadata?: Record<string, any>;
}

class ErrorTracker {
  private errors: ErrorReport[] = [];

  track(
    error: Error,
    context: {
      service: string;
      endpoint?: string;
      userId?: string;
      requestId?: string;
      metadata?: Record<string, any>;
    },
  ) {
    const errorReport: ErrorReport = {
      id: `error_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      message: error.message,
      stack: error.stack,
      timestamp: Date.now(),
      ...context,
    };

    this.errors.push(errorReport);

    // Store in database
    this.storeError(errorReport);

    // Alert on critical errors
    if (this.isCriticalError(error, context)) {
      this.sendAlert(errorReport);
    }
  }

  private async storeError(errorReport: ErrorReport) {
    try {
      const db = getDatabase();
      await db
        .prepare(
          `
        INSERT INTO error_logs (
          id, message, stack, service, endpoint, user_id, request_id, metadata, timestamp
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      `,
        )
        .run(
          errorReport.id,
          errorReport.message,
          errorReport.stack,
          errorReport.service,
          errorReport.endpoint,
          errorReport.userId,
          errorReport.requestId,
          JSON.stringify(errorReport.metadata || {}),
          errorReport.timestamp,
        );
    } catch (err) {
      console.error("Failed to store error report:", err);
    }
  }

  private isCriticalError(error: Error, context: any): boolean {
    // Define critical error patterns
    const criticalPatterns = [
      /database.*connection/i,
      /auth.*failed/i,
      /payment.*error/i,
      /zalo.*api.*down/i,
    ];

    return criticalPatterns.some(
      (pattern) => pattern.test(error.message) || pattern.test(context.service),
    );
  }

  private async sendAlert(errorReport: ErrorReport) {
    // Send alert via email, Slack, etc.
    // For simplicity, we'll just log it prominently
    console.error(
      "🚨 CRITICAL ERROR ALERT 🚨",
      JSON.stringify(errorReport, null, 2),
    );

    // Could integrate with external alerting services:
    // - Email via SMTP
    // - Slack webhook
    // - Discord webhook
    // - SMS via Twilio
  }

  async getErrorSummary(hours: number = 24): Promise<{
    totalErrors: number;
    errorsByService: Record<string, number>;
    criticalErrors: number;
    topErrors: Array<{ message: string; count: number }>;
  }> {
    const since = Date.now() - hours * 60 * 60 * 1000;
    const db = getDatabase();

    const totalErrors = await db
      .prepare(
        `
      SELECT COUNT(*) as count FROM error_logs WHERE timestamp > ?
    `,
      )
      .get(since);

    const errorsByService = await db
      .prepare(
        `
      SELECT service, COUNT(*) as count 
      FROM error_logs 
      WHERE timestamp > ? 
      GROUP BY service
    `,
      )
      .all(since);

    const topErrors = await db
      .prepare(
        `
      SELECT message, COUNT(*) as count 
      FROM error_logs 
      WHERE timestamp > ? 
      GROUP BY message 
      ORDER BY count DESC 
      LIMIT 10
    `,
      )
      .all(since);

    return {
      totalErrors: totalErrors.count,
      errorsByService: errorsByService.reduce((acc, row) => {
        acc[row.service] = row.count;
        return acc;
      }, {}),
      criticalErrors: 0, // Would need to track this separately
      topErrors,
    };
  }
}

export const errorTracker = new ErrorTracker();
```

## Dashboard and Alerts

### Simple Metrics Dashboard

```typescript
// src/api/dashboard.ts
export async function getDashboardMetrics(c: Context) {
  const period = c.req.query("period") || "24h";
  const hours = period === "7d" ? 168 : period === "30d" ? 720 : 24;

  const since = Date.now() - hours * 60 * 60 * 1000;
  const db = getDatabase();

  // Get message metrics
  const messageStats = await db
    .prepare(
      `
    SELECT 
      type,
      COUNT(*) as count
    FROM messages 
    WHERE created_at > ? 
    GROUP BY type
  `,
    )
    .all(since);

  // Get user activity
  const activeUsers = await db
    .prepare(
      `
    SELECT COUNT(DISTINCT user_id) as count
    FROM messages 
    WHERE created_at > ?
  `,
    )
    .get(since);

  // Get response times
  const avgResponseTime = await db
    .prepare(
      `
    SELECT AVG(
      CASE 
        WHEN m2.created_at IS NOT NULL 
        THEN (m2.created_at - m1.created_at) / 1000.0
        ELSE NULL 
      END
    ) as avg_seconds
    FROM messages m1
    LEFT JOIN messages m2 ON (
      m1.customer_id = m2.customer_id 
      AND m2.created_at > m1.created_at 
      AND m2.type = 'outgoing'
      AND m1.type = 'incoming'
    )
    WHERE m1.created_at > ? AND m1.type = 'incoming'
  `,
    )
    .get(since);

  // Get error count
  const errorCount = await db
    .prepare(
      `
    SELECT COUNT(*) as count
    FROM error_logs 
    WHERE timestamp > ?
  `,
    )
    .get(since);

  // Get AI usage
  const aiStats = await db
    .prepare(
      `
    SELECT 
      COUNT(*) as responses,
      SUM(tokens_used) as total_tokens,
      AVG(response_time) as avg_response_time
    FROM ai_conversations 
    WHERE created_at > ?
  `,
    )
    .get(since);

  return c.json({
    success: true,
    data: {
      period,
      messages: {
        total: messageStats.reduce((sum, stat) => sum + stat.count, 0),
        incoming: messageStats.find((s) => s.type === "incoming")?.count || 0,
        outgoing: messageStats.find((s) => s.type === "outgoing")?.count || 0,
        auto: messageStats.find((s) => s.type === "auto")?.count || 0,
      },
      users: {
        active: activeUsers.count,
      },
      performance: {
        avgResponseTime: avgResponseTime.avg_seconds || 0,
        errorCount: errorCount.count,
      },
      ai: {
        responses: aiStats.responses || 0,
        totalTokens: aiStats.total_tokens || 0,
        avgResponseTime: aiStats.avg_response_time || 0,
      },
    },
  });
}
```

### Alert Configuration

```typescript
// src/utils/alerts.ts
interface AlertRule {
  name: string;
  condition: (metrics: any) => boolean;
  message: string;
  severity: "low" | "medium" | "high" | "critical";
  cooldown: number; // minutes
}

class AlertManager {
  private alertHistory = new Map<string, number>();

  private rules: AlertRule[] = [
    {
      name: "high_error_rate",
      condition: (metrics) => {
        const errorRate = metrics.errors / metrics.totalRequests;
        return errorRate > 0.05; // 5% error rate
      },
      message: "Error rate is above 5%",
      severity: "high",
      cooldown: 30,
    },
    {
      name: "slow_response_time",
      condition: (metrics) => metrics.avgResponseTime > 5000, // 5 seconds
      message: "Average response time is above 5 seconds",
      severity: "medium",
      cooldown: 15,
    },
    {
      name: "ai_service_down",
      condition: (metrics) => metrics.aiHealthy === false,
      message: "AI service is not responding",
      severity: "critical",
      cooldown: 5,
    },
    {
      name: "zalo_service_down",
      condition: (metrics) => metrics.zaloHealthy === false,
      message: "Zalo API is not responding",
      severity: "critical",
      cooldown: 5,
    },
  ];

  async checkAlerts(metrics: any) {
    for (const rule of this.rules) {
      if (rule.condition(metrics)) {
        await this.triggerAlert(rule);
      }
    }
  }

  private async triggerAlert(rule: AlertRule) {
    const now = Date.now();
    const lastAlert = this.alertHistory.get(rule.name) || 0;
    const cooldownMs = rule.cooldown * 60 * 1000;

    // Check cooldown
    if (now - lastAlert < cooldownMs) {
      return;
    }

    // Record alert
    this.alertHistory.set(rule.name, now);

    // Send alert
    await this.sendAlert(rule);
  }

  private async sendAlert(rule: AlertRule) {
    const alert = {
      name: rule.name,
      message: rule.message,
      severity: rule.severity,
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV,
    };

    console.error(`🚨 ALERT [${rule.severity.toUpperCase()}]: ${rule.message}`);

    // Send to external alerting services
    if (process.env.SLACK_WEBHOOK_URL) {
      await this.sendSlackAlert(alert);
    }

    if (process.env.EMAIL_ALERTS_ENABLED === "true") {
      await this.sendEmailAlert(alert);
    }
  }

  private async sendSlackAlert(alert: any) {
    try {
      await fetch(process.env.SLACK_WEBHOOK_URL!, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          text: `🚨 Alert: ${alert.message}`,
          attachments: [
            {
              color: this.getSeverityColor(alert.severity),
              fields: [
                { title: "Severity", value: alert.severity, short: true },
                { title: "Environment", value: alert.environment, short: true },
                { title: "Time", value: alert.timestamp, short: false },
              ],
            },
          ],
        }),
      });
    } catch (error) {
      console.error("Failed to send Slack alert:", error);
    }
  }

  private async sendEmailAlert(alert: any) {
    // Implement email alerting
    // Could use SMTP, SendGrid, etc.
  }

  private getSeverityColor(severity: string): string {
    const colors = {
      low: "#36a64f", // green
      medium: "#ffae42", // orange
      high: "#ff6b6b", // red
      critical: "#d63384", // dark red
    };
    return colors[severity] || colors.medium;
  }
}

export const alertManager = new AlertManager();
```

## External Monitoring Setup

### UptimeRobot Configuration

1. **Create UptimeRobot Account** (Free)
2. **Add HTTP Monitor**:
   - URL: `https://your-domain.pages.dev/api/health`
   - Interval: 5 minutes
   - Alert When: Down
   - Notification: Email/SMS

3. **Add Keyword Monitor**:
   - URL: `https://your-domain.pages.dev/api/health`
   - Keyword: `"status":"healthy"`
   - Alert When: Keyword Not Found

### Cloudflare Analytics

Cloudflare automatically provides:

- Request volume and patterns
- Error rates (4xx, 5xx)
- Response times
- Geographic distribution
- Bot traffic detection

Access via Cloudflare Dashboard → Analytics

### Simple Status Page

```html
<!-- public/status.html -->
<!DOCTYPE html>
<html>
  <head>
    <title>Zalo AI Assistant - Status</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style>
      body {
        font-family: -apple-system, sans-serif;
        margin: 40px;
      }
      .status {
        display: flex;
        align-items: center;
        margin: 20px 0;
      }
      .status-icon {
        width: 20px;
        height: 20px;
        border-radius: 50%;
        margin-right: 15px;
      }
      .healthy {
        background: #28a745;
      }
      .degraded {
        background: #ffc107;
      }
      .unhealthy {
        background: #dc3545;
      }
      .metrics {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 20px;
        margin: 30px 0;
      }
      .metric {
        padding: 20px;
        border: 1px solid #ddd;
        border-radius: 8px;
      }
    </style>
  </head>
  <body>
    <h1>Zalo AI Assistant Status</h1>

    <div id="overall-status">
      <div class="status">
        <div class="status-icon healthy"></div>
        <span>All Systems Operational</span>
      </div>
    </div>

    <div id="services">
      <h2>Services</h2>
      <div id="service-list"></div>
    </div>

    <div id="metrics-section">
      <h2>24-Hour Metrics</h2>
      <div class="metrics" id="metrics"></div>
    </div>

    <script>
      async function loadStatus() {
        try {
          const response = await fetch("/api/health");
          const health = await response.json();

          const metricsResponse = await fetch("/api/dashboard?period=24h");
          const metrics = await metricsResponse.json();

          updateStatus(health, metrics.data);
        } catch (error) {
          console.error("Failed to load status:", error);
          document.getElementById("overall-status").innerHTML =
            '<div class="status"><div class="status-icon unhealthy"></div><span>Status Check Failed</span></div>';
        }
      }

      function updateStatus(health, metrics) {
        // Update overall status
        const overallStatus = document.getElementById("overall-status");
        const statusClass =
          health.status === "healthy"
            ? "healthy"
            : health.status === "degraded"
              ? "degraded"
              : "unhealthy";
        const statusText =
          health.status === "healthy"
            ? "All Systems Operational"
            : health.status === "degraded"
              ? "Some Services Degraded"
              : "Service Issues Detected";

        overallStatus.innerHTML = `
                <div class="status">
                    <div class="status-icon ${statusClass}"></div>
                    <span>${statusText}</span>
                </div>
            `;

        // Update services
        const serviceList = document.getElementById("service-list");
        serviceList.innerHTML = Object.entries(health.checks)
          .map(([name, check]) => {
            const statusClass =
              check.status === "healthy"
                ? "healthy"
                : check.status === "degraded"
                  ? "degraded"
                  : "unhealthy";
            return `
                    <div class="status">
                        <div class="status-icon ${statusClass}"></div>
                        <span>${name.replace("_", " ").toUpperCase()}</span>
                        ${check.responseTime ? `<span style="margin-left: auto;">${check.responseTime}ms</span>` : ""}
                    </div>
                `;
          })
          .join("");

        // Update metrics
        const metricsDiv = document.getElementById("metrics");
        metricsDiv.innerHTML = `
                <div class="metric">
                    <h3>Messages</h3>
                    <div>Total: ${metrics.messages.total}</div>
                    <div>Incoming: ${metrics.messages.incoming}</div>
                    <div>Auto Replies: ${metrics.messages.auto}</div>
                </div>
                <div class="metric">
                    <h3>Performance</h3>
                    <div>Avg Response: ${metrics.performance.avgResponseTime.toFixed(2)}s</div>
                    <div>Errors: ${metrics.performance.errorCount}</div>
                </div>
                <div class="metric">
                    <h3>AI Usage</h3>
                    <div>Responses: ${metrics.ai.responses}</div>
                    <div>Tokens: ${metrics.ai.totalTokens}</div>
                </div>
                <div class="metric">
                    <h3>Users</h3>
                    <div>Active: ${metrics.users.active}</div>
                </div>
            `;
      }

      // Load status on page load
      loadStatus();

      // Refresh every 30 seconds
      setInterval(loadStatus, 30000);
    </script>
  </body>
</html>
```

This comprehensive monitoring and logging strategy provides essential visibility into the Zalo AI Assistant's health and performance while maintaining simplicity and cost-effectiveness for solo developers.

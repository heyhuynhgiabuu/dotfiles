# Zalo AI Assistant - API Specification

## Overview

This document defines the REST API specification for the Zalo AI Assistant. The API follows RESTful principles with JSON payloads and follows KISS design patterns for solo development.

## API Principles

### Design Philosophy

- **RESTful Design**: Standard HTTP methods and status codes
- **JSON Communication**: Simple request/response format
- **Stateless Operations**: No server-side session dependencies
- **Consistent Patterns**: Uniform response structure across endpoints
- **Error Clarity**: Clear error messages with actionable information

### Response Format

All API responses follow a consistent structure:

```json
{
  "success": boolean,
  "data": object | array | null,
  "error": {
    "code": string,
    "message": string,
    "details": object
  } | null,
  "pagination": {
    "page": number,
    "limit": number,
    "total": number,
    "hasNext": boolean,
    "hasPrev": boolean
  } | null
}
```

## Authentication

### JWT Token Authentication

All protected endpoints require a valid JWT token in the Authorization header:

```
Authorization: Bearer <jwt_token>
```

### Token Structure

```json
{
  "sub": "user_id",
  "iat": 1609459200,
  "exp": 1609545600,
  "role": "user",
  "zalo_id": "zalo_user_id"
}
```

## Core API Endpoints

### Authentication Routes

#### POST /api/auth/zalo/redirect

Initiate Zalo OAuth flow.

**Request:**

```json
{
  "redirect_uri": "https://example.com/auth/callback"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "auth_url": "https://oauth.zaloapp.com/v4/permission?..."
  },
  "error": null
}
```

#### POST /api/auth/zalo/callback

Handle Zalo OAuth callback.

**Request:**

```json
{
  "code": "authorization_code",
  "state": "random_state_string"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "token": "jwt_token",
    "expires_in": 3600,
    "user": {
      "id": "user_id",
      "name": "User Name",
      "zalo_id": "zalo_user_id",
      "avatar": "avatar_url"
    }
  },
  "error": null
}
```

#### POST /api/auth/refresh

Refresh JWT token.

**Request:**

```json
{
  "refresh_token": "refresh_token"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "token": "new_jwt_token",
    "expires_in": 3600
  },
  "error": null
}
```

#### POST /api/auth/logout

Invalidate user session.

**Request:** No body required.

**Response:**

```json
{
  "success": true,
  "data": null,
  "error": null
}
```

### User Management Routes

#### GET /api/users/profile

Get current user profile.

**Response:**

```json
{
  "success": true,
  "data": {
    "id": "user_id",
    "name": "User Name",
    "email": "user@example.com",
    "zalo_id": "zalo_user_id",
    "avatar": "avatar_url",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z",
    "settings": {
      "auto_reply": true,
      "business_hours": {
        "start": "09:00",
        "end": "18:00"
      }
    }
  },
  "error": null
}
```

#### PUT /api/users/profile

Update user profile.

**Request:**

```json
{
  "name": "Updated Name",
  "settings": {
    "auto_reply": false,
    "business_hours": {
      "start": "08:00",
      "end": "19:00"
    }
  }
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "id": "user_id",
    "name": "Updated Name",
    "updated_at": "2024-01-01T00:00:00Z"
  },
  "error": null
}
```

### Customer Management Routes

#### GET /api/customers

List customers with pagination and filtering.

**Query Parameters:**

- `page`: Page number (default: 1)
- `limit`: Items per page (default: 20, max: 100)
- `search`: Search term for name/phone
- `status`: Filter by status (active, inactive)
- `sort`: Sort field (name, created_at, last_message)
- `order`: Sort order (asc, desc)

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "id": "customer_id",
      "name": "Customer Name",
      "phone": "+84123456789",
      "zalo_id": "zalo_customer_id",
      "status": "active",
      "last_message": "2024-01-01T12:00:00Z",
      "message_count": 25,
      "created_at": "2024-01-01T00:00:00Z"
    }
  ],
  "error": null,
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "hasNext": true,
    "hasPrev": false
  }
}
```

#### GET /api/customers/:id

Get specific customer details.

**Response:**

```json
{
  "success": true,
  "data": {
    "id": "customer_id",
    "name": "Customer Name",
    "phone": "+84123456789",
    "zalo_id": "zalo_customer_id",
    "status": "active",
    "notes": "Customer notes here",
    "tags": ["vip", "wholesale"],
    "last_message": "2024-01-01T12:00:00Z",
    "message_count": 25,
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  },
  "error": null
}
```

#### PUT /api/customers/:id

Update customer information.

**Request:**

```json
{
  "name": "Updated Customer Name",
  "notes": "Updated notes",
  "tags": ["vip", "premium"],
  "status": "active"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "id": "customer_id",
    "name": "Updated Customer Name",
    "updated_at": "2024-01-01T00:00:00Z"
  },
  "error": null
}
```

### Message Management Routes

#### GET /api/messages

List messages with pagination and filtering.

**Query Parameters:**

- `page`: Page number (default: 1)
- `limit`: Items per page (default: 50, max: 200)
- `customer_id`: Filter by customer
- `type`: Filter by type (incoming, outgoing, auto)
- `date_from`: Start date filter (ISO 8601)
- `date_to`: End date filter (ISO 8601)
- `search`: Search message content

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "id": "message_id",
      "customer_id": "customer_id",
      "type": "incoming",
      "content": "Message content",
      "is_auto_reply": false,
      "status": "delivered",
      "created_at": "2024-01-01T12:00:00Z",
      "customer": {
        "id": "customer_id",
        "name": "Customer Name"
      }
    }
  ],
  "error": null,
  "pagination": {
    "page": 1,
    "limit": 50,
    "total": 500,
    "hasNext": true,
    "hasPrev": false
  }
}
```

#### GET /api/messages/conversation/:customer_id

Get conversation with specific customer.

**Query Parameters:**

- `page`: Page number (default: 1)
- `limit`: Items per page (default: 50)

**Response:**

```json
{
  "success": true,
  "data": {
    "customer": {
      "id": "customer_id",
      "name": "Customer Name",
      "phone": "+84123456789"
    },
    "messages": [
      {
        "id": "message_id",
        "type": "incoming",
        "content": "Hello, I need help",
        "is_auto_reply": false,
        "status": "delivered",
        "created_at": "2024-01-01T12:00:00Z"
      }
    ]
  },
  "error": null,
  "pagination": {
    "page": 1,
    "limit": 50,
    "total": 25,
    "hasNext": false,
    "hasPrev": false
  }
}
```

#### POST /api/messages/send

Send message to customer.

**Request:**

```json
{
  "customer_id": "customer_id",
  "content": "Message content",
  "type": "text"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "id": "message_id",
    "customer_id": "customer_id",
    "content": "Message content",
    "status": "sent",
    "created_at": "2024-01-01T12:00:00Z"
  },
  "error": null
}
```

### Zalo Integration Routes

#### POST /api/zalo/webhook

Handle incoming Zalo webhooks.

**Request (Zalo webhook format):**

```json
{
  "app_id": "zalo_app_id",
  "user_id_by_app": "zalo_user_id",
  "event_name": "user_send_text",
  "timestamp": 1609459200000,
  "message": {
    "text": "User message content",
    "msg_id": "message_id"
  }
}
```

**Response:**

```json
{
  "success": true,
  "data": null,
  "error": null
}
```

#### GET /api/zalo/status

Get Zalo integration status.

**Response:**

```json
{
  "success": true,
  "data": {
    "connected": true,
    "app_id": "zalo_app_id",
    "webhook_verified": true,
    "last_message": "2024-01-01T12:00:00Z",
    "message_count_today": 150
  },
  "error": null
}
```

#### POST /api/zalo/connect

Connect Zalo Official Account.

**Request:**

```json
{
  "app_id": "zalo_app_id",
  "app_secret": "zalo_app_secret"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "connected": true,
    "webhook_url": "https://example.com/api/zalo/webhook"
  },
  "error": null
}
```

### AI Configuration Routes

#### GET /api/ai/settings

Get AI configuration settings.

**Response:**

```json
{
  "success": true,
  "data": {
    "provider": "openai",
    "model": "gpt-3.5-turbo",
    "temperature": 0.7,
    "max_tokens": 150,
    "auto_reply_enabled": true,
    "business_context": "Vietnamese small business",
    "response_style": "polite",
    "custom_prompts": [
      {
        "trigger": "greeting",
        "template": "Xin chào! Cảm ơn bạn đã liên hệ..."
      }
    ]
  },
  "error": null
}
```

#### PUT /api/ai/settings

Update AI configuration.

**Request:**

```json
{
  "provider": "openai",
  "model": "gpt-4",
  "temperature": 0.8,
  "auto_reply_enabled": true,
  "business_context": "Vietnamese restaurant",
  "response_style": "friendly"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "updated_at": "2024-01-01T00:00:00Z"
  },
  "error": null
}
```

### File Management Routes

#### POST /api/files/upload

Upload file (images, documents).

**Request:** Multipart form data

- `file`: File to upload
- `type`: File type (image, document)
- `customer_id`: Associated customer (optional)

**Response:**

```json
{
  "success": true,
  "data": {
    "id": "file_id",
    "filename": "original_filename.jpg",
    "url": "https://r2.example.com/files/file_id.jpg",
    "type": "image",
    "size": 1024000,
    "created_at": "2024-01-01T12:00:00Z"
  },
  "error": null
}
```

#### GET /api/files

List uploaded files.

**Query Parameters:**

- `page`: Page number (default: 1)
- `limit`: Items per page (default: 20)
- `type`: Filter by type
- `customer_id`: Filter by customer

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "id": "file_id",
      "filename": "file.jpg",
      "url": "https://r2.example.com/files/file_id.jpg",
      "type": "image",
      "size": 1024000,
      "customer_id": "customer_id",
      "created_at": "2024-01-01T12:00:00Z"
    }
  ],
  "error": null,
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 50,
    "hasNext": true,
    "hasPrev": false
  }
}
```

### Analytics Routes

#### GET /api/analytics/dashboard

Get dashboard analytics.

**Query Parameters:**

- `period`: Time period (today, week, month, year)
- `date_from`: Custom start date
- `date_to`: Custom end date

**Response:**

```json
{
  "success": true,
  "data": {
    "messages": {
      "total": 1500,
      "incoming": 900,
      "outgoing": 600,
      "auto_replies": 400
    },
    "customers": {
      "total": 150,
      "active": 120,
      "new": 25
    },
    "response_times": {
      "average": 45,
      "median": 30,
      "fastest": 5,
      "slowest": 180
    },
    "top_customers": [
      {
        "customer_id": "customer_id",
        "name": "Customer Name",
        "message_count": 50
      }
    ]
  },
  "error": null
}
```

### Real-time Routes

#### GET /api/events/stream

Server-Sent Events endpoint for real-time updates.

**Response:** Event stream

```
data: {"type": "new_message", "data": {...}}

data: {"type": "customer_status", "data": {...}}

data: {"type": "system_status", "data": {...}}
```

## Error Handling

### Error Response Format

All errors follow a consistent format:

```json
{
  "success": false,
  "data": null,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable error message",
    "details": {
      "field": "validation_error_message"
    }
  }
}
```

### Error Codes

#### Authentication Errors (40x)

- `AUTH_REQUIRED`: Authentication required
- `AUTH_INVALID`: Invalid token
- `AUTH_EXPIRED`: Token expired
- `AUTH_FORBIDDEN`: Insufficient permissions

#### Validation Errors (400)

- `VALIDATION_ERROR`: Request validation failed
- `INVALID_FORMAT`: Invalid data format
- `REQUIRED_FIELD`: Required field missing
- `INVALID_VALUE`: Invalid field value

#### Resource Errors (404, 409)

- `RESOURCE_NOT_FOUND`: Resource not found
- `RESOURCE_EXISTS`: Resource already exists
- `RESOURCE_CONFLICT`: Resource conflict

#### External Service Errors (502, 503)

- `ZALO_API_ERROR`: Zalo API error
- `AI_SERVICE_ERROR`: AI service error
- `STORAGE_ERROR`: File storage error

#### Server Errors (500)

- `INTERNAL_ERROR`: Internal server error
- `DATABASE_ERROR`: Database error
- `CONFIGURATION_ERROR`: Configuration error

### HTTP Status Codes

- `200`: Success
- `201`: Created
- `400`: Bad Request
- `401`: Unauthorized
- `403`: Forbidden
- `404`: Not Found
- `409`: Conflict
- `422`: Unprocessable Entity
- `429`: Too Many Requests
- `500`: Internal Server Error
- `502`: Bad Gateway
- `503`: Service Unavailable

## Rate Limiting

### Rate Limit Headers

All responses include rate limit headers:

```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1609459200
```

### Rate Limits by Endpoint

- **Authentication**: 10 requests/minute
- **Messages**: 100 requests/minute
- **File Upload**: 20 requests/minute
- **General API**: 1000 requests/hour

### Rate Limit Exceeded Response

```json
{
  "success": false,
  "data": null,
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Rate limit exceeded. Try again later.",
    "details": {
      "retry_after": 60
    }
  }
}
```

## Pagination

### Pagination Parameters

- `page`: Page number (starts from 1)
- `limit`: Items per page (default varies by endpoint)

### Pagination Response

```json
{
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "hasNext": true,
    "hasPrev": false
  }
}
```

## Webhooks

### Webhook Verification

All webhooks include verification headers:

```
X-Webhook-Signature: sha256=signature
X-Webhook-Timestamp: 1609459200
```

### Webhook Retry Policy

- **Retry attempts**: 3
- **Retry intervals**: 5s, 30s, 5m
- **Timeout**: 30 seconds
- **Success codes**: 200, 201, 204

## API Versioning

### Version Header

```
API-Version: v1
```

### Backward Compatibility

- Minor changes: Backward compatible
- Major changes: New version endpoint
- Deprecation: 6 month notice period

This API specification provides a complete and KISS-compliant interface for the Zalo AI Assistant, ensuring easy integration and maintenance for solo developers.

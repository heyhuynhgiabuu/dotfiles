# Zalo AI Assistant - System Architecture

## Overview

This document outlines the system architecture for the Zalo AI Assistant, designed with KISS principles for solo development. The architecture emphasizes simplicity, maintainability, and scalability while minimizing complexity.

## Architectural Principles

### Core Principles

- **Simplicity Over Complexity**: Choose the simplest solution that works
- **Clear Separation of Concerns**: Each component has a single responsibility
- **Stateless Where Possible**: Minimize server-side state management
- **Progressive Enhancement**: Start simple, add complexity only when needed
- **Solo Developer Friendly**: Easy to understand, modify, and maintain

### Design Patterns

- **Layered Architecture**: Clear separation between presentation, business logic, and data
- **Repository Pattern**: Abstract data access for easy testing and swapping
- **Service Layer**: Business logic separated from API routes
- **Middleware Pattern**: Cross-cutting concerns handled by middleware

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Cloudflare Pages                         │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐│
│  │   Static Files  │  │   API Routes    │  │   Webhooks      ││
│  │   (HTML/CSS/JS) │  │   (Hono)        │  │   (Hono)        ││
│  └─────────────────┘  └─────────────────┘  └─────────────────┘│
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Cloudflare Services                      │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐│
│  │   Cloudflare    │  │   Cloudflare    │  │   Cloudflare    ││
│  │   R2 (Storage)  │  │   D1 (Database) │  │   Workers       ││
│  └─────────────────┘  └─────────────────┘  └─────────────────┘│
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    External Services                        │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐│
│  │   Zalo API      │  │   AI Provider   │  │   Zalo OAuth    ││
│  └─────────────────┘  └─────────────────┘  └─────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

### Component Architecture

#### 1. Presentation Layer

```
public/
├── index.html          # Main application page
├── dashboard.html      # User dashboard
├── settings.html       # Settings page
├── css/
│   └── style.css       # Application styles
├── js/
│   ├── app.js          # Main application logic
│   ├── auth.js         # Authentication logic
│   └── zalo.js         # Zalo integration
└── assets/             # Images, icons, etc.
```

**Responsibilities:**

- User interface rendering
- Client-side interactions
- Form handling and validation
- Real-time updates via SSE/polling

**Technologies:**

- Plain HTML5 for structure
- Tailwind CSS (CDN) for styling
- Vanilla JavaScript for interactivity
- HTMX for dynamic content updates
- Alpine.js (optional) for reactive UI

#### 2. API Layer

```
src/api/
├── routes/
│   ├── auth.ts         # Authentication routes
│   ├── zalo.ts         # Zalo integration routes
│   ├── messages.ts     # Message management routes
│   ├── customers.ts    # Customer management routes
│   └── files.ts        # File handling routes
├── middleware/
│   ├── auth.ts         # Authentication middleware
│   ├── cors.ts         # CORS middleware
│   ├── rate-limit.ts   # Rate limiting middleware
│   └── error.ts        # Error handling middleware
└── types/
    └── api.ts          # API type definitions
```

**Responsibilities:**

- HTTP request handling
- Request validation
- Response formatting
- Authentication and authorization
- Rate limiting and security

**Technologies:**

- Hono framework for routing
- Zod for request validation
- TypeScript for type safety
- Custom middleware for cross-cutting concerns

#### 3. Service Layer

```
src/services/
├── auth.service.ts     # Authentication business logic
├── zalo.service.ts     # Zalo API integration
├── ai.service.ts       # AI provider integration
├── message.service.ts  # Message processing logic
├── customer.service.ts # Customer management logic
├── file.service.ts     # File handling logic
└── notification.service.ts # Notification handling
```

**Responsibilities:**

- Business logic implementation
- External API integration
- Data transformation
- Error handling and retry logic
- Business rule enforcement

**Technologies:**

- TypeScript for type safety
- Fetch API for HTTP requests
- Custom error classes
- Retry mechanisms with exponential backoff

#### 4. Data Access Layer

```
src/db/
├── connection.ts       # Database connection setup
├── migrations/         # Database migrations
│   ├── 001_initial.ts
│   ├── 002_add_customers.ts
│   └── ...
├── schema/
│   ├── users.ts        # User table schema
│   ├── customers.ts    # Customer table schema
│   ├── messages.ts     # Message table schema
│   └── files.ts        # File table schema
├── repositories/
│   ├── user.repository.ts
│   ├── customer.repository.ts
│   ├── message.repository.ts
│   └── file.repository.ts
└── types/
    └── database.ts     # Database type definitions
```

**Responsibilities:**

- Database connection management
- Data persistence and retrieval
- Schema management and migrations
- Data validation and constraints
- Query optimization

**Technologies:**

- SQLite for local development
- Cloudflare D1 for production
- Drizzle ORM for type-safe queries
- Migration system for schema changes

#### 5. Utility Layer

```
src/utils/
├── crypto.ts          # Cryptographic utilities
├── validation.ts      # Data validation utilities
├── formatting.ts      # Data formatting utilities
├── date.ts            # Date/time utilities
├── logger.ts          # Logging utilities
├── config.ts          # Configuration management
└── errors.ts          # Custom error classes
```

**Responsibilities:**

- Common utility functions
- Data validation and formatting
- Logging and monitoring
- Configuration management
- Error handling utilities

## Data Flow

### 1. User Authentication Flow

```
User → Login Page → Zalo OAuth → JWT Token → Protected Routes
```

**Steps:**

1. User clicks login on the web application
2. Redirect to Zalo OAuth authorization
3. User approves application access
4. Zalo redirects back with authorization code
5. Exchange code for access token and user info
6. Create JWT token for session management
7. Store user session in database
8. Return JWT to client for subsequent requests

### 2. Message Processing Flow

```
Zalo Webhook → API Route → Service Layer → AI Provider → Response → Zalo API
```

**Steps:**

1. Zalo sends message webhook to application
2. API route validates and processes webhook
3. Service layer extracts message content and context
4. AI service generates appropriate response
5. Response is formatted for Vietnamese business etiquette
6. Send response back to Zalo API
7. Store conversation in database for tracking

### 3. Real-time Updates Flow

```
Database Change → Service Layer → SSE Endpoint → Client Browser
```

**Steps:**

1. Database record is created/updated
2. Service layer detects change
3. SSE endpoint pushes update to connected clients
4. Client browser receives update via EventSource
5. UI updates to reflect new information
6. Fallback to polling if SSE fails

### 4. File Upload Flow

```
Client Upload → API Route → Validation → Cloudflare R2 → Database Record
```

**Steps:**

1. Client uploads file via multipart form
2. API route validates file type and size
3. File is uploaded to Cloudflare R2
4. File metadata is stored in database
5. Return file URL and metadata to client
6. Client can now access and use the file

## Security Architecture

### Authentication & Authorization

```
Client Request → JWT Validation → User Lookup → Permission Check → Route Handler
```

**Components:**

- JWT tokens for stateless authentication
- Role-based access control (RBAC)
- Session management with refresh tokens
- Secure password handling with bcrypt

### Data Security

- Encryption at rest (SQLite/Cloudflare D1)
- Encryption in transit (HTTPS/TLS)
- Sensitive data masking in logs
- Secure file storage with Cloudflare R2

### API Security

- Rate limiting per user/IP
- Request validation with Zod
- CORS configuration
- CSRF protection
- Input sanitization

## Performance Architecture

### Caching Strategy

```
Request → Cache Check → Cache Hit → Return Response
                ↓
          Cache Miss → Database Query → Cache Store → Return Response
```

**Cache Layers:**

- In-memory cache for frequently accessed data
- Database query result caching
- Static asset caching via Cloudflare CDN
- API response caching for expensive operations

### Database Optimization

- Connection pooling for SQLite
- Indexed queries for performance
- Query optimization with Drizzle ORM
- Read replicas for scaling (future)

### Frontend Optimization

- Lazy loading of components
- Code splitting for large applications
- Image optimization and lazy loading
- Minification and compression

## Scalability Architecture

### Horizontal Scaling

```
Load Balancer → Cloudflare Pages Instances → Shared Database
```

**Scaling Strategy:**

- Stateless application for easy horizontal scaling
- Database connection pooling
- Read replicas for database scaling
- Queue-based processing for async tasks

### Vertical Scaling

- Memory optimization for Bun.js runtime
- CPU optimization for AI processing
- Storage optimization for file handling
- Network optimization for API calls

## Deployment Architecture

### Development Environment

```
Local Machine → Bun.js Runtime → SQLite Database → Local Testing
```

**Components:**

- Local development with Bun.js
- SQLite database for local development
- Hot reload for rapid development
- Local testing with Bun test

### Production Environment

```
GitHub → Cloudflare Pages → Cloudflare D1 → Cloudflare R2 → Monitoring
```

**Components:**

- Git-based deployment to Cloudflare Pages
- Cloudflare D1 for production database
- Cloudflare R2 for file storage
- Integrated monitoring and logging

### CI/CD Pipeline

```
Git Push → GitHub Actions → Build → Test → Deploy → Monitor
```

**Pipeline Stages:**

1. Code commit and push to GitHub
2. Automated testing with GitHub Actions
3. Build and optimization
4. Deployment to Cloudflare Pages
5. Post-deployment monitoring

## Monitoring & Observability

### Logging Architecture

```
Application → Structured Logging → Cloudflare Logs → Analysis
```

**Logging Components:**

- Structured logging with JSON format
- Log levels (DEBUG, INFO, WARN, ERROR)
- Request/response logging
- Error tracking and alerting

### Monitoring Architecture

```
Application Metrics → Cloudflare Analytics → Dashboard → Alerts
```

**Monitoring Components:**

- Application performance metrics
- Database query performance
- API response times
- Error rates and patterns

### Error Handling

```
Error → Capture → Log → Alert → Notify → Resolve
```

**Error Handling Strategy:**

- Graceful error handling with try/catch
- Error logging and tracking
- User-friendly error messages
- Automatic retry for transient errors

## Disaster Recovery

### Backup Strategy

- Automated database backups
- File storage replication
- Configuration versioning
- Regular backup testing

### Recovery Strategy

- Automated deployment rollback
- Database restore procedures
- File recovery from backups
- Incident response procedures

## Future Enhancements

### Phase 1: MVP (Current)

- Basic Zalo integration
- Simple AI responses
- SQLite database
- Plain frontend

### Phase 2: Enhanced

- Cloudflare D1 database
- Advanced AI features
- HTMX for better UX
- File upload capabilities

### Phase 3: Advanced

- Multi-tenant architecture
- Advanced analytics
- Mobile app support
- Enterprise features

This architecture provides a solid foundation for the Zalo AI Assistant while maintaining KISS principles and ensuring solo developer productivity.

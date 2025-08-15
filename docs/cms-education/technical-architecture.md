# CMS Education Platform - Technical Architecture Guide

## Architecture Documentation Structure

This technical architecture is organized into **phase-specific documents** to support rapid MVP development with clear evolution paths.

### 📋 **Start Here: MVP Architecture (Weeks 1-6)**
**File**: [mvp-architecture.md](mvp-architecture.md)

**Purpose**: Simple, fast-to-implement architecture for 6-week MVP delivery  
**Pattern**: Simplified Spring Boot monolith  
**Focus**: Core booking + payment flow with minimal complexity

**Key Features**:
- 6 essential database tables
- Simple layered Spring Boot structure
- Stripe Checkout integration
- Basic HTMX for interactivity
- Traditional repository pattern

**When to Use**: Starting development, first 6 weeks of implementation

---

### 🚀 **Advanced Architecture (Phases 2-4)**
**File**: [advanced-architecture.md](advanced-architecture.md)

**Purpose**: Full Domain-Driven Design architecture for complex business logic  
**Pattern**: DDD with bounded contexts, aggregates, and domain events  
**Focus**: Scalable, maintainable architecture for long-term growth

**Key Features**:
- Bounded context design
- Aggregate roots and domain events
- CQRS pattern for complex queries
- Advanced repository patterns
- Event-driven architecture

**When to Use**: After MVP success, when complexity justifies sophisticated patterns

---

## Technology Stack Evolution

### MVP Stack (Simple & Fast)
```
Frontend:  Thymeleaf + Bootstrap + Basic HTMX
Backend:   Spring Boot + Traditional Layers
Database:  MySQL + Simple JDBC
Payments:  Stripe Checkout (hosted)
Deploy:    Single Docker container
```

### Advanced Stack (Scalable & Sophisticated)
```
Frontend:  Thymeleaf + Bootstrap + Advanced HTMX + Alpine.js
Backend:   Spring Boot + DDD + Domain Events + CQRS
Database:  MySQL + Advanced JDBC + Read Models
Payments:  Stripe API + Webhook handling
Deploy:    Microservices consideration + Event store
```

## Implementation Strategy

### Phase 1: MVP Foundation (Weeks 1-6)
**Architecture**: Use [MVP Architecture](mvp-architecture.md)
- Simple Spring Boot layers
- 6 core database tables
- Basic authentication and session booking
- Stripe payment integration

### Phase 2: Enhanced Features (Weeks 7-10) 
**Architecture**: Gradual migration to [Advanced Architecture](advanced-architecture.md)
- Introduce value objects and domain events
- Add homework and multi-child support
- Implement basic CQRS patterns

### Phase 3: Complex Business Logic (Weeks 11-14)
**Architecture**: Full [Advanced Architecture](advanced-architecture.md)
- Complete bounded context implementation
- Advanced domain modeling
- Event-driven processing

### Phase 4: Scale & Optimize (Weeks 15+)
**Architecture**: Enhanced [Advanced Architecture](advanced-architecture.md)
- Microservices consideration
- Advanced event sourcing
- Performance optimization

## Migration Path: MVP → Advanced

### Step 1: Extract Value Objects
```java
// Before (MVP)
public class Session {
    private BigDecimal amount;
    private String currency;
    private LocalDateTime scheduledAt;
    private Integer durationMinutes;
}

// After (Advanced)
public class Session extends AggregateRoot<SessionId> {
    private Money fee;
    private SessionSchedule schedule;
    private List<DomainEvent> domainEvents;
}
```

### Step 2: Introduce Domain Events
```java
// Add to existing Session class
public void complete(SessionNotes notes) {
    this.status = SessionStatus.COMPLETED;
    this.notes = notes;
    
    // New: Domain event
    addDomainEvent(new SessionCompletedEvent(this.id, this.fee));
}
```

### Step 3: Implement CQRS
```java
// Separate command and query responsibilities
@Service
public class SessionApplicationService {
    // Commands only
    public SessionId bookSession(BookSessionCommand command) { ... }
}

@Service  
public class SessionQueryService {
    // Queries only
    public List<SessionProjection> findUpcomingSessions(...) { ... }
}
```

## Decision Framework: Which Architecture to Use?

### Use MVP Architecture When:
- ✅ Building initial MVP (first 6 weeks)
- ✅ Team has basic Spring Boot experience
- ✅ Simple business requirements
- ✅ Need to get to market quickly
- ✅ Limited complexity in business rules

### Use Advanced Architecture When:
- ✅ MVP is successful and needs scaling
- ✅ Complex business rules emerge
- ✅ Multiple bounded contexts identified
- ✅ Team has DDD experience
- ✅ Long-term maintainability is priority

## Quick Reference

### MVP Development
1. **Start**: [MVP Architecture](mvp-architecture.md)
2. **Database**: 6 simple tables
3. **Pattern**: Traditional Spring Boot layers
4. **Timeline**: 6 weeks to market

### Advanced Development  
1. **Evolve**: [Advanced Architecture](advanced-architecture.md)
2. **Database**: Normalized with event store
3. **Pattern**: DDD with bounded contexts
4. **Timeline**: Post-MVP enhancement

### Migration Support
- **Gradual Evolution**: No big-bang rewrites
- **Backward Compatibility**: MVP code can coexist
- **Risk Mitigation**: Test advanced patterns in isolation
- **Team Learning**: Gradual introduction of DDD concepts

Choose the appropriate architecture document based on your current phase and complexity needs.
# CMS Education Platform - Advanced DDD Architecture

## Overview

**Purpose**: Advanced Domain-Driven Design architecture for Phases 2-4  
**When to Use**: After MVP success, when complexity justifies sophisticated patterns  
**Evolution**: Gradual migration from simple MVP architecture to full DDD

## Domain-Driven Design Architecture

### 1. Bounded Context Design

#### Core Domains (Phase 2+)
```
┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────────┐
│   User Management   │  │  Session Management │  │  Payment Management │
│                     │  │                     │  │                     │
│ • Authentication    │  │ • Booking           │  │ • Stripe Integration│
│ • Authorization     │  │ • Scheduling        │  │ • Commission Split  │
│ • Profile Mgmt      │  │ • Progress Tracking │  │ • Financial Reports │
└─────────────────────┘  └─────────────────────┘  └─────────────────────┘

┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────────┐
│   Tutor Management  │  │  Academic Management│  │ Notification System │
│                     │  │                     │  │                     │
│ • Verification      │  │ • Subjects & Levels │  │ • Email/SMS         │
│ • Qualifications    │  │ • Homework System   │  │ • In-App Messages   │
│ • Performance       │  │ • Progress Reports  │  │ • Automated Alerts  │
└─────────────────────┘  └─────────────────────┘  └─────────────────────┘
```

### 2. Advanced Package Structure (DDD)

```
src/main/java/uk/co/cms/education/
├── CmsEducationApplication.java
├── shared/
│   ├── domain/
│   │   ├── AggregateRoot.java
│   │   ├── DomainEvent.java
│   │   ├── Entity.java
│   │   └── ValueObject.java
│   ├── infrastructure/
│   │   ├── EventPublisher.java
│   │   └── TransactionalEventListener.java
│   └── application/
│       ├── ApplicationService.java
│       └── CommandHandler.java
├── user/
│   ├── domain/
│   │   ├── model/
│   │   │   ├── User.java              # Aggregate Root
│   │   │   ├── UserProfile.java       # Entity
│   │   │   ├── Email.java             # Value Object
│   │   │   ├── UserId.java            # Value Object
│   │   │   └── UserRole.java          # Value Object
│   │   ├── repository/
│   │   │   └── UserRepository.java
│   │   ├── service/
│   │   │   └── UserDomainService.java
│   │   └── event/
│   │       ├── UserRegisteredEvent.java
│   │       └── UserProfileUpdatedEvent.java
│   ├── application/
│   │   ├── UserApplicationService.java
│   │   ├── command/
│   │   │   ├── RegisterUserCommand.java
│   │   │   └── UpdateUserProfileCommand.java
│   │   ├── query/
│   │   │   ├── UserQueryService.java
│   │   │   └── UserProjection.java
│   │   └── handler/
│   │       ├── RegisterUserCommandHandler.java
│   │       └── UpdateUserProfileCommandHandler.java
│   └── infrastructure/
│       ├── persistence/
│       │   ├── UserRepositoryImpl.java
│       │   ├── UserJdbcAdapter.java
│       │   └── UserRowMapper.java
│       └── web/
│           ├── UserController.java
│           └── UserRestController.java
├── session/
│   ├── domain/
│   │   ├── model/
│   │   │   ├── Session.java           # Aggregate Root
│   │   │   ├── SessionId.java         # Value Object
│   │   │   ├── SessionStatus.java     # Value Object
│   │   │   ├── SessionSchedule.java   # Value Object
│   │   │   └── SessionNotes.java      # Value Object
│   │   ├── repository/
│   │   │   └── SessionRepository.java
│   │   ├── service/
│   │   │   ├── SessionDomainService.java
│   │   │   └── AvailabilityService.java
│   │   └── event/
│   │       ├── SessionBookedEvent.java
│   │       ├── SessionCompletedEvent.java
│   │       └── SessionCancelledEvent.java
│   ├── application/
│   │   ├── SessionApplicationService.java
│   │   ├── command/
│   │   │   ├── BookSessionCommand.java
│   │   │   ├── CompleteSessionCommand.java
│   │   │   └── CancelSessionCommand.java
│   │   ├── query/
│   │   │   ├── SessionQueryService.java
│   │   │   └── SessionProjection.java
│   │   └── handler/
│   │       ├── BookSessionCommandHandler.java
│   │       └── CompleteSessionCommandHandler.java
│   └── infrastructure/
│       ├── persistence/
│       │   ├── SessionRepositoryImpl.java
│       │   └── SessionJdbcAdapter.java
│       └── web/
│           └── SessionController.java
├── payment/
│   ├── domain/
│   │   ├── model/
│   │   │   ├── Payment.java           # Aggregate Root
│   │   │   ├── PaymentId.java         # Value Object
│   │   │   ├── Money.java             # Value Object
│   │   │   ├── PaymentStatus.java     # Value Object
│   │   │   └── Commission.java        # Value Object
│   │   ├── repository/
│   │   │   └── PaymentRepository.java
│   │   ├── service/
│   │   │   ├── PaymentDomainService.java
│   │   │   └── CommissionCalculationService.java
│   │   └── event/
│   │       ├── PaymentProcessedEvent.java
│   │       └── PaymentFailedEvent.java
│   ├── application/
│   │   ├── PaymentApplicationService.java
│   │   ├── command/
│   │   │   ├── ProcessPaymentCommand.java
│   │   │   └── RefundPaymentCommand.java
│   │   ├── query/
│   │   │   └── PaymentQueryService.java
│   │   └── handler/
│   │       └── ProcessPaymentCommandHandler.java
│   └── infrastructure/
│       ├── persistence/
│       │   └── PaymentRepositoryImpl.java
│       ├── stripe/
│       │   ├── StripePaymentGateway.java
│       │   └── StripeWebhookHandler.java
│       └── web/
│           └── PaymentController.java
└── tutor/
    ├── domain/
    │   ├── model/
    │   │   ├── Tutor.java             # Aggregate Root
    │   │   ├── TutorId.java           # Value Object
    │   │   ├── Qualification.java     # Entity
    │   │   ├── SubjectExpertise.java  # Value Object
    │   │   ├── TutorAvailability.java # Value Object
    │   │   └── VerificationStatus.java # Value Object
    │   ├── repository/
    │   │   └── TutorRepository.java
    │   ├── service/
    │   │   ├── TutorDomainService.java
    │   │   └── QualificationVerificationService.java
    │   └── event/
    │       ├── TutorVerifiedEvent.java
    │       └── QualificationAddedEvent.java
    ├── application/
    │   ├── TutorApplicationService.java
    │   ├── command/
    │   │   ├── VerifyTutorCommand.java
    │   │   └── AddQualificationCommand.java
    │   ├── query/
    │   │   └── TutorQueryService.java
    │   └── handler/
    │       └── VerifyTutorCommandHandler.java
    └── infrastructure/
        ├── persistence/
        │   └── TutorRepositoryImpl.java
        └── web/
            └── TutorController.java
```

### 3. Advanced Domain Models

#### Session Aggregate (Full DDD)
```java
@Entity
public class Session extends AggregateRoot<SessionId> {
    private SessionId id;
    private StudentId studentId;
    private TutorId tutorId;
    private SubjectId subjectId;
    private SessionSchedule schedule;
    private SessionStatus status;
    private Money fee;
    private SessionNotes notes;
    private List<DomainEvent> domainEvents;
    
    // Factory method
    public static Session book(StudentId studentId, TutorId tutorId, 
                              SubjectId subjectId, SessionSchedule schedule,
                              Money fee) {
        Session session = new Session();
        session.id = SessionId.generate();
        session.studentId = studentId;
        session.tutorId = tutorId;
        session.subjectId = subjectId;
        session.schedule = schedule;
        session.status = SessionStatus.PENDING;
        session.fee = fee;
        session.notes = SessionNotes.empty();
        
        // Domain event
        session.addDomainEvent(new SessionBookedEvent(session.id, studentId, tutorId, schedule));
        
        return session;
    }
    
    // Business methods
    public void confirm() {
        if (!canBeConfirmed()) {
            throw new IllegalSessionStatusException("Session cannot be confirmed");
        }
        
        this.status = SessionStatus.CONFIRMED;
        addDomainEvent(new SessionConfirmedEvent(this.id));
    }
    
    public void complete(SessionNotes notes) {
        if (!canBeCompleted()) {
            throw new IllegalSessionStatusException("Session cannot be completed");
        }
        
        this.status = SessionStatus.COMPLETED;
        this.notes = notes;
        addDomainEvent(new SessionCompletedEvent(this.id, this.fee));
    }
    
    public void cancel(CancellationReason reason) {
        if (!canBeCancelled()) {
            throw new IllegalSessionStatusException("Session cannot be cancelled");
        }
        
        this.status = SessionStatus.CANCELLED;
        addDomainEvent(new SessionCancelledEvent(this.id, reason));
    }
    
    // Domain rules
    private boolean canBeConfirmed() {
        return status == SessionStatus.PENDING && 
               schedule.isInFuture();
    }
    
    private boolean canBeCompleted() {
        return status == SessionStatus.CONFIRMED && 
               schedule.hasStarted();
    }
    
    private boolean canBeCancelled() {
        return status == SessionStatus.PENDING || 
               status == SessionStatus.CONFIRMED;
    }
}

// Value Objects
@Embeddable
public class SessionSchedule extends ValueObject {
    private LocalDateTime scheduledAt;
    private Duration duration;
    
    public SessionSchedule(LocalDateTime scheduledAt, Duration duration) {
        this.scheduledAt = requireNonNull(scheduledAt);
        this.duration = requireNonNull(duration);
        
        if (scheduledAt.isBefore(LocalDateTime.now())) {
            throw new IllegalArgumentException("Session cannot be scheduled in the past");
        }
        
        if (duration.toMinutes() < 30 || duration.toMinutes() > 180) {
            throw new IllegalArgumentException("Session duration must be between 30 and 180 minutes");
        }
    }
    
    public boolean isInFuture() {
        return scheduledAt.isAfter(LocalDateTime.now());
    }
    
    public boolean hasStarted() {
        return LocalDateTime.now().isAfter(scheduledAt);
    }
    
    public LocalDateTime getEndTime() {
        return scheduledAt.plus(duration);
    }
    
    // Value object equality
    @Override
    protected List<Object> getEqualityComponents() {
        return List.of(scheduledAt, duration);
    }
}

@Embeddable
public class Money extends ValueObject {
    private BigDecimal amount;
    private Currency currency;
    
    public Money(BigDecimal amount, Currency currency) {
        this.amount = requireNonNull(amount);
        this.currency = requireNonNull(currency);
        
        if (amount.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Money amount cannot be negative");
        }
    }
    
    public static Money gbp(BigDecimal amount) {
        return new Money(amount, Currency.getInstance("GBP"));
    }
    
    public Money multiply(BigDecimal multiplier) {
        return new Money(amount.multiply(multiplier), currency);
    }
    
    public Money add(Money other) {
        if (!currency.equals(other.currency)) {
            throw new IllegalArgumentException("Cannot add money with different currencies");
        }
        return new Money(amount.add(other.amount), currency);
    }
    
    @Override
    protected List<Object> getEqualityComponents() {
        return List.of(amount, currency);
    }
}
```

#### Advanced Repository Pattern with CQRS
```java
// Command side repository
public interface SessionRepository extends Repository<Session, SessionId> {
    void save(Session session);
    Optional<Session> findById(SessionId id);
    List<Session> findByTutorId(TutorId tutorId);
    List<Session> findConflictingSessions(TutorId tutorId, SessionSchedule schedule);
}

// Query side service
@Service
@Transactional(readOnly = true)
public class SessionQueryService {
    
    private final JdbcTemplate jdbcTemplate;
    
    public List<SessionProjection> findUpcomingSessions(UserId userId, UserRole role) {
        String sql = switch (role) {
            case TUTOR -> """
                SELECT s.id, s.scheduled_at, s.duration_minutes, s.status,
                       st.first_name || ' ' || st.last_name as student_name,
                       sub.name as subject_name, sub.level as subject_level
                FROM sessions s
                JOIN students st ON s.student_id = st.id
                JOIN subjects sub ON s.subject_id = sub.id
                JOIN tutors t ON s.tutor_id = t.id
                WHERE t.user_id = ? AND s.scheduled_at > NOW()
                ORDER BY s.scheduled_at
                """;
            case CLIENT -> """
                SELECT s.id, s.scheduled_at, s.duration_minutes, s.status,
                       u.first_name || ' ' || u.last_name as tutor_name,
                       sub.name as subject_name, sub.level as subject_level
                FROM sessions s
                JOIN tutors t ON s.tutor_id = t.id
                JOIN users u ON t.user_id = u.id
                JOIN subjects sub ON s.subject_id = sub.id
                JOIN students st ON s.student_id = st.id
                WHERE st.parent_user_id = ? AND s.scheduled_at > NOW()
                ORDER BY s.scheduled_at
                """;
            default -> throw new IllegalArgumentException("Invalid role for session query");
        };
        
        return jdbcTemplate.query(sql, sessionProjectionRowMapper, userId.getValue());
    }
    
    public SessionAnalyticsProjection getSessionAnalytics(TutorId tutorId) {
        String sql = """
            SELECT 
                COUNT(*) as total_sessions,
                COUNT(CASE WHEN status = 'COMPLETED' THEN 1 END) as completed_sessions,
                AVG(CASE WHEN status = 'COMPLETED' THEN s.hourly_rate * (s.duration_minutes / 60.0) END) as avg_earnings_per_session,
                SUM(CASE WHEN status = 'COMPLETED' THEN s.hourly_rate * (s.duration_minutes / 60.0) END) as total_earnings
            FROM sessions s
            WHERE s.tutor_id = ? AND s.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
            """;
            
        return jdbcTemplate.queryForObject(sql, sessionAnalyticsRowMapper, tutorId.getValue());
    }
}
```

### 4. Domain Events & Event Handling

```java
// Domain Event
public class SessionCompletedEvent extends DomainEvent {
    private final SessionId sessionId;
    private final Money sessionFee;
    private final LocalDateTime completedAt;
    
    public SessionCompletedEvent(SessionId sessionId, Money sessionFee) {
        super();
        this.sessionId = sessionId;
        this.sessionFee = sessionFee;
        this.completedAt = LocalDateTime.now();
    }
    
    // Getters...
}

// Event Handler
@Component
public class SessionEventHandler {
    
    private final PaymentApplicationService paymentService;
    private final NotificationService notificationService;
    
    @EventListener
    @Async
    public void handleSessionCompleted(SessionCompletedEvent event) {
        // Trigger payment processing
        ProcessPaymentCommand paymentCommand = new ProcessPaymentCommand(
            event.getSessionId(),
            event.getSessionFee()
        );
        paymentService.processPayment(paymentCommand);
    }
    
    @EventListener
    @Async
    public void handleSessionBooked(SessionBookedEvent event) {
        // Send notifications
        notificationService.sendBookingConfirmation(
            event.getSessionId(),
            event.getStudentId(),
            event.getTutorId()
        );
    }
    
    @EventListener
    @Async
    public void handleSessionCancelled(SessionCancelledEvent event) {
        // Handle refunds if applicable
        if (event.getCancellationReason().requiresRefund()) {
            RefundPaymentCommand refundCommand = new RefundPaymentCommand(
                event.getSessionId(),
                event.getCancellationReason()
            );
            paymentService.processRefund(refundCommand);
        }
    }
}
```

### 5. Advanced Application Services with CQRS

```java
@Service
@Transactional
public class SessionApplicationService {
    
    private final SessionRepository sessionRepository;
    private final TutorRepository tutorRepository;
    private final StudentRepository studentRepository;
    private final DomainEventPublisher eventPublisher;
    
    public SessionId bookSession(BookSessionCommand command) {
        // Load aggregates
        Student student = studentRepository.findById(command.getStudentId())
            .orElseThrow(() -> new StudentNotFoundException(command.getStudentId()));
            
        Tutor tutor = tutorRepository.findById(command.getTutorId())
            .orElseThrow(() -> new TutorNotFoundException(command.getTutorId()));
        
        // Business rules validation
        if (!tutor.isAvailableFor(command.getSchedule())) {
            throw new TutorNotAvailableException("Tutor is not available at the requested time");
        }
        
        if (!tutor.canTeach(command.getSubjectId())) {
            throw new TutorSubjectMismatchException("Tutor cannot teach the requested subject");
        }
        
        // Check for conflicts
        List<Session> conflictingSessions = sessionRepository.findConflictingSessions(
            command.getTutorId(), command.getSchedule()
        );
        
        if (!conflictingSessions.isEmpty()) {
            throw new SessionConflictException("Session conflicts with existing bookings");
        }
        
        // Create session
        Money sessionFee = tutor.calculateFeeFor(command.getSubjectId(), command.getSchedule().getDuration());
        
        Session session = Session.book(
            command.getStudentId(),
            command.getTutorId(),
            command.getSubjectId(),
            command.getSchedule(),
            sessionFee
        );
        
        // Save and publish events
        sessionRepository.save(session);
        eventPublisher.publishAll(session.getDomainEvents());
        
        return session.getId();
    }
    
    public void completeSession(CompleteSessionCommand command) {
        Session session = sessionRepository.findById(command.getSessionId())
            .orElseThrow(() -> new SessionNotFoundException(command.getSessionId()));
        
        // Business rule: Only tutor can complete their own session
        if (!session.getTutorId().equals(command.getTutorId())) {
            throw new UnauthorizedSessionAccessException("Only the assigned tutor can complete this session");
        }
        
        session.complete(command.getSessionNotes());
        
        sessionRepository.save(session);
        eventPublisher.publishAll(session.getDomainEvents());
    }
}
```

## Migration Strategy (MVP → DDD)

### Phase 2: Introduce Basic DDD Concepts
1. **Extract Value Objects**: Email, Money, SessionSchedule
2. **Add Domain Events**: SessionBooked, SessionCompleted
3. **Implement Repository Interfaces**: Separate from implementation
4. **Add Domain Services**: For complex business rules

### Phase 3: Full DDD Implementation
1. **Aggregate Boundaries**: Proper aggregate design
2. **CQRS**: Separate command and query models
3. **Event Sourcing**: For audit trail and complex business rules
4. **Domain Event Handlers**: Async processing of business events

### Phase 4: Advanced Patterns
1. **Saga Pattern**: For complex multi-step processes
2. **Specification Pattern**: For complex business rules
3. **Domain Event Store**: Persistent event store
4. **Read Models**: Optimized projections for queries

This advanced architecture provides the foundation for a scalable, maintainable platform while preserving the business rules and invariants in the domain layer.
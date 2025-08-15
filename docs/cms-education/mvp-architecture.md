# CMS Education Platform - MVP Technical Architecture

## Overview

**Goal**: Simple, fast-to-implement architecture for 6-week MVP delivery  
**Pattern**: Simplified monolith with clear evolution path to DDD  
**Focus**: Get core booking + payment flow working quickly and reliably

## Technology Stack (MVP)

- **Framework**: Spring Boot 3.x
- **Frontend**: Thymeleaf + Bootstrap 5 + minimal HTMX
- **Database**: MySQL 8.x with JDBC (simplified queries)
- **Payments**: Stripe Checkout (hosted)
- **Deployment**: Single Docker container
- **Architecture**: Simple layered monolith

## Simplified Architecture Layers

### 1. MVP Package Structure (Simplified)

```
src/main/java/uk/co/cms/education/
├── CmsEducationApplication.java
├── config/
│   ├── DatabaseConfig.java
│   ├── SecurityConfig.java
│   └── StripeConfig.java
├── controller/
│   ├── AdminController.java
│   ├── TutorController.java
│   ├── ClientController.java
│   └── AuthController.java
├── model/
│   ├── User.java
│   ├── Student.java
│   ├── Tutor.java
│   ├── Subject.java
│   ├── Session.java
│   └── Payment.java
├── repository/
│   ├── UserRepository.java
│   ├── StudentRepository.java
│   ├── TutorRepository.java
│   ├── SubjectRepository.java
│   ├── SessionRepository.java
│   └── PaymentRepository.java
├── service/
│   ├── UserService.java
│   ├── SessionService.java
│   ├── PaymentService.java
│   └── NotificationService.java
└── dto/
    ├── SessionBookingRequest.java
    ├── PaymentRequest.java
    └── UserRegistrationRequest.java
```

**Why Simplified?**
- No complex DDD layers for MVP
- Traditional Spring Boot structure for fast development
- Clear separation of concerns without over-engineering
- Easy for any Spring developer to understand

### 2. MVP Database Schema (6 Essential Tables)

```sql
-- Core MVP Tables Only
CREATE DATABASE cms_education_mvp;

-- Users (all 3 roles in one table)
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('ADMIN', 'CLIENT', 'TUTOR') NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    status ENUM('ACTIVE', 'PENDING') NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Students (simplified)
CREATE TABLE students (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    parent_user_id BIGINT NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    academic_level ENUM('GCSE', 'A_LEVEL') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_user_id) REFERENCES users(id)
);

-- Tutors (simplified)
CREATE TABLE tutors (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    bio TEXT,
    hourly_rate DECIMAL(10,2) NOT NULL,
    verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    UNIQUE KEY uk_tutor_user (user_id)
);

-- Subjects (6 combinations only)
CREATE TABLE subjects (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name ENUM('MATHEMATICS', 'ENGLISH', 'SCIENCE') NOT NULL,
    level ENUM('GCSE', 'A_LEVEL') NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE KEY uk_subject_level (name, level)
);

-- Sessions (core business entity)
CREATE TABLE sessions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    student_id BIGINT NOT NULL,
    tutor_id BIGINT NOT NULL,
    subject_id BIGINT NOT NULL,
    scheduled_at DATETIME NOT NULL,
    duration_minutes INT NOT NULL DEFAULT 60,
    status ENUM('PENDING', 'CONFIRMED', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'PENDING',
    hourly_rate DECIMAL(10,2) NOT NULL,
    session_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (tutor_id) REFERENCES tutors(id),
    FOREIGN KEY (subject_id) REFERENCES subjects(id)
);

-- Payments (Stripe integration)
CREATE TABLE payments (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    session_id BIGINT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    stripe_payment_intent_id VARCHAR(100) NOT NULL,
    status ENUM('PENDING', 'COMPLETED', 'FAILED', 'REFUNDED') NOT NULL,
    tutor_amount DECIMAL(10,2) NOT NULL, -- 80% of total
    platform_fee DECIMAL(10,2) NOT NULL, -- 20% of total
    paid_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES sessions(id),
    UNIQUE KEY uk_payment_session (session_id)
);

-- Initial data for MVP
INSERT INTO subjects (name, level) VALUES 
('MATHEMATICS', 'GCSE'), ('MATHEMATICS', 'A_LEVEL'),
('ENGLISH', 'GCSE'), ('ENGLISH', 'A_LEVEL'),
('SCIENCE', 'GCSE'), ('SCIENCE', 'A_LEVEL');
```

**MVP Schema Benefits**:
- Only 6 tables for complete functionality
- Denormalized for simplicity (can normalize later)
- All essential relationships covered
- Ready for immediate development

### 3. Simplified Domain Models

```java
// Simple JPA-style entities for MVP
@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true, nullable = false)
    private String email;
    
    private String passwordHash;
    
    @Enumerated(EnumType.STRING)
    private UserRole role;
    
    private String firstName;
    private String lastName;
    private String phone;
    
    @Enumerated(EnumType.STRING)
    private UserStatus status;
    
    private LocalDateTime createdAt;
    
    // Standard getters/setters
}

@Entity
@Table(name = "sessions")
public class Session {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private Long studentId;
    private Long tutorId;
    private Long subjectId;
    
    private LocalDateTime scheduledAt;
    private Integer durationMinutes;
    
    @Enumerated(EnumType.STRING)
    private SessionStatus status;
    
    private BigDecimal hourlyRate;
    private String sessionNotes;
    
    private LocalDateTime createdAt;
    
    // Standard getters/setters
    // Helper methods for business logic
    public BigDecimal calculateTotalAmount() {
        return hourlyRate.multiply(BigDecimal.valueOf(durationMinutes / 60.0));
    }
    
    public boolean canBeCompleted() {
        return status == SessionStatus.CONFIRMED && 
               scheduledAt.isBefore(LocalDateTime.now());
    }
}
```

### 4. MVP Service Layer Pattern

```java
@Service
@Transactional
public class SessionService {
    
    private final SessionRepository sessionRepository;
    private final PaymentService paymentService;
    private final NotificationService notificationService;
    
    // Simple booking flow
    public Session bookSession(SessionBookingRequest request) {
        // Validate tutor availability
        if (!isTutorAvailable(request.getTutorId(), request.getScheduledAt())) {
            throw new TutorNotAvailableException("Tutor not available at this time");
        }
        
        // Create session
        Session session = new Session();
        session.setStudentId(request.getStudentId());
        session.setTutorId(request.getTutorId());
        session.setSubjectId(request.getSubjectId());
        session.setScheduledAt(request.getScheduledAt());
        session.setDurationMinutes(60); // Fixed for MVP
        session.setStatus(SessionStatus.PENDING);
        session.setHourlyRate(getTutorRate(request.getTutorId(), request.getSubjectId()));
        
        Session savedSession = sessionRepository.save(session);
        
        // Send confirmation emails
        notificationService.sendBookingConfirmation(savedSession);
        
        return savedSession;
    }
    
    // Complete session and trigger payment
    public void completeSession(Long sessionId, String sessionNotes) {
        Session session = sessionRepository.findById(sessionId)
            .orElseThrow(() -> new SessionNotFoundException("Session not found"));
            
        if (!session.canBeCompleted()) {
            throw new IllegalStateException("Session cannot be completed");
        }
        
        session.setStatus(SessionStatus.COMPLETED);
        session.setSessionNotes(sessionNotes);
        sessionRepository.save(session);
        
        // Trigger payment
        paymentService.processSessionPayment(session);
        
        // Send completion notifications
        notificationService.sendSessionCompletionNotification(session);
    }
}
```

### 5. Stripe Payment Integration (MVP)

```java
@Service
public class PaymentService {
    
    private final StripeClient stripeClient;
    private final PaymentRepository paymentRepository;
    
    @Value("${stripe.webhook.secret}")
    private String webhookSecret;
    
    public String createPaymentIntent(Session session) {
        BigDecimal amount = session.calculateTotalAmount();
        
        PaymentIntentCreateParams params = PaymentIntentCreateParams.builder()
            .setAmount(amount.multiply(BigDecimal.valueOf(100)).longValue()) // Convert to pence
            .setCurrency("gbp")
            .setDescription("Tutoring session: " + session.getId())
            .putMetadata("session_id", session.getId().toString())
            .build();
            
        try {
            PaymentIntent intent = PaymentIntent.create(params);
            
            // Create payment record
            Payment payment = new Payment();
            payment.setSessionId(session.getId());
            payment.setAmount(amount);
            payment.setStripePaymentIntentId(intent.getId());
            payment.setStatus(PaymentStatus.PENDING);
            payment.setTutorAmount(amount.multiply(BigDecimal.valueOf(0.8))); // 80%
            payment.setPlatformFee(amount.multiply(BigDecimal.valueOf(0.2))); // 20%
            
            paymentRepository.save(payment);
            
            return intent.getClientSecret();
        } catch (StripeException e) {
            throw new PaymentProcessingException("Failed to create payment intent", e);
        }
    }
    
    // Webhook handler for payment confirmation
    public void handlePaymentWebhook(String payload, String signature) {
        Event event = Webhook.constructEvent(payload, signature, webhookSecret);
        
        if ("payment_intent.succeeded".equals(event.getType())) {
            PaymentIntent paymentIntent = (PaymentIntent) event.getDataObjectDeserializer()
                .getObject().orElse(null);
                
            if (paymentIntent != null) {
                updatePaymentStatus(paymentIntent.getId(), PaymentStatus.COMPLETED);
            }
        }
    }
}
```

### 6. Simple HTMX Frontend Integration

```html
<!-- Session booking form -->
<form hx-post="/client/sessions/book" 
      hx-target="#booking-result"
      hx-indicator="#booking-spinner">
    
    <select name="tutorId" class="form-select" required>
        <option value="">Select Tutor</option>
        <option th:each="tutor : ${availableTutors}" 
                th:value="${tutor.id}" 
                th:text="${tutor.name + ' - £' + tutor.hourlyRate + '/hour'}">
        </option>
    </select>
    
    <input type="datetime-local" name="scheduledAt" class="form-control" required>
    
    <button type="submit" class="btn btn-primary">
        Book Session
        <span id="booking-spinner" class="spinner-border spinner-border-sm d-none"></span>
    </button>
</form>

<div id="booking-result"></div>
```

```java
@PostMapping("/sessions/book")
public String bookSession(@ModelAttribute SessionBookingRequest request, Model model) {
    try {
        Session session = sessionService.bookSession(request);
        
        // Redirect to Stripe Checkout
        String paymentUrl = createStripeCheckoutSession(session);
        model.addAttribute("redirectUrl", paymentUrl);
        
        return "fragments/booking-success :: success";
    } catch (Exception e) {
        model.addAttribute("error", e.getMessage());
        return "fragments/booking-error :: error";
    }
}
```

## MVP Implementation Priority

### Week 1-2: Foundation
1. **Spring Boot Setup**: Basic project with security
2. **Database Schema**: Create 6 core tables
3. **User Management**: Registration and authentication
4. **Basic Controllers**: Admin, Tutor, Client dashboards

### Week 3-4: Core Booking
1. **Session Booking**: Complete booking workflow
2. **Tutor Management**: Set availability and rates
3. **Subject Management**: Admin manages 6 subject-level combinations
4. **Basic Frontend**: Functional forms and tables

### Week 5-6: Payment Integration
1. **Stripe Setup**: Payment intent creation
2. **Webhook Handling**: Payment confirmation
3. **Session Completion**: Mark completed and process payment
4. **Email Notifications**: Basic email confirmations

## Evolution Path to Full Architecture

### Phase 2: Add Complexity Gradually
- Extract services into domain services
- Add more sophisticated error handling
- Implement proper validation
- Add caching for frequently accessed data

### Phase 3: Introduce DDD Patterns
- Refactor into bounded contexts
- Add aggregate roots and domain events
- Implement CQRS for complex queries
- Add event sourcing for audit trail

### Phase 4: Scale and Optimize
- Consider microservices for payment/notification
- Add Redis for session management
- Implement proper monitoring and logging
- Add comprehensive testing suite

This MVP architecture prioritizes **simplicity and speed** while maintaining a clear evolution path to the full DDD architecture outlined in the advanced documents.
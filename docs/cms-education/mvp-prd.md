# CMS Education Platform - MVP Product Requirements

## Executive Summary

**Goal**: Launch a minimal viable tutoring management platform for London, UK market within 10 weeks.

**Core Value**: Enable parents to book individual tutoring sessions, tutors to manage their teaching, and admins to oversee operations.

## Business Model (MVP)

### Simple Hierarchy: Subject → Level → Session

**Subject**: Mathematics, English, Science (3 core subjects only)  
**Level**: GCSE, A-Level (2 levels only)  
**Session**: 1-hour individual tutoring sessions  

### MVP Flow
1. Admin creates subjects and levels
2. Tutor sets availability and rates
3. Parent books session for child
4. Session occurs and payment processed
5. Basic progress tracking

## Core MVP Features

### 1. User Management (Week 1-2)
- **3 Roles**: Admin, Parent (Client), Tutor
- **Basic Authentication**: Email/password login
- **Profile Management**: Name, email, phone for all users

### 2. Student & Tutor Basics (Week 2-3)
- **Student Profile**: Name, age, academic level
- **Tutor Profile**: Name, subjects taught, hourly rate
- **Simple Subject Catalog**: Admin manages 6 combinations (3 subjects × 2 levels)

### 3. Session Booking (Week 3-4)
- **Tutor Availability**: Set available time slots
- **Session Booking**: Parent selects tutor and time slot
- **Basic Calendar**: Show upcoming sessions
- **Session Status**: Pending, Confirmed, Completed

### 4. Payment Processing (Week 4-5)
- **Stripe Integration**: Credit card payments only
- **Session-Based Billing**: Pay per completed session
- **Simple Invoicing**: Email invoice after session
- **Basic Commission**: 20% platform fee for tutors

### 5. Basic Progress Tracking (Week 5-6)
- **Session Notes**: Tutor adds brief notes after session
- **Simple Dashboard**: Show completed sessions and total hours
- **Parent View**: See child's session history and tutor feedback

## MVP Data Models (Essential Only)

```sql
-- Core Tables for MVP
users (id, email, password, role, name, phone, created_at)
students (id, parent_id, name, age, academic_level, created_at)
tutors (id, user_id, bio, hourly_rate, verified, created_at)
subjects (id, name, level, active)
sessions (id, student_id, tutor_id, subject_id, scheduled_at, duration, status, rate, notes, created_at)
payments (id, session_id, amount, stripe_payment_id, status, created_at)
```

## MVP User Stories

### Admin (Essential)
1. I can create tutor and parent accounts
2. I can manage the subject catalog (3 subjects × 2 levels)
3. I can view all sessions and payments
4. I can verify tutors before they go live

### Parent (Essential)
1. I can add my child's profile with academic level
2. I can search for tutors by subject and level
3. I can book a session with an available tutor
4. I can see my child's session history and tutor feedback

### Tutor (Essential)
1. I can set my availability (day/time slots)
2. I can set my hourly rate per subject/level
3. I can see my upcoming sessions
4. I can add session notes and mark sessions complete
5. I can view my earnings and payment history

## Technical Stack (MVP)

- **Backend**: Spring Boot + MySQL + JDBC
- **Frontend**: Thymeleaf + Bootstrap + basic HTMX
- **Payments**: Stripe Checkout (hosted)
- **Deployment**: Single Docker container on AWS
- **File Storage**: Local filesystem (no cloud storage yet)

## MVP Success Criteria

### Week 6 Demo Goals
- [ ] 3 user roles can log in and use their dashboards
- [ ] Complete booking flow: parent books → tutor confirms → session occurs → payment processed
- [ ] Basic session tracking and tutor feedback
- [ ] Stripe payment integration working
- [ ] Admin can oversee all platform activity

### Key Metrics
- **Functional**: Complete session booking and payment flow
- **Performance**: Page loads under 3 seconds
- **Reliability**: 99% uptime during demo period
- **User Experience**: Intuitive navigation without training

## What's NOT in MVP

### Deferred to Post-MVP
- **Homework Management**: No homework assignment/tracking
- **Advanced Scheduling**: No recurring sessions or complex availability
- **Group Sessions**: Individual sessions only
- **Multiple Children**: One child per parent account
- **Advanced Analytics**: Basic reporting only
- **Document Upload**: No certificate/qualification uploads
- **Mobile App**: Web-only responsive design
- **Video Integration**: In-person sessions only
- **Complex Pricing**: Fixed hourly rates only
- **Waitlists**: First-come-first-served booking
- **Dispute Resolution**: Admin handles manually
- **GDPR Compliance**: Basic privacy policy only
- **Advanced Security**: Standard Spring Security

## Implementation Timeline

### Week 1-2: Foundation
- Spring Boot project setup
- User authentication (3 roles)
- Basic CRUD for users, students, tutors

### Week 3-4: Core Features
- Subject catalog management
- Session booking system
- Basic calendar views

### Week 5-6: Payment & Polish
- Stripe integration
- Session completion flow
- Basic reporting dashboards
- UI/UX polish and testing

## Risk Mitigation

### Technical Risks
- **Stripe Integration**: Use Stripe Checkout (hosted) to minimize complexity
- **Database Design**: Keep schema simple, easy to extend later
- **Authentication**: Use Spring Security defaults, no custom implementation

### Scope Risks
- **Feature Creep**: Strict "no new features" policy during MVP development
- **Complex Requirements**: Document advanced features for post-MVP phases
- **Time Constraints**: Focus on core booking + payment flow only

## Post-MVP Roadmap

### Phase 2 (Weeks 7-10): Enhanced Features
- Homework assignment and tracking
- Multiple children per family
- Advanced tutor scheduling
- Document upload for qualifications

### Phase 3 (Weeks 11-14): Business Features
- Group sessions and family discounts
- Advanced analytics and reporting
- GDPR compliance and audit trails
- Mobile optimization

### Phase 4 (Weeks 15+): Advanced Platform
- Video conferencing integration
- AI-powered tutor matching
- Advanced dispute resolution
- Third-party integrations

This MVP approach gets you to market quickly with core functionality while providing a clear path for enhancement based on user feedback.
# Zalo AI Assistant - KISS Tech Stack & Specifications

## Project Overview

Zalo AI Assistant is a web application designed to help Vietnamese small businesses automate their Zalo customer communications with proper Vietnamese business etiquette. The solution targets saving businesses 15+ hours/week in manual messaging while using culturally appropriate AI responses.

## Core Problem

- Vietnamese businesses waste money on ineffective Western AI tools
- Manual Zalo message management takes 5+ hours/day
- Lost sales from slow response times
- No proper Vietnamese business etiquette in existing AI tools
- No customer conversation tracking

## Solution

- AI auto-reply with Vietnamese business etiquette
- Customer conversation tracking and management
- Content generation for Zalo business communications
- Simple, affordable solution for Vietnamese small businesses

## Target Users

- Vietnamese small business owners
- Zalo Official Account (OA) users
- Businesses with high customer message volume
- Non-technical users who need simple solutions

## Success Metrics

- Save 15+ hours/week per business
- 95%+ response rate improvement
- 80%+ reduction in manual messaging
- < 30 second average response time
- $10/month price point

---

## Documentation Structure

### Core Specifications

- [Tech Stack](./tech-stack.md) - Complete KISS technology stack
- [Architecture](./architecture.md) - System architecture and design
- [API Specification](./api-spec.md) - REST API endpoints and schemas
- [Database Schema](./database-schema.md) - Data models and relationships

### Feature Specifications

- [Authentication](./auth-spec.md) - User authentication and authorization
- [Zalo Integration](./zalo-integration.md) - Zalo API integration details
- [Real-time Communication](./realtime-spec.md) - Real-time messaging architecture
- [File Storage](./file-storage.md) - File upload and storage strategy

### Implementation Guides

- [Development Setup](./dev-setup.md) - Local development environment
- [Deployment Guide](./deployment.md) - Production deployment
- [Testing Strategy](./testing.md) - Testing approach and tools
- [Monitoring & Logging](./monitoring.md) - Application monitoring

---

## Quick Start

1. **Tech Stack**: Bun.js + Hono + Cloudflare Pages + SQLite
2. **Development**: `bun install && bun run dev`
3. **Deployment**: Git push to Cloudflare Pages
4. **Database**: SQLite file with simple migrations
5. **Authentication**: JWT tokens with Zalo OAuth

## KISS Principles

- **Minimal Dependencies**: Use built-in features whenever possible
- **Simple File Structure**: Flat organization, clear naming
- **No Build Tools**: Plain HTML/CSS/JS where possible
- **Progressive Enhancement**: Start simple, add complexity only when needed
- **Solo Developer Friendly**: Easy to understand, modify, and maintain

## Getting Started

Read the [Tech Stack](./tech-stack.md) document first to understand the complete technology choices, then proceed to [Architecture](./architecture.md) for system design.

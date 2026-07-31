# Architecture Decision Records (ADR)

## ADR-001: Dart-Only Technology Stack

### Status: Accepted

### Context
The project requires a unified technology stack to reduce cognitive load, enable code sharing between frontend and backend, and maintain type safety across the entire system.

### Decision
Use Dart for the entire ecosystem:
- **Frontend**: Flutter Web with Material 3
- **Backend**: Serverpod framework
- **Shared**: Common Dart package for models, enums, and utilities

### Consequences
- ✅ Full type safety end-to-end
- ✅ Code reuse between client and server
- ✅ Single language expertise required
- ✅ Unified serialization with `json_serializable` and `freezed`
- ⚠️ Smaller ecosystem compared to Node.js/Java
- ⚠️ Serverpod is younger than Express/Spring Boot

---

## ADR-002: Serverpod as Backend Framework

### Status: Accepted

### Context
We need a production-ready Dart backend framework with ORM, authentication, WebSocket support, and background job processing.

### Decision
Use **Serverpod 2.0+** as the backend framework.

### Rationale
- Native Dart support with code generation
- Built-in PostgreSQL ORM with type-safe queries
- Integrated authentication module
- WebSocket support for real-time features
- Background workers for async processing
- Automatic OpenAPI/Swagger generation
- Built-in logging and monitoring hooks

---

## ADR-003: PostgreSQL as Primary Database

### Status: Accepted

### Context
The system requires a relational database with ACID compliance, complex querying capabilities, and JSON support for flexible schemas.

### Decision
Use **PostgreSQL 15+** with Serverpod ORM.

### Rationale
- ACID compliance for financial transactions (orders, payments)
- Advanced indexing (B-tree, GiST, GIN) for search performance
- JSONB support for flexible product attributes
- Full-text search capabilities
- Row-level security for multi-tenant considerations
- Excellent Dart/Serverpod integration

---

## ADR-004: Riverpod for State Management

### Status: Accepted

### Context
The Flutter frontend requires robust, testable, and scalable state management for a complex e-commerce application.

### Decision
Use **Riverpod 2.0+** (with code generation) for all state management.

### Rationale
- Compile-safe dependency injection
- Built-in caching and auto-dispose
- Excellent async state handling (AsyncValue)
- DevTools integration for debugging
- Testable providers with overrides
- No BuildContext dependency for business logic

---

## ADR-005: Clean Architecture with Feature-First Organization

### Status: Accepted

### Context
The application will grow to 13+ modules with complex business logic. We need maintainable, testable code organization.

### Decision
Implement **Clean Architecture** with **Feature-First** folder structure.

### Layer Definitions
1. **Presentation Layer**: Widgets, Providers, Screens
2. **Domain Layer**: Entities, Use Cases, Repository Interfaces
3. **Data Layer**: Repositories, Data Sources, DTOs, Mappers

### Rules
- The Domain layer has NO external dependencies
- Data layer depends only on Domain
- Presentation depends on Domain and Data
- Features are self-contained vertical slices

---

## ADR-006: JWT with Refresh Token Rotation

### Status: Accepted

### Context
The system requires secure, stateless authentication for web clients with "Remember Me" functionality.

### Decision
Implement **JWT access tokens** (short-lived, 15 minutes) with **refresh token rotation** (long-lived, 7-30 days).

### Security Measures
- Access tokens: HS256, 15-minute expiry
- Refresh tokens: Secure random 256-bit, stored hashed in database
- Token rotation: New refresh token issued on every refresh
- Token family detection: Prevent replay attacks
- Secure cookies with HttpOnly, Secure, SameSite=Strict
- Argon2id for password hashing

---

## ADR-007: Repository Pattern with Dependency Injection

### Status: Accepted

### Context
We need testable, swappable data access layers for both unit testing and future infrastructure changes.

### Decision
Implement **Repository Pattern** with constructor injection.

### Implementation
- Abstract repository interfaces in Domain layer
- Concrete implementations in Data layer
- Providers injected via Riverpod
- Mock implementations for testing

---

## ADR-008: Monorepo with Melos

### Status: Accepted

### Context
Three interdependent Dart packages (client, server, shared) need coordinated versioning, dependency management, and scripts.

### Decision
Use **Melos** for monorepo management with `pubspec_overrides.yaml` for local path dependencies.

### Benefits
- Single source of truth for shared code
- Coordinated versioning
- Unified scripts (test, analyze, build)
- Local package linking for development

---

## ADR-009: Docker & Docker Compose for Local Dev

### Status: Accepted

### Context
The team needs consistent, reproducible local development environments across macOS, Linux, and Windows.

### Decision
Use **Docker Compose** for local infrastructure (PostgreSQL, Redis, Nginx) with hot-reload for Dart/Flutter development.

---

## ADR-010: Material 3 with Custom Bakery Theme

### Status: Accepted

### Context
The bakery brand requires warm, elegant visuals while maintaining accessibility and responsive design.

### Decision
Use **Flutter Material 3** with a custom color scheme:
- Primary: Warm Amber (#D4A373)
- Secondary: Cream (#FAEDCD)
- Tertiary: Chocolate (#5D4037)
- Error: Soft Red (#B3261E)
- Surface: Off-white (#FFFBF5)
- Dark Surface: Deep Brown (#1C110A)

### Accessibility
- WCAG 2.1 AA compliance
- Minimum contrast ratio 4.5:1
- Semantic HTML for screen readers
- Keyboard navigation support

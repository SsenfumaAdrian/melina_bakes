# 🧁 Melina Bakes — Enterprise Bakery Management Platform

> **Production-ready, enterprise-grade bakery management system built entirely in Dart.**

[![Dart](https://img.shields.io/badge/Dart-3.5+-blue.svg)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-Web-02569B.svg)](https://flutter.dev)
[![Serverpod](https://img.shields.io/badge/Serverpod-2.0+-green.svg)](https://serverpod.dev)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-336791.svg)](https://postgresql.org)

---

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Development Phases](#development-phases)
- [Contributing](#contributing)
- [License](#license)

---

## 🏛️ Architecture Overview

Melina Bakes follows **Clean Architecture** and **Domain-Driven Design (DDD)** principles with strict layer separation:

```
┌─────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                      │
│  Flutter Web • Material 3 • Riverpod • GoRouter • Responsive │
├─────────────────────────────────────────────────────────────┤
│                      DOMAIN LAYER                            │
│  Entities • Use Cases • Repository Contracts • Value Objects │
├─────────────────────────────────────────────────────────────┤
│                      DATA LAYER                              │
│  Repositories • Data Sources • DTOs • Models • Mappers       │
├─────────────────────────────────────────────────────────────┤
│                      INFRASTRUCTURE LAYER                    │
│  Serverpod • PostgreSQL • Redis • Docker • K8s • CI/CD       │
└─────────────────────────────────────────────────────────────┘
```

### Core Architectural Principles

- **Single Responsibility**: Every class has one reason to change
- **Dependency Inversion**: Dependencies point inward toward domain
- **Interface Segregation**: Client-specific interfaces over general ones
- **Repository Pattern**: Abstract data access for testability
- **Feature-First Organization**: Code organized by business capability

---

## 🛠️ Technology Stack

### Frontend
| Technology | Purpose |
|------------|---------|
| Flutter Web | Cross-platform UI framework |
| Material 3 | Modern design system |
| Riverpod | Reactive state management |
| GoRouter | Declarative routing |
| Dio | HTTP client with interceptors |
| Freezed | Immutable data classes |
| json_serializable | JSON serialization |
| flutter_animate | Rich animations |
| responsive_framework | Adaptive layouts |

### Backend
| Technology | Purpose |
|------------|---------|
| Serverpod | Dart backend framework |
| PostgreSQL | Primary database |
| JWT | Stateless authentication |
| Argon2id | Password hashing |
| WebSocket | Real-time updates |
| Redis | Session caching & rate limiting |

### DevOps
| Technology | Purpose |
|------------|---------|
| Docker | Containerization |
| Docker Compose | Local orchestration |
| GitHub Actions | CI/CD pipelines |
| Terraform | Infrastructure as Code |
| Nginx | Reverse proxy & load balancing |

---

## 📁 Project Structure

```
melina_bakes/
├── melina_bakes_client/          # Flutter Web Application
│   ├── lib/
│   │   ├── src/core/             # Core utilities, theme, router, DI
│   │   ├── src/features/         # Feature modules (auth, cart, etc.)
│   │   └── src/shared/           # Shared widgets & models
│   ├── assets/                   # Images, icons, fonts
│   └── web/                      # Web-specific configurations
│
├── melina_bakes_server/          # Serverpod Backend
│   ├── lib/
│   │   ├── src/endpoints/        # API endpoint definitions
│   │   ├── src/services/         # Business logic services
│   │   ├── src/repositories/     # Data access layer
│   │   ├── src/models/           # Serverpod entity models
│   │   ├── src/middleware/       # Auth, validation, rate limiting
│   │   ├── src/workers/          # Background job processors
│   │   └── src/config/           # Environment configurations
│   ├── config/                   # Serverpod YAML configurations
│   └── migrations/               # Database migrations
│
├── melina_bakes_shared/          # Shared Dart Package
│   └── lib/
│       ├── src/models/           # Shared data models
│       ├── src/enums/            # Shared enumerations
│       ├── src/constants/        # Shared constants
│       └── src/utils/            # Shared utilities
│
├── docker/                       # Docker configurations
├── infrastructure/               # Terraform & K8s manifests
├── scripts/                      # Build & deployment scripts
├── docs/                         # Architecture & API documentation
└── .github/workflows/            # CI/CD pipeline definitions
```

---

## 🚀 Getting Started

### Prerequisites

- Dart SDK >= 3.5.0
- Flutter SDK >= 3.24.0
- Docker & Docker Compose
- PostgreSQL 15+
- Redis 7+

### Local Development Setup

```bash
# 1. Clone the repository
git clone https://github.com/your-org/melina_bakes.git
cd melina_bakes

# 2. Start infrastructure services
docker-compose -f docker/docker-compose.dev.yml up -d

# 3. Install dependencies
melos bootstrap

# 4. Run database migrations
cd melina_bakes_server
dart bin/main.dart --apply-migrations

# 5. Start the server
dart bin/main.dart

# 6. In a new terminal, start the client
cd melina_bakes_client
flutter run -d chrome
```

---

## 📅 Development Phases

| Phase | Description | Status |
|-------|-------------|--------|
| 1 | Architecture & Foundation | 🔄 In Progress |
| 2 | Database Design & Models | ⏳ Pending |
| 3 | Authentication System | ⏳ Pending |
| 4 | Backend APIs | ⏳ Pending |
| 5 | Flutter Foundation | ⏳ Pending |
| 6 | Product Catalog | ⏳ Pending |
| 7 | Shopping Cart | ⏳ Pending |
| 8 | Order Management | ⏳ Pending |
| 9 | Admin Dashboard | ⏳ Pending |
| 10 | Deployment & DevOps | ⏳ Pending |

---

## 🤝 Contributing

Please read our [Contributing Guide](docs/CONTRIBUTING.md) before submitting PRs.

---

## 📄 License

Proprietary - Melina Bakes Enterprise Platform. All rights reserved.

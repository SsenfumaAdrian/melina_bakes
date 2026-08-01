# 🧁 Melina Bakes — Enterprise Bakery Management Platform

> **Production-ready, enterprise-grade bakery management system built entirely in Dart.**

[![Dart](https://img.shields.io/badge/Dart-3.5+-blue.svg)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-Web-02569B.svg)](https://flutter.dev)
[![Serverpod](https://img.shields.io/badge/Serverpod-2.0+-green.svg)](https://serverpod.dev)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-336791.svg)](https://postgresql.org)

---

## 🏗️ Project Status

| Phase | Status | Description |
|-------|--------|-------------|
| 1 | ✅ Complete | Architecture, Monorepo, Docker, CI/CD, Shared Package |
| 2 | ✅ Complete | Database Design, Serverpod Models, Migrations, Repositories |
| 3 | ✅ Complete | Authentication (Argon2id, JWT, RBAC, Email) |
| 4 | ✅ Complete | Backend APIs (Products, Cart, Orders, Payments, Admin, Customer) |
| 5 | ✅ Complete | Flutter Foundation (Theme, Router, Network, Auth UI, Home) |
| 6 | 🔄 **Next** | Product Catalog UI (Listing, Detail, Categories, Search) |
| 7 | ⏳ Pending | Shopping Cart |
| 8 | ⏳ Pending | Order Management |
| 9 | ⏳ Pending | Admin Dashboard |
| 10 | ⏳ Pending | Deployment & DevOps |

**📋 See [PROGRESS.md](PROGRESS.md) for detailed build status and handoff notes.**

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
│  Entities • Use Cases • Repository Contracts                 │
├─────────────────────────────────────────────────────────────┤
│                      DATA LAYER                              │
│  Repositories • Data Sources • Models • DTOs                 │
├─────────────────────────────────────────────────────────────┤
│                      PLATFORM LAYER                          │
│  Serverpod • PostgreSQL • Dio • Secure Storage               │
└─────────────────────────────────────────────────────────────┘
```

---

## 🛠️ Technology Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | Flutter Web, Material 3, Riverpod, GoRouter, Dio, Freezed |
| **Backend** | Serverpod (Dart), PostgreSQL, JWT, Argon2id |
| **DevOps** | Docker, Docker Compose, GitHub Actions, Nginx |
| **Design** | Figma-ready, WCAG 2.1 AA, Responsive (Mobile/Tablet/Desktop) |

---

## 📁 Project Structure

```
melina_bakes/
├── melina_bakes_client/          # Flutter Web application
│   ├── lib/
│   │   ├── src/
│   │   │   ├── core/             # Theme, Router, Network, DI
│   │   │   ├── features/         # Auth, Home, Products, Cart, Orders, Admin
│   │   │   └── shared/           # Reusable widgets, utilities
│   │   └── main.dart
│   └── pubspec.yaml
├── melina_bakes_server/          # Serverpod backend API
│   ├── lib/src/
│   │   ├── endpoints/            # REST API endpoints
│   │   ├── services/             # Business logic (Auth, Payment, Email)
│   │   ├── repositories/         # Data access layer
│   │   ├── middleware/           # Auth middleware, RBAC
│   │   ├── generated/            # Serverpod ORM models
│   │   └── protocol/             # YAML model definitions
│   ├── migrations/               # PostgreSQL schema migrations
│   └── pubspec.yaml
├── melina_bakes_shared/          # Shared enums, constants, utilities
│   └── lib/src/
│       ├── enums/                # UserRole, OrderStatus, PaymentStatus, etc.
│       ├── constants/            # API constants, storage keys
│       ├── models/               # PaginatedResponse
│       └── utils/                # Result<T,F>, Validators, Extensions
├── docker/                       # Docker & Nginx configurations
├── .github/workflows/            # CI/CD pipelines
├── docs/                         # Architecture Decision Records
└── scripts/                      # Automation scripts
```

---

## 🚀 Getting Started

### Prerequisites

- Dart SDK >= 3.5.0
- Flutter SDK >= 3.24.0
- Docker & Docker Compose
- PostgreSQL 15+

### Clone & Setup

```bash
git clone https://github.com/SsenfumaAdrian/melina_bakes.git
cd melina_bakes

# Start infrastructure
docker-compose -f docker/docker-compose.dev.yml up -d

# Install dependencies
cd melina_bakes_server && dart pub get
cd ../melina_bakes_client && flutter pub get
cd ../melina_bakes_shared && dart pub get
```

### Run the Server

```bash
cd melina_bakes_server
dart bin/main.dart
```

### Run the Client

```bash
cd melina_bakes_client
flutter run -d chrome
```

---

## 📅 Development Phases

### ✅ Phase 1 — Architecture & Foundation
- Monorepo structure with `melos`
- Docker Compose (dev + prod)
- GitHub Actions CI/CD
- Shared package with enums, constants, Result type
- Architecture Decision Records (ADRs)

### ✅ Phase 2 — Database Design
- 28 Serverpod protocol YAML files
- 25 PostgreSQL tables with indexes, FKs, constraints
- Generated Dart models (User, Product, Order, Category)
- Database views for analytics

### ✅ Phase 3 — Authentication
- Password hashing (Argon2id)
- JWT service (HS256) with refresh tokens
- Auth middleware with RBAC
- Email service with HTML templates
- Account lockout, email verification

### ✅ Phase 4 — Backend APIs
- **Bakery**: Categories, Products, Search, Filters
- **Cart**: Add, Update, Remove, Coupons
- **Orders**: Create, Track, History, Status updates
- **Payments**: Stripe, Flutterwave, PayPal, Mobile Money architecture
- **Customer**: Profile, Addresses, Wishlist, Notifications
- **Admin**: Dashboard, Orders, Products, Inventory, Reports, Staff

### ✅ Phase 5 — Flutter Foundation
- Material 3 theme (light + dark modes)
- Google Fonts (Playfair Display + Inter)
- GoRouter with auth guards & role-based access
- Dio network layer with 4 interceptors
- Secure storage for tokens
- Auth feature: Login, Register, Logout, Token refresh
- Home screen: Hero banner, categories, featured products
- Responsive shell: NavigationRail (desktop) / BottomNav (mobile)

### 🔄 Phase 6 — Product Catalog UI *(In Progress)*
- Product grid/list with filters
- Product detail with image gallery
- Category browsing
- Search with suggestions

### ⏳ Phase 7 — Shopping Cart
### ⏳ Phase 8 — Order Management
### ⏳ Phase 9 — Admin Dashboard
### ⏳ Phase 10 — Deployment & DevOps

---

## 🤝 Contributing

This project is being built iteratively with AI assistance. Each phase is committed with detailed messages and signed commits.

**Commit Signing:** This repository uses SSH commit signing. See [GitHub Docs](https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification) for setup instructions.

---

## 📄 License

MIT License — See [LICENSE](LICENSE) for details.

---

<p align="center">
  <strong>🧁 Melina Bakes</strong> — Crafted with love in Dart<br>
  <em>Built by Ssenfuma Adrian</em>
</p>

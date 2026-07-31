# 🧁 Melina Bakes — Project Progress & Handoff Document

> **This document exists so any AI assistant can pick up exactly where the last one left off.**
> 
> **Owner:** Ssenfuma Adrian <adrianssenfuma@gmail.com>  
> **Repo:** https://github.com/SsenfumaAdrian/melina_bakes.git  
> **Last Updated:** 2026-08-01

---

## 📊 Current Status: PHASE 3 COMPLETE → PHASE 4 NEXT

| Phase | Name | Status | Commit |
|-------|------|--------|--------|
| 1 | Architecture & Foundation | ✅ Complete | `63eaf48` |
| 2 | Database Design & Models | ✅ Complete | `46045ad` |
| 3 | Authentication System | ✅ Complete | `66e5d5e` |
| 4 | Backend APIs | 🔄 **NEXT** | — |
| 5 | Flutter Foundation | ⏳ Pending | — |
| 6 | Product Catalog UI | ⏳ Pending | — |
| 7 | Shopping Cart | ⏳ Pending | — |
| 8 | Order Management | ⏳ Pending | — |
| 9 | Admin Dashboard | ⏳ Pending | — |
| 10 | Deployment & DevOps | ⏳ Pending | — |

---

## 🏗️ Architecture (DO NOT CHANGE)

### Technology Stack (NON-NEGOTIABLE)
- **Frontend:** Flutter Web, Material 3, Riverpod, GoRouter, Dio, Freezed
- **Backend:** Serverpod (Dart ONLY - no Node.js, Java, Python, PHP, C#)
- **Database:** PostgreSQL 15+ with Serverpod ORM
- **DevOps:** Docker, Docker Compose, GitHub Actions, Nginx

### Design Patterns
- Clean Architecture (Domain → Data → Presentation)
- Domain-Driven Design (DDD)
- Feature-First folder structure
- Repository Pattern with Dependency Injection
- MVVM where appropriate

### Monorepo Structure
```
melina_bakes/
├── melina_bakes_client/     # Flutter Web
├── melina_bakes_server/     # Serverpod Backend
├── melina_bakes_shared/     # Shared Dart package
├── docker/                  # Docker configs
├── infrastructure/          # Terraform/K8s
├── docs/                    # Documentation
└── .github/workflows/       # CI/CD
```

---

## ✅ PHASE 1: Architecture & Foundation (COMPLETE)

**Commit:** `63eaf48` (GPG Signed)

### Deliverables
- Complete monorepo structure (109 folders)
- `melos.yaml` for monorepo management
- `pubspec.yaml` for all 3 packages (client, server, shared)
- `analysis_options.yaml` with 200+ lint rules
- Serverpod configs (`development.yaml`, `production.yaml`)
- Docker Compose (dev + prod)
- Nginx reverse proxy configs
- GitHub Actions CI/CD (CI + CD pipelines)
- Architecture Decision Records (10 ADRs)

### Shared Package (`melina_bakes_shared`)
- **8 Enums:** UserRole, OrderStatus, PaymentStatus, PaymentMethod, ProductStatus, InventoryStatus, NotificationType, CouponType
- **Constants:** AppConstants, ApiConstants (40+ endpoints), StorageKeys
- **Utils:** Result<R,F> (functional error handling), Validators (email, password, phone, etc.), Extensions (String, DateTime, List)
- **Models:** PaginatedResponse<T>

---

## ✅ PHASE 2: Database Design & Models (COMPLETE)

**Commit:** `46045ad` (GPG Signed)

### Serverpod Protocol Files (28 YAML files)
All in `melina_bakes_server/lib/src/protocol/`

| Domain | Files |
|--------|-------|
| Auth | `user.yaml`, `refresh_token.yaml`, `password_reset.yaml`, `email_verification.yaml` |
| Catalog | `category.yaml`, `product.yaml`, `product_image.yaml` |
| Cart | `cart.yaml`, `cart_item.yaml` |
| Orders | `order.yaml`, `order_item.yaml`, `order_status_history.yaml` |
| Payments | `payment.yaml` |
| Customer | `address.yaml`, `wishlist_item.yaml` |
| Notifications | `notification.yaml` |
| Admin/CMS | `coupon.yaml`, `coupon_usage.yaml`, `banner.yaml`, `testimonial.yaml`, `faq.yaml` |
| Inventory | `ingredient.yaml`, `supplier.yaml`, `purchase_order.yaml`, `purchase_order_item.yaml`, `inventory_log.yaml` |
| Audit | `audit_log.yaml`, `staff_member.yaml` |

### Generated Dart Models
- `user.dart` — Full User model with UserTable
- `product.dart` — Product with pricing logic, stock checks
- `order.dart` — Order with status tracking
- `category.dart` — Category with hierarchy support

### Database Migration
**File:** `migrations/0001_initial_schema.sql`
- 25 tables with full constraints
- 60+ indexes for performance
- 30+ foreign keys with ON DELETE policies
- 3 materialized views (daily_revenue, low_stock_products, low_stock_ingredients)
- Auto-update triggers on all mutable tables
- Soft delete pattern
- Full-text search (pg_trgm)
- Seed data (admin user, default categories)

### Repository Interfaces
- `user_repository.dart` — 10 operations
- `product_repository.dart` — 11 operations
- `order_repository.dart` — 7 operations
- `category_repository.dart` — 6 operations

---

## ✅ PHASE 3: Authentication System (COMPLETE)

**Commit:** `66e5d5e` (GPG Signed)

### Services
| File | Purpose |
|------|---------|
| `services/auth/password_service.dart` | Argon2id hashing (64MB, 3 iterations, 4 parallelism) |
| `services/auth/jwt_service.dart` | HS256 JWT creation/validation, claims extraction |
| `services/auth/auth_service.dart` | Full auth business logic |
| `services/notification/email_service.dart` | 6 HTML email templates |

### AuthService Features
- `register()` — Email validation, password strength, hash, create user, issue tokens
- `login()` — Credential verification, account lockout check (5 attempts, 30min), password rehashing, token generation
- `refreshAccessToken()` — Token rotation (new refresh token on every use)
- `validateAccessToken()` — JWT validation + user lookup
- `requestPasswordReset()` — Enumeration-safe (always returns success)
- `resetPassword()` — Token validation + password update
- `changePassword()` — Current password verification + update

### AuthEndpoint (10 REST Endpoints)
- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/refresh`
- `POST /auth/logout`
- `POST /auth/forgot-password`
- `POST /auth/reset-password`
- `POST /auth/change-password`
- `POST /auth/verify-email`
- `POST /auth/resend-verification`
- `GET /auth/me`

### AuthMiddleware
- JWT validation from Authorization header
- Role-based access control (RBAC) with hierarchy
- Optional auth middleware for guest-accessible endpoints
- Email verification enforcement (configurable)

### UserRepositoryImpl
- Full CRUD operations
- Soft delete with email anonymization
- Pagination with filtering
- Login tracking (failed attempts, lockout, IP)
- Password updates

### Security Features
- Argon2id password hashing (memory-hard)
- HS256 JWT with 15-min access / 7-day refresh
- Token rotation on every refresh
- Account lockout (5 failed attempts → 30 min)
- Constant-time password comparison
- Password rehashing on login when params change
- Secure token generation (Random.secure(), 64 bytes)
- Email enumeration prevention

---

## 🔄 PHASE 4: BACKEND APIs (NEXT — BUILD THIS NOW)

### What Needs to Be Built

#### 1. Product Catalog Endpoints
```
GET    /api/v1/categories              → listCategories
GET    /api/v1/categories/:slug        → getCategoryBySlug
GET    /api/v1/products                → listProducts (with filters, sort, pagination)
GET    /api/v1/products/:slug          → getProductBySlug
GET    /api/v1/products/featured       → getFeaturedProducts
GET    /api/v1/products/search         → searchProducts (full-text)
```

#### 2. Cart Endpoints
```
GET    /api/v1/cart                    → getCart
POST   /api/v1/cart/items              → addToCart
PUT    /api/v1/cart/items/:id          → updateCartItem
DELETE /api/v1/cart/items/:id          → removeFromCart
POST   /api/v1/cart/apply-coupon       → applyCoupon
POST   /api/v1/cart/remove-coupon      → removeCoupon
```

#### 3. Order Endpoints
```
POST   /api/v1/orders                  → createOrder
GET    /api/v1/orders                  → listOrders
GET    /api/v1/orders/:number          → getOrderByNumber
GET    /api/v1/orders/:number/track    → trackOrder
POST   /api/v1/orders/:id/cancel       → cancelOrder
```

#### 4. Payment Endpoints (Architecture Only)
```
POST   /api/v1/payments/intent         → createPaymentIntent
POST   /api/v1/payments/confirm        → confirmPayment
POST   /api/v1/payments/webhook        → handleWebhook
```

#### 5. Customer Endpoints
```
GET    /api/v1/customer/profile        → getProfile
PUT    /api/v1/customer/profile        → updateProfile
GET    /api/v1/customer/addresses      → listAddresses
POST   /api/v1/customer/addresses      → createAddress
PUT    /api/v1/customer/addresses/:id  → updateAddress
DELETE /api/v1/customer/addresses/:id  → deleteAddress
GET    /api/v1/customer/orders         → listCustomerOrders
GET    /api/v1/customer/wishlist       → listWishlist
POST   /api/v1/customer/wishlist       → addToWishlist
DELETE /api/v1/customer/wishlist/:id   → removeFromWishlist
GET    /api/v1/customer/notifications  → listNotifications
PUT    /api/v1/customer/notifications/:id/read → markRead
```

#### 6. Admin Endpoints
```
GET    /api/v1/admin/dashboard         → getDashboardStats
GET    /api/v1/admin/orders            → listAllOrders
PUT    /api/v1/admin/orders/:id/status → updateOrderStatus
GET    /api/v1/admin/customers         → listCustomers
GET    /api/v1/admin/products          → listProducts (admin)
POST   /api/v1/admin/products          → createProduct
PUT    /api/v1/admin/products/:id      → updateProduct
DELETE /api/v1/admin/products/:id      → deleteProduct
GET    /api/v1/admin/categories        → listCategories (admin)
POST   /api/v1/admin/categories        → createCategory
PUT    /api/v1/admin/categories/:id    → updateCategory
DELETE /api/v1/admin/categories/:id    → deleteCategory
GET    /api/v1/admin/inventory         → getInventory
PUT    /api/v1/admin/inventory/:id     → updateStock
GET    /api/v1/admin/coupons           → listCoupons
POST   /api/v1/admin/coupons           → createCoupon
GET    /api/v1/admin/reports           → getReports
GET    /api/v1/admin/staff             → listStaff
POST   /api/v1/admin/staff             → createStaff
```

### Files to Create
- `endpoints/bakery/bakery_endpoint.dart` — Products & Categories
- `endpoints/cart/cart_endpoint.dart` — Cart operations
- `endpoints/orders/orders_endpoint.dart` — Order management
- `endpoints/payments/payments_endpoint.dart` — Payment processing
- `endpoints/customer/customer_endpoint.dart` — Customer dashboard
- `endpoints/admin/admin_endpoint.dart` — Admin operations
- `repositories/product_repository_impl.dart`
- `repositories/order_repository_impl.dart`
- `repositories/cart_repository_impl.dart`
- `services/payment/payment_service.dart` — Payment provider interfaces
- `services/payment/stripe_service.dart`
- `services/payment/flutterwave_service.dart`
- `services/payment/paypal_service.dart`

---

## ⏳ PHASE 5: FLUTTER FOUNDATION (PENDING)

### What Needs to Be Built
- `main.dart` — App entry point with ProviderScope
- Material 3 theme system (light + dark modes)
- GoRouter configuration with route guards
- Dio client with interceptors (auth token injection, error handling)
- Riverpod provider container setup
- Core widgets (responsive layout, loading states, error boundaries)
- Localization setup

---

## ⏳ PHASE 6-10: PENDING

See original project specification for full details on:
- Phase 6: Product Catalog UI
- Phase 7: Shopping Cart
- Phase 8: Order Management
- Phase 9: Admin Dashboard
- Phase 10: Deployment & DevOps

---

## 🔑 Critical Context for AI Assistants

### Owner Preferences
- **Language:** English
- **Code Style:** Clean Architecture, DDD, SOLID, DRY, KISS
- **No placeholder code** — everything must compile and be production-ready
- **No TODOs** in code
- **Every file** must have documentation comments
- **Type safety** everywhere — no dynamic unless absolutely necessary
- **Async/await** — no raw Futures
- **Error handling** — use Result<T,F> pattern from shared package

### Git Workflow
- Commits must be GPG-signed for "Verified" badge on GitHub
- Owner: Ssenfuma Adrian <adrianssenfuma@gmail.com>
- Use conventional commit messages with phase emojis
- Push to: `https://github.com/SsenfumaAdrian/melina_bakes.git`

### Security Requirements
- Argon2id for passwords
- JWT with refresh token rotation
- Rate limiting on auth endpoints
- CSRF protection
- XSS prevention
- SQL injection protection (use ORM, no raw SQL)
- Input validation on all endpoints
- Audit logging for sensitive operations

### Design Requirements
- Material 3 with custom bakery theme
- Warm colors: Amber (#D4A373), Cream (#FAEDCD), Chocolate (#5D4037)
- Responsive: Desktop, Tablet, Mobile
- Accessibility: WCAG 2.1 AA
- Dark mode + Light mode
- Beautiful animations (flutter_animate)

---

## 📞 Contact

**Project Owner:** Ssenfuma Adrian  
**Email:** adrianssenfuma@gmail.com  
**GitHub:** https://github.com/SsenfumaAdrian  
**Repository:** https://github.com/SsenfumaAdrian/melina_bakes.git

---

*This document ensures seamless continuity. If you are a new AI assistant reading this, start with Phase 4 (Backend APIs) immediately. Do not rebuild Phases 1-3 unless explicitly asked.*

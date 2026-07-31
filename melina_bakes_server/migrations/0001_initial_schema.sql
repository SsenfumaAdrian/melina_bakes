-- ============================================================================
-- MELINA BAKES DATABASE MIGRATION
-- Phase 2: Initial Schema
-- PostgreSQL 15+ | Serverpod ORM Compatible
-- ============================================================================
-- This migration creates all tables, indexes, constraints, and triggers
-- for the Melina Bakes enterprise bakery management platform.
-- ============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";  -- For text search

-- ============================================================================
-- 1. AUTH & USER TABLES
-- ============================================================================

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone_number VARCHAR(20),
    avatar_url TEXT,
    role VARCHAR(20) NOT NULL DEFAULT 'customer',
    is_email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    failed_login_attempts INTEGER NOT NULL DEFAULT 0,
    locked_until TIMESTAMP WITH TIME ZONE,
    last_login_at TIMESTAMP WITH TIME ZONE,
    last_login_ip INET,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT chk_user_role CHECK (role IN ('admin', 'manager', 'staff', 'customer', 'guest')),
    CONSTRAINT chk_user_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

COMMENT ON TABLE users IS 'Core user accounts for all roles';

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_active ON users(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_users_deleted ON users(deleted_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_name_search ON users USING gin (first_name gin_trgm_ops, last_name gin_trgm_ops);

-- Auto-update updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Soft delete view (active users only)
CREATE VIEW active_users AS
SELECT * FROM users WHERE deleted_at IS NULL;

-- ============================================================================

CREATE TABLE refresh_tokens (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    token_family VARCHAR(255) NOT NULL,
    device_info TEXT,
    ip_address INET,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    revoked_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_refresh_token_expires CHECK (expires_at > created_at)
);

COMMENT ON TABLE refresh_tokens IS 'JWT refresh tokens for session management';

CREATE INDEX idx_refresh_tokens_token ON refresh_tokens(token_hash);
CREATE INDEX idx_refresh_tokens_user ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_expires ON refresh_tokens(expires_at);
CREATE INDEX idx_refresh_tokens_active ON refresh_tokens(user_id, revoked_at) 
    WHERE revoked_at IS NULL;

-- ============================================================================

CREATE TABLE password_resets (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    used_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_password_reset_expires CHECK (expires_at > created_at)
);

COMMENT ON TABLE password_resets IS 'Password reset request tokens';

CREATE INDEX idx_password_resets_token ON password_resets(token_hash);
CREATE INDEX idx_password_resets_user ON password_resets(user_id);
CREATE INDEX idx_password_resets_expires ON password_resets(expires_at);

-- ============================================================================

CREATE TABLE email_verifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    verified_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_email_verification_expires CHECK (expires_at > created_at)
);

COMMENT ON TABLE email_verifications IS 'Email verification tokens';

CREATE INDEX idx_email_verifications_token ON email_verifications(token_hash);
CREATE INDEX idx_email_verifications_user ON email_verifications(user_id);

-- ============================================================================
-- 2. PRODUCT CATALOG TABLES
-- ============================================================================

CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    parent_id INTEGER REFERENCES categories(id) ON DELETE SET NULL,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    image_url TEXT,
    icon_url TEXT,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_featured BOOLEAN NOT NULL DEFAULT FALSE,
    meta_title VARCHAR(255),
    meta_description VARCHAR(500),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT chk_category_no_self_parent CHECK (parent_id IS NULL OR parent_id != id)
);

COMMENT ON TABLE categories IS 'Product categories with hierarchical support';

CREATE INDEX idx_categories_slug ON categories(slug);
CREATE INDEX idx_categories_parent ON categories(parent_id);
CREATE INDEX idx_categories_active ON categories(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_categories_featured ON categories(is_featured) WHERE is_featured = TRUE;
CREATE INDEX idx_categories_sort ON categories(sort_order);

CREATE TRIGGER trg_categories_updated_at
    BEFORE UPDATE ON categories
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    category_id INTEGER NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
    name VARCHAR(200) NOT NULL,
    slug VARCHAR(200) NOT NULL UNIQUE,
    sku VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    short_description VARCHAR(500),
    base_price DECIMAL(10, 2) NOT NULL,
    sale_price DECIMAL(10, 2),
    cost_price DECIMAL(10, 2),
    quantity_in_stock INTEGER NOT NULL DEFAULT 0,
    low_stock_threshold INTEGER NOT NULL DEFAULT 10,
    track_inventory BOOLEAN NOT NULL DEFAULT TRUE,
    status VARCHAR(20) NOT NULL DEFAULT 'available',
    is_featured BOOLEAN NOT NULL DEFAULT FALSE,
    is_new BOOLEAN NOT NULL DEFAULT TRUE,
    primary_image_url TEXT,
    meta_title VARCHAR(255),
    meta_description VARCHAR(500),
    attributes JSONB,
    weight_grams DECIMAL(10, 2),
    allergens TEXT,
    ingredients TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT chk_product_status CHECK (status IN ('available', 'outOfStock', 'discontinued', 'comingSoon')),
    CONSTRAINT chk_product_price_positive CHECK (base_price >= 0),
    CONSTRAINT chk_product_sale_price CHECK (sale_price IS NULL OR sale_price >= 0),
    CONSTRAINT chk_product_stock CHECK (quantity_in_stock >= 0)
);

COMMENT ON TABLE products IS 'Bakery products with pricing and inventory';

CREATE INDEX idx_products_slug ON products(slug);
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_status ON products(status);
CREATE INDEX idx_products_featured ON products(is_featured) WHERE is_featured = TRUE;
CREATE INDEX idx_products_new ON products(is_new) WHERE is_new = TRUE;
CREATE INDEX idx_products_price ON products(base_price);
CREATE INDEX idx_products_stock ON products(quantity_in_stock);
CREATE INDEX idx_products_active ON products(deleted_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_products_name_search ON products USING gin (name gin_trgm_ops);
CREATE INDEX idx_products_attributes ON products USING gin (attributes);

CREATE TRIGGER trg_products_updated_at
    BEFORE UPDATE ON products
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================

CREATE TABLE product_images (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    thumbnail_url TEXT,
    medium_url TEXT,
    alt_text VARCHAR(255),
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_product_image_sort CHECK (sort_order >= 0)
);

COMMENT ON TABLE product_images IS 'Product gallery images';

CREATE INDEX idx_product_images_product ON product_images(product_id);
CREATE INDEX idx_product_images_primary ON product_images(product_id, is_primary) WHERE is_primary = TRUE;
CREATE INDEX idx_product_images_sort ON product_images(product_id, sort_order);

-- ============================================================================
-- 3. CART TABLES
-- ============================================================================

CREATE TABLE carts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    session_id VARCHAR(255),
    subtotal DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    discount_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    tax_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    delivery_charge DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    total DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    coupon_id INTEGER,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_cart_user_or_session CHECK (user_id IS NOT NULL OR session_id IS NOT NULL)
);

COMMENT ON TABLE carts IS 'Persistent shopping carts';

CREATE INDEX idx_carts_user ON carts(user_id);
CREATE INDEX idx_carts_session ON carts(session_id);
CREATE INDEX idx_carts_active ON carts(is_active) WHERE is_active = TRUE;

CREATE TRIGGER trg_carts_updated_at
    BEFORE UPDATE ON carts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================

CREATE TABLE cart_items (
    id SERIAL PRIMARY KEY,
    cart_id INTEGER NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    special_instructions TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_cart_item_quantity CHECK (quantity > 0),
    CONSTRAINT chk_cart_item_price CHECK (unit_price >= 0),
    CONSTRAINT uq_cart_item_product UNIQUE (cart_id, product_id)
);

COMMENT ON TABLE cart_items IS 'Individual items in a cart';

CREATE INDEX idx_cart_items_cart ON cart_items(cart_id);
CREATE INDEX idx_cart_items_product ON cart_items(product_id);

CREATE TRIGGER trg_cart_items_updated_at
    BEFORE UPDATE ON cart_items
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 4. ORDER TABLES
-- ============================================================================

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    cart_id INTEGER REFERENCES carts(id) ON DELETE SET NULL,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    payment_status VARCHAR(20) NOT NULL DEFAULT 'pending',
    subtotal DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    discount_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    tax_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    delivery_charge DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    total DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    coupon_code VARCHAR(50),
    coupon_discount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    delivery_address_id INTEGER,
    delivery_method VARCHAR(50) NOT NULL DEFAULT 'standard',
    estimated_delivery_date DATE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    customer_name VARCHAR(200) NOT NULL,
    customer_email VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(20),
    customer_notes TEXT,
    staff_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_order_status CHECK (status IN ('pending', 'confirmed', 'preparing', 'baking', 'ready', 'outForDelivery', 'completed', 'cancelled')),
    CONSTRAINT chk_order_payment_status CHECK (payment_status IN ('pending', 'processing', 'completed', 'failed', 'refunded', 'partiallyRefunded')),
    CONSTRAINT chk_order_total CHECK (total >= 0)
);

COMMENT ON TABLE orders IS 'Customer orders with full pricing';

CREATE INDEX idx_orders_number ON orders(order_number);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_payment ON orders(payment_status);
CREATE INDEX idx_orders_created ON orders(created_at);
CREATE INDEX idx_orders_date ON orders(created_at DESC);

CREATE TRIGGER trg_orders_updated_at
    BEFORE UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================

CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    product_name VARCHAR(200) NOT NULL,
    product_sku VARCHAR(100),
    product_image_url TEXT,
    unit_price DECIMAL(10, 2) NOT NULL,
    quantity INTEGER NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    special_instructions TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_order_item_quantity CHECK (quantity > 0),
    CONSTRAINT chk_order_item_price CHECK (unit_price >= 0)
);

COMMENT ON TABLE order_items IS 'Snapshot of products at time of order';

CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);

-- ============================================================================

CREATE TABLE order_status_history (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    changed_by_user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    previous_status VARCHAR(20),
    new_status VARCHAR(20) NOT NULL,
    reason TEXT,
    changed_by_role VARCHAR(20),
    ip_address INET,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_osh_status CHECK (new_status IN ('pending', 'confirmed', 'preparing', 'baking', 'ready', 'outForDelivery', 'completed', 'cancelled'))
);

COMMENT ON TABLE order_status_history IS 'Audit trail of order status changes';

CREATE INDEX idx_order_status_history_order ON order_status_history(order_id);
CREATE INDEX idx_order_status_history_status ON order_status_history(new_status);
CREATE INDEX idx_order_status_history_created ON order_status_history(created_at);

-- ============================================================================
-- 5. PAYMENT TABLES
-- ============================================================================

CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE RESTRICT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    transaction_id VARCHAR(255) NOT NULL UNIQUE,
    provider VARCHAR(20) NOT NULL,
    provider_transaction_id VARCHAR(255),
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    fee DECIMAL(10, 2),
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    failure_reason TEXT,
    provider_response TEXT,
    metadata JSONB,
    refunded_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    refunded_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_payment_provider CHECK (provider IN ('stripe', 'flutterwave', 'paypal', 'mobileMoney', 'cashOnDelivery', 'bankTransfer')),
    CONSTRAINT chk_payment_status CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'refunded', 'partiallyRefunded')),
    CONSTRAINT chk_payment_amount CHECK (amount >= 0)
);

COMMENT ON TABLE payments IS 'Payment transactions';

CREATE INDEX idx_payments_transaction ON payments(transaction_id);
CREATE INDEX idx_payments_order ON payments(order_id);
CREATE INDEX idx_payments_user ON payments(user_id);
CREATE INDEX idx_payments_provider ON payments(provider);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_created ON payments(created_at);

CREATE TRIGGER trg_payments_updated_at
    BEFORE UPDATE ON payments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 6. CUSTOMER TABLES
-- ============================================================================

CREATE TABLE addresses (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    label VARCHAR(50),
    recipient_name VARCHAR(200) NOT NULL,
    phone_number VARCHAR(20),
    street_address TEXT NOT NULL,
    apartment VARCHAR(50),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_address_coords CHECK (
        (latitude IS NULL AND longitude IS NULL) OR
        (latitude BETWEEN -90 AND 90 AND longitude BETWEEN -180 AND 180)
    )
);

COMMENT ON TABLE addresses IS 'Customer shipping/billing addresses';

CREATE INDEX idx_addresses_user ON addresses(user_id);
CREATE INDEX idx_addresses_default ON addresses(user_id, is_default) WHERE is_default = TRUE;
CREATE INDEX idx_addresses_active ON addresses(is_active) WHERE is_active = TRUE;

CREATE TRIGGER trg_addresses_updated_at
    BEFORE UPDATE ON addresses
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================

CREATE TABLE wishlist_items (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_wishlist UNIQUE (user_id, product_id)
);

COMMENT ON TABLE wishlist_items IS 'Customer wishlist entries';

CREATE INDEX idx_wishlist_user ON wishlist_items(user_id);
CREATE INDEX idx_wishlist_product ON wishlist_items(product_id);

-- ============================================================================
-- 7. NOTIFICATION TABLE
-- ============================================================================

CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(20) NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    data JSONB,
    image_url TEXT,
    action_url TEXT,
    channel VARCHAR(20) NOT NULL DEFAULT 'in_app',
    sent_at TIMESTAMP WITH TIME ZONE,
    read_at TIMESTAMP WITH TIME ZONE,
    failed_at TIMESTAMP WITH TIME ZONE,
    failure_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_notification_type CHECK (type IN ('orderUpdate', 'promotion', 'inventoryAlert', 'payment', 'system', 'security')),
    CONSTRAINT chk_notification_channel CHECK (channel IN ('in_app', 'email', 'sms', 'push'))
);

COMMENT ON TABLE notifications IS 'Multi-channel notifications';

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_channel ON notifications(channel);
CREATE INDEX idx_notifications_read ON notifications(user_id, read_at) WHERE read_at IS NULL;
CREATE INDEX idx_notifications_created ON notifications(created_at DESC);

-- ============================================================================
-- 8. ADMIN / CMS TABLES
-- ============================================================================

CREATE TABLE coupons (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    type VARCHAR(20) NOT NULL,
    value DECIMAL(10, 2) NOT NULL,
    minimum_order_amount DECIMAL(10, 2),
    maximum_discount DECIMAL(10, 2),
    usage_limit INTEGER,
    usage_count INTEGER NOT NULL DEFAULT 0,
    usage_limit_per_user INTEGER,
    starts_at TIMESTAMP WITH TIME ZONE NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE,
    applicable_products INTEGER[],
    applicable_categories INTEGER[],
    excluded_products INTEGER[],
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT chk_coupon_type CHECK (type IN ('percentage', 'fixedAmount', 'freeShipping', 'buyXGetY')),
    CONSTRAINT chk_coupon_value CHECK (value >= 0),
    CONSTRAINT chk_coupon_dates CHECK (expires_at IS NULL OR expires_at > starts_at)
);

COMMENT ON TABLE coupons IS 'Discount coupons and promo codes';

CREATE INDEX idx_coupons_code ON coupons(code);
CREATE INDEX idx_coupons_active ON coupons(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_coupons_dates ON coupons(starts_at, expires_at);

CREATE TRIGGER trg_coupons_updated_at
    BEFORE UPDATE ON coupons
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================

CREATE TABLE coupon_usage (
    id SERIAL PRIMARY KEY,
    coupon_id INTEGER NOT NULL REFERENCES coupons(id) ON DELETE RESTRICT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE RESTRICT,
    discount_amount DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_coupon_usage_amount CHECK (discount_amount >= 0)
);

COMMENT ON TABLE coupon_usage IS 'Individual coupon redemptions';

CREATE INDEX idx_coupon_usage_coupon ON coupon_usage(coupon_id);
CREATE INDEX idx_coupon_usage_user ON coupon_usage(user_id);
CREATE INDEX idx_coupon_usage_order ON coupon_usage(order_id);

-- ============================================================================

CREATE TABLE banners (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    subtitle VARCHAR(500),
    description TEXT,
    image_url TEXT NOT NULL,
    mobile_image_url TEXT,
    link_url TEXT,
    link_text VARCHAR(100),
    position VARCHAR(50) NOT NULL DEFAULT 'homepage',
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    starts_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_banner_dates CHECK (expires_at IS NULL OR starts_at IS NULL OR expires_at > starts_at)
);

COMMENT ON TABLE banners IS 'Homepage banners and promotional slides';

CREATE INDEX idx_banners_position ON banners(position);
CREATE INDEX idx_banners_active ON banners(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_banners_sort ON banners(position, sort_order);

CREATE TRIGGER trg_banners_updated_at
    BEFORE UPDATE ON banners
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================

CREATE TABLE testimonials (
    id SERIAL PRIMARY KEY,
    customer_name VARCHAR(200) NOT NULL,
    customer_title VARCHAR(200),
    content TEXT NOT NULL,
    rating INTEGER CHECK (rating IS NULL OR (rating >= 1 AND rating <= 5)),
    customer_image_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE testimonials IS 'Customer reviews and testimonials';

CREATE INDEX idx_testimonials_active ON testimonials(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_testimonials_sort ON testimonials(sort_order);

CREATE TRIGGER trg_testimonials_updated_at
    BEFORE UPDATE ON testimonials
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================

CREATE TABLE faqs (
    id SERIAL PRIMARY KEY,
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    category VARCHAR(100),
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE faqs IS 'Frequently asked questions';

CREATE INDEX idx_faqs_category ON faqs(category);
CREATE INDEX idx_faqs_active ON faqs(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_faqs_sort ON faqs(sort_order);
CREATE INDEX idx_faqs_search ON faqs USING gin (question gin_trgm_ops);

CREATE TRIGGER trg_faqs_updated_at
    BEFORE UPDATE ON faqs
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 9. INVENTORY TABLES
-- ============================================================================

CREATE TABLE suppliers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    contact_person VARCHAR(200),
    email VARCHAR(255),
    phone VARCHAR(20),
    address TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

COMMENT ON TABLE suppliers IS 'Ingredient and material suppliers';

CREATE INDEX idx_suppliers_active ON suppliers(is_active) WHERE is_active = TRUE;

CREATE TRIGGER trg_suppliers_updated_at
    BEFORE UPDATE ON suppliers
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================

CREATE TABLE ingredients (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    sku VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    quantity_in_stock DECIMAL(10, 3) NOT NULL DEFAULT 0.000,
    unit_of_measure VARCHAR(20) NOT NULL DEFAULT 'kg',
    reorder_level DECIMAL(10, 3) NOT NULL DEFAULT 10.000,
    reorder_quantity DECIMAL(10, 3) NOT NULL DEFAULT 50.000,
    default_supplier_id INTEGER REFERENCES suppliers(id) ON DELETE SET NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'inStock',
    expiry_date DATE,
    batch_number VARCHAR(100),
    unit_cost DECIMAL(10, 2),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT chk_ingredient_status CHECK (status IN ('inStock', 'lowStock', 'critical', 'outOfStock')),
    CONSTRAINT chk_ingredient_stock CHECK (quantity_in_stock >= 0)
);

COMMENT ON TABLE ingredients IS 'Raw ingredients for bakery products';

CREATE INDEX idx_ingredients_sku ON ingredients(sku);
CREATE INDEX idx_ingredients_status ON ingredients(status);
CREATE INDEX idx_ingredients_supplier ON ingredients(default_supplier_id);
CREATE INDEX idx_ingredients_expiry ON ingredients(expiry_date);
CREATE INDEX idx_ingredients_low_stock ON ingredients(status) WHERE status IN ('lowStock', 'critical');

CREATE TRIGGER trg_ingredients_updated_at
    BEFORE UPDATE ON ingredients
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================

CREATE TABLE purchase_orders (
    id SERIAL PRIMARY KEY,
    supplier_id INTEGER NOT NULL REFERENCES suppliers(id) ON DELETE RESTRICT,
    created_by_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    status VARCHAR(20) NOT NULL DEFAULT 'draft',
    subtotal DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    tax_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    total DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    expected_delivery_date DATE,
    received_at TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_po_status CHECK (status IN ('draft', 'sent', 'confirmed', 'received', 'cancelled'))
);

COMMENT ON TABLE purchase_orders IS 'Orders placed with suppliers';

CREATE INDEX idx_purchase_orders_number ON purchase_orders(order_number);
CREATE INDEX idx_purchase_orders_supplier ON purchase_orders(supplier_id);
CREATE INDEX idx_purchase_orders_status ON purchase_orders(status);

CREATE TRIGGER trg_purchase_orders_updated_at
    BEFORE UPDATE ON purchase_orders
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================

CREATE TABLE purchase_order_items (
    id SERIAL PRIMARY KEY,
    purchase_order_id INTEGER NOT NULL REFERENCES purchase_orders(id) ON DELETE CASCADE,
    ingredient_id INTEGER NOT NULL REFERENCES ingredients(id) ON DELETE RESTRICT,
    quantity DECIMAL(10, 3) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    received_quantity DECIMAL(10, 3) NOT NULL DEFAULT 0.000,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_poi_quantity CHECK (quantity > 0),
    CONSTRAINT chk_poi_price CHECK (unit_price >= 0)
);

COMMENT ON TABLE purchase_order_items IS 'Items in a purchase order';

CREATE INDEX idx_poi_po ON purchase_order_items(purchase_order_id);
CREATE INDEX idx_poi_ingredient ON purchase_order_items(ingredient_id);

CREATE TRIGGER trg_purchase_order_items_updated_at
    BEFORE UPDATE ON purchase_order_items
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================

CREATE TABLE inventory_logs (
    id SERIAL PRIMARY KEY,
    ingredient_id INTEGER NOT NULL REFERENCES ingredients(id) ON DELETE RESTRICT,
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    change_type VARCHAR(20) NOT NULL,
    quantity_change DECIMAL(10, 3) NOT NULL,
    previous_quantity DECIMAL(10, 3) NOT NULL,
    new_quantity DECIMAL(10, 3) NOT NULL,
    reference_type VARCHAR(50),
    reference_id INTEGER,
    reason TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_il_type CHECK (change_type IN ('purchase', 'usage', 'adjustment', 'waste', 'return'))
);

COMMENT ON TABLE inventory_logs IS 'Audit trail of inventory changes';

CREATE INDEX idx_inventory_logs_ingredient ON inventory_logs(ingredient_id);
CREATE INDEX idx_inventory_logs_type ON inventory_logs(change_type);
CREATE INDEX idx_inventory_logs_created ON inventory_logs(created_at DESC);

-- ============================================================================
-- 10. AUDIT & SECURITY TABLES
-- ============================================================================

CREATE TABLE audit_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    user_role VARCHAR(20),
    ip_address INET,
    user_agent TEXT,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100) NOT NULL,
    entity_id INTEGER,
    old_values JSONB,
    new_values JSONB,
    metadata JSONB,
    success BOOLEAN NOT NULL DEFAULT TRUE,
    failure_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE audit_logs IS 'Security and compliance audit trail';

CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_created ON audit_logs(created_at DESC);
CREATE INDEX idx_audit_logs_success ON audit_logs(success);

-- Partition audit_logs by month for performance
-- (In production, implement table partitioning)

-- ============================================================================

CREATE TABLE staff_members (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    employee_id VARCHAR(50) NOT NULL UNIQUE,
    department VARCHAR(100),
    position VARCHAR(100),
    hire_date DATE,
    termination_date DATE,
    salary DECIMAL(10, 2),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_staff_dates CHECK (termination_date IS NULL OR termination_date >= hire_date)
);

COMMENT ON TABLE staff_members IS 'Extended profile for staff users';

CREATE INDEX idx_staff_members_user ON staff_members(user_id);
CREATE INDEX idx_staff_members_employee ON staff_members(employee_id);
CREATE INDEX idx_staff_members_active ON staff_members(is_active) WHERE is_active = TRUE;

CREATE TRIGGER trg_staff_members_updated_at
    BEFORE UPDATE ON staff_members
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- VIEWS FOR REPORTING
-- ============================================================================

CREATE VIEW daily_revenue AS
SELECT 
    DATE(created_at) as date,
    COUNT(*) as order_count,
    SUM(total) as total_revenue,
    SUM(discount_amount) as total_discounts,
    SUM(tax_amount) as total_tax,
    SUM(delivery_charge) as total_delivery
FROM orders
WHERE status NOT IN ('cancelled')
GROUP BY DATE(created_at)
ORDER BY date DESC;

CREATE VIEW low_stock_products AS
SELECT 
    p.*,
    c.name as category_name
FROM products p
JOIN categories c ON p.category_id = c.id
WHERE p.track_inventory = TRUE 
  AND p.quantity_in_stock <= p.low_stock_threshold
  AND p.deleted_at IS NULL;

CREATE VIEW low_stock_ingredients AS
SELECT 
    i.*,
    s.name as supplier_name
FROM ingredients i
LEFT JOIN suppliers s ON i.default_supplier_id = s.id
WHERE i.status IN ('lowStock', 'critical')
  AND i.deleted_at IS NULL;

-- ============================================================================
-- SEED DATA
-- ============================================================================

-- Default admin user (password: Admin@2024! - change immediately)
-- Password hash is a placeholder - use Argon2id in production
INSERT INTO users (email, password_hash, first_name, last_name, role, is_email_verified, is_active)
VALUES ('admin@melinabakes.com', 'PLACEHOLDER_HASH_CHANGE_IMMEDIATELY', 'System', 'Administrator', 'admin', TRUE, TRUE);

-- Default categories
INSERT INTO categories (name, slug, description, sort_order, is_active, is_featured) VALUES
('Cakes', 'cakes', 'Delicious handcrafted cakes for all occasions', 1, TRUE, TRUE),
('Pastries', 'pastries', 'Fresh baked pastries daily', 2, TRUE, TRUE),
('Bread', 'bread', 'Artisan breads baked fresh', 3, TRUE, FALSE),
('Cookies', 'cookies', 'Homemade cookies and biscuits', 4, TRUE, FALSE),
('Specialty', 'specialty', 'Special occasion and custom items', 5, TRUE, TRUE);

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================

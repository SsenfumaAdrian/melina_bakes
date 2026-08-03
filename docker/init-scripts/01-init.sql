-- Melina Bakes — Database Initialization Script
-- Runs on first Docker container start when data directory is empty.
-- Creates the dev database if it does not exist (handled by POSTGRES_DB env var).
-- Seeds initial data for development and testing.

-- ============================================================
-- SEED DATA — Categories
-- ============================================================
INSERT INTO category (name, slug, description, imageUrl, sortOrder, isActive, createdAt, updatedAt)
VALUES
  ('Cakes', 'cakes', 'Celebration cakes for every occasion', 'assets/images/categories/cakes.jpg', 1, true, NOW(), NOW()),
  ('Pastries', 'pastries', 'Freshly baked croissants, danish, and more', 'assets/images/categories/pastries.jpg', 2, true, NOW(), NOW()),
  ('Breads', 'breads', 'Artisan breads baked fresh daily', 'assets/images/categories.jpg', 3, true, NOW(), NOW()),
  ('Cookies', 'cookies', 'Chewy, classic homemade cookies', 'assets/images/categories.jpg', 4, true, NOW(), NOW()),
  ('Cupcakes', 'cupcakes', 'Individual sweet treats', 'assets/images/categories.jpg', 5, true, NOW(), NOW()),
  ('Pies', 'pies', 'Fruit pies and savory pies', 'assets/images/categories.jpg', 6, true, NOW(), NOW()),
  ('Specialty', 'specialty', 'Custom orders and seasonal specialties', 'assets/images/categories.jpg', 7, true, NOW(), NOW())
ON CONFLICT DO NOTHING;

-- ============================================================
-- SEED DATA — Admin User (mock, for testing)
-- Password: admin123  (change in production)
-- ============================================================
-- INSERT INTO users (email, firstName, lastName, role, isEmailVerified, createdAt, updatedAt)
-- VALUES ('admin@melinabakes.com', 'Admin', 'User', 'admin', true, NOW(), NOW())
-- ON CONFLICT DO NOTHING;
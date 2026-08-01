
/// Domain entity representing a bakery product.
///
/// Decoupled from data models. Used throughout the presentation layer.
library;

import 'package:equatable/equatable.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';

class ProductEntity extends Equatable {
  final int id;
  final String name;
  final String slug;
  final String sku;
  final String? description;
  final String? shortDescription;
  final double basePrice;
  final double? salePrice;
  final ProductStatus status;
  final bool isFeatured;
  final bool isNew;
  final String? primaryImageUrl;
  final List<String> imageUrls;
  final String? categoryName;
  final String? categorySlug;
  final int quantityInStock;
  final double? rating;
  final int? reviewCount;
  final String? allergens;
  final String? ingredients;
  final double? weightGrams;
  final Map<String, dynamic>? attributes;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.slug,
    required this.sku,
    this.description,
    this.shortDescription,
    required this.basePrice,
    this.salePrice,
    this.status = ProductStatus.available,
    this.isFeatured = false,
    this.isNew = false,
    this.primaryImageUrl,
    this.imageUrls = const [],
    this.categoryName,
    this.categorySlug,
    this.quantityInStock = 0,
    this.rating,
    this.reviewCount,
    this.allergens,
    this.ingredients,
    this.weightGrams,
    this.attributes,
  });

  /// Returns the effective price (sale price if available, otherwise base).
  double get price => salePrice ?? basePrice;

  /// Returns true if the product is on sale.
  bool get isOnSale => salePrice != null && salePrice! < basePrice;

  /// Returns the discount percentage (0 if not on sale).
  int get discountPercent {
    if (!isOnSale) return 0;
    return (((basePrice - salePrice!) / basePrice) * 100).round();
  }

  /// Returns true if the product is in stock.
  bool get inStock => quantityInStock > 0 && status == ProductStatus.available;

  @override
  List<Object?> get props => [
        id, name, slug, sku, description, shortDescription, basePrice, salePrice,
        status, isFeatured, isNew, primaryImageUrl, imageUrls, categoryName,
        categorySlug, quantityInStock, rating, reviewCount, allergens,
        ingredients, weightGrams, attributes,
      ];
}

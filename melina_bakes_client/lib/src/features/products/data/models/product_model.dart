
/// Data model for product serialization.
library;

import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../domain/entities/product_entity.dart';

class ProductModel {
  final int id;
  final String name;
  final String slug;
  final String sku;
  final String? description;
  final String? shortDescription;
  final double basePrice;
  final double? salePrice;
  final String status;
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

  ProductModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.sku,
    this.description,
    this.shortDescription,
    required this.basePrice,
    this.salePrice,
    this.status = 'available',
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

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      description: json['description'] as String?,
      shortDescription: json['shortDescription'] as String?,
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
      salePrice: (json['salePrice'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'available',
      isFeatured: json['isFeatured'] as bool? ?? false,
      isNew: json['isNew'] as bool? ?? false,
      primaryImageUrl: json['primaryImageUrl'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [],
      categoryName: json['categoryName'] as String? ?? (json['category']?['name'] as String?),
      categorySlug: json['categorySlug'] as String? ?? (json['category']?['slug'] as String?),
      quantityInStock: json['quantityInStock'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['reviewCount'] as int?,
      allergens: json['allergens'] as String?,
      ingredients: json['ingredients'] as String?,
      weightGrams: (json['weightGrams'] as num?)?.toDouble(),
      attributes: json['attributes'] as Map<String, dynamic>?,
    );
  }

  ProductEntity toEntity() => ProductEntity(
    id: id, name: name, slug: slug, sku: sku, description: description,
    shortDescription: shortDescription, basePrice: basePrice, salePrice: salePrice,
    status: ProductStatus.values.byName(status), isFeatured: isFeatured, isNew: isNew,
    primaryImageUrl: primaryImageUrl, imageUrls: imageUrls, categoryName: categoryName,
    categorySlug: categorySlug, quantityInStock: quantityInStock, rating: rating,
    reviewCount: reviewCount, allergens: allergens, ingredients: ingredients,
    weightGrams: weightGrams, attributes: attributes,
  );
}

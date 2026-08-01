
/// Data model for category serialization.
library;

import '../../domain/entities/category_entity.dart';

class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? imageUrl;
  final int? parentId;
  final int sortOrder;
  final bool isFeatured;
  final int productCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.imageUrl,
    this.parentId,
    this.sortOrder = 0,
    this.isFeatured = false,
    this.productCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      parentId: json['parentId'] as int?,
      sortOrder: json['sortOrder'] as int? ?? 0,
      isFeatured: json['isFeatured'] as bool? ?? false,
      productCount: json['productCount'] as int? ?? 0,
    );
  }

  CategoryEntity toEntity() => CategoryEntity(
    id: id, name: name, slug: slug, description: description,
    imageUrl: imageUrl, parentId: parentId, sortOrder: sortOrder,
    isFeatured: isFeatured, productCount: productCount,
  );
}

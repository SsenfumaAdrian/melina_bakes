
/// Domain entity representing a product category.
library;

import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? imageUrl;
  final int? parentId;
  final int sortOrder;
  final bool isFeatured;
  final int productCount;

  const CategoryEntity({
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

  @override
  List<Object?> get props => [id, name, slug, description, imageUrl, parentId, sortOrder, isFeatured, productCount];
}

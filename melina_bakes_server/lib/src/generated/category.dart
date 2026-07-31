/// GENERATED CODE - DO NOT MODIFY BY HAND
/// Generated from protocol/category.yaml

// ignore_for_file: public_member_api_docs

import 'package:serverpod/serverpod.dart';

class Category extends TableRow {
  @override
  String get tableName => 'categories';

  int? id;
  int? parentId;
  String name;
  String slug;
  String? description;
  String? imageUrl;
  String? iconUrl;
  int sortOrder;
  bool isActive;
  bool isFeatured;
  String? metaTitle;
  String? metaDescription;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  Category({
    this.id,
    this.parentId,
    required this.name,
    required this.slug,
    this.description,
    this.imageUrl,
    this.iconUrl,
    this.sortOrder = 0,
    this.isActive = true,
    this.isFeatured = false,
    this.metaTitle,
    this.metaDescription,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'parentId': parentId,
        'name': name,
        'slug': slug,
        'description': description,
        'imageUrl': imageUrl,
        'iconUrl': iconUrl,
        'sortOrder': sortOrder,
        'isActive': isActive,
        'isFeatured': isFeatured,
        'metaTitle': metaTitle,
        'metaDescription': metaDescription,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as int?,
        parentId: json['parentId'] as int?,
        name: json['name'] as String,
        slug: json['slug'] as String,
        description: json['description'] as String?,
        imageUrl: json['imageUrl'] as String?,
        iconUrl: json['iconUrl'] as String?,
        sortOrder: json['sortOrder'] as int? ?? 0,
        isActive: json['isActive'] as bool? ?? true,
        isFeatured: json['isFeatured'] as bool? ?? false,
        metaTitle: json['metaTitle'] as String?,
        metaDescription: json['metaDescription'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        deletedAt: json['deletedAt'] != null
            ? DateTime.parse(json['deletedAt'] as String)
            : null,
      );

  @override
  String toString() => 'Category(id: \$id, name: \$name, slug: \$slug)';
}

class CategoryTable extends Table {
  CategoryTable() : super(tableName: 'categories');

  final parentId = ColumnInt('parent_id');
  final name = ColumnString('name');
  final slug = ColumnString('slug');
  final description = ColumnString('description');
  final imageUrl = ColumnString('image_url');
  final iconUrl = ColumnString('icon_url');
  final sortOrder = ColumnInt('sort_order');
  final isActive = ColumnBool('is_active');
  final isFeatured = ColumnBool('is_featured');
  final metaTitle = ColumnString('meta_title');
  final metaDescription = ColumnString('meta_description');
  final createdAt = ColumnDateTime('created_at');
  final updatedAt = ColumnDateTime('updated_at');
  final deletedAt = ColumnDateTime('deleted_at');

  @override
  List<Column> get columns => [
        parentId, name, slug, description, imageUrl, iconUrl,
        sortOrder, isActive, isFeatured, metaTitle, metaDescription,
        createdAt, updatedAt, deletedAt,
      ];
}

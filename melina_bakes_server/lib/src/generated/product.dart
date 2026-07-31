/// GENERATED CODE - DO NOT MODIFY BY HAND
/// Generated from protocol/product.yaml

// ignore_for_file: public_member_api_docs

import 'package:serverpod/serverpod.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';

class Product extends TableRow {
  @override
  String get tableName => 'products';

  int? id;
  int categoryId;
  String name;
  String slug;
  String sku;
  String? description;
  String? shortDescription;
  double basePrice;
  double? salePrice;
  double? costPrice;
  int quantityInStock;
  int lowStockThreshold;
  bool trackInventory;
  ProductStatus status;
  bool isFeatured;
  bool isNew;
  String? primaryImageUrl;
  String? metaTitle;
  String? metaDescription;
  Map<String, dynamic>? attributes;
  double? weightGrams;
  String? allergens;
  String? ingredients;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  Product({
    this.id,
    required this.categoryId,
    required this.name,
    required this.slug,
    required this.sku,
    this.description,
    this.shortDescription,
    required this.basePrice,
    this.salePrice,
    this.costPrice,
    this.quantityInStock = 0,
    this.lowStockThreshold = 10,
    this.trackInventory = true,
    this.status = ProductStatus.available,
    this.isFeatured = false,
    this.isNew = true,
    this.primaryImageUrl,
    this.metaTitle,
    this.metaDescription,
    this.attributes,
    this.weightGrams,
    this.allergens,
    this.ingredients,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'name': name,
        'slug': slug,
        'sku': sku,
        'description': description,
        'shortDescription': shortDescription,
        'basePrice': basePrice,
        'salePrice': salePrice,
        'costPrice': costPrice,
        'quantityInStock': quantityInStock,
        'lowStockThreshold': lowStockThreshold,
        'trackInventory': trackInventory,
        'status': status.name,
        'isFeatured': isFeatured,
        'isNew': isNew,
        'primaryImageUrl': primaryImageUrl,
        'metaTitle': metaTitle,
        'metaDescription': metaDescription,
        'attributes': attributes,
        'weightGrams': weightGrams,
        'allergens': allergens,
        'ingredients': ingredients,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as int?,
        categoryId: json['categoryId'] as int,
        name: json['name'] as String,
        slug: json['slug'] as String,
        sku: json['sku'] as String,
        description: json['description'] as String?,
        shortDescription: json['shortDescription'] as String?,
        basePrice: (json['basePrice'] as num).toDouble(),
        salePrice: json['salePrice'] != null
            ? (json['salePrice'] as num).toDouble()
            : null,
        costPrice: json['costPrice'] != null
            ? (json['costPrice'] as num).toDouble()
            : null,
        quantityInStock: json['quantityInStock'] as int? ?? 0,
        lowStockThreshold: json['lowStockThreshold'] as int? ?? 10,
        trackInventory: json['trackInventory'] as bool? ?? true,
        status: ProductStatus.values.byName(json['status'] as String),
        isFeatured: json['isFeatured'] as bool? ?? false,
        isNew: json['isNew'] as bool? ?? true,
        primaryImageUrl: json['primaryImageUrl'] as String?,
        metaTitle: json['metaTitle'] as String?,
        metaDescription: json['metaDescription'] as String?,
        attributes: json['attributes'] as Map<String, dynamic>?,
        weightGrams: json['weightGrams'] != null
            ? (json['weightGrams'] as num).toDouble()
            : null,
        allergens: json['allergens'] as String?,
        ingredients: json['ingredients'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        deletedAt: json['deletedAt'] != null
            ? DateTime.parse(json['deletedAt'] as String)
            : null,
      );

  /// Returns the effective price (sale price if available, otherwise base).
  double get currentPrice => salePrice ?? basePrice;

  /// Returns true if the product is on sale.
  bool get isOnSale => salePrice != null && salePrice! < basePrice;

  /// Returns the discount percentage if on sale.
  double? get discountPercentage {
    if (!isOnSale) return null;
    return ((basePrice - salePrice!) / basePrice * 100).roundToDouble();
  }

  /// Returns true if stock is low.
  bool get isLowStock =>
      trackInventory && quantityInStock <= lowStockThreshold;

  /// Returns true if out of stock.
  bool get isOutOfStock =>
      trackInventory && quantityInStock <= 0;

  @override
  String toString() =>
      'Product(id: \$id, name: \$name, sku: \$sku, price: \$basePrice)';
}

class ProductTable extends Table {
  ProductTable() : super(tableName: 'products');

  final categoryId = ColumnInt('category_id');
  final name = ColumnString('name');
  final slug = ColumnString('slug');
  final sku = ColumnString('sku');
  final description = ColumnString('description');
  final shortDescription = ColumnString('short_description');
  final basePrice = ColumnDouble('base_price');
  final salePrice = ColumnDouble('sale_price');
  final costPrice = ColumnDouble('cost_price');
  final quantityInStock = ColumnInt('quantity_in_stock');
  final lowStockThreshold = ColumnInt('low_stock_threshold');
  final trackInventory = ColumnBool('track_inventory');
  final status = ColumnString('status');
  final isFeatured = ColumnBool('is_featured');
  final isNew = ColumnBool('is_new');
  final primaryImageUrl = ColumnString('primary_image_url');
  final metaTitle = ColumnString('meta_title');
  final metaDescription = ColumnString('meta_description');
  final attributes = ColumnSerializable('attributes');
  final weightGrams = ColumnDouble('weight_grams');
  final allergens = ColumnString('allergens');
  final ingredients = ColumnString('ingredients');
  final createdAt = ColumnDateTime('created_at');
  final updatedAt = ColumnDateTime('updated_at');
  final deletedAt = ColumnDateTime('deleted_at');

  @override
  List<Column> get columns => [
        categoryId, name, slug, sku, description, shortDescription,
        basePrice, salePrice, costPrice, quantityInStock,
        lowStockThreshold, trackInventory, status, isFeatured,
        isNew, primaryImageUrl, metaTitle, metaDescription,
        attributes, weightGrams, allergens, ingredients,
        createdAt, updatedAt, deletedAt,
      ];
}

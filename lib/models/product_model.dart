import 'package:sultan_app/models/product_option_group_model.dart';

class ProductModel {
  const ProductModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.isAvailable = true,
    this.optionGroups = const [],
  });
  final int id;
  final int categoryId;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final List<ProductOptionGroupModel> optionGroups;

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json['id'] as int,
    categoryId: json['category_id'] as int,
    name: json['name'] as String,
    description: json['description'] as String,
    price: (json['price'] as num).toDouble(),
    imageUrl: json['image_url'] as String?,
    isAvailable: json['is_available'] as bool? ?? true,
    optionGroups: (json['option_groups'] as List<dynamic>? ?? [])
        .map(
          (item) =>
              ProductOptionGroupModel.fromJson(item as Map<String, dynamic>),
        )
        .toList(),
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'category_id': categoryId,
    'name': name,
    'description': description,
    'price': price,
    'image_url': imageUrl,
    'is_available': isAvailable,
    'option_groups': optionGroups.map((item) => item.toJson()).toList(),
  };
}

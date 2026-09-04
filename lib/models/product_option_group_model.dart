import 'package:sultan_app/models/product_option_model.dart';

class ProductOptionGroupModel {
  const ProductOptionGroupModel({
    required this.id,
    required this.name,
    required this.options,
    this.isRequired = false,
    this.allowsMultiple = false,
  });
  final int id;
  final String name;
  final List<ProductOptionModel> options;
  final bool isRequired;
  final bool allowsMultiple;

  factory ProductOptionGroupModel.fromJson(Map<String, dynamic> json) =>
      ProductOptionGroupModel(
        id: json['id'] as int,
        name: json['name'] as String,
        options: (json['options'] as List<dynamic>)
            .map(
              (item) =>
                  ProductOptionModel.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
        isRequired: json['is_required'] as bool? ?? false,
        allowsMultiple: json['allows_multiple'] as bool? ?? false,
      );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'options': options.map((item) => item.toJson()).toList(),
    'is_required': isRequired,
    'allows_multiple': allowsMultiple,
  };
}

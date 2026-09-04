import 'package:sultan_app/models/product_model.dart';
import 'package:sultan_app/models/product_option_model.dart';

class CartItemModel {
  const CartItemModel({
    required this.product,
    required this.quantity,
    this.selectedOptions = const [],
    this.notes,
  });
  final ProductModel product;
  final int quantity;
  final List<ProductOptionModel> selectedOptions;
  final String? notes;

  double get total =>
      quantity *
      (product.price +
          selectedOptions.fold(0, (sum, option) => sum + option.price));
  double get unitPrice =>
      product.price +
      selectedOptions.fold(0, (sum, option) => sum + option.price);

  CartItemModel copyWith({
    ProductModel? product,
    int? quantity,
    List<ProductOptionModel>? selectedOptions,
    String? notes,
  }) => CartItemModel(
    product: product ?? this.product,
    quantity: quantity ?? this.quantity,
    selectedOptions: selectedOptions ?? this.selectedOptions,
    notes: notes ?? this.notes,
  );
  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
    'selected_options': selectedOptions.map((item) => item.toJson()).toList(),
    'notes': notes,
  };
}

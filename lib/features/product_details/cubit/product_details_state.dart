import 'package:sultan_app/models/product_model.dart';
import 'package:sultan_app/models/product_option_model.dart';

enum ProductDetailsStatus { initial, loading, success, failure }

class ProductDetailsState {
  const ProductDetailsState({
    this.status = ProductDetailsStatus.initial,
    this.product,
    this.selectedOptionIds = const {},
    this.quantity = 1,
    this.notes = '',
    this.errorMessage,
  });

  final ProductDetailsStatus status;
  final ProductModel? product;
  final Map<int, Set<int>> selectedOptionIds;
  final int quantity;
  final String notes;
  final String? errorMessage;

  double get totalPrice {
    final currentProduct = product;
    if (currentProduct == null) return 0;
    var optionsPrice = 0.0;
    for (final group in currentProduct.optionGroups) {
      final selected = selectedOptionIds[group.id] ?? const <int>{};
      for (final option in group.options) {
        if (selected.contains(option.id)) optionsPrice += option.price;
      }
    }
    return (currentProduct.price + optionsPrice) * quantity;
  }

  List<ProductOptionModel> get selectedOptions {
    final currentProduct = product;
    if (currentProduct == null) return const [];
    final result = <ProductOptionModel>[];
    for (final group in currentProduct.optionGroups) {
      final selected = selectedOptionIds[group.id] ?? const <int>{};
      result.addAll(
        group.options.where((option) => selected.contains(option.id)),
      );
    }
    return result;
  }

  ProductDetailsState copyWith({
    ProductDetailsStatus? status,
    ProductModel? product,
    Map<int, Set<int>>? selectedOptionIds,
    int? quantity,
    String? notes,
    String? errorMessage,
  }) => ProductDetailsState(
    status: status ?? this.status,
    product: product ?? this.product,
    selectedOptionIds: selectedOptionIds ?? this.selectedOptionIds,
    quantity: quantity ?? this.quantity,
    notes: notes ?? this.notes,
    errorMessage: errorMessage,
  );
}

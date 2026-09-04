import 'package:sultan_app/models/product_model.dart';

enum FavoritesStatus { initial, loading, success, failure }

class FavoritesState {
  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.products = const [],
    this.errorMessage,
  });

  final FavoritesStatus status;
  final List<ProductModel> products;
  final String? errorMessage;

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<ProductModel>? products,
    String? errorMessage,
  }) => FavoritesState(
    status: status ?? this.status,
    products: products ?? this.products,
    errorMessage: errorMessage,
  );
}

import 'package:sultan_app/models/category_model.dart';
import 'package:sultan_app/models/product_model.dart';

enum MenuStatus { initial, loading, success, failure }

class MenuState {
  const MenuState({
    this.status = MenuStatus.initial,
    this.categories = const [],
    this.products = const [],
    this.visibleProducts = const [],
    this.selectedCategoryId,
    this.searchQuery = '',
    this.errorMessage,
  });

  final MenuStatus status;
  final List<CategoryModel> categories;
  final List<ProductModel> products;
  final List<ProductModel> visibleProducts;
  final int? selectedCategoryId;
  final String searchQuery;
  final String? errorMessage;

  MenuState copyWith({
    MenuStatus? status,
    List<CategoryModel>? categories,
    List<ProductModel>? products,
    List<ProductModel>? visibleProducts,
    int? selectedCategoryId,
    bool clearCategory = false,
    String? searchQuery,
    String? errorMessage,
  }) => MenuState(
    status: status ?? this.status,
    categories: categories ?? this.categories,
    products: products ?? this.products,
    visibleProducts: visibleProducts ?? this.visibleProducts,
    selectedCategoryId: clearCategory
        ? null
        : selectedCategoryId ?? this.selectedCategoryId,
    searchQuery: searchQuery ?? this.searchQuery,
    errorMessage: errorMessage,
  );
}

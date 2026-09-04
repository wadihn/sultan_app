import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/data/repositories/product_repository.dart';
import 'package:sultan_app/features/menu/cubit/menu_state.dart';

class MenuCubit extends Cubit<MenuState> {
  MenuCubit(this._repository) : super(const MenuState());
  final ProductRepository _repository;

  Future<void> loadMenu({int? selectedCategoryId}) async {
    emit(state.copyWith(status: MenuStatus.loading));
    try {
      final categories = await _repository.getCategories();
      final products = await _repository.getProducts();
      emit(
        state.copyWith(
          status: MenuStatus.success,
          categories: categories,
          products: products,
          selectedCategoryId: selectedCategoryId,
          clearCategory: selectedCategoryId == null,
        ),
      );
      _applyFilters();
    } catch (_) {
      emit(
        state.copyWith(
          status: MenuStatus.failure,
          errorMessage: 'تعذر تحميل المنيو',
        ),
      );
    }
  }

  void selectCategory(int? categoryId) {
    emit(
      state.copyWith(
        selectedCategoryId: categoryId,
        clearCategory: categoryId == null,
      ),
    );
    _applyFilters();
  }

  void search(String value) {
    emit(state.copyWith(searchQuery: value.trim()));
    _applyFilters();
  }

  void _applyFilters() {
    final normalizedQuery = state.searchQuery.toLowerCase();
    final filtered = state.products.where((product) {
      final matchesCategory =
          state.selectedCategoryId == null ||
          product.categoryId == state.selectedCategoryId;
      final matchesSearch =
          normalizedQuery.isEmpty ||
          product.name.toLowerCase().contains(normalizedQuery);
      return matchesCategory && matchesSearch;
    }).toList();
    emit(state.copyWith(visibleProducts: filtered));
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/data/repositories/favorites_repository.dart';
import 'package:sultan_app/features/favorites/cubit/favorites_state.dart';
import 'package:sultan_app/models/product_model.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(this._repository) : super(const FavoritesState());

  final FavoritesRepository _repository;

  Future<void> loadFavorites() async {
    emit(state.copyWith(status: FavoritesStatus.loading));
    await _refreshFavorites();
  }

  Future<void> addFavorite(ProductModel product) async {
    try {
      await _repository.addFavorite(product);
      await _refreshFavorites();
    } catch (_) {
      _emitFailure();
    }
  }

  Future<void> removeFavorite(int productId) async {
    try {
      await _repository.removeFavorite(productId);
      await _refreshFavorites();
    } catch (_) {
      _emitFailure();
    }
  }

  Future<void> toggleFavorite(ProductModel product) async {
    if (isFavorite(product.id)) {
      await removeFavorite(product.id);
    } else {
      await addFavorite(product);
    }
  }

  bool isFavorite(int productId) =>
      state.products.any((product) => product.id == productId);

  Future<void> _refreshFavorites() async {
    try {
      final products = await _repository.getFavorites();
      emit(FavoritesState(status: FavoritesStatus.success, products: products));
    } catch (_) {
      _emitFailure();
    }
  }

  void _emitFailure() {
    emit(
      state.copyWith(
        status: FavoritesStatus.failure,
        errorMessage: 'تعذر تحميل المنتجات المفضلة',
      ),
    );
  }
}

import 'package:sultan_app/data/dummy/dummy_data.dart';
import 'package:sultan_app/models/product_model.dart';

abstract interface class FavoritesRepository {
  Future<List<ProductModel>> getFavorites();

  Future<void> addFavorite(ProductModel product);

  Future<void> removeFavorite(int productId);
}

class DummyFavoritesRepository implements FavoritesRepository {
  DummyFavoritesRepository()
    : _favorites = [
        for (final product in DummyData.products)
          if (DummyData.favoriteProductIds.contains(product.id)) product,
      ];

  final List<ProductModel> _favorites;

  @override
  Future<List<ProductModel>> getFavorites() async =>
      List<ProductModel>.unmodifiable(_favorites);

  @override
  Future<void> addFavorite(ProductModel product) async {
    if (_favorites.any((item) => item.id == product.id)) return;
    _favorites.add(product);
  }

  @override
  Future<void> removeFavorite(int productId) async {
    _favorites.removeWhere((product) => product.id == productId);
  }
}

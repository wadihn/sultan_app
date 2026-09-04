import 'package:flutter_test/flutter_test.dart';
import 'package:sultan_app/data/repositories/favorites_repository.dart';
import 'package:sultan_app/features/favorites/cubit/favorites_cubit.dart';
import 'package:sultan_app/features/favorites/cubit/favorites_state.dart';
import 'package:sultan_app/models/product_model.dart';

void main() {
  test('FavoritesCubit يحمل ويضيف ويزيل المنتجات', () async {
    final cubit = FavoritesCubit(DummyFavoritesRepository());
    addTearDown(cubit.close);

    await cubit.loadFavorites();
    expect(cubit.state.status, FavoritesStatus.success);
    expect(cubit.isFavorite(1), isTrue);

    const product = ProductModel(
      id: 99,
      categoryId: 1,
      name: 'منتج تجريبي',
      description: 'وصف',
      price: 1,
    );
    await cubit.addFavorite(product);
    expect(cubit.isFavorite(product.id), isTrue);

    await cubit.removeFavorite(product.id);
    expect(cubit.isFavorite(product.id), isFalse);
  });
}

import 'package:sultan_app/data/dummy/dummy_data.dart';
import 'package:sultan_app/models/category_model.dart';
import 'package:sultan_app/models/product_model.dart';

abstract interface class ProductRepository {
  /// Catalog data used by Menu and Product Details features.
  Future<List<CategoryModel>> getCategories();
  Future<List<ProductModel>> getProducts();
  Future<ProductModel?> getProductById(int id);
}

class DummyProductRepository implements ProductRepository {
  @override
  Future<List<CategoryModel>> getCategories() async => DummyData.categories;

  @override
  Future<List<ProductModel>> getProducts() async => DummyData.products;

  @override
  Future<ProductModel?> getProductById(int id) async {
    for (final product in DummyData.products) {
      if (product.id == id) return product;
    }
    return null;
  }
}

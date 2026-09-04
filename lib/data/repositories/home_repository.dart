import 'package:sultan_app/data/dummy/dummy_data.dart';
import 'package:sultan_app/models/cafe_info_model.dart';
import 'package:sultan_app/models/category_model.dart';
import 'package:sultan_app/models/offer_model.dart';
import 'package:sultan_app/models/product_model.dart';

abstract interface class HomeRepository {
  /// Home-specific content and cafe operational information.
  Future<CafeInfoModel> getCafeInfo();
  Future<List<CategoryModel>> getCategories();
  Future<List<OfferModel>> getOffers();
  Future<List<ProductModel>> getPopularProducts();
}

class DummyHomeRepository implements HomeRepository {
  @override
  Future<CafeInfoModel> getCafeInfo() async => DummyData.cafeInfo;

  @override
  Future<List<CategoryModel>> getCategories() async => DummyData.categories;

  @override
  Future<List<OfferModel>> getOffers() async => DummyData.offers;

  @override
  // Dummy-only popularity rule. Laravel can replace it through this contract.
  Future<List<ProductModel>> getPopularProducts() async => DummyData.products
      .where((product) => product.isAvailable)
      .take(4)
      .toList();
}

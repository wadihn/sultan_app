import 'package:sultan_app/models/cafe_info_model.dart';
import 'package:sultan_app/models/category_model.dart';
import 'package:sultan_app/models/offer_model.dart';
import 'package:sultan_app/models/product_model.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState {
  const HomeState({
    this.status = HomeStatus.initial,
    this.cafeInfo,
    this.isCafeOpen,
    this.categories = const [],
    this.offers = const [],
    this.popularProducts = const [],
    this.errorMessage,
  });

  final HomeStatus status;
  final CafeInfoModel? cafeInfo;
  final bool? isCafeOpen;
  final List<CategoryModel> categories;
  final List<OfferModel> offers;
  final List<ProductModel> popularProducts;
  final String? errorMessage;

  HomeState copyWith({
    HomeStatus? status,
    CafeInfoModel? cafeInfo,
    bool? isCafeOpen,
    List<CategoryModel>? categories,
    List<OfferModel>? offers,
    List<ProductModel>? popularProducts,
    String? errorMessage,
  }) => HomeState(
    status: status ?? this.status,
    cafeInfo: cafeInfo ?? this.cafeInfo,
    isCafeOpen: isCafeOpen ?? this.isCafeOpen,
    categories: categories ?? this.categories,
    offers: offers ?? this.offers,
    popularProducts: popularProducts ?? this.popularProducts,
    errorMessage: errorMessage,
  );
}

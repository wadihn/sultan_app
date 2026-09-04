import 'package:sultan_app/core/network/api_interceptor.dart';
import 'package:sultan_app/core/network/dio_client.dart';
import 'package:sultan_app/core/storage/secure_storage_service.dart';
import 'package:sultan_app/data/repositories/auth_repository.dart';
import 'package:sultan_app/data/repositories/address_repository.dart';
import 'package:sultan_app/data/repositories/checkout_repository.dart';
import 'package:sultan_app/data/repositories/favorites_repository.dart';
import 'package:sultan_app/data/repositories/home_repository.dart';
import 'package:sultan_app/data/repositories/product_repository.dart';
import 'package:sultan_app/data/repositories/profile_repository.dart';
import 'package:sultan_app/data/services/auth_service.dart';
import 'package:sultan_app/data/services/address_service.dart';
import 'package:sultan_app/data/services/catalog_service.dart';
import 'package:sultan_app/data/services/orders_service.dart';
import 'package:sultan_app/data/services/profile_service.dart';
import 'package:sultan_app/data/repositories/orders_repository.dart';

/// App-scoped composition root. Change implementation selection here for Laravel.
/// The creator owns this container; providers only borrow its instances.
class AppDependencies {
  AppDependencies({
    SecureStorageService? secureStorage,
    AuthRepository? authRepository,
    AddressRepository? addressRepository,
    HomeRepository? homeRepository,
    ProductRepository? productRepository,
    CheckoutRepository? checkoutRepository,
    FavoritesRepository? favoritesRepository,
    OrdersRepository? ordersRepository,
    ProfileRepository? profileRepository,
  }) : secureStorage = secureStorage ?? SecureStorageService() {
    apiInterceptor = ApiInterceptor(this.secureStorage);
    dioClient = DioClient(apiInterceptor);
    authService = AuthService(dioClient.dio);
    addressService = AddressService(dioClient.dio);
    catalogService = CatalogService(dioClient.dio);
    ordersService = OrdersService(dioClient.dio);
    profileService = ProfileService(dioClient.dio);
    this.ordersRepository = ordersRepository ?? DummyOrdersRepository();
    // Dummy repositories do not use the remote services or issue HTTP requests.
    this.authRepository =
        authRepository ?? DummyAuthRepository(this.secureStorage);
    this.profileRepository =
        profileRepository ?? DummyProfileRepository(this.authRepository);
    this.homeRepository = homeRepository ?? DummyHomeRepository();
    this.productRepository = productRepository ?? DummyProductRepository();
    this.addressRepository = addressRepository ?? DummyAddressRepository();
    this.checkoutRepository =
        checkoutRepository ??
        DummyCheckoutRepository(addressRepository: this.addressRepository);
    this.favoritesRepository =
        favoritesRepository ?? DummyFavoritesRepository();
  }

  final SecureStorageService secureStorage;
  late final ApiInterceptor apiInterceptor;
  late final DioClient dioClient;
  late final AuthService authService;
  late final AddressService addressService;
  late final CatalogService catalogService;
  late final OrdersService ordersService;
  late final ProfileService profileService;
  late final OrdersRepository ordersRepository;
  late final AuthRepository authRepository;
  late final ProfileRepository profileRepository;
  late final HomeRepository homeRepository;
  late final ProductRepository productRepository;
  late final AddressRepository addressRepository;
  late final CheckoutRepository checkoutRepository;
  late final FavoritesRepository favoritesRepository;

  void dispose() => dioClient.dio.close();
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sultan_app/app/app.dart';
import 'package:sultan_app/app/app_dependencies.dart';
import 'package:sultan_app/app/routes.dart';
import 'package:sultan_app/data/dummy/dummy_data.dart';
import 'package:sultan_app/data/repositories/auth_repository.dart';
import 'package:sultan_app/data/repositories/home_repository.dart';
import 'package:sultan_app/data/repositories/product_repository.dart';
import 'package:sultan_app/features/auth/cubit/auth_cubit.dart';
import 'package:sultan_app/features/auth/screens/login_screen.dart';
import 'package:sultan_app/features/cart/cubit/cart_cubit.dart';
import 'package:sultan_app/features/checkout/cubit/checkout_cubit.dart';
import 'package:sultan_app/features/favorites/cubit/favorites_cubit.dart';
import 'package:sultan_app/features/favorites/screens/favorites_screen.dart';
import 'package:sultan_app/features/menu/cubit/menu_cubit.dart';
import 'package:sultan_app/features/menu/screens/menu_screen.dart';
import 'package:sultan_app/features/product_details/screens/product_details_screen.dart';
import 'package:sultan_app/models/cart_item_model.dart';
import 'package:sultan_app/models/category_model.dart';
import 'package:sultan_app/models/product_model.dart';
import 'package:sultan_app/models/requests/login_request.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test(
    'Container shares Dio/services and allows isolated repository overrides',
    () {
      final products = _Products();
      final dependencies = AppDependencies(productRepository: products);
      final other = AppDependencies();
      addTearDown(dependencies.dispose);
      addTearDown(other.dispose);
      expect(identical(dependencies.productRepository, products), isTrue);
      expect(
        identical(dependencies.authService.client, dependencies.dioClient.dio),
        isTrue,
      );
      expect(
        identical(
          dependencies.catalogService.client,
          dependencies.dioClient.dio,
        ),
        isTrue,
      );
      expect(
        dependencies.dioClient.dio.interceptors,
        contains(dependencies.apiInterceptor),
      );
      expect(
        identical(dependencies.favoritesRepository, other.favoritesRepository),
        isFalse,
      );
    },
  );

  testWidgets(
    'Routes share app state and resolve the injected product repository',
    (tester) async {
      final products = _Products();
      final dependencies = AppDependencies(productRepository: products);
      addTearDown(dependencies.dispose);
      await tester.pumpWidget(SultanApp(dependencies: dependencies));
      await tester.pumpAndSettle();
      final loginContext = tester.element(find.byType(LoginScreen));
      final auth = loginContext.read<AuthCubit>();
      final cart = loginContext.read<CartCubit>();
      final favorites = loginContext.read<FavoritesCubit>();
      final checkout = loginContext.read<CheckoutCubit>();
      await tester.pumpAndSettle();
      expect(
        identical(
          loginContext.read<AuthRepository>(),
          dependencies.authRepository,
        ),
        isTrue,
      );
      expect(
        identical(
          loginContext.read<HomeRepository>(),
          dependencies.homeRepository,
        ),
        isTrue,
      );
      await auth.login(
        const LoginRequest(identity: '0791234567', password: 'password123'),
      );
      final token = await dependencies.secureStorage.readAuthToken();
      cart.addItem(CartItemModel(product: DummyData.products[1], quantity: 2));
      await favorites.addFavorite(DummyData.products[1]);
      Navigator.of(loginContext).pushNamed(AppRoutes.menu);
      await tester.pumpAndSettle();
      var context = tester.element(find.byType(MenuScreen));
      expect(context.read<MenuCubit>().state.products.single.id, 2);
      expect(identical(context.read<CartCubit>(), cart), isTrue);
      Navigator.of(context).pushNamed(AppRoutes.productDetails, arguments: 2);
      await tester.pumpAndSettle();
      context = tester.element(find.byType(ProductDetailsScreen));
      expect(products.requestedId, 2);
      expect(identical(context.read<AuthCubit>(), auth), isTrue);
      expect(identical(context.read<CheckoutCubit>(), checkout), isTrue);
      expect(identical(context.read<FavoritesCubit>(), favorites), isTrue);
      expect(context.read<CartCubit>().state.totalQuantity, 2);
      Navigator.of(context).pushNamed(AppRoutes.favorites);
      await tester.pumpAndSettle();
      context = tester.element(find.byType(FavoritesScreen));
      expect(context.read<FavoritesCubit>().isFavorite(2), isTrue);
      expect(identical(context.read<FavoritesCubit>(), favorites), isTrue);
      expect(await dependencies.secureStorage.readAuthToken(), token);
      expect(await dependencies.authRepository.hasValidSession(), isTrue);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(cart.isClosed, isTrue);
      expect(favorites.isClosed, isTrue);
      expect(auth.isClosed, isTrue);
      expect(checkout.isClosed, isTrue);
    },
  );
}

class _Products implements ProductRepository {
  int? requestedId;
  @override
  Future<List<CategoryModel>> getCategories() async => [
    DummyData.categories.first,
  ];
  @override
  Future<List<ProductModel>> getProducts() async => [DummyData.products[1]];
  @override
  Future<ProductModel?> getProductById(int id) async {
    requestedId = id;
    return id == 2 ? DummyData.products[1] : null;
  }
}

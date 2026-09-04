import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sultan_app/core/theme/app_theme.dart';
import 'package:sultan_app/app/app_dependencies.dart';
import 'package:sultan_app/data/repositories/home_repository.dart';
import 'package:sultan_app/data/repositories/product_repository.dart';
import 'package:sultan_app/data/repositories/orders_repository.dart';
import 'package:sultan_app/data/repositories/profile_repository.dart';
import 'package:sultan_app/features/cart/cubit/cart_cubit.dart';
import 'package:sultan_app/features/favorites/cubit/favorites_cubit.dart';
import 'package:sultan_app/features/main_navigation/screens/main_navigation_screen.dart';
import 'package:sultan_app/features/profile/cubit/profile_cubit.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  testWidgets('Home وMenu تعملان على شاشة هاتف صغيرة', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final dependencies = AppDependencies();
    addTearDown(dependencies.dispose);

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<OrdersRepository>.value(
            value: dependencies.ordersRepository,
          ),
          RepositoryProvider<ProfileRepository>.value(
            value: dependencies.profileRepository,
          ),
          RepositoryProvider<HomeRepository>.value(
            value: dependencies.homeRepository,
          ),
          RepositoryProvider<ProductRepository>.value(
            value: dependencies.productRepository,
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => ProfileCubit(dependencies.profileRepository),
            ),
            BlocProvider(create: (_) => CartCubit()),
            BlocProvider(
              create: (_) =>
                  FavoritesCubit(dependencies.favoritesRepository)
                    ..loadFavorites(),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            builder: (context, child) =>
                Directionality(textDirection: TextDirection.rtl, child: child!),
            home: const MainNavigationScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('في كافيه السلطان'), findsOneWidget);
    await tester.tap(find.text('المنيو'));
    await tester.pumpAndSettle();
    expect(find.text('ابحث عن مشروب أو منتج...'), findsOneWidget);
    await tester.tap(find.text('طلباتي'));
    await tester.pumpAndSettle();
    expect(find.text('قيد المراجعة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/app/routes.dart';
import 'package:sultan_app/app/app_dependencies.dart';
import 'package:sultan_app/core/constants/app_strings.dart';
import 'package:sultan_app/core/theme/app_theme.dart';
import 'package:sultan_app/data/repositories/auth_repository.dart';
import 'package:sultan_app/data/repositories/address_repository.dart';
import 'package:sultan_app/features/auth/cubit/auth_cubit.dart';
import 'package:sultan_app/data/repositories/checkout_repository.dart';
import 'package:sultan_app/data/repositories/favorites_repository.dart';
import 'package:sultan_app/data/repositories/home_repository.dart';
import 'package:sultan_app/data/repositories/product_repository.dart';
import 'package:sultan_app/data/repositories/orders_repository.dart';
import 'package:sultan_app/data/repositories/profile_repository.dart';
import 'package:sultan_app/features/cart/cubit/cart_cubit.dart';
import 'package:sultan_app/features/checkout/cubit/checkout_cubit.dart';
import 'package:sultan_app/features/favorites/cubit/favorites_cubit.dart';
import 'package:sultan_app/features/profile/cubit/profile_cubit.dart';

class SultanApp extends StatelessWidget {
  const SultanApp({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider<OrdersRepository>.value(
        value: dependencies.ordersRepository,
      ),
      RepositoryProvider<AuthRepository>.value(
        value: dependencies.authRepository,
      ),
      RepositoryProvider<ProfileRepository>.value(
        value: dependencies.profileRepository,
      ),
      RepositoryProvider<AddressRepository>.value(
        value: dependencies.addressRepository,
      ),
      RepositoryProvider<HomeRepository>.value(
        value: dependencies.homeRepository,
      ),
      RepositoryProvider<ProductRepository>.value(
        value: dependencies.productRepository,
      ),
      RepositoryProvider<CheckoutRepository>.value(
        value: dependencies.checkoutRepository,
      ),
      RepositoryProvider<FavoritesRepository>.value(
        value: dependencies.favoritesRepository,
      ),
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(context.read<AuthRepository>()),
        ),
        BlocProvider(
          create: (context) => ProfileCubit(context.read<ProfileRepository>()),
        ),
        BlocProvider(create: (_) => CartCubit()),
        BlocProvider(
          create: (context) =>
              FavoritesCubit(context.read<FavoritesRepository>())
                ..loadFavorites(),
        ),
        BlocProvider(
          create: (context) => CheckoutCubit(
            context.read<CheckoutRepository>(),
            context.read<HomeRepository>(),
          )..loadData(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppStrings.appName,
        theme: AppTheme.light,
        locale: const Locale('ar'),
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        ),
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    ),
  );
}

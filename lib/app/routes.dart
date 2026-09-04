import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/core/widgets/foundation_placeholder.dart';
import 'package:sultan_app/data/repositories/product_repository.dart';
import 'package:sultan_app/data/repositories/address_repository.dart';
import 'package:sultan_app/features/addresses/screens/add_address_screen.dart';
import 'package:sultan_app/features/addresses/screens/delivery_address_screen.dart';
import 'package:sultan_app/features/addresses/screens/saved_addresses_screen.dart';
import 'package:sultan_app/features/addresses/cubit/address_cubit.dart';
import 'package:sultan_app/features/auth/screens/login_screen.dart';
import 'package:sultan_app/features/auth/screens/register_screen.dart';
import 'package:sultan_app/features/booking/screens/booking_order_screen.dart';
import 'package:sultan_app/features/cart/screens/cart_screen.dart';
import 'package:sultan_app/features/checkout/screens/confirm_order_screen.dart';
import 'package:sultan_app/features/checkout/screens/order_success_screen.dart';
import 'package:sultan_app/features/favorites/screens/favorites_screen.dart';
import 'package:sultan_app/features/main_navigation/screens/main_navigation_screen.dart';
import 'package:sultan_app/features/product_details/cubit/product_details_cubit.dart';
import 'package:sultan_app/features/product_details/screens/product_details_screen.dart';
import 'package:sultan_app/features/service_type/screens/service_type_screen.dart';
import 'package:sultan_app/features/splash/screens/splash_screen.dart';
import 'package:sultan_app/features/orders/screens/order_details_screen.dart';
import 'package:sultan_app/features/orders/cubit/order_details_cubit.dart';
import 'package:sultan_app/features/profile/screens/edit_profile_screen.dart';
import 'package:sultan_app/features/cafe_info/screens/cafe_info_screen.dart';
import 'package:sultan_app/features/cafe_info/cubit/cafe_info_cubit.dart';
import 'package:sultan_app/features/privacy/screens/privacy_policy_screen.dart';
import 'package:sultan_app/data/repositories/home_repository.dart';
import 'package:sultan_app/data/repositories/orders_repository.dart';

abstract final class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String mainNavigation = '/main';
  static const String home = '/home';
  static const String menu = '/menu';
  static const String auth = '/auth';
  static const String productDetails = '/product-details';
  static const String cart = '/cart';
  static const String serviceType = '/service-type';
  static const String checkout = '/checkout';
  static const String favorites = '/favorites';
  static const String addresses = '/addresses';
  static const String cafeInfo = '/cafe-info';
  static const String privacy = '/privacy';
  static const String booking = '/booking';
  static const String deliveryAddress = '/delivery-address';
  static const String addAddress = '/add-address';
  static const String confirmOrder = '/confirm-order';
  static const String orderSuccess = '/order-success';
  static const String orderDetails = '/order-details';
  static const String editProfile = '/edit-profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final page = switch (settings.name) {
      splash => const SplashScreen(),
      login || auth => const LoginScreen(),
      register => const RegisterScreen(),
      mainNavigation || home => const MainNavigationScreen(),
      menu => const MainNavigationScreen(initialIndex: 1),
      productDetails => _buildProductDetails(settings.arguments),
      cart => const CartScreen(),
      serviceType => const ServiceTypeScreen(),
      checkout || confirmOrder => const ConfirmOrderScreen(),
      favorites => const FavoritesScreen(),
      addresses => BlocProvider(
        create: (context) =>
            AddressCubit(context.read<AddressRepository>())..loadAddresses(),
        child: const SavedAddressesScreen(),
      ),
      deliveryAddress => const DeliveryAddressScreen(),
      addAddress => _buildAddAddress(settings.arguments),
      cafeInfo => BlocProvider(
        create: (context) =>
            CafeInfoCubit(context.read<HomeRepository>())..loadCafeInfo(),
        child: const CafeInfoScreen(),
      ),
      privacy => const PrivacyPolicyScreen(),
      editProfile => const EditProfileScreen(),
      booking => const BookingOrderScreen(),
      orderSuccess => const OrderSuccessScreen(),
      orderDetails => _buildOrderDetails(settings.arguments),
      _ => const FoundationPlaceholder(title: 'الصفحة غير موجودة'),
    };
    return MaterialPageRoute<dynamic>(builder: (_) => page, settings: settings);
  }

  static Widget _buildAddAddress(Object? arguments) {
    final addArguments = arguments is AddAddressArguments
        ? arguments
        : const AddAddressArguments.checkout();
    final screen = AddAddressScreen(arguments: addArguments);
    if (!addArguments.isManagement) return screen;
    return BlocProvider(
      create: (context) =>
          AddressCubit(context.read<AddressRepository>())..loadAddresses(),
      child: screen,
    );
  }

  static Widget _buildProductDetails(Object? arguments) {
    final productId = arguments is int ? arguments : -1;
    return BlocProvider(
      create: (context) =>
          ProductDetailsCubit(context.read<ProductRepository>())
            ..loadProduct(productId),
      child: const ProductDetailsScreen(),
    );
  }

  static Widget _buildOrderDetails(Object? arguments) {
    if (arguments is! int) {
      return const Scaffold(
        body: SafeArea(child: Center(child: Text('لا توجد تفاصيل طلب لعرضها'))),
      );
    }
    return BlocProvider(
      create: (context) =>
          OrderDetailsCubit(context.read<OrdersRepository>())
            ..loadOrderDetails(arguments),
      child: OrderDetailsScreen(orderId: arguments),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/core/widgets/app_bottom_navigation_bar.dart';
import 'package:sultan_app/data/repositories/home_repository.dart';
import 'package:sultan_app/data/repositories/product_repository.dart';
import 'package:sultan_app/data/repositories/orders_repository.dart';
import 'package:sultan_app/features/orders/cubit/orders_cubit.dart';
import 'package:sultan_app/features/cart/screens/cart_screen.dart';
import 'package:sultan_app/features/home/screens/home_screen.dart';
import 'package:sultan_app/features/home/cubit/home_cubit.dart';
import 'package:sultan_app/features/main_navigation/cubit/navigation_cubit.dart';
import 'package:sultan_app/features/main_navigation/cubit/navigation_state.dart';
import 'package:sultan_app/features/menu/cubit/menu_cubit.dart';
import 'package:sultan_app/features/menu/screens/menu_screen.dart';
import 'package:sultan_app/features/orders/screens/orders_screen.dart';
import 'package:sultan_app/features/profile/screens/profile_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({this.initialIndex = 0, super.key});

  final int initialIndex;

  static const _screens = [
    HomeScreen(),
    MenuScreen(),
    CartScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) =>
            OrdersCubit(context.read<OrdersRepository>())..loadOrders(),
      ),
      BlocProvider(create: (_) => NavigationCubit(initialIndex: initialIndex)),
      BlocProvider(
        create: (context) =>
            HomeCubit(context.read<HomeRepository>())..loadHome(),
      ),
      BlocProvider(
        create: (context) =>
            MenuCubit(context.read<ProductRepository>())..loadMenu(),
      ),
    ],
    child: BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) => Scaffold(
        body: IndexedStack(index: state.currentIndex, children: _screens),
        bottomNavigationBar: AppBottomNavigationBar(
          currentIndex: state.currentIndex,
          onTap: (index) {
            context.read<NavigationCubit>().selectTab(index);
            if (index == 3) {
              context.read<OrdersCubit>().refreshOrders();
            }
          },
        ),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/app/routes.dart';
import 'package:sultan_app/core/constants/app_constants.dart';
import 'package:sultan_app/core/theme/app_colors.dart';
import 'package:sultan_app/core/widgets/custom_button.dart';
import 'package:sultan_app/core/widgets/custom_error_widget.dart';
import 'package:sultan_app/core/widgets/loading_widget.dart';
import 'package:sultan_app/features/favorites/cubit/favorites_cubit.dart';
import 'package:sultan_app/features/favorites/cubit/favorites_state.dart';
import 'package:sultan_app/features/favorites/widgets/favorite_item_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('المفضلة')),
    body: SafeArea(
      child: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          if (state.status == FavoritesStatus.initial ||
              state.status == FavoritesStatus.loading) {
            return const LoadingWidget();
          }
          if (state.status == FavoritesStatus.failure) {
            return CustomErrorWidget(
              message: state.errorMessage ?? 'تعذر تحميل المفضلة',
              onRetry: context.read<FavoritesCubit>().loadFavorites,
            );
          }
          if (state.products.isEmpty) {
            return _EmptyFavorites(
              onBrowseMenu: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.menu),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppConstants.pagePadding),
            itemCount: state.products.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = state.products[index];
              return FavoriteItemCard(
                product: product,
                onRemove: () =>
                    context.read<FavoritesCubit>().removeFavorite(product.id),
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.productDetails,
                  arguments: product.id,
                ),
              );
            },
          );
        },
      ),
    ),
  );
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites({required this.onBrowseMenu});

  final VoidCallback onBrowseMenu;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.pagePadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.favorite_border_rounded,
            size: 68,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'ما عندك منتجات مفضلة لحد الآن',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: CustomButton(
              label: 'تصفح المنيو',
              icon: Icons.restaurant_menu_outlined,
              onPressed: onBrowseMenu,
            ),
          ),
        ],
      ),
    ),
  );
}

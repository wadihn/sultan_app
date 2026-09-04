import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/core/constants/app_constants.dart';
import 'package:sultan_app/core/theme/app_colors.dart';
import 'package:sultan_app/core/utils/price_formatter.dart';
import 'package:sultan_app/core/widgets/cart_icon_button.dart';
import 'package:sultan_app/core/widgets/custom_button.dart';
import 'package:sultan_app/core/widgets/custom_error_widget.dart';
import 'package:sultan_app/core/widgets/loading_widget.dart';
import 'package:sultan_app/core/widgets/product_image.dart';
import 'package:sultan_app/features/cart/cubit/cart_cubit.dart';
import 'package:sultan_app/features/favorites/cubit/favorites_cubit.dart';
import 'package:sultan_app/features/favorites/cubit/favorites_state.dart';
import 'package:sultan_app/features/product_details/cubit/product_details_cubit.dart';
import 'package:sultan_app/features/product_details/cubit/product_details_state.dart';
import 'package:sultan_app/features/product_details/widgets/product_option_group_card.dart';
import 'package:sultan_app/features/product_details/widgets/quantity_selector.dart';
import 'package:sultan_app/models/cart_item_model.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  void _addToCart(BuildContext context, ProductDetailsState state) {
    final product = state.product;
    if (product == null || !product.isAvailable) return;
    context.read<CartCubit>().addItem(
      CartItemModel(
        product: product,
        quantity: state.quantity,
        selectedOptions: state.selectedOptions,
        notes: state.notes.isEmpty ? null : state.notes,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تمت إضافة ${product.name} إلى السلة')),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
    builder: (context, state) {
      if (state.status == ProductDetailsStatus.loading ||
          state.status == ProductDetailsStatus.initial) {
        return const Scaffold(body: LoadingWidget());
      }
      if (state.status == ProductDetailsStatus.failure ||
          state.product == null) {
        return Scaffold(
          appBar: AppBar(),
          body: CustomErrorWidget(
            message: state.errorMessage ?? 'تعذر تحميل المنتج',
          ),
        );
      }
      final product = state.product!;
      final cubit = context.read<ProductDetailsCubit>();
      return Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل المنتج'),
          actions: const [CartIconButton()],
        ),
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 20),
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ProductImage(imagePath: product.imageUrl),
                    PositionedDirectional(
                      top: 12,
                      end: 16,
                      child: Material(
                        color: AppColors.white.withValues(alpha: 0.92),
                        shape: const CircleBorder(),
                        child:
                            BlocSelector<FavoritesCubit, FavoritesState, bool>(
                              selector: (favoritesState) => favoritesState
                                  .products
                                  .any((item) => item.id == product.id),
                              builder: (context, isFavorite) => IconButton(
                                onPressed: () => context
                                    .read<FavoritesCubit>()
                                    .toggleFavorite(product),
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: isFavorite
                                      ? AppColors.primary
                                      : AppColors.black,
                                ),
                                tooltip: isFavorite
                                    ? 'إزالة من المفضلة'
                                    : 'إضافة إلى المفضلة',
                              ),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppConstants.pagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        Text(
                          PriceFormatter.format(product.price),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      product.isAvailable ? 'متوفر' : 'غير متوفر حاليًا',
                      style: TextStyle(
                        color: product.isAvailable
                            ? const Color(0xFF268A43)
                            : AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    for (final group in product.optionGroups) ...[
                      const SizedBox(height: 18),
                      ProductOptionGroupCard(
                        group: group,
                        selectedIds:
                            state.selectedOptionIds[group.id] ?? const {},
                        onChanged: (option, selected) => cubit.selectOption(
                          group,
                          option,
                          selected: selected,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'الكمية',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        QuantitySelector(
                          quantity: state.quantity,
                          onDecrement: cubit.decrementQuantity,
                          onIncrement: cubit.incrementQuantity,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      onChanged: cubit.updateNotes,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات على الطلب',
                        hintText: 'مثال: بدون سكر، ثلج قليل...',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.all(AppConstants.pagePadding),
          child: CustomButton(
            label: 'إضافة للسلة — ${PriceFormatter.format(state.totalPrice)}',
            onPressed: product.isAvailable
                ? () => _addToCart(context, state)
                : null,
            icon: Icons.shopping_bag_outlined,
          ),
        ),
      );
    },
  );
}

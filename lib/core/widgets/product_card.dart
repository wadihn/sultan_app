import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/core/constants/app_constants.dart';
import 'package:sultan_app/core/theme/app_colors.dart';
import 'package:sultan_app/core/utils/price_formatter.dart';
import 'package:sultan_app/core/widgets/product_image.dart';
import 'package:sultan_app/features/favorites/cubit/favorites_cubit.dart';
import 'package:sultan_app/features/favorites/cubit/favorites_state.dart';
import 'package:sultan_app/models/product_model.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.product,
    required this.onPressed,
    this.compact = false,
    super.key,
  });

  final ProductModel product;
  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    margin: EdgeInsets.zero,
    color: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      side: const BorderSide(color: AppColors.border),
    ),
    child: InkWell(
      onTap: product.isAvailable ? onPressed : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ProductImage(imagePath: product.imageUrl),
                PositionedDirectional(
                  top: 6,
                  end: 6,
                  child: Material(
                    color: AppColors.white.withValues(alpha: 0.9),
                    shape: const CircleBorder(),
                    child: BlocSelector<FavoritesCubit, FavoritesState, bool>(
                      selector: (state) =>
                          state.products.any((item) => item.id == product.id),
                      builder: (context, isFavorite) => IconButton(
                        constraints: const BoxConstraints.tightFor(
                          width: 36,
                          height: 36,
                        ),
                        padding: EdgeInsets.zero,
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
                          size: 20,
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
            padding: EdgeInsets.all(compact ? 10 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (!compact) ...[
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: product.isAvailable
                          ? Text(
                              PriceFormatter.format(product.price),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : const Text(
                              'غير متوفر حاليًا',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.error,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                    IconButton.filled(
                      onPressed: product.isAvailable ? onPressed : null,
                      constraints: const BoxConstraints.tightFor(
                        width: 36,
                        height: 36,
                      ),
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.arrow_back, size: 19),
                      tooltip: 'عرض التفاصيل',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

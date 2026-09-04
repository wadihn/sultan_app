import 'package:flutter/material.dart';
import 'package:sultan_app/core/constants/app_constants.dart';
import 'package:sultan_app/core/theme/app_colors.dart';
import 'package:sultan_app/core/utils/price_formatter.dart';
import 'package:sultan_app/core/widgets/product_image.dart';
import 'package:sultan_app/models/product_model.dart';

class FavoriteItemCard extends StatelessWidget {
  const FavoriteItemCard({
    required this.product,
    required this.onPressed,
    required this.onRemove,
    super.key,
  });

  final ProductModel product;
  final VoidCallback onPressed;
  final VoidCallback onRemove;

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
      onTap: onPressed,
      child: SizedBox(
        height: 126,
        child: Row(
          children: [
            SizedBox(
              width: 112,
              height: double.infinity,
              child: ProductImage(imagePath: product.imageUrl),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        IconButton(
                          onPressed: onRemove,
                          constraints: const BoxConstraints.tightFor(
                            width: 36,
                            height: 36,
                          ),
                          padding: EdgeInsets.zero,
                          tooltip: 'إزالة من المفضلة',
                          icon: const Icon(
                            Icons.favorite_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      PriceFormatter.format(product.price),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      product.isAvailable ? 'متوفر' : 'غير متوفر حاليًا',
                      style: TextStyle(
                        color: product.isAvailable
                            ? const Color(0xFF268A43)
                            : AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

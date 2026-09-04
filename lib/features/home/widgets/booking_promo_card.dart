import 'package:flutter/material.dart';
import 'package:sultan_app/core/constants/app_constants.dart';
import 'package:sultan_app/core/theme/app_colors.dart';

class BookingPromoCard extends StatelessWidget {
  const BookingPromoCard({required this.onPressed, super.key});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.white,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.table_restaurant_outlined,
          size: 42,
          color: AppColors.primary,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'احجز طاولتك',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                'استمتع بجلستك المفضلة مع العائلة والأصدقاء',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(onPressed: onPressed, child: const Text('احجز الآن')),
      ],
    ),
  );
}

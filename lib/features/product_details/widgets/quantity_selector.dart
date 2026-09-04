import 'package:flutter/material.dart';
import 'package:sultan_app/core/constants/app_constants.dart';
import 'package:sultan_app/core/theme/app_colors.dart';

class QuantitySelector extends StatelessWidget {
  const QuantitySelector({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
    super.key,
  });
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: quantity > 1 ? onDecrement : null,
          icon: const Icon(Icons.remove),
          tooltip: 'تقليل الكمية',
        ),
        Text(
          '$quantity',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        IconButton(
          onPressed: onIncrement,
          icon: const Icon(Icons.add),
          tooltip: 'زيادة الكمية',
        ),
      ],
    ),
  );
}

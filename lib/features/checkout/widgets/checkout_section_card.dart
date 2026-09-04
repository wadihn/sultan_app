import 'package:flutter/material.dart';
import 'package:sultan_app/core/constants/app_constants.dart';
import 'package:sultan_app/core/theme/app_colors.dart';

class CheckoutSectionCard extends StatelessWidget {
  const CheckoutSectionCard({
    required this.title,
    required this.child,
    this.onEdit,
    super.key,
  });

  final String title;
  final Widget child;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.white,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            if (onEdit != null)
              TextButton(onPressed: onEdit, child: const Text('تعديل')),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    ),
  );
}

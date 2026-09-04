import 'package:flutter/material.dart';
import 'package:sultan_app/core/constants/app_strings.dart';
import 'package:sultan_app/core/widgets/custom_button.dart';

class CustomErrorWidget extends StatelessWidget {
  const CustomErrorWidget({
    this.message = AppStrings.genericError,
    this.onRetry,
    super.key,
  });
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 44),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            CustomButton(label: AppStrings.retry, onPressed: onRetry),
          ],
        ],
      ),
    ),
  );
}

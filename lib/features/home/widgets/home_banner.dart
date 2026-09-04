import 'package:flutter/material.dart';
import 'package:sultan_app/core/constants/app_constants.dart';
import 'package:sultan_app/core/theme/app_colors.dart';

class HomeBanner extends StatelessWidget {
  const HomeBanner({
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onTap,
    this.icon = Icons.campaign_outlined,
    super.key,
  });

  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.primaryDark, AppColors.primary],
      ),
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final showIcon = constraints.maxWidth >= 300;
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(color: AppColors.white, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  TextButton.icon(
                    onPressed: onTap,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryDark,
                      backgroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                    icon: const Icon(Icons.phone_outlined, size: 19),
                    label: Text(buttonText),
                  ),
                ],
              ),
            ),
            if (showIcon) ...[
              const SizedBox(width: 12),
              Icon(icon, color: AppColors.white, size: 46),
            ],
          ],
        );
      },
    ),
  );
}

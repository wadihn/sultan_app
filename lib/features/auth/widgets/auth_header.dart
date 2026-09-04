import 'package:flutter/material.dart';
import 'package:sultan_app/core/constants/app_assets.dart';
import 'package:sultan_app/core/theme/app_colors.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({required this.title, required this.description, super.key});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Image.asset(AppAssets.logo, height: 112, fit: BoxFit.contain),
      const SizedBox(height: 16),
      Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 6),
      Text(
        description,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: AppColors.textSecondary),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

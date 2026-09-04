import 'package:flutter/material.dart';
import 'package:sultan_app/app/routes.dart';
import 'package:sultan_app/core/constants/app_assets.dart';
import 'package:sultan_app/core/theme/app_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          AppAssets.logo,
          width: 52,
          height: 52,
          fit: BoxFit.contain,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'أهلاً بك',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            Text(
              'في كافيه السلطان',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      IconButton(
        tooltip: 'المفضلة',
        onPressed: () => Navigator.pushNamed(context, AppRoutes.favorites),
        icon: const Icon(Icons.favorite_border_rounded),
      ),
    ],
  );
}

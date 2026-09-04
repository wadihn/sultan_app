import 'package:flutter/material.dart';
import 'package:sultan_app/core/theme/app_colors.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({this.imagePath, this.fit = BoxFit.cover, super.key});
  final String? imagePath;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    if (path != null && path.isNotEmpty) {
      return Image.asset(
        path,
        fit: fit,
        errorBuilder: (_, _, _) => const _ProductImagePlaceholder(),
      );
    }
    return const _ProductImagePlaceholder();
  }
}

class _ProductImagePlaceholder extends StatelessWidget {
  const _ProductImagePlaceholder();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.background,
    child: Center(
      child: Icon(
        Icons.local_cafe_outlined,
        size: 54,
        color: AppColors.primary.withValues(alpha: 0.75),
      ),
    ),
  );
}

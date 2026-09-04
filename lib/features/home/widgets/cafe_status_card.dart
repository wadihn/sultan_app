import 'package:flutter/material.dart';
import 'package:sultan_app/core/constants/app_constants.dart';
import 'package:sultan_app/core/theme/app_colors.dart';
import 'package:sultan_app/models/cafe_info_model.dart';

class CafeStatusCard extends StatelessWidget {
  const CafeStatusCard({
    required this.cafeInfo,
    required this.isOpen,
    super.key,
  });
  final CafeInfoModel cafeInfo;
  final bool isOpen;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.black,
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
    ),
    child: Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isOpen ? const Color(0xFF35B85A) : AppColors.error,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isOpen ? 'مفتوح الآن' : 'مغلق الآن',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                cafeInfo.statusMessage,
                style: const TextStyle(color: AppColors.disabled),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.local_cafe_outlined,
          color: AppColors.primary,
          size: 38,
        ),
      ],
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:sultan_app/core/constants/app_constants.dart';
import 'package:sultan_app/core/theme/app_colors.dart';
import 'package:sultan_app/models/address_model.dart';

class AddressSelectionCard extends StatelessWidget {
  const AddressSelectionCard({
    required this.address,
    required this.isSelected,
    required this.onPressed,
    super.key,
  });

  final AddressModel address;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
        width: isSelected ? 1.5 : 1,
      ),
    ),
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.title,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(address.addressLine),
                  Text(
                    address.phone,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  if (address.landmark case final landmark?)
                    Text(
                      landmark,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

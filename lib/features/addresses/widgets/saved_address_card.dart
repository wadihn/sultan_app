import 'package:flutter/material.dart';
import 'package:sultan_app/core/constants/app_constants.dart';
import 'package:sultan_app/core/theme/app_colors.dart';
import 'package:sultan_app/models/address_model.dart';

class SavedAddressCard extends StatelessWidget {
  const SavedAddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final AddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      side: const BorderSide(color: AppColors.border),
    ),
    clipBehavior: Clip.antiAlias,
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address.title,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                tooltip: 'تعديل العنوان',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 20),
              ),
              IconButton(
                tooltip: 'حذف العنوان',
                onPressed: onDelete,
                color: AppColors.primaryDark,
                icon: const Icon(Icons.delete_outline, size: 20),
              ),
            ],
          ),
          const Divider(height: 18),
          _AddressDetail(icon: Icons.phone_outlined, text: address.phone),
          const SizedBox(height: 8),
          _AddressDetail(icon: Icons.map_outlined, text: address.addressLine),
          if (address.landmark case final landmark?) ...[
            const SizedBox(height: 8),
            _AddressDetail(icon: Icons.near_me_outlined, text: landmark),
          ],
          if (address.deliveryZoneName case final zone?) ...[
            const SizedBox(height: 8),
            _AddressDetail(icon: Icons.delivery_dining_outlined, text: zone),
          ],
        ],
      ),
    ),
  );
}

class _AddressDetail extends StatelessWidget {
  const _AddressDetail({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 18, color: AppColors.textSecondary),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AppColors.textSecondary),
        ),
      ),
    ],
  );
}

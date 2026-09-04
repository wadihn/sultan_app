import 'package:flutter/material.dart';
import 'package:sultan_app/core/constants/app_constants.dart';
import 'package:sultan_app/core/theme/app_colors.dart';
import 'package:sultan_app/core/utils/price_formatter.dart';
import 'package:sultan_app/models/product_option_group_model.dart';
import 'package:sultan_app/models/product_option_model.dart';

class ProductOptionGroupCard extends StatelessWidget {
  const ProductOptionGroupCard({
    required this.group,
    required this.selectedIds,
    required this.onChanged,
    super.key,
  });
  final ProductOptionGroupModel group;
  final Set<int> selectedIds;
  final void Function(ProductOptionModel option, bool selected) onChanged;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.white,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      side: const BorderSide(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  group.name,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                group.isRequired ? 'مطلوب' : 'اختياري',
                style: TextStyle(
                  color: group.isRequired
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        for (final option in group.options)
          _OptionTile(
            option: option,
            isSelected: selectedIds.contains(option.id),
            allowsMultiple: group.allowsMultiple,
            onTap: () => onChanged(option, !selectedIds.contains(option.id)),
          ),
      ],
    ),
  );
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.isSelected,
    required this.allowsMultiple,
    required this.onTap,
  });
  final ProductOptionModel option;
  final bool isSelected;
  final bool allowsMultiple;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    leading: Icon(
      allowsMultiple
          ? isSelected
                ? Icons.check_box
                : Icons.check_box_outline_blank
          : isSelected
          ? Icons.radio_button_checked
          : Icons.radio_button_off,
      color: isSelected ? AppColors.primary : AppColors.textSecondary,
    ),
    title: Text(option.name),
    trailing: option.price == 0
        ? const Text(
            'بدون زيادة',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          )
        : Text(
            '+${PriceFormatter.format(option.price)}',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
  );
}

import 'package:flutter/material.dart';
import 'package:sultan_app/core/theme/app_colors.dart';
import 'package:sultan_app/models/category_model.dart';

class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
    super.key,
  });
  final List<CategoryModel> categories;
  final int? selectedId;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 44,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: categories.length + 1,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final category = index == 0 ? null : categories[index - 1];
        final id = category?.id;
        final selected = id == selectedId;
        return ChoiceChip(
          label: Text(category?.name ?? 'الكل'),
          selected: selected,
          onSelected: (_) => onSelected(id),
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.white,
          labelStyle: TextStyle(
            color: selected ? AppColors.white : AppColors.black,
          ),
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.border,
          ),
          showCheckmark: false,
        );
      },
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sultan_app/core/theme/app_theme.dart';
import 'package:sultan_app/features/product_details/widgets/product_option_group_card.dart';
import 'package:sultan_app/models/product_option_group_model.dart';
import 'package:sultan_app/models/product_option_model.dart';

void main() {
  testWidgets('خيارات المنتج تظهر داخل Material دون استثناءات', (tester) async {
    const group = ProductOptionGroupModel(
      id: 1,
      name: 'الحجم',
      isRequired: true,
      options: [
        ProductOptionModel(id: 1, name: 'صغير', price: 0),
        ProductOptionModel(id: 2, name: 'كبير', price: 1),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: ProductOptionGroupCard(
              group: group,
              selectedIds: const {1},
              onChanged: (_, _) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('صغير'), findsOneWidget);
    expect(find.text('كبير'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sultan_app/core/theme/app_theme.dart';
import 'package:sultan_app/features/home/widgets/booking_promo_card.dart';

void main() {
  testWidgets('زر الحجز يأخذ عرضًا محدودًا داخل Row', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BookingPromoCard(onPressed: _doNothing),
            ),
          ),
        ),
      ),
    );

    expect(find.text('احجز الآن'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _doNothing() {}

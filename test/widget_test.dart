import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sultan_app/app/app.dart';
import 'package:sultan_app/app/app_dependencies.dart';
import 'package:sultan_app/core/constants/app_strings.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  testWidgets('ينتقل من Splash إلى تسجيل الدخول', (tester) async {
    final dependencies = AppDependencies();
    addTearDown(dependencies.dispose);
    await tester.pumpWidget(SultanApp(dependencies: dependencies));

    expect(find.text(AppStrings.appName), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.welcomeBack), findsOneWidget);
    expect(find.text(AppStrings.login), findsOneWidget);
  });

  testWidgets('يعمل Login وRegister على شاشة هاتف ضيقة دون Overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final dependencies = AppDependencies();
    addTearDown(dependencies.dispose);
    await tester.pumpWidget(SultanApp(dependencies: dependencies));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    final registerLink = find.text(AppStrings.register);
    await tester.ensureVisible(registerLink);
    await tester.tap(registerLink);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.register), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

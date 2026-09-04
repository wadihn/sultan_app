import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sultan_app/app/routes.dart';
import 'package:sultan_app/core/theme/app_theme.dart';
import 'package:sultan_app/data/repositories/address_repository.dart';
import 'package:sultan_app/data/repositories/checkout_repository.dart';
import 'package:sultan_app/features/addresses/cubit/address_cubit.dart';
import 'package:sultan_app/features/addresses/screens/add_address_screen.dart';
import 'package:sultan_app/features/addresses/screens/saved_addresses_screen.dart';
import 'package:sultan_app/features/cart/cubit/cart_cubit.dart';
import 'package:sultan_app/features/checkout/cubit/checkout_cubit.dart';
import 'package:sultan_app/data/repositories/home_repository.dart';
import 'package:sultan_app/models/address_model.dart';
import 'package:sultan_app/models/requests/create_address_request.dart';
import 'package:sultan_app/models/requests/update_address_request.dart';

void main() {
  test('AddressCubit CRUD and Checkout share the same repository', () async {
    final addresses = DummyAddressRepository(initialAddresses: const []);
    final cubit = AddressCubit(addresses);
    final checkout = CheckoutCubit(
      DummyCheckoutRepository(addressRepository: addresses),
      DummyHomeRepository(),
    );
    addTearDown(cubit.close);
    addTearDown(checkout.close);

    await cubit.loadAddresses();
    const request = CreateAddressRequest(
      title: 'البيت',
      phone: '0791234567',
      addressLine: 'عمّان، الجبيهة',
      deliveryZoneId: 2,
      landmark: 'بجانب المسجد',
    );
    expect(await cubit.addAddress(request), isTrue);
    final created = cubit.state.addresses.single;
    expect(created.id, isPositive);

    expect(
      await cubit.updateAddress(
        created.id,
        const UpdateAddressRequest(
          title: 'العمل',
          phone: '0791234567',
          addressLine: 'شارع الجامعة',
          deliveryZoneId: 1,
        ),
      ),
      isTrue,
    );
    await checkout.loadData();
    expect(checkout.state.addresses.single.title, 'العمل');
    expect(checkout.state.addresses.single.deliveryZoneId, 1);
    expect(checkout.state.addresses.single.deliveryZoneName, 'مؤتة');
    expect(checkout.state.selectedZone?.id, 1);

    await cubit.deleteAddress(created.id);
    await checkout.loadData();
    expect(checkout.state.addresses, isEmpty);
  });

  for (final size in [const Size(320, 568), const Size(430, 932)]) {
    testWidgets('Saved addresses are management-only and RTL at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final addresses = DummyAddressRepository();
      final home = DummyHomeRepository();

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<AddressRepository>.value(value: addresses),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => AddressCubit(addresses)..loadAddresses(),
              ),
              BlocProvider(create: (_) => CartCubit()),
              BlocProvider(
                create: (_) => CheckoutCubit(
                  DummyCheckoutRepository(addressRepository: addresses),
                  home,
                )..loadData(),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              builder: (_, child) => Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              ),
              home: const SavedAddressesScreen(),
              onGenerateRoute: AppRoutes.onGenerateRoute,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('المنزل'), findsOneWidget);
      expect(find.text('0790000000'), findsNWidgets(2));
      expect(find.text('بجانب المسجد'), findsOneWidget);
      expect(find.text('الكرك'), findsOneWidget);
      expect(find.text('متابعة إلى تأكيد الطلب'), findsNothing);
      expect(find.text('المجموع الفرعي'), findsNothing);
      expect(
        Directionality.of(tester.element(find.byType(SavedAddressesScreen))),
        TextDirection.rtl,
      );

      await tester.tap(find.text('إضافة عنوان'));
      await tester.pumpAndSettle();
      expect(find.byType(AddAddressScreen), findsOneWidget);
      expect(find.text('إضافة عنوان جديد'), findsOneWidget);
      var fields = find.byType(TextFormField);
      expect(fields, findsNWidgets(4));
      for (var index = 0; index < 4; index++) {
        expect(
          tester.widget<TextFormField>(fields.at(index)).controller?.text,
          '',
        );
      }
      await tester.enterText(fields.at(0), 'الجامعة');
      await tester.enterText(fields.at(1), '0791234567');
      await tester.enterText(fields.at(2), 'شارع الجامعة');
      await tester.enterText(fields.at(3), 'مقابل البوابة');
      await tester.tap(find.byKey(const ValueKey('address-delivery-zone')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('الكرك').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('حفظ العنوان'));
      await tester.tap(find.text('حفظ العنوان'));
      await tester.pumpAndSettle();
      expect(find.byType(SavedAddressesScreen), findsOneWidget);
      expect(find.text('الجامعة'), findsOneWidget);
      final added = (await addresses.getAddresses()).last;
      expect(added.deliveryZoneId, 2);

      await tester.ensureVisible(find.byTooltip('تعديل العنوان').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('تعديل العنوان').last);
      await tester.pumpAndSettle();
      expect(find.byType(AddAddressScreen), findsOneWidget);
      expect(find.text('تعديل العنوان'), findsOneWidget);
      expect(find.text('حفظ التعديلات'), findsOneWidget);
      final zoneField = tester.widget<DropdownButtonFormField<int>>(
        find.byKey(const ValueKey('address-delivery-zone')),
      );
      expect(zoneField.initialValue, 2);
      fields = find.byType(TextFormField);
      expect(
        tester.widget<TextFormField>(fields.at(0)).controller?.text,
        'الجامعة',
      );
      expect(
        tester.widget<TextFormField>(fields.at(1)).controller?.text,
        '0791234567',
      );
      expect(
        tester.widget<TextFormField>(fields.at(2)).controller?.text,
        'شارع الجامعة',
      );
      expect(
        tester.widget<TextFormField>(fields.at(3)).controller?.text,
        'مقابل البوابة',
      );
      await tester.enterText(fields.at(0), 'الجامعة الجديدة');
      await tester.tap(find.byKey(const ValueKey('address-delivery-zone')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('مؤتة').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('حفظ التعديلات'));
      await tester.tap(find.text('حفظ التعديلات'));
      await tester.pumpAndSettle();
      final updated = (await addresses.getAddresses()).last;
      expect(updated.id, added.id);
      expect(updated.title, 'الجامعة الجديدة');
      expect(updated.deliveryZoneId, 1);
      expect(updated.deliveryZoneName, 'مؤتة');
      expect((await addresses.getAddresses()).length, 3);
      expect(find.text('الجامعة الجديدة'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  test('Address JSON and requests use delivery zone ID', () {
    const created = CreateAddressRequest(
      title: 'البيت',
      phone: '0790000000',
      addressLine: 'الكرك',
      deliveryZoneId: 2,
    );
    const updated = UpdateAddressRequest(
      title: 'العمل',
      phone: '0790000000',
      addressLine: 'مؤتة',
      deliveryZoneId: 1,
    );
    expect(created.toJson()['delivery_zone_id'], 2);
    expect(updated.toJson()['delivery_zone_id'], 1);

    final address = AddressModel.fromJson({
      'id': 10,
      'title': 'البيت',
      'phone': '0790000000',
      'address_line': 'الكرك',
      'delivery_zone_id': 2,
      'delivery_zone': {'id': 2, 'name': 'الكرك', 'delivery_fee': '1.50'},
    });
    expect(address.deliveryZoneId, 2);
    expect(address.deliveryZoneName, 'الكرك');
    expect(address.toJson()['delivery_zone_id'], 2);
  });
}

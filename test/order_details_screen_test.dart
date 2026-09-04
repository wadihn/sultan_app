import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sultan_app/app/routes.dart';
import 'package:sultan_app/core/theme/app_theme.dart';
import 'package:sultan_app/core/utils/price_formatter.dart';
import 'package:sultan_app/data/dummy/dummy_data.dart';
import 'package:sultan_app/data/repositories/checkout_repository.dart';
import 'package:sultan_app/data/repositories/home_repository.dart';
import 'package:sultan_app/data/repositories/orders_repository.dart';
import 'package:sultan_app/features/checkout/cubit/checkout_cubit.dart';
import 'package:sultan_app/features/checkout/cubit/checkout_state.dart';
import 'package:sultan_app/features/checkout/screens/order_success_screen.dart';
import 'package:sultan_app/features/orders/screens/order_details_screen.dart';
import 'package:sultan_app/models/cart_item_model.dart';

void main() {
  for (final type in ServiceType.values) {
    for (final width in [320.0, 430.0]) {
      testWidgets('Success opens the exact $type response at width $width', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final orders = [...DummyData.orders];
        addTearDown(() {
          DummyData.orders
            ..clear()
            ..addAll(orders);
        });
        final cubit = CheckoutCubit(
          DummyCheckoutRepository(),
          DummyHomeRepository(),
        );
        addTearDown(cubit.close);
        await cubit.loadData();
        cubit.selectServiceType(type);
        if (type == ServiceType.booking) {
          cubit.selectBookingDate(DateTime.now().add(const Duration(days: 7)));
          cubit.selectBookingTime(hour: 20, minute: 35);
          expect(
            cubit.saveBooking(peopleCount: 4, notes: 'قرب النافذة'),
            isTrue,
          );
        } else {
          cubit.selectDeliveryZone(cubit.state.deliveryZones[1]);
        }
        final order = await cubit.createOrder(
          cartItems: [
            CartItemModel(
              product: DummyData.products.first,
              quantity: 2,
              selectedOptions: [
                DummyData.sizeOptions.options.last,
                DummyData.milkOptions.options.first,
              ],
              notes: 'بدون سكر',
            ),
          ],
        );
        expect(order, isNotNull);
        await tester.pumpWidget(
          RepositoryProvider<OrdersRepository>.value(
            value: DummyOrdersRepository(),
            child: BlocProvider.value(
              value: cubit,
              child: MaterialApp(
                theme: AppTheme.light,
                builder: (_, child) => Directionality(
                  textDirection: TextDirection.rtl,
                  child: child!,
                ),
                home: const OrderSuccessScreen(),
                onGenerateRoute: AppRoutes.onGenerateRoute,
              ),
            ),
          ),
        );
        await tester.ensureVisible(find.text('عرض تفاصيل الطلب'));
        await tester.tap(find.text('عرض تفاصيل الطلب'));
        await tester.pumpAndSettle();
        final screen = tester.widget<OrderDetailsScreen>(
          find.byType(OrderDetailsScreen),
        );
        expect(screen.orderId, order!.id);
        expect(find.text('الطلب #${order.id}'), findsOneWidget);
        expect(find.text('قيد المراجعة'), findsWidgets);
        if (type == ServiceType.booking) {
          expect(find.text('عدد الأشخاص'), findsOneWidget);
          expect(find.text('4'), findsOneWidget);
          expect(find.text('ملاحظات الحجز'), findsOneWidget);
          expect(find.text('قرب النافذة'), findsOneWidget);
          expect(find.textContaining('8:35'), findsOneWidget);
        } else {
          expect(find.text(order.address!.addressLine), findsOneWidget);
        }
        await tester.scrollUntilVisible(
          find.text('ملاحظات المنتج: بدون سكر'),
          150,
        );
        expect(find.text('الكمية: 2'), findsOneWidget);
        expect(find.textContaining('الخيارات:'), findsOneWidget);
        await tester.scrollUntilVisible(find.text('الإجمالي'), 150);
        expect(find.text(PriceFormatter.format(order.total)), findsWidgets);
        expect(find.text('المجموع الفرعي'), findsOneWidget);
        expect(find.text(PriceFormatter.format(order.subtotal)), findsWidgets);
        expect(
          find.text('رسوم التوصيل'),
          type == ServiceType.delivery ? findsOneWidget : findsNothing,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('Missing route argument does not create a fake order', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: AppRoutes.orderDetails,
        onGenerateRoute: (settings) => settings.name == '/'
            ? MaterialPageRoute<void>(builder: (_) => const SizedBox.shrink())
            : AppRoutes.onGenerateRoute(settings),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('لا توجد تفاصيل طلب لعرضها'), findsOneWidget);
    expect(find.byType(OrderDetailsScreen), findsNothing);
  });
}

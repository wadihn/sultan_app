import 'package:flutter_test/flutter_test.dart';
import 'package:sultan_app/data/dummy/dummy_data.dart';
import 'package:sultan_app/data/repositories/checkout_repository.dart';
import 'package:sultan_app/data/repositories/home_repository.dart';
import 'package:sultan_app/features/cart/cubit/cart_cubit.dart';
import 'package:sultan_app/features/checkout/cubit/checkout_cubit.dart';
import 'package:sultan_app/features/checkout/cubit/checkout_state.dart';
import 'package:sultan_app/models/cart_item_model.dart';

void main() {
  test('CartCubit يدير الكمية والمجموع الفرعي', () {
    final cubit = CartCubit();
    addTearDown(cubit.close);
    final item = CartItemModel(
      product: DummyData.products.first,
      quantity: 1,
      selectedOptions: [DummyData.sizeOptions.options.last],
    );

    cubit.addItem(item);
    cubit.addItem(item);
    expect(cubit.state.totalQuantity, 2);
    expect(cubit.state.subtotal, closeTo(7, 0.001));

    cubit.decrementQuantity(0);
    expect(cubit.state.totalQuantity, 1);
    cubit.removeItem(0);
    expect(cubit.state.items, isEmpty);
  });

  test('CheckoutCubit يحسب رسوم التوصيل وينشئ طلب pending', () async {
    final cubit = CheckoutCubit(
      DummyCheckoutRepository(),
      DummyHomeRepository(),
    );
    addTearDown(cubit.close);
    await cubit.loadData();
    cubit.selectServiceType(ServiceType.delivery);
    cubit.selectAddress(cubit.state.addresses.first);
    cubit.selectDeliveryZone(cubit.state.deliveryZones[1]);

    final item = CartItemModel(product: DummyData.products[1], quantity: 1);
    final order = await cubit.createOrder(cartItems: [item]);

    expect(cubit.state.estimatedDeliveryFee, 1.50);
    expect(order?.total, closeTo(3.25, 0.001));
    expect(order?.status, 'pending');
    expect(order?.paymentMethod, 'cash_on_delivery');
    expect(order?.address, isNotNull);
  });

  test('CheckoutCubit يربط الحجز بالطلب والدفع في الكافيه', () async {
    final cubit = CheckoutCubit(
      DummyCheckoutRepository(),
      DummyHomeRepository(),
    );
    addTearDown(cubit.close);
    await cubit.loadData();
    final selectedDate = DateTime.now().add(const Duration(days: 7));
    cubit.selectBookingDate(selectedDate);
    cubit.selectBookingTime(hour: 20, minute: 35);
    final saved = cubit.saveBooking(peopleCount: 4, notes: 'قرب النافذة');
    final item = CartItemModel(product: DummyData.products[1], quantity: 1);
    final order = await cubit.createOrder(cartItems: [item]);

    expect(saved, isTrue);
    expect(order?.booking?.peopleCount, 4);
    expect(order?.booking?.date, _date(selectedDate));
    expect(order?.booking?.time, '20:35');
    expect(order?.paymentMethod, 'pay_at_cafe');
    expect(order?.deliveryFee, 0);
  });
}

String _date(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

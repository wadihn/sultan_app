import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sultan_app/data/dummy/dummy_data.dart';
import 'package:sultan_app/core/theme/app_theme.dart';
import 'package:sultan_app/features/cart/cubit/cart_cubit.dart';
import 'package:sultan_app/features/addresses/screens/delivery_address_screen.dart';
import 'package:sultan_app/features/checkout/screens/confirm_order_screen.dart';
import 'package:sultan_app/data/repositories/checkout_repository.dart';
import 'package:sultan_app/data/repositories/home_repository.dart';
import 'package:sultan_app/features/checkout/cubit/checkout_cubit.dart';
import 'package:sultan_app/features/checkout/cubit/checkout_state.dart';
import 'package:sultan_app/features/checkout/screens/order_success_screen.dart';
import 'package:sultan_app/models/address_model.dart';
import 'package:sultan_app/models/booking_model.dart';
import 'package:sultan_app/models/cart_item_model.dart';
import 'package:sultan_app/models/delivery_zone_model.dart';
import 'package:sultan_app/models/order_model.dart';
import 'package:sultan_app/models/order_types.dart';
import 'package:sultan_app/models/product_model.dart';
import 'package:sultan_app/models/product_option_model.dart';
import 'package:sultan_app/models/requests/create_address_request.dart';
import 'package:sultan_app/models/requests/create_booking_request.dart';
import 'package:sultan_app/models/requests/create_order_item_request.dart';
import 'package:sultan_app/models/requests/create_order_request.dart';

CreateOrderRequest deliveryRequest({
  int productId = 2,
  List<int> options = const [],
  int quantity = 1,
  int zoneId = 2,
}) => CreateOrderRequest(
  serviceType: ServiceType.delivery,
  paymentMethod: PaymentMethod.cashOnDelivery,
  addressId: 1,
  deliveryZoneId: zoneId,
  items: [
    CreateOrderItemRequest(
      productId: productId,
      quantity: quantity,
      optionIds: options,
      notes: 'بدون سكر',
    ),
  ],
  notes: 'ملاحظة الطلب',
);

void main() {
  setUp(() {
    final orders = [...DummyData.orders];
    addTearDown(() {
      DummyData.orders
        ..clear()
        ..addAll(orders);
    });
  });

  for (final size in [const Size(320, 568), const Size(430, 932)]) {
    testWidgets('Checkout RTL previews and final response fit $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final cubit = CheckoutCubit(
        DummyCheckoutRepository(),
        DummyHomeRepository(),
      );
      final cart = CartCubit();
      addTearDown(cubit.close);
      addTearDown(cart.close);
      await cubit.loadData();
      cubit.selectServiceType(ServiceType.delivery);
      cubit.selectDeliveryZone(cubit.state.deliveryZones[1]);
      cart.addItem(CartItemModel(product: DummyData.products[1], quantity: 1));
      Future<void> render(Widget screen) async {
        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider.value(value: cubit),
              BlocProvider.value(value: cart),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              builder: (context, child) => Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              ),
              home: screen,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      await render(const DeliveryAddressScreen());
      await render(const ConfirmOrderScreen());
      final order = await cubit.createOrder(cartItems: cart.state.items);
      expect(order, isNotNull);
      await render(const OrderSuccessScreen());
      expect(find.text('رقم الطلب #${order!.id}'), findsOneWidget);
      expect(find.textContaining('الإجمالي النهائي:'), findsOneWidget);
    });
  }

  test('Request JSON contains only client selections and IDs', () {
    final json = deliveryRequest(productId: 1, options: [3, 7, 4]).toJson();
    expect(json['service_type'], 'delivery');
    expect(json['payment_method'], 'cash_on_delivery');
    expect(json['delivery_zone_id'], 2);
    expect(json.keys, isNot(contains('id')));
    expect(json.keys, isNot(contains('status')));
    expect(json.keys, isNot(contains('created_at')));
    expect(json.keys, isNot(contains('total')));
    expect(json.keys, isNot(contains('delivery_fee')));
    expect((json['items'] as List).single, {
      'product_id': 1,
      'quantity': 1,
      'option_ids': [3, 7, 4],
      'notes': 'بدون سكر',
    });
    final booking = CreateBookingRequest(
      date: DateTime(2030, 1, 2),
      time: '20:35',
      peopleCount: 4,
      notes: 'نافذة',
    );
    expect(booking.toJson(), {
      'date': '2030-01-02',
      'time': '20:35',
      'people_count': 4,
      'notes': 'نافذة',
    });
    expect(booking.dateTime.minute, 35);
    final bookingOrder = CreateOrderRequest(
      serviceType: ServiceType.booking,
      paymentMethod: PaymentMethod.payAtCafe,
      items: [CreateOrderItemRequest(productId: 2, quantity: 1)],
      booking: booking,
    ).toJson();
    expect(bookingOrder['booking'], booking.toJson());
    expect(bookingOrder, isNot(contains('address_id')));
    expect(bookingOrder, isNot(contains('delivery_zone_id')));
    expect(json, isNot(contains('booking')));
    const address = CreateAddressRequest(
      title: 'المنزل',
      phone: '0790000000',
      addressLine: 'شارع الجامعة',
      deliveryZoneId: 2,
      landmark: 'المسجد',
      deliveryNotes: 'اتصل',
    );
    expect(address.toJson(), {
      'title': 'المنزل',
      'phone': '0790000000',
      'address_line': 'شارع الجامعة',
      'delivery_zone_id': 2,
      'landmark': 'المسجد',
      'delivery_notes': 'اتصل',
    });
  });

  test('Booking response uses the final API contract', () {
    final booking = BookingModel.fromJson({
      'id': 25,
      'date': '2026-09-10',
      'time': '20:35',
      'people_count': 4,
      'notes': 'قرب النافذة',
      'status': 'pending',
    });
    expect(booking.date, '2026-09-10');
    expect(booking.time, '20:35');
    expect(booking.peopleCount, 4);
    expect(booking.localDateTime, DateTime(2026, 9, 10, 20, 35));
    expect(booking.toJson(), {
      'id': 25,
      'date': '2026-09-10',
      'time': '20:35',
      'people_count': 4,
      'status': 'pending',
      'notes': 'قرب النافذة',
    });

    final orderJson = DummyData.orders
        .firstWhere((order) => order.booking != null)
        .toJson();
    final parsed = OrderModel.fromJson(orderJson);
    expect(parsed.booking?.date, isNotEmpty);
    expect(parsed.booking?.time, isNotEmpty);
    expect(parsed.booking?.peopleCount, isPositive);
  });

  test(
    'Repository calculates authoritative prices and generates unique IDs',
    () async {
      final repo = DummyCheckoutRepository();
      final first = await repo.createOrder(
        deliveryRequest(productId: 1, options: [3, 8, 4], quantity: 2),
      );
      final second = await repo.createOrder(deliveryRequest());
      expect(first.subtotal, 8.6);
      expect(first.deliveryFee, 1.5);
      expect(first.total, 10.1);
      expect(first.status, 'pending');
      expect(second.id, greaterThan(first.id));
      expect(first.items.single.notes, 'بدون سكر');
      expect(first.notes, 'ملاحظة الطلب');
      expect(OrderModel.fromJson(first.toJson()).toJson(), first.toJson());
    },
  );

  test(
    'Repository rejects invalid products, options, quantity, and zone',
    () async {
      final repo = DummyCheckoutRepository();
      final before = DummyData.orders.length;
      for (final request in [
        deliveryRequest(productId: 999),
        deliveryRequest(productId: 5),
        deliveryRequest(quantity: 0),
        deliveryRequest(zoneId: 999),
        deliveryRequest(options: [999]),
        deliveryRequest(productId: 1),
        deliveryRequest(productId: 1, options: [1, 2, 7]),
        deliveryRequest(productId: 1, options: [1, 1, 7]),
      ]) {
        await expectLater(repo.createOrder(request), throwsStateError);
      }
      expect(DummyData.orders.length, before);
    },
  );

  test('Repository generates address IDs and preserves the response', () async {
    final repo = DummyCheckoutRepository();
    const request = CreateAddressRequest(
      title: 'عمل',
      phone: '0790000000',
      addressLine: 'الكرك',
      deliveryZoneId: 2,
    );
    final first = await repo.saveAddress(request);
    final second = await repo.saveAddress(request);
    expect(second.id, greaterThan(first.id));
    expect((await repo.getSavedAddresses()).last.id, second.id);
    expect(first.deliveryZoneId, 2);
    expect(first.deliveryZoneName, 'الكرك');
    expect(AddressModel.fromJson(first.toJson()).toJson(), first.toJson());
  });

  test(
    'Cubit ignores stale cart prices and clears old success after failure',
    () async {
      final cubit = CheckoutCubit(
        DummyCheckoutRepository(),
        DummyHomeRepository(),
      );
      addTearDown(cubit.close);
      await cubit.loadData();
      cubit.selectServiceType(ServiceType.delivery);
      cubit.selectDeliveryZone(cubit.state.deliveryZones[1]);
      const staleProduct = ProductModel(
        id: 1,
        categoryId: 1,
        name: 'قديم',
        description: '',
        price: 900,
      );
      final response = await cubit.createOrder(
        cartItems: [
          CartItemModel(
            product: staleProduct,
            quantity: 1,
            selectedOptions: const [
              ProductOptionModel(id: 3, name: 'قديم', price: 800),
              ProductOptionModel(id: 7, name: 'قديم', price: 700),
            ],
          ),
        ],
      );
      expect(response?.total, 5);
      expect(identical(cubit.state.createdOrder, response), isTrue);
      final rejected = await cubit.createOrder(
        cartItems: [CartItemModel(product: DummyData.products[4], quantity: 1)],
      );
      expect(rejected, isNull);
      expect(cubit.state.status, CheckoutStatus.failure);
      expect(cubit.state.createdOrder, isNull);
      expect(cubit.state.errorMessage, isNotEmpty);
    },
  );

  test('Repository failure leaves address form state recoverable', () async {
    final cubit = CheckoutCubit(_FailingRepository(), DummyHomeRepository());
    addTearDown(cubit.close);
    final saved = await cubit.addAddress(
      const CreateAddressRequest(
        title: 'بيت',
        phone: '0790000000',
        addressLine: 'الكرك',
        deliveryZoneId: 2,
      ),
    );
    expect(saved, isFalse);
    expect(cubit.state.addresses, isEmpty);
    expect(cubit.state.isSavingAddress, isFalse);
    expect(cubit.state.addressErrorMessage, isNotEmpty);
  });

  testWidgets('Success screen has no fake order when state is empty', (
    tester,
  ) async {
    final cubit = CheckoutCubit(
      DummyCheckoutRepository(),
      DummyHomeRepository(),
    );
    addTearDown(cubit.close);
    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: const MaterialApp(home: OrderSuccessScreen()),
      ),
    );
    expect(find.text('لا يوجد طلب مؤكد لعرضه'), findsOneWidget);
    expect(find.textContaining('1025'), findsNothing);
    expect(find.text('تم إرسال طلبك بنجاح'), findsNothing);
  });
}

class _FailingRepository implements CheckoutRepository {
  @override
  Future<List<AddressModel>> getSavedAddresses() async => [];
  @override
  Future<List<DeliveryZoneModel>> getDeliveryZones() async => [];
  @override
  Future<AddressModel> saveAddress(CreateAddressRequest request) async =>
      throw StateError('Simulated failure');
  @override
  Future<OrderModel> createOrder(CreateOrderRequest request) async =>
      throw StateError('Simulated failure');
}

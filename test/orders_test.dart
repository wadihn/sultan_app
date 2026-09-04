import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sultan_app/app/routes.dart';
import 'package:sultan_app/core/theme/app_theme.dart';
import 'package:sultan_app/core/utils/price_formatter.dart';
import 'package:sultan_app/core/widgets/loading_widget.dart';
import 'package:sultan_app/data/dummy/dummy_data.dart';
import 'package:sultan_app/data/repositories/orders_repository.dart';
import 'package:sultan_app/data/repositories/checkout_repository.dart';
import 'package:sultan_app/features/orders/cubit/orders_cubit.dart';
import 'package:sultan_app/features/orders/cubit/orders_state.dart';
import 'package:sultan_app/features/orders/cubit/order_details_cubit.dart';
import 'package:sultan_app/features/orders/cubit/order_details_state.dart';
import 'package:sultan_app/features/orders/screens/orders_screen.dart';
import 'package:sultan_app/features/orders/screens/order_details_screen.dart';
import 'package:sultan_app/features/orders/utils/order_formatter.dart';
import 'package:sultan_app/features/orders/widgets/order_card.dart';
import 'package:sultan_app/models/order_model.dart';
import 'package:sultan_app/models/order_types.dart';
import 'package:sultan_app/models/requests/create_order_request.dart';
import 'package:sultan_app/models/requests/create_order_item_request.dart';

class _Repository implements OrdersRepository {
  List<OrderModel> orders = [...DummyData.orders];
  bool fail = false;
  int calls = 0;
  int detailCalls = 0;
  bool detailsFail = false;
  Completer<OrderModel>? pendingDetails;
  Completer<List<OrderModel>>? pending;
  @override
  Future<List<OrderModel>> getOrders() async {
    calls++;
    if (fail) throw StateError('private backend error');
    return pending == null ? orders : await pending!.future;
  }

  @override
  Future<OrderModel> getOrderDetails(int orderId) async {
    detailCalls++;
    if (detailsFail) throw StateError('private backend error');
    return pendingDetails == null
        ? orders.firstWhere((order) => order.id == orderId)
        : await pendingDetails!.future;
  }
}

Widget _app(OrdersCubit cubit, OrdersRepository repository) =>
    RepositoryProvider<OrdersRepository>.value(
      value: repository,
      child: BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          theme: AppTheme.light,
          builder: (_, child) =>
              Directionality(textDirection: TextDirection.rtl, child: child!),
          home: const Scaffold(body: OrdersScreen()),
          onGenerateRoute: (settings) => settings.name == AppRoutes.menu
              ? MaterialPageRoute<void>(
                  builder: (_) =>
                      const Scaffold(body: Text('menu destination')),
                )
              : AppRoutes.onGenerateRoute(settings),
        ),
      ),
    );

void main() {
  test(
    'Cubit exposes loading/success, sorts a copy and preserves all statuses',
    () async {
      final repo = _Repository()..pending = Completer<List<OrderModel>>();
      final original = [...repo.orders];
      final cubit = OrdersCubit(repo);
      addTearDown(cubit.close);
      expect(cubit.state.status, OrdersStatus.initial);
      final task = cubit.loadOrders();
      expect(cubit.state.status, OrdersStatus.loading);
      repo.pending!.complete(repo.orders);
      await task;
      expect(cubit.state.status, OrdersStatus.success);
      expect(cubit.state.orders.map((o) => o.id), [1002, 1004, 1003, 1001]);
      expect(repo.orders, original);
      expect(cubit.state.orders.map((o) => o.status).toSet(), {
        'pending',
        'accepted',
        'ready',
        'cancelled',
      });
    },
  );

  test('OrderDetailsCubit loads, fails, and retries by ID', () async {
    final repo = _Repository()..pendingDetails = Completer<OrderModel>();
    final cubit = OrderDetailsCubit(repo);
    addTearDown(cubit.close);
    final order = repo.orders.first;
    final loading = cubit.loadOrderDetails(order.id);
    expect(cubit.state.status, OrderDetailsStatus.loading);
    expect(cubit.state.order, isNull);
    repo.pendingDetails!.complete(order);
    await loading;
    expect(cubit.state.status, OrderDetailsStatus.success);
    expect(identical(cubit.state.order, order), isTrue);

    repo
      ..pendingDetails = null
      ..detailsFail = true;
    await cubit.loadOrderDetails(999999);
    expect(cubit.state.status, OrderDetailsStatus.failure);
    expect(cubit.state.order, isNull);
    repo.detailsFail = false;
    await cubit.loadOrderDetails(order.id);
    expect(cubit.state.status, OrderDetailsStatus.success);
    expect(repo.detailCalls, 3);
  });

  test(
    'Cubit handles empty/failure/retry without backend error leakage',
    () async {
      final repo = _Repository()..orders = [];
      final cubit = OrdersCubit(repo);
      addTearDown(cubit.close);
      await cubit.loadOrders();
      expect(cubit.state.status, OrdersStatus.empty);
      repo.fail = true;
      await cubit.refreshOrders();
      expect(cubit.state.status, OrdersStatus.failure);
      expect(cubit.state.errorMessage, 'حدث خطأ أثناء تحميل الطلبات');
      repo.fail = false;
      repo.orders = [...DummyData.orders];
      await cubit.loadOrders();
      expect(cubit.state.status, OrdersStatus.success);
      expect(repo.calls, 3);
    },
  );

  test(
    'Shared dummy history includes a new checkout response and zone JSON',
    () async {
      final snapshot = [...DummyData.orders];
      addTearDown(() {
        DummyData.orders
          ..clear()
          ..addAll(snapshot);
      });
      final repo = DummyOrdersRepository();
      final cubit = OrdersCubit(repo);
      addTearDown(cubit.close);
      await cubit.loadOrders();
      final order = await DummyCheckoutRepository().createOrder(
        CreateOrderRequest(
          serviceType: ServiceType.delivery,
          paymentMethod: PaymentMethod.cashOnDelivery,
          addressId: DummyData.addresses.first.id,
          deliveryZoneId: DummyData.deliveryZones.first.id,
          items: [CreateOrderItemRequest(productId: 2, quantity: 1)],
        ),
      );
      await cubit.refreshOrders();
      expect(identical(cubit.state.orders.first, order), isTrue);
      expect(identical(await repo.getOrderDetails(order.id), order), isTrue);
      expect(
        OrderModel.fromJson(order.toJson()).deliveryZone?.name,
        order.deliveryZone!.name,
      );
    },
  );

  testWidgets(
    'Loading, failure retry, empty menu action and refresh are wired',
    (tester) async {
      final repo = _Repository()..pending = Completer<List<OrderModel>>();
      final cubit = OrdersCubit(repo);
      addTearDown(cubit.close);
      final loading = cubit.loadOrders();
      await tester.pumpWidget(_app(cubit, repo));
      expect(find.byType(LoadingWidget), findsOneWidget);
      repo.pending!.completeError(StateError('failure'));
      await loading;
      await tester.pumpAndSettle();
      expect(find.text('حدث خطأ أثناء تحميل الطلبات'), findsOneWidget);
      repo.pending = null;
      repo.orders = [];
      await tester.tap(find.text('إعادة المحاولة'));
      await tester.pumpAndSettle();
      expect(find.text('لا توجد طلبات حتى الآن'), findsOneWidget);
      final calls = repo.calls;
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, 350),
      );
      await tester.pumpAndSettle();
      expect(repo.calls, greaterThan(calls));
      await tester.tap(find.text('تصفح المنيو'));
      await tester.pumpAndSettle();
      expect(find.text('menu destination'), findsOneWidget);
    },
  );

  testWidgets('Order details failure UI retries the same order ID', (
    tester,
  ) async {
    final repo = _Repository()..detailsFail = true;
    final cubit = OrdersCubit(repo);
    addTearDown(cubit.close);
    await cubit.loadOrders();
    final order = cubit.state.orders.first;
    await tester.pumpWidget(_app(cubit, repo));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(OrderCard).first);
    await tester.pumpAndSettle();
    expect(find.text('تعذر تحميل تفاصيل الطلب'), findsOneWidget);
    expect(repo.detailCalls, 1);
    repo.detailsFail = false;
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();
    expect(find.text('الطلب #${order.id}'), findsOneWidget);
    expect(repo.detailCalls, 2);
  });

  for (final size in [const Size(320, 568), const Size(430, 932)]) {
    testWidgets('Orders RTL statuses/details/no cancellation fit $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = _Repository();
      final cubit = OrdersCubit(repo);
      addTearDown(cubit.close);
      await cubit.loadOrders();
      await tester.pumpWidget(_app(cubit, repo));
      await tester.pumpAndSettle();
      expect(
        Directionality.of(tester.element(find.byType(OrdersScreen))),
        TextDirection.rtl,
      );
      expect(
        tester.widget<OrderCard>(find.byType(OrderCard).first).order.id,
        1002,
      );
      expect(find.text('طلب #1002'), findsOneWidget);
      expect(find.byKey(const ValueKey('order-status-badge')), findsWidgets);
      expect(
        find.text(OrderFormatter.service(cubit.state.orders.first.serviceType)),
        findsWidgets,
      );
      expect(
        find.textContaining(
          OrderFormatter.date(cubit.state.orders.first.createdAt),
        ),
        findsOneWidget,
      );
      expect(find.text('2 عناصر'), findsWidgets);
      expect(
        find.text(PriceFormatter.format(cubit.state.orders.first.total)),
        findsOneWidget,
      );
      expect(find.text('عرض التفاصيل'), findsWidgets);
      for (final order in cubit.state.orders) {
        final card = find.byWidgetPredicate(
          (w) => w is OrderCard && w.order.id == order.id,
        );
        await tester.scrollUntilVisible(
          card,
          150,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text(OrderFormatter.status(order.status)), findsOneWidget);
        await tester.tap(card);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<OrderDetailsScreen>(find.byType(OrderDetailsScreen))
              .orderId,
          order.id,
        );
        expect(find.text(OrderFormatter.status(order.status)), findsWidgets);
        expect(find.text('إلغاء الطلب'), findsNothing);
        expect(find.byType(FilledButton), findsNothing);
        expect(find.byType(OutlinedButton), findsNothing);
        if (order.deliveryZone != null) {
          await tester.scrollUntilVisible(
            find.text(order.deliveryZone!.name),
            120,
            scrollable: find.byType(Scrollable).last,
          );
        }
        expect(tester.takeException(), isNull);
        await tester.pageBack();
        await tester.pumpAndSettle();
      }
      final calls = repo.calls;
      await tester
          .widget<RefreshIndicator>(find.byType(RefreshIndicator))
          .onRefresh();
      await tester.pumpAndSettle();
      expect(repo.calls, calls + 1);
      expect(cubit.state.orders.length, 4);
      expect(tester.takeException(), isNull);
    });
  }
}

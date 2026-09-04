import 'package:sultan_app/models/order_model.dart';

enum OrdersStatus { initial, loading, success, empty, failure }

class OrdersState {
  const OrdersState({
    this.status = OrdersStatus.initial,
    this.orders = const [],
    this.errorMessage,
  });
  final OrdersStatus status;
  final List<OrderModel> orders;
  final String? errorMessage;
}

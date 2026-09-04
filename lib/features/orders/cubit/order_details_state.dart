import 'package:sultan_app/models/order_model.dart';

enum OrderDetailsStatus { initial, loading, success, failure }

class OrderDetailsState {
  const OrderDetailsState({
    this.status = OrderDetailsStatus.initial,
    this.order,
    this.errorMessage,
  });

  final OrderDetailsStatus status;
  final OrderModel? order;
  final String? errorMessage;

  OrderDetailsState copyWith({
    OrderDetailsStatus? status,
    OrderModel? order,
    String? errorMessage,
    bool clearOrder = false,
    bool clearErrorMessage = false,
  }) => OrderDetailsState(
    status: status ?? this.status,
    order: clearOrder ? null : order ?? this.order,
    errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
  );
}

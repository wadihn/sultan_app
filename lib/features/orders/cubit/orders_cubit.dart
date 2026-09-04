import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/data/repositories/orders_repository.dart';
import 'package:sultan_app/features/orders/cubit/orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._repository) : super(const OrdersState());
  final OrdersRepository _repository;

  Future<void> loadOrders() async {
    if (state.status == OrdersStatus.loading) return;
    emit(const OrdersState(status: OrdersStatus.loading));
    try {
      final orders = [...await _repository.getOrders()]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (isClosed) return;
      emit(
        OrdersState(
          status: orders.isEmpty ? OrdersStatus.empty : OrdersStatus.success,
          orders: List.unmodifiable(orders),
        ),
      );
    } catch (_) {
      if (!isClosed) {
        emit(
          const OrdersState(
            status: OrdersStatus.failure,
            errorMessage: 'حدث خطأ أثناء تحميل الطلبات',
          ),
        );
      }
    }
  }

  Future<void> refreshOrders() => loadOrders();
}

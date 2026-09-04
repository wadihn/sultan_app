import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/data/repositories/orders_repository.dart';
import 'package:sultan_app/features/orders/cubit/order_details_state.dart';

class OrderDetailsCubit extends Cubit<OrderDetailsState> {
  OrderDetailsCubit(this._repository) : super(const OrderDetailsState());

  final OrdersRepository _repository;

  Future<void> loadOrderDetails(int orderId) async {
    emit(
      state.copyWith(
        status: OrderDetailsStatus.loading,
        clearOrder: true,
        clearErrorMessage: true,
      ),
    );
    try {
      final order = await _repository.getOrderDetails(orderId);
      emit(state.copyWith(status: OrderDetailsStatus.success, order: order));
    } catch (_) {
      emit(
        state.copyWith(
          status: OrderDetailsStatus.failure,
          clearOrder: true,
          errorMessage: 'تعذر تحميل تفاصيل الطلب',
        ),
      );
    }
  }
}

import 'package:dio/dio.dart';
import 'package:sultan_app/models/order_model.dart';

/// Remote contract only; not called by the dummy repository.
class OrdersService {
  const OrdersService(this.client);
  final Dio client;

  // TODO: GET /orders and /orders/{id} after Laravel is available.
  // Ownership is determined by Bearer token, never a supplied user ID.
  Future<List<OrderModel>> getOrders() async =>
      throw UnsupportedError('Laravel Orders is not configured');
  Future<OrderModel> getOrderDetails(int orderId) async =>
      throw UnsupportedError('Laravel Orders is not configured');
}

import 'package:sultan_app/data/dummy/dummy_data.dart';
import 'package:sultan_app/models/order_model.dart';

abstract interface class OrdersRepository {
  Future<List<OrderModel>> getOrders();
  Future<OrderModel> getOrderDetails(int orderId);
}

class DummyOrdersRepository implements OrdersRepository {
  @override
  Future<List<OrderModel>> getOrders() async =>
      List.unmodifiable(DummyData.orders);

  @override
  Future<OrderModel> getOrderDetails(int orderId) async =>
      DummyData.orders.firstWhere((order) => order.id == orderId);
}

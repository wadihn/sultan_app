import 'package:sultan_app/models/cart_item_model.dart';

class CartState {
  const CartState({this.items = const []});
  final List<CartItemModel> items;
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => items.fold(0, (sum, item) => sum + item.total);
}

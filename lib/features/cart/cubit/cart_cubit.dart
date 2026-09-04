import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/features/cart/cubit/cart_state.dart';
import 'package:sultan_app/models/cart_item_model.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());

  void addItem(CartItemModel item) {
    final index = state.items.indexWhere(
      (current) => _isSameItem(current, item),
    );
    if (index == -1) {
      emit(CartState(items: [...state.items, item]));
      return;
    }
    final items = [...state.items];
    final current = items[index];
    items[index] = current.copyWith(quantity: current.quantity + item.quantity);
    emit(CartState(items: items));
  }

  void incrementQuantity(int index) {
    if (!_isValidIndex(index)) return;
    final items = [...state.items];
    items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    emit(CartState(items: items));
  }

  void decrementQuantity(int index) {
    if (!_isValidIndex(index)) return;
    final items = [...state.items];
    final item = items[index];
    if (item.quantity == 1) return;
    items[index] = item.copyWith(quantity: item.quantity - 1);
    emit(CartState(items: items));
  }

  void removeItem(int index) {
    if (!_isValidIndex(index)) return;
    final items = [...state.items]..removeAt(index);
    emit(CartState(items: items));
  }

  void updateItem(int index, CartItemModel item) {
    if (!_isValidIndex(index)) return;
    final items = [...state.items];
    items[index] = item;
    emit(CartState(items: items));
  }

  void clear() => emit(const CartState());

  bool _isValidIndex(int index) => index >= 0 && index < state.items.length;

  bool _isSameItem(CartItemModel first, CartItemModel second) {
    if (first.product.id != second.product.id || first.notes != second.notes) {
      return false;
    }
    final firstIds = first.selectedOptions.map((option) => option.id).toSet();
    final secondIds = second.selectedOptions.map((option) => option.id).toSet();
    return firstIds.length == secondIds.length &&
        firstIds.containsAll(secondIds);
  }
}

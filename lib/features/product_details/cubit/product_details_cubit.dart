import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/data/repositories/product_repository.dart';
import 'package:sultan_app/features/product_details/cubit/product_details_state.dart';
import 'package:sultan_app/models/product_option_group_model.dart';
import 'package:sultan_app/models/product_option_model.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit(this._repository) : super(const ProductDetailsState());
  final ProductRepository _repository;

  Future<void> loadProduct(int productId) async {
    emit(state.copyWith(status: ProductDetailsStatus.loading));
    try {
      final product = await _repository.getProductById(productId);
      if (product == null) {
        emit(
          state.copyWith(
            status: ProductDetailsStatus.failure,
            errorMessage: 'المنتج غير موجود',
          ),
        );
        return;
      }
      final defaults = <int, Set<int>>{};
      for (final group in product.optionGroups) {
        if (group.isRequired && group.options.isNotEmpty) {
          defaults[group.id] = {group.options.first.id};
        }
      }
      emit(
        ProductDetailsState(
          status: ProductDetailsStatus.success,
          product: product,
          selectedOptionIds: defaults,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ProductDetailsStatus.failure,
          errorMessage: 'تعذر تحميل تفاصيل المنتج',
        ),
      );
    }
  }

  void selectOption(
    ProductOptionGroupModel group,
    ProductOptionModel option, {
    required bool selected,
  }) {
    final selections = <int, Set<int>>{
      for (final entry in state.selectedOptionIds.entries)
        entry.key: {...entry.value},
    };
    if (group.allowsMultiple) {
      final groupSelections = selections.putIfAbsent(group.id, () => {});
      selected
          ? groupSelections.add(option.id)
          : groupSelections.remove(option.id);
    } else {
      selections[group.id] = {option.id};
    }
    emit(state.copyWith(selectedOptionIds: selections));
  }

  void incrementQuantity() =>
      emit(state.copyWith(quantity: state.quantity + 1));

  void decrementQuantity() {
    if (state.quantity > 1) {
      emit(state.copyWith(quantity: state.quantity - 1));
    }
  }

  void updateNotes(String value) => emit(state.copyWith(notes: value.trim()));
}

import 'package:flutter_test/flutter_test.dart';
import 'package:sultan_app/data/repositories/product_repository.dart';
import 'package:sultan_app/features/product_details/cubit/product_details_cubit.dart';

void main() {
  test('ProductDetailsCubit يحسب الخيارات والكمية', () async {
    final cubit = ProductDetailsCubit(DummyProductRepository());
    addTearDown(cubit.close);
    await cubit.loadProduct(1);

    final product = cubit.state.product!;
    final sizeGroup = product.optionGroups.firstWhere((group) => group.id == 1);
    final large = sizeGroup.options.firstWhere(
      (option) => option.name == 'كبير',
    );
    final extrasGroup = product.optionGroups.firstWhere(
      (group) => group.id == 2,
    );
    final caramel = extrasGroup.options.firstWhere(
      (option) => option.name == 'كراميل',
    );

    cubit.selectOption(sizeGroup, large, selected: true);
    cubit.selectOption(extrasGroup, caramel, selected: true);
    cubit.incrementQuantity();

    expect(cubit.state.totalPrice, closeTo(7.60, 0.001));
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:sultan_app/data/repositories/product_repository.dart';
import 'package:sultan_app/features/menu/cubit/menu_cubit.dart';

void main() {
  test('MenuCubit يطبق القسم والبحث معًا', () async {
    final cubit = MenuCubit(DummyProductRepository());
    addTearDown(cubit.close);

    await cubit.loadMenu(selectedCategoryId: 1);
    cubit.search('كابتشينو');

    expect(cubit.state.visibleProducts, hasLength(1));
    expect(cubit.state.visibleProducts.single.name, 'كابتشينو');

    cubit.selectCategory(2);
    expect(cubit.state.visibleProducts, isEmpty);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/app/routes.dart';
import 'package:sultan_app/core/constants/app_constants.dart';
import 'package:sultan_app/core/widgets/cart_icon_button.dart';
import 'package:sultan_app/core/widgets/custom_error_widget.dart';
import 'package:sultan_app/core/widgets/empty_widget.dart';
import 'package:sultan_app/core/widgets/loading_widget.dart';
import 'package:sultan_app/core/widgets/product_card.dart';
import 'package:sultan_app/features/menu/cubit/menu_cubit.dart';
import 'package:sultan_app/features/menu/cubit/menu_state.dart';
import 'package:sultan_app/features/menu/widgets/category_filter_bar.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: BlocBuilder<MenuCubit, MenuState>(
      builder: (context, state) {
        if (state.status == MenuStatus.loading ||
            state.status == MenuStatus.initial) {
          return const LoadingWidget();
        }
        if (state.status == MenuStatus.failure) {
          return CustomErrorWidget(
            message: state.errorMessage ?? 'تعذر تحميل المنيو',
            onRetry: context.read<MenuCubit>().loadMenu,
          );
        }
        return CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.pagePadding,
                10,
                AppConstants.pagePadding,
                8,
              ),
              sliver: SliverList.list(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'المنيو',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      const CartIconButton(),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    onChanged: context.read<MenuCubit>().search,
                    decoration: const InputDecoration(
                      hintText: 'ابحث عن مشروب أو منتج...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 14),
                  CategoryFilterBar(
                    categories: state.categories,
                    selectedId: state.selectedCategoryId,
                    onSelected: context.read<MenuCubit>().selectCategory,
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
            if (state.visibleProducts.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyWidget(message: 'لا توجد منتجات مطابقة'),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.pagePadding,
                  0,
                  AppConstants.pagePadding,
                  24,
                ),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.crossAxisExtent;
                    final columns = width < 360
                        ? 1
                        : width >= 720
                        ? 3
                        : 2;
                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: columns == 1 ? 1.12 : 0.62,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final product = state.visibleProducts[index];
                        return ProductCard(
                          product: product,
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.productDetails,
                            arguments: product.id,
                          ),
                        );
                      }, childCount: state.visibleProducts.length),
                    );
                  },
                ),
              ),
          ],
        );
      },
    ),
  );
}

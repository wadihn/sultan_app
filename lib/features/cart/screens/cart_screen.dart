import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/app/routes.dart';
import 'package:sultan_app/core/constants/app_constants.dart';
import 'package:sultan_app/core/utils/price_formatter.dart';
import 'package:sultan_app/core/widgets/custom_button.dart';
import 'package:sultan_app/core/widgets/empty_widget.dart';
import 'package:sultan_app/features/cart/cubit/cart_cubit.dart';
import 'package:sultan_app/features/cart/cubit/cart_state.dart';
import 'package:sultan_app/features/cart/widgets/cart_item_card.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<CartCubit, CartState>(
    builder: (context, state) {
      final cubit = context.read<CartCubit>();
      return Scaffold(
        appBar: AppBar(title: const Text('السلة')),
        body: SafeArea(
          bottom: false,
          child: state.items.isEmpty
              ? const EmptyWidget(message: 'السلة فارغة، أضف منتجاتك المفضلة')
              : ListView.separated(
                  padding: const EdgeInsets.all(AppConstants.pagePadding),
                  itemCount: state.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => CartItemCard(
                    item: state.items[index],
                    onIncrement: () => cubit.incrementQuantity(index),
                    onDecrement: () => cubit.decrementQuantity(index),
                    onRemove: () => cubit.removeItem(index),
                  ),
                ),
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.all(AppConstants.pagePadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'المجموع',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  Text(
                    PriceFormatter.format(state.subtotal),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              CustomButton(
                label: 'متابعة الطلب',
                onPressed: state.items.isEmpty
                    ? null
                    : () => Navigator.pushNamed(context, AppRoutes.serviceType),
                icon: Icons.arrow_back,
              ),
            ],
          ),
        ),
      );
    },
  );
}

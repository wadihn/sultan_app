import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/app/routes.dart';
import 'package:sultan_app/core/theme/app_colors.dart';
import 'package:sultan_app/features/cart/cubit/cart_cubit.dart';
import 'package:sultan_app/features/cart/cubit/cart_state.dart';

class CartIconButton extends StatelessWidget {
  const CartIconButton({this.onPressed, super.key});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => BlocBuilder<CartCubit, CartState>(
    builder: (context, state) => IconButton(
      tooltip: 'السلة',
      onPressed:
          onPressed ?? () => Navigator.pushNamed(context, AppRoutes.cart),
      icon: Badge(
        isLabelVisible: state.totalQuantity > 0,
        backgroundColor: AppColors.primary,
        label: Text('${state.totalQuantity}'),
        child: const Icon(Icons.shopping_bag_outlined),
      ),
    ),
  );
}

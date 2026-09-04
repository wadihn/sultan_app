import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/app/routes.dart';
import 'package:sultan_app/core/constants/app_constants.dart';
import 'package:sultan_app/features/checkout/cubit/checkout_cubit.dart';
import 'package:sultan_app/features/checkout/cubit/checkout_state.dart';
import 'package:sultan_app/features/service_type/widgets/service_type_card.dart';

class ServiceTypeScreen extends StatelessWidget {
  const ServiceTypeScreen({super.key});

  void _select(BuildContext context, ServiceType type) {
    context.read<CheckoutCubit>().selectServiceType(type);
    Navigator.pushNamed(
      context,
      type == ServiceType.booking
          ? AppRoutes.booking
          : AppRoutes.deliveryAddress,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppConstants.pagePadding),
        children: [
          Text(
            'كيف تريد إكمال الطلب؟',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text('اختر الطريقة المناسبة لك لإكمال طلبك'),
          const SizedBox(height: 28),
          ServiceTypeCard(
            title: 'حجز طاولة',
            description: 'احجز طاولة وسيكون طلبك مرتبطًا بالحجز',
            icon: Icons.table_restaurant_outlined,
            onPressed: () => _select(context, ServiceType.booking),
          ),
          const SizedBox(height: 16),
          ServiceTypeCard(
            title: 'توصيل',
            description: 'نوصّل طلبك إلى عنوانك',
            icon: Icons.delivery_dining_outlined,
            onPressed: () => _select(context, ServiceType.delivery),
          ),
        ],
      ),
    ),
  );
}

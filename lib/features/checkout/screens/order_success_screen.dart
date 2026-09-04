import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/app/routes.dart';
import 'package:sultan_app/core/constants/app_constants.dart';
import 'package:sultan_app/core/theme/app_colors.dart';
import 'package:sultan_app/core/utils/price_formatter.dart';
import 'package:sultan_app/core/widgets/custom_button.dart';
import 'package:sultan_app/features/checkout/cubit/checkout_cubit.dart';
import 'package:sultan_app/models/order_types.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CheckoutCubit>().state;
    final order = state.createdOrder;
    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('الطلب')),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.pagePadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'لا يوجد طلب مؤكد لعرضه',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    label: 'العودة للرئيسية',
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.mainNavigation,
                      (route) => false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    final isBooking = order.serviceType == ServiceType.booking.name;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.pagePadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.08),
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 68,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'تم إرسال طلبك بنجاح',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isBooking
                        ? 'تم إرسال طلبك وحجزك للكافيه'
                        : 'تم إرسال طلبك للكافيه',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'رقم الطلب #${order.id}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'الإجمالي النهائي: ${PriceFormatter.format(order.total)}',
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    label: 'العودة للرئيسية',
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.mainNavigation,
                      (route) => false,
                    ),
                    icon: Icons.home_outlined,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.orderDetails,
                        arguments: order.id,
                      ),
                      child: const Text('عرض تفاصيل الطلب'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

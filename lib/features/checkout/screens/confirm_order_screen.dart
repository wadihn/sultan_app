import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/app/routes.dart';
import 'package:sultan_app/core/constants/app_constants.dart';
import 'package:sultan_app/core/utils/arabic_time_formatter.dart';
import 'package:sultan_app/core/utils/price_formatter.dart';
import 'package:sultan_app/core/widgets/custom_button.dart';
import 'package:sultan_app/features/cart/cubit/cart_cubit.dart';
import 'package:sultan_app/features/cart/cubit/cart_state.dart';
import 'package:sultan_app/features/checkout/cubit/checkout_cubit.dart';
import 'package:sultan_app/features/checkout/cubit/checkout_state.dart';
import 'package:sultan_app/features/checkout/widgets/checkout_section_card.dart';

class ConfirmOrderScreen extends StatelessWidget {
  const ConfirmOrderScreen({super.key});

  Future<void> _confirm(BuildContext context, CartState cart) async {
    final order = await context.read<CheckoutCubit>().createOrder(
      cartItems: cart.items,
    );
    if (order == null || !context.mounted) return;
    context.read<CartCubit>().clear();
    Navigator.pushReplacementNamed(context, AppRoutes.orderSuccess);
  }

  void _editProducts(BuildContext context) => Navigator.popUntil(
    context,
    (route) => route.settings.name == AppRoutes.cart,
  );

  void _editService(BuildContext context) => Navigator.popUntil(
    context,
    (route) => route.settings.name == AppRoutes.serviceType,
  );

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<CheckoutCubit, CheckoutState>(
    builder: (context, checkout) {
      final cart = context.watch<CartCubit>().state;
      final isBooking = checkout.serviceType == ServiceType.booking;
      final booking = checkout.booking;
      final address = checkout.selectedAddress;
      return Scaffold(
        appBar: AppBar(title: const Text('تأكيد الطلب')),
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.all(AppConstants.pagePadding),
            children: [
              CheckoutSectionCard(
                title: 'نوع الخدمة',
                onEdit: () => _editService(context),
                child: Text(isBooking ? 'حجز طاولة' : 'توصيل'),
              ),
              const SizedBox(height: 12),
              if (isBooking && booking != null)
                CheckoutSectionCard(
                  title: 'بيانات الحجز',
                  onEdit: () => Navigator.pop(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'التاريخ: ${booking.dateTime.day} / ${booking.dateTime.month} / ${booking.dateTime.year}',
                      ),
                      Text(
                        'الوقت: ${ArabicTimeFormatter.formatDateTime(booking.dateTime)}',
                      ),
                      Text('عدد الأشخاص: ${booking.peopleCount}'),
                      if (booking.notes != null)
                        Text('الملاحظات: ${booking.notes}'),
                    ],
                  ),
                ),
              if (!isBooking && address != null)
                CheckoutSectionCard(
                  title: 'بيانات التوصيل',
                  onEdit: () => Navigator.pop(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${address.title}: ${address.addressLine}'),
                      Text('المنطقة: ${checkout.selectedZone?.name ?? '-'}'),
                      Text('الهاتف: ${address.phone}'),
                      if (address.deliveryNotes != null)
                        Text('الملاحظات: ${address.deliveryNotes}'),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              CheckoutSectionCard(
                title: 'المنتجات',
                onEdit: () => _editProducts(context),
                child: Column(
                  children: [
                    for (final item in cart.items) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${item.quantity}×'),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.product.name),
                                if (item.selectedOptions.isNotEmpty)
                                  Text(
                                    item.selectedOptions
                                        .map((option) => option.name)
                                        .join(' • '),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                              ],
                            ),
                          ),
                          Text(PriceFormatter.format(item.total)),
                        ],
                      ),
                      const Divider(),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              CheckoutSectionCard(
                title: 'ملخص السعر التقديري',
                child: Column(
                  children: [
                    _SummaryRow(label: 'المجموع الفرعي', value: cart.subtotal),
                    if (!isBooking) ...[
                      const SizedBox(height: 6),
                      _SummaryRow(
                        label: 'رسوم التوصيل',
                        value: checkout.estimatedDeliveryFee,
                      ),
                    ],
                    const Divider(height: 22),
                    _SummaryRow(
                      label: 'الإجمالي',
                      value: checkout.estimatedTotal(cart.subtotal),
                      isTotal: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              CheckoutSectionCard(
                title: 'طريقة الدفع',
                child: Text(checkout.paymentMethod),
              ),
              if (checkout.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  checkout.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.all(AppConstants.pagePadding),
          child: CustomButton(
            label:
                'تأكيد الطلب — ${PriceFormatter.format(checkout.estimatedTotal(cart.subtotal))}',
            isLoading: checkout.status == CheckoutStatus.creating,
            onPressed: cart.items.isEmpty
                ? null
                : () => _confirm(context, cart),
          ),
        ),
      );
    },
  );
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });
  final String label;
  final double value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        label,
        style: isTotal ? Theme.of(context).textTheme.titleLarge : null,
      ),
      const Spacer(),
      Text(
        PriceFormatter.format(value),
        style: isTotal ? Theme.of(context).textTheme.titleLarge : null,
      ),
    ],
  );
}

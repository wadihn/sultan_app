import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/app/routes.dart';
import 'package:sultan_app/core/constants/app_constants.dart';
import 'package:sultan_app/core/utils/price_formatter.dart';
import 'package:sultan_app/core/widgets/custom_button.dart';
import 'package:sultan_app/features/addresses/widgets/address_selection_card.dart';
import 'package:sultan_app/features/cart/cubit/cart_cubit.dart';
import 'package:sultan_app/features/checkout/cubit/checkout_cubit.dart';
import 'package:sultan_app/features/checkout/cubit/checkout_state.dart';
import 'package:sultan_app/models/delivery_zone_model.dart';

class DeliveryAddressScreen extends StatefulWidget {
  const DeliveryAddressScreen({super.key});

  @override
  State<DeliveryAddressScreen> createState() => _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends State<DeliveryAddressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CheckoutCubit>().loadData();
    });
  }

  void _continue(BuildContext context, CheckoutState state) {
    if (state.selectedAddress == null || state.selectedZone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار العنوان ومنطقة التوصيل')),
      );
      return;
    }
    Navigator.pushNamed(context, AppRoutes.confirmOrder);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('عنوان التوصيل')),
    body: SafeArea(
      bottom: false,
      child: BlocBuilder<CheckoutCubit, CheckoutState>(
        builder: (context, state) => ListView(
          padding: const EdgeInsets.all(AppConstants.pagePadding),
          children: [
            Text(
              'العناوين المحفوظة',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            for (final address in state.addresses) ...[
              AddressSelectionCard(
                address: address,
                isSelected: state.selectedAddress?.id == address.id,
                onPressed: () =>
                    context.read<CheckoutCubit>().selectAddress(address),
              ),
              const SizedBox(height: 10),
            ],
            OutlinedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.addAddress),
              icon: const Icon(Icons.add),
              label: const Text('إضافة عنوان جديد'),
            ),
            const SizedBox(height: 24),
            Text(
              'منطقة التوصيل',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<DeliveryZoneModel>(
              initialValue: state.selectedZone,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.map_outlined),
                hintText: 'اختر المنطقة',
              ),
              items: state.deliveryZones
                  .map(
                    (zone) => DropdownMenuItem(
                      value: zone,
                      child: Text(
                        '${zone.name} — ${PriceFormatter.format(zone.deliveryFee)}',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (zone) {
                if (zone != null) {
                  context.read<CheckoutCubit>().selectDeliveryZone(zone);
                }
              },
            ),
            const SizedBox(height: 20),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.payments_outlined),
              title: Text('طريقة الدفع'),
              subtitle: Text('الدفع عند الاستلام'),
            ),
          ],
        ),
      ),
    ),
    bottomNavigationBar: SafeArea(
      minimum: const EdgeInsets.all(AppConstants.pagePadding),
      child: BlocBuilder<CheckoutCubit, CheckoutState>(
        builder: (context, state) {
          final subtotal = context.watch<CartCubit>().state.subtotal;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PriceRow(label: 'المجموع الفرعي', value: subtotal),
              const SizedBox(height: 6),
              _PriceRow(
                label: 'رسوم التوصيل التقديرية',
                value: state.estimatedDeliveryFee,
              ),
              const Divider(height: 20),
              _PriceRow(
                label: 'الإجمالي',
                value: state.estimatedTotal(subtotal),
                isTotal: true,
              ),
              const SizedBox(height: 14),
              CustomButton(
                label: 'متابعة إلى تأكيد الطلب',
                onPressed: () => _continue(context, state),
              ),
            ],
          );
        },
      ),
    ),
  );
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
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
      Expanded(
        child: Text(
          label,
          style: isTotal ? Theme.of(context).textTheme.titleLarge : null,
        ),
      ),
      const SizedBox(width: 8),
      Text(
        PriceFormatter.format(value),
        style: isTotal ? Theme.of(context).textTheme.titleLarge : null,
      ),
    ],
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/core/constants/app_constants.dart';
import 'package:sultan_app/core/theme/app_colors.dart';
import 'package:sultan_app/core/theme/app_text_styles.dart';
import 'package:sultan_app/core/utils/price_formatter.dart';
import 'package:sultan_app/core/widgets/custom_error_widget.dart';
import 'package:sultan_app/core/widgets/loading_widget.dart';
import 'package:sultan_app/features/orders/cubit/order_details_cubit.dart';
import 'package:sultan_app/features/orders/cubit/order_details_state.dart';
import 'package:sultan_app/features/orders/utils/order_formatter.dart';
import 'package:sultan_app/models/order_item_model.dart';
import 'package:sultan_app/models/order_model.dart';
import 'package:sultan_app/models/order_types.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({required this.orderId, super.key});
  final int orderId;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('تفاصيل الطلب')),
    body: SafeArea(
      child: BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
        builder: (context, state) {
          if (state.status == OrderDetailsStatus.initial ||
              state.status == OrderDetailsStatus.loading) {
            return const LoadingWidget();
          }
          if (state.status == OrderDetailsStatus.failure) {
            return CustomErrorWidget(
              message: state.errorMessage ?? 'تعذر تحميل تفاصيل الطلب',
              onRetry: () =>
                  context.read<OrderDetailsCubit>().loadOrderDetails(orderId),
            );
          }
          final order = state.order;
          if (order == null) {
            return const CustomErrorWidget(message: 'تعذر تحميل تفاصيل الطلب');
          }
          return _OrderDetailsContent(order: order);
        },
      ),
    ),
  );

  static bool _has(String? value) => value?.trim().isNotEmpty ?? false;
}

class _OrderDetailsContent extends StatelessWidget {
  const _OrderDetailsContent({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final booking = order.booking;
    final address = order.address;
    final delivery = order.serviceType == ServiceType.delivery.name;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        _Header(order: order),
        _Title('ملخص الطلب'),
        _Box(
          children: [
            _Row(
              Icons.room_service_outlined,
              'نوع الخدمة',
              OrderFormatter.service(order.serviceType),
            ),
            _Row(
              Icons.payments_outlined,
              'طريقة الدفع',
              OrderFormatter.payment(order.paymentMethod),
            ),
            _Row(
              Icons.info_outline,
              'حالة الطلب',
              OrderFormatter.status(order.status),
            ),
            if (OrderDetailsScreen._has(order.notes))
              _Row(Icons.notes, 'ملاحظات الطلب', order.notes!),
          ],
        ),
        if (booking != null) ...[
          _Title('تفاصيل الحجز'),
          _Box(
            children: [
              _Row(
                Icons.calendar_month_outlined,
                'تاريخ الحجز',
                OrderFormatter.date(booking.localDateTime),
              ),
              _Row(
                Icons.schedule_outlined,
                'وقت الحجز',
                OrderFormatter.time(booking.localDateTime),
              ),
              _Row(
                Icons.people_outline,
                'عدد الأشخاص',
                '${booking.peopleCount}',
              ),
              if (OrderDetailsScreen._has(booking.notes))
                _Row(Icons.notes, 'ملاحظات الحجز', booking.notes!),
            ],
          ),
        ],
        if (delivery && address != null) ...[
          _Title('تفاصيل التوصيل'),
          _Box(
            children: [
              _Row(Icons.label_outline, 'اسم العنوان', address.title),
              _Row(Icons.phone_outlined, 'رقم الهاتف', address.phone),
              _Row(
                Icons.location_on_outlined,
                'تفاصيل العنوان',
                address.addressLine,
              ),
              if (OrderDetailsScreen._has(address.landmark))
                _Row(Icons.near_me_outlined, 'أقرب معلم', address.landmark!),
              if (order.deliveryZone != null)
                _Row(
                  Icons.map_outlined,
                  'منطقة التوصيل',
                  order.deliveryZone!.name,
                ),
              if (OrderDetailsScreen._has(address.deliveryNotes))
                _Row(Icons.notes, 'ملاحظات التوصيل', address.deliveryNotes!),
            ],
          ),
        ],
        _Title('المنتجات'),
        _Box(
          children: order.items.isEmpty
              ? [const Text('لا توجد منتجات في هذا الطلب')]
              : order.items.map((item) => _Item(item)).toList(),
        ),
        _Title('ملخص السعر'),
        _Box(
          children: [
            _Price('المجموع الفرعي', order.subtotal),
            if (delivery) _Price('رسوم التوصيل', order.deliveryFee),
            _Price('الإجمالي', order.total, total: true),
          ],
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.order});
  final OrderModel order;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.black,
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'الطلب #${order.id}',
                style: AppTextStyles.title.copyWith(color: AppColors.white),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .18),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                OrderFormatter.status(order.status),
                style: AppTextStyles.label.copyWith(
                  color: AppColors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '${OrderFormatter.date(order.createdAt)} • ${OrderFormatter.time(order.createdAt)}',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AppColors.disabled),
        ),
      ],
    ),
  );
}

class _Title extends StatelessWidget {
  const _Title(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 22, bottom: 10),
    child: Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(9),
          ),
        ),
        const SizedBox(width: 8),
        Text(text, style: AppTextStyles.label.copyWith(fontSize: 16)),
      ],
    ),
  );
}

class _Box extends StatelessWidget {
  const _Box({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 11),
              child: Divider(height: 1, color: AppColors.border),
            ),
        ],
      ],
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 19, color: AppColors.primary),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 2),
            Text(value),
          ],
        ),
      ),
    ],
  );
}

class _Item extends StatelessWidget {
  const _Item(this.item);
  final OrderItemModel item;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              item.productName,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            PriceFormatter.format(item.unitPrice),
            style: AppTextStyles.label.copyWith(color: AppColors.primaryDark),
          ),
        ],
      ),
      const SizedBox(height: 6),
      Text('الكمية: ${item.quantity}'),
      if (item.selectedOptions.isNotEmpty)
        Text(
          'الخيارات: ${item.selectedOptions.join(' • ')}',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
      if (OrderDetailsScreen._has(item.notes))
        Text(
          'ملاحظات المنتج: ${item.notes}',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
    ],
  );
}

class _Price extends StatelessWidget {
  const _Price(this.label, this.value, {this.total = false});
  final String label;
  final double value;
  final bool total;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(label, style: total ? AppTextStyles.title : null)),
      Text(
        PriceFormatter.format(value),
        style: total
            ? AppTextStyles.title.copyWith(color: AppColors.primaryDark)
            : AppTextStyles.label,
      ),
    ],
  );
}

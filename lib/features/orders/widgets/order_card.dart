import 'package:flutter/material.dart';
import 'package:sultan_app/core/constants/app_constants.dart';
import 'package:sultan_app/core/theme/app_colors.dart';
import 'package:sultan_app/core/utils/price_formatter.dart';
import 'package:sultan_app/features/orders/utils/order_formatter.dart';
import 'package:sultan_app/models/order_model.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({required this.order, required this.onTap, super.key});
  final OrderModel order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final itemCount = order.items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0.5,
      shadowColor: AppColors.black.withValues(alpha: 0.04),
      surfaceTintColor: Colors.transparent,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'طلب #${order.id}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(child: _StatusBadge(status: order.status)),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _OrderMeta(
                    icon: order.serviceType == 'delivery'
                        ? Icons.delivery_dining_outlined
                        : Icons.event_seat_outlined,
                    text: OrderFormatter.service(order.serviceType),
                  ),
                  const SizedBox(height: 10),
                  _OrderMeta(
                    icon: Icons.calendar_month_outlined,
                    text:
                        '${OrderFormatter.date(order.createdAt)} • ${OrderFormatter.time(order.createdAt)}',
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1, color: AppColors.border),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      '$itemCount ${itemCount == 1 ? 'عنصر' : 'عناصر'}',
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'الإجمالي',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        PriceFormatter.format(order.total),
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: AlignmentDirectional.centerStart,
                child: _DetailsHint(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isCancelled = status == 'cancelled';
    final isReady = status == 'ready';
    final foreground = isCancelled
        ? AppColors.primaryDark
        : isReady
        ? AppColors.primary
        : status == 'accepted'
        ? AppColors.primaryDark
        : AppColors.textSecondary;
    final background = isCancelled
        ? AppColors.primary.withValues(alpha: 0.06)
        : isReady
        ? AppColors.primary.withValues(alpha: 0.12)
        : status == 'accepted'
        ? AppColors.primary.withValues(alpha: 0.08)
        : AppColors.black.withValues(alpha: 0.05);

    return Container(
      key: const ValueKey('order-status-badge'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: foreground.withValues(alpha: 0.18)),
      ),
      child: Text(
        OrderFormatter.status(status),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(color: foreground, fontSize: 12),
      ),
    );
  }
}

class _OrderMeta extends StatelessWidget {
  const _OrderMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 17, color: AppColors.textSecondary),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AppColors.textSecondary),
        ),
      ),
    ],
  );
}

class _DetailsHint extends StatelessWidget {
  const _DetailsHint();

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'عرض التفاصيل',
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(color: AppColors.primary),
      ),
      const SizedBox(width: 4),
      const Icon(
        Icons.arrow_back_ios_new_rounded,
        size: 13,
        color: AppColors.primary,
      ),
    ],
  );
}

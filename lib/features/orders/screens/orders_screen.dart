import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/app/routes.dart';
import 'package:sultan_app/core/constants/app_constants.dart';
import 'package:sultan_app/core/widgets/loading_widget.dart';
import 'package:sultan_app/core/widgets/empty_widget.dart';
import 'package:sultan_app/core/widgets/custom_error_widget.dart';
import 'package:sultan_app/core/widgets/custom_button.dart';
import 'package:sultan_app/features/orders/cubit/orders_cubit.dart';
import 'package:sultan_app/features/orders/cubit/orders_state.dart';
import 'package:sultan_app/features/orders/widgets/order_card.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppConstants.pagePadding),
          child: Text(
            'طلباتي',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Expanded(
          child: BlocBuilder<OrdersCubit, OrdersState>(
            builder: (context, state) {
              final cubit = context.read<OrdersCubit>();
              if (state.status == OrdersStatus.initial ||
                  state.status == OrdersStatus.loading) {
                return const LoadingWidget();
              }
              return RefreshIndicator(
                onRefresh: cubit.refreshOrders,
                child: state.status == OrdersStatus.success
                    ? ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(AppConstants.pagePadding),
                        itemCount: state.orders.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) => OrderCard(
                          order: state.orders[index],
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.orderDetails,
                            arguments: state.orders[index].id,
                          ),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) =>
                            SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: Center(
                                  child: state.status == OrdersStatus.failure
                                      ? CustomErrorWidget(
                                          message: state.errorMessage!,
                                          onRetry: cubit.loadOrders,
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.all(
                                            AppConstants.pagePadding,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const EmptyWidget(
                                                message:
                                                    'لا توجد طلبات حتى الآن',
                                              ),
                                              CustomButton(
                                                label: 'تصفح المنيو',
                                                onPressed: () =>
                                                    Navigator.pushNamed(
                                                      context,
                                                      AppRoutes.menu,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ),
                              ),
                            ),
                      ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

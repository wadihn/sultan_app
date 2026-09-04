import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/app/routes.dart';
import 'package:sultan_app/core/constants/app_constants.dart';
import 'package:sultan_app/core/widgets/custom_error_widget.dart';
import 'package:sultan_app/core/widgets/empty_widget.dart';
import 'package:sultan_app/core/widgets/loading_widget.dart';
import 'package:sultan_app/features/addresses/cubit/address_cubit.dart';
import 'package:sultan_app/features/addresses/cubit/address_state.dart';
import 'package:sultan_app/features/addresses/screens/add_address_screen.dart';
import 'package:sultan_app/features/addresses/widgets/saved_address_card.dart';
import 'package:sultan_app/models/address_model.dart';

class SavedAddressesScreen extends StatelessWidget {
  const SavedAddressesScreen({super.key});

  Future<void> _openForm(BuildContext context, [AddressModel? address]) async {
    final changed = await Navigator.pushNamed<dynamic>(
      context,
      AppRoutes.addAddress,
      arguments: AddAddressArguments.management(address: address),
    );
    if (changed == true && context.mounted) {
      await context.read<AddressCubit>().loadAddresses();
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AddressModel address,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف العنوان'),
        content: Text('هل تريد حذف عنوان ${address.title}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AddressCubit>().deleteAddress(address.id);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('العناوين المحفوظة')),
    body: SafeArea(
      bottom: false,
      child: BlocConsumer<AddressCubit, AddressState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.addresses.isNotEmpty) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          if (state.status == AddressStatus.initial ||
              state.status == AddressStatus.loading) {
            return const LoadingWidget();
          }
          if (state.status == AddressStatus.failure &&
              state.addresses.isEmpty) {
            return CustomErrorWidget(
              message: state.errorMessage ?? 'تعذر تحميل العناوين المحفوظة',
              onRetry: context.read<AddressCubit>().loadAddresses,
            );
          }
          if (state.addresses.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.pagePadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const EmptyWidget(
                      message: 'لا توجد عناوين محفوظة لحد الآن',
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _openForm(context),
                      icon: const Icon(Icons.add),
                      label: const Text('إضافة عنوان جديد'),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppConstants.pagePadding),
            itemCount: state.addresses.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final address = state.addresses[index];
              return SavedAddressCard(
                address: address,
                onEdit: () => _openForm(context, address),
                onDelete: () => _confirmDelete(context, address),
              );
            },
          );
        },
      ),
    ),
    floatingActionButton: BlocBuilder<AddressCubit, AddressState>(
      builder: (context, state) => state.addresses.isEmpty
          ? const SizedBox.shrink()
          : FloatingActionButton.extended(
              onPressed: () => _openForm(context),
              icon: const Icon(Icons.add),
              label: const Text('إضافة عنوان'),
            ),
    ),
  );
}

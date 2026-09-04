import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/core/constants/app_constants.dart';
import 'package:sultan_app/core/utils/validators.dart';
import 'package:sultan_app/core/widgets/custom_button.dart';
import 'package:sultan_app/core/widgets/custom_text_field.dart';
import 'package:sultan_app/features/addresses/cubit/address_cubit.dart';
import 'package:sultan_app/features/addresses/cubit/address_state.dart';
import 'package:sultan_app/features/checkout/cubit/checkout_cubit.dart';
import 'package:sultan_app/features/checkout/cubit/checkout_state.dart';
import 'package:sultan_app/models/address_model.dart';
import 'package:sultan_app/models/requests/create_address_request.dart';
import 'package:sultan_app/models/requests/update_address_request.dart';

enum AddressFormMode { checkoutCreate, managementCreate, managementEdit }

class AddAddressArguments {
  const AddAddressArguments.checkout()
    : mode = AddressFormMode.checkoutCreate,
      address = null;

  const AddAddressArguments.management({AddressModel? address})
    : mode = address == null
          ? AddressFormMode.managementCreate
          : AddressFormMode.managementEdit,
      address = address;

  final AddressFormMode mode;
  final AddressModel? address;

  bool get isManagement => mode != AddressFormMode.checkoutCreate;
  bool get isEdit => mode == AddressFormMode.managementEdit;
}

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({
    this.arguments = const AddAddressArguments.checkout(),
    super.key,
  });

  final AddAddressArguments arguments;

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _landmarkController;
  late final TextEditingController _notesController;
  int? _selectedDeliveryZoneId;

  @override
  void initState() {
    super.initState();
    final address = widget.arguments.address;
    _titleController = TextEditingController(text: address?.title);
    _phoneController = TextEditingController(text: address?.phone);
    _addressController = TextEditingController(text: address?.addressLine);
    _landmarkController = TextEditingController(text: address?.landmark);
    _notesController = TextEditingController(text: address?.deliveryNotes);
    _selectedDeliveryZoneId = address?.deliveryZoneId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final deliveryZoneId = _selectedDeliveryZoneId;
    if (deliveryZoneId == null) return;
    final createRequest = CreateAddressRequest(
      title: _titleController.text.trim(),
      phone: _phoneController.text.trim(),
      addressLine: _addressController.text.trim(),
      deliveryZoneId: deliveryZoneId,
      landmark: _landmarkController.text.trim().isEmpty
          ? null
          : _landmarkController.text.trim(),
      deliveryNotes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    final existingAddress = widget.arguments.address;
    final saved = widget.arguments.isManagement
        ? existingAddress == null
              ? await context.read<AddressCubit>().addAddress(createRequest)
              : await context.read<AddressCubit>().updateAddress(
                  existingAddress.id,
                  UpdateAddressRequest(
                    title: createRequest.title,
                    phone: createRequest.phone,
                    addressLine: createRequest.addressLine,
                    deliveryZoneId: deliveryZoneId,
                    landmark: createRequest.landmark,
                    deliveryNotes: createRequest.deliveryNotes,
                  ),
                )
        : await context.read<CheckoutCubit>().addAddress(createRequest);
    if (mounted && saved) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final zones = widget.arguments.isManagement
        ? context.watch<AddressCubit>().state.deliveryZones
        : context.watch<CheckoutCubit>().state.deliveryZones;
    final selectedZoneId =
        zones.any((zone) => zone.id == _selectedDeliveryZoneId)
        ? _selectedDeliveryZoneId
        : null;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.arguments.isEdit ? 'تعديل العنوان' : 'إضافة عنوان جديد',
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Form(
          key: _formKey,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(AppConstants.pagePadding),
            children: [
              CustomTextField(
                controller: _titleController,
                label: 'اسم العنوان',
                prefixIcon: Icons.label_outline,
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    Validators.requiredField(value, fieldName: 'اسم العنوان'),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _phoneController,
                label: 'رقم الهاتف',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: Validators.phone,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                key: const ValueKey('address-delivery-zone'),
                initialValue: selectedZoneId,
                decoration: const InputDecoration(
                  labelText: 'منطقة التوصيل',
                  prefixIcon: Icon(Icons.delivery_dining_outlined),
                ),
                items: zones
                    .map(
                      (zone) => DropdownMenuItem<int>(
                        value: zone.id,
                        child: Text(zone.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() {
                  _selectedDeliveryZoneId = value;
                }),
                validator: (value) =>
                    value == null ? 'اختر منطقة التوصيل' : null,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _addressController,
                label: 'تفاصيل العنوان',
                prefixIcon: Icons.location_on_outlined,
                textInputAction: TextInputAction.next,
                validator: (value) => Validators.requiredField(
                  value,
                  fieldName: 'تفاصيل العنوان',
                ),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _landmarkController,
                label: 'علامة مميزة (اختياري)',
                prefixIcon: Icons.near_me_outlined,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _notesController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات التوصيل',
                  hintText: 'مثال: الطابق الثالث، بجانب المسجد...',
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(AppConstants.pagePadding),
        child: widget.arguments.isManagement
            ? BlocBuilder<AddressCubit, AddressState>(
                builder: (context, state) => _SaveArea(
                  errorMessage: state.errorMessage,
                  isLoading: state.isSaving,
                  onSave: _save,
                  label: widget.arguments.isEdit
                      ? 'حفظ التعديلات'
                      : 'حفظ العنوان',
                ),
              )
            : BlocBuilder<CheckoutCubit, CheckoutState>(
                builder: (context, state) => _SaveArea(
                  errorMessage: state.addressErrorMessage,
                  isLoading: state.isSavingAddress,
                  onSave: _save,
                  label: 'حفظ العنوان',
                ),
              ),
      ),
    );
  }
}

class _SaveArea extends StatelessWidget {
  const _SaveArea({
    required this.errorMessage,
    required this.isLoading,
    required this.onSave,
    required this.label,
  });

  final String? errorMessage;
  final bool isLoading;
  final VoidCallback onSave;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (errorMessage != null) ...[
        Text(
          errorMessage!,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        const SizedBox(height: 8),
      ],
      CustomButton(label: label, onPressed: onSave, isLoading: isLoading),
    ],
  );
}

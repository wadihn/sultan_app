import 'package:sultan_app/models/address_model.dart';
import 'package:sultan_app/models/delivery_zone_model.dart';

enum AddressStatus { initial, loading, success, failure }

class AddressState {
  const AddressState({
    this.status = AddressStatus.initial,
    this.addresses = const [],
    this.deliveryZones = const [],
    this.errorMessage,
    this.isSaving = false,
  });

  final AddressStatus status;
  final List<AddressModel> addresses;
  final List<DeliveryZoneModel> deliveryZones;
  final String? errorMessage;
  final bool isSaving;

  AddressState copyWith({
    AddressStatus? status,
    List<AddressModel>? addresses,
    List<DeliveryZoneModel>? deliveryZones,
    String? errorMessage,
    bool? isSaving,
    bool clearError = false,
  }) => AddressState(
    status: status ?? this.status,
    addresses: addresses ?? this.addresses,
    deliveryZones: deliveryZones ?? this.deliveryZones,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    isSaving: isSaving ?? this.isSaving,
  );
}

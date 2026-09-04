import 'package:sultan_app/models/address_model.dart';
import 'package:sultan_app/models/requests/create_booking_request.dart';
import 'package:sultan_app/models/order_types.dart';
import 'package:sultan_app/models/delivery_zone_model.dart';
import 'package:sultan_app/models/order_model.dart';
import 'package:sultan_app/models/opening_hour_model.dart';

export 'package:sultan_app/models/order_types.dart' show ServiceType;

enum CheckoutStatus { initial, loading, ready, creating, success, failure }

class CheckoutState {
  const CheckoutState({
    this.status = CheckoutStatus.initial,
    this.serviceType,
    this.booking,
    this.addresses = const [],
    this.selectedAddress,
    this.deliveryZones = const [],
    this.selectedZone,
    this.openingHours = const [],
    this.selectedDate,
    this.selectedTime,
    this.bookingValidationMessage,
    this.createdOrder,
    this.errorMessage,
    this.isSavingAddress = false,
    this.addressErrorMessage,
  });

  final CheckoutStatus status;
  final ServiceType? serviceType;
  final CreateBookingRequest? booking;
  final List<AddressModel> addresses;
  final AddressModel? selectedAddress;
  final List<DeliveryZoneModel> deliveryZones;
  final DeliveryZoneModel? selectedZone;
  final List<OpeningHourModel> openingHours;
  final DateTime? selectedDate;
  final String? selectedTime;
  final String? bookingValidationMessage;
  final OrderModel? createdOrder;
  final String? errorMessage;
  final bool isSavingAddress;
  final String? addressErrorMessage;

  // Preview only. Final amounts belong to createdOrder returned by the repository.
  double get estimatedDeliveryFee =>
      serviceType == ServiceType.delivery ? selectedZone?.deliveryFee ?? 0 : 0;

  String get paymentMethod => serviceType == ServiceType.booking
      ? 'الدفع في الكافيه'
      : 'الدفع عند الاستلام';

  PaymentMethod get paymentMethodCode => serviceType == ServiceType.booking
      ? PaymentMethod.payAtCafe
      : PaymentMethod.cashOnDelivery;

  double estimatedTotal(double subtotal) => subtotal + estimatedDeliveryFee;

  int? get selectedHour => _selectedTimePart(0);

  int? get selectedMinute => _selectedTimePart(1);

  DateTime? get selectedBookingDateTime {
    final date = selectedDate;
    final hour = selectedHour;
    final minute = selectedMinute;
    if (date == null || hour == null || minute == null) return null;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  bool get canContinueBooking =>
      selectedBookingDateTime != null && bookingValidationMessage == null;

  CheckoutState copyWith({
    CheckoutStatus? status,
    ServiceType? serviceType,
    CreateBookingRequest? booking,
    bool clearBooking = false,
    List<AddressModel>? addresses,
    AddressModel? selectedAddress,
    List<DeliveryZoneModel>? deliveryZones,
    DeliveryZoneModel? selectedZone,
    bool clearSelectedZone = false,
    List<OpeningHourModel>? openingHours,
    DateTime? selectedDate,
    String? selectedTime,
    String? bookingValidationMessage,
    bool clearBookingValidationMessage = false,
    OrderModel? createdOrder,
    bool clearCreatedOrder = false,
    String? errorMessage,
    bool? isSavingAddress,
    String? addressErrorMessage,
  }) => CheckoutState(
    status: status ?? this.status,
    serviceType: serviceType ?? this.serviceType,
    booking: clearBooking ? null : booking ?? this.booking,
    addresses: addresses ?? this.addresses,
    selectedAddress: selectedAddress ?? this.selectedAddress,
    deliveryZones: deliveryZones ?? this.deliveryZones,
    selectedZone: clearSelectedZone ? null : selectedZone ?? this.selectedZone,
    openingHours: openingHours ?? this.openingHours,
    selectedDate: selectedDate ?? this.selectedDate,
    selectedTime: selectedTime ?? this.selectedTime,
    bookingValidationMessage: clearBookingValidationMessage
        ? null
        : bookingValidationMessage ?? this.bookingValidationMessage,
    createdOrder: clearCreatedOrder ? null : createdOrder ?? this.createdOrder,
    errorMessage: errorMessage,
    isSavingAddress: isSavingAddress ?? this.isSavingAddress,
    addressErrorMessage: addressErrorMessage,
  );

  int? _selectedTimePart(int index) {
    final value = selectedTime;
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    return int.tryParse(parts[index]);
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/core/utils/opening_hours_validator.dart';
import 'package:sultan_app/data/repositories/checkout_repository.dart';
import 'package:sultan_app/data/repositories/home_repository.dart';
import 'package:sultan_app/features/checkout/cubit/checkout_state.dart';
import 'package:sultan_app/models/address_model.dart';
import 'package:sultan_app/models/cart_item_model.dart';
import 'package:sultan_app/models/delivery_zone_model.dart';
import 'package:sultan_app/models/order_model.dart';
import 'package:sultan_app/models/requests/create_address_request.dart';
import 'package:sultan_app/models/requests/create_booking_request.dart';
import 'package:sultan_app/models/requests/create_order_item_request.dart';
import 'package:sultan_app/models/requests/create_order_request.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit(this._repository, this._homeRepository)
    : super(const CheckoutState());
  final CheckoutRepository _repository;
  final HomeRepository _homeRepository;

  Future<void> loadData() async {
    emit(state.copyWith(status: CheckoutStatus.loading));
    try {
      final addresses = await _repository.getSavedAddresses();
      final zones = await _repository.getDeliveryZones();
      final cafeInfo = await _homeRepository.getCafeInfo();
      final selectedAddress = addresses.isEmpty
          ? null
          : addresses.firstWhere(
              (item) => item.isDefault,
              orElse: () => addresses.first,
            );
      final selectedZone = _findZone(zones, selectedAddress?.deliveryZoneId);
      emit(
        state.copyWith(
          status: CheckoutStatus.ready,
          addresses: addresses,
          selectedAddress: selectedAddress,
          deliveryZones: zones,
          selectedZone: selectedZone,
          clearSelectedZone: selectedZone == null,
          openingHours: cafeInfo.openingHours,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: CheckoutStatus.failure,
          errorMessage: 'تعذر تحميل بيانات إكمال الطلب',
        ),
      );
    }
  }

  void selectServiceType(ServiceType value) =>
      emit(state.copyWith(serviceType: value, clearCreatedOrder: true));

  void selectBookingDate(DateTime date) {
    emit(
      state.copyWith(
        selectedDate: DateTime(date.year, date.month, date.day),
        clearBooking: true,
        clearBookingValidationMessage: true,
      ),
    );
    _validateCurrentSelection();
  }

  void selectBookingTime({required int hour, required int minute}) {
    final value =
        '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
    emit(
      state.copyWith(
        selectedTime: value,
        clearBooking: true,
        clearBookingValidationMessage: true,
      ),
    );
    _validateCurrentSelection();
  }

  bool saveBooking({required int peopleCount, String? notes, DateTime? now}) {
    final date = state.selectedDate;
    final time = state.selectedTime;
    if (date == null || time == null || peopleCount < 1) {
      emit(
        state.copyWith(bookingValidationMessage: 'اختر التاريخ والوقت أولًا'),
      );
      return false;
    }
    final validationMessage = OpeningHoursValidator.validateBooking(
      openingHours: state.openingHours,
      selectedDate: date,
      selectedTime: time,
      now: now,
    );
    if (validationMessage != null) {
      emit(state.copyWith(bookingValidationMessage: validationMessage));
      return false;
    }

    final normalizedNotes = notes?.trim();
    emit(
      state.copyWith(
        serviceType: ServiceType.booking,
        booking: CreateBookingRequest(
          date: date,
          time: time,
          peopleCount: peopleCount,
          notes: normalizedNotes == null || normalizedNotes.isEmpty
              ? null
              : normalizedNotes,
        ),
        clearBookingValidationMessage: true,
      ),
    );
    return true;
  }

  void _validateCurrentSelection() {
    final date = state.selectedDate;
    final time = state.selectedTime;
    if (date == null || time == null) return;
    final message = OpeningHoursValidator.validateBooking(
      openingHours: state.openingHours,
      selectedDate: date,
      selectedTime: time,
    );
    emit(
      state.copyWith(
        bookingValidationMessage: message,
        clearBookingValidationMessage: message == null,
      ),
    );
  }

  void selectAddress(AddressModel address) {
    final selectedZone = _findZone(state.deliveryZones, address.deliveryZoneId);
    emit(
      state.copyWith(
        selectedAddress: address,
        selectedZone: selectedZone,
        clearSelectedZone: selectedZone == null,
      ),
    );
  }

  static DeliveryZoneModel? _findZone(
    List<DeliveryZoneModel> zones,
    int? zoneId,
  ) {
    if (zoneId == null) return null;
    for (final zone in zones) {
      if (zone.id == zoneId) return zone;
    }
    return null;
  }

  void selectDeliveryZone(DeliveryZoneModel zone) =>
      emit(state.copyWith(selectedZone: zone));

  Future<bool> addAddress(CreateAddressRequest request) async {
    if (state.isSavingAddress) return false;
    emit(state.copyWith(isSavingAddress: true));
    try {
      final saved = await _repository.saveAddress(request);
      final selectedZone = _findZone(state.deliveryZones, saved.deliveryZoneId);
      emit(
        state.copyWith(
          isSavingAddress: false,
          addresses: [...state.addresses, saved],
          selectedAddress: saved,
          selectedZone: selectedZone,
          clearSelectedZone: selectedZone == null,
        ),
      );
      return true;
    } catch (_) {
      emit(
        state.copyWith(
          isSavingAddress: false,
          addressErrorMessage: 'تعذر حفظ العنوان، حاول مرة أخرى',
        ),
      );
      return false;
    }
  }

  Future<OrderModel?> createOrder({
    required List<CartItemModel> cartItems,
  }) async {
    if (state.status == CheckoutStatus.creating) return null;
    final type = state.serviceType;
    if (type == null ||
        cartItems.isEmpty ||
        (type == ServiceType.delivery &&
            (state.selectedAddress == null || state.selectedZone == null)) ||
        (type == ServiceType.booking && state.booking == null)) {
      emit(
        state.copyWith(
          status: CheckoutStatus.failure,
          clearCreatedOrder: true,
          errorMessage: 'يرجى استكمال بيانات الطلب',
        ),
      );
      return null;
    }
    final booking = type == ServiceType.booking ? state.booking : null;
    if (booking != null) {
      final message = OpeningHoursValidator.validateBooking(
        openingHours: state.openingHours,
        selectedDate: booking.date,
        selectedTime: booking.time,
      );
      if (message != null) {
        emit(
          state.copyWith(
            status: CheckoutStatus.failure,
            clearCreatedOrder: true,
            errorMessage: message,
          ),
        );
        return null;
      }
    }
    emit(
      state.copyWith(status: CheckoutStatus.creating, clearCreatedOrder: true),
    );
    try {
      final request = CreateOrderRequest(
        serviceType: type,
        paymentMethod: state.paymentMethodCode,
        addressId: type == ServiceType.delivery
            ? state.selectedAddress?.id
            : null,
        deliveryZoneId: type == ServiceType.delivery
            ? state.selectedZone?.id
            : null,
        booking: booking,
        items: cartItems
            .map(
              (item) => CreateOrderItemRequest(
                productId: item.product.id,
                quantity: item.quantity,
                optionIds: item.selectedOptions
                    .map((option) => option.id)
                    .toList(),
                notes: item.notes,
              ),
            )
            .toList(),
      );
      final created = await _repository.createOrder(request);
      emit(
        state.copyWith(status: CheckoutStatus.success, createdOrder: created),
      );
      return created;
    } catch (_) {
      emit(
        state.copyWith(
          status: CheckoutStatus.failure,
          errorMessage: 'تعذر إنشاء الطلب، تحقق من البيانات وحاول مرة أخرى',
        ),
      );
      return null;
    }
  }
}

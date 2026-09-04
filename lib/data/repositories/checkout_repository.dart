import 'package:sultan_app/data/dummy/dummy_data.dart';
import 'package:sultan_app/core/utils/opening_hours_validator.dart';
import 'package:sultan_app/data/repositories/address_repository.dart';
import 'package:sultan_app/models/address_model.dart';
import 'package:sultan_app/models/booking_model.dart';
import 'package:sultan_app/models/delivery_zone_model.dart';
import 'package:sultan_app/models/order_item_model.dart';
import 'package:sultan_app/models/order_model.dart';
import 'package:sultan_app/models/order_types.dart';
import 'package:sultan_app/models/requests/create_address_request.dart';
import 'package:sultan_app/models/requests/create_order_item_request.dart';
import 'package:sultan_app/models/requests/create_order_request.dart';

abstract interface class CheckoutRepository {
  Future<List<AddressModel>> getSavedAddresses();
  Future<List<DeliveryZoneModel>> getDeliveryZones();
  Future<AddressModel> saveAddress(CreateAddressRequest request);
  Future<OrderModel> createOrder(CreateOrderRequest request);
}

class DummyCheckoutRepository implements CheckoutRepository {
  DummyCheckoutRepository({AddressRepository? addressRepository})
    : _addressRepository = addressRepository ?? DummyAddressRepository();

  final AddressRepository _addressRepository;

  @override
  Future<List<AddressModel>> getSavedAddresses() async =>
      _addressRepository.getAddresses();

  @override
  Future<List<DeliveryZoneModel>> getDeliveryZones() async =>
      DummyData.deliveryZones;

  @override
  Future<AddressModel> saveAddress(CreateAddressRequest request) async {
    return _addressRepository.createAddress(request);
  }

  @override
  Future<OrderModel> createOrder(CreateOrderRequest request) async {
    if (request.items.isEmpty) throw StateError('Empty order');
    final isDelivery = request.serviceType == ServiceType.delivery;
    final expectedPayment = isDelivery
        ? PaymentMethod.cashOnDelivery
        : PaymentMethod.payAtCafe;
    if (request.paymentMethod != expectedPayment) {
      throw StateError('Unsupported payment method');
    }

    AddressModel? address;
    BookingModel? booking;
    DeliveryZoneModel? deliveryZone;
    var deliveryFee = 0.0;
    if (isDelivery) {
      if (request.booking != null) throw StateError('Unexpected booking');
      final addresses = await _addressRepository.getAddresses();
      address = addresses.firstWhere((item) => item.id == request.addressId);
      final zone = DummyData.deliveryZones.firstWhere(
        (item) => item.id == request.deliveryZoneId,
      );
      deliveryFee = zone.deliveryFee;
      deliveryZone = zone;
    } else {
      if (request.addressId != null || request.deliveryZoneId != null) {
        throw StateError('Unexpected delivery data');
      }
      final selection = request.booking;
      if (selection == null || selection.peopleCount < 1) {
        throw StateError('Incomplete booking');
      }
      final error = OpeningHoursValidator.validateBooking(
        openingHours: DummyData.cafeInfo.openingHours,
        selectedDate: selection.date,
        selectedTime: selection.time,
      );
      if (error != null) throw StateError(error);
      booking = BookingModel(
        id: _nextId(
          DummyData.orders.map((order) => order.booking?.id).whereType<int>(),
        ),
        date: _formatDate(selection.date),
        time: selection.time,
        peopleCount: selection.peopleCount,
        notes: selection.notes,
        status: 'pending',
      );
    }

    // Simulate authoritative server prices, never prices from the cart/UI.
    final items = request.items.map(_resolveItem).toList();
    final subtotal = _money(
      items.fold<double>(
        0,
        (sum, item) => sum + item.unitPrice * item.quantity,
      ),
    );
    final order = OrderModel(
      id: _nextId(DummyData.orders.map((item) => item.id)),
      status: 'pending',
      createdAt: DateTime.now(),
      subtotal: subtotal,
      deliveryFee: _money(deliveryFee),
      total: _money(subtotal + deliveryFee),
      items: items,
      serviceType: request.serviceType.name,
      paymentMethod: request.paymentMethod.code,
      address: address,
      deliveryZone: deliveryZone,
      booking: booking,
      notes: request.notes,
    );
    DummyData.orders.add(order);
    return order;
  }

  OrderItemModel _resolveItem(CreateOrderItemRequest request) {
    final product = DummyData.products.firstWhere(
      (item) => item.id == request.productId,
    );
    if (!product.isAvailable || request.quantity < 1) {
      throw StateError('Unavailable product or invalid quantity');
    }
    final ids = request.optionIds.toSet();
    if (ids.length != request.optionIds.length) {
      throw StateError('Duplicate options');
    }
    final options = product.optionGroups
        .expand((group) => group.options)
        .where((option) => ids.contains(option.id))
        .toList();
    if (options.length != ids.length) throw StateError('Unknown options');
    for (final group in product.optionGroups) {
      final count = group.options
          .where((option) => ids.contains(option.id))
          .length;
      if ((group.isRequired && count == 0) ||
          (!group.allowsMultiple && count > 1)) {
        throw StateError('Invalid option group selection');
      }
    }
    return OrderItemModel(
      productId: product.id,
      productName: product.name,
      quantity: request.quantity,
      unitPrice: _money(
        product.price +
            options.fold<double>(0, (sum, option) => sum + option.price),
      ),
      selectedOptions: options.map((option) => option.name).toList(),
      notes: request.notes,
    );
  }

  int _nextId(Iterable<int> ids) =>
      ids.fold<int>(0, (max, id) => id > max ? id : max) + 1;

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  double _money(double amount) => (amount * 100).round() / 100;
}

import 'package:sultan_app/models/order_types.dart';
import 'package:sultan_app/models/requests/create_booking_request.dart';
import 'package:sultan_app/models/requests/create_order_item_request.dart';

class CreateOrderRequest {
  CreateOrderRequest({
    required this.serviceType,
    required this.paymentMethod,
    required List<CreateOrderItemRequest> items,
    this.addressId,
    this.deliveryZoneId,
    this.booking,
    this.notes,
  }) : items = List.unmodifiable(items);

  final ServiceType serviceType;
  final PaymentMethod paymentMethod;
  final List<CreateOrderItemRequest> items;
  final int? addressId;
  final int? deliveryZoneId;
  final CreateBookingRequest? booking;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'service_type': serviceType.name,
    'payment_method': paymentMethod.code,
    'items': items.map((item) => item.toJson()).toList(),
    if (addressId != null) 'address_id': addressId,
    if (deliveryZoneId != null) 'delivery_zone_id': deliveryZoneId,
    if (booking != null) 'booking': booking!.toJson(),
    if (notes != null) 'notes': notes,
  };
}

import 'package:sultan_app/models/address_model.dart';
import 'package:sultan_app/models/booking_model.dart';
import 'package:sultan_app/models/order_item_model.dart';
import 'package:sultan_app/models/delivery_zone_model.dart';

class OrderModel {
  const OrderModel({
    required this.id,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceType,
    required this.paymentMethod,
    this.address,
    this.booking,
    this.notes,
    this.deliveryZone,
  });
  final int id;
  final String status;
  final double total;
  final DateTime createdAt;
  final List<OrderItemModel> items;
  final double subtotal;
  final double deliveryFee;
  final String serviceType;
  final String paymentMethod;
  final AddressModel? address;
  final BookingModel? booking;
  final String? notes;
  final DeliveryZoneModel? deliveryZone;

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id'] as int,
    status: json['status'] as String,
    total: (json['total'] as num).toDouble(),
    createdAt: DateTime.parse(json['created_at'] as String),
    items: (json['items'] as List<dynamic>)
        .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
        .toList(),
    subtotal: (json['subtotal'] as num).toDouble(),
    deliveryFee: (json['delivery_fee'] as num).toDouble(),
    serviceType: json['service_type'] as String,
    paymentMethod: json['payment_method'] as String,
    address: json['address'] == null
        ? null
        : AddressModel.fromJson(json['address'] as Map<String, dynamic>),
    booking: json['booking'] == null
        ? null
        : BookingModel.fromJson(json['booking'] as Map<String, dynamic>),
    notes: json['notes'] as String?,
    deliveryZone: json['delivery_zone'] == null
        ? null
        : DeliveryZoneModel.fromJson(
            json['delivery_zone'] as Map<String, dynamic>,
          ),
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status,
    'total': total,
    'created_at': createdAt.toIso8601String(),
    'items': items.map((item) => item.toJson()).toList(),
    'subtotal': subtotal,
    'delivery_fee': deliveryFee,
    'service_type': serviceType,
    'payment_method': paymentMethod,
    'address': address?.toJson(),
    'booking': booking?.toJson(),
    'notes': notes,
    'delivery_zone': deliveryZone?.toJson(),
  };
}

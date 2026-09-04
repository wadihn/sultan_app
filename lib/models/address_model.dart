class AddressModel {
  const AddressModel({
    required this.id,
    required this.title,
    required this.addressLine,
    required this.phone,
    this.isDefault = false,
    this.landmark,
    this.deliveryNotes,
    this.deliveryZoneId,
    this.deliveryZoneName,
  });
  final int id;
  final String title;
  final String addressLine;
  final String phone;
  final bool isDefault;
  final String? landmark;
  final String? deliveryNotes;
  final int? deliveryZoneId;
  final String? deliveryZoneName;

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
    id: json['id'] as int,
    title: json['title'] as String,
    addressLine: json['address_line'] as String,
    phone: json['phone'] as String,
    isDefault: json['is_default'] as bool? ?? false,
    landmark: json['landmark'] as String?,
    deliveryNotes: json['delivery_notes'] as String?,
    deliveryZoneId:
        json['delivery_zone_id'] as int? ??
        (json['delivery_zone'] as Map<String, dynamic>?)?['id'] as int?,
    deliveryZoneName:
        (json['delivery_zone'] as Map<String, dynamic>?)?['name'] as String? ??
        json['delivery_zone_name'] as String?,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'address_line': addressLine,
    'phone': phone,
    'is_default': isDefault,
    'landmark': landmark,
    'delivery_notes': deliveryNotes,
    'delivery_zone_id': deliveryZoneId,
    'delivery_zone_name': deliveryZoneName,
  };
}

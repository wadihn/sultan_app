class UpdateAddressRequest {
  const UpdateAddressRequest({
    required this.title,
    required this.phone,
    required this.addressLine,
    required this.deliveryZoneId,
    this.landmark,
    this.deliveryNotes,
  });

  final String title;
  final String phone;
  final String addressLine;
  final int deliveryZoneId;
  final String? landmark;
  final String? deliveryNotes;

  Map<String, dynamic> toJson() => {
    'title': title,
    'phone': phone,
    'address_line': addressLine,
    'delivery_zone_id': deliveryZoneId,
    if (landmark != null) 'landmark': landmark,
    if (deliveryNotes != null) 'delivery_notes': deliveryNotes,
  };
}

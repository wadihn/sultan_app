class DeliveryZoneModel {
  const DeliveryZoneModel({
    required this.id,
    required this.name,
    required this.deliveryFee,
  });
  final int id;
  final String name;
  final double deliveryFee;

  factory DeliveryZoneModel.fromJson(Map<String, dynamic> json) =>
      DeliveryZoneModel(
        id: json['id'] as int,
        name: json['name'] as String,
        deliveryFee: (json['delivery_fee'] as num).toDouble(),
      );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'delivery_fee': deliveryFee,
  };
}

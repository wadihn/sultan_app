import 'package:sultan_app/models/opening_hour_model.dart';

class CafeInfoModel {
  const CafeInfoModel({
    required this.name,
    required this.phone,
    required this.address,
    required this.openingHours,
    this.isOpen = false,
    this.statusMessage = '',
    this.instagramUrl,
  });
  final String name;
  final String phone;
  final String address;
  final List<OpeningHourModel> openingHours;
  final bool isOpen;
  final String statusMessage;
  final String? instagramUrl;

  factory CafeInfoModel.fromJson(Map<String, dynamic> json) => CafeInfoModel(
    name: json['name'] as String,
    phone: json['phone'] as String,
    address: json['address'] as String,
    openingHours: (json['opening_hours'] as List<dynamic>? ?? const [])
        .map((item) => OpeningHourModel.fromJson(item as Map<String, dynamic>))
        .toList(),
    isOpen: json['is_open'] as bool? ?? false,
    statusMessage: json['status_message'] as String? ?? '',
    instagramUrl: json['instagram_url'] as String?,
  );
  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'address': address,
    'opening_hours': openingHours.map((item) => item.toJson()).toList(),
    'is_open': isOpen,
    'status_message': statusMessage,
    'instagram_url': instagramUrl,
  };
}

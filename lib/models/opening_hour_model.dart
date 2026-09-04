class OpeningHourModel {
  const OpeningHourModel({
    required this.dayOfWeek,
    required this.openingTime,
    required this.closingTime,
    required this.isClosed,
  });

  final String dayOfWeek;
  final String openingTime;
  final String closingTime;
  final bool isClosed;

  factory OpeningHourModel.fromJson(Map<String, dynamic> json) =>
      OpeningHourModel(
        dayOfWeek: (json['day_of_week'] as String).toLowerCase(),
        openingTime: json['opening_time'] as String,
        closingTime: json['closing_time'] as String,
        isClosed: json['is_closed'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
    'day_of_week': dayOfWeek,
    'opening_time': openingTime,
    'closing_time': closingTime,
    'is_closed': isClosed,
  };
}

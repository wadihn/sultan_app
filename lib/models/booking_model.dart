class BookingModel {
  const BookingModel({
    required this.id,
    required this.date,
    required this.time,
    required this.peopleCount,
    required this.status,
    this.notes,
  });
  final int id;
  final String date;
  final String time;
  final int peopleCount;
  final String status;
  final String? notes;

  /// Local cafe date and time combined for presentation only.
  /// The API contract remains two independent string fields.
  DateTime get localDateTime => DateTime.parse('${date}T$time:00');

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
    id: json['id'] as int,
    date: json['date'] as String,
    time: json['time'] as String,
    peopleCount: json['people_count'] as int,
    status: json['status'] as String,
    notes: json['notes'] as String?,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'time': time,
    'people_count': peopleCount,
    'status': status,
    'notes': notes,
  };
}

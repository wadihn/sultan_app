class CreateBookingRequest {
  const CreateBookingRequest({
    required this.date,
    required this.time,
    required this.peopleCount,
    this.notes,
  });

  final DateTime date;
  final String time;
  final int peopleCount;
  final String? notes;

  DateTime get dateTime {
    final parts = time.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  Map<String, dynamic> toJson() => {
    'date':
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}',
    'time': time,
    'people_count': peopleCount,
    if (notes != null) 'notes': notes,
  };
}

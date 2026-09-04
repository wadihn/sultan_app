import 'package:sultan_app/models/opening_hour_model.dart';

abstract final class OpeningHoursValidator {
  static const _days = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  static String? validateBooking({
    required List<OpeningHourModel> openingHours,
    required DateTime selectedDate,
    required String selectedTime,
    DateTime? now,
  }) {
    final selectedMinutes = _parseMinutes(selectedTime);
    if (selectedMinutes == null) return 'تعذر التحقق من وقت الحجز';

    final candidate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedMinutes ~/ 60,
      selectedMinutes % 60,
    );
    if (candidate.isBefore(now ?? DateTime.now())) {
      return 'لا يمكن اختيار وقت سابق';
    }

    final currentHours = hoursForDate(openingHours, selectedDate);
    final previousHours = hoursForDate(
      openingHours,
      selectedDate.subtract(const Duration(days: 1)),
    );
    if (_isWithinHours(
          hours: currentHours,
          minutes: selectedMinutes,
          includeAfterMidnight: false,
        ) ||
        _isWithinPreviousDayOvernight(previousHours, selectedMinutes)) {
      return null;
    }

    if (currentHours == null || currentHours.isClosed) {
      return 'الكافيه مغلق في هذا اليوم';
    }
    return 'الكافيه مغلق في هذا الوقت';
  }

  static bool isOpenAt(List<OpeningHourModel> openingHours, DateTime dateTime) {
    final minutes = dateTime.hour * 60 + dateTime.minute;
    final currentHours = hoursForDate(openingHours, dateTime);
    final previousHours = hoursForDate(
      openingHours,
      dateTime.subtract(const Duration(days: 1)),
    );
    return _isWithinHours(
          hours: currentHours,
          minutes: minutes,
          includeAfterMidnight: false,
        ) ||
        _isWithinPreviousDayOvernight(previousHours, minutes);
  }

  static OpeningHourModel? hoursForDate(
    List<OpeningHourModel> openingHours,
    DateTime date,
  ) {
    final day = _days[date.weekday - 1];
    for (final hours in openingHours) {
      if (hours.dayOfWeek.toLowerCase() == day) return hours;
    }
    return null;
  }

  static bool _isWithinHours({
    required OpeningHourModel? hours,
    required int minutes,
    required bool includeAfterMidnight,
  }) {
    if (hours == null || hours.isClosed) return false;
    final opening = _parseMinutes(hours.openingTime);
    final closing = _parseMinutes(hours.closingTime);
    if (opening == null || closing == null) return false;
    if (opening == closing) return true;
    if (closing > opening) {
      return minutes >= opening && minutes <= closing;
    }
    return minutes >= opening || (includeAfterMidnight && minutes <= closing);
  }

  static bool _isWithinPreviousDayOvernight(
    OpeningHourModel? hours,
    int minutes,
  ) {
    if (hours == null || hours.isClosed) return false;
    final opening = _parseMinutes(hours.openingTime);
    final closing = _parseMinutes(hours.closingTime);
    if (opening == null || closing == null || closing >= opening) return false;
    return minutes <= closing;
  }

  static int? _parseMinutes(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return hour * 60 + minute;
  }
}

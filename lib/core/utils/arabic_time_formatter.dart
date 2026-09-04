abstract final class ArabicTimeFormatter {
  static String formatDateTime(DateTime dateTime) =>
      formatHourMinute(dateTime.hour, dateTime.minute);

  static String formatHourMinute(int hour, int minute) {
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final displayMinute = minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'مساءً' : 'صباحًا';
    return '$displayHour:$displayMinute $period';
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:sultan_app/core/utils/opening_hours_validator.dart';
import 'package:sultan_app/models/opening_hour_model.dart';

void main() {
  const hours = [
    OpeningHourModel(
      dayOfWeek: 'monday',
      openingTime: '10:00',
      closingTime: '01:00',
      isClosed: false,
    ),
    OpeningHourModel(
      dayOfWeek: 'tuesday',
      openingTime: '10:00',
      closingTime: '01:00',
      isClosed: true,
    ),
    OpeningHourModel(
      dayOfWeek: 'sunday',
      openingTime: '10:00',
      closingTime: '22:00',
      isClosed: false,
    ),
  ];

  test('يسمح بوقت مسائي ضمن دوام يعبر منتصف الليل', () {
    final result = OpeningHoursValidator.validateBooking(
      openingHours: hours,
      selectedDate: DateTime(2026, 8, 31),
      selectedTime: '23:30',
      now: DateTime(2026, 8, 30),
    );

    expect(result, isNull);
  });

  test('يسمح بالجزء المبكر المغطى من دوام اليوم السابق', () {
    final result = OpeningHoursValidator.validateBooking(
      openingHours: hours,
      selectedDate: DateTime(2026, 9, 1),
      selectedTime: '00:35',
      now: DateTime(2026, 8, 30),
    );

    expect(result, isNull);
  });

  test('يرفض اليوم المغلق خارج امتداد دوام اليوم السابق', () {
    final result = OpeningHoursValidator.validateBooking(
      openingHours: hours,
      selectedDate: DateTime(2026, 9, 1),
      selectedTime: '12:00',
      now: DateTime(2026, 8, 30),
    );

    expect(result, 'الكافيه مغلق في هذا اليوم');
  });

  test('يرفض الوقت السابق في اليوم الحالي', () {
    final result = OpeningHoursValidator.validateBooking(
      openingHours: hours,
      selectedDate: DateTime(2026, 8, 31),
      selectedTime: '10:30',
      now: DateTime(2026, 8, 31, 11),
    );

    expect(result, 'لا يمكن اختيار وقت سابق');
  });

  test('OpeningHourModel يدعم JSON الخاص بـLaravel', () {
    final model = OpeningHourModel.fromJson(const {
      'day_of_week': 'sunday',
      'opening_time': '10:00',
      'closing_time': '01:00',
      'is_closed': false,
    });

    expect(model.dayOfWeek, 'sunday');
    expect(model.toJson()['closing_time'], '01:00');
  });
}

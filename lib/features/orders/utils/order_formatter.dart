import 'package:sultan_app/core/utils/arabic_time_formatter.dart';

abstract final class OrderFormatter {
  static String date(DateTime value) =>
      '${value.day} / ${value.month} / ${value.year}';
  static String time(DateTime value) =>
      ArabicTimeFormatter.formatDateTime(value);
  static String status(String code) => switch (code) {
    'pending' => 'قيد المراجعة',
    'accepted' => 'تم قبول الطلب',
    'ready' => 'الطلب جاهز',
    'cancelled' => 'تم إلغاء الطلب',
    _ => 'حالة غير معروفة',
  };
  static String service(String code) => switch (code) {
    'booking' => 'حجز طاولة',
    'delivery' => 'توصيل',
    _ => code,
  };
  static String payment(String code) => switch (code) {
    'pay_at_cafe' => 'الدفع في الكافيه',
    'cash_on_delivery' => 'الدفع عند الاستلام',
    _ => code,
  };
}

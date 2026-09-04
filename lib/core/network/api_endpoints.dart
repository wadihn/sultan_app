abstract final class ApiEndpoints {
  // يُضبط عند استلام عنوان Laravel الحقيقي؛ لا يوجد اتصال فعلي حاليًا.
  static const String baseUrl = '';
  static const String login = '/auth/login';
  static const String products = '/products';
  static const String orders = '/orders';
  static const String addresses = '/addresses';
  static String address(int id) => '$addresses/$id';
}

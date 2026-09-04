abstract final class Validators {
  static String? requiredField(String? value, {String fieldName = 'الحقل'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName مطلوب';
    return null;
  }

  static String? email(String? value) {
    final requiredError = requiredField(value, fieldName: 'البريد الإلكتروني');
    if (requiredError != null) return requiredError;
    final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailPattern.hasMatch(value!.trim())
        ? null
        : 'أدخل بريدًا إلكترونيًا صحيحًا';
  }

  static String? phone(String? value) {
    final requiredError = requiredField(value, fieldName: 'رقم الهاتف');
    if (requiredError != null) return requiredError;
    final normalized = value!.replaceAll(RegExp(r'[\s\-()]'), '');
    return RegExp(r'^\+?[0-9]{8,15}$').hasMatch(normalized)
        ? null
        : 'أدخل رقم هاتف صحيحًا';
  }

  static String? emailOrPhone(String? value) {
    final requiredError = requiredField(
      value,
      fieldName: 'البريد أو رقم الهاتف',
    );
    if (requiredError != null) return requiredError;
    return value!.contains('@') ? email(value) : phone(value);
  }

  static String? password(String? value) {
    final requiredError = requiredField(value, fieldName: 'كلمة المرور');
    if (requiredError != null) return requiredError;
    return value!.length >= 8 ? null : 'كلمة المرور يجب ألا تقل عن 8 أحرف';
  }

  static String? confirmPassword(String? value, String password) {
    final passwordError = Validators.password(value);
    if (passwordError != null) return passwordError;
    return value == password ? null : 'كلمتا المرور غير متطابقتين';
  }
}

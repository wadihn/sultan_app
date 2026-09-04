class RegisterRequest {
  const RegisterRequest({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  final String name;
  final String phone;
  final String email;
  final String password;
  final String passwordConfirmation;

  Map<String, dynamic> toJson() => {
    'name': name.trim(),
    'phone': phone.trim(),
    'email': email.trim(),
    'password': password,
    'password_confirmation': passwordConfirmation,
  };
}

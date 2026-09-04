class LoginRequest {
  const LoginRequest({required this.identity, required this.password});

  final String identity;
  final String password;

  Map<String, dynamic> toJson() => {
    identity.contains('@') ? 'email' : 'phone': identity.trim(),
    'password': password,
  };
}

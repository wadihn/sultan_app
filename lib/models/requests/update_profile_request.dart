class UpdateProfileRequest {
  const UpdateProfileRequest({
    required this.name,
    required this.phone,
    this.email,
  });

  final String name;
  final String phone;
  final String? email;

  Map<String, dynamic> toJson() => {
    'name': name.trim(),
    'phone': phone.trim(),
    'email': email?.trim(),
  };
}

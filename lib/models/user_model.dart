class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
  });
  final int id;
  final String name;
  final String phone;
  final String? email;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as int,
    name: json['name'] as String,
    phone: json['phone'] as String,
    email: json['email'] as String?,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
  };
}

import 'package:sultan_app/models/user_model.dart';

class AuthResponseModel {
  const AuthResponseModel({required this.token, required this.user});
  final String token;
  final UserModel user;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      AuthResponseModel(
        token: json['token'] as String,
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      );
  Map<String, dynamic> toJson() => {'token': token, 'user': user.toJson()};
}

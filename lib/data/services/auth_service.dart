import 'package:dio/dio.dart';
import 'package:sultan_app/models/auth_response_model.dart';
import 'package:sultan_app/models/user_model.dart';
import 'package:sultan_app/models/requests/login_request.dart';
import 'package:sultan_app/models/requests/register_request.dart';

/// نقطة توسعة لاتصال Laravel الحقيقي. لا تنفذ طلبات في مرحلة الـFoundation.
class AuthService {
  const AuthService(this._dio);
  final Dio _dio;

  Dio get client => _dio;

  // TODO: Implement using the centralized Dio client once Laravel is available.
  // No HTTP calls or dummy success responses belong in these remote methods.
  Future<AuthResponseModel> login(LoginRequest request) async =>
      throw UnsupportedError('Laravel Auth is not configured');
  Future<AuthResponseModel> register(RegisterRequest request) async =>
      throw UnsupportedError('Laravel Auth is not configured');
  Future<void> logout() async =>
      throw UnsupportedError('Laravel Auth is not configured');
  Future<UserModel> getCurrentUser() async =>
      throw UnsupportedError('Laravel Auth is not configured');
}

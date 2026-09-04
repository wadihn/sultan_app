import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _authTokenKey = 'auth_token';
  static const _authUserKey = 'auth_user';
  final FlutterSecureStorage _storage;

  Future<void> saveAuthToken(String token) =>
      _storage.write(key: _authTokenKey, value: token);
  Future<String?> readAuthToken() => _storage.read(key: _authTokenKey);
  Future<void> deleteAuthToken() => _storage.delete(key: _authTokenKey);

  Future<void> saveAuthUser(String json) =>
      _storage.write(key: _authUserKey, value: json);
  Future<String?> readAuthUser() => _storage.read(key: _authUserKey);
  Future<void> deleteAuthUser() => _storage.delete(key: _authUserKey);
}

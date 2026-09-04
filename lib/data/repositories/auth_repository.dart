import 'dart:convert';
import 'dart:math';

import 'package:sultan_app/core/storage/secure_storage_service.dart';
import 'package:sultan_app/core/utils/validators.dart';
import 'package:sultan_app/models/auth_response_model.dart';
import 'package:sultan_app/models/requests/login_request.dart';
import 'package:sultan_app/models/requests/register_request.dart';
import 'package:sultan_app/models/user_model.dart';

abstract interface class AuthRepository {
  Future<AuthResponseModel> login(LoginRequest request);
  Future<AuthResponseModel> register(RegisterRequest request);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<void> updateCurrentUser(UserModel user);
  Future<bool> hasValidSession();
}

/// Development simulation only: accepts valid-shaped credentials, not real authentication.
/// Passwords are never persisted. Replace this implementation for Laravel.
class DummyAuthRepository implements AuthRepository {
  DummyAuthRepository(this._storage);
  final SecureStorageService _storage;
  UserModel? _currentUser;

  @override
  Future<AuthResponseModel> login(LoginRequest request) async {
    if (Validators.emailOrPhone(request.identity) != null ||
        Validators.password(request.password) != null) {
      throw const FormatException('Invalid login input');
    }
    final identity = request.identity.trim();
    final previous = await _readSavedUser();
    final user =
        previous != null &&
            (previous.email == identity || previous.phone == identity)
        ? previous
        : UserModel(
            id: 1,
            name: 'مستخدم تجريبي',
            phone: identity.contains('@') ? '' : identity,
            email: identity.contains('@') ? identity : null,
          );
    return _saveSession(user);
  }

  @override
  Future<AuthResponseModel> register(RegisterRequest request) async {
    if (Validators.requiredField(request.name) != null ||
        Validators.phone(request.phone) != null ||
        Validators.email(request.email) != null ||
        Validators.confirmPassword(
              request.passwordConfirmation,
              request.password,
            ) !=
            null) {
      throw const FormatException('Invalid registration input');
    }
    final previous = await _readSavedUser();
    return _saveSession(
      UserModel(
        id: (previous?.id ?? 0) + 1,
        name: request.name.trim(),
        phone: request.phone.trim(),
        email: request.email.trim(),
      ),
    );
  }

  Future<AuthResponseModel> _saveSession(UserModel user) async {
    final random = Random.secure();
    final token =
        'dummy_${base64UrlEncode(List.generate(32, (_) => random.nextInt(256)))}';
    final response = AuthResponseModel(token: token, user: user);
    // Invalidate the old session first; a storage failure must not become a login success.
    _currentUser = null;
    await _storage.deleteAuthToken();
    try {
      await _storage.saveAuthUser(jsonEncode(response.user.toJson()));
      await _storage.saveAuthToken(response.token);
    } catch (_) {
      await _storage.deleteAuthToken();
      rethrow;
    }
    _currentUser = response.user;
    return response;
  }

  @override
  Future<bool> hasValidSession() async =>
      (await _storage.readAuthToken())?.trim().isNotEmpty ?? false;

  @override
  Future<UserModel?> getCurrentUser() async {
    if (!await hasValidSession()) {
      _currentUser = null;
      return null;
    }
    return _currentUser ??= await _readSavedUser();
  }

  @override
  Future<void> updateCurrentUser(UserModel user) async {
    if (!await hasValidSession()) throw StateError('Unauthenticated');
    await _storage.saveAuthUser(jsonEncode(user.toJson()));
    _currentUser = user;
  }

  Future<UserModel?> _readSavedUser() async {
    final json = await _storage.readAuthUser();
    if (json == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _storage.deleteAuthToken();
    _currentUser = null;
    await _storage.deleteAuthUser();
  }
}

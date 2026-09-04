import 'package:sultan_app/core/utils/validators.dart';
import 'package:sultan_app/data/repositories/auth_repository.dart';
import 'package:sultan_app/models/requests/update_profile_request.dart';
import 'package:sultan_app/models/user_model.dart';

abstract interface class ProfileRepository {
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile(UpdateProfileRequest request);
}

/// Uses the same authenticated-user source as Auth; no duplicate profile store.
class DummyProfileRepository implements ProfileRepository {
  DummyProfileRepository(this._authRepository);
  final AuthRepository _authRepository;

  @override
  Future<UserModel> getProfile() async {
    final user = await _authRepository.getCurrentUser();
    if (user == null) throw StateError('Unauthenticated');
    return user;
  }

  @override
  Future<UserModel> updateProfile(UpdateProfileRequest request) async {
    if (Validators.requiredField(request.name, fieldName: 'الاسم') != null ||
        Validators.phone(request.phone) != null ||
        (request.email?.isNotEmpty == true &&
            Validators.email(request.email) != null)) {
      throw const FormatException('Invalid profile input');
    }
    final current = await getProfile();
    final updated = UserModel(
      id: current.id,
      name: request.name.trim(),
      phone: request.phone.trim(),
      email: request.email?.trim().isEmpty == true
          ? null
          : request.email?.trim(),
    );
    await _authRepository.updateCurrentUser(updated);
    return updated;
  }
}

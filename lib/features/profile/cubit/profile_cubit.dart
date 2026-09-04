import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/data/repositories/profile_repository.dart';
import 'package:sultan_app/features/profile/cubit/profile_state.dart';
import 'package:sultan_app/models/requests/update_profile_request.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository) : super(const ProfileState());
  final ProfileRepository _repository;

  Future<void> loadProfile() async {
    if (state.status == ProfileStatus.loading || state.isUpdating) return;
    emit(ProfileState(status: ProfileStatus.loading, user: state.user));
    try {
      final user = await _repository.getProfile();
      if (!isClosed) {
        emit(ProfileState(status: ProfileStatus.success, user: user));
      }
    } catch (_) {
      if (!isClosed) {
        emit(
          const ProfileState(
            status: ProfileStatus.failure,
            errorMessage: 'تعذر تحميل بيانات الحساب',
          ),
        );
      }
    }
  }

  Future<bool> updateProfile(UpdateProfileRequest request) async {
    if (state.isUpdating) return false;
    emit(ProfileState(status: ProfileStatus.updating, user: state.user));
    try {
      final user = await _repository.updateProfile(request);
      if (!isClosed) {
        emit(ProfileState(status: ProfileStatus.success, user: user));
      }
      return true;
    } catch (_) {
      if (!isClosed) {
        emit(
          ProfileState(
            status: ProfileStatus.failure,
            user: state.user,
            errorMessage: 'تعذر تحديث بيانات الحساب',
          ),
        );
      }
      return false;
    }
  }

  void clearProfile() => emit(const ProfileState());
}

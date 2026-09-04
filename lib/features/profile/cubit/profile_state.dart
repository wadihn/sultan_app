import 'package:sultan_app/models/user_model.dart';

enum ProfileStatus { initial, loading, success, updating, failure }

class ProfileState {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.errorMessage,
  });

  final ProfileStatus status;
  final UserModel? user;
  final String? errorMessage;

  bool get isUpdating => status == ProfileStatus.updating;
}

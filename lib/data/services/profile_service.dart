import 'package:dio/dio.dart';
import 'package:sultan_app/models/requests/update_profile_request.dart';
import 'package:sultan_app/models/user_model.dart';

/// Future remote contract; no HTTP requests are executed in the dummy phase.
class ProfileService {
  const ProfileService(this.client);
  final Dio client;

  // TODO: GET /profile and PUT /profile after Laravel is available.
  Future<UserModel> getProfile() async =>
      throw UnsupportedError('Laravel Profile is not configured');
  Future<UserModel> updateProfile(UpdateProfileRequest request) async =>
      throw UnsupportedError('Laravel Profile is not configured');
}

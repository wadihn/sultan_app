import 'package:sultan_app/models/user_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

class AuthState {
  const AuthState({
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.acceptedPrivacy = false,
  });

  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  bool get isLoading => status == AuthStatus.loading;
  final bool acceptedPrivacy;

  AuthState copyWith({
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
    AuthStatus? status,
    UserModel? user,
    bool clearUser = false,
    String? errorMessage,
    bool? acceptedPrivacy,
  }) => AuthState(
    isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
    isConfirmPasswordVisible:
        isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
    status: status ?? this.status,
    user: clearUser ? null : user ?? this.user,
    errorMessage: errorMessage,
    acceptedPrivacy: acceptedPrivacy ?? this.acceptedPrivacy,
  );
}

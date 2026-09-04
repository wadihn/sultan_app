import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/features/auth/cubit/auth_state.dart';
import 'package:sultan_app/data/repositories/auth_repository.dart';
import 'package:sultan_app/models/auth_response_model.dart';
import 'package:sultan_app/models/requests/login_request.dart';
import 'package:sultan_app/models/requests/register_request.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState());
  final AuthRepository _repository;

  void togglePasswordVisibility() =>
      emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));

  void toggleConfirmPasswordVisibility() => emit(
    state.copyWith(isConfirmPasswordVisible: !state.isConfirmPasswordVisible),
  );

  void setPrivacyAccepted({required bool value}) =>
      emit(state.copyWith(acceptedPrivacy: value));

  Future<bool> login(LoginRequest request) => _authenticate(
    () => _repository.login(request),
    'تعذر تسجيل الدخول، تحقق من البيانات وحاول مرة أخرى',
  );

  Future<bool> register(RegisterRequest request) => _authenticate(
    () => _repository.register(request),
    'تعذر إنشاء الحساب، حاول مرة أخرى',
  );

  Future<bool> _authenticate(
    Future<AuthResponseModel> Function() action,
    String message,
  ) async {
    if (state.isLoading) return false;
    emit(state.copyWith(status: AuthStatus.loading, clearUser: true));
    try {
      final response = await action();
      emit(
        state.copyWith(status: AuthStatus.authenticated, user: response.user),
      );
      return true;
    } catch (_) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          clearUser: true,
          errorMessage: message,
        ),
      );
      return false;
    }
  }

  Future<void> checkSession() async {
    if (state.isLoading) return;
    emit(state.copyWith(status: AuthStatus.loading, clearUser: true));
    try {
      if (!await _repository.hasValidSession()) {
        emit(
          state.copyWith(status: AuthStatus.unauthenticated, clearUser: true),
        );
        return;
      }
      final user = await _repository.getCurrentUser();
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } catch (_) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          clearUser: true,
          errorMessage: 'تعذر استعادة الجلسة، حاول مرة أخرى',
        ),
      );
    }
  }

  Future<void> loadCurrentUser() => checkSession();

  Future<bool> logout() async {
    if (state.isLoading) return false;
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _repository.logout();
      emit(const AuthState(status: AuthStatus.unauthenticated));
      return true;
    } catch (_) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'تعذر تسجيل الخروج، حاول مرة أخرى',
        ),
      );
      return false;
    }
  }
}

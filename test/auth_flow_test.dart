import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sultan_app/app/routes.dart';
import 'package:sultan_app/core/storage/secure_storage_service.dart';
import 'package:sultan_app/core/theme/app_theme.dart';
import 'package:sultan_app/data/repositories/auth_repository.dart';
import 'package:sultan_app/features/auth/cubit/auth_cubit.dart';
import 'package:sultan_app/features/auth/cubit/auth_state.dart';
import 'package:sultan_app/features/auth/screens/login_screen.dart';
import 'package:sultan_app/features/auth/screens/register_screen.dart';
import 'package:sultan_app/features/splash/screens/splash_screen.dart';
import 'package:sultan_app/models/auth_response_model.dart';
import 'package:sultan_app/models/requests/login_request.dart';
import 'package:sultan_app/models/requests/register_request.dart';

const registration = RegisterRequest(
  name: 'أحمد',
  phone: '0791234567',
  email: 'ahmad@example.com',
  password: 'password123',
  passwordConfirmation: 'password123',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('Requests serialize actual fields without user IDs', () {
    expect(
      const LoginRequest(
        identity: 'ahmad@example.com',
        password: 'secret',
      ).toJson(),
      {'email': 'ahmad@example.com', 'password': 'secret'},
    );
    expect(
      const LoginRequest(identity: '0791234567', password: 'secret').toJson(),
      {'phone': '0791234567', 'password': 'secret'},
    );
    expect(registration.toJson(), {
      'name': 'أحمد',
      'phone': '0791234567',
      'email': 'ahmad@example.com',
      'password': 'password123',
      'password_confirmation': 'password123',
    });
  });

  test('Register persists token/user, restores across repositories, logout clears both', () async {
    final storage = SecureStorageService();
    final repo = DummyAuthRepository(storage);
    final response = await repo.register(registration);
    expect(await storage.readAuthToken(), response.token);
    expect(await storage.readAuthUser(), isNot(contains('password')));
    expect(
      AuthResponseModel.fromJson(response.toJson()).toJson(),
      response.toJson(),
    );
    final restarted = DummyAuthRepository(SecureStorageService());
    expect(await restarted.hasValidSession(), isTrue);
    expect((await restarted.getCurrentUser())?.name, 'أحمد');
    await restarted.logout();
    expect(await storage.readAuthToken(), isNull);
    expect(await storage.readAuthUser(), isNull);
    expect(await restarted.hasValidSession(), isFalse);
    expect(await restarted.getCurrentUser(), isNull);
  });

  test(
    'Cubit uses repository for login/session/logout and maps failures',
    () async {
      final cubit = AuthCubit(DummyAuthRepository(SecureStorageService()));
      addTearDown(cubit.close);
      await cubit.checkSession();
      expect(cubit.state.status, AuthStatus.unauthenticated);
      final success = await cubit.login(
        const LoginRequest(identity: '0791234567', password: 'password123'),
      );
      expect(success, isTrue);
      expect(cubit.state.user?.phone, '0791234567');
      expect(cubit.state.status, AuthStatus.authenticated);
      await cubit.logout();
      expect(cubit.state.status, AuthStatus.unauthenticated);
      expect(cubit.state.user, isNull);
      expect(
        await cubit.login(const LoginRequest(identity: '', password: '')),
        isFalse,
      );
      expect(cubit.state.status, AuthStatus.failure);
      expect(cubit.state.errorMessage, isNot(contains('FormatException')));
    },
  );

  test('Storage failure does not produce authenticated success', () async {
    final cubit = AuthCubit(DummyAuthRepository(_FailingStorage()));
    addTearDown(cubit.close);
    expect(await cubit.register(registration), isFalse);
    expect(cubit.state.status, AuthStatus.failure);
    expect(cubit.state.user, isNull);
    expect(await SecureStorageService().readAuthToken(), isNull);
  });

  for (final saved in [false, true]) {
    testWidgets('Splash routes from repository session: $saved', (
      tester,
    ) async {
      final repo = DummyAuthRepository(SecureStorageService());
      if (saved) await repo.register(registration);
      final cubit = AuthCubit(DummyAuthRepository(SecureStorageService()));
      addTearDown(cubit.close);
      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: MaterialApp(
            home: const SplashScreen(),
            routes: {
              AppRoutes.login: (_) =>
                  const Scaffold(body: Text('login target')),
              AppRoutes.mainNavigation: (_) =>
                  const Scaffold(body: Text('main target')),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(saved ? 'main target' : 'login target'), findsOneWidget);
    });
  }

  for (final register in [false, true]) {
    testWidgets(
      'Auth form submits real fields and navigates: register=$register',
      (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final cubit = AuthCubit(DummyAuthRepository(SecureStorageService()));
        addTearDown(cubit.close);
        await tester.pumpWidget(
          BlocProvider.value(
            value: cubit,
            child: MaterialApp(
              theme: AppTheme.light,
              builder: (_, child) => Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              ),
              home: register ? const RegisterScreen() : const LoginScreen(),
              routes: {
                AppRoutes.mainNavigation: (_) =>
                    const Scaffold(body: Text('main target')),
              },
            ),
          ),
        );
        final values = register
            ? [
                'أحمد',
                '0791234567',
                'ahmad@example.com',
                'password123',
                'password123',
              ]
            : ['0791234567', 'password123'];
        for (var i = 0; i < values.length; i++) {
          await tester.enterText(find.byType(TextFormField).at(i), values[i]);
        }
        if (register) {
          await tester.ensureVisible(find.byType(CheckboxListTile));
          await tester.tap(find.byType(CheckboxListTile));
          await tester.pump();
        }
        await tester.ensureVisible(find.byType(FilledButton));
        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();
        expect(find.text('main target'), findsOneWidget);
        expect(cubit.state.user?.phone, '0791234567');
        if (register) expect(cubit.state.user?.name, 'أحمد');
        expect(tester.takeException(), isNull);
      },
    );
  }
}

class _FailingStorage extends SecureStorageService {
  @override
  Future<void> saveAuthToken(String token) async =>
      throw StateError('storage failure');
}

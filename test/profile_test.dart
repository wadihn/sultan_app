import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sultan_app/app/routes.dart';
import 'package:sultan_app/core/storage/secure_storage_service.dart';
import 'package:sultan_app/core/theme/app_theme.dart';
import 'package:sultan_app/core/widgets/loading_widget.dart';
import 'package:sultan_app/data/repositories/auth_repository.dart';
import 'package:sultan_app/data/repositories/address_repository.dart';
import 'package:sultan_app/data/repositories/checkout_repository.dart';
import 'package:sultan_app/data/repositories/home_repository.dart';
import 'package:sultan_app/data/repositories/profile_repository.dart';
import 'package:sultan_app/features/addresses/screens/saved_addresses_screen.dart';
import 'package:sultan_app/features/auth/cubit/auth_cubit.dart';
import 'package:sultan_app/features/auth/screens/login_screen.dart';
import 'package:sultan_app/features/cafe_info/screens/cafe_info_screen.dart';
import 'package:sultan_app/features/cart/cubit/cart_cubit.dart';
import 'package:sultan_app/features/checkout/cubit/checkout_cubit.dart';
import 'package:sultan_app/features/privacy/screens/privacy_policy_screen.dart';
import 'package:sultan_app/features/profile/cubit/profile_cubit.dart';
import 'package:sultan_app/features/profile/cubit/profile_state.dart';
import 'package:sultan_app/features/profile/screens/edit_profile_screen.dart';
import 'package:sultan_app/features/profile/screens/profile_screen.dart';
import 'package:sultan_app/models/requests/register_request.dart';
import 'package:sultan_app/models/requests/update_profile_request.dart';
import 'package:sultan_app/models/user_model.dart';

const registration = RegisterRequest(
  name: 'أحمد السلطان',
  phone: '0791234567',
  email: 'ahmad@example.com',
  password: 'password123',
  passwordConfirmation: 'password123',
);

class _FailureProfileRepository implements ProfileRepository {
  @override
  Future<UserModel> getProfile() async => throw StateError('private error');
  @override
  Future<UserModel> updateProfile(UpdateProfileRequest request) async =>
      throw StateError('private error');
}

class _PendingProfileRepository implements ProfileRepository {
  final completer = Completer<UserModel>();
  @override
  Future<UserModel> getProfile() => completer.future;
  @override
  Future<UserModel> updateProfile(UpdateProfileRequest request) =>
      completer.future;
}

Widget _profileApp({
  required ProfileRepository profileRepository,
  required AuthRepository authRepository,
}) {
  final home = DummyHomeRepository();
  final addresses = DummyAddressRepository();
  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider<HomeRepository>.value(value: home),
      RepositoryProvider<AddressRepository>.value(value: addresses),
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(authRepository)),
        BlocProvider(create: (_) => ProfileCubit(profileRepository)),
        BlocProvider(create: (_) => CartCubit()),
        BlocProvider(
          create: (_) =>
              CheckoutCubit(DummyCheckoutRepository(), home)..loadData(),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        builder: (_, child) =>
            Directionality(textDirection: TextDirection.rtl, child: child!),
        home: const Scaffold(body: ProfileScreen()),
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test(
    'Request has no server fields and profile updates the shared Auth user',
    () async {
      const request = UpdateProfileRequest(
        name: 'الاسم الجديد',
        phone: '0787654321',
        email: 'new@example.com',
      );
      expect(request.toJson(), {
        'name': 'الاسم الجديد',
        'phone': '0787654321',
        'email': 'new@example.com',
      });
      expect(request.toJson().containsKey('id'), isFalse);
      final auth = DummyAuthRepository(SecureStorageService());
      final original = await auth.register(registration);
      final profile = DummyProfileRepository(auth);
      expect(identical(await profile.getProfile(), original.user), isTrue);
      final updated = await profile.updateProfile(request);
      expect(updated.id, original.user.id);
      expect((await auth.getCurrentUser())?.toJson(), updated.toJson());
      expect(
        await SecureStorageService().readAuthUser(),
        contains('الاسم الجديد'),
      );
    },
  );

  test(
    'ProfileCubit supports loading, success, update and mapped failure',
    () async {
      final pending = _PendingProfileRepository();
      final cubit = ProfileCubit(pending);
      addTearDown(cubit.close);
      final task = cubit.loadProfile();
      expect(cubit.state.status, ProfileStatus.loading);
      pending.completer.complete(
        const UserModel(id: 1, name: 'أحمد', phone: '0791234567'),
      );
      await task;
      expect(cubit.state.status, ProfileStatus.success);
      final failing = ProfileCubit(_FailureProfileRepository());
      addTearDown(failing.close);
      await failing.loadProfile();
      expect(failing.state.status, ProfileStatus.failure);
      expect(failing.state.errorMessage, 'تعذر تحميل بيانات الحساب');
      expect(
        await failing.updateProfile(
          const UpdateProfileRequest(name: 'أحمد', phone: '0791234567'),
        ),
        isFalse,
      );
      expect(failing.state.errorMessage, 'تعذر تحديث بيانات الحساب');
    },
  );

  testWidgets('Profile shows loading and retryable failure', (tester) async {
    final auth = DummyAuthRepository(SecureStorageService());
    await tester.pumpWidget(
      _profileApp(
        profileRepository: _PendingProfileRepository(),
        authRepository: auth,
      ),
    );
    await tester.pump();
    expect(find.byType(LoadingWidget), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pumpWidget(
      _profileApp(
        profileRepository: _FailureProfileRepository(),
        authRepository: auth,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('تعذر تحميل بيانات الحساب'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);
  });

  for (final size in [const Size(320, 568), const Size(430, 932)]) {
    testWidgets('Profile edit/routes/logout are responsive at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final auth = DummyAuthRepository(SecureStorageService());
      await auth.register(registration);
      final profile = DummyProfileRepository(auth);
      await tester.pumpWidget(
        _profileApp(profileRepository: profile, authRepository: auth),
      );
      await tester.pumpAndSettle();
      final profileCubit = tester
          .element(find.byType(ProfileScreen))
          .read<ProfileCubit>();

      expect(
        Directionality.of(tester.element(find.byType(ProfileScreen))),
        TextDirection.rtl,
      );
      expect(find.text('أحمد السلطان'), findsOneWidget);
      expect(find.text('0791234567'), findsOneWidget);
      expect(find.text('ahmad@example.com'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(find.byType(CircleAvatar), findsNothing);
      for (final excluded in ['المفضلة', 'طلباتي', 'حجوزاتي']) {
        expect(find.text(excluded), findsNothing);
      }

      await tester.ensureVisible(find.text('تعديل الملف الشخصي'));
      await tester.tap(find.text('تعديل الملف الشخصي'));
      await tester.pumpAndSettle();
      expect(find.byType(EditProfileScreen), findsOneWidget);
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'محمود السلطان');
      await tester.enterText(fields.at(1), '0787654321');
      await tester.enterText(fields.at(2), 'mahmoud@example.com');
      await tester.ensureVisible(find.text('حفظ التعديلات'));
      await tester.tap(find.text('حفظ التعديلات'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.text('محمود السلطان'), findsOneWidget);
      expect(find.text('0787654321'), findsOneWidget);
      expect(find.text('mahmoud@example.com'), findsOneWidget);
      expect((await auth.getCurrentUser())?.name, 'محمود السلطان');
      expect(tester.takeException(), isNull);

      await tester.ensureVisible(find.text('العناوين المحفوظة'));
      await tester.tap(find.text('العناوين المحفوظة'));
      await tester.pumpAndSettle();
      expect(find.byType(SavedAddressesScreen), findsOneWidget);
      expect(find.text('متابعة إلى تأكيد الطلب'), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('معلومات الكافيه'));
      await tester.tap(find.text('معلومات الكافيه'));
      await tester.pumpAndSettle();
      expect(find.byType(CafeInfoScreen), findsOneWidget);
      expect(find.text('كافيه السلطان'), findsOneWidget);
      expect(find.text('0790000000'), findsOneWidget);
      expect(find.text('ساعات العمل'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('سياسة الخصوصية'));
      await tester.tap(find.text('سياسة الخصوصية'));
      await tester.pumpAndSettle();
      expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
      expect(find.text('محتوى مؤقت'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('تسجيل الخروج'));
      await tester.tap(find.text('تسجيل الخروج'));
      await tester.pumpAndSettle();
      expect(find.text('هل تريد تسجيل الخروج؟'), findsOneWidget);
      await tester.tap(find.text('إلغاء'));
      await tester.pumpAndSettle();
      expect(await auth.hasValidSession(), isTrue);
      await tester.tap(find.text('تسجيل الخروج'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(TextButton, 'تسجيل الخروج'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(await auth.hasValidSession(), isFalse);
      expect(profileCubit.state.user, isNull);
      expect(tester.takeException(), isNull);
    });
  }
}

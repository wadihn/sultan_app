import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/app/routes.dart';
import 'package:sultan_app/core/constants/app_strings.dart';
import 'package:sultan_app/core/theme/app_colors.dart';
import 'package:sultan_app/core/utils/validators.dart';
import 'package:sultan_app/core/widgets/custom_button.dart';
import 'package:sultan_app/core/widgets/custom_text_field.dart';
import 'package:sultan_app/features/auth/cubit/auth_cubit.dart';
import 'package:sultan_app/features/auth/cubit/auth_state.dart';
import 'package:sultan_app/models/requests/login_request.dart';
import 'package:sultan_app/features/auth/widgets/auth_divider.dart';
import 'package:sultan_app/features/auth/widgets/auth_footer_link.dart';
import 'package:sultan_app/features/auth/widgets/auth_header.dart';
import 'package:sultan_app/features/auth/widgets/auth_page_layout.dart';
import 'package:sultan_app/features/auth/widgets/social_login_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identityController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _identityController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showUnavailableMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ستتوفر هذه الخدمة عند ربط نظام المصادقة')),
    );
  }

  Future<void> _submit(AuthCubit cubit) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final success = await cubit.login(
      LoginRequest(
        identity: _identityController.text.trim(),
        password: _passwordController.text,
      ),
    );
    if (!mounted || !success) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.mainNavigation,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: AuthPageLayout(
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final cubit = context.read<AuthCubit>();
          return AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthHeader(
                    title: AppStrings.welcomeBack,
                    description: AppStrings.loginDescription,
                  ),
                  const SizedBox(height: 28),
                  CustomTextField(
                    controller: _identityController,
                    label: 'البريد الإلكتروني أو رقم الهاتف',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.username],
                    prefixIcon: Icons.person_outline,
                    validator: Validators.emailOrPhone,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'كلمة المرور',
                    obscureText: !state.isPasswordVisible,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    prefixIcon: Icons.lock_outline,
                    validator: Validators.password,
                    onFieldSubmitted: (_) => _submit(cubit),
                    suffixIcon: IconButton(
                      tooltip: state.isPasswordVisible
                          ? 'إخفاء كلمة المرور'
                          : 'إظهار كلمة المرور',
                      onPressed: cubit.togglePasswordVisibility,
                      icon: Icon(
                        state.isPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: _showUnavailableMessage,
                      child: const Text(
                        'نسيت كلمة المرور؟',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ),
                  CustomButton(
                    label: AppStrings.login,
                    isLoading: state.isLoading,
                    onPressed: () => _submit(cubit),
                  ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      state.errorMessage!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ],
                  const SizedBox(height: 22),
                  const AuthDivider(),
                  const SizedBox(height: 18),
                  SocialLoginButton(
                    provider: SocialProvider.google,
                    onPressed: _showUnavailableMessage,
                  ),
                  const SizedBox(height: 12),
                  SocialLoginButton(
                    provider: SocialProvider.facebook,
                    onPressed: _showUnavailableMessage,
                  ),
                  const SizedBox(height: 12),
                  AuthFooterLink(
                    prompt: 'ليس لديك حساب؟',
                    actionLabel: AppStrings.register,
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.register),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}

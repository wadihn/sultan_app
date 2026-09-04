import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/app/routes.dart';
import 'package:sultan_app/models/requests/register_request.dart';
import 'package:sultan_app/core/constants/app_strings.dart';
import 'package:sultan_app/core/theme/app_colors.dart';
import 'package:sultan_app/core/utils/validators.dart';
import 'package:sultan_app/core/widgets/custom_button.dart';
import 'package:sultan_app/core/widgets/custom_text_field.dart';
import 'package:sultan_app/features/auth/cubit/auth_cubit.dart';
import 'package:sultan_app/features/auth/cubit/auth_state.dart';
import 'package:sultan_app/features/auth/widgets/auth_divider.dart';
import 'package:sultan_app/features/auth/widgets/auth_footer_link.dart';
import 'package:sultan_app/features/auth/widgets/auth_header.dart';
import 'package:sultan_app/features/auth/widgets/auth_page_layout.dart';
import 'package:sultan_app/features/auth/widgets/social_login_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showUnavailableMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ستتوفر هذه الخدمة عند ربط نظام المصادقة')),
    );
  }

  Future<void> _submit(AuthCubit cubit, AuthState state) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!state.acceptedPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى الموافقة على سياسة الخصوصية')),
      );
      return;
    }
    final success = await cubit.register(
      RegisterRequest(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
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
    appBar: AppBar(leading: const BackButton()),
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
                    title: AppStrings.register,
                    description: AppStrings.registerDescription,
                  ),
                  const SizedBox(height: 28),
                  CustomTextField(
                    controller: _nameController,
                    label: 'الاسم الكامل',
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    prefixIcon: Icons.person_outline,
                    validator: (value) => Validators.requiredField(
                      value,
                      fieldName: 'الاسم الكامل',
                    ),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _phoneController,
                    label: 'رقم الهاتف',
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    prefixIcon: Icons.phone_outlined,
                    validator: Validators.phone,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _emailController,
                    label: 'البريد الإلكتروني',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    prefixIcon: Icons.email_outlined,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'كلمة المرور',
                    obscureText: !state.isPasswordVisible,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                    prefixIcon: Icons.lock_outline,
                    validator: Validators.password,
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
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'تأكيد كلمة المرور',
                    obscureText: !state.isConfirmPasswordVisible,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    prefixIcon: Icons.lock_outline,
                    validator: (value) => Validators.confirmPassword(
                      value,
                      _passwordController.text,
                    ),
                    onFieldSubmitted: (_) => _submit(cubit, state),
                    suffixIcon: IconButton(
                      tooltip: state.isConfirmPasswordVisible
                          ? 'إخفاء تأكيد كلمة المرور'
                          : 'إظهار تأكيد كلمة المرور',
                      onPressed: cubit.toggleConfirmPasswordVisibility,
                      icon: Icon(
                        state.isConfirmPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  CheckboxListTile(
                    value: state.acceptedPrivacy,
                    onChanged: (value) =>
                        cubit.setPrivacyAccepted(value: value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('أوافق على سياسة الخصوصية'),
                    activeColor: AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  CustomButton(
                    label: AppStrings.register,
                    isLoading: state.isLoading,
                    onPressed: () => _submit(cubit, state),
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
                    isRegister: true,
                    onPressed: _showUnavailableMessage,
                  ),
                  const SizedBox(height: 12),
                  SocialLoginButton(
                    provider: SocialProvider.facebook,
                    isRegister: true,
                    onPressed: _showUnavailableMessage,
                  ),
                  const SizedBox(height: 12),
                  AuthFooterLink(
                    prompt: 'لديك حساب بالفعل؟',
                    actionLabel: AppStrings.login,
                    onPressed: () => Navigator.pop(context),
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

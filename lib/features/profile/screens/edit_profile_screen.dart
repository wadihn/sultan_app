import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/core/constants/app_constants.dart';
import 'package:sultan_app/core/theme/app_colors.dart';
import 'package:sultan_app/core/theme/app_text_styles.dart';
import 'package:sultan_app/core/utils/validators.dart';
import 'package:sultan_app/core/widgets/custom_button.dart';
import 'package:sultan_app/core/widgets/custom_text_field.dart';
import 'package:sultan_app/features/auth/cubit/auth_cubit.dart';
import 'package:sultan_app/features/profile/cubit/profile_cubit.dart';
import 'package:sultan_app/features/profile/cubit/profile_state.dart';
import 'package:sultan_app/models/requests/update_profile_request.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _email;

  @override
  void initState() {
    super.initState();
    final user = context.read<ProfileCubit>().state.user!;
    _name = TextEditingController(text: user.name);
    _phone = TextEditingController(text: user.phone);
    _email = TextEditingController(text: user.email);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final success = await context.read<ProfileCubit>().updateProfile(
      UpdateProfileRequest(
        name: _name.text,
        phone: _phone.text,
        email: _email.text.trim().isEmpty ? null : _email.text,
      ),
    );
    if (!mounted || !success) return;
    await context.read<AuthCubit>().loadCurrentUser();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('تعديل الملف الشخصي')),
    body: SafeArea(
      bottom: false,
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.pagePadding,
            16,
            AppConstants.pagePadding,
            28,
          ),
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 4,
                    child: ColoredBox(color: AppColors.primary),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'بيانات الحساب',
                          style: AppTextStyles.label.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _name,
                          label: 'الاسم',
                          prefixIcon: Icons.person_outline,
                          textInputAction: TextInputAction.next,
                          validator: (value) => Validators.requiredField(
                            value,
                            fieldName: 'الاسم',
                          ),
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          controller: _phone,
                          label: 'رقم الهاتف',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          validator: Validators.phone,
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          controller: _email,
                          label: 'البريد الإلكتروني (اختياري)',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          validator: (value) => value?.trim().isEmpty == true
                              ? null
                              : Validators.email(value),
                          onFieldSubmitted: (_) => _save(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) => Column(
                children: [
                  if (state.errorMessage != null) ...[
                    Text(
                      state.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  CustomButton(
                    label: 'حفظ التعديلات',
                    onPressed: _save,
                    isLoading: state.isUpdating,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

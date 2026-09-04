import 'package:flutter/material.dart';
import 'package:sultan_app/core/constants/app_constants.dart';
import 'package:sultan_app/core/theme/app_colors.dart';

enum SocialProvider { google, facebook }

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    required this.provider,
    required this.onPressed,
    this.isRegister = false,
    super.key,
  });

  final SocialProvider provider;
  final VoidCallback? onPressed;
  final bool isRegister;

  @override
  Widget build(BuildContext context) {
    final providerName = provider == SocialProvider.google
        ? 'Google'
        : 'Facebook';
    final iconColor = provider == SocialProvider.google
        ? AppColors.primary
        : const Color(0xFF1877F2);
    return SizedBox(
      width: double.infinity,
      height: AppConstants.buttonHeight,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.black,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
        icon: Icon(
          provider == SocialProvider.google
              ? Icons.g_mobiledata_rounded
              : Icons.facebook_rounded,
          color: iconColor,
          size: 26,
        ),
        label: Text(
          '${isRegister ? 'التسجيل' : 'الدخول'} باستخدام $providerName',
        ),
      ),
    );
  }
}

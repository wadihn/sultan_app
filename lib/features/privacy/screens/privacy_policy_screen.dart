import 'package:flutter/material.dart';
import 'package:sultan_app/core/theme/app_colors.dart';
import 'package:sultan_app/core/theme/app_text_styles.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('سياسة الخصوصية')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(9),
            ),
          ),
          const SizedBox(height: 18),
          Text('محتوى مؤقت', style: AppTextStyles.title),
          const SizedBox(height: 12),
          Text(
            'سيتم استبدال هذا المحتوى بسياسة الخصوصية القانونية النهائية قبل نشر التطبيق. '
            'هذه الصفحة مهيأة لعرض المحتوى المعتمد لاحقًا من ملف محلي أو من الخادم.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.8,
            ),
          ),
        ],
      ),
    ),
  );
}

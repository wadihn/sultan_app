import 'package:flutter/material.dart';
import 'package:sultan_app/core/theme/app_colors.dart';

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) => const Row(
    children: [
      Expanded(child: Divider(color: AppColors.border)),
      Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('أو')),
      Expanded(child: Divider(color: AppColors.border)),
    ],
  );
}

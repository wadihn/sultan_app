import 'package:flutter/material.dart';
import 'package:sultan_app/core/constants/app_strings.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({this.message = AppStrings.noData, super.key});
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(message, textAlign: TextAlign.center),
    ),
  );
}

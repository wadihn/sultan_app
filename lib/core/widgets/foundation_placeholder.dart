import 'package:flutter/material.dart';
import 'package:sultan_app/core/constants/app_constants.dart';

class FoundationPlaceholder extends StatelessWidget {
  const FoundationPlaceholder({required this.title, super.key});
  final String title;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.pagePadding),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}

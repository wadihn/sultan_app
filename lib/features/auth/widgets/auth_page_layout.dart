import 'package:flutter/material.dart';
import 'package:sultan_app/core/constants/app_constants.dart';

class AuthPageLayout extends StatelessWidget {
  const AuthPageLayout({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            AppConstants.pagePadding,
            20,
            AppConstants.pagePadding,
            20 + keyboardInset,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - 40 - keyboardInset)
                  .clamp(0, double.infinity)
                  .toDouble(),
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppConstants.authContentMaxWidth,
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    ),
  );
}

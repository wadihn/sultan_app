import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/features/auth/cubit/auth_cubit.dart';
import 'package:sultan_app/features/auth/cubit/auth_state.dart';
import 'package:sultan_app/app/routes.dart';
import 'package:sultan_app/core/constants/app_assets.dart';
import 'package:sultan_app/core/constants/app_constants.dart';
import 'package:sultan_app/core/constants/app_strings.dart';
import 'package:sultan_app/core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSession());
  }

  Future<void> _checkSession() async {
    if (!mounted) return;
    final cubit = context.read<AuthCubit>();
    await cubit.checkSession();
    if (!mounted) return;
    if (cubit.state.status == AuthStatus.authenticated ||
        cubit.state.status == AuthStatus.unauthenticated) {
      Navigator.pushReplacementNamed(
        context,
        cubit.state.status == AuthStatus.authenticated
            ? AppRoutes.mainNavigation
            : AppRoutes.login,
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.white,
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.pagePadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FractionallySizedBox(
                    widthFactor: constraints.maxWidth < 340 ? 0.68 : 0.74,
                    child: Image.asset(AppAssets.logo, fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    AppStrings.appName,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'تجربة طعم مختلفة في أجواء مميزة',
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      if (state.status == AuthStatus.failure) {
                        return Column(
                          children: [
                            Text(
                              state.errorMessage!,
                              textAlign: TextAlign.center,
                            ),
                            TextButton(
                              onPressed: _checkSession,
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        );
                      }
                      return const SizedBox(
                        width: 28,
                        child: LinearProgressIndicator(
                          minHeight: 4,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

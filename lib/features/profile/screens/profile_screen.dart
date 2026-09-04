import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/app/routes.dart';
import 'package:sultan_app/core/constants/app_constants.dart';
import 'package:sultan_app/core/theme/app_colors.dart';
import 'package:sultan_app/core/theme/app_text_styles.dart';
import 'package:sultan_app/core/widgets/custom_error_widget.dart';
import 'package:sultan_app/core/widgets/loading_widget.dart';
import 'package:sultan_app/features/auth/cubit/auth_cubit.dart';
import 'package:sultan_app/features/profile/cubit/profile_cubit.dart';
import 'package:sultan_app/features/profile/cubit/profile_state.dart';
import 'package:sultan_app/features/profile/widgets/profile_menu_item.dart';
import 'package:sultan_app/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ProfileCubit>().loadProfile();
    });
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final success = await context.read<AuthCubit>().logout();
    if (!context.mounted) return;
    if (success) {
      context.read<ProfileCubit>().clearProfile();
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تسجيل الخروج، حاول مرة أخرى')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if ((state.status == ProfileStatus.initial ||
                state.status == ProfileStatus.loading) &&
            state.user == null) {
          return const LoadingWidget();
        }
        if (state.status == ProfileStatus.failure && state.user == null) {
          return CustomErrorWidget(
            message: state.errorMessage ?? 'تعذر تحميل بيانات الحساب',
            onRetry: context.read<ProfileCubit>().loadProfile,
          );
        }
        final user = state.user;
        if (user == null) return const SizedBox.shrink();
        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.pagePadding,
            12,
            AppConstants.pagePadding,
            28,
          ),
          children: [
            Text('حسابي', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 14),
            _ProfileHeader(user: user),
            const SizedBox(height: 24),
            _SectionTitle(title: 'الحساب'),
            const SizedBox(height: 10),
            _MenuSection(
              children: [
                ProfileMenuItem(
                  icon: Icons.edit_outlined,
                  title: 'تعديل الملف الشخصي',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.editProfile),
                ),
                ProfileMenuItem(
                  icon: Icons.location_on_outlined,
                  title: 'العناوين المحفوظة',
                  showDivider: false,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.addresses),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: 'عن الكافيه'),
            const SizedBox(height: 10),
            _MenuSection(
              children: [
                ProfileMenuItem(
                  icon: Icons.storefront_outlined,
                  title: 'معلومات الكافيه',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.cafeInfo),
                ),
                ProfileMenuItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'سياسة الخصوصية',
                  showDivider: false,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.privacy),
                ),
              ],
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('تسجيل الخروج'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryDark,
                side: const BorderSide(color: AppColors.primary),
                minimumSize: const Size(0, 46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.black,
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4, child: ColoredBox(color: AppColors.primary)),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                user.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.title.copyWith(color: AppColors.white),
              ),
              const SizedBox(height: 16),
              _InfoRow(icon: Icons.phone_outlined, text: user.phone),
              if (user.email?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 10),
                _InfoRow(icon: Icons.email_outlined, text: user.email!),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 18, color: AppColors.primary),
      const SizedBox(width: 9),
      Expanded(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AppColors.white.withValues(alpha: 0.82)),
        ),
      ),
    ],
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 4,
        height: 18,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      const SizedBox(width: 8),
      Text(title, style: AppTextStyles.label.copyWith(fontSize: 16)),
    ],
  );
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      side: const BorderSide(color: AppColors.border),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(children: children),
  );
}

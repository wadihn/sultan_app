import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/core/constants/app_constants.dart';
import 'package:sultan_app/core/constants/app_assets.dart';
import 'package:sultan_app/core/theme/app_colors.dart';
import 'package:sultan_app/core/theme/app_text_styles.dart';
import 'package:sultan_app/core/widgets/custom_error_widget.dart';
import 'package:sultan_app/core/widgets/loading_widget.dart';
import 'package:sultan_app/features/cafe_info/cubit/cafe_info_cubit.dart';
import 'package:sultan_app/features/cafe_info/cubit/cafe_info_state.dart';
import 'package:sultan_app/models/opening_hour_model.dart';

class CafeInfoScreen extends StatelessWidget {
  const CafeInfoScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('معلومات الكافيه')),
    body: SafeArea(
      child: BlocBuilder<CafeInfoCubit, CafeInfoState>(
        builder: (context, state) {
          if (state.status == CafeInfoStatus.initial ||
              state.status == CafeInfoStatus.loading) {
            return const LoadingWidget();
          }
          if (state.status == CafeInfoStatus.failure || state.info == null) {
            return CustomErrorWidget(
              message: state.errorMessage ?? 'تعذر تحميل معلومات الكافيه',
              onRetry: context.read<CafeInfoCubit>().loadCafeInfo,
            );
          }
          final info = state.info!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        AppAssets.logo,
                        width: 64,
                        height: 64,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        info.name,
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const _SectionTitle('معلومات التواصل'),
              _InfoSurface(
                child: Column(
                  children: [
                    _Info(icon: Icons.phone_outlined, text: info.phone),
                    const Divider(height: 24, color: AppColors.border),
                    _Info(icon: Icons.location_on_outlined, text: info.address),
                    if (info.instagramUrl?.trim().isNotEmpty == true) ...[
                      const Divider(height: 24, color: AppColors.border),
                      _Info(
                        icon: Icons.alternate_email,
                        text: info.instagramUrl!,
                      ),
                    ],
                  ],
                ),
              ),
              const _SectionTitle('ساعات العمل'),
              _InfoSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (
                      var index = 0;
                      index < info.openingHours.length;
                      index++
                    ) ...[
                      _OpeningHoursRow(hours: info.openingHours[index]),
                      if (index < info.openingHours.length - 1)
                        const Divider(height: 1, color: AppColors.border),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 22, bottom: 10),
    child: Row(
      children: [
        Container(width: 4, height: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.label.copyWith(fontSize: 16)),
      ],
    ),
  );
}

class _InfoSurface extends StatelessWidget {
  const _InfoSurface({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
    ),
    child: child,
  );
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 20, color: AppColors.primary),
      const SizedBox(width: 10),
      Expanded(child: Text(text)),
    ],
  );
}

class _OpeningHoursRow extends StatelessWidget {
  const _OpeningHoursRow({required this.hours});
  final OpeningHourModel hours;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Expanded(child: Text(_day(hours.dayOfWeek))),
        Text(
          hours.isClosed
              ? 'مغلق'
              : '${hours.openingTime} – ${hours.closingTime}',
          style: TextStyle(
            color: hours.isClosed
                ? AppColors.primaryDark
                : AppColors.textSecondary,
          ),
        ),
      ],
    ),
  );

  String _day(String value) =>
      const {
        'sunday': 'الأحد',
        'monday': 'الاثنين',
        'tuesday': 'الثلاثاء',
        'wednesday': 'الأربعاء',
        'thursday': 'الخميس',
        'friday': 'الجمعة',
        'saturday': 'السبت',
      }[value.toLowerCase()] ??
      value;
}

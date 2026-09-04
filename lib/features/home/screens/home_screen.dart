import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/app/routes.dart';
import 'package:sultan_app/core/constants/app_constants.dart';
import 'package:sultan_app/core/theme/app_colors.dart';
import 'package:sultan_app/core/widgets/custom_error_widget.dart';
import 'package:sultan_app/core/widgets/loading_widget.dart';
import 'package:sultan_app/core/widgets/product_card.dart';
import 'package:sultan_app/features/home/cubit/home_cubit.dart';
import 'package:sultan_app/features/home/cubit/home_state.dart';
import 'package:sultan_app/features/home/widgets/booking_promo_card.dart';
import 'package:sultan_app/features/home/widgets/cafe_status_card.dart';
import 'package:sultan_app/features/home/widgets/home_banner.dart';
import 'package:sultan_app/features/home/widgets/home_header.dart';
import 'package:sultan_app/features/home/widgets/home_section_title.dart';
import 'package:sultan_app/features/main_navigation/cubit/navigation_cubit.dart';
import 'package:sultan_app/features/menu/cubit/menu_cubit.dart';
import 'package:sultan_app/features/cart/cubit/cart_cubit.dart';
import 'package:sultan_app/features/checkout/cubit/checkout_cubit.dart';
import 'package:sultan_app/features/checkout/cubit/checkout_state.dart';
import 'package:sultan_app/models/category_model.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openMenu(BuildContext context, [CategoryModel? category]) {
    context.read<MenuCubit>().selectCategory(category?.id);
    context.read<NavigationCubit>().selectTab(1);
  }

  void _startBooking(BuildContext context) {
    if (context.read<CartCubit>().state.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أضف منتجات إلى السلة أولًا لربطها بالحجز'),
        ),
      );
      return;
    }
    context.read<CheckoutCubit>().selectServiceType(ServiceType.booking);
    Navigator.pushNamed(context, AppRoutes.booking);
  }

  Future<void> _openPhoneDialer(BuildContext context, String phone) async {
    final normalizedPhone = phone.trim();
    if (normalizedPhone.isEmpty) {
      _showDialerError(context);
      return;
    }

    try {
      final opened = await launchUrl(
        Uri(scheme: 'tel', path: normalizedPhone),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && context.mounted) {
        _showDialerError(context);
      }
    } catch (_) {
      if (context.mounted) {
        _showDialerError(context);
      }
    }
  }

  void _showDialerError(BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('تعذر فتح تطبيق الاتصال')));
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state.status == HomeStatus.loading ||
            state.status == HomeStatus.initial) {
          return const LoadingWidget();
        }
        if (state.status == HomeStatus.failure) {
          return CustomErrorWidget(
            message: state.errorMessage ?? 'تعذر تحميل الرئيسية',
            onRetry: context.read<HomeCubit>().loadHome,
          );
        }
        final cafeInfo = state.cafeInfo;
        return RefreshIndicator(
          onRefresh: context.read<HomeCubit>().loadHome,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.pagePadding,
              12,
              AppConstants.pagePadding,
              28,
            ),
            children: [
              const HomeHeader(),
              const SizedBox(height: 18),
              if (cafeInfo != null)
                CafeStatusCard(
                  cafeInfo: cafeInfo,
                  isOpen: state.isCafeOpen ?? cafeInfo.isOpen,
                ),
              const SizedBox(height: 16),
              TextField(
                readOnly: true,
                onTap: () => _openMenu(context),
                decoration: const InputDecoration(
                  hintText: 'ابحث عن مشروب أو منتج...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              if (cafeInfo != null) ...[
                const SizedBox(height: 22),
                const HomeSectionTitle(title: 'حجز المناسبات'),
                const SizedBox(height: 10),
                HomeBanner(
                  title: 'احجز مناسبتك معنا',
                  description: 'حفلات • أعياد ميلاد • مناسبات خاصة',
                  buttonText: 'تواصل للحجز',
                  icon: Icons.celebration_outlined,
                  onTap: () => _openPhoneDialer(context, cafeInfo.phone),
                ),
              ],
              const SizedBox(height: 22),
              const HomeSectionTitle(title: 'الأقسام'),
              const SizedBox(height: 10),
              SizedBox(
                height: 92,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final category = state.categories[index];
                    return InkWell(
                      onTap: () => _openMenu(context, category),
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius,
                      ),
                      child: Container(
                        width: 94,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.local_cafe_outlined,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 7),
                            Text(
                              category.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 22),
              HomeSectionTitle(
                title: 'الأكثر طلبًا',
                actionLabel: 'عرض الكل',
                onAction: () => _openMenu(context),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 270,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.popularProducts.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final product = state.popularProducts[index];
                    return SizedBox(
                      width: 178,
                      child: ProductCard(
                        product: product,
                        compact: true,
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.productDetails,
                          arguments: product.id,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              BookingPromoCard(onPressed: () => _startBooking(context)),
            ],
          ),
        );
      },
    ),
  );
}

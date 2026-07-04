import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../models/hotel_model.dart';
import '../home/main_navigation_screen.dart';

class BookingSuccessScreen extends ConsumerWidget {
  final HotelModel hotel;
  const BookingSuccessScreen({super.key, required this.hotel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.pagePadding),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: AppColors.success, size: 56),
              ),
              const SizedBox(height: AppDimens.xl),
              Text(AppStrings.t(isArabic, 'booking_success'),
                  textAlign: TextAlign.center, style: textTheme.headlineMedium),
              const SizedBox(height: AppDimens.sm),
              Text(AppStrings.t(isArabic, 'booking_success_desc'),
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppDimens.lg),
              Container(
                padding: const EdgeInsets.all(AppDimens.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
                child: Row(
                  children: [
                    Text(AppStrings.t(isArabic, 'booking_reference'), style: textTheme.bodySmall),
                    const Spacer(),
                    Text('#AO-${hotel.id}2026',
                        style: textTheme.titleSmall?.copyWith(color: AppColors.goldDark)),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: AppDimens.buttonHeight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                      (route) => false,
                    );
                  },
                  child: Text(AppStrings.t(isArabic, 'home')),
                ),
              ),
              const SizedBox(height: AppDimens.lg),
            ],
          ),
        ),
      ),
    );
  }
}

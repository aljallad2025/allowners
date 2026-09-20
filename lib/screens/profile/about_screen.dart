import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';

/// «عن التطبيق» — تعريف All Owners (النص من ملف التعديلات)
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;
    final bodyStyle = textTheme.bodyMedium?.copyWith(
      color: AppColors.textSecondary,
      height: 1.8,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(AppStrings.t(isArabic, 'about_us')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimens.radiusXl),
                  child: Image.asset(
                    isArabic
                        ? 'assets/images/official_logo_ar.png'
                        : 'assets/images/official_logo_en.png',
                    width: 220,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.lg),
              Text(AppStrings.t(isArabic, 'about_desc_1'), style: textTheme.titleMedium?.copyWith(height: 1.6)),
              const SizedBox(height: AppDimens.md),
              Text(AppStrings.t(isArabic, 'about_desc_2'), style: bodyStyle),
              const SizedBox(height: AppDimens.md),
              Text(AppStrings.t(isArabic, 'about_desc_3'), style: bodyStyle),
              const SizedBox(height: AppDimens.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimens.md),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  border: Border.all(color: AppColors.gold.withOpacity(0.5)),
                ),
                child: Text(
                  AppStrings.t(isArabic, 'about_closing'),
                  style: textTheme.titleSmall?.copyWith(color: AppColors.goldDark, height: 1.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

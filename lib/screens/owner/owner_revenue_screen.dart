import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';

class OwnerRevenueScreen extends ConsumerWidget {
  const OwnerRevenueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;

    final months = [
      (label: isArabic ? 'يونيو' : 'June', value: 12450),
      (label: isArabic ? 'مايو' : 'May', value: 10900),
      (label: isArabic ? 'أبريل' : 'April', value: 11700),
      (label: isArabic ? 'مارس' : 'March', value: 9800),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(AppStrings.t(isArabic, 'nav_revenue')),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.pagePadding),
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimens.lg),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.t(isArabic, 'total_revenue_month'),
                      style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Text('${months.first.value} ${AppStrings.t(isArabic, 'sar')}',
                      style: textTheme.headlineMedium?.copyWith(color: AppColors.goldDark)),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.xl),
            Text(AppStrings.t(isArabic, 'revenue_history'), style: textTheme.titleMedium),
            const SizedBox(height: AppDimens.md),
            ...months.map((m) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(m.label, style: textTheme.bodyMedium),
                      Text('${m.value} ${AppStrings.t(isArabic, 'sar')}',
                          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
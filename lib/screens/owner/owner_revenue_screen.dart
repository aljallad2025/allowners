import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../providers/owner_provider.dart';

const _arMonths = [
  'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
];
const _enMonths = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

class OwnerRevenueScreen extends ConsumerWidget {
  const OwnerRevenueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;
    final historyAsync = ref.watch(ownerRevenueHistoryProvider);
    final totalAsync = ref.watch(ownerMonthlyRevenueProvider);

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
                  Text('${totalAsync.asData?.value.toInt() ?? 0} ${AppStrings.t(isArabic, 'sar')}',
                      style: textTheme.headlineMedium?.copyWith(color: AppColors.goldDark)),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.xl),
            Text(AppStrings.t(isArabic, 'revenue_history'), style: textTheme.titleMedium),
            const SizedBox(height: AppDimens.md),
            historyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
              error: (err, st) => Text(AppStrings.t(isArabic, 'something_went_wrong'),
                  style: const TextStyle(color: AppColors.textMuted)),
              data: (records) {
                if (records.isEmpty) {
                  return Text(AppStrings.t(isArabic, 'no_hotels_found'),
                      style: const TextStyle(color: AppColors.textMuted));
                }
                return Column(
                  children: records.map((r) {
                    final month = DateTime.parse(r['month'] as String);
                    final label = isArabic ? _arMonths[month.month - 1] : _enMonths[month.month - 1];
                    final amount = (r['amount'] as num).toDouble();
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('$label ${month.year}', style: textTheme.bodyMedium),
                          Text('${amount.toInt()} ${AppStrings.t(isArabic, 'sar')}',
                              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

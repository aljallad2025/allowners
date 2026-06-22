import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';

class OwnerUnitsScreen extends ConsumerWidget {
  const OwnerUnitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;

    final units = [
      (
        name: isArabic ? 'وحدة 204 - جناح ديلوكس' : 'Unit 204 - Deluxe Suite',
        hotel: isArabic ? 'فندق أول أونرز - الرياض' : 'All Owners Hotel - Riyadh',
        occupied: true,
        revenue: 4200,
      ),
      (
        name: isArabic ? 'وحدة 311 - غرفة عائلية' : 'Unit 311 - Family Room',
        hotel: isArabic ? 'فندق أول أونرز - جدة' : 'All Owners Hotel - Jeddah',
        occupied: false,
        revenue: 3100,
      ),
      (
        name: isArabic ? 'وحدة 108 - استوديو' : 'Unit 108 - Studio',
        hotel: isArabic ? 'فندق أول أونرز - الخبر' : 'All Owners Hotel - Khobar',
        occupied: true,
        revenue: 5150,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(AppStrings.t(isArabic, 'nav_units')),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(AppDimens.pagePadding),
          itemCount: units.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppDimens.md),
          itemBuilder: (context, index) {
            final unit = units[index];
            return Container(
              padding: const EdgeInsets.all(AppDimens.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(unit.name, style: textTheme.titleSmall)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (unit.occupied ? AppColors.success : AppColors.textMuted).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                        ),
                        child: Text(
                          AppStrings.t(isArabic, unit.occupied ? 'occupied' : 'vacant'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: unit.occupied ? AppColors.success : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(unit.hotel, style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                  const Divider(height: AppDimens.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppStrings.t(isArabic, 'monthly_revenue'),
                          style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                      Text('${unit.revenue} ${AppStrings.t(isArabic, 'sar')}',
                          style: textTheme.titleSmall?.copyWith(color: AppColors.goldDark)),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
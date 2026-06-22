import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';

class OwnerNotificationsScreen extends ConsumerWidget {
  const OwnerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;

    final notifications = [
      (
        icon: Icons.account_balance_wallet_outlined,
        title: isArabic ? 'تم إيداع إيراد الشهر' : 'Monthly revenue deposited',
        time: isArabic ? 'منذ ساعتين' : '2h ago',
      ),
      (
        icon: Icons.how_to_vote_outlined,
        title: isArabic ? 'تصويت جديد على قرار الصيانة' : 'New vote on maintenance decision',
        time: isArabic ? 'منذ يوم' : '1d ago',
      ),
      (
        icon: Icons.build_outlined,
        title: isArabic ? 'تم إغلاق طلب صيانة الوحدة 204' : 'Maintenance request for Unit 204 closed',
        time: isArabic ? 'منذ 3 أيام' : '3d ago',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(AppStrings.t(isArabic, 'notifications')),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(AppDimens.pagePadding),
          itemCount: notifications.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppDimens.sm),
          itemBuilder: (context, index) {
            final n = notifications[index];
            return Container(
              padding: const EdgeInsets.all(AppDimens.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    ),
                    child: Icon(n.icon, color: AppColors.goldDark, size: 20),
                  ),
                  const SizedBox(width: AppDimens.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.title, style: textTheme.bodyMedium),
                        const SizedBox(height: 2),
                        Text(n.time, style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                      ],
                    ),
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
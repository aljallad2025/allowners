import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../providers/owner_provider.dart';

IconData _iconForKey(String key) {
  switch (key) {
    case 'revenue':
      return Icons.account_balance_wallet_outlined;
    case 'vote':
      return Icons.how_to_vote_outlined;
    case 'maintenance':
      return Icons.build_outlined;
    default:
      return Icons.notifications_outlined;
  }
}

String _timeAgo(DateTime dt, bool isArabic) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 60) return isArabic ? 'منذ ${diff.inMinutes} د' : '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return isArabic ? 'منذ ${diff.inHours} س' : '${diff.inHours}h ago';
  return isArabic ? 'منذ ${diff.inDays} يوم' : '${diff.inDays}d ago';
}

class OwnerNotificationsScreen extends ConsumerWidget {
  const OwnerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;
    final notificationsAsync = ref.watch(ownerNotificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(AppStrings.t(isArabic, 'notifications')),
      ),
      body: SafeArea(
        child: notificationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
          error: (err, st) => Center(
            child: Text(AppStrings.t(isArabic, 'something_went_wrong'),
                style: const TextStyle(color: AppColors.textMuted)),
          ),
          data: (notifications) {
            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off_outlined, size: 56, color: AppColors.textMuted),
                    const SizedBox(height: AppDimens.md),
                    Text(AppStrings.t(isArabic, 'no_hotels_found'),
                        style: const TextStyle(color: AppColors.textMuted)),
                  ],
                ),
              );
            }
            return ListView.separated(
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
                        child: Icon(_iconForKey(n.iconKey), color: AppColors.goldDark, size: 20),
                      ),
                      const SizedBox(width: AppDimens.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n.title(isArabic), style: textTheme.bodyMedium),
                            const SizedBox(height: 2),
                            Text(_timeAgo(n.createdAt, isArabic),
                                style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

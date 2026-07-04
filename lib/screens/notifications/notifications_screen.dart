import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../providers/guest_notifications_provider.dart';

IconData _iconForKey(String key) {
  switch (key) {
    case 'booking':
      return Icons.calendar_month_outlined;
    case 'maintenance':
      return Icons.build_outlined;
    case 'meal':
      return Icons.restaurant_outlined;
    case 'revenue':
      return Icons.account_balance_wallet_outlined;
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

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;
    final notificationsAsync = ref.watch(myNotificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(AppStrings.t(isArabic, 'notifications'))),
      body: SafeArea(
        child: notificationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
          error: (err, st) => Center(
            child: Text(AppStrings.t(isArabic, 'something_went_wrong'), style: const TextStyle(color: AppColors.textMuted)),
          ),
          data: (notifications) {
            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off_outlined, size: 56, color: AppColors.textMuted),
                    const SizedBox(height: AppDimens.md),
                    Text(AppStrings.t(isArabic, 'no_notifications_yet'), style: const TextStyle(color: AppColors.textMuted)),
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
                return InkWell(
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  onTap: () {
                    if (!n.isRead) {
                      ref.read(notificationsRepositoryProvider).markAsRead(n.id);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppDimens.md),
                    decoration: BoxDecoration(
                      color: n.isRead ? AppColors.surface : AppColors.gold.withOpacity(0.06),
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
                              Text(n.title(isArabic),
                                  style: textTheme.bodyMedium?.copyWith(
                                      fontWeight: n.isRead ? FontWeight.normal : FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text(_timeAgo(n.createdAt, isArabic),
                                  style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                        if (!n.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                          ),
                      ],
                    ),
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

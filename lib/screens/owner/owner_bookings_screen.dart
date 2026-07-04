import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../providers/owner_requests_provider.dart';

class OwnerBookingsScreen extends ConsumerWidget {
  const OwnerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;
    final bookingsAsync = ref.watch(ownerBookingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(AppStrings.t(isArabic, 'owner_bookings')),
      ),
      body: SafeArea(
        child: bookingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
          error: (err, st) => Center(
            child: Text(AppStrings.t(isArabic, 'something_went_wrong'),
                style: const TextStyle(color: AppColors.textMuted)),
          ),
          data: (bookings) {
            if (bookings.isEmpty) {
              return Center(
                child: Text(AppStrings.t(isArabic, 'no_bookings_yet'),
                    style: const TextStyle(color: AppColors.textMuted)),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppDimens.pagePadding),
              itemCount: bookings.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppDimens.md),
              itemBuilder: (context, index) {
                final b = bookings[index];
                final hotel = b['hotels'] as Map<String, dynamic>?;
                final hotelName = hotel?['name'] as String? ?? '';
                final checkIn = DateTime.parse(b['check_in'] as String);
                final checkOut = DateTime.parse(b['check_out'] as String);
                final total = (b['total_price'] as num).toDouble();
                final status = b['status'] as String? ?? 'upcoming';
                final statusColor = status == 'cancelled'
                    ? AppColors.danger
                    : status == 'completed'
                        ? AppColors.textMuted
                        : AppColors.success;
                final statusLabel = AppStrings.t(isArabic, status == 'upcoming'
                    ? 'upcoming'
                    : status == 'completed'
                        ? 'past'
                        : 'cancelled');
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
                          Expanded(child: Text(hotelName, style: textTheme.titleSmall)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                            ),
                            child: Text(statusLabel,
                                style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${checkIn.day}/${checkIn.month} - ${checkOut.day}/${checkOut.month}',
                          style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                      const Divider(height: AppDimens.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppStrings.t(isArabic, 'total'),
                              style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                          Text('${total.toInt()} ${AppStrings.t(isArabic, "sar")}',
                              style: textTheme.titleSmall?.copyWith(color: AppColors.goldDark)),
                        ],
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../models/booking_model.dart';
import '../../providers/bookings_provider.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final bookingsAsync = ref.watch(myBookingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.t(isArabic, 'my_bookings')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppStrings.t(isArabic, 'upcoming')),
            Tab(text: AppStrings.t(isArabic, 'past')),
            Tab(text: AppStrings.t(isArabic, 'cancelled')),
          ],
        ),
      ),
      body: SafeArea(
        child: bookingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
          error: (err, st) => Center(
            child: Text(AppStrings.t(isArabic, 'something_went_wrong'),
                style: const TextStyle(color: AppColors.textMuted)),
          ),
          data: (bookings) {
            final upcoming = bookings.where((b) => b.status == BookingStatus.upcoming).toList();
            final past = bookings.where((b) => b.status == BookingStatus.completed).toList();
            final cancelled = bookings.where((b) => b.status == BookingStatus.cancelled).toList();
            return TabBarView(
              controller: _tabController,
              children: [
                _buildList(upcoming, isArabic),
                _buildList(past, isArabic),
                _buildList(cancelled, isArabic),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(List<BookingModel> items, bool isArabic) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 56, color: AppColors.textMuted),
            const SizedBox(height: AppDimens.md),
            Text(AppStrings.t(isArabic, 'no_bookings_yet'), style: const TextStyle(color: AppColors.textMuted)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimens.pagePadding),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final city = isArabic ? item.hotelCityAr : item.hotelCityEn;
        final dateRange =
            '${item.checkIn.day}/${item.checkIn.month} - ${item.checkOut.day}/${item.checkOut.month}';
        final statusLabel = switch (item.status) {
          BookingStatus.upcoming => AppStrings.t(isArabic, 'upcoming'),
          BookingStatus.completed => AppStrings.t(isArabic, 'past'),
          BookingStatus.cancelled => AppStrings.t(isArabic, 'cancelled'),
        };
        final statusColor = switch (item.status) {
          BookingStatus.cancelled => AppColors.danger,
          BookingStatus.completed => AppColors.textMuted,
          BookingStatus.upcoming => AppColors.success,
        };
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimens.md),
          child: Container(
            padding: const EdgeInsets.all(AppDimens.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: item.hotelImageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        Icon(Icons.image_outlined, color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(width: AppDimens.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.hotelName, style: Theme.of(context).textTheme.titleSmall),
                      Text(city,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                      Text(dateRange,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ),
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
          ),
        );
      },
    );
  }
}

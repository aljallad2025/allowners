import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _upcoming = [
    {
      'name': 'Ritz Carlton Riyadh',
      'city': 'الرياض',
      'date': '24 - 26 يونيو',
      'status': 'مؤكد',
      'image': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&q=80',
    },
  ];
  final _past = [
    {
      'name': 'Jeddah Hilton Corniche',
      'city': 'جدة',
      'date': '10 - 12 مايو',
      'status': 'مكتمل',
      'image': 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400&q=80',
    },
  ];
  final _cancelled = <Map<String, String>>[];

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
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildList(_upcoming, isArabic),
            _buildList(_past, isArabic),
            _buildList(_cancelled, isArabic),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<Map<String, String>> items, bool isArabic) {
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
                    imageUrl: item['image'] ?? '',
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
                      Text(item['name']!, style: Theme.of(context).textTheme.titleSmall),
                      Text(item['city']!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                      Text(item['date']!,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  ),
                  child: Text(item['status']!,
                      style: const TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

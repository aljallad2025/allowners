import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../models/hotel_model.dart';
import '../search/search_screen.dart';
import '../hotel/hotel_details_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;
    final hotels = HotelModel.demoList();

    final categories = [
      {'icon': Icons.king_bed_outlined, 'key': 'hotels', 'color': AppColors.ink},
      {'icon': Icons.apartment_rounded, 'key': 'apartments', 'color': AppColors.secondary},
      {'icon': Icons.beach_access_rounded, 'key': 'resorts', 'color': AppColors.goldDark},
      {'icon': Icons.cabin_outlined, 'key': 'chalets', 'color': AppColors.success},
    ];

    final destinations = [
      {
        'name_ar': 'الرياض',
        'name_en': 'Riyadh',
        'count': '320',
        'image': 'https://images.unsplash.com/photo-1578894381163-e72c17f2d45f?w=600&q=80',
      },
      {
        'name_ar': 'جدة',
        'name_en': 'Jeddah',
        'count': '210',
        'image': 'https://images.unsplash.com/photo-1591604442743-26d4c1494ed4?w=600&q=80',
      },
      {
        'name_ar': 'مكة المكرمة',
        'name_en': 'Makkah',
        'count': '180',
        'image': 'https://images.unsplash.com/photo-1565019011521-b0575f9e0495?w=600&q=80',
      },
      {
        'name_ar': 'أبها',
        'name_en': 'Abha',
        'count': '95',
        'image': 'https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=600&q=80',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ===== Header =====
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppDimens.pagePadding, AppDimens.md, AppDimens.pagePadding, 0),
                child: Row(
                  children: [
                    Image.asset('assets/images/logo.png', width: 38),
                    const SizedBox(width: AppDimens.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${AppStrings.t(isArabic, 'hello')}, ثائر 👋',
                              style: textTheme.titleMedium),
                          Text(
                            AppStrings.t(isArabic, 'where_to'),
                            style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_outlined),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surfaceMuted,
                        shape: const CircleBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ===== Search bar =====
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.pagePadding),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  child: Container(
                    padding: const EdgeInsets.all(AppDimens.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                      border: Border.all(color: AppColors.cardBorder),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: AppColors.textMuted),
                        const SizedBox(width: AppDimens.sm),
                        Expanded(
                          child: Text(
                            AppStrings.t(isArabic, 'search_destination'),
                            style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            gradient: AppColors.goldGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.tune_rounded, size: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ===== Categories =====
            SliverToBoxAdapter(
              child: SizedBox(
                height: 96,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return Padding(
                      padding: const EdgeInsets.only(left: AppDimens.md),
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: (cat['color'] as Color).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                            ),
                            child: Icon(cat['icon'] as IconData, color: cat['color'] as Color),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            AppStrings.t(isArabic, cat['key'] as String),
                            style: textTheme.labelSmall,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppDimens.md)),

            // ===== Featured Deals =====
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppStrings.t(isArabic, 'featured_deals'), style: textTheme.headlineSmall),
                    TextButton(onPressed: () {}, child: Text(AppStrings.t(isArabic, 'see_all'))),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 260,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
                  itemCount: hotels.length,
                  itemBuilder: (context, index) {
                    final hotel = hotels[index];
                    return Padding(
                      padding: const EdgeInsets.only(left: AppDimens.md),
                      child: _HotelCard(
                        hotel: hotel,
                        isArabic: isArabic,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => HotelDetailsScreen(hotel: hotel)),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppDimens.lg)),

            // ===== Popular destinations =====
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
                child: Text(AppStrings.t(isArabic, 'popular_destinations'), style: textTheme.headlineSmall),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AppDimens.pagePadding),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppDimens.md,
                  crossAxisSpacing: AppDimens.md,
                  childAspectRatio: 1.3,
                ),
                delegate: SliverChildListDelegate(
                  destinations.map((d) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SearchScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: d['image']!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: AppColors.surfaceMuted),
                              errorWidget: (context, url, error) => Container(
                                decoration: const BoxDecoration(gradient: AppColors.heroDarkGradient),
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(gradient: AppColors.darkOverlayGradient),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(AppDimens.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    isArabic ? d['name_ar']! : d['name_en']!,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    '${d['count']} ${AppStrings.t(isArabic, "hotels")}',
                                    style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppDimens.xxl)),
          ],
        ),
      ),
    );
  }
}

class _HotelCard extends StatelessWidget {
  final HotelModel hotel;
  final bool isArabic;
  final VoidCallback onTap;

  const _HotelCard({required this.hotel, required this.isArabic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLg)),
                  child: CachedNetworkImage(
                    imageUrl: hotel.imageUrl,
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 130,
                      color: AppColors.surfaceMuted,
                      child: const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 130,
                      color: AppColors.surfaceMuted,
                      child: Icon(Icons.image_outlined, color: AppColors.textMuted, size: 36),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: isArabic ? null : 10,
                  left: isArabic ? 10 : null,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                    child: Icon(
                      hotel.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 16,
                      color: hotel.isFavorite ? AppColors.danger : AppColors.textMuted,
                    ),
                  ),
                ),
                if (hotel.freeCancellation)
                  Positioned(
                    bottom: 8,
                    left: isArabic ? null : 8,
                    right: isArabic ? 8 : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                      ),
                      child: Text(
                        AppStrings.t(isArabic, 'free_cancellation'),
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimens.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hotel.name, style: textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 2),
                      Text(hotel.city(isArabic),
                          style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 12, color: AppColors.secondary),
                            Text(' ${hotel.rating}',
                                style: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${hotel.pricePerNight.toInt()} ${AppStrings.t(isArabic, "sar")}',
                        style: textTheme.titleSmall?.copyWith(color: AppColors.goldDark),
                      ),
                      Text(AppStrings.t(isArabic, 'per_night'),
                          style: textTheme.labelSmall?.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

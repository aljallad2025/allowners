import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../models/hotel_model.dart';
import '../booking/booking_screen.dart';

class HotelDetailsScreen extends ConsumerStatefulWidget {
  final HotelModel hotel;
  const HotelDetailsScreen({super.key, required this.hotel});

  @override
  ConsumerState<HotelDetailsScreen> createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends ConsumerState<HotelDetailsScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.hotel.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;
    final hotel = widget.hotel;

    final amenitiesAr = ['واي فاي مجاني', 'موقف سيارات', 'مسبح', 'صالة رياضية', 'مكيف هواء', 'خدمة الغرف'];
    final amenitiesEn = ['Free WiFi', 'Parking', 'Pool', 'Gym', 'AC', 'Room Service'];
    final amenityIcons = [
      Icons.wifi_rounded,
      Icons.local_parking_outlined,
      Icons.pool_outlined,
      Icons.fitness_center_outlined,
      Icons.ac_unit_rounded,
      Icons.room_service_outlined,
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.9),
                child: IconButton(
                  icon: Icon(isArabic ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
                      color: AppColors.ink),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: _isFavorite ? AppColors.danger : AppColors.ink,
                    ),
                    onPressed: () => setState(() => _isFavorite = !_isFavorite),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: PageView.builder(
                itemCount: hotel.galleryUrls.isEmpty ? 1 : hotel.galleryUrls.length,
                itemBuilder: (context, index) {
                  final url = hotel.galleryUrls.isEmpty ? hotel.imageUrl : hotel.galleryUrls[index];
                  return CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.surfaceMuted,
                      child: const Center(
                        child: CircularProgressIndicator(color: AppColors.gold),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.surfaceMuted,
                      child: Icon(Icons.image_outlined, size: 64, color: AppColors.textMuted),
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(hotel.name, style: textTheme.headlineMedium)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 16, color: AppColors.secondary),
                            Text(' ${hotel.rating}',
                                style: const TextStyle(
                                    color: AppColors.secondary, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      ...List.generate(hotel.stars,
                          (i) => const Icon(Icons.star_rounded, size: 14, color: AppColors.goldDark)),
                      const SizedBox(width: 6),
                      Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                      Text(' ${hotel.city(isArabic)} · ${hotel.type(isArabic)}',
                          style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: AppDimens.lg),

                  Row(
                    children: [
                      if (hotel.freeCancellation) _Badge(text: AppStrings.t(isArabic, 'free_cancellation'), color: AppColors.success),
                      if (hotel.breakfastIncluded) ...[
                        const SizedBox(width: AppDimens.sm),
                        _Badge(text: AppStrings.t(isArabic, 'breakfast_included'), color: AppColors.secondary),
                      ],
                      const SizedBox(width: AppDimens.sm),
                      _Badge(text: AppStrings.t(isArabic, 'pay_at_property'), color: AppColors.goldDark),
                    ],
                  ),
                  const SizedBox(height: AppDimens.lg),

                  Text(AppStrings.t(isArabic, 'about_property'), style: textTheme.titleMedium),
                  const SizedBox(height: AppDimens.sm),
                  Text(
                    isArabic
                        ? 'يقع ${hotel.name} في موقع متميز بـ${hotel.cityAr}، يوفر إقامة فاخرة مع خدمات متكاملة وإطلالات رائعة، مناسب للأعمال والعائلات.'
                        : '${hotel.name} is ideally located in ${hotel.cityEn}, offering a luxurious stay with full amenities and great views, suitable for business and family travelers.',
                    style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, height: 1.7),
                  ),
                  const SizedBox(height: AppDimens.lg),

                  Text(AppStrings.t(isArabic, 'amenities'), style: textTheme.titleMedium),
                  const SizedBox(height: AppDimens.sm),
                  Wrap(
                    spacing: AppDimens.md,
                    runSpacing: AppDimens.md,
                    children: List.generate(amenitiesAr.length, (i) {
                      return SizedBox(
                        width: (MediaQuery.of(context).size.width - AppDimens.pagePadding * 2 - AppDimens.md) / 2,
                        child: Row(
                          children: [
                            Icon(amenityIcons[i], size: 18, color: AppColors.goldDark),
                            const SizedBox(width: 8),
                            Text(isArabic ? amenitiesAr[i] : amenitiesEn[i], style: textTheme.bodySmall),
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppDimens.lg),

                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.map_outlined, size: 32, color: AppColors.textMuted),
                          const SizedBox(height: 6),
                          Text(AppStrings.t(isArabic, 'view_on_map'),
                              style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.lg),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppStrings.t(isArabic, 'guest_reviews'), style: textTheme.titleMedium),
                      TextButton(onPressed: () {}, child: Text(AppStrings.t(isArabic, 'see_all_reviews'))),
                    ],
                  ),
                  _ReviewItem(
                    name: isArabic ? 'محمد العتيبي' : 'Mohammed Alotaibi',
                    rating: 5,
                    comment: isArabic
                        ? 'إقامة رائعة، خدمة ممتازة وموقع مثالي.'
                        : 'Amazing stay, excellent service and perfect location.',
                  ),
                  const SizedBox(height: AppDimens.xxl + AppDimens.xl),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppDimens.pagePadding),
        decoration: BoxDecoration(color: AppColors.surface, boxShadow: AppColors.cardShadow),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('${hotel.pricePerNight.toInt()}',
                          style: textTheme.headlineSmall?.copyWith(color: AppColors.goldDark)),
                      Text(' ${AppStrings.t(isArabic, "sar")} ${AppStrings.t(isArabic, "per_night")}',
                          style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => BookingScreen(hotel: hotel)),
                    );
                  },
                  child: Text(AppStrings.t(isArabic, 'book_now')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final String name;
  final int rating;
  final String comment;

  const _ReviewItem({required this.name, required this.rating, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.surfaceMuted,
            child: const Icon(Icons.person_rounded, size: 18, color: AppColors.textMuted),
          ),
          const SizedBox(width: AppDimens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleSmall),
                Row(
                  children: List.generate(
                      rating, (i) => const Icon(Icons.star_rounded, size: 12, color: AppColors.goldDark)),
                ),
                const SizedBox(height: 2),
                Text(comment,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

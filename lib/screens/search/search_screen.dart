import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../models/hotel_model.dart';
import '../hotel/hotel_details_screen.dart';
import 'filters_sheet.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _hotels = HotelModel.demoList();

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FiltersSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimens.pagePadding),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: AppStrings.t(isArabic, 'search_destination'),
                          filled: false,
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.sm),
                  InkWell(
                    onTap: _openFilters,
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.ink,
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                      ),
                      child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
              child: Row(
                children: [
                  Text('${_hotels.length} ${AppStrings.t(isArabic, "results_found")}',
                      style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                  const Spacer(),
                  InkWell(
                    onTap: () {},
                    child: Row(
                      children: [
                        Text(AppStrings.t(isArabic, 'sort_by'), style: textTheme.bodyMedium),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.sm),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
                itemCount: _hotels.length,
                itemBuilder: (context, index) {
                  final hotel = _hotels[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppDimens.md),
                    child: _SearchResultCard(
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
          ],
        ),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final HotelModel hotel;
  final bool isArabic;
  final VoidCallback onTap;

  const _SearchResultCard({required this.hotel, required this.isArabic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 100,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              ),
              child: CachedNetworkImage(
                imageUrl: hotel.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
                  ),
                ),
                errorWidget: (context, url, error) =>
                    Icon(Icons.image_outlined, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(width: AppDimens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(hotel.name,
                            style: textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      Icon(
                        hotel.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 18,
                        color: hotel.isFavorite ? AppColors.danger : AppColors.textMuted,
                      ),
                    ],
                  ),
                  Row(
                    children: List.generate(
                      hotel.stars,
                      (i) => const Icon(Icons.star_rounded, size: 12, color: AppColors.goldDark),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 2),
                      Text(hotel.city(isArabic),
                          style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                  const Spacer(),
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
                            Text(' ${hotel.rating} ',
                                style: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary)),
                            Text('(${hotel.reviewsCount})',
                                style: const TextStyle(fontSize: 10, color: AppColors.secondary)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text('${hotel.pricePerNight.toInt()} ${AppStrings.t(isArabic, "sar")}',
                          style: textTheme.titleSmall?.copyWith(color: AppColors.goldDark)),
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

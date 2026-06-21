import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../models/hotel_model.dart';
import '../hotel/hotel_details_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final favorites = HotelModel.demoList().take(2).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(AppStrings.t(isArabic, 'favorites'))),
      body: SafeArea(
        child: favorites.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border_rounded, size: 56, color: AppColors.textMuted),
                    const SizedBox(height: AppDimens.md),
                    Text(AppStrings.t(isArabic, 'no_favorites_yet'),
                        style: const TextStyle(color: AppColors.textMuted)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(AppDimens.pagePadding),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final hotel = favorites[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppDimens.md),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => HotelDetailsScreen(hotel: hotel)),
                        );
                      },
                      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                      child: Container(
                        padding: const EdgeInsets.all(AppDimens.sm),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: hotel.imageUrl,
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
                                  Text(hotel.name, style: Theme.of(context).textTheme.titleSmall),
                                  Text(hotel.city(isArabic),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: AppColors.textMuted)),
                                  const SizedBox(height: 4),
                                  Text('${hotel.pricePerNight.toInt()} ${AppStrings.t(isArabic, "sar")} ${AppStrings.t(isArabic, "per_night")}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(color: AppColors.goldDark)),
                                ],
                              ),
                            ),
                            const Icon(Icons.favorite_rounded, color: AppColors.danger),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

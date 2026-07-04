import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../providers/hotels_provider.dart';
import '../../providers/owner_hotel_mutations_provider.dart';
import 'add_hotel_screen.dart';
import 'edit_hotel_screen.dart';
import 'add_unit_screen.dart';

class OwnerHotelsScreen extends ConsumerWidget {
  const OwnerHotelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;
    final hotelsAsync = ref.watch(ownerHotelsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(AppStrings.t(isArabic, 'my_hotels')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddHotelScreen()));
        },
        icon: const Icon(Icons.add),
        label: Text(AppStrings.t(isArabic, 'add_hotel')),
      ),
      body: SafeArea(
        child: hotelsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
          error: (err, st) => Center(
            child: Text(AppStrings.t(isArabic, 'something_went_wrong'),
                style: const TextStyle(color: AppColors.textMuted)),
          ),
          data: (hotels) {
            if (hotels.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.apartment_outlined, size: 56, color: AppColors.textMuted),
                      const SizedBox(height: AppDimens.md),
                      Text(AppStrings.t(isArabic, 'no_hotels_yet'),
                          textAlign: TextAlign.center, style: textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text(AppStrings.t(isArabic, 'add_hotel_hint'),
                          textAlign: TextAlign.center,
                          style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePadding, AppDimens.pagePadding, AppDimens.pagePadding, 90),
              itemCount: hotels.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppDimens.md),
              itemBuilder: (context, index) {
                final hotel = hotels[index];
                return Container(
                  padding: const EdgeInsets.all(AppDimens.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        ),
                        child: hotel.imageUrl.isEmpty
                            ? const Icon(Icons.apartment_outlined, color: AppColors.textMuted)
                            : CachedNetworkImage(imageUrl: hotel.imageUrl, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: AppDimens.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(hotel.name, style: textTheme.titleSmall),
                            Text(hotel.city(isArabic),
                                style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                            Text('${hotel.pricePerNight.toInt()} ${AppStrings.t(isArabic, "sar")} / ${AppStrings.t(isArabic, "per_night")}',
                                style: textTheme.bodySmall?.copyWith(color: AppColors.goldDark)),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, color: AppColors.textMuted),
                        onSelected: (value) async {
                          if (value == 'edit') {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => EditHotelScreen(hotel: hotel)),
                            );
                          } else if (value == 'delete') {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(AppStrings.t(isArabic, 'confirm_delete')),
                                content: Text(AppStrings.t(isArabic, 'confirm_delete_hotel')),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: Text(AppStrings.t(isArabic, 'cancel')),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: Text(AppStrings.t(isArabic, 'delete'),
                                        style: const TextStyle(color: AppColors.danger)),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              await ref.read(ownerHotelMutationsProvider).deleteHotel(hotel.id);
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(value: 'edit', child: Text(AppStrings.t(isArabic, 'edit'))),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(AppStrings.t(isArabic, 'delete'), style: const TextStyle(color: AppColors.danger)),
                          ),
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

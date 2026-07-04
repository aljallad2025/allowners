import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/hotels_provider.dart';
import '../../providers/marketplace_provider.dart';
import 'chat_screen.dart';

class MarketplaceScreen extends ConsumerWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;
    final listingsAsync = ref.watch(marketplaceListingsProvider);
    final currentUserId = ref.watch(currentUserProvider)?.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(AppStrings.t(isArabic, 'units_marketplace')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateListingSheet(context, ref, isArabic),
        icon: const Icon(Icons.add),
        label: Text(AppStrings.t(isArabic, 'add_listing')),
      ),
      body: SafeArea(
        child: listingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
          error: (err, st) => Center(
            child: Text(AppStrings.t(isArabic, 'something_went_wrong'), style: const TextStyle(color: AppColors.textMuted)),
          ),
          data: (listings) {
            if (listings.isEmpty) {
              return Center(
                child: Text(AppStrings.t(isArabic, 'no_listings_yet'), style: const TextStyle(color: AppColors.textMuted)),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, AppDimens.pagePadding, AppDimens.pagePadding, 90),
              itemCount: listings.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppDimens.md),
              itemBuilder: (context, index) {
                final l = listings[index];
                final profile = l['profiles'] as Map<String, dynamic>?;
                final hotel = l['hotels'] as Map<String, dynamic>?;
                final isMine = l['owner_id'] == currentUserId;
                final isRent = l['listing_type'] == 'rent';
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
                          Expanded(child: Text(l['title'] as String, style: textTheme.titleSmall)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (isRent ? AppColors.secondary : AppColors.goldDark).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                            ),
                            child: Text(
                              AppStrings.t(isArabic, isRent ? 'for_rent' : 'for_sale'),
                              style: TextStyle(
                                color: isRent ? AppColors.secondary : AppColors.goldDark,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (hotel?['name'] != null) ...[
                        const SizedBox(height: 2),
                        Text(hotel!['name'] as String, style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                      ],
                      if ((l['description'] as String?)?.isNotEmpty == true) ...[
                        const SizedBox(height: AppDimens.sm),
                        Text(l['description'] as String, style: textTheme.bodyMedium),
                      ],
                      const Divider(height: AppDimens.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${(l['price'] as num).toInt()} ${AppStrings.t(isArabic, "sar")}',
                              style: textTheme.titleSmall?.copyWith(color: AppColors.goldDark)),
                          if (!isMine)
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                      peerId: l['owner_id'] as String,
                                      peerName: (profile?['full_name'] as String?) ?? '',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                              label: Text(AppStrings.t(isArabic, 'contact_owner')),
                            )
                          else
                            Text(AppStrings.t(isArabic, 'your_listing'),
                                style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
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

  void _openCreateListingSheet(BuildContext context, WidgetRef ref, bool isArabic) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    String listingType = 'sale';
    String? selectedHotelId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            left: AppDimens.pagePadding,
            right: AppDimens.pagePadding,
            top: AppDimens.pagePadding,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppDimens.pagePadding,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(AppStrings.t(isArabic, 'add_listing'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppDimens.md),
                Consumer(
                  builder: (context, ref, _) {
                    final hotelsAsync = ref.watch(ownerHotelsProvider);
                    return hotelsAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (err, st) => const SizedBox.shrink(),
                      data: (hotels) => DropdownButtonFormField<String>(
                        value: selectedHotelId,
                        hint: Text(AppStrings.t(isArabic, 'select_hotel')),
                        items: hotels.map((h) => DropdownMenuItem(value: h.id, child: Text(h.name))).toList(),
                        onChanged: (v) => setState(() => selectedHotelId = v),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppDimens.md),
                TextField(controller: titleController, decoration: InputDecoration(labelText: AppStrings.t(isArabic, 'listing_title'))),
                const SizedBox(height: AppDimens.md),
                TextField(controller: descController, maxLines: 3, decoration: InputDecoration(labelText: AppStrings.t(isArabic, 'description_ar'))),
                const SizedBox(height: AppDimens.md),
                TextField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(labelText: AppStrings.t(isArabic, 'price_per_night'), suffixText: AppStrings.t(isArabic, 'sar')),
                ),
                const SizedBox(height: AppDimens.md),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        value: 'sale',
                        groupValue: listingType,
                        title: Text(AppStrings.t(isArabic, 'for_sale')),
                        onChanged: (v) => setState(() => listingType = v!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        value: 'rent',
                        groupValue: listingType,
                        title: Text(AppStrings.t(isArabic, 'for_rent')),
                        onChanged: (v) => setState(() => listingType = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.md),
                ElevatedButton(
                  onPressed: () async {
                    final price = double.tryParse(priceController.text.trim());
                    if (titleController.text.trim().isEmpty || price == null) return;
                    await ref.read(marketplaceRepositoryProvider).createListing(
                          hotelId: selectedHotelId,
                          title: titleController.text.trim(),
                          description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                          listingType: listingType,
                          price: price,
                        );
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: Text(AppStrings.t(isArabic, 'publish')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

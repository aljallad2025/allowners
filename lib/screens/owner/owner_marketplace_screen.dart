import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../services/owner_service.dart';
import '../../services/api_client.dart';

class OwnerMarketplaceScreen extends ConsumerStatefulWidget {
  const OwnerMarketplaceScreen({super.key});

  @override
  ConsumerState<OwnerMarketplaceScreen> createState() => _OwnerMarketplaceScreenState();
}

class _OwnerMarketplaceScreenState extends ConsumerState<OwnerMarketplaceScreen> {
  final _service = OwnerService();
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getMarketplaceListings();
  }

  void _reload() => setState(() => _future = _service.getMarketplaceListings());

  Future<void> _openNewListingSheet(bool isArabic) async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String listingType = 'sale';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppDimens.pagePadding,
            right: AppDimens.pagePadding,
            top: AppDimens.pagePadding,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppDimens.pagePadding,
          ),
          child: StatefulBuilder(
            builder: (ctx, setSheetState) => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.t(isArabic, 'add_listing'), style: Theme.of(ctx).textTheme.titleMedium),
                  const SizedBox(height: AppDimens.md),
                  TextField(controller: titleCtrl, decoration: InputDecoration(labelText: AppStrings.t(isArabic, 'listing_title'))),
                  const SizedBox(height: AppDimens.md),
                  DropdownButtonFormField<String>(
                    value: listingType,
                    decoration: InputDecoration(labelText: AppStrings.t(isArabic, 'listing_type')),
                    items: [
                      DropdownMenuItem(value: 'sale', child: Text(AppStrings.t(isArabic, 'for_sale'))),
                      DropdownMenuItem(value: 'rent', child: Text(AppStrings.t(isArabic, 'for_rent'))),
                    ],
                    onChanged: (v) => setSheetState(() => listingType = v ?? 'sale'),
                  ),
                  const SizedBox(height: AppDimens.md),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: AppStrings.t(isArabic, 'price')),
                  ),
                  const SizedBox(height: AppDimens.md),
                  TextField(controller: descCtrl, maxLines: 3, decoration: InputDecoration(labelText: AppStrings.t(isArabic, 'description'))),
                  const SizedBox(height: AppDimens.lg),
                  SizedBox(
                    width: double.infinity,
                    height: AppDimens.buttonHeight,
                    child: ElevatedButton(
                      onPressed: titleCtrl.text.trim().isEmpty
                          ? null
                          : () async {
                              try {
                                await _service.createListing(
                                  title: titleCtrl.text.trim(),
                                  description: descCtrl.text.trim(),
                                  listingType: listingType,
                                  price: double.tryParse(priceCtrl.text.trim()),
                                );
                                if (ctx.mounted) Navigator.of(ctx).pop();
                                _reload();
                              } on ApiException catch (e) {
                                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                              }
                            },
                      child: Text(AppStrings.t(isArabic, 'submit')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _expressInterest(bool isArabic, int listingId) async {
    try {
      await _service.expressInterest(listingId);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.t(isArabic, 'interest_sent'))));
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(AppStrings.t(isArabic, 'units_marketplace')),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.gold,
        onPressed: () => _openNewListingSheet(isArabic),
        child: const Icon(Icons.add, color: AppColors.textOnGold),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _reload(),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppDimens.xl),
                  children: [
                    Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 32),
                    const SizedBox(height: AppDimens.sm),
                    Text(AppStrings.t(isArabic, 'error_loading'), textAlign: TextAlign.center),
                    const SizedBox(height: AppDimens.sm),
                    Center(child: OutlinedButton(onPressed: _reload, child: Text(AppStrings.t(isArabic, 'retry')))),
                  ],
                );
              }

              final listings = snapshot.data ?? [];
              if (listings.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppDimens.xl),
                      child: Center(child: Text(AppStrings.t(isArabic, 'no_listings'))),
                    ),
                  ],
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(AppDimens.pagePadding),
                itemCount: listings.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppDimens.md,
                  crossAxisSpacing: AppDimens.md,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (context, index) {
                  final l = listings[index];
                  final isMine = l['is_mine'] == true;
                  final isRent = l['listing_type'] == 'rent';
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 1.5,
                          child: l['image_url'] != null
                              ? Image.network(l['image_url'].toString(), fit: BoxFit.cover)
                              : Container(color: AppColors.surfaceMuted, child: const Icon(Icons.storefront_outlined, color: AppColors.textMuted)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppDimens.sm),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l['title'].toString(), style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text(
                                AppStrings.t(isArabic, isRent ? 'for_rent' : 'for_sale'),
                                style: textTheme.bodySmall?.copyWith(color: isRent ? AppColors.secondary : AppColors.goldDark, fontWeight: FontWeight.w600),
                              ),
                              if (l['price'] != null)
                                Text('${(l['price'] as num).toStringAsFixed(0)} ${AppStrings.t(isArabic, 'sar')}',
                                    style: textTheme.bodySmall?.copyWith(color: AppColors.success, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              if (!isMine)
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 6)),
                                    onPressed: () => _expressInterest(isArabic, l['id'] as int),
                                    child: Text(AppStrings.t(isArabic, 'im_interested'), style: const TextStyle(fontSize: 11)),
                                  ),
                                )
                              else
                                Text('${l['interest_count']} ${isArabic ? "مهتم" : "interested"}',
                                    style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted, fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

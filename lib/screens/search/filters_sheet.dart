import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';

class FiltersSheet extends ConsumerStatefulWidget {
  const FiltersSheet({super.key});

  @override
  ConsumerState<FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends ConsumerState<FiltersSheet> {
  RangeValues _priceRange = const RangeValues(200, 1500);
  int _selectedStars = 0;
  final Set<String> _selectedAmenities = {};

  final List<String> _amenityKeysAr = ['واي فاي مجاني', 'موقف سيارات', 'مسبح', 'صالة رياضية', 'إفطار مشمول'];
  final List<String> _amenityKeysEn = ['Free WiFi', 'Parking', 'Pool', 'Gym', 'Breakfast Included'];

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;
    final amenities = isArabic ? _amenityKeysAr : _amenityKeysEn;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXl)),
      ),
      padding: const EdgeInsets.all(AppDimens.pagePadding),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.cardBorder, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: AppDimens.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppStrings.t(isArabic, 'filters'), style: textTheme.headlineSmall),
                TextButton(
                  onPressed: () => setState(() {
                    _priceRange = const RangeValues(200, 1500);
                    _selectedStars = 0;
                    _selectedAmenities.clear();
                  }),
                  child: Text(AppStrings.t(isArabic, 'reset')),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.md),

            Text(AppStrings.t(isArabic, 'price_range'), style: textTheme.titleSmall),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 3000,
              divisions: 30,
              activeColor: AppColors.gold,
              inactiveColor: AppColors.surfaceMuted,
              labels: RangeLabels('${_priceRange.start.toInt()}', '${_priceRange.end.toInt()}'),
              onChanged: (values) => setState(() => _priceRange = values),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_priceRange.start.toInt()} ${AppStrings.t(isArabic, "sar")}',
                    style: textTheme.bodySmall),
                Text('${_priceRange.end.toInt()} ${AppStrings.t(isArabic, "sar")}',
                    style: textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: AppDimens.md),

            Text(AppStrings.t(isArabic, 'star_rating'), style: textTheme.titleSmall),
            const SizedBox(height: AppDimens.sm),
            Row(
              children: List.generate(5, (i) {
                final stars = i + 1;
                final selected = _selectedStars == stars;
                return Padding(
                  padding: const EdgeInsets.only(right: AppDimens.sm),
                  child: InkWell(
                    onTap: () => setState(() => _selectedStars = selected ? 0 : stars),
                    borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.ink : AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$stars',
                              style: TextStyle(
                                  color: selected ? Colors.white : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600)),
                          Icon(Icons.star_rounded,
                              size: 14, color: selected ? AppColors.gold : AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppDimens.md),

            Text(AppStrings.t(isArabic, 'amenities'), style: textTheme.titleSmall),
            const SizedBox(height: AppDimens.sm),
            Wrap(
              spacing: AppDimens.sm,
              runSpacing: AppDimens.sm,
              children: amenities.map((a) {
                final selected = _selectedAmenities.contains(a);
                return InkWell(
                  onTap: () => setState(() {
                    selected ? _selectedAmenities.remove(a) : _selectedAmenities.add(a);
                  }),
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.ink : AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                    ),
                    child: Text(
                      a,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppDimens.xl),

            SizedBox(
              width: double.infinity,
              height: AppDimens.buttonHeight,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppStrings.t(isArabic, 'apply_filters')),
              ),
            ),
            const SizedBox(height: AppDimens.lg),
          ],
        ),
      ),
    );
  }
}

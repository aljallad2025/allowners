import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';

class FiltersResult {
  final RangeValues priceRange;
  final int stars;
  final bool breakfastOnly;
  FiltersResult({required this.priceRange, required this.stars, required this.breakfastOnly});
}

class FiltersSheet extends ConsumerStatefulWidget {
  final RangeValues initialPriceRange;
  final int initialStars;
  final bool initialBreakfastOnly;

  const FiltersSheet({
    super.key,
    this.initialPriceRange = const RangeValues(0, 3000),
    this.initialStars = 0,
    this.initialBreakfastOnly = false,
  });

  @override
  ConsumerState<FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends ConsumerState<FiltersSheet> {
  late RangeValues _priceRange;
  late int _selectedStars;
  late bool _breakfastOnly;

  @override
  void initState() {
    super.initState();
    _priceRange = widget.initialPriceRange;
    _selectedStars = widget.initialStars;
    _breakfastOnly = widget.initialBreakfastOnly;
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;

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
                    _priceRange = const RangeValues(0, 3000);
                    _selectedStars = 0;
                    _breakfastOnly = false;
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

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(AppStrings.t(isArabic, 'breakfast_included')),
              value: _breakfastOnly,
              onChanged: (v) => setState(() => _breakfastOnly = v),
            ),
            const SizedBox(height: AppDimens.lg),

            SizedBox(
              width: double.infinity,
              height: AppDimens.buttonHeight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(
                    FiltersResult(priceRange: _priceRange, stars: _selectedStars, breakfastOnly: _breakfastOnly),
                  );
                },
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

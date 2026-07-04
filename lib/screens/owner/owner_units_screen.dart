import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../providers/owner_provider.dart';
import '../../providers/owner_hotel_mutations_provider.dart';
import 'add_unit_screen.dart';
import 'edit_unit_screen.dart';

class OwnerUnitsScreen extends ConsumerWidget {
  const OwnerUnitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;
    final unitsAsync = ref.watch(ownerUnitsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(AppStrings.t(isArabic, 'nav_units')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddUnitScreen()));
        },
        icon: const Icon(Icons.add),
        label: Text(AppStrings.t(isArabic, 'add_unit')),
      ),
      body: SafeArea(
        child: unitsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
          error: (err, st) => Center(
            child: Text(AppStrings.t(isArabic, 'something_went_wrong'),
                style: const TextStyle(color: AppColors.textMuted)),
          ),
          data: (units) {
            if (units.isEmpty) {
              return Center(
                child: Text(AppStrings.t(isArabic, 'no_hotels_found'),
                    style: const TextStyle(color: AppColors.textMuted)),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePadding, AppDimens.pagePadding, AppDimens.pagePadding, 90),
              itemCount: units.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppDimens.md),
              itemBuilder: (context, index) {
                final unit = units[index];
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
                          Expanded(child: Text(unit.name, style: textTheme.titleSmall)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: (unit.occupied ? AppColors.success : AppColors.textMuted)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                            ),
                            child: Text(
                              AppStrings.t(isArabic, unit.occupied ? 'occupied' : 'vacant'),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: unit.occupied ? AppColors.success : AppColors.textMuted,
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textMuted),
                            onSelected: (value) async {
                              if (value == 'edit') {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => EditUnitScreen(unit: unit)),
                                );
                              } else if (value == 'delete') {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(AppStrings.t(isArabic, 'confirm_delete')),
                                    content: Text(AppStrings.t(isArabic, 'confirm_delete_unit')),
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
                                  await ref.read(ownerHotelMutationsProvider).deleteUnit(unit.id);
                                }
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(value: 'edit', child: Text(AppStrings.t(isArabic, 'edit'))),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(AppStrings.t(isArabic, 'delete'),
                                    style: const TextStyle(color: AppColors.danger)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(unit.hotelName, style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                      const Divider(height: AppDimens.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppStrings.t(isArabic, 'monthly_revenue'),
                              style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                          Text('${unit.monthlyRevenue.toInt()} ${AppStrings.t(isArabic, 'sar')}',
                              style: textTheme.titleSmall?.copyWith(color: AppColors.goldDark)),
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

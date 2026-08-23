import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../services/owner_service.dart';

class OwnerUnitsScreen extends ConsumerStatefulWidget {
  const OwnerUnitsScreen({super.key});

  @override
  ConsumerState<OwnerUnitsScreen> createState() => _OwnerUnitsScreenState();
}

class _OwnerUnitsScreenState extends ConsumerState<OwnerUnitsScreen> {
  final _service = OwnerService();
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getUnits();
  }

  void _reload() => setState(() => _future = _service.getUnits());

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(AppStrings.t(isArabic, 'nav_units')),
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
                  children: [_ErrorBox(isArabic: isArabic, onRetry: _reload)],
                );
              }
              final units = snapshot.data ?? [];
              if (units.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppDimens.xl),
                      child: Center(child: Text(AppStrings.t(isArabic, 'no_units'))),
                    ),
                  ],
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(AppDimens.pagePadding),
                itemCount: units.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppDimens.md),
                itemBuilder: (context, index) {
                  final unit = units[index];
                  final active = unit['is_active'] == 1 || unit['is_active'] == true;
                  final name = isArabic ? (unit['name_ar'] ?? '') : (unit['name_en'] ?? unit['name_ar'] ?? '');
                  final hotel = unit['hotel_name'] ?? '';
                  final price = (unit['price_per_night'] is num) ? (unit['price_per_night'] as num).toStringAsFixed(0) : '0';
                  final images = (unit['images'] as List?)?.cast<String>() ?? const <String>[];
                  final coverImage = (unit['cover_image'] as String?)?.isNotEmpty == true
                      ? unit['cover_image'] as String
                      : (images.isNotEmpty ? images.first : null);

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
                        if (coverImage != null)
                          Image.network(coverImage, height: 130, width: double.infinity, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(height: 130, color: AppColors.surfaceMuted)),
                        Padding(
                          padding: const EdgeInsets.all(AppDimens.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(name, style: textTheme.titleSmall)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (active ? AppColors.success : AppColors.textMuted).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                                    ),
                                    child: Text(
                                      AppStrings.t(isArabic, active ? 'occupied' : 'vacant'),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: active ? AppColors.success : AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(hotel.toString(), style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                              const Divider(height: AppDimens.lg),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(AppStrings.t(isArabic, 'monthly_revenue'),
                                      style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                                  Text('$price ${AppStrings.t(isArabic, 'sar')}',
                                      style: textTheme.titleSmall?.copyWith(color: AppColors.goldDark)),
                                ],
                              ),
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

class _ErrorBox extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onRetry;
  const _ErrorBox({required this.isArabic, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.xl),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 32),
          const SizedBox(height: AppDimens.sm),
          Text(AppStrings.t(isArabic, 'error_loading'), textAlign: TextAlign.center),
          const SizedBox(height: AppDimens.sm),
          OutlinedButton(onPressed: onRetry, child: Text(AppStrings.t(isArabic, 'retry'))),
        ],
      ),
    );
  }
}

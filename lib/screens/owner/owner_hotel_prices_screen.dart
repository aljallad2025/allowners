import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/owner_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/locale_provider.dart';
import '../../utils/tr.dart';

/// أسعار خدمات الفندق (نظافة / صيانة / وجبات / سرير إضافي) — المالك يطّلع عليها فقط،
/// وإدارة الفندق هي من تحددها.
class OwnerHotelPricesScreen extends ConsumerStatefulWidget {
  const OwnerHotelPricesScreen({super.key});

  @override
  ConsumerState<OwnerHotelPricesScreen> createState() => _OwnerHotelPricesScreenState();
}

class _OwnerHotelPricesScreenState extends ConsumerState<OwnerHotelPricesScreen> {
  final _service = OwnerService();
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getHotelPrices();
  }

  void _reload() => setState(() => _future = _service.getHotelPrices());

  static const _order = ['cleaning', 'maintenance', 'meal', 'extra_bed'];

  String _typeLabel(String t, bool ar) {
    switch (t) {
      case 'cleaning':
        return tr(ar, 'النظافة', 'Cleaning');
      case 'maintenance':
        return tr(ar, 'الصيانة', 'Maintenance');
      case 'meal':
        return tr(ar, 'الوجبات', 'Meals');
      default:
        return tr(ar, 'السرير الإضافي', 'Extra bed');
    }
  }

  IconData _typeIcon(String t) {
    switch (t) {
      case 'cleaning':
        return Icons.cleaning_services_outlined;
      case 'maintenance':
        return Icons.build_outlined;
      case 'meal':
        return Icons.restaurant_outlined;
      default:
        return Icons.bed_outlined;
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
        title: Text(tr(isArabic, 'أسعار خدمات الفندق', 'Hotel service prices')),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _reload(),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.gold));
              }
              if (snapshot.hasError) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppDimens.xl),
                  children: [
                    Text(snapshot.error.toString(), textAlign: TextAlign.center),
                    Center(child: TextButton(onPressed: _reload, child: Text(tr(isArabic, 'إعادة المحاولة', 'Retry')))),
                  ],
                );
              }
              final prices = snapshot.data ?? const [];
              if (prices.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppDimens.xl),
                      child: Center(
                        child: Text(
                          tr(isArabic, 'لم تحدد إدارة الفندق أسعار الخدمات بعد', 'The hotel has not set service prices yet'),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                );
              }

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppDimens.pagePadding),
                children: [
                  for (final type in _order)
                    if (prices.any((p) => p['service_type'] == type)) ...[
                      Row(
                        children: [
                          Icon(_typeIcon(type), color: AppColors.goldDark, size: 20),
                          const SizedBox(width: AppDimens.sm),
                          Text(_typeLabel(type, isArabic), style: textTheme.titleMedium),
                        ],
                      ),
                      const SizedBox(height: AppDimens.sm),
                      for (final p in prices.where((p) => p['service_type'] == type))
                        Container(
                          margin: const EdgeInsets.only(bottom: AppDimens.sm),
                          padding: const EdgeInsets.all(AppDimens.md),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${isArabic ? p['title_ar'] : p['title_en']}',
                                      style: textTheme.titleSmall,
                                    ),
                                    Text(
                                      '${p['hotel_name'] ?? ''}${p['unit_name_ar'] != null ? ' — ${isArabic ? p['unit_name_ar'] : (p['unit_name_en'] ?? p['unit_name_ar'])}' : ''}',
                                      style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${(p['price'] as num).toStringAsFixed(0)} ${tr(isArabic, 'ريال', 'SAR')}',
                                style: textTheme.titleSmall?.copyWith(color: AppColors.goldDark),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: AppDimens.md),
                    ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

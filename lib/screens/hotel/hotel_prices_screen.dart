import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_client.dart';
import '../../services/hotel_staff_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/locale_provider.dart';
import '../../utils/tr.dart';

/// أسعار خدمات الفندق — تحددها إدارة الفندق (نظافة حسب كل جناح، صيانة، وجبات، سرير إضافي) ويطّلع عليها المالك
class HotelPricesScreen extends ConsumerStatefulWidget {
  const HotelPricesScreen({super.key});

  @override
  ConsumerState<HotelPricesScreen> createState() => _HotelPricesScreenState();
}

class _HotelPricesScreenState extends ConsumerState<HotelPricesScreen> {
  final _service = HotelStaffService();
  late Future<Map<String, dynamic>> _future;

  static const _types = ['cleaning', 'maintenance', 'meal', 'extra_bed'];

  @override
  void initState() {
    super.initState();
    _future = _service.getPrices();
  }

  void _reload() => setState(() => _future = _service.getPrices());

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

  Future<void> _edit(Map<String, dynamic> data, Map<String, dynamic>? existing, bool isArabic) async {
    final hotels = (data['hotels'] as List).cast<Map<String, dynamic>>();
    final units = (data['units'] as List).cast<Map<String, dynamic>>();
    if (hotels.isEmpty) return;

    String type = existing?['service_type']?.toString() ?? 'cleaning';
    int hotelId = (existing?['hotel_id'] as num?)?.toInt() ?? (hotels.first['id'] as num).toInt();
    int? unitId = (existing?['unit_id'] as num?)?.toInt();
    final titleArCtrl = TextEditingController(text: existing?['title_ar']?.toString() ?? '');
    final titleEnCtrl = TextEditingController(text: existing?['title_en']?.toString() ?? '');
    final priceCtrl = TextEditingController(text: existing != null ? (existing['price'] as num).toStringAsFixed(0) : '');

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) {
          final hotelUnits = units.where((u) => (u['hotel_id'] as num).toInt() == hotelId).toList();
          if (unitId != null && !hotelUnits.any((u) => (u['id'] as num).toInt() == unitId)) unitId = null;
          return AlertDialog(
            title: Text(existing == null ? tr(isArabic, 'سعر جديد', 'New price') : tr(isArabic, 'تعديل السعر', 'Edit price')),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: type,
                    decoration: InputDecoration(labelText: tr(isArabic, 'نوع الخدمة', 'Service')),
                    items: [for (final t in _types) DropdownMenuItem(value: t, child: Text(_typeLabel(t, isArabic)))],
                    onChanged: (v) => setDialog(() => type = v ?? type),
                  ),
                  if (hotels.length > 1) ...[
                    const SizedBox(height: AppDimens.sm),
                    DropdownButtonFormField<int>(
                      value: hotelId,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: tr(isArabic, 'الفندق', 'Hotel')),
                      items: [
                        for (final h in hotels)
                          DropdownMenuItem(value: (h['id'] as num).toInt(), child: Text('${h['name']}', overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (v) => setDialog(() => hotelId = v ?? hotelId),
                    ),
                  ],
                  const SizedBox(height: AppDimens.sm),
                  DropdownButtonFormField<int?>(
                    value: unitId,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: tr(isArabic, 'الجناح / الوحدة', 'Suite / unit')),
                    items: [
                      DropdownMenuItem<int?>(value: null, child: Text(tr(isArabic, 'كل الوحدات (سعر عام)', 'All units (general price)'))),
                      for (final u in hotelUnits)
                        DropdownMenuItem<int?>(
                          value: (u['id'] as num).toInt(),
                          child: Text('${isArabic ? u['name_ar'] : (u['name_en'] ?? u['name_ar'])}', overflow: TextOverflow.ellipsis),
                        ),
                    ],
                    onChanged: (v) => setDialog(() => unitId = v),
                  ),
                  const SizedBox(height: AppDimens.sm),
                  TextField(controller: titleArCtrl, decoration: InputDecoration(labelText: tr(isArabic, 'الاسم بالعربي (اختياري)', 'Arabic title (optional)'))),
                  const SizedBox(height: AppDimens.sm),
                  TextField(controller: titleEnCtrl, decoration: InputDecoration(labelText: tr(isArabic, 'الاسم بالإنجليزي (اختياري)', 'English title (optional)'))),
                  const SizedBox(height: AppDimens.sm),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: tr(isArabic, 'السعر (ريال)', 'Price (SAR)')),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr(isArabic, 'إلغاء', 'Cancel'))),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(tr(isArabic, 'حفظ', 'Save'))),
            ],
          );
        },
      ),
    );
    final price = double.tryParse(priceCtrl.text.trim());
    final titleAr = titleArCtrl.text.trim();
    final titleEn = titleEnCtrl.text.trim();
    if (ok != true) return;
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(isArabic, 'أدخل سعراً صحيحاً', 'Enter a valid price'))));
      return;
    }
    try {
      await _service.savePrice(
        id: (existing?['id'] as num?)?.toInt(),
        hotelId: hotelId,
        unitId: unitId,
        serviceType: type,
        titleAr: titleAr,
        titleEn: titleEn,
        price: price,
      );
      _reload();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _delete(int id) async {
    try {
      await _service.deletePrice(id);
      _reload();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;

    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            title: Text(tr(isArabic, 'أسعار الخدمات', 'Service prices')),
          ),
          floatingActionButton: data == null
              ? null
              : FloatingActionButton.extended(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.white,
                  onPressed: () => _edit(data, null, isArabic),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(tr(isArabic, 'إضافة سعر', 'Add price')),
                ),
          body: SafeArea(
            child: snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                : snapshot.hasError
                    ? ListView(
                        padding: const EdgeInsets.all(AppDimens.xl),
                        children: [
                          Text(snapshot.error.toString(), textAlign: TextAlign.center),
                          Center(child: TextButton(onPressed: _reload, child: Text(tr(isArabic, 'إعادة المحاولة', 'Retry')))),
                        ],
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _reload(),
                        child: Builder(builder: (context) {
                          final d = data!;
                          final prices = (d['prices'] as List).cast<Map<String, dynamic>>();
                          if (prices.isEmpty) {
                            return ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(AppDimens.xl),
                                  child: Center(
                                    child: Text(
                                      tr(isArabic, 'لم تُضف أسعاراً بعد — اضغط «إضافة سعر»', 'No prices yet — tap "Add price"'),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                          return ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, AppDimens.pagePadding, AppDimens.pagePadding, 96),
                            children: [
                              for (final t in _types)
                                if (prices.any((p) => p['service_type'] == t)) ...[
                                  Text(_typeLabel(t, isArabic), style: textTheme.titleMedium),
                                  const SizedBox(height: AppDimens.sm),
                                  for (final p in prices.where((p) => p['service_type'] == t))
                                    Container(
                                      margin: const EdgeInsets.only(bottom: AppDimens.sm),
                                      padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: AppDimens.sm),
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
                                                Text('${isArabic ? p['title_ar'] : p['title_en']}', style: textTheme.titleSmall),
                                                Text(
                                                  '${p['hotel_name'] ?? ''}${p['unit_name_ar'] != null ? ' — ${isArabic ? p['unit_name_ar'] : (p['unit_name_en'] ?? p['unit_name_ar'])}' : ' — ${tr(isArabic, 'سعر عام', 'general')}'}',
                                                  style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text('${(p['price'] as num).toStringAsFixed(0)} ${tr(isArabic, 'ريال', 'SAR')}',
                                              style: textTheme.titleSmall?.copyWith(color: AppColors.goldDark)),
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, size: 20),
                                            onPressed: () => _edit(d, p, isArabic),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.danger),
                                            onPressed: () => _delete((p['id'] as num).toInt()),
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(height: AppDimens.md),
                                ],
                            ],
                          );
                        }),
                      ),
          ),
        );
      },
    );
  }
}
